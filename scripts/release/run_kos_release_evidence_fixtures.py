#!/usr/bin/env python3
"""Run the bounded KOS release-evidence fixture matrix.

The runner creates temporary Envelope inputs from content-free fixtures and
invokes the pinned standalone evaluator with an explicit ``--as-of`` value.
It also invokes the project delta adapter for each reuse/invalidation case.
The output is a review receipt input; it is not a Product, Quality, Gate or
Release decision.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import importlib.util
import json
import re
import shlex
import subprocess
import sys
from pathlib import Path
from typing import Any, Mapping


SCRIPT_DIR = Path(__file__).resolve().parent
FIXTURE_DEFAULT = SCRIPT_DIR / "fixtures" / "kos_release_evidence_cases.json"
ADAPTER_PATH = SCRIPT_DIR / "kos_release_evidence_adapter.py"
ADAPTER_MODULE_SPEC = importlib.util.spec_from_file_location(
    "kos_release_evidence_adapter", ADAPTER_PATH
)
if ADAPTER_MODULE_SPEC is None or ADAPTER_MODULE_SPEC.loader is None:
    raise RuntimeError(f"unable to load adapter module: {ADAPTER_PATH}")
ADAPTER = importlib.util.module_from_spec(ADAPTER_MODULE_SPEC)
sys.modules[ADAPTER_MODULE_SPEC.name] = ADAPTER
ADAPTER_MODULE_SPEC.loader.exec_module(ADAPTER)


PATH_TOKEN_RE = re.compile(r"([A-Za-z0-9_-]+)|\[(\d+|\*)\]")
CAPTURE_LIMIT = 12000
EXPECTED_ENVELOPE_FIXTURE_IDS = tuple(
    f"UK-RE-FX-{index:03d}" for index in range(1, 53)
)
EXPECTED_DELTA_FIXTURE_IDS = tuple(
    f"UK-RE-DELTA-{index:03d}" for index in range(1, 25)
)


def _parse_path(raw_path: str) -> list[str | int]:
    if not isinstance(raw_path, str) or not raw_path:
        raise ValueError("mutation path must be a non-empty string")
    tokens: list[str | int] = []
    cursor = 0
    for match in PATH_TOKEN_RE.finditer(raw_path):
        if match.start() != cursor and not (
            cursor == 0 and match.start() == 0
        ):
            raise ValueError(f"unsupported mutation path: {raw_path}")
        cursor = match.end()
        if match.group(1) is not None:
            tokens.append(match.group(1))
        else:
            index = match.group(2)
            tokens.append("*" if index == "*" else int(index))
        if cursor < len(raw_path) and raw_path[cursor] == ".":
            cursor += 1
    if cursor != len(raw_path) or not tokens:
        raise ValueError(f"unsupported mutation path: {raw_path}")
    return tokens


def _set_path(current: Any, tokens: list[str | int], value: Any) -> None:
    token = tokens[0]
    if len(tokens) == 1:
        if token == "*":
            if not isinstance(current, list):
                raise ValueError("wildcard mutation requires a list")
            for index in range(len(current)):
                current[index] = copy.deepcopy(value)
            return
        if isinstance(token, int):
            if not isinstance(current, list) or token >= len(current):
                raise ValueError("mutation list index is out of range")
            current[token] = copy.deepcopy(value)
            return
        if not isinstance(current, dict):
            raise ValueError("mutation parent is not an object")
        current[token] = copy.deepcopy(value)
        return

    if token == "*":
        if not isinstance(current, list):
            raise ValueError("wildcard mutation requires a list")
        for child in current:
            _set_path(child, tokens[1:], value)
        return
    if isinstance(token, int):
        if not isinstance(current, list) or token >= len(current):
            raise ValueError("mutation list index is out of range")
        _set_path(current[token], tokens[1:], value)
        return
    if not isinstance(current, dict) or token not in current:
        raise ValueError(f"mutation path is missing: {token}")
    _set_path(current[token], tokens[1:], value)


def _delete_path(current: Any, tokens: list[str | int]) -> None:
    token = tokens[0]
    if len(tokens) == 1:
        if isinstance(token, int):
            if not isinstance(current, list) or token >= len(current):
                raise ValueError("delete list index is out of range")
            current.pop(token)
            return
        if token == "*":
            raise ValueError("delete wildcard is not supported")
        if not isinstance(current, dict) or token not in current:
            raise ValueError(f"delete path is missing: {token}")
        del current[token]
        return

    if token == "*":
        if not isinstance(current, list):
            raise ValueError("wildcard deletion requires a list")
        for child in current:
            _delete_path(child, tokens[1:])
        return
    if isinstance(token, int):
        if not isinstance(current, list) or token >= len(current):
            raise ValueError("delete list index is out of range")
        _delete_path(current[token], tokens[1:])
        return
    if not isinstance(current, dict) or token not in current:
        raise ValueError(f"delete path is missing: {token}")
    _delete_path(current[token], tokens[1:])


def apply_envelope_mutations(envelope: dict[str, Any], mutations: Any) -> None:
    if mutations is None:
        return
    if not isinstance(mutations, list):
        raise ValueError("envelope_mutations must be an array")
    for mutation in mutations:
        if not isinstance(mutation, Mapping):
            raise ValueError("each envelope mutation must be an object")
        operation = mutation.get("op")
        path = _parse_path(mutation.get("path"))
        if operation in {"set", "set_each"}:
            if operation == "set_each" and "*" not in path:
                raise ValueError("set_each requires a wildcard path")
            if "value" not in mutation:
                raise ValueError("set mutation requires value")
            _set_path(envelope, path, mutation["value"])
        elif operation == "delete":
            _delete_path(envelope, path)
        else:
            raise ValueError(f"unsupported envelope mutation: {operation}")


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _raw_concat_sha256(root: Path, relative_paths: tuple[str, ...]) -> str:
    digest = hashlib.sha256()
    for relative_path in relative_paths:
        path = root / relative_path
        if path.is_symlink() or not path.is_file():
            raise RuntimeError(f"candidate manifest entry is not a regular file: {path}")
        digest.update(path.read_bytes())
    return digest.hexdigest()


def _git_output(root: Path, *arguments: str) -> str:
    completed = subprocess.run(
        ["git", "-C", str(root), *arguments],
        capture_output=True,
        text=True,
        check=False,
    )
    if completed.returncode != 0:
        detail = completed.stderr.strip() or completed.stdout.strip()
        raise RuntimeError(f"git {' '.join(arguments)} failed: {detail}")
    return completed.stdout.strip()


def _verify_git_commit(root: Path, commit: str, label: str) -> None:
    completed = subprocess.run(
        ["git", "-C", str(root), "cat-file", "-e", f"{commit}^{{commit}}"],
        capture_output=True,
        text=True,
        check=False,
    )
    if completed.returncode != 0:
        raise RuntimeError(f"{label} is not available as a commit: {commit}")


def _bounded_output(value: str) -> str:
    if len(value) <= CAPTURE_LIMIT:
        return value
    return value[:CAPTURE_LIMIT] + "\n[output truncated]"


def _fixture_baseline(payload: Mapping[str, Any]) -> dict[str, Any]:
    """Return an explicit test receipt; the adapter never synthesizes one."""

    candidate = payload["candidate"]
    run = payload["main_app_export"]["run"]
    return {
        "verification_ref": (
            "opaque://universe-keyboard/daily-beta-baseline-build-56;"
            f"sha256={'9' * 64};class=review-record"
        ),
        "reason": "first_external_candidate_requires_baseline",
        "candidate_id": run["candidateID"],
        "artifact_identity": copy.deepcopy(candidate["artifact_identity"]),
        "context_identity": copy.deepcopy(candidate["context_identity"]),
        "source_stage": "daily_beta",
        "target_stage": "external_candidate",
        "profile_ref": ADAPTER.PROFILE_ID,
        "contract_version": copy.deepcopy(ADAPTER.CONTRACT_VERSION),
    }


def _external_input(base: Mapping[str, Any], sequence: str) -> dict[str, Any]:
    payload = copy.deepcopy(base)
    source = payload["main_app_source"]
    if sequence == "first":
        record_suffix = "FIRST"
        operation_suffix = "057"
    else:
        record_suffix = "SUBSEQUENT"
        operation_suffix = "058"
    source_digest = "a" * 63 + "b"
    source.update(
        {
            "record_id": f"RUN-EXTERNAL-{record_suffix}-56",
            "operation_id": f"30000000-0000-4000-8000-000000000{operation_suffix}",
            "sha256": source_digest,
        }
    )
    payload["record_id"] = f"UK-RE-EXTERNAL-{record_suffix}-56"

    run = payload["main_app_export"]["run"]
    run.update(
        {
            "id": f"40000000-0000-4000-8000-000000000{operation_suffix}",
            "createdAt": "2026-09-14T10:10:00+08:00",
            "updatedAt": "2026-09-14T10:10:00+08:00",
            "lane": "external_candidate",
            "profile": "baseline",
            "promotionMode": "pending_artifact_match",
            "steps": [
                {"scope": "candidate_identity", "outcome": "pass"},
                {"scope": "changed_path_validation", "outcome": "pass"},
                {"scope": "affected_path_smoke", "outcome": "pass"},
                {"scope": "evidence_reuse", "outcome": "pass"},
                {"scope": "external_candidate_readiness", "outcome": "pass"},
                {"scope": "baseline_boundary", "outcome": "pass"},
            ],
        }
    )
    # The Main-App's pending artifact match is a partial source outcome.  The
    # adapter must preserve this canonical wrapper fact even though the KOS
    # observations below can still be structurally complete.
    payload["main_app_export"]["outcome"] = "partial"

    baseline_context = {
        "behavior_contract": run["behaviorContract"],
        "device_model": run["deviceModel"],
        "os_version": run["osVersion"],
        "validation_profile": "baseline",
    }
    payload["candidate"]["context_identity"] = copy.deepcopy(baseline_context)
    payload["delivery"]["context_identity"] = copy.deepcopy(baseline_context)
    payload["final_validation"]["context_identity"] = copy.deepcopy(baseline_context)
    payload["evidence"].update(
        {
            "observed_at": "2026-09-14T10:10:00+08:00",
            "valid_until": "2026-10-14T10:10:00+08:00",
        }
    )
    payload["delivery"]["observed_at"] = "2026-09-14T10:15:00+08:00"
    payload["final_validation"]["observed_at"] = "2026-09-14T10:16:00+08:00"
    payload["provenance"] = {
        "producer_ref": (
            "opaque://universe-keyboard/external-app-export;"
            f"sha256={source_digest};class=review-record"
        ),
        "created_at": "2026-09-14T10:10:00+08:00",
    }

    previous_artifact = copy.deepcopy(payload["candidate"]["artifact_identity"])
    previous_artifact.update(
        {
            "source_commit": "2" * 40,
            "build": "55",
            "archive_sha256": "6" * 64,
            "package_sha256": "7" * 64,
        }
    )
    previous_receipt = {
        "receipt_ref": (
            "opaque://universe-keyboard/previous-target-build-55;"
            f"sha256={'6' * 64};class=review-record"
        ),
        "candidate_id": "Build-55",
        "artifact_identity": previous_artifact,
        "context_identity": copy.deepcopy(baseline_context),
        "source_stage": "daily_beta",
        "target_stage": "external_candidate",
        "profile_ref": ADAPTER.PROFILE_ID,
        "contract_version": copy.deepcopy(ADAPTER.CONTRACT_VERSION),
    }
    payload["promotion"] = {
        "target_sequence": sequence,
        "target_binding": True,
        "baseline": _fixture_baseline(payload) if sequence == "first" else None,
        "previous_target_receipt": True if sequence == "subsequent" else None,
        "previous_target": previous_receipt,
    }
    return payload


def _prepare_case(fixture: Mapping[str, Any], case: Mapping[str, Any]) -> dict[str, Any]:
    variant = case.get("variant", "daily")
    if variant == "daily":
        payload = copy.deepcopy(fixture["base_input"])
    elif variant == "external_first":
        payload = _external_input(fixture["base_input"], "first")
    elif variant == "external_subsequent":
        payload = _external_input(fixture["base_input"], "subsequent")
    else:
        raise ValueError(f"unsupported fixture variant: {variant}")

    if case.get("input_mode") == "direct_run":
        payload["main_app_export"] = copy.deepcopy(payload["main_app_export"]["run"])

    if variant.startswith("external_"):
        promotion = case.get("promotion", {})
        if not isinstance(promotion, Mapping):
            raise ValueError("case promotion must be an object")
        for key in ("target_binding", "baseline", "previous_target_receipt"):
            if key in promotion:
                value = promotion[key]
                if key == "baseline" and value == "fixture_verified":
                    payload["promotion"][key] = _fixture_baseline(payload)
                else:
                    payload["promotion"][key] = copy.deepcopy(value)
    return payload


def _run_command(command: list[str]) -> tuple[int, str, str]:
    completed = subprocess.run(
        command,
        capture_output=True,
        text=True,
        check=False,
    )
    return (
        completed.returncode,
        _bounded_output(completed.stdout),
        _bounded_output(completed.stderr),
    )


def _run_envelope_case(
    fixture: Mapping[str, Any],
    case: Mapping[str, Any],
    evaluator_path: Path,
    work_dir: Path,
) -> dict[str, Any]:
    fixture_id = case["fixture_id"]
    envelope_path = work_dir / "envelopes" / f"{fixture_id}.json"
    envelope_path.parent.mkdir(parents=True, exist_ok=True)
    adapter_input_path = work_dir / "adapter-inputs" / f"{fixture_id}.json"
    adapter_command: list[str] | None = None
    evaluator_command: list[str] | None = None
    adapter_exit_code: int | None = None
    adapter_stdout = ""
    adapter_stderr = ""
    adapter_error: str | None = None

    as_of = case.get("as_of", fixture["as_of"])
    evaluator_command = [
        "python3",
        str(evaluator_path),
        str(envelope_path),
        "--as-of",
        as_of,
    ]
    use_adapter_cli = "adapter_input_mutations" in case or "input_mode" in case
    if use_adapter_cli:
        try:
            input_payload = _prepare_case(fixture, case)
            apply_envelope_mutations(
                input_payload, case.get("adapter_input_mutations")
            )
            ADAPTER.write_json(adapter_input_path, input_payload)
            adapter_command = [
                "python3",
                str(ADAPTER_PATH),
                "envelope",
                "--input",
                str(adapter_input_path),
                "--output",
                str(envelope_path),
            ]
            adapter_exit_code, adapter_stdout, adapter_stderr = _run_command(
                adapter_command
            )
        except (ADAPTER.AdapterInputError, OSError, TypeError, ValueError) as error:
            adapter_error = str(error)
            adapter_exit_code = -1
            adapter_stderr = f"adapter failed: {adapter_error}"
        if adapter_error is None and adapter_exit_code == 0:
            actual_exit_code, stdout, stderr = _run_command(evaluator_command)
        else:
            actual_exit_code, stdout, stderr = (
                adapter_exit_code if adapter_exit_code is not None else -1,
                adapter_stdout,
                adapter_stderr,
            )
    else:
        try:
            if "raw_content" in case:
                raw_content = case["raw_content"]
                if not isinstance(raw_content, str):
                    raise ValueError("raw_content must be a string")
                envelope_path.write_text(raw_content, encoding="utf-8")
            else:
                input_payload = _prepare_case(fixture, case)
                envelope = ADAPTER.build_envelope(input_payload)
                apply_envelope_mutations(envelope, case.get("envelope_mutations"))
                ADAPTER.write_json(envelope_path, envelope)
        except (ADAPTER.AdapterInputError, OSError, TypeError, ValueError) as error:
            adapter_error = str(error)
        if adapter_error is None:
            actual_exit_code, stdout, stderr = _run_command(evaluator_command)
        else:
            actual_exit_code, stdout, stderr = -1, "", f"adapter failed: {adapter_error}"

    actual_status: str | None = None
    parsed_output: dict[str, Any] | None = None
    if actual_exit_code == 0:
        try:
            parsed = json.loads(stdout)
            if isinstance(parsed, dict):
                parsed_output = parsed
                actual_status = parsed.get("derived_status")
        except (json.JSONDecodeError, TypeError):
            stderr = f"{stderr}\ninvalid evaluator JSON output".strip()

    expected_exit_code = case.get("expected_exit_code")
    expected_adapter_exit_code = case.get("expected_adapter_exit_code")
    expected_status = case.get("expected_derived_status")
    if expected_adapter_exit_code is not None:
        passed = (
            adapter_error is None
            and adapter_exit_code == expected_adapter_exit_code
            and actual_status is None
        )
    else:
        passed = (
            adapter_error is None
            and actual_exit_code == expected_exit_code
            and actual_status == expected_status
            and (expected_status is None or parsed_output is not None)
        )
    return {
        "fixture_id": fixture_id,
        "name": case["name"],
        "variant": case.get("variant", "daily"),
        "as_of": as_of,
        "command": shlex.join(adapter_command or evaluator_command or []),
        "adapter_command": shlex.join(adapter_command) if adapter_command else None,
        "evaluator_command": shlex.join(evaluator_command),
        "adapter_input_path": str(adapter_input_path) if use_adapter_cli else None,
        "envelope_path": str(envelope_path),
        "envelope_sha256": _sha256(envelope_path) if envelope_path.exists() else None,
        "expected_exit_code": expected_exit_code,
        "expected_adapter_exit_code": expected_adapter_exit_code,
        "actual_exit_code": actual_exit_code,
        "adapter_exit_code": adapter_exit_code,
        "expected_derived_status": expected_status,
        "actual_derived_status": actual_status,
        "stdout": stdout,
        "stderr": stderr,
        "adapter_stdout": adapter_stdout,
        "adapter_stderr": adapter_stderr,
        "non_claim": case["non_claim"],
        "passed": passed,
    }


def _run_delta_case(
    fixture: Mapping[str, Any],
    case: Mapping[str, Any],
    work_dir: Path,
) -> dict[str, Any]:
    fixture_id = case["fixture_id"]
    payload = copy.deepcopy(fixture["delta_candidate"])
    payload["changed_surface"] = copy.deepcopy(case["changed_surface"])
    for key in ("base_sha", "head_sha", "as_of", "source_identity"):
        if key in case:
            payload[key] = copy.deepcopy(case[key])
    if "evidence_overrides" in case:
        overrides = case["evidence_overrides"]
        if not isinstance(overrides, Mapping):
            raise ValueError("evidence_overrides must be an object")
        for evidence in payload["evidence"]:
            evidence.update(copy.deepcopy(overrides))

    input_path = work_dir / "delta" / f"{fixture_id}-input.json"
    input_path.parent.mkdir(parents=True, exist_ok=True)
    ADAPTER.write_json(input_path, payload)
    command = ["python3", str(ADAPTER_PATH), "delta", "--input", str(input_path)]
    actual_exit_code, stdout, stderr = _run_command(command)
    actual_plan: dict[str, Any] | None = None
    if actual_exit_code == 0:
        try:
            parsed = json.loads(stdout)
            if isinstance(parsed, dict):
                actual_plan = parsed
        except (json.JSONDecodeError, TypeError):
            stderr = f"{stderr}\ninvalid adapter JSON output".strip()

    actual_reusable = sorted((actual_plan or {}).get("reusable_evidence_keys", []))
    actual_invalidated = sorted((actual_plan or {}).get("invalidated_evidence_keys", []))
    passed = (
        actual_exit_code == 0
        and actual_plan is not None
        and actual_plan.get("release_validation_profile") == case["expected_profile"]
        and actual_plan.get("ci_change_tier") == case["expected_ci_change_tier"]
        and actual_reusable == sorted(case["expected_reusable_evidence_keys"])
        and actual_invalidated == sorted(case["expected_invalidated_evidence_keys"])
        and actual_plan.get("stop_before_current_proof")
        == case["expected_stop_before_current_proof"]
    )
    return {
        "fixture_id": fixture_id,
        "name": case["name"],
        "as_of": payload["as_of"],
        "command": shlex.join(command),
        "input_path": str(input_path),
        "input_sha256": _sha256(input_path),
        "expected": {
            "release_validation_profile": case["expected_profile"],
            "ci_change_tier": case["expected_ci_change_tier"],
            "reusable_evidence_keys": sorted(case["expected_reusable_evidence_keys"]),
            "invalidated_evidence_keys": sorted(case["expected_invalidated_evidence_keys"]),
            "stop_before_current_proof": case["expected_stop_before_current_proof"],
        },
        "actual": actual_plan,
        "actual_exit_code": actual_exit_code,
        "stdout": stdout,
        "stderr": stderr,
        "non_claim": case["non_claim"],
        "passed": passed,
    }


def _verify_pins(kos_kit_root: Path) -> dict[str, Any]:
    expected_implementation_commit = ADAPTER.PINNED_PROFILE["implementation_commit"]
    expected_adoption_commit = ADAPTER.PINNED_PROFILE["adoption_metadata_commit"]
    expected_tree_digest = ADAPTER.PINNED_PROFILE["candidate_tree_digest"]
    expected_manifest = tuple(ADAPTER.PINNED_PROFILE["candidate_manifest"])

    _verify_git_commit(kos_kit_root, expected_implementation_commit, "implementation pin")
    _verify_git_commit(kos_kit_root, expected_adoption_commit, "adoption metadata pin")
    actual_head = _git_output(kos_kit_root, "rev-parse", "HEAD")
    if actual_head != expected_adoption_commit:
        raise RuntimeError(
            "candidate HEAD does not match the adoption metadata pin: "
            f"expected={expected_adoption_commit} actual={actual_head}"
        )
    ancestry = subprocess.run(
        [
            "git",
            "-C",
            str(kos_kit_root),
            "merge-base",
            "--is-ancestor",
            expected_implementation_commit,
            expected_adoption_commit,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if ancestry.returncode != 0:
        raise RuntimeError(
            "implementation pin is not an ancestor of the adoption metadata pin: "
            f"implementation={expected_implementation_commit} adoption={expected_adoption_commit}"
        )
    working_tree = _git_output(kos_kit_root, "status", "--porcelain")
    if working_tree:
        raise RuntimeError("pinned KOS kit worktree is not clean")

    actual_tree_digest = _raw_concat_sha256(kos_kit_root, expected_manifest)
    if actual_tree_digest != expected_tree_digest:
        raise RuntimeError(
            "candidate tree digest mismatch: "
            f"expected={expected_tree_digest} actual={actual_tree_digest}"
        )

    paths = {
        "contract_source": kos_kit_root / "ops" / "release-evidence.md",
        "schema": kos_kit_root / "schemas" / "release-evidence-v1.schema.json",
        "evaluator": kos_kit_root / "scripts" / "validate_release_evidence.py",
    }
    actual = {name: _sha256(path) for name, path in paths.items()}
    expected = {
        "contract_source": ADAPTER.PINNED_PROFILE["contract_source_digest"],
        "schema": ADAPTER.PINNED_PROFILE["schema_digest"],
        "evaluator": ADAPTER.PINNED_PROFILE["evaluator_digest"],
    }
    if actual != expected:
        raise RuntimeError(f"pinned KOS source digest mismatch: expected={expected} actual={actual}")
    return {
        "kit_root": str(kos_kit_root),
        "implementation_commit": expected_implementation_commit,
        "adoption_metadata_commit": expected_adoption_commit,
        "actual_head": actual_head,
        "candidate_manifest": list(expected_manifest),
        "candidate_tree_digest": {
            "expected": expected_tree_digest,
            "actual": actual_tree_digest,
        },
        "working_tree": "clean",
        "paths": {name: str(path) for name, path in paths.items()},
        "expected_sha256": expected,
        "actual_sha256": actual,
    }


def run_fixture_matrix(
    fixture_path: Path,
    kos_kit_root: Path,
    work_dir: Path,
) -> dict[str, Any]:
    fixture = ADAPTER.read_json(fixture_path)
    pin_report = _verify_pins(kos_kit_root)
    evaluator_path = kos_kit_root / "scripts" / "validate_release_evidence.py"
    envelope_fixture_ids = tuple(case["fixture_id"] for case in fixture["cases"])
    delta_fixture_ids = tuple(
        case["fixture_id"] for case in fixture.get("delta_cases", [])
    )
    if envelope_fixture_ids != EXPECTED_ENVELOPE_FIXTURE_IDS:
        raise RuntimeError(
            "fixed envelope fixture inventory mismatch: "
            f"expected={EXPECTED_ENVELOPE_FIXTURE_IDS} actual={envelope_fixture_ids}"
        )
    if delta_fixture_ids != EXPECTED_DELTA_FIXTURE_IDS:
        raise RuntimeError(
            "fixed delta fixture inventory mismatch: "
            f"expected={EXPECTED_DELTA_FIXTURE_IDS} actual={delta_fixture_ids}"
        )
    envelope_results = [
        _run_envelope_case(fixture, case, evaluator_path, work_dir)
        for case in fixture["cases"]
    ]
    delta_results = [
        _run_delta_case(fixture, case, work_dir)
        for case in fixture.get("delta_cases", [])
    ]
    passed = sum(1 for result in envelope_results + delta_results if result["passed"])
    total = len(envelope_results) + len(delta_results)
    return {
        "fixture_path": str(fixture_path),
        "work_dir": str(work_dir),
        "pinned_sources": pin_report,
        "adapter_path": str(ADAPTER_PATH),
        "adapter_sha256": _sha256(ADAPTER_PATH),
        "fixed_inventory": {
            "envelope_fixture_ids": list(EXPECTED_ENVELOPE_FIXTURE_IDS),
            "delta_fixture_ids": list(EXPECTED_DELTA_FIXTURE_IDS),
        },
        "envelope_cases": envelope_results,
        "envelope_summary": {
            "total": len(envelope_results),
            "passed": sum(1 for result in envelope_results if result["passed"]),
            "failed": sum(1 for result in envelope_results if not result["passed"]),
        },
        "delta_cases": delta_results,
        "delta_summary": {
            "total": len(delta_results),
            "passed": sum(1 for result in delta_results if result["passed"]),
            "failed": sum(1 for result in delta_results if not result["passed"]),
        },
        "summary": {
            "total": total,
            "passed": passed,
            "failed": total - passed,
        },
        "non_claim": (
            "fixture/evaluator classifications are contract evidence only; "
            "they do not authorize upload, Beta Review, Product Gate, Release or publication"
        ),
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fixture", type=Path, default=FIXTURE_DEFAULT)
    parser.add_argument(
        "--kos-kit-root",
        type=Path,
        required=True,
        help="root of the exact pinned kos-agent-kit checkout",
    )
    parser.add_argument(
        "--work-dir",
        type=Path,
        default=Path("/private/tmp/kos-release-evidence-fixtures"),
    )
    parser.add_argument("--output", type=Path)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        args.work_dir.mkdir(parents=True, exist_ok=True)
        report = run_fixture_matrix(
            args.fixture.resolve(), args.kos_kit_root.resolve(), args.work_dir.resolve()
        )
        if args.output:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(
                json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
                encoding="utf-8",
            )
        print(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True))
        return 0 if report["summary"]["failed"] == 0 else 1
    except (ADAPTER.AdapterInputError, OSError, TypeError, ValueError, RuntimeError) as error:
        print(f"FAIL closed: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
