#!/usr/bin/env python3
"""Focused tests for the Universe Keyboard KOS release-evidence adapter."""

from __future__ import annotations

import copy
import json
import sys
import unittest
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPT_DIR))

import kos_release_evidence_adapter as adapter  # noqa: E402
import run_kos_release_evidence_fixtures as fixture_runner  # noqa: E402


FIXTURE_PATH = SCRIPT_DIR / "fixtures" / "kos_release_evidence_cases.json"


class ReleaseEvidenceAdapterTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.fixture = json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))
        cls.base = cls.fixture["base_input"]

    def test_main_app_export_maps_to_allowlisted_content_free_envelope(self) -> None:
        envelope = adapter.build_envelope(copy.deepcopy(self.base))

        self.assertEqual(envelope["contract"], adapter.CONTRACT)
        self.assertEqual(envelope["candidate"]["candidate_id"], "Build-56")
        self.assertEqual(
            [item["claim_ref"] for item in envelope["policy"]["required_claim_bindings"]],
            [
                "UK-RE-CANDIDATE-IDENTITY",
                "UK-RE-CHANGED-PATH-VALIDATION",
                "UK-RE-AFFECTED-PATH-SMOKE",
            ],
        )
        self.assertTrue(
            all(
                item["evidence_ref"].startswith("appdiag://release-evidence/")
                for item in envelope["observations"]
            )
        )
        serialized = json.dumps(envelope, ensure_ascii=False)
        self.assertNotIn("fixture note", serialized)
        self.assertNotIn('"note"', serialized)
        self.assertNotIn("nonClaims", serialized)
        self.assertNotIn("raw_user_input", serialized)

    def test_default_receipts_are_not_false_current_proof_inputs(self) -> None:
        payload = copy.deepcopy(self.base)
        payload.pop("delivery")
        payload.pop("final_validation")

        envelope = adapter.build_envelope(payload)

        self.assertEqual(envelope["delivery"]["hosted_ci_result"], "not-run")
        self.assertEqual(envelope["final_validation"]["result"], "not-run")
        self.assertEqual(envelope["final_validation"]["exit_code"], 255)
        self.assertEqual(envelope["final_validation"]["output_ref"], adapter.UNKNOWN)

    def test_main_app_partial_outcome_maps_to_kos_inconclusive(self) -> None:
        payload = copy.deepcopy(self.base)
        payload["main_app_export"]["run"]["steps"][0]["outcome"] = "partial"
        payload["main_app_export"]["outcome"] = "partial"

        envelope = adapter.build_envelope(payload)

        self.assertEqual(
            envelope["observations"][0]["observation_outcome"], "inconclusive"
        )

    def test_unresolved_source_binding_cannot_produce_current_proof(self) -> None:
        envelope = adapter.build_envelope(copy.deepcopy(self.base))

        self.assertEqual(
            {item["observation_outcome"] for item in envelope["observations"]},
            {"inconclusive"},
        )

        for binding_alias in self.fixture["f001_negative_coverage"][
            "caller_binding_aliases"
        ]:
            with self.subTest(binding_alias=binding_alias):
                payload = copy.deepcopy(self.base)
                payload["main_app_source"][binding_alias] = True
                with self.assertRaises(adapter.AdapterInputError):
                    adapter.build_envelope(payload)

    def test_main_app_source_identity_must_be_resolved(self) -> None:
        unresolved_values = self.fixture["f001_negative_coverage"][
            "unresolved_record_ids"
        ]
        for unresolved in unresolved_values:
            with self.subTest(unresolved=unresolved):
                payload = copy.deepcopy(self.base)
                payload["main_app_source"]["record_id"] = unresolved

                with self.assertRaisesRegex(
                    adapter.AdapterInputError, "main_app_source.record_id is unresolved"
                ):
                    adapter.build_envelope(payload)

    def test_main_app_source_must_bind_the_canonical_store(self) -> None:
        foreign_identities = self.fixture["f001_negative_coverage"][
            "foreign_source_identities"
        ]
        for source_identity in foreign_identities:
            with self.subTest(source_identity=source_identity):
                payload = copy.deepcopy(self.base)
                payload["main_app_source"]["source_identity"] = source_identity
                with self.assertRaises(adapter.AdapterInputError):
                    adapter.build_envelope(payload)

        for extra_key in self.fixture["f001_negative_coverage"]["extra_source_keys"]:
            with self.subTest(extra_key=extra_key):
                payload = copy.deepcopy(self.base)
                payload["main_app_source"][extra_key] = "ignored"
                with self.assertRaises(adapter.AdapterInputError):
                    adapter.build_envelope(payload)

    def test_main_app_source_requires_each_canonical_key(self) -> None:
        missing_keys = self.fixture["f001_negative_coverage"][
            "missing_source_keys"
        ]
        for missing_key in missing_keys:
            with self.subTest(missing_key=missing_key):
                payload = copy.deepcopy(self.base)
                del payload["main_app_source"][missing_key]
                with self.assertRaisesRegex(
                    adapter.AdapterInputError, "canonical source seam"
                ):
                    adapter.build_envelope(payload)

    def test_main_app_wrapper_versions_and_direct_run_are_rejected(self) -> None:
        for field, value in (
            ("schemaVersion", 999),
            ("evidenceContractVersion", "foreign-contract"),
        ):
            with self.subTest(field=field):
                payload = copy.deepcopy(self.base)
                payload["main_app_export"][field] = value
                with self.assertRaises(adapter.AdapterInputError):
                    adapter.build_envelope(payload)

        payload = copy.deepcopy(self.base)
        payload["main_app_export"] = copy.deepcopy(payload["main_app_export"]["run"])
        with self.assertRaisesRegex(
            adapter.AdapterInputError, "canonical Main-App export shape"
        ):
            adapter.build_envelope(payload)

    def test_main_app_wrapper_requires_canonical_outcome_and_non_claims(self) -> None:
        payload = copy.deepcopy(self.base)
        payload["main_app_export"]["nonClaims"] = ["grant_release"]
        with self.assertRaisesRegex(
            adapter.AdapterInputError, "nonClaims must match"
        ):
            adapter.build_envelope(payload)

        payload = copy.deepcopy(self.base)
        payload["main_app_export"]["outcome"] = "fail"
        with self.assertRaisesRegex(
            adapter.AdapterInputError, "outcome does not match"
        ):
            adapter.build_envelope(payload)

        payload = copy.deepcopy(self.base)
        payload["main_app_export"]["run"]["raw_user_input"] = "SENSITIVE"
        with self.assertRaises(adapter.AdapterInputError):
            adapter.build_envelope(payload)

        payload = copy.deepcopy(self.base)
        payload["main_app_export"]["run"]["steps"] = {
            "candidate_identity": "pass",
            "changed_path_validation": "pass",
            "affected_path_smoke": "pass",
        }
        with self.assertRaisesRegex(adapter.AdapterInputError, "canonical array"):
            adapter.build_envelope(payload)

        payload = copy.deepcopy(self.base)
        payload["main_app_export"]["run"]["steps"][0]["raw_user_input"] = "SENSITIVE"
        with self.assertRaises(adapter.AdapterInputError):
            adapter.build_envelope(payload)

    def test_fixture_matrix_has_the_fixed_inventory(self) -> None:
        envelope_ids = tuple(case["fixture_id"] for case in self.fixture["cases"])
        delta_ids = tuple(
            case["fixture_id"] for case in self.fixture["delta_cases"]
        )

        self.assertEqual(envelope_ids, fixture_runner.EXPECTED_ENVELOPE_FIXTURE_IDS)
        self.assertEqual(delta_ids, fixture_runner.EXPECTED_DELTA_FIXTURE_IDS)

    def test_nested_identity_and_receipt_values_are_allowlisted(self) -> None:
        payload = copy.deepcopy(self.base)
        payload["candidate"]["artifact_identity"]["raw_user_input"] = "SENSITIVE"
        with self.assertRaises(adapter.AdapterInputError):
            adapter.build_envelope(payload)

        for location in ("candidate", "provenance", "evidence"):
            with self.subTest(location=location):
                payload = copy.deepcopy(self.base)
                payload[location]["raw_user_input"] = "SENSITIVE"
                with self.assertRaises(adapter.AdapterInputError):
                    adapter.build_envelope(payload)

        payload = copy.deepcopy(self.base)
        payload["raw_user_input"] = "SENSITIVE"
        with self.assertRaises(adapter.AdapterInputError):
            adapter.build_envelope(payload)

        payload = copy.deepcopy(self.base)
        payload["final_validation"]["checker_version"] = "contains narrative text"
        with self.assertRaises(adapter.AdapterInputError):
            adapter.build_envelope(payload)

    def test_pointer_paths_and_appdiag_uuids_are_canonical(self) -> None:
        for pointer in (
            "repo://../outside#artifact;sha256=" + "a" * 64 + ";class=release-candidate",
            "repo:///etc/passwd#artifact;sha256=" + "b" * 64 + ";class=release-candidate",
            "repo://foo/../bar#artifact;sha256=" + "c" * 64 + ";class=release-candidate",
        ):
            with self.subTest(pointer=pointer):
                payload = copy.deepcopy(self.base)
                payload["candidate"]["artifact_or_input_ref"] = pointer
                with self.assertRaises(adapter.AdapterInputError):
                    adapter.build_envelope(payload)

        payload = copy.deepcopy(self.base)
        payload["candidate"]["environment_ref"] = (
            "appdiag://release-evidence/RUN-DAILY-56/"
            "00000000-0000-4000-8000-00000000005A;sha256="
            + "d" * 64
            + ";class=diagnostic-short"
        )
        with self.assertRaises(adapter.AdapterInputError):
            adapter.build_envelope(payload)

    def test_external_candidate_requires_explicit_promotion_history(self) -> None:
        payload = copy.deepcopy(self.base)
        payload["main_app_export"]["run"]["lane"] = "external_candidate"
        payload["main_app_export"]["run"]["profile"] = "baseline"
        payload["main_app_export"]["run"]["promotionMode"] = "pending_artifact_match"
        payload["main_app_export"]["outcome"] = "partial"
        payload["candidate"] = {
            "artifact_identity": copy.deepcopy(
                self.base["candidate"]["artifact_identity"]
            ),
            "context_identity": {
                "behavior_contract": "keyboard-behavior-v1",
                "device_model": "iPhone17,1",
                "os_version": "iOS-26.0",
                "validation_profile": "baseline",
            },
            "artifact_or_input_ref": self.base["candidate"]["artifact_or_input_ref"],
            "environment_ref": self.base["candidate"]["environment_ref"],
            "comparison_basis": self.base["candidate"]["comparison_basis"],
            "profile_ref": adapter.PROFILE_ID,
            "final_tree_digest": self.base["candidate"]["final_tree_digest"],
            "candidate_head": self.base["candidate"]["candidate_head"],
        }
        payload["delivery"]["context_identity"]["validation_profile"] = "baseline"
        payload["final_validation"]["context_identity"]["validation_profile"] = "baseline"

        with self.assertRaisesRegex(
            adapter.AdapterInputError, "must declare first/subsequent promotion"
        ):
            adapter.build_envelope(payload)

    def test_external_first_and_subsequent_history_are_bound(self) -> None:
        first = adapter.build_envelope(
            fixture_runner._external_input(self.base, "first")
        )
        subsequent = adapter.build_envelope(
            fixture_runner._external_input(self.base, "subsequent")
        )

        self.assertEqual(first["promotion"]["target_sequence"], "first")
        self.assertIsNotNone(first["promotion"]["baseline"])
        self.assertIsNone(first["promotion"]["previous_target_receipt"])
        self.assertEqual(subsequent["promotion"]["target_sequence"], "subsequent")
        self.assertIsNone(subsequent["promotion"]["baseline"])
        previous = subsequent["promotion"]["previous_target_receipt"]
        self.assertEqual(previous["candidate_id"], "Build-55")
        self.assertEqual(
            previous["artifact_identity"]["release_lineage"],
            "universe-keyboard-main",
        )

    def test_external_first_rejects_boolean_baseline_shortcut(self) -> None:
        payload = fixture_runner._external_input(self.base, "first")
        payload["promotion"]["baseline"] = True
        with self.assertRaisesRegex(
            adapter.AdapterInputError, "explicit verified receipt object"
        ):
            adapter.build_envelope(payload)

    def test_delta_reuses_only_untouched_fresh_claims(self) -> None:
        payload = copy.deepcopy(self.fixture["delta_candidate"])
        payload["changed_surface"] = [
            "Universe Keyboard/Views/Settings/AppearanceView.swift"
        ]

        plan = adapter.plan_delta(payload)

        self.assertEqual(plan.release_validation_profile, "delta")
        self.assertEqual(plan.ci_change_tier, "full")
        self.assertEqual(
            plan.reusable_evidence_keys, ("EVIDENCE-CANDIDATE-IDENTITY-56",)
        )
        self.assertEqual(
            plan.invalidated_evidence_keys,
            ("EVIDENCE-AFFECTED-SMOKE-56", "EVIDENCE-CHANGED-PATH-56"),
        )
        self.assertTrue(plan.stop_before_current_proof)

    def test_docs_only_can_reuse_fresh_claims_without_downgrading_ci_rule(self) -> None:
        payload = copy.deepcopy(self.fixture["delta_candidate"])
        payload["changed_surface"] = ["docs/RELEASE_CHECKLIST.md"]

        plan = adapter.plan_delta(payload)

        self.assertEqual(plan.release_validation_profile, "delta")
        self.assertEqual(plan.ci_change_tier, "docs_only")
        self.assertEqual(
            plan.reusable_evidence_keys,
            (
                "EVIDENCE-AFFECTED-SMOKE-56",
                "EVIDENCE-CANDIDATE-IDENTITY-56",
                "EVIDENCE-CHANGED-PATH-56",
            ),
        )
        self.assertEqual(plan.invalidated_evidence_keys, ())
        self.assertFalse(plan.stop_before_current_proof)

    def test_release_dependency_paths_are_not_docs_only(self) -> None:
        for changed_path in (
            "docs/kos/release-evidence-profile.md",
            ".kos/project.json",
            "Universe Keyboard/Services/ReleaseEvidenceStore.swift",
        ):
            with self.subTest(changed_path=changed_path):
                payload = copy.deepcopy(self.fixture["delta_candidate"])
                payload["changed_surface"] = [changed_path]
                plan = adapter.plan_delta(payload)

                self.assertEqual(plan.release_validation_profile, "full")
                expected_ci_tier = (
                    "full"
                    if changed_path.startswith("Universe Keyboard/")
                    else "docs_only"
                )
                self.assertEqual(plan.ci_change_tier, expected_ci_tier)
                self.assertEqual(plan.reusable_evidence_keys, ())
                self.assertEqual(
                    plan.invalidated_evidence_keys,
                    (
                        "EVIDENCE-AFFECTED-SMOKE-56",
                        "EVIDENCE-CANDIDATE-IDENTITY-56",
                        "EVIDENCE-CHANGED-PATH-56",
                    ),
                )
                self.assertTrue(plan.stop_before_current_proof)

    def test_delta_requires_exact_claim_coverage_binding(self) -> None:
        for overrides in (
            {"claim_ref": "UK-RE-OTHER-CLAIM"},
            {"coverage_ref": None},
            {"scope": "unknown_scope"},
            {"raw_user_input": "SENSITIVE"},
        ):
            with self.subTest(overrides=overrides):
                payload = copy.deepcopy(self.fixture["delta_candidate"])
                payload["changed_surface"] = ["docs/RELEASE_CHECKLIST.md"]
                if "raw_user_input" in overrides:
                    payload["evidence"][0].update(overrides)
                else:
                    for evidence in payload["evidence"]:
                        evidence.update(overrides)

                plan = adapter.plan_delta(payload)

                self.assertEqual(plan.release_validation_profile, "full")
                self.assertEqual(plan.ci_change_tier, "full")
                self.assertEqual(plan.reusable_evidence_keys, ())
                self.assertTrue(plan.stop_before_current_proof)

    def test_delta_missing_or_duplicate_evidence_fails_closed(self) -> None:
        payload = copy.deepcopy(self.fixture["delta_candidate"])
        payload["changed_surface"] = ["docs/RELEASE_CHECKLIST.md"]
        payload["evidence"].append("malformed")
        plan = adapter.plan_delta(payload)
        self.assertEqual(plan.release_validation_profile, "full")
        self.assertEqual(plan.ci_change_tier, "full")
        self.assertEqual(plan.reusable_evidence_keys, ())
        self.assertTrue(plan.stop_before_current_proof)

    def test_delta_preserves_diff_binding_and_rejects_ambiguous_surface(self) -> None:
        payload = copy.deepcopy(self.fixture["delta_candidate"])
        payload["changed_surface"] = ["docs/RELEASE_CHECKLIST.md"]
        plan = adapter.plan_delta(payload)
        self.assertEqual(plan.base_sha, payload["base_sha"])
        self.assertEqual(plan.head_sha, payload["head_sha"])

        payload["base_sha"] = payload["head_sha"]
        plan = adapter.plan_delta(payload)
        self.assertEqual(plan.release_validation_profile, "full")
        self.assertEqual(plan.reason, "base_equals_head_with_changed_surface")
        self.assertEqual(plan.reusable_evidence_keys, ())
        self.assertTrue(plan.stop_before_current_proof)

        payload = copy.deepcopy(self.fixture["delta_candidate"])
        payload["changed_surface"] = [
            "docs/RELEASE_CHECKLIST.md",
            "docs/RELEASE_CHECKLIST.md",
        ]
        plan = adapter.plan_delta(payload)
        self.assertEqual(plan.reason, "ambiguous_changed_surface")
        self.assertEqual(plan.reusable_evidence_keys, ())
        self.assertTrue(plan.stop_before_current_proof)

        for changed_path in (
            ".kos/project.json/.",
            ".kos//project.json",
            "Universe Keyboard/Services/ReleaseEvidenceStore.swift/.",
            "Universe Keyboard//Services/ReleaseEvidenceStore.swift",
        ):
            with self.subTest(changed_path=changed_path):
                payload = copy.deepcopy(self.fixture["delta_candidate"])
                payload["changed_surface"] = [changed_path]
                plan = adapter.plan_delta(payload)
                self.assertEqual(plan.release_validation_profile, "full")
                self.assertEqual(plan.reusable_evidence_keys, ())
                self.assertEqual(
                    plan.invalidated_evidence_keys,
                    (
                        "EVIDENCE-AFFECTED-SMOKE-56",
                        "EVIDENCE-CANDIDATE-IDENTITY-56",
                        "EVIDENCE-CHANGED-PATH-56",
                    ),
                )
                self.assertTrue(plan.stop_before_current_proof)

    def test_delta_rejects_case_variant_unresolved_bindings(self) -> None:
        for field, value in (
            ("candidate_id", "unknown"),
            ("candidate_id", "Tbd"),
            ("comparison_basis", "UNKNOWN"),
        ):
            with self.subTest(field=field, value=value):
                payload = copy.deepcopy(self.fixture["delta_candidate"])
                payload["changed_surface"] = ["docs/RELEASE_CHECKLIST.md"]
                payload[field] = value
                for evidence in payload["evidence"]:
                    evidence[field] = value
                plan = adapter.plan_delta(payload)
                self.assertEqual(plan.release_validation_profile, "full")
                self.assertEqual(plan.reusable_evidence_keys, ())
                self.assertTrue(plan.stop_before_current_proof)

        payload = copy.deepcopy(self.fixture["delta_candidate"])
        payload["changed_surface"] = ["docs/RELEASE_CHECKLIST.md"]
        payload["evidence"][0]["evidence_key"] = "unknown"
        plan = adapter.plan_delta(payload)
        self.assertEqual(plan.release_validation_profile, "full")
        self.assertEqual(plan.reusable_evidence_keys, ())
        self.assertTrue(plan.stop_before_current_proof)

    def test_runner_verifies_complete_kos_candidate_pin(self) -> None:
        report = fixture_runner._verify_pins(Path("/Users/doubleshy0n/Dev/kos-agent-kit"))
        self.assertEqual(
            report["implementation_commit"],
            adapter.PINNED_PROFILE["implementation_commit"],
        )
        self.assertEqual(
            report["adoption_metadata_commit"],
            adapter.PINNED_PROFILE["adoption_metadata_commit"],
        )
        self.assertEqual(
            report["candidate_tree_digest"]["actual"],
            adapter.PINNED_PROFILE["candidate_tree_digest"],
        )

        payload = copy.deepcopy(self.fixture["delta_candidate"])
        payload["changed_surface"] = ["docs/RELEASE_CHECKLIST.md"]
        payload["evidence"][1]["evidence_key"] = payload["evidence"][0]["evidence_key"]
        plan = adapter.plan_delta(payload)
        self.assertEqual(plan.release_validation_profile, "full")
        self.assertEqual(plan.reusable_evidence_keys, ())
        self.assertTrue(plan.stop_before_current_proof)

    def test_delivery_and_final_validation_force_fresh_boundary_only(self) -> None:
        for surface in ("delivery", "final_validation"):
            with self.subTest(surface=surface):
                payload = copy.deepcopy(self.fixture["delta_candidate"])
                payload["changed_surface"] = [surface]
                plan = adapter.plan_delta(payload)

                self.assertEqual(plan.release_validation_profile, "triggered")
                self.assertEqual(plan.ci_change_tier, "full")
                self.assertEqual(plan.invalidated_evidence_keys, ())
                self.assertEqual(
                    plan.reusable_evidence_keys,
                    (
                        "EVIDENCE-AFFECTED-SMOKE-56",
                        "EVIDENCE-CANDIDATE-IDENTITY-56",
                        "EVIDENCE-CHANGED-PATH-56",
                    ),
                )
                self.assertTrue(plan.stop_before_current_proof)

    def test_contract_owner_or_unknown_surface_fails_closed(self) -> None:
        for surface in ("schema", "privacy_allowlist"):
            with self.subTest(surface=surface):
                payload = copy.deepcopy(self.fixture["delta_candidate"])
                payload["changed_surface"] = [surface]
                plan = adapter.plan_delta(payload)
                self.assertEqual(plan.release_validation_profile, "full")
                self.assertEqual(plan.reusable_evidence_keys, ())
                self.assertTrue(plan.stop_before_current_proof)

        payload = copy.deepcopy(self.fixture["delta_candidate"])
        payload["changed_surface"] = ["mystery/unknown.swift"]
        plan = adapter.plan_delta(payload)
        self.assertEqual(plan.release_validation_profile, "full")
        self.assertEqual(plan.ci_change_tier, "full")
        self.assertEqual(plan.reusable_evidence_keys, ())
        self.assertTrue(plan.stop_before_current_proof)

        payload["changed_surface"] = ["mystery-root-file"]
        plan = adapter.plan_delta(payload)
        self.assertEqual(plan.release_validation_profile, "full")
        self.assertEqual(plan.ci_change_tier, "full")
        self.assertEqual(plan.reusable_evidence_keys, ())
        self.assertTrue(plan.stop_before_current_proof)

    def test_mutation_runner_supports_wildcard_and_list_paths(self) -> None:
        envelope = adapter.build_envelope(copy.deepcopy(self.base))

        fixture_runner.apply_envelope_mutations(
            envelope,
            [
                {
                    "op": "set_each",
                    "path": "observations[*].candidate_id",
                    "value": "Build-55",
                },
                {"op": "delete", "path": "observations[1]"},
            ],
        )

        self.assertEqual(len(envelope["observations"]), 2)
        self.assertTrue(
            all(item["candidate_id"] == "Build-55" for item in envelope["observations"])
        )


if __name__ == "__main__":
    unittest.main()
