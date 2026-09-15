#!/usr/bin/env python3
"""Prepare and promote release evidence without changing release authority.

This tool deliberately sits beside the existing CI classifier. CI decides the
repository quality tier; this tool decides which release evidence slices need
to be refreshed for a candidate. It never uploads, assigns testers, submits
Beta Review, or turns a green result into Product/Quality/Release approval.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
import re
import subprocess
import sys
import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import PurePosixPath
from typing import Any, Iterable


UNKNOWN = "UNKNOWN"
SCHEMA_VERSION = 1
RECEIPT_CONTRACT_VERSION = "release-candidate-receipt-v1"
EVIDENCE_CONTRACT_VERSION = "release-evidence-v1"
KNOWN_OUTCOMES = {"pass", "partial", "fail", "inconclusive", "not-run"}
CURRENT_PROOF_MAX_AGE = timedelta(days=30)

BASELINE_PREFIXES = (
    ".github/workflows/",
    ".xcodeproj/",
    ".xcworkspace/",
    "Keyboard/Resources/",
    "Packages/RimeBridge/",
    "scripts/ci/",
    "scripts/release/",
    "Universe Keyboard/RimeBuiltin/",
    "Universe Keyboard/Vendor/",
)

TRIGGERED_PREFIXES = (
    "Keyboard/",
    "KeyboardTests/",
    "KeyboardExtensionTests/",
    "Packages/KeyboardCore/",
    "Universe Keyboard/Services/",
    "Universe Keyboard/Models/Rime",
    "Universe Keyboard/Views/Settings/Rime",
)

BASELINE_FILENAMES = {
    "Package.swift",
    "Package.resolved",
    "config/Info.plist",
    "config/rime-vendor-manifest.env",
    "Universe Keyboard/PrivacyInfo.xcprivacy",
    "Universe Keyboard/Universe Keyboard.entitlements",
    "Keyboard/Info.plist",
}

TRIGGERED_FILENAMES = {
    "Universe Keyboard/Services/SchemaManager.swift",
    "Universe Keyboard/Models/RimeSyncViewModel.swift",
}

ARTIFACT_IDENTITY_FIELDS = (
    "source_commit",
    "version",
    "build",
    "archive_sha256",
    "package_sha256",
)

# These fields are useful provenance, but they are not substitutes for the
# five-field artifact identity above. Keeping the distinction explicit avoids
# silently changing the exact-artifact contract when a new receipt field is
# added later.
ARTIFACT_PROVENANCE_FIELDS = (
    "rc_tag",
    "archive_kind",
    "package_kind",
    "app_uuid",
    "keyboard_uuid",
    "app_dsym_uuid",
    "keyboard_dsym_uuid",
    "cloud_workflow_build",
    "rime_manifest_digest",
    "toolchain",
)

CURRENT_PROOF_CONTEXT_FIELDS = (
    "behavior_contract",
    "device_model",
    "os_version",
    "validation_profile",
)


@dataclass(frozen=True)
class ReleaseClassification:
    profile: str
    reason: str
    changed_paths: tuple[str, ...]
    affected_areas: tuple[str, ...]
    required_checks: tuple[str, ...]
    revalidation_triggers: tuple[str, ...]
    ci_classification: str


def normalize_paths(paths: Iterable[str]) -> tuple[str, ...]:
    """Normalize paths while preserving the fail-closed behavior of CI."""

    normalized: set[str] = set()
    for raw_path in paths:
        path = raw_path.replace("\\", "/")
        normalized.add(path)
    return tuple(sorted(normalized))


def is_safe_relative_path(path: str) -> bool:
    pure_path = PurePosixPath(path)
    return bool(path) and not pure_path.is_absolute() and ".." not in pure_path.parts


def is_docs_only_path(path: str) -> bool:
    """Return true for documentation paths that cannot change the artifact."""

    pure_path = PurePosixPath(path)
    if not is_safe_relative_path(path) or not pure_path.parts:
        return False
    if pure_path.parts[0] in {"docs", ".kos"}:
        return True
    return len(pure_path.parts) == 1 and pure_path.suffix.lower() == ".md"


def starts_with_any(path: str, prefixes: Iterable[str]) -> bool:
    return any(path.startswith(prefix) for prefix in prefixes)


def area_for_path(path: str) -> set[str]:
    areas: set[str] = set()
    if path.startswith("Universe Keyboard/"):
        areas.add("main_app")
    if path.startswith("Keyboard/") or path.startswith("KeyboardTests/"):
        areas.add("keyboard_extension")
    if path.startswith("KeyboardExtensionTests/"):
        areas.add("keyboard_extension_tests")
    if path.startswith("Packages/KeyboardCore/"):
        areas.add("keyboard_core")
    if path.startswith("Packages/RimeBridge/") or path.startswith(
        "Universe Keyboard/RimeBuiltin/"
    ):
        areas.add("rime_runtime")
    if path.startswith("scripts/") or path.startswith(".github/") or ".xcode" in path:
        areas.add("release_tooling")
    if path in BASELINE_FILENAMES or path.endswith((".entitlements", ".xcconfig")):
        areas.add("artifact_identity")
    if not areas and not is_docs_only_path(path):
        areas.add("main_app")
    return areas


def classify_paths(
    paths: Iterable[str], *, first_external_candidate: bool = False
) -> ReleaseClassification:
    normalized = normalize_paths(paths)
    if not normalized:
        return ReleaseClassification(
            profile="baseline",
            reason="empty_diff_fails_closed",
            changed_paths=(),
            affected_areas=("artifact_identity",),
            required_checks=("candidate_fact_tuple", "artifact_mapping", "baseline_review"),
            revalidation_triggers=("changed_paths_unavailable",),
            ci_classification="full",
        )

    if any(not is_safe_relative_path(path) for path in normalized):
        return ReleaseClassification(
            profile="baseline",
            reason="unsafe_changed_path_fails_closed",
            changed_paths=normalized,
            affected_areas=("artifact_identity", "release_tooling"),
            required_checks=(
                "candidate_fact_tuple",
                "artifact_mapping",
                "existing_ci_full_gate",
                "baseline_review",
            ),
            revalidation_triggers=("changed_path_is_not_safe_relative_path",),
            ci_classification="full",
        )

    if first_external_candidate:
        affected_areas = {area for path in normalized for area in area_for_path(path)}
        affected_areas.add("artifact_identity")
        return ReleaseClassification(
            profile="baseline",
            reason="first_external_candidate_requires_baseline",
            changed_paths=normalized,
            affected_areas=tuple(sorted(affected_areas)),
            required_checks=(
                "candidate_fact_tuple",
                "artifact_mapping",
                "existing_ci_full_gate",
                "affected_path_validation",
                "physical_device_baseline",
                "performance_and_crash_classification",
                "fresh_install_or_shared_container_boundary",
                "external_only_checks",
            ),
            revalidation_triggers=("first_external_candidate",),
            # Release evidence and CI are intentionally independent. A first
            # external candidate with documentation-only changes still keeps
            # the existing docs-only CI classification.
            ci_classification=(
                "docs_only"
                if all(is_docs_only_path(path) for path in normalized)
                else "full"
            ),
        )

    if all(is_docs_only_path(path) for path in normalized):
        return ReleaseClassification(
            profile="docs_only",
            reason="all_paths_are_documentation",
            changed_paths=normalized,
            affected_areas=("documentation",),
            required_checks=("documentation_link_and_policy_check",),
            revalidation_triggers=(),
            ci_classification="docs_only",
        )

    has_baseline_path = any(
        starts_with_any(path, BASELINE_PREFIXES)
        or path in BASELINE_FILENAMES
        or path.endswith((".entitlements", ".xcconfig"))
        or ".xcodeproj/" in path
        or ".xcworkspace/" in path
        for path in normalized
    )
    has_triggered_path = any(
        starts_with_any(path, TRIGGERED_PREFIXES) or path in TRIGGERED_FILENAMES
        for path in normalized
    )

    if has_baseline_path:
        profile = "baseline"
        reason = "artifact_toolchain_permission_or_rime_boundary_changed"
        required_checks = (
            "candidate_fact_tuple",
            "artifact_mapping",
            "existing_ci_full_gate",
            "affected_path_validation",
            "physical_device_baseline",
            "performance_and_crash_classification",
            "fresh_install_or_shared_container_boundary",
            "external_only_checks",
        )
        revalidation_triggers = (
            "artifact_identity_changed",
            "toolchain_or_support_matrix_changed",
            "rime_or_permission_boundary_changed",
        )
    elif has_triggered_path:
        profile = "triggered"
        reason = "runtime_or_keyboard_boundary_changed"
        required_checks = (
            "candidate_fact_tuple",
            "artifact_mapping",
            "existing_ci_full_gate",
            "affected_path_validation",
            "triggered_runtime_or_device_smoke",
            "external_only_checks",
        )
        revalidation_triggers = (
            "affected_runtime_contract_changed",
            "new_failure_class_or_unknown_boundary",
        )
    else:
        profile = "delta"
        reason = "ordinary_runtime_or_ui_delta"
        required_checks = (
            "candidate_fact_tuple",
            "artifact_mapping",
            "existing_ci_full_gate",
            "changed_path_validation",
            "affected_path_smoke",
            "external_only_checks",
        )
        revalidation_triggers = (
            "changed_path_expands",
            "unexplained_regression_or_unknown_result",
        )

    areas = sorted({area for path in normalized for area in area_for_path(path)})
    return ReleaseClassification(
        profile=profile,
        reason=reason,
        changed_paths=normalized,
        affected_areas=tuple(areas),
        required_checks=required_checks,
        revalidation_triggers=revalidation_triggers,
        # This is intentionally separate from release profile. A source or
        # tooling change remains full CI even when release evidence is delta.
        ci_classification="full",
    )


def require_commit(reference: str) -> None:
    if not reference:
        raise ValueError("commit reference is empty")
    result = subprocess.run(
        ["git", "cat-file", "-e", f"{reference}^{{commit}}"],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise ValueError(f"comparison reference is not a commit: {reference}")


def resolve_commit(reference: str) -> str:
    require_commit(reference)
    result = subprocess.run(
        ["git", "rev-parse", "--verify", f"{reference}^{{commit}}"],
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def changed_paths(base: str, head: str) -> list[str]:
    require_commit(base)
    require_commit(head)
    result = subprocess.run(
        [
            "git",
            "diff",
            "--name-only",
            "--no-renames",
            "--diff-filter=ACDMRTUXB",
            "-z",
            base,
            head,
        ],
        check=True,
        capture_output=True,
    )
    return [
        item.decode("utf-8", errors="surrogateescape")
        for item in result.stdout.split(b"\0")
        if item
    ]


def plan_payload(
    base: str,
    head: str,
    paths: Iterable[str],
    *,
    first_external_candidate: bool = False,
) -> dict[str, Any]:
    classification = classify_paths(
        paths, first_external_candidate=first_external_candidate
    )
    return {
        "schema_version": SCHEMA_VERSION,
        "record_type": "release_validation_plan",
        "base_sha": base,
        "head_sha": head,
        "changed_paths": list(classification.changed_paths),
        "release_validation": {
            "profile": classification.profile,
            "reason": classification.reason,
            "affected_areas": list(classification.affected_areas),
            "required_checks": list(classification.required_checks),
            "revalidation_triggers": list(classification.revalidation_triggers),
            "first_external_candidate": first_external_candidate,
        },
        "ci_validation": {
            "classification": classification.ci_classification,
            "authority": "docs/CI_CHANGE_CLASSIFICATION.md",
            "non_claim": "release_validation_profile_does_not_skip_existing_ci_gate",
        },
        "non_claims": [
            "does_not_upload_or_assign_testers",
            "does_not_submit_beta_review",
            "does_not_grant_independent_quality_pass",
            "does_not_grant_product_or_release_gate_pass",
        ],
    }


def write_json(path: str, payload: dict[str, Any]) -> None:
    parent = os.path.dirname(os.path.abspath(path))
    os.makedirs(parent, exist_ok=True)
    with open(path, "w", encoding="utf-8") as output:
        json.dump(payload, output, ensure_ascii=False, indent=2, sort_keys=True)
        output.write("\n")


def read_json(path: str) -> dict[str, Any]:
    with open(path, encoding="utf-8") as source:
        payload = json.load(source)
    if not isinstance(payload, dict):
        raise ValueError(f"JSON object expected: {path}")
    return payload


def validate_plan(plan: dict[str, Any]) -> None:
    if (
        plan.get("record_type") != "release_validation_plan"
        or plan.get("schema_version") != SCHEMA_VERSION
    ):
        raise ValueError("plan must be a release_validation_plan with the current schema")
    for field in ("base_sha", "head_sha"):
        value = plan.get(field)
        if not isinstance(value, str) or re.fullmatch(r"[0-9a-f]{40,64}", value) is None:
            raise ValueError(f"plan field {field} must contain a full commit SHA")
    release_validation = plan.get("release_validation")
    if not isinstance(release_validation, dict) or release_validation.get(
        "profile"
    ) not in {"docs_only", "delta", "triggered", "baseline"}:
        raise ValueError("plan has no valid release_validation profile")
    first_external_candidate = release_validation.get("first_external_candidate", False)
    if not isinstance(first_external_candidate, bool):
        raise ValueError("plan first_external_candidate marker must be boolean")


def known(value: Any) -> bool:
    return isinstance(value, str) and bool(value) and value != UNKNOWN


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def parse_timestamp(value: Any) -> datetime | None:
    """Parse only timezone-aware timestamps so freshness checks fail closed."""

    if not known(value):
        return None
    normalized = value.strip()
    if normalized.endswith("Z"):
        normalized = normalized[:-1] + "+00:00"
    try:
        parsed = datetime.fromisoformat(normalized)
    except ValueError:
        return None
    if parsed.tzinfo is None:
        return None
    return parsed.astimezone(timezone.utc)


def consistent_known_value(runs: Iterable[dict[str, Any]], key: str) -> str:
    values = [run.get(key) for run in runs if known(run.get(key))]
    if values and all(value == values[0] for value in values):
        return values[0]
    return UNKNOWN


def valid_sha256(value: Any) -> bool:
    return isinstance(value, str) and re.fullmatch(r"[0-9a-f]{64}", value) is not None


def valid_commit_sha(value: Any) -> bool:
    return isinstance(value, str) and re.fullmatch(r"[0-9a-f]{40,64}", value) is not None


def validate_candidate_id(value: str) -> str:
    normalized = value.strip()
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,63}", normalized):
        raise ValueError(
            "candidate id must be 1-64 ASCII letters, digits, dot, underscore or hyphen"
        )
    return normalized


def sha256_file(path: str) -> str:
    digest = hashlib.sha256()
    with open(path, "rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def sha256_directory(path: str) -> str:
    """Hash a directory by sorted relative names and bytes, not filesystem order."""

    digest = hashlib.sha256()
    root = os.path.abspath(path)
    files: list[str] = []
    for current_root, directories, filenames in os.walk(root):
        directories.sort()
        for filename in sorted(filenames):
            full_path = os.path.join(current_root, filename)
            if os.path.islink(full_path):
                continue
            files.append(os.path.relpath(full_path, root))
    for relative_path in files:
        digest.update(relative_path.replace(os.sep, "/").encode("utf-8"))
        digest.update(b"\0")
        with open(os.path.join(root, relative_path), "rb") as source:
            for chunk in iter(lambda: source.read(1024 * 1024), b""):
                digest.update(chunk)
        digest.update(b"\0")
    return digest.hexdigest()


def artifact_digest(path: str | None) -> tuple[str, str]:
    if not path:
        return UNKNOWN, UNKNOWN
    if not os.path.exists(path):
        raise ValueError(f"artifact does not exist: {path}")
    if os.path.isdir(path):
        return "directory", sha256_directory(path)
    return "file", sha256_file(path)


def infer_project_value(name: str) -> str:
    project_path = "Universe Keyboard.xcodeproj/project.pbxproj"
    try:
        with open(project_path, encoding="utf-8") as source:
            contents = source.read()
    except OSError:
        return UNKNOWN
    match = re.search(rf"\b{name}\s*=\s*([^;]+);", contents)
    return match.group(1).strip() if match else UNKNOWN


def evidence_value(run: dict[str, Any], *keys: str) -> Any:
    for key in keys:
        if key in run:
            return run[key]
    return UNKNOWN


def normalize_evidence_run(
    run: dict[str, Any], *, source: str = "external_evidence", evidence_contract: Any = UNKNOWN
) -> dict[str, Any]:
    lane = evidence_value(run, "lane")
    profile = evidence_value(run, "profile", "validation_profile")
    outcome = evidence_value(run, "outcome")
    if outcome not in KNOWN_OUTCOMES:
        outcome = "inconclusive"
    return {
        "id": evidence_value(run, "id", "run_id", "runID"),
        "claim": evidence_value(run, "claim"),
        "outcome": outcome,
        "source": evidence_value(run, "source")
        if known(evidence_value(run, "source"))
        else source,
        "lane": lane,
        "profile": profile,
        "candidate_id": evidence_value(run, "candidate_id", "candidateID"),
        "app_version": evidence_value(run, "app_version", "appVersion", "version"),
        "app_build": evidence_value(run, "app_build", "appBuild", "build"),
        "device_model": evidence_value(run, "device_model", "deviceModel"),
        "os_version": evidence_value(run, "os_version", "osVersion"),
        "recorded_at": evidence_value(
            run, "recorded_at", "recordedAt", "updated_at", "updatedAt", "created_at", "createdAt"
        ),
        "evidence_contract_version": evidence_value(
            run, "evidence_contract_version", "evidenceContractVersion"
        )
        if evidence_contract == UNKNOWN
        else evidence_contract,
        "behavior_contract": evidence_value(run, "behavior_contract", "behaviorContract"),
    }


def load_evidence_runs(path: str | None) -> list[dict[str, Any]]:
    if not path:
        return []
    payload = read_json(path)
    if payload.get("record_type") == "release_evidence_run":
        run = payload.get("run")
        if isinstance(run, dict):
            normalized = normalize_evidence_run(
                {
                    **run,
                    "outcome": payload.get("outcome", run.get("outcome", "not-run")),
                    "claim": (
                        f"{run.get('lane', 'release_evidence')}:"
                        f"{run.get('profile', 'unknown')}"
                    ),
                },
                source="main_app_release_evidence",
                evidence_contract=payload.get("evidenceContractVersion", UNKNOWN),
            )
            return [normalized]
        return [payload]
    runs = payload.get("runs")
    if isinstance(runs, list):
        return [
            normalize_evidence_run(run)
            for run in runs
            if isinstance(run, dict)
        ]
    if isinstance(payload.get("evidence_runs"), list):
        return [
            normalize_evidence_run(run)
            for run in payload["evidence_runs"]
            if isinstance(run, dict)
        ]
    raise ValueError("evidence file must contain a release_evidence_run or runs array")


def receipt_payload(args: argparse.Namespace) -> dict[str, Any]:
    plan = read_json(args.plan)
    validate_plan(plan)
    candidate_id = UNKNOWN
    if args.candidate_id:
        candidate_id = validate_candidate_id(args.candidate_id)
    version = args.version or infer_project_value("MARKETING_VERSION")
    build = args.build or infer_project_value("CURRENT_PROJECT_VERSION")
    package_kind, package_sha = artifact_digest(args.package)
    archive_kind, archive_sha = artifact_digest(args.archive)
    evidence_runs = load_evidence_runs(args.evidence_file)
    created_at = utc_now_iso()
    release_validation = plan["release_validation"]
    candidate_context = {
        # The behavior contract is intentionally explicit. A matching version
        # or build is not enough to prove that the observed behavior is the
        # same contract.
        "behavior_contract": getattr(args, "behavior_contract", None)
        or consistent_known_value(evidence_runs, "behavior_contract"),
        "device_model": getattr(args, "device_model", None)
        or consistent_known_value(evidence_runs, "device_model"),
        "os_version": getattr(args, "os_version", None)
        or consistent_known_value(evidence_runs, "os_version"),
        "validation_profile": release_validation["profile"],
    }

    external_candidate_provenance: dict[str, Any] | None = None
    previous_path = getattr(args, "previous_external_receipt", None)
    if args.kind != "external_candidate" and previous_path:
        raise ValueError("previous external receipt is only valid for external candidates")
    if args.kind == "external_candidate":
        first_external_candidate = release_validation.get(
            "first_external_candidate", False
        )
        if first_external_candidate:
            if previous_path:
                raise ValueError(
                    "first external candidate cannot also provide a previous receipt"
                )
            if (
                release_validation["profile"] != "baseline"
                or release_validation["reason"]
                != "first_external_candidate_requires_baseline"
            ):
                raise ValueError(
                    "first external candidate requires a verified baseline plan"
                )
            external_candidate_provenance = {
                "mode": "first_external_candidate",
                "plan_marker": "verified",
            }
        elif previous_path:
            previous = read_json(previous_path)
            validate_receipt(previous, expected_kind="external_candidate")
            previous_created_at = parse_timestamp(previous.get("created_at"))
            current_created_at = parse_timestamp(created_at)
            if (
                previous_created_at is None
                or current_created_at is None
                or previous_created_at >= current_created_at
            ):
                raise ValueError(
                    "previous external receipt must have an older valid created_at"
                )
            external_candidate_provenance = {
                "mode": "subsequent_external_candidate",
                "previous_receipt_id": previous["receipt_id"],
                "previous_receipt_sha256": sha256_file(previous_path),
            }
        else:
            raise ValueError(
                "external candidate requires first external baseline plan or previous external receipt"
            )

    payload: dict[str, Any] = {
        "schema_version": SCHEMA_VERSION,
        "receipt_contract_version": RECEIPT_CONTRACT_VERSION,
        "record_type": "release_candidate_receipt",
        "receipt_id": str(uuid.uuid4()),
        "created_at": created_at,
        "candidate_kind": args.kind,
        "candidate_fact_tuple": {
            "source_commit": plan.get("head_sha", UNKNOWN),
            "rc_tag": args.rc_tag or UNKNOWN,
            "version": version,
            "build": build,
            "candidate_id": candidate_id,
            "archive_sha256": archive_sha,
            "package_sha256": package_sha,
            "archive_kind": archive_kind,
            "package_kind": package_kind,
            "app_uuid": args.app_uuid or UNKNOWN,
            "keyboard_uuid": args.keyboard_uuid or UNKNOWN,
            "app_dsym_uuid": args.app_dsym_uuid or UNKNOWN,
            "keyboard_dsym_uuid": args.keyboard_dsym_uuid or UNKNOWN,
            "cloud_workflow_build": args.cloud_workflow_build or UNKNOWN,
            "rime_manifest_digest": args.rime_manifest_digest or UNKNOWN,
            "toolchain": args.toolchain or UNKNOWN,
        },
        "candidate_context": candidate_context,
        "validation_plan": plan,
        "evidence_runs": evidence_runs,
        "external_only_checks": {
            "artifact_external_eligibility": "not-run",
            "app_store_connect_processing": "not-run",
            "external_group_assignment": "not-authorized",
            "beta_review": "not-authorized",
        },
        "status": "prepared",
        "non_claims": [
            "receipt_creation_is_not_upload",
            "receipt_creation_is_not_quality_or_product_acceptance",
            "unknown_identity_fields_cannot_support_exact_artifact_claim",
        ],
    }
    if external_candidate_provenance is not None:
        payload["external_candidate_provenance"] = external_candidate_provenance
    validate_receipt(payload, expected_kind=args.kind)
    return payload


def validate_external_candidate_provenance(payload: dict[str, Any]) -> None:
    provenance = payload.get("external_candidate_provenance")
    if not isinstance(provenance, dict):
        raise ValueError("external candidate receipt has no verifiable baseline provenance")
    mode = provenance.get("mode")
    plan = payload.get("validation_plan")
    if not isinstance(plan, dict):
        raise ValueError("external candidate receipt has no validation plan")
    release_validation = plan.get("release_validation")
    if not isinstance(release_validation, dict):
        raise ValueError("external candidate receipt has no release validation metadata")
    if mode == "first_external_candidate":
        if (
            release_validation.get("first_external_candidate") is not True
            or release_validation.get("profile") != "baseline"
            or release_validation.get("reason")
            != "first_external_candidate_requires_baseline"
            or provenance.get("plan_marker") != "verified"
        ):
            raise ValueError("first external candidate provenance is not verified")
    elif mode == "subsequent_external_candidate":
        if not known(provenance.get("previous_receipt_id")) or not valid_sha256(
            provenance.get("previous_receipt_sha256")
        ):
            raise ValueError(
                "subsequent external candidate has no verifiable previous receipt digest"
            )
    else:
        raise ValueError("external candidate provenance mode is not recognized")


def validate_receipt(
    payload: dict[str, Any], *, expected_kind: str | None = None
) -> None:
    if (
        payload.get("record_type") != "release_candidate_receipt"
        or payload.get("schema_version") != SCHEMA_VERSION
        or payload.get("receipt_contract_version") != RECEIPT_CONTRACT_VERSION
    ):
        raise ValueError("receipt does not use the current release candidate contract")
    candidate_kind = payload.get("candidate_kind")
    if expected_kind is not None and candidate_kind != expected_kind:
        raise ValueError(f"receipt must be a {expected_kind}")
    if candidate_kind not in {"daily_beta", "external_candidate"}:
        raise ValueError("receipt has an unknown candidate kind")
    if not known(payload.get("receipt_id")) or parse_timestamp(payload.get("created_at")) is None:
        raise ValueError("receipt must have a valid id and timezone-aware created_at")
    tuple_for(payload)
    context = payload.get("candidate_context")
    if not isinstance(context, dict):
        raise ValueError("receipt has no candidate_context")
    for field in CURRENT_PROOF_CONTEXT_FIELDS:
        if field not in context:
            raise ValueError(f"receipt candidate_context is missing {field}")
    plan = payload.get("validation_plan")
    if not isinstance(plan, dict):
        raise ValueError("receipt has no validation_plan")
    validate_plan(plan)
    release_validation = plan["release_validation"]
    if context.get("validation_profile") != release_validation["profile"]:
        raise ValueError("receipt candidate_context profile does not match its plan")
    source_commit = tuple_for(payload).get("source_commit")
    if known(source_commit) and source_commit != plan["head_sha"]:
        raise ValueError("receipt source_commit does not match its plan head_sha")
    evidence_runs = payload.get("evidence_runs", [])
    if not isinstance(evidence_runs, list) or any(
        not isinstance(run, dict) for run in evidence_runs
    ):
        raise ValueError("receipt evidence_runs must be an array of objects")
    if candidate_kind == "external_candidate":
        validate_external_candidate_provenance(payload)


def tuple_for(payload: dict[str, Any]) -> dict[str, Any]:
    value = payload.get("candidate_fact_tuple")
    if not isinstance(value, dict):
        raise ValueError("candidate receipt has no candidate_fact_tuple")
    return value


def has_exact_artifact_identity(source: dict[str, Any], target: dict[str, Any]) -> bool:
    source_tuple = tuple_for(source)
    target_tuple = tuple_for(target)
    for field in ARTIFACT_IDENTITY_FIELDS:
        source_value = source_tuple.get(field)
        target_value = target_tuple.get(field)
        if not known(source_value) or not known(target_value) or source_value != target_value:
            return False
        if field == "source_commit" and not valid_commit_sha(source_value):
            return False
        if field in {"archive_sha256", "package_sha256"} and not valid_sha256(
            source_value
        ):
            return False
    return True


def same_contract_baseline(source: dict[str, Any], target: dict[str, Any]) -> bool:
    source_tuple = tuple_for(source)
    target_tuple = tuple_for(target)
    # A new build is expected to differ in source/build/package identity. The
    # stable contract boundary available to this tool is the marketing
    # version; the resulting evidence is explicitly comparator-only.
    return all(
        known(source_tuple.get(field))
        and known(target_tuple.get(field))
        and source_tuple[field] == target_tuple[field]
        for field in ("version",)
    )


def current_proof_context_matches(
    source: dict[str, Any], target: dict[str, Any]
) -> bool:
    source_context = source.get("candidate_context")
    target_context = target.get("candidate_context")
    if not isinstance(source_context, dict) or not isinstance(target_context, dict):
        return False
    return all(
        known(source_context.get(field))
        and known(target_context.get(field))
        and source_context[field] == target_context[field]
        for field in CURRENT_PROOF_CONTEXT_FIELDS
    )


def current_proof_candidate_binding_matches(
    source: dict[str, Any], target: dict[str, Any]
) -> bool:
    """Keep a proof attached to the same named candidate on both receipts."""

    source_tuple = tuple_for(source)
    target_tuple = tuple_for(target)
    source_candidate_id = source_tuple.get("candidate_id")
    target_candidate_id = target_tuple.get("candidate_id")
    return (
        known(source_candidate_id)
        and known(target_candidate_id)
        and source_candidate_id == target_candidate_id
    )


def evidence_run_supports_current_proof(
    run: dict[str, Any], source: dict[str, Any], target: dict[str, Any]
) -> bool:
    """Require a fresh, source-bound Main App observation for current-proof."""

    if (
        run.get("outcome") != "pass"
        or run.get("lane") != "daily_beta"
        or run.get("source") != "main_app_release_evidence"
    ):
        return False
    if run.get("evidence_contract_version") != EVIDENCE_CONTRACT_VERSION:
        return False
    if not current_proof_context_matches(source, target):
        return False
    if not current_proof_candidate_binding_matches(source, target):
        return False

    source_tuple = tuple_for(source)
    source_context = source["candidate_context"]
    required_run_values = {
        "candidate_id": source_tuple.get("candidate_id"),
        "app_version": source_tuple.get("version"),
        "app_build": source_tuple.get("build"),
        "device_model": source_context.get("device_model"),
        "os_version": source_context.get("os_version"),
        "behavior_contract": source_context.get("behavior_contract"),
        "profile": source_context.get("validation_profile"),
    }
    if any(
        not known(value) or run.get(field) != value
        for field, value in required_run_values.items()
    ):
        return False

    recorded_at = parse_timestamp(run.get("recorded_at"))
    target_created_at = parse_timestamp(target.get("created_at"))
    if recorded_at is None or target_created_at is None:
        return False
    age = target_created_at - recorded_at
    return timedelta(0) <= age <= CURRENT_PROOF_MAX_AGE


def promote_receipt(
    source: dict[str, Any], target: dict[str, Any] | None = None
) -> dict[str, Any]:
    validate_receipt(source, expected_kind="daily_beta")
    if target is not None:
        validate_receipt(target, expected_kind="external_candidate")
    promoted = copy.deepcopy(target if target is not None else source)
    promoted["candidate_kind"] = "external_candidate"
    promoted["receipt_id"] = str(uuid.uuid4())

    if target is None:
        mode = "pending_artifact_match"
        artifact_match = "not_verified"
    elif has_exact_artifact_identity(source, promoted):
        mode = "exact_artifact"
        artifact_match = "verified"
    elif same_contract_baseline(source, promoted):
        mode = "contract_baseline"
        artifact_match = "not_verified"
    else:
        mode = "not_reusable"
        artifact_match = "mismatch"

    reused_evidence: list[dict[str, Any]] = []
    for run in source.get("evidence_runs", []):
        if not isinstance(run, dict):
            continue
        outcome = run.get("outcome", "not-run")
        if outcome not in KNOWN_OUTCOMES:
            outcome = "inconclusive"
        if mode == "exact_artifact" and evidence_run_supports_current_proof(
            run, source, promoted
        ):
            reusable_as = "current-proof"
        elif mode == "contract_baseline" and outcome in {"pass", "partial"}:
            reusable_as = "comparator"
        else:
            reusable_as = "none"
        reused_evidence.append(
            {
                "source_run_id": run.get("id", UNKNOWN),
                "claim": run.get("claim", "daily_beta_evidence"),
                "outcome": outcome,
                "reusable_as": reusable_as,
                "reason": (
                    "same verified artifact identity with matching fresh evidence context"
                    if reusable_as == "current-proof"
                    else "artifact identity matches but evidence context is incomplete or stale"
                    if mode == "exact_artifact"
                    else "new or incomplete candidate identity requires current delta"
                ),
            }
        )

    promoted["promotion"] = {
        "source_receipt_id": source.get("receipt_id", UNKNOWN),
        "mode": mode,
        "artifact_match": artifact_match,
        "reused_evidence": reused_evidence,
        "baseline_proof": (
            "verified"
            if target is not None and mode in {"exact_artifact", "contract_baseline"}
            else "not_verified"
        ),
        "required_current_delta": [
            "artifact_identity_and_evidence_context",
            "external_candidate_readiness",
            "independent_quality_review",
            "product_release_gate",
        ],
    }
    promoted["external_only_checks"] = {
        "artifact_external_eligibility": "not-run",
        "app_store_connect_processing": "not-run",
        "external_group_assignment": "not-authorized",
        "beta_review": "not-authorized",
    }
    promoted["status"] = "promoted_pending_external_checks"
    if target is None:
        promoted["external_candidate_provenance"] = {
            "mode": "pending_external_baseline",
            "reason": "a target receipt with verifiable baseline provenance is required",
        }
    promoted["non_claims"] = sorted(
        set(promoted.get("non_claims", []))
        | {
            "promotion_does_not_grant_quality_pass",
            "promotion_does_not_grant_product_or_release_gate_pass",
            "external_actions_remain_separately_authorized",
        }
    )
    return promoted


def print_plan(payload: dict[str, Any]) -> None:
    release = payload["release_validation"]
    print(f"release_profile={release['profile']}")
    print(f"ci_classification={payload['ci_validation']['classification']}")
    print(f"reason={release['reason']}")
    print("affected_areas=" + ",".join(release["affected_areas"]))
    print("required_checks=" + ",".join(release["required_checks"]))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    plan_parser = subparsers.add_parser("plan", help="classify a source diff")
    plan_parser.add_argument("--base", required=True)
    plan_parser.add_argument("--head", default="HEAD")
    plan_parser.add_argument(
        "--first-external-candidate",
        action="store_true",
        help="force baseline release evidence for the first formal external candidate",
    )
    plan_parser.add_argument("--output")

    receipt_parser = subparsers.add_parser("receipt", help="write a candidate fact receipt")
    receipt_parser.add_argument("--plan", required=True)
    receipt_parser.add_argument(
        "--kind", choices=("daily_beta", "external_candidate"), required=True
    )
    receipt_parser.add_argument("--version")
    receipt_parser.add_argument("--build")
    receipt_parser.add_argument("--candidate-id")
    receipt_parser.add_argument("--rc-tag")
    receipt_parser.add_argument("--archive")
    receipt_parser.add_argument("--package")
    receipt_parser.add_argument("--app-uuid")
    receipt_parser.add_argument("--keyboard-uuid")
    receipt_parser.add_argument("--app-dsym-uuid")
    receipt_parser.add_argument("--keyboard-dsym-uuid")
    receipt_parser.add_argument("--cloud-workflow-build")
    receipt_parser.add_argument("--rime-manifest-digest")
    receipt_parser.add_argument("--toolchain")
    receipt_parser.add_argument(
        "--behavior-contract",
        help="versioned behavior contract observed by the evidence run",
    )
    receipt_parser.add_argument("--device-model")
    receipt_parser.add_argument("--os-version")
    receipt_parser.add_argument(
        "--previous-external-receipt",
        help="prior external receipt required for every external candidate after the first",
    )
    receipt_parser.add_argument("--evidence-file")
    receipt_parser.add_argument("--output", required=True)

    promote_parser = subparsers.add_parser(
        "promote", help="promote daily Beta evidence into an external candidate receipt"
    )
    promote_parser.add_argument("--source", required=True)
    promote_parser.add_argument(
        "--target",
        help="optional external-candidate receipt; omit to promote the same recorded tuple",
    )
    promote_parser.add_argument("--output", required=True)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        if args.command == "plan":
            base_sha = resolve_commit(args.base)
            head_sha = resolve_commit(args.head)
            paths = changed_paths(base_sha, head_sha)
            payload = plan_payload(
                base_sha,
                head_sha,
                paths,
                first_external_candidate=args.first_external_candidate,
            )
            if args.output:
                write_json(args.output, payload)
            print(json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True))
            print_plan(payload)
            return 0

        if args.command == "receipt":
            payload = receipt_payload(args)
            write_json(args.output, payload)
            print(f"wrote={args.output}")
            print(f"candidate_kind={payload['candidate_kind']}")
            print(f"source_commit={payload['candidate_fact_tuple']['source_commit']}")
            print(f"package_sha256={payload['candidate_fact_tuple']['package_sha256']}")
            return 0

        source = read_json(args.source)
        target = read_json(args.target) if args.target else None
        payload = promote_receipt(source, target)
        write_json(args.output, payload)
        print(f"wrote={args.output}")
        print(f"promotion_mode={payload['promotion']['mode']}")
        print(f"artifact_match={payload['promotion']['artifact_match']}")
        return 0
    except (OSError, ValueError, json.JSONDecodeError, subprocess.CalledProcessError) as error:
        print(f"FAIL closed: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
