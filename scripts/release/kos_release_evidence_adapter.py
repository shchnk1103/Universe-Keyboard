#!/usr/bin/env python3
"""Map Universe release-evidence exports to the KOS v1 Envelope.

This module is a build/release-time adapter.  It deliberately does not own the
Main-App evidence store, read the App Group, call a network service, or make a
Product/Quality/Release decision.  The Main App remains the source of the
content-free run export; this adapter only constructs a portable KOS Envelope
from that export and separately plans delta-aware evidence reuse.
"""

from __future__ import annotations

import argparse
import copy
import json
import re
import sys
import uuid
from dataclasses import asdict, dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping


UNKNOWN = "UNKNOWN"
CONTRACT = "kos.release-evidence"
CONTRACT_VERSION = {"major": 1, "minor": 0}
PROFILE_ID = "profile://universe-keyboard/release-evidence-v1"
MAX_STRING_LENGTH = 1024
MAX_IDENTITY_PROPERTIES = 64
MAX_AGE_DAYS = 30
PINNED_CANDIDATE_MANIFEST = (
    "README.md",
    "docs/adoption-guide.md",
    "docs/assignments/KOS-RELEASE-EVIDENCE-PORTABILITY-001.md",
    "docs/assignments/KOS-RELEASE-EVIDENCE-PORTABILITY-002.md",
    "ops/release-evidence.md",
    "schemas/release-evidence-v1.schema.json",
    "scripts/validate_release_evidence.py",
    "templates/docs/RELEASE_EVIDENCE_PROFILE.md",
    "tests/fixtures/release_evidence_cases.json",
    "tests/test_release_evidence.py",
)

# These values are the exact candidate pins recorded by the adopter Profile.
# They are metadata for the adapter/review receipt; they are not copied into a
# portable Envelope field and they do not turn the untagged candidate into a
# hosted release.
PINNED_PROFILE = {
    "kit_version": "v0.8.0",
    "candidate_manifest": PINNED_CANDIDATE_MANIFEST,
    "implementation_commit": "8e55551a3b56b57e7fc5ab5544d653f9c6854df9",
    "adoption_metadata_commit": "f5c88d57f599d7ef352322ea7664f637fb288d60",
    "candidate_tree_digest": "fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9",
    "contract_source_digest": "f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673",
    "schema_digest": "4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce",
    "evaluator_digest": "a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9",
}

KNOWN_OUTCOMES = {"pass", "fail", "inconclusive", "not-run"}
MAIN_APP_OUTCOME_MAP = {
    "pass": "pass",
    # The Main App has a source-specific partial state; KOS v1 has no partial
    # outcome, so preserve the non-passing meaning as inconclusive.
    "partial": "inconclusive",
    "fail": "fail",
    "inconclusive": "inconclusive",
    "not-run": "not-run",
}
KNOWN_LANES = {"daily_beta", "external_candidate"}
KNOWN_PROFILES = {"delta", "triggered", "baseline"}
MAIN_APP_RECORD_TYPE = "release_evidence_run"
MAIN_APP_SCHEMA_VERSION = 1
MAIN_APP_EVIDENCE_CONTRACT_VERSION = "release-evidence-v1"
MAIN_APP_SOURCE_ID = "SRC-MAIN-STORE"
MAIN_APP_SOURCE_OWNER_PATH = "Universe Keyboard/Services/ReleaseEvidenceStore.swift"
# REP-Q-01 has not yet supplied a stable, owner-attested implementation identity
# for the Main-App source seam.  Keep this gate deliberately code-controlled:
# caller input must not be able to opt into current-proof by declaring a boolean.
MAIN_APP_SOURCE_BINDING_STATE = "unresolved"
MAIN_APP_NON_CLAIMS = (
    "does_not_replace_existing_ci_gate",
    "does_not_grant_independent_quality_pass",
    "does_not_grant_product_or_release_gate_pass",
    "external_actions_remain_separately_authorized",
)
MAIN_APP_RUN_REQUIRED_KEYS = frozenset(
    {
        "schemaVersion",
        "id",
        "createdAt",
        "updatedAt",
        "lane",
        "profile",
        "appVersion",
        "appBuild",
        "deviceModel",
        "osVersion",
        "candidateID",
        "behaviorContract",
        "steps",
    }
)
MAIN_APP_RUN_OPTIONAL_KEYS = frozenset({"promotionSourceRunID", "promotionMode"})
MAIN_APP_STEP_ALLOWED_KEYS = frozenset({"scope", "outcome", "note"})
MAIN_APP_PROMOTION_MODES = {
    "pending_artifact_match",
    "contract_baseline",
    "exact_artifact",
}
KNOWN_SCOPES = {
    "candidate_identity",
    "changed_path_validation",
    "affected_path_smoke",
    "evidence_reuse",
    "triggered_boundary",
    "baseline_boundary",
    "external_candidate_readiness",
}

CLAIM_BINDINGS_BY_SCOPE = {
    "candidate_identity": {
        "claim_ref": "UK-RE-CANDIDATE-IDENTITY",
        "coverage_ref": "UK-RE-COVERAGE-CANDIDATE-IDENTITY",
    },
    "changed_path_validation": {
        "claim_ref": "UK-RE-CHANGED-PATH-VALIDATION",
        "coverage_ref": "UK-RE-COVERAGE-CHANGED-PATH-VALIDATION",
    },
    "affected_path_smoke": {
        "claim_ref": "UK-RE-AFFECTED-PATH-SMOKE",
        "coverage_ref": "UK-RE-COVERAGE-AFFECTED-PATH-SMOKE",
    },
    "evidence_reuse": {
        "claim_ref": "UK-RE-EVIDENCE-REUSE",
        "coverage_ref": "UK-RE-COVERAGE-EVIDENCE-REUSE",
    },
    "triggered_boundary": {
        "claim_ref": "UK-RE-TRIGGERED-BOUNDARY",
        "coverage_ref": "UK-RE-COVERAGE-TRIGGERED-BOUNDARY",
    },
    "baseline_boundary": {
        "claim_ref": "UK-RE-BASELINE-BOUNDARY",
        "coverage_ref": "UK-RE-COVERAGE-BASELINE-BOUNDARY",
    },
    "external_candidate_readiness": {
        "claim_ref": "UK-RE-EXTERNAL-CANDIDATE-READINESS",
        "coverage_ref": "UK-RE-COVERAGE-EXTERNAL-CANDIDATE-READINESS",
    },
}

ARTIFACT_IDENTITY_KEYS = frozenset(
    {"source_commit", "version", "build", "archive_sha256", "package_sha256", "release_lineage"}
)
CONTEXT_IDENTITY_KEYS = frozenset(
    {"behavior_contract", "device_model", "os_version", "validation_profile"}
)
DELTA_EVIDENCE_REQUIRED_KEYS = frozenset(
    {
        "evidence_key",
        "scope",
        "claim_ref",
        "coverage_ref",
        "candidate_id",
        "artifact_identity",
        "context_identity",
        "profile_ref",
        "source_identity",
        "comparison_basis",
        "observed_at",
        "contract_pin",
        "schema_pin",
        "evaluator_pin",
    }
)
DELTA_EVIDENCE_ALLOWED_KEYS = DELTA_EVIDENCE_REQUIRED_KEYS | {"valid_until"}
CANDIDATE_REQUIRED_KEYS = frozenset(
    {
        "artifact_identity",
        "artifact_or_input_ref",
        "environment_ref",
        "comparison_basis",
        "final_tree_digest",
        "candidate_head",
    }
)
CANDIDATE_OPTIONAL_KEYS = frozenset(
    {"candidate_id", "context_identity", "profile_ref"}
)
PROVENANCE_ALLOWED_KEYS = frozenset({"producer_ref", "created_at"})
EVIDENCE_ALLOWED_KEYS = frozenset({"observed_at", "valid_until"})
ADAPTER_INPUT_REQUIRED_KEYS = frozenset(
    {"record_type", "main_app_source", "main_app_export", "candidate", "evidence"}
)
ADAPTER_INPUT_OPTIONAL_KEYS = frozenset(
    {"record_id", "provenance", "delivery", "final_validation", "promotion"}
)

BASE_SCOPES = (
    "candidate_identity",
    "changed_path_validation",
    "affected_path_smoke",
)

# Semantic surfaces are accepted as explicit input because a changed claim or
# policy can be affected without a one-to-one source-file path.
SEMANTIC_SURFACES = {
    "candidate_identity",
    "artifact_identity",
    "context_identity",
    "environment_identity",
    "comparison_basis",
    "profile",
    "source_owner",
    "privacy_allowlist",
    "observation_freshness",
    "freshness",
    "promotion",
    "release_lineage",
    "baseline",
    "previous_receipt",
    "schema",
    "contract",
    "evaluator",
    "delivery",
    "hosted_ci",
    "final_validation",
    "publication",
    "unknown",
}

BASELINE_PREFIXES = (
    ".github/workflows/",
    ".xcodeproj/",
    ".xcworkspace/",
    "Packages/RimeBridge/",
    "scripts/ci/",
    "scripts/release/",
    "Universe Keyboard/RimeBuiltin/",
    "Universe Keyboard/Vendor/",
    "config/",
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

KNOWN_TOP_LEVELS = {
    ".github",
    ".kos",
    "docs",
    "Keyboard",
    "KeyboardTests",
    "KeyboardExtensionTests",
    "Packages",
    "Universe Keyboard",
    "UniverseKeyboardTests",
    "UniverseKeyboardUITests",
    "scripts",
    "config",
}

# Keep the docs-only escape hatch explicit.  Profile, authority, assignment,
# architecture and machine-readable KOS files are release-evidence
# dependencies, not ordinary documentation.
DOCS_ONLY_PATHS = frozenset({"docs/RELEASE_CHECKLIST.md"})
RELEASE_DEPENDENCY_PATH_PREFIXES = (
    "docs/kos/",
    "docs/assignments/",
    "docs/authorizations/",
    "docs/product-decisions/",
    "docs/architecture/decisions/",
)

POINTER_RE = re.compile(
    r"^(?:"
    r"repo://[A-Za-z0-9._/-]+#[A-Za-z0-9_.-]+|"
    r"appdiag://release-evidence/[A-Za-z0-9._-]+/[0-9a-f-]{36}|"
    r"opaque://[A-Za-z0-9._-]+/[A-Za-z0-9._-]+"
    r");sha256=[0-9a-f]{64};class=(?:release-candidate|diagnostic-short|review-record)$"
)
TOKEN_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:/#,?=-]*$")
IDENTITY_KEY_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_.-]*$")
COMMIT_RE = re.compile(r"^[0-9a-f]{40,64}$")
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
TREE_DIGEST_RE = re.compile(r"^sha256:[0-9a-f]{64}$")
SAFE_PATH_RE = re.compile(r"^[^\x00]+$")
SAFE_RECORD_ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$")


class AdapterInputError(ValueError):
    """Raised when a project input cannot safely map to the Profile."""


def _path(label: str, key: str) -> str:
    return f"{label}.{key}"


def _mapping(value: Any, label: str) -> Mapping[str, Any]:
    if not isinstance(value, Mapping):
        raise AdapterInputError(f"{label} must be an object")
    return value


def _bounded_string(value: Any, label: str) -> str:
    if not isinstance(value, str) or not value or len(value) > MAX_STRING_LENGTH:
        raise AdapterInputError(f"{label} must be a non-empty bounded string")
    if any(ord(character) < 32 or ord(character) == 127 for character in value):
        raise AdapterInputError(f"{label} contains a control character")
    return value


def _resolved(value: Any, label: str) -> str:
    result = _bounded_string(value, label)
    if result.strip().upper() in {UNKNOWN, "TODO", "TBD"}:
        raise AdapterInputError(f"{label} is unresolved")
    return result


def _optional_resolved(value: Any, label: str) -> str | None:
    if value is None:
        return None
    return _resolved(value, label)


def _token(value: Any, label: str, *, allow_unknown: bool = False) -> str:
    result = _bounded_string(value, label)
    if result.strip().upper() in {UNKNOWN, "TODO", "TBD"}:
        # Only the canonical UNKNOWN spelling is allowed for fields whose
        # contract explicitly permits an unresolved value.  Rejecting case or
        # whitespace variants keeps the adapter and pinned evaluator aligned.
        if allow_unknown and result == UNKNOWN:
            return result
        raise AdapterInputError(f"{label} is unresolved")
    if not TOKEN_RE.fullmatch(result):
        raise AdapterInputError(f"{label} must be a content-free token")
    return result


def _identity(
    value: Any,
    label: str,
    *,
    require_resolved: bool = True,
    allowed_keys: Iterable[str] | None = None,
) -> dict[str, str]:
    source = _mapping(value, label)
    if not source or len(source) > MAX_IDENTITY_PROPERTIES:
        raise AdapterInputError(f"{label} must have 1-{MAX_IDENTITY_PROPERTIES} properties")
    allowed = set(allowed_keys) if allowed_keys is not None else None
    if allowed is not None and set(source) != allowed:
        missing = sorted(allowed - set(source))
        extra = sorted(set(source) - allowed)
        details = []
        if missing:
            details.append(f"missing={missing}")
        if extra:
            details.append(f"unsupported={extra}")
        raise AdapterInputError(f"{label} identity keys are not exact: {', '.join(details)}")
    result: dict[str, str] = {}
    for key, raw_value in source.items():
        if not isinstance(key, str) or not IDENTITY_KEY_RE.fullmatch(key) or len(key) > 64:
            raise AdapterInputError(f"{label} has an invalid identity key")
        if allowed is not None and key not in allowed:
            raise AdapterInputError(f"{label}.{key} is not an allowlisted identity key")
        value_label = _path(label, key)
        if require_resolved:
            result[key] = _resolved(raw_value, value_label)
        else:
            result[key] = _bounded_string(raw_value, value_label)
    return result


def _require_sha(value: Any, label: str) -> str:
    result = _resolved(value, label)
    if not SHA256_RE.fullmatch(result):
        raise AdapterInputError(f"{label} must be a lower-case SHA-256 digest")
    return result


def _require_commit(value: Any, label: str) -> str:
    result = _resolved(value, label)
    if not COMMIT_RE.fullmatch(result):
        raise AdapterInputError(f"{label} must be a full lower-case commit SHA")
    return result


def _head_or_unknown(value: Any, label: str) -> str:
    if value == UNKNOWN:
        return UNKNOWN
    return _require_commit(value, label)


def _tree_digest(value: Any, label: str, *, allow_unknown: bool = False) -> str:
    if value == UNKNOWN and allow_unknown:
        return UNKNOWN
    result = _resolved(value, label)
    if not TREE_DIGEST_RE.fullmatch(result):
        raise AdapterInputError(f"{label} must be a sha256 tree digest")
    return result


def _outcome(value: Any, label: str, *, allow_unknown: bool = False) -> str:
    result = _token(value, label, allow_unknown=allow_unknown)
    if result == UNKNOWN:
        return result
    if result not in KNOWN_OUTCOMES:
        raise AdapterInputError(f"{label} must be a supported outcome")
    return result


def _relation(value: Any, label: str) -> str:
    """Validate the delivery relation, where ``unknown`` is a real state."""

    result = _bounded_string(value, label)
    if result not in {"same-head", "ahead", "divergent", "unknown"}:
        raise AdapterInputError(f"{label} is unsupported")
    return result


def _iso_datetime(value: Any, label: str) -> str:
    result = _resolved(value, label)
    normalized = result[:-1] + "+00:00" if result.endswith("Z") else result
    try:
        parsed = datetime.fromisoformat(normalized)
    except ValueError as error:
        raise AdapterInputError(f"{label} must be ISO-8601 with timezone") from error
    if parsed.tzinfo is None or parsed.utcoffset() is None:
        raise AdapterInputError(f"{label} must include a timezone")
    return result


def _pointer(value: Any, label: str, *, allow_unknown: bool = False) -> str:
    result = _bounded_string(value, label)
    if result == UNKNOWN and allow_unknown:
        return result
    if not POINTER_RE.fullmatch(result):
        raise AdapterInputError(f"{label} does not use the Profile pointer grammar")
    if result.startswith("repo://"):
        repo_path = result[len("repo://") :].split("#", 1)[0]
        segments = repo_path.split("/")
        if not repo_path or any(segment in {"", ".", ".."} for segment in segments):
            raise AdapterInputError(f"{label} repo path is not canonical and repository-relative")
    elif result.startswith("appdiag://release-evidence/"):
        match = re.fullmatch(
            r"appdiag://release-evidence/[A-Za-z0-9._-]+/([0-9a-f-]{36});"
            r"sha256=[0-9a-f]{64};class=(?:release-candidate|diagnostic-short|review-record)",
            result,
        )
        if match is None:
            raise AdapterInputError(f"{label} does not use a canonical App-Diagnostics pointer")
        try:
            operation_id = str(uuid.UUID(match.group(1)))
        except ValueError as error:
            raise AdapterInputError(f"{label} operation ID is not a UUID") from error
        if operation_id != match.group(1):
            raise AdapterInputError(f"{label} operation ID is not canonical")
    return result


def _uuid_string(value: Any, label: str) -> str:
    result = _resolved(value, label).lower()
    try:
        parsed = uuid.UUID(result)
    except ValueError as error:
        raise AdapterInputError(f"{label} must be a UUID") from error
    return str(parsed)


def _value(mapping: Mapping[str, Any], *keys: str, default: Any = None) -> Any:
    for key in keys:
        if key in mapping:
            return mapping[key]
    return default


def _validate_adapter_input(payload: Mapping[str, Any]) -> None:
    missing = ADAPTER_INPUT_REQUIRED_KEYS - set(payload)
    unknown = set(payload) - (ADAPTER_INPUT_REQUIRED_KEYS | ADAPTER_INPUT_OPTIONAL_KEYS)
    if missing or unknown:
        details = []
        if missing:
            details.append(f"missing={sorted(missing)}")
        if unknown:
            details.append(f"unsupported={sorted(unknown)}")
        raise AdapterInputError(
            "adapter input does not match the canonical root shape: "
            + ", ".join(details)
        )
    record_type = _token(payload.get("record_type"), "record_type")
    if record_type != "universe-release-evidence-adapter-input":
        raise AdapterInputError("record_type is unsupported")


def _run_from_input(payload: Mapping[str, Any]) -> Mapping[str, Any]:
    raw_export = payload.get("main_app_export")
    export = _mapping(raw_export, "main_app_export")
    required_keys = {
        "schemaVersion",
        "evidenceContractVersion",
        "recordType",
        "run",
        "outcome",
        "nonClaims",
    }
    if set(export) != required_keys:
        raise AdapterInputError(
            "main_app_export must match the canonical Main-App export shape"
        )
    record_type = _value(export, "record_type", "recordType")
    if record_type != MAIN_APP_RECORD_TYPE:
        raise AdapterInputError("main_app_export.recordType is not supported")
    if export.get("schemaVersion") != MAIN_APP_SCHEMA_VERSION:
        raise AdapterInputError("main_app_export.schemaVersion is unsupported")
    if export.get("evidenceContractVersion") != MAIN_APP_EVIDENCE_CONTRACT_VERSION:
        raise AdapterInputError(
            "main_app_export.evidenceContractVersion is unsupported"
        )
    export_outcome = _token(export.get("outcome"), "main_app_export.outcome")
    if export_outcome not in MAIN_APP_OUTCOME_MAP:
        raise AdapterInputError("main_app_export.outcome is unsupported")
    non_claims = export.get("nonClaims")
    if non_claims != list(MAIN_APP_NON_CLAIMS):
        raise AdapterInputError(
            "main_app_export.nonClaims must match the canonical Main-App contract"
        )
    for index, non_claim in enumerate(non_claims):
        _token(non_claim, f"main_app_export.nonClaims[{index}]")
    return _mapping(export.get("run"), "main_app_export.run")


def _source_pointer(payload: Mapping[str, Any]) -> tuple[dict[str, str], str]:
    source = _mapping(payload.get("main_app_source"), "main_app_source")
    required_keys = {
        "source_identity",
        "record_id",
        "operation_id",
        "sha256",
        "retention_class",
    }
    if set(source) != required_keys:
        raise AdapterInputError("main_app_source must bind the canonical source seam")
    source_identity = _token(
        source.get("source_identity"), "main_app_source.source_identity"
    )
    if source_identity != MAIN_APP_SOURCE_ID:
        raise AdapterInputError("main_app_source.source_identity is not canonical")
    record_id = _resolved(source.get("record_id"), "main_app_source.record_id")
    if not SAFE_RECORD_ID_RE.fullmatch(record_id):
        raise AdapterInputError("main_app_source.record_id must be a safe opaque identifier")
    operation_id = _uuid_string(source.get("operation_id"), "main_app_source.operation_id")
    digest = _require_sha(source.get("sha256"), "main_app_source.sha256")
    retention_class = _token(source.get("retention_class"), "main_app_source.retention_class")
    if retention_class != "diagnostic-short":
        raise AdapterInputError("Main-App source records must use diagnostic-short retention")
    pointer = (
        f"appdiag://release-evidence/{record_id}/{operation_id};"
        f"sha256={digest};class={retention_class}"
    )
    return {
        "record_id": record_id,
        "operation_id": operation_id,
        "sha256": digest,
        "retention_class": retention_class,
    }, pointer


def _required_scopes(lane: str, profile: str) -> tuple[str, ...]:
    scopes = list(BASE_SCOPES)
    if lane == "external_candidate":
        scopes.extend(("evidence_reuse", "external_candidate_readiness"))
    if profile == "triggered":
        scopes.append("triggered_boundary")
    elif profile == "baseline":
        scopes.append("baseline_boundary")
    return tuple(scopes)


def _normalize_steps(run: Mapping[str, Any]) -> dict[str, str]:
    raw_steps = run.get("steps")
    if isinstance(raw_steps, list):
        entries = raw_steps
    else:
        # ReleaseEvidenceRun Codable encodes steps as an array.  Do not accept
        # a convenient object shorthand at this source-owner boundary: it can
        # come from a foreign serializer and still look like a valid run.
        raise AdapterInputError("run.steps must be the canonical array shape")

    steps: dict[str, str] = {}
    for index, raw_step in enumerate(entries):
        step = _mapping(raw_step, f"run.steps[{index}]")
        unknown_keys = set(step) - MAIN_APP_STEP_ALLOWED_KEYS
        missing_keys = {"scope", "outcome"} - set(step)
        if unknown_keys or missing_keys:
            details = []
            if missing_keys:
                details.append(f"missing={sorted(missing_keys)}")
            if unknown_keys:
                details.append(f"unsupported={sorted(unknown_keys)}")
            raise AdapterInputError(
                f"run.steps[{index}] does not match the canonical step shape: "
                + ", ".join(details)
            )
        scope = _token(step.get("scope"), f"run.steps[{index}].scope")
        if scope not in KNOWN_SCOPES:
            raise AdapterInputError(f"run.steps[{index}].scope is not in the Profile registry")
        source_outcome = _token(step.get("outcome"), f"run.steps[{index}].outcome")
        try:
            outcome = MAIN_APP_OUTCOME_MAP[source_outcome]
        except KeyError as error:
            raise AdapterInputError(
                f"run.steps[{index}].outcome is unsupported"
            ) from error
        if scope in steps:
            raise AdapterInputError(f"run.steps contains duplicate scope: {scope}")
        if "note" in step:
            note = step["note"]
            if not isinstance(note, str) or len(note) > MAX_STRING_LENGTH:
                raise AdapterInputError(
                    f"run.steps[{index}].note must be a bounded string"
                )
            if any(ord(character) < 32 or ord(character) == 127 for character in note):
                raise AdapterInputError(
                    f"run.steps[{index}].note contains a control character"
                )
        # Notes, if present in the Main-App export, are intentionally ignored.
        # They are not part of the portable Envelope and cannot leak into it.
        steps[scope] = outcome
    return steps


def _run_identity(run: Mapping[str, Any]) -> dict[str, Any]:
    missing_keys = MAIN_APP_RUN_REQUIRED_KEYS - set(run)
    unknown_keys = set(run) - (MAIN_APP_RUN_REQUIRED_KEYS | MAIN_APP_RUN_OPTIONAL_KEYS)
    if missing_keys or unknown_keys:
        details = []
        if missing_keys:
            details.append(f"missing={sorted(missing_keys)}")
        if unknown_keys:
            details.append(f"unsupported={sorted(unknown_keys)}")
        raise AdapterInputError(
            "main_app_export.run does not match the canonical Main-App shape: "
            + ", ".join(details)
        )
    if run.get("schemaVersion") != MAIN_APP_SCHEMA_VERSION:
        raise AdapterInputError("main_app_export.run.schemaVersion is unsupported")
    lane = _token(_value(run, "lane"), "run.lane")
    profile = _token(_value(run, "profile", "validation_profile"), "run.profile")
    if lane not in KNOWN_LANES or profile not in KNOWN_PROFILES:
        raise AdapterInputError("run lane/profile is not supported by the Profile")
    candidate_id = _token(
        _value(run, "candidate_id", "candidateID"), "run.candidate_id"
    )
    behavior_contract = _token(
        _value(run, "behavior_contract", "behaviorContract"),
        "run.behavior_contract",
    )
    device_model = _token(
        _value(run, "device_model", "deviceModel"), "run.device_model"
    )
    os_version = _token(
        _value(run, "os_version", "osVersion"), "run.os_version"
    )
    app_version = _token(
        _value(run, "app_version", "appVersion"), "run.app_version"
    )
    app_build = _token(_value(run, "app_build", "appBuild"), "run.app_build")
    created_at = _iso_datetime(
        _value(run, "created_at", "createdAt"), "run.created_at"
    )
    updated_at = _iso_datetime(
        _value(run, "updated_at", "updatedAt"), "run.updated_at"
    )
    run_id = _uuid_string(_value(run, "id", "run_id", "runID"), "run.id")
    if "promotionSourceRunID" in run:
        _uuid_string(run["promotionSourceRunID"], "run.promotionSourceRunID")
    if "promotionMode" in run:
        promotion_mode = _token(run["promotionMode"], "run.promotionMode")
        if promotion_mode not in MAIN_APP_PROMOTION_MODES:
            raise AdapterInputError("run.promotionMode is unsupported")
    return {
        "lane": lane,
        "profile": profile,
        "candidate_id": candidate_id,
        "behavior_contract": behavior_contract,
        "device_model": device_model,
        "os_version": os_version,
        "app_version": app_version,
        "app_build": app_build,
        "created_at": created_at,
        "updated_at": updated_at,
        "run_id": run_id,
    }


def _canonical_main_app_outcome(
    run: Mapping[str, Any], run_identity: Mapping[str, Any]
) -> str:
    raw_steps = run["steps"]
    if not isinstance(raw_steps, list):
        raise AdapterInputError("run.steps must be the canonical array shape")
    raw_outcomes = [
        _mapping(step, f"run.steps[{index}]").get("outcome")
        for index, step in enumerate(raw_steps)
    ]
    outcomes = [
        _token(value, f"run.steps[{index}].outcome")
        for index, value in enumerate(raw_outcomes)
    ]
    if not outcomes:
        return "not-run"
    if "fail" in outcomes:
        return "fail"
    if "inconclusive" in outcomes:
        return "inconclusive"
    if any(outcome in {"partial", "not-run"} for outcome in outcomes):
        return "partial"
    if (
        run_identity["lane"] == "external_candidate"
        and run.get("promotionMode") != "exact_artifact"
    ):
        return "partial"
    return "pass"


def _artifact_identity(
    raw: Any, label: str = "candidate.artifact_identity"
) -> dict[str, str]:
    identity = _identity(
        raw,
        label,
        allowed_keys=ARTIFACT_IDENTITY_KEYS,
    )
    _require_commit(identity["source_commit"], f"{label}.source_commit")
    _require_sha(identity["archive_sha256"], f"{label}.archive_sha256")
    _require_sha(identity["package_sha256"], f"{label}.package_sha256")
    for key in ("version", "build", "release_lineage"):
        _token(identity[key], f"{label}.{key}")
    return identity


def _context_identity(raw: Any, label: str) -> dict[str, str]:
    identity = _identity(raw, label, allowed_keys=CONTEXT_IDENTITY_KEYS)
    for key, value in identity.items():
        _token(value, f"{label}.{key}")
    return identity


def _candidate(payload: Mapping[str, Any], run_identity: Mapping[str, Any]) -> dict[str, Any]:
    raw = _mapping(payload.get("candidate"), "candidate")
    candidate_keys = set(raw)
    unsupported = candidate_keys - (CANDIDATE_REQUIRED_KEYS | CANDIDATE_OPTIONAL_KEYS)
    missing = CANDIDATE_REQUIRED_KEYS - candidate_keys
    if unsupported or missing:
        details = []
        if missing:
            details.append(f"missing={sorted(missing)}")
        if unsupported:
            details.append(f"unsupported={sorted(unsupported)}")
        raise AdapterInputError(
            "candidate does not match the canonical input shape: "
            + ", ".join(details)
        )
    candidate_id = _token(
        raw.get("candidate_id", run_identity["candidate_id"]), "candidate.candidate_id"
    )
    if candidate_id != run_identity["candidate_id"]:
        raise AdapterInputError("candidate.candidate_id must match the Main-App run")
    artifact_identity = _artifact_identity(raw.get("artifact_identity"))
    if artifact_identity["version"] != run_identity["app_version"]:
        raise AdapterInputError("candidate artifact version does not match Main-App run")
    if artifact_identity["build"] != run_identity["app_build"]:
        raise AdapterInputError("candidate artifact build does not match Main-App run")

    expected_context = {
        "behavior_contract": run_identity["behavior_contract"],
        "device_model": run_identity["device_model"],
        "os_version": run_identity["os_version"],
        "validation_profile": run_identity["profile"],
    }
    context_identity = _context_identity(
        raw.get("context_identity", expected_context), "candidate.context_identity"
    )
    if context_identity != expected_context:
        raise AdapterInputError("candidate.context_identity must match Main-App run context")

    profile_ref = _token(raw.get("profile_ref", PROFILE_ID), "candidate.profile_ref")
    if profile_ref != PROFILE_ID:
        raise AdapterInputError("candidate.profile_ref does not match the adopter Profile")
    return {
        "candidate_id": candidate_id,
        "artifact_identity": artifact_identity,
        "context_identity": context_identity,
        "artifact_or_input_ref": _pointer(
            raw.get("artifact_or_input_ref"), "candidate.artifact_or_input_ref"
        ),
        "environment_ref": _pointer(raw.get("environment_ref"), "candidate.environment_ref"),
        "comparison_basis": _token(raw.get("comparison_basis"), "candidate.comparison_basis"),
        "profile_ref": profile_ref,
        "final_tree_digest": _tree_digest(
            raw.get("final_tree_digest"), "candidate.final_tree_digest"
        ),
        "candidate_head": _require_commit(raw.get("candidate_head"), "candidate.candidate_head"),
    }


def _default_delivery(candidate: Mapping[str, Any], observed_at: str) -> dict[str, Any]:
    return {
        "observed_at": observed_at,
        "candidate_id": candidate["candidate_id"],
        "artifact_identity": copy.deepcopy(candidate["artifact_identity"]),
        "context_identity": copy.deepcopy(candidate["context_identity"]),
        "profile_ref": candidate["profile_ref"],
        "local_head": UNKNOWN,
        "published_head": UNKNOWN,
        "hosted_ci_run_ref": UNKNOWN,
        "hosted_ci_head": UNKNOWN,
        "hosted_ci_result": "not-run",
        "pr_state": "not-authorized",
        "comparison_basis": candidate["comparison_basis"],
        "relation": "unknown",
    }


def _default_final_validation(candidate: Mapping[str, Any], observed_at: str) -> dict[str, Any]:
    return {
        "observed_at": observed_at,
        "candidate_id": candidate["candidate_id"],
        "artifact_identity": copy.deepcopy(candidate["artifact_identity"]),
        "context_identity": copy.deepcopy(candidate["context_identity"]),
        "profile_ref": candidate["profile_ref"],
        "final_tree_digest": UNKNOWN,
        "checker_ref": UNKNOWN,
        "checker_version": UNKNOWN,
        "scope": UNKNOWN,
        "comparison_baseline": UNKNOWN,
        "exit_code": 255,
        "result": "not-run",
        "output_ref": UNKNOWN,
    }


def _merge_receipt_defaults(
    defaults: dict[str, Any], raw: Any, label: str
) -> dict[str, Any]:
    """Overlay a receipt while keeping its top-level shape closed.

    The KOS schema permits arbitrary strings in several receipt fields.  The
    project Profile is stricter: every supplied value must remain an opaque
    token, a known outcome, a digest, or a Profile pointer before it reaches
    the portable Envelope.
    """

    if raw is None:
        return copy.deepcopy(defaults)
    source = _mapping(raw, label)
    unknown_keys = set(source) - set(defaults)
    if unknown_keys:
        raise AdapterInputError(f"{label} has unsupported fields: {sorted(unknown_keys)}")
    result = copy.deepcopy(defaults)
    result.update(source)
    return result


def _validate_receipt_binding(
    receipt: Mapping[str, Any],
    label: str,
    candidate: Mapping[str, Any],
) -> None:
    candidate_id = _token(receipt.get("candidate_id"), f"{label}.candidate_id")
    if candidate_id != candidate["candidate_id"]:
        raise AdapterInputError(f"{label}.candidate_id does not match candidate")
    artifact = _artifact_identity(
        receipt.get("artifact_identity"), f"{label}.artifact_identity"
    )
    if artifact != candidate["artifact_identity"]:
        raise AdapterInputError(f"{label}.artifact_identity does not match candidate")
    context = _context_identity(
        receipt.get("context_identity"), f"{label}.context_identity"
    )
    if context != candidate["context_identity"]:
        raise AdapterInputError(f"{label}.context_identity does not match candidate")
    profile_ref = _token(receipt.get("profile_ref"), f"{label}.profile_ref")
    if profile_ref != candidate["profile_ref"]:
        raise AdapterInputError(f"{label}.profile_ref does not match candidate")


def _merge_delivery(
    candidate: Mapping[str, Any], raw: Any, observed_at: str
) -> dict[str, Any]:
    result = _merge_receipt_defaults(
        _default_delivery(candidate, observed_at), raw, "delivery"
    )
    result["observed_at"] = _iso_datetime(result["observed_at"], "delivery.observed_at")
    _validate_receipt_binding(result, "delivery", candidate)
    result["local_head"] = _head_or_unknown(result["local_head"], "delivery.local_head")
    result["published_head"] = _head_or_unknown(
        result["published_head"], "delivery.published_head"
    )
    result["hosted_ci_run_ref"] = _pointer(
        result["hosted_ci_run_ref"], "delivery.hosted_ci_run_ref", allow_unknown=True
    )
    result["hosted_ci_head"] = _head_or_unknown(
        result["hosted_ci_head"], "delivery.hosted_ci_head"
    )
    result["hosted_ci_result"] = _outcome(
        result["hosted_ci_result"], "delivery.hosted_ci_result"
    )
    result["pr_state"] = _token(result["pr_state"], "delivery.pr_state")
    result["comparison_basis"] = _token(
        result["comparison_basis"], "delivery.comparison_basis"
    )
    if result["comparison_basis"] != candidate["comparison_basis"]:
        raise AdapterInputError("delivery.comparison_basis does not match candidate")
    result["relation"] = _relation(result["relation"], "delivery.relation")
    return result


def _merge_final_validation(
    candidate: Mapping[str, Any], raw: Any, observed_at: str
) -> dict[str, Any]:
    result = _merge_receipt_defaults(
        _default_final_validation(candidate, observed_at),
        raw,
        "final_validation",
    )
    result["observed_at"] = _iso_datetime(
        result["observed_at"], "final_validation.observed_at"
    )
    _validate_receipt_binding(result, "final_validation", candidate)
    result["final_tree_digest"] = _tree_digest(
        result["final_tree_digest"],
        "final_validation.final_tree_digest",
        allow_unknown=True,
    )
    result["checker_ref"] = _pointer(
        result["checker_ref"], "final_validation.checker_ref", allow_unknown=True
    )
    result["checker_version"] = _token(
        result["checker_version"], "final_validation.checker_version", allow_unknown=True
    )
    result["scope"] = _token(
        result["scope"], "final_validation.scope", allow_unknown=True
    )
    result["comparison_baseline"] = _pointer(
        result["comparison_baseline"],
        "final_validation.comparison_baseline",
        allow_unknown=True,
    )
    exit_code = result["exit_code"]
    if type(exit_code) is not int or not 0 <= exit_code <= 255:
        raise AdapterInputError("final_validation.exit_code must be an integer from 0 through 255")
    result["result"] = _outcome(result["result"], "final_validation.result")
    result["output_ref"] = _pointer(
        result["output_ref"], "final_validation.output_ref", allow_unknown=True
    )
    return result


def _bound_target(candidate: Mapping[str, Any]) -> dict[str, Any]:
    return {
        "candidate_id": candidate["candidate_id"],
        "artifact_identity": copy.deepcopy(candidate["artifact_identity"]),
        "context_identity": copy.deepcopy(candidate["context_identity"]),
        "profile_ref": candidate["profile_ref"],
        "contract_version": copy.deepcopy(CONTRACT_VERSION),
    }


def _contract_version(value: Any, label: str) -> dict[str, int]:
    version = _mapping(value, label)
    if set(version) != {"major", "minor"}:
        raise AdapterInputError(f"{label} must contain only major and minor")
    if version.get("major") != CONTRACT_VERSION["major"] or version.get(
        "minor"
    ) != CONTRACT_VERSION["minor"]:
        raise AdapterInputError(f"{label} does not match the adapter contract")
    return copy.deepcopy(CONTRACT_VERSION)


def _target_binding(value: Any, candidate: Mapping[str, Any]) -> dict[str, Any]:
    target = _mapping(value, "promotion.target_binding")
    required = {
        "candidate_id",
        "artifact_identity",
        "context_identity",
        "profile_ref",
        "contract_version",
    }
    if set(target) != required:
        raise AdapterInputError("promotion.target_binding keys are not exact")
    candidate_id = _token(
        target.get("candidate_id"), "promotion.target_binding.candidate_id"
    )
    if candidate_id != candidate["candidate_id"]:
        raise AdapterInputError("promotion.target_binding.candidate_id does not match candidate")
    artifact = _artifact_identity(
        target.get("artifact_identity"), "promotion.target_binding.artifact_identity"
    )
    if artifact != candidate["artifact_identity"]:
        raise AdapterInputError("promotion.target_binding.artifact_identity does not match candidate")
    context = _context_identity(
        target.get("context_identity"), "promotion.target_binding.context_identity"
    )
    if context != candidate["context_identity"]:
        raise AdapterInputError("promotion.target_binding.context_identity does not match candidate")
    profile_ref = _token(
        target.get("profile_ref"), "promotion.target_binding.profile_ref"
    )
    if profile_ref != candidate["profile_ref"]:
        raise AdapterInputError("promotion.target_binding.profile_ref does not match candidate")
    return {
        "candidate_id": candidate_id,
        "artifact_identity": artifact,
        "context_identity": context,
        "profile_ref": profile_ref,
        "contract_version": _contract_version(
            target.get("contract_version"), "promotion.target_binding.contract_version"
        ),
    }


def _generated_receipt_pointer(kind: str, source: Mapping[str, str]) -> str:
    digest = source["sha256"]
    return (
        f"opaque://universe-keyboard/{kind}-{source['record_id']};"
        f"sha256={digest};class=review-record"
    )


def _baseline(value: Any, candidate: Mapping[str, Any]) -> dict[str, Any] | None:
    if value is None:
        return None
    if isinstance(value, bool):
        raise AdapterInputError(
            "promotion.baseline must be an explicit verified receipt object or null"
        )
    baseline = _mapping(value, "promotion.baseline")
    required = {
        "verification_ref",
        "reason",
        "candidate_id",
        "artifact_identity",
        "context_identity",
        "source_stage",
        "target_stage",
        "profile_ref",
        "contract_version",
    }
    if set(baseline) != required:
        raise AdapterInputError("promotion.baseline keys are not exact")
    verification_ref = _pointer(
        baseline.get("verification_ref"), "promotion.baseline.verification_ref"
    )
    if not verification_ref.endswith(";class=review-record"):
        raise AdapterInputError(
            "promotion.baseline.verification_ref must be a review-record pointer"
        )
    reason = _token(baseline.get("reason"), "promotion.baseline.reason")
    candidate_id = _token(
        baseline.get("candidate_id"), "promotion.baseline.candidate_id"
    )
    if candidate_id != candidate["candidate_id"]:
        raise AdapterInputError("promotion.baseline.candidate_id does not match candidate")
    artifact = _artifact_identity(
        baseline.get("artifact_identity"), "promotion.baseline.artifact_identity"
    )
    if artifact != candidate["artifact_identity"]:
        raise AdapterInputError("promotion.baseline.artifact_identity does not match candidate")
    context = _context_identity(
        baseline.get("context_identity"), "promotion.baseline.context_identity"
    )
    if context != candidate["context_identity"]:
        raise AdapterInputError("promotion.baseline.context_identity does not match candidate")
    source_stage = _token(
        baseline.get("source_stage"), "promotion.baseline.source_stage"
    )
    target_stage = _token(
        baseline.get("target_stage"), "promotion.baseline.target_stage"
    )
    profile_ref = _token(baseline.get("profile_ref"), "promotion.baseline.profile_ref")
    if (
        source_stage != "daily_beta"
        or target_stage != "external_candidate"
        or profile_ref != candidate["profile_ref"]
    ):
        raise AdapterInputError("promotion.baseline stage or profile is not canonical")
    return {
        "verification_ref": verification_ref,
        "reason": reason,
        "candidate_id": candidate_id,
        "artifact_identity": artifact,
        "context_identity": context,
        "source_stage": source_stage,
        "target_stage": target_stage,
        "profile_ref": profile_ref,
        "contract_version": _contract_version(
            baseline.get("contract_version"), "promotion.baseline.contract_version"
        ),
    }


def _previous_target_receipt(
    value: Any, candidate: Mapping[str, Any]
) -> dict[str, Any] | None:
    if value is None:
        return None
    receipt = _mapping(value, "promotion.previous_target_receipt")
    required = {
        "receipt_ref",
        "candidate_id",
        "artifact_identity",
        "context_identity",
        "source_stage",
        "target_stage",
        "profile_ref",
        "contract_version",
    }
    if set(receipt) != required:
        raise AdapterInputError("promotion.previous_target_receipt keys are not exact")
    receipt_ref = _pointer(
        receipt.get("receipt_ref"), "promotion.previous_target_receipt.receipt_ref"
    )
    candidate_id = _token(
        receipt.get("candidate_id"), "promotion.previous_target_receipt.candidate_id"
    )
    if candidate_id == candidate["candidate_id"]:
        raise AdapterInputError("previous target receipt must use a different candidate")
    artifact = _artifact_identity(
        receipt.get("artifact_identity"),
        "promotion.previous_target_receipt.artifact_identity",
    )
    if artifact["release_lineage"] != candidate["artifact_identity"]["release_lineage"]:
        raise AdapterInputError("previous target receipt release_lineage does not match")
    context = _context_identity(
        receipt.get("context_identity"),
        "promotion.previous_target_receipt.context_identity",
    )
    if context != candidate["context_identity"]:
        raise AdapterInputError(
            "promotion.previous_target_receipt.context_identity does not match candidate"
        )
    source_stage = _token(
        receipt.get("source_stage"), "promotion.previous_target_receipt.source_stage"
    )
    target_stage = _token(
        receipt.get("target_stage"), "promotion.previous_target_receipt.target_stage"
    )
    profile_ref = _token(
        receipt.get("profile_ref"), "promotion.previous_target_receipt.profile_ref"
    )
    if (
        source_stage != "daily_beta"
        or target_stage != "external_candidate"
        or profile_ref != candidate["profile_ref"]
    ):
        raise AdapterInputError(
            "promotion.previous_target_receipt stage or profile is not canonical"
        )
    return {
        "receipt_ref": receipt_ref,
        "candidate_id": candidate_id,
        "artifact_identity": artifact,
        "context_identity": context,
        "source_stage": source_stage,
        "target_stage": target_stage,
        "profile_ref": profile_ref,
        "contract_version": _contract_version(
            receipt.get("contract_version"),
            "promotion.previous_target_receipt.contract_version",
        ),
    }


def _promotion(raw: Any, candidate: Mapping[str, Any]) -> dict[str, Any]:
    promotion = _mapping(raw, "promotion")
    allowed = {
        "target_sequence",
        "target_binding",
        "baseline",
        "previous_target_receipt",
        "previous_target",
    }
    unknown_keys = set(promotion) - allowed
    if unknown_keys:
        raise AdapterInputError(f"promotion has unsupported fields: {sorted(unknown_keys)}")
    sequence = _token(promotion.get("target_sequence"), "promotion.target_sequence")
    if sequence not in {"first", "subsequent"}:
        raise AdapterInputError("promotion.target_sequence must be first or subsequent")

    target_spec = promotion.get("target_binding")
    if target_spec is True:
        target_binding: dict[str, Any] | None = _bound_target(candidate)
    elif target_spec is None:
        target_binding = None
    else:
        target_binding = _target_binding(target_spec, candidate)

    baseline_spec = promotion.get("baseline")
    baseline = _baseline(baseline_spec, candidate)

    previous_spec = promotion.get("previous_target_receipt")
    if previous_spec is True:
        previous = _previous_target_receipt(
            promotion.get("previous_target"), candidate
        )
    else:
        previous = _previous_target_receipt(previous_spec, candidate)

    return {
        "source_stage": "daily_beta",
        "target_stage": "external_candidate",
        "target_sequence": sequence,
        "target_binding": target_binding,
        "baseline": baseline,
        "previous_target_receipt": previous,
    }


def build_envelope(payload: Mapping[str, Any]) -> dict[str, Any]:
    """Build one KOS Envelope from a content-free Main-App export input."""

    _validate_adapter_input(payload)
    run = _run_from_input(payload)
    run_identity = _run_identity(run)
    source, source_pointer = _source_pointer(payload)
    candidate = _candidate(payload, run_identity)
    steps = _normalize_steps(run)
    export = _mapping(payload.get("main_app_export"), "main_app_export")
    expected_export_outcome = _canonical_main_app_outcome(run, run_identity)
    if export["outcome"] != expected_export_outcome:
        raise AdapterInputError(
            "main_app_export.outcome does not match the canonical Main-App run outcome"
        )
    evidence = _mapping(payload.get("evidence"), "evidence")
    unsupported_evidence = set(evidence) - EVIDENCE_ALLOWED_KEYS
    if unsupported_evidence:
        raise AdapterInputError(
            f"evidence has unsupported fields: {sorted(unsupported_evidence)}"
        )
    observed_at = _iso_datetime(
        evidence.get("observed_at", run_identity["updated_at"]),
        "evidence.observed_at",
    )
    valid_until = evidence.get("valid_until")
    if valid_until is not None:
        valid_until = _iso_datetime(valid_until, "evidence.valid_until")
    required_scopes = _required_scopes(run_identity["lane"], run_identity["profile"])
    claim_bindings = [CLAIM_BINDINGS_BY_SCOPE[scope] for scope in required_scopes]

    observations: list[dict[str, Any]] = []
    source_binding_verified = MAIN_APP_SOURCE_BINDING_STATE == "verified"
    for scope in required_scopes:
        binding = CLAIM_BINDINGS_BY_SCOPE[scope]
        outcome = steps.get(scope, "not-run")
        if not source_binding_verified and outcome == "pass":
            # The source seam is still caller-supplied until REP-Q-01 binds a
            # stable owner identity.  Preserve the observation, but make the
            # unresolved trust root visible to the evaluator as non-passing.
            outcome = "inconclusive"
        freshness: dict[str, str] = {"observed_at": observed_at}
        if valid_until is not None:
            freshness["valid_until"] = valid_until
        observations.append(
            {
                "observation_id": f"{source['record_id']}-{scope}",
                "claim_ref": binding["claim_ref"],
                "observation_outcome": outcome,
                "observed_at": observed_at,
                "evidence_ref": source_pointer if outcome != "not-run" else UNKNOWN,
                "environment_ref": candidate["environment_ref"],
                "artifact_or_input_ref": candidate["artifact_or_input_ref"],
                "coverage_ref": binding["coverage_ref"],
                "comparison_basis": candidate["comparison_basis"],
                "freshness": freshness,
                "candidate_id": candidate["candidate_id"],
                "artifact_identity": copy.deepcopy(candidate["artifact_identity"]),
                "context_identity": copy.deepcopy(candidate["context_identity"]),
            }
        )

    provenance_input = _mapping(payload.get("provenance", {}), "provenance")
    unsupported_provenance = set(provenance_input) - PROVENANCE_ALLOWED_KEYS
    if unsupported_provenance:
        raise AdapterInputError(
            f"provenance has unsupported fields: {sorted(unsupported_provenance)}"
        )
    provenance = {
        "producer_ref": _pointer(
            provenance_input.get(
                "producer_ref",
                _generated_receipt_pointer("adapter", source),
            ),
            "provenance.producer_ref",
        ),
        "created_at": _iso_datetime(
            provenance_input.get("created_at", run_identity["created_at"]),
            "provenance.created_at",
        ),
        "source_ref": source_pointer,
        "content_digest": source["sha256"],
    }

    delivery = _merge_delivery(candidate, payload.get("delivery"), observed_at)
    final_validation = _merge_final_validation(
        candidate, payload.get("final_validation"), observed_at
    )

    record_id = _token(
        payload.get("record_id", f"UK-RE-{source['record_id']}"), "record_id"
    )
    if not re.fullmatch(r"[A-Z][A-Z0-9_.-]+", record_id):
        raise AdapterInputError("record_id must use the KOS record identifier grammar")

    envelope: dict[str, Any] = {
        "contract": CONTRACT,
        "contract_version": copy.deepcopy(CONTRACT_VERSION),
        "record_id": record_id,
        "candidate": candidate,
        "policy": {
            "required_claim_bindings": claim_bindings,
            "max_age_days": MAX_AGE_DAYS,
            "require_baseline_for_first_target": True,
            "require_previous_target_for_subsequent": True,
            "previous_receipt_identity_keys": ["release_lineage"],
        },
        "observations": observations,
        "provenance": provenance,
        "delivery": delivery,
        "final_validation": final_validation,
    }
    if run_identity["lane"] == "external_candidate":
        if "promotion" not in payload:
            raise AdapterInputError(
                "external_candidate records must declare first/subsequent promotion history"
            )
        envelope["promotion"] = _promotion(payload["promotion"], candidate)
    return envelope


def _safe_relative_path(raw_path: Any) -> str:
    if not isinstance(raw_path, str) or not raw_path or not SAFE_PATH_RE.fullmatch(raw_path):
        raise AdapterInputError("changed_surface contains an invalid path")
    path = raw_path.replace("\\", "/")
    parts = path.split("/")
    if path.startswith("/") or not parts or any(
        part in {"", ".", ".."} for part in parts
    ):
        raise AdapterInputError("changed_surface contains an unsafe path")
    return path


def _is_docs_only_path(path: str) -> bool:
    return path in DOCS_ONLY_PATHS


def _is_repository_ci_docs_only_path(path: str) -> bool:
    """Mirror the repository CI classifier's lightweight path allowlist."""

    if path in SEMANTIC_SURFACES:
        return False
    parts = path.split("/")
    if not parts or any(part in {"", ".", ".."} for part in parts):
        return False
    if parts[0] in {"docs", ".kos"}:
        return True
    return len(parts) == 1 and parts[0].lower().endswith(".md")


def _is_release_dependency_path(path: str) -> bool:
    return path in {".kos/project.json", MAIN_APP_SOURCE_OWNER_PATH} or any(
        path.startswith(prefix) for prefix in RELEASE_DEPENDENCY_PATH_PREFIXES
    )


def _area_for_path(path: str) -> set[str]:
    areas: set[str] = set()
    if path.startswith("Universe Keyboard/"):
        areas.add("main_app")
    if path.startswith("Keyboard/"):
        areas.add("keyboard_extension")
    if path.startswith("KeyboardTests/") or path.startswith("KeyboardExtensionTests/"):
        areas.add("keyboard_extension_tests")
    if path.startswith("Packages/KeyboardCore/"):
        areas.add("keyboard_core")
    if path.startswith("Packages/RimeBridge/") or path.startswith("Universe Keyboard/RimeBuiltin/"):
        areas.add("rime_runtime")
    if path.startswith("scripts/") or path.startswith(".github/") or ".xcode" in path:
        areas.add("release_tooling")
    if path.startswith("config/") or path.endswith((".entitlements", ".xcconfig", "Package.swift", "Package.resolved")):
        areas.add("artifact_identity")
    return areas


def _scopes_for_areas(areas: Iterable[str]) -> set[str]:
    scopes = {"changed_path_validation", "affected_path_smoke"}
    area_set = set(areas)
    if area_set & {"keyboard_extension", "keyboard_core", "rime_runtime"}:
        scopes.add("triggered_boundary")
    if area_set & {"release_tooling", "artifact_identity"}:
        scopes.add("baseline_boundary")
    return scopes


def _semantic_surface(surface: str) -> tuple[str, set[str], bool]:
    if surface in {"schema", "contract", "evaluator", "profile", "source_owner", "privacy_allowlist"}:
        return "contract_or_owner_boundary_changed", set(KNOWN_SCOPES), True
    if surface in {"candidate_identity", "artifact_identity", "context_identity", "environment_identity", "comparison_basis"}:
        return "candidate_binding_changed", set(KNOWN_SCOPES), True
    if surface in {"observation_freshness", "freshness"}:
        return "freshness_policy_changed", set(KNOWN_SCOPES), True
    if surface in {"promotion", "release_lineage", "baseline", "previous_receipt"}:
        return "promotion_history_changed", set(KNOWN_SCOPES), True
    if surface in {"delivery", "hosted_ci"}:
        # Delivery facts are a separate P-01 boundary.  They require a fresh
        # owner receipt, but do not invalidate unrelated, still-fresh claims.
        return "delivery_fact_changed", {"external_candidate_readiness"}, False
    if surface in {"final_validation", "publication"}:
        # The same rule applies to D-01/publication facts: stop the current
        # proof boundary while retaining reusable observation evidence.
        return "final_validation_or_publication_changed", {"external_candidate_readiness"}, False
    return "unknown_surface_fails_closed", set(KNOWN_SCOPES), True


def _parse_as_of(value: Any, label: str = "as_of") -> datetime:
    normalized = _iso_datetime(value, label)
    parsed_value = normalized[:-1] + "+00:00" if normalized.endswith("Z") else normalized
    parsed = datetime.fromisoformat(parsed_value)
    return parsed.astimezone(timezone.utc)


def _normalize_delta_evidence(
    evidence: Mapping[str, Any], label: str
) -> dict[str, Any]:
    """Validate one complete, claim-bound entry before any reuse decision."""

    source = _mapping(evidence, label)
    missing = DELTA_EVIDENCE_REQUIRED_KEYS - set(source)
    unknown = set(source) - DELTA_EVIDENCE_ALLOWED_KEYS
    if missing or unknown:
        details = []
        if missing:
            details.append(f"missing={sorted(missing)}")
        if unknown:
            details.append(f"unsupported={sorted(unknown)}")
        raise AdapterInputError(f"{label} is not a complete evidence tuple: {', '.join(details)}")

    evidence_key = _token(source["evidence_key"], f"{label}.evidence_key")
    scope = _token(source["scope"], f"{label}.scope")
    if scope not in KNOWN_SCOPES:
        raise AdapterInputError(f"{label}.scope is not in the Profile registry")
    binding = CLAIM_BINDINGS_BY_SCOPE[scope]
    claim_ref = _token(source["claim_ref"], f"{label}.claim_ref")
    coverage_ref = _token(source["coverage_ref"], f"{label}.coverage_ref")
    if claim_ref != binding["claim_ref"] or coverage_ref != binding["coverage_ref"]:
        raise AdapterInputError(f"{label} claim/coverage binding does not match scope")

    candidate_id = _token(source["candidate_id"], f"{label}.candidate_id")
    artifact_identity = _artifact_identity(
        source["artifact_identity"], f"{label}.artifact_identity"
    )
    context_identity = _context_identity(
        source["context_identity"], f"{label}.context_identity"
    )
    profile_ref = _token(source["profile_ref"], f"{label}.profile_ref")
    source_identity = _token(source["source_identity"], f"{label}.source_identity")
    comparison_basis = _token(
        source["comparison_basis"], f"{label}.comparison_basis"
    )
    observed_at = _parse_as_of(source["observed_at"], f"{label}.observed_at")
    valid_until = None
    if "valid_until" in source:
        valid_until = _parse_as_of(source["valid_until"], f"{label}.valid_until")
        if valid_until < observed_at:
            raise AdapterInputError(f"{label}.valid_until precedes observed_at")
    contract_pin = _token(source["contract_pin"], f"{label}.contract_pin")
    schema_pin = _require_sha(source["schema_pin"], f"{label}.schema_pin")
    evaluator_pin = _require_sha(source["evaluator_pin"], f"{label}.evaluator_pin")
    if contract_pin != CONTRACT:
        raise AdapterInputError(f"{label}.contract_pin does not match the adapter contract")
    if schema_pin != PINNED_PROFILE["schema_digest"]:
        raise AdapterInputError(f"{label}.schema_pin does not match the pinned schema")
    if evaluator_pin != PINNED_PROFILE["evaluator_digest"]:
        raise AdapterInputError(f"{label}.evaluator_pin does not match the pinned evaluator")
    return {
        "evidence_key": evidence_key,
        "scope": scope,
        "claim_ref": claim_ref,
        "coverage_ref": coverage_ref,
        "candidate_id": candidate_id,
        "artifact_identity": artifact_identity,
        "context_identity": context_identity,
        "profile_ref": profile_ref,
        "source_identity": source_identity,
        "comparison_basis": comparison_basis,
        "observed_at": observed_at,
        "valid_until": valid_until,
    }


def _evidence_is_reusable(
    evidence: Mapping[str, Any],
    *,
    expected_candidate: Mapping[str, Any],
    expected_source: str,
    expected_comparison_basis: str,
    as_of: datetime,
) -> bool:
    try:
        normalized = _normalize_delta_evidence(evidence, "evidence")
    except (AdapterInputError, TypeError, ValueError):
        return False
    if normalized["candidate_id"] != expected_candidate["candidate_id"]:
        return False
    if normalized["artifact_identity"] != expected_candidate["artifact_identity"]:
        return False
    if normalized["context_identity"] != expected_candidate["context_identity"]:
        return False
    if normalized["profile_ref"] != PROFILE_ID or normalized["source_identity"] != expected_source:
        return False
    if normalized["comparison_basis"] != expected_comparison_basis:
        return False
    observed_at = normalized["observed_at"]
    if observed_at > as_of or as_of - observed_at > timedelta(days=MAX_AGE_DAYS):
        return False
    valid_until = normalized["valid_until"]
    return valid_until is None or as_of <= valid_until


@dataclass(frozen=True)
class DeltaPlan:
    release_validation_profile: str
    reason: str
    changed_surface: tuple[str, ...]
    affected_scopes: tuple[str, ...]
    reusable_evidence_keys: tuple[str, ...]
    invalidated_evidence_keys: tuple[str, ...]
    ci_change_tier: str
    stop_before_current_proof: bool
    # Preserve the caller's diff binding in the machine plan.  These values are
    # inputs to the classifier, not a claim that the adapter verified Git diff.
    base_sha: str = UNKNOWN
    head_sha: str = UNKNOWN


def plan_delta(payload: Mapping[str, Any]) -> DeltaPlan:
    """Classify changed surfaces and return a fail-closed reuse plan.

    This classifier is intentionally independent of the repository CI
    classifier.  A release-level ``delta`` may reduce evidence work, while any
    non-document source/tooling/unknown path remains CI ``full``.
    """

    base_sha = UNKNOWN
    head_sha = UNKNOWN
    try:
        base_sha = _require_commit(payload.get("base_sha"), "base_sha")
        head_sha = _require_commit(payload.get("head_sha"), "head_sha")
    except AdapterInputError:
        return DeltaPlan(
            "full",
            "base_or_head_unresolved",
            (),
            tuple(sorted(KNOWN_SCOPES)),
            (),
            tuple(sorted(_evidence_keys(payload.get("evidence")))),
            "full",
            True,
        )

    raw_surface = payload.get("changed_surface")
    if not isinstance(raw_surface, list) or not raw_surface:
        return DeltaPlan(
            "full",
            "empty_or_missing_changed_surface",
            (),
            tuple(sorted(KNOWN_SCOPES)),
            (),
            tuple(sorted(_evidence_keys(payload.get("evidence")))),
            "full",
            True,
            base_sha,
            head_sha,
        )

    normalized: list[str] = []
    for item in raw_surface:
        if not isinstance(item, str):
            return DeltaPlan(
                "full",
                "ambiguous_changed_surface",
                (),
                tuple(sorted(KNOWN_SCOPES)),
                (),
                tuple(sorted(_evidence_keys(payload.get("evidence")))),
                "full",
                True,
                base_sha,
                head_sha,
            )
        if item in SEMANTIC_SURFACES:
            normalized.append(item)
            continue
        try:
            normalized.append(_safe_relative_path(item))
        except AdapterInputError:
            return DeltaPlan(
                "full",
                "unsafe_changed_surface",
                (),
                tuple(sorted(KNOWN_SCOPES)),
                (),
                tuple(sorted(_evidence_keys(payload.get("evidence")))),
                "full",
                True,
                base_sha,
                head_sha,
            )
    if len(normalized) != len(set(normalized)):
        return DeltaPlan(
            "full",
            "ambiguous_changed_surface",
            tuple(sorted(normalized)),
            tuple(sorted(KNOWN_SCOPES)),
            (),
            tuple(sorted(_evidence_keys(payload.get("evidence")))),
            "full",
            True,
            base_sha,
            head_sha,
        )
    normalized = sorted(normalized)

    if base_sha == head_sha:
        return DeltaPlan(
            "full",
            "base_equals_head_with_changed_surface",
            tuple(normalized),
            tuple(sorted(KNOWN_SCOPES)),
            (),
            tuple(sorted(_evidence_keys(payload.get("evidence")))),
            "full",
            True,
            base_sha,
            head_sha,
        )

    semantic_reasons: list[str] = []
    affected_scopes: set[str] = set()
    force_full = False
    for surface in normalized:
        if surface in SEMANTIC_SURFACES:
            reason, scopes, semantic_full = _semantic_surface(surface)
            semantic_reasons.append(reason)
            affected_scopes.update(scopes)
            force_full = force_full or semantic_full
            continue
        if _is_release_dependency_path(surface):
            semantic_reasons.append("release_evidence_dependency_changed")
            affected_scopes.update(KNOWN_SCOPES)
            force_full = True
            continue
        if _is_docs_only_path(surface):
            semantic_reasons.append("documentation_delta")
            continue
        top_level = Path(surface).parts[0]
        if top_level not in KNOWN_TOP_LEVELS:
            force_full = True
            semantic_reasons.append("unknown_repository_surface")
            affected_scopes.update(KNOWN_SCOPES)
            continue
        if any(surface.startswith(prefix) for prefix in BASELINE_PREFIXES) or surface.endswith(
            (".entitlements", ".xcconfig", "Package.swift", "Package.resolved")
        ):
            force_full = True
            semantic_reasons.append("artifact_or_toolchain_boundary_changed")
            affected_scopes.update(KNOWN_SCOPES)
        elif any(surface.startswith(prefix) for prefix in TRIGGERED_PREFIXES):
            semantic_reasons.append("runtime_or_keyboard_boundary_changed")
            affected_scopes.update(_scopes_for_areas(_area_for_path(surface)))
        else:
            semantic_reasons.append("ordinary_delta")
            affected_scopes.update(_scopes_for_areas(_area_for_path(surface)))

    # Keep this field aligned with scripts/ci/classify_changes.py.  Release
    # dependencies such as docs/kos still force a full release-validation
    # profile above, but repository CI classifies them as docs_only.
    ci_docs_only = all(
        _is_repository_ci_docs_only_path(surface) for surface in normalized
    )
    ci_tier = "docs_only" if ci_docs_only else "full"
    if force_full:
        profile = "full"
    elif any("runtime_or_keyboard" in reason for reason in semantic_reasons):
        profile = "triggered"
    elif all(
        reason in {"ordinary_delta", "documentation_delta"}
        for reason in semantic_reasons
    ):
        profile = "delta"
    else:
        profile = "triggered"

    # First external candidate must create a baseline even if its source diff
    # is documentation-only; this is a release fact, not a CI classification.
    if payload.get("first_external_candidate") is True:
        profile = "baseline"
        force_full = True
        semantic_reasons.append("first_external_candidate_requires_baseline")
        affected_scopes.update(KNOWN_SCOPES)

    if force_full:
        affected_scopes.update(KNOWN_SCOPES)

    as_of_raw = payload.get("as_of")
    try:
        as_of = _parse_as_of(as_of_raw)
    except (AdapterInputError, TypeError, ValueError):
        return DeltaPlan(
            "full",
            "as_of_unresolved",
            tuple(normalized),
            tuple(sorted(KNOWN_SCOPES)),
            (),
            tuple(sorted(_evidence_keys(payload.get("evidence")))),
            "full",
            True,
            base_sha,
            head_sha,
        )

    # The project fixture uses a compact direct-candidate shape.  Accepting an
    # explicit ``candidate`` object as well keeps the boundary clear for a
    # future caller without changing the reuse tuple or its fail-closed rules.
    candidate = _mapping(payload.get("candidate", payload), "delta.candidate")
    try:
        expected_candidate = {
            "candidate_id": _token(
                candidate.get("candidate_id"), "delta.candidate.candidate_id"
            ),
            "artifact_identity": _artifact_identity(
                candidate.get("artifact_identity"), "delta.candidate.artifact_identity"
            ),
            "context_identity": _context_identity(
                candidate.get("context_identity"), "delta.candidate.context_identity"
            ),
        }
        expected_profile = _token(
            candidate.get("profile_ref"), "delta.candidate.profile_ref"
        )
        expected_source = _token(
            payload.get("source_identity"), "delta.source_identity"
        )
        expected_basis = _token(
            candidate.get("comparison_basis"), "delta.candidate.comparison_basis"
        )
        dependencies_resolved = (
            expected_profile == PROFILE_ID and expected_source == MAIN_APP_SOURCE_ID
        )
    except (AdapterInputError, TypeError, ValueError):
        dependencies_resolved = False
        expected_candidate = {}
        expected_source = ""
        expected_basis = ""

    evidence_entries = payload.get("evidence")
    entries = evidence_entries if isinstance(evidence_entries, list) else []
    reusable: list[str] = []
    invalidated: list[str] = []
    if not entries:
        return DeltaPlan(
            "full",
            "evidence_missing_or_empty",
            tuple(normalized),
            tuple(sorted(KNOWN_SCOPES)),
            (),
            tuple(sorted(_evidence_keys(entries))),
            "full",
            True,
            base_sha,
            head_sha,
        )
    if not dependencies_resolved:
        invalidated = sorted(_evidence_keys(entries))
        profile = "full"
        affected_scopes.update(KNOWN_SCOPES)
    else:
        try:
            normalized_entries = [
                _normalize_delta_evidence(raw_entry, f"evidence[{index}]")
                for index, raw_entry in enumerate(entries)
            ]
        except (AdapterInputError, TypeError, ValueError):
            return DeltaPlan(
                "full",
                "evidence_binding_unresolved",
                tuple(normalized),
                tuple(sorted(KNOWN_SCOPES)),
                (),
                tuple(sorted(_evidence_keys(entries))),
                "full",
                True,
                base_sha,
                head_sha,
            )
        evidence_keys = [entry["evidence_key"] for entry in normalized_entries]
        if len(set(evidence_keys)) != len(evidence_keys):
            return DeltaPlan(
                "full",
                "duplicate_evidence_key",
                tuple(normalized),
                tuple(sorted(KNOWN_SCOPES)),
                (),
                tuple(sorted(set(evidence_keys))),
                "full",
                True,
                base_sha,
                head_sha,
            )
        for raw_entry, normalized_entry in zip(entries, normalized_entries):
            key = normalized_entry["evidence_key"]
            claim_scope = raw_entry.get("scope")
            if claim_scope in affected_scopes or force_full:
                invalidated.append(key)
                continue
            if _evidence_is_reusable(
                raw_entry,
                expected_candidate=expected_candidate,
                expected_source=expected_source,
                expected_comparison_basis=expected_basis,
                as_of=as_of,
            ):
                reusable.append(key)
            else:
                invalidated.append(key)

    proof_boundary_changed = bool(
        affected_scopes
        & {
            "external_candidate_readiness",
            "baseline_boundary",
            "triggered_boundary",
        }
    )
    return DeltaPlan(
        profile,
        "+".join(sorted(set(semantic_reasons))) or "ordinary_delta",
        tuple(normalized),
        tuple(sorted(affected_scopes)),
        tuple(sorted(set(reusable))),
        tuple(sorted(set(invalidated))),
        ci_tier,
        True if force_full or invalidated or not reusable or proof_boundary_changed else False,
        base_sha,
        head_sha,
    )


def _evidence_keys(value: Any) -> set[str]:
    if not isinstance(value, list):
        return set()
    return {
        item["evidence_key"]
        for item in value
        if isinstance(item, Mapping) and isinstance(item.get("evidence_key"), str)
    }


def read_json(path: Path) -> dict[str, Any]:
    try:
        raw = path.read_bytes()
    except OSError as error:
        raise AdapterInputError(f"unable to read {path}: {error}") from error
    if len(raw) > 2 * 1024 * 1024:
        raise AdapterInputError("adapter input exceeds 2 MiB")
    try:
        value = json.loads(
            raw.decode("utf-8"),
            object_pairs_hook=_reject_duplicate_keys,
        )
    except (UnicodeError, json.JSONDecodeError, ValueError) as error:
        raise AdapterInputError(f"invalid JSON: {error}") from error
    if not isinstance(value, dict):
        raise AdapterInputError("adapter input must be an object")
    return value


def _reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    envelope_parser = subparsers.add_parser(
        "envelope", help="map a Main-App export input to a KOS Envelope"
    )
    envelope_parser.add_argument("--input", type=Path, required=True)
    envelope_parser.add_argument("--output", type=Path)

    delta_parser = subparsers.add_parser(
        "delta", help="plan delta-aware evidence reuse and independent CI tier"
    )
    delta_parser.add_argument("--input", type=Path, required=True)
    delta_parser.add_argument("--output", type=Path)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        payload = read_json(args.input)
        if args.command == "envelope":
            output = build_envelope(payload)
        else:
            output = asdict(plan_delta(payload))
        if args.output:
            write_json(args.output, output)
        print(json.dumps(output, ensure_ascii=False, indent=2, sort_keys=True))
        return 0
    except (AdapterInputError, OSError, TypeError, ValueError) as error:
        print(f"FAIL closed: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
