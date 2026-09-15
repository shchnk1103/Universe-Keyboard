from __future__ import annotations

import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "release_evidence.py"
SPEC = importlib.util.spec_from_file_location("release_evidence", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


def candidate_receipt(
    kind: str,
    *,
    build: str = "55",
    package: str = "a" * 64,
    created_at: str = "2026-09-14T00:00:00Z",
    device_model: str = "iPhone 17 Pro",
    os_version: str = "iOS 26.0",
    behavior_contract: str = "keyboard-behavior-v1",
    recorded_at: str = "2026-09-13T12:00:00Z",
) -> dict:
    receipt = {
        "schema_version": MODULE.SCHEMA_VERSION,
        "receipt_contract_version": MODULE.RECEIPT_CONTRACT_VERSION,
        "record_type": "release_candidate_receipt",
        "receipt_id": f"{kind}-receipt",
        "created_at": created_at,
        "candidate_kind": kind,
        "candidate_fact_tuple": {
            "source_commit": "b" * 40,
            "version": "1.0",
            "build": build,
            "candidate_id": f"candidate-{build}",
            "archive_sha256": "c" * 64,
            "package_sha256": package,
        },
        "candidate_context": {
            "behavior_contract": behavior_contract,
            "device_model": device_model,
            "os_version": os_version,
            "validation_profile": "delta",
        },
        "validation_plan": {
            "record_type": "release_validation_plan",
            "schema_version": MODULE.SCHEMA_VERSION,
            "base_sha": "a" * 40,
            "head_sha": "b" * 40,
            "release_validation": {
                "profile": "delta",
                "reason": "ordinary_app_change",
                "first_external_candidate": False,
            },
        },
        "evidence_runs": [
            {
                "id": "daily-run-1",
                "claim": "affected path smoke",
                "outcome": "pass",
                "lane": "daily_beta",
                "profile": "delta",
                "candidate_id": f"candidate-{build}",
                "app_version": "1.0",
                "app_build": build,
                "device_model": device_model,
                "os_version": os_version,
                "behavior_contract": behavior_contract,
                "recorded_at": recorded_at,
                "evidence_contract_version": MODULE.EVIDENCE_CONTRACT_VERSION,
                "source": "main_app_release_evidence",
            }
        ],
        "non_claims": [],
    }
    if kind == "external_candidate":
        receipt["external_candidate_provenance"] = {
            "mode": "subsequent_external_candidate",
            "previous_receipt_id": "external-baseline",
            "previous_receipt_sha256": "d" * 64,
        }
    return receipt


class ReleaseClassificationTests(unittest.TestCase):
    def test_ordinary_app_change_is_delta_but_ci_stays_full(self) -> None:
        result = MODULE.classify_paths(["Universe Keyboard/Views/Home/HomeTab.swift"])
        self.assertEqual(result.profile, "delta")
        self.assertEqual(result.ci_classification, "full")
        self.assertIn("main_app", result.affected_areas)

    def test_rime_or_toolchain_change_is_baseline(self) -> None:
        result = MODULE.classify_paths(
            ["Packages/RimeBridge/Sources/RimeBridge/RimeEngine.swift"]
        )
        self.assertEqual(result.profile, "baseline")
        self.assertIn("rime_runtime", result.affected_areas)

    def test_keyboard_change_is_triggered(self) -> None:
        result = MODULE.classify_paths(["Keyboard/Controllers/KeyboardViewController.swift"])
        self.assertEqual(result.profile, "triggered")
        self.assertIn("keyboard_extension", result.affected_areas)

    def test_documentation_change_has_no_candidate_runtime_checks(self) -> None:
        result = MODULE.classify_paths(["docs/RELEASE_CHECKLIST.md", "README.md"])
        self.assertEqual(result.profile, "docs_only")
        self.assertEqual(result.ci_classification, "docs_only")

    def test_empty_diff_fails_closed(self) -> None:
        result = MODULE.classify_paths([])
        self.assertEqual(result.profile, "baseline")
        self.assertEqual(result.reason, "empty_diff_fails_closed")

    def test_unsafe_path_fails_closed(self) -> None:
        result = MODULE.classify_paths(["../outside/Feature.swift"])
        self.assertEqual(result.profile, "baseline")
        self.assertEqual(result.reason, "unsafe_changed_path_fails_closed")

    def test_xcode_project_change_is_baseline(self) -> None:
        result = MODULE.classify_paths(
            ["Universe Keyboard.xcodeproj/project.pbxproj"]
        )
        self.assertEqual(result.profile, "baseline")

    def test_first_external_candidate_requires_baseline(self) -> None:
        result = MODULE.classify_paths(
            ["Universe Keyboard/Views/Home/HomeTab.swift"],
            first_external_candidate=True,
        )
        self.assertEqual(result.profile, "baseline")
        self.assertEqual(result.reason, "first_external_candidate_requires_baseline")
        self.assertIn("artifact_identity", result.affected_areas)
        self.assertEqual(result.ci_classification, "full")

    def test_plan_schema_and_commit_identity_are_validated(self) -> None:
        valid_plan = {
            "record_type": "release_validation_plan",
            "schema_version": MODULE.SCHEMA_VERSION,
            "base_sha": "a" * 40,
            "head_sha": "b" * 40,
            "release_validation": {"profile": "delta"},
        }
        MODULE.validate_plan(valid_plan)

        invalid_plan = dict(valid_plan)
        invalid_plan["head_sha"] = MODULE.UNKNOWN
        with self.assertRaises(ValueError):
            MODULE.validate_plan(invalid_plan)


class PromotionTests(unittest.TestCase):
    def test_without_target_receipt_promotion_stays_pending(self) -> None:
        source = candidate_receipt("daily_beta")
        promoted = MODULE.promote_receipt(source)

        self.assertEqual(promoted["candidate_kind"], "external_candidate")
        self.assertEqual(promoted["promotion"]["mode"], "pending_artifact_match")
        self.assertEqual(
            promoted["promotion"]["reused_evidence"][0]["reusable_as"], "none"
        )
        self.assertEqual(promoted["promotion"]["baseline_proof"], "not_verified")

    def test_same_complete_artifact_with_matching_context_becomes_current_proof(self) -> None:
        source = candidate_receipt("daily_beta")
        target = candidate_receipt(
            "external_candidate", created_at="2026-09-14T01:00:00Z"
        )
        promoted = MODULE.promote_receipt(source, target)

        self.assertEqual(promoted["candidate_kind"], "external_candidate")
        self.assertEqual(promoted["promotion"]["mode"], "exact_artifact")
        self.assertEqual(
            promoted["promotion"]["reused_evidence"][0]["reusable_as"], "current-proof"
        )
        self.assertIn("product_release_gate", promoted["promotion"]["required_current_delta"])
        self.assertIn(
            "artifact_identity_and_evidence_context",
            promoted["promotion"]["required_current_delta"],
        )

    def test_new_build_keeps_beta_evidence_as_comparator(self) -> None:
        source = candidate_receipt("daily_beta", build="55")
        target = candidate_receipt("external_candidate", build="56")
        promoted = MODULE.promote_receipt(source, target)

        self.assertEqual(promoted["promotion"]["mode"], "contract_baseline")
        self.assertEqual(
            promoted["promotion"]["reused_evidence"][0]["reusable_as"], "comparator"
        )

    def test_promotion_rejects_a_beta_receipt_as_target(self) -> None:
        source = candidate_receipt("daily_beta")
        target = candidate_receipt("daily_beta", build="56")

        with self.assertRaises(ValueError):
            MODULE.promote_receipt(source, target)

    def test_same_commit_and_build_without_package_hash_is_only_baseline(self) -> None:
        source = candidate_receipt("daily_beta", package=MODULE.UNKNOWN)
        target = candidate_receipt("external_candidate", package=MODULE.UNKNOWN)
        promoted = MODULE.promote_receipt(source, target)

        self.assertEqual(promoted["promotion"]["mode"], "contract_baseline")
        self.assertEqual(
            promoted["promotion"]["reused_evidence"][0]["reusable_as"], "comparator"
        )

    def test_malformed_artifact_digest_cannot_be_exact_identity(self) -> None:
        source = candidate_receipt("daily_beta")
        target = candidate_receipt("external_candidate")
        source["candidate_fact_tuple"]["archive_sha256"] = "same-value"
        target["candidate_fact_tuple"]["archive_sha256"] = "same-value"
        promoted = MODULE.promote_receipt(source, target)

        self.assertEqual(promoted["promotion"]["mode"], "contract_baseline")
        self.assertEqual(
            promoted["promotion"]["reused_evidence"][0]["reusable_as"], "comparator"
        )

    def test_exact_artifact_without_behavior_context_is_not_current_proof(self) -> None:
        source = candidate_receipt("daily_beta", behavior_contract=MODULE.UNKNOWN)
        target = candidate_receipt(
            "external_candidate",
            behavior_contract=MODULE.UNKNOWN,
            created_at="2026-09-14T01:00:00Z",
        )
        promoted = MODULE.promote_receipt(source, target)

        self.assertEqual(promoted["promotion"]["mode"], "exact_artifact")
        self.assertEqual(
            promoted["promotion"]["reused_evidence"][0]["reusable_as"], "none"
        )

    def test_exact_artifact_with_stale_evidence_is_not_current_proof(self) -> None:
        source = candidate_receipt(
            "daily_beta", recorded_at="2026-08-01T12:00:00Z"
        )
        target = candidate_receipt(
            "external_candidate", created_at="2026-09-14T01:00:00Z"
        )
        promoted = MODULE.promote_receipt(source, target)

        self.assertEqual(
            promoted["promotion"]["reused_evidence"][0]["reusable_as"], "none"
        )

    def test_exact_artifact_with_different_environment_is_not_current_proof(self) -> None:
        source = candidate_receipt("daily_beta")
        target = candidate_receipt(
            "external_candidate",
            device_model="iPad Pro",
            created_at="2026-09-14T01:00:00Z",
        )
        promoted = MODULE.promote_receipt(source, target)

        self.assertEqual(promoted["promotion"]["mode"], "exact_artifact")
        self.assertEqual(
            promoted["promotion"]["reused_evidence"][0]["reusable_as"], "none"
        )

    def test_exact_artifact_with_different_candidate_id_is_not_current_proof(self) -> None:
        source = candidate_receipt("daily_beta")
        target = candidate_receipt(
            "external_candidate", created_at="2026-09-14T01:00:00Z"
        )
        target["candidate_fact_tuple"]["candidate_id"] = "different-candidate"

        promoted = MODULE.promote_receipt(source, target)

        self.assertEqual(promoted["promotion"]["mode"], "exact_artifact")
        self.assertEqual(
            promoted["promotion"]["reused_evidence"][0]["reusable_as"], "none"
        )

    def test_receipt_hashes_are_deterministic_for_directory(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "b.txt").write_text("b", encoding="utf-8")
            (root / "a.txt").write_text("a", encoding="utf-8")
            first = MODULE.sha256_directory(str(root))
            (root / "a.txt").write_text("changed", encoding="utf-8")
            second = MODULE.sha256_directory(str(root))

        self.assertNotEqual(first, second)


class ReceiptContractTests(unittest.TestCase):
    def test_external_receipt_without_baseline_or_previous_receipt_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            plan_path = Path(directory) / "plan.json"
            plan_path.write_text(
                json.dumps(candidate_receipt("daily_beta")["validation_plan"]),
                encoding="utf-8",
            )
            args = MODULE.build_parser().parse_args(
                [
                    "receipt",
                    "--plan",
                    str(plan_path),
                    "--kind",
                    "external_candidate",
                    "--version",
                    "1.0",
                    "--build",
                    "56",
                    "--output",
                    str(Path(directory) / "receipt.json"),
                ]
            )
            with self.assertRaisesRegex(ValueError, "requires first external baseline"):
                MODULE.receipt_payload(args)

    def test_first_external_receipt_requires_and_accepts_verified_plan_marker(self) -> None:
        plan = candidate_receipt("daily_beta")["validation_plan"]
        plan["release_validation"] = {
            "profile": "baseline",
            "reason": "first_external_candidate_requires_baseline",
            "first_external_candidate": True,
        }
        with tempfile.TemporaryDirectory() as directory:
            plan_path = Path(directory) / "plan.json"
            plan_path.write_text(json.dumps(plan), encoding="utf-8")
            args = MODULE.build_parser().parse_args(
                [
                    "receipt",
                    "--plan",
                    str(plan_path),
                    "--kind",
                    "external_candidate",
                    "--version",
                    "1.0",
                    "--build",
                    "56",
                    "--behavior-contract",
                    "keyboard-behavior-v1",
                    "--device-model",
                    "iPhone 17 Pro",
                    "--os-version",
                    "iOS 26.0",
                    "--output",
                    str(Path(directory) / "receipt.json"),
                ]
            )
            receipt = MODULE.receipt_payload(args)

        self.assertEqual(
            receipt["external_candidate_provenance"]["mode"],
            "first_external_candidate",
        )


if __name__ == "__main__":
    unittest.main()
