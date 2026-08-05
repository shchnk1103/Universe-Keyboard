#!/usr/bin/env python3
"""Fail-closed local evidence tooling for CANARY-001 QEF-01 v9.

Raw build and test artifacts remain in the ignored local quarantine. Only
tool-generated, content-free JSON summaries may be referenced by repository
evidence documents.
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any, Iterable


TOOL_SCHEMA = "CANARY-001-QEF-TOOL-v9"
GATE_MANIFEST = Path("docs/evidence/t9-responsive-pipeline-canary-001-build-test-command-manifest-v9-2026-08-04.txt")
GATE_BINDING = Path("docs/evidence/t9-responsive-pipeline-canary-001-run-header-binding-v9-2026-08-04.json")
GATE_APPROVAL = Path("docs/evidence/t9-responsive-pipeline-canary-001-pre-run-approval-v9-2026-08-04.json")
GATE_EXPECTED = Path("docs/evidence/t9-responsive-pipeline-canary-001-expected-artifacts-v9-2026-08-04.json")
SENSITIVE_KEYS = {
    "rawinput",
    "rawtext",
    "pinyin",
    "preedit",
    "candidate",
    "candidatetext",
    "committedtext",
    "hosttext",
    "surroundingtext",
    "clipboardtext",
    "markedtext",
    "documentcontext",
}
ENVIRONMENT_SKIP_PATTERNS = (
    "set uk_rime",
    "set isolated t9 spike",
    "directories do not exist",
    "runtime directories",
    "runtime lacks",
    "fixture is incomplete",
    "lua files",
    "schema file",
)
PROVENANCE_SKIP_PATTERNS = ("immutable 40-character lowercase s4 commit",)


class EvidenceError(RuntimeError):
    pass


def now() -> str:
    return dt.datetime.now().astimezone().isoformat(timespec="seconds")


def atomic_write(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        dir=path.parent, prefix=f".{path.name}.", delete=False
    ) as temporary:
        temporary.write(data)
        temporary.flush()
        os.fsync(temporary.fileno())
        temporary_path = Path(temporary.name)
    os.replace(temporary_path, path)


def write_json(path: Path, value: Any) -> None:
    atomic_write(
        path,
        (json.dumps(value, ensure_ascii=True, sort_keys=True, indent=2) + "\n").encode(),
    )


def read_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as error:
        raise EvidenceError(f"invalid JSON {path}: {error}") from error


def sha256_file(path: Path) -> str:
    if not path.is_file():
        raise EvidenceError(f"not a regular file: {path}")
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def directory_digest(path: Path) -> tuple[str, int, int]:
    if not path.is_dir():
        raise EvidenceError(f"not a directory: {path}")
    digest = hashlib.sha256()
    total_bytes = 0
    file_count = 0
    for file_path in sorted(item for item in path.rglob("*") if item.is_file()):
        relative = file_path.relative_to(path).as_posix()
        file_digest = sha256_file(file_path)
        size = file_path.stat().st_size
        digest.update(f"{relative}|{file_digest}|{size}\n".encode())
        total_bytes += size
        file_count += 1
    return digest.hexdigest(), total_bytes, file_count


def artifact_identity(path: Path) -> dict[str, Any]:
    if path.is_file():
        return {
            "path": str(path),
            "kind": "file",
            "sha256": sha256_file(path),
            "bytes": path.stat().st_size,
        }
    if path.is_dir():
        digest, size, count = directory_digest(path)
        return {
            "path": str(path),
            "kind": "directory",
            "treeSHA256": digest,
            "bytes": size,
            "fileCount": count,
        }
    raise EvidenceError(f"missing artifact: {path}")


def require_identity(record: dict[str, Any], label: str) -> Path:
    path = Path(str(record.get("path", "")))
    expected_file = record.get("sha256")
    expected_tree = record.get("treeSHA256")
    if path.is_file() and isinstance(expected_file, str):
        if sha256_file(path) != expected_file:
            raise EvidenceError(f"frozen identity drift for {label}")
    elif path.is_dir() and isinstance(expected_tree, str):
        actual_tree, _, _ = directory_digest(path)
        if actual_tree != expected_tree:
            raise EvidenceError(f"frozen directory drift for {label}")
    else:
        raise EvidenceError(f"invalid frozen identity for {label}")
    return path


def manifest_command(path: Path, command_id: str) -> list[str]:
    prefix = f"{command_id}="
    matches = [line[len(prefix) :] for line in path.read_text().splitlines() if line.startswith(prefix)]
    if len(matches) != 1:
        raise EvidenceError(f"manifest must contain exactly one {command_id} command")
    try:
        return shlex.split(matches[0])
    except ValueError as error:
        raise EvidenceError(f"invalid manifest command quoting for {command_id}") from error


def gate_command_id(args: argparse.Namespace) -> str:
    if args.subcommand == "run":
        return str(args.command_id)
    return {
        "reconcile-skips": "P01V9",
        "restore": "P02V9",
        "render-result": "P03V9",
        "publish-scan": "P04V9",
        "inventory": "P05V9",
    }[args.subcommand]


def validate_sequence(
    command_id: str, expected: dict[str, Any], execution_gate: dict[str, Any]
) -> None:
    sequence = expected.get("sequence")
    if not isinstance(sequence, list):
        raise EvidenceError("frozen command sequence is missing")
    command_ids = [item.get("commandID") for item in sequence if isinstance(item, dict)]
    required_ids = [
        *[f"C{number:02d}V9" for number in range(2, 12)],
        *[f"P{number:02d}V9" for number in range(1, 6)],
    ]
    if command_ids != required_ids or command_id not in command_ids:
        raise EvidenceError("frozen command sequence is invalid")
    current_index = command_ids.index(command_id)

    for predecessor in sequence[:current_index]:
        predecessor_id = predecessor["commandID"]
        completion = Path(predecessor["completion"])
        if predecessor_id.startswith("C"):
            receipt_summary(completion, execution_gate)
            continue
        value = read_json(completion)
        if (
            value.get("commandID") != predecessor_id
            or value.get("exitCode") != 0
            or value.get("verdict") != "pass"
        ):
            raise EvidenceError(f"predecessor is not passing: {predecessor_id}")
        predecessor_gate = value.get("executionGate")
        if not isinstance(predecessor_gate, dict) or any(
            predecessor_gate.get(key) != execution_gate.get(key)
            for key in (
                "manifestSHA256",
                "bindingSHA256",
                "approvalSHA256",
                "expectedArtifactManifestSHA256",
            )
        ):
            raise EvidenceError(f"predecessor gate drift: {predecessor_id}")

    for item in sequence[current_index:]:
        for path_value in item.get("ownedArtifacts", []):
            if Path(path_value).exists():
                raise EvidenceError(
                    f"one-shot sequence artifact already exists for {item['commandID']}"
                )


def validate_execution_gate(args: argparse.Namespace) -> dict[str, Any]:
    command_id = gate_command_id(args)
    manifest_path = GATE_MANIFEST
    binding_path = GATE_BINDING
    approval_path = GATE_APPROVAL
    expected_path = GATE_EXPECTED

    binding = read_json(binding_path)
    if binding.get("schema") != "CANARY-001-QEF-RUN-HEADER-BINDING-v9":
        raise EvidenceError("invalid run-header binding schema")
    bound_manifest = require_identity(binding.get("manifest", {}), "manifest")
    bound_header = require_identity(binding.get("runHeader", {}), "run header")
    bound_expected = require_identity(
        binding.get("expectedArtifactManifest", {}), "expected artifacts"
    )
    bound_tool = require_identity(binding.get("tool", {}), "evidence tool")
    if manifest_path.resolve() != bound_manifest.resolve():
        raise EvidenceError("gate manifest path differs from binding")
    if expected_path.resolve() != bound_expected.resolve():
        raise EvidenceError("gate expected-artifact path differs from binding")
    if bound_tool.resolve() != Path(__file__).resolve():
        raise EvidenceError("executing evidence tool differs from binding")

    expected = read_json(expected_path)
    if expected.get("schema") != "CANARY-001-QEF-EXPECTED-ARTIFACTS-v9":
        raise EvidenceError("invalid expected-artifact manifest schema")
    frozen_inputs = expected.get("frozenInputs")
    if not isinstance(frozen_inputs, list) or not frozen_inputs:
        raise EvidenceError("frozen source inputs are missing")
    for index, identity in enumerate(frozen_inputs):
        if not isinstance(identity, dict):
            raise EvidenceError("invalid frozen source input")
        require_identity(identity, f"source input {index}")

    header = read_json(bound_header)
    approval = read_json(approval_path)
    if approval.get("schema") != "CANARY-001-QEF-PRE-RUN-APPROVAL-v9":
        raise EvidenceError("invalid pre-run approval schema")
    if approval.get("state") != "approved":
        raise EvidenceError("pre-run approval is not approved")
    expected_approval_hashes = {
        "manifestSHA256": sha256_file(manifest_path),
        "bindingSHA256": sha256_file(binding_path),
        "runHeaderSHA256": sha256_file(bound_header),
        "expectedArtifactManifestSHA256": sha256_file(expected_path),
        "toolSHA256": sha256_file(Path(__file__)),
    }
    if any(approval.get(key) != value for key, value in expected_approval_hashes.items()):
        raise EvidenceError("pre-run approval hashes differ from frozen gate")
    contract = header.get("contract", {})
    if approval.get("runID") != contract.get("runID"):
        raise EvidenceError("pre-run approval runID mismatch")
    if approval.get("freshToken") != contract.get("freshToken"):
        raise EvidenceError("pre-run approval fresh token mismatch")
    if binding.get("bindingID") != contract.get("runID"):
        raise EvidenceError("binding/run-header runID mismatch")

    reviews = approval.get("reviews")
    if not isinstance(reviews, list) or len(reviews) != 2:
        raise EvidenceError("pre-run approval must contain two reviews")
    roles = {review.get("role") for review in reviews if isinstance(review, dict)}
    if roles != {"Architecture", "Quality"}:
        raise EvidenceError("pre-run approval roles are incomplete")
    for review in reviews:
        if (
            review.get("verdict") != "approve"
            or review.get("P0") != 0
            or review.get("P1") != 0
        ):
            raise EvidenceError("pre-run review is not P0/P1 clear")

    expected_invocation = manifest_command(manifest_path, command_id)
    actual_invocation = ["python3", *sys.argv]
    if actual_invocation != expected_invocation:
        raise EvidenceError(f"actual invocation differs from frozen {command_id}")
    execution_gate = {
        "verdict": "pass",
        "commandID": command_id,
        "manifestSHA256": sha256_file(manifest_path),
        "bindingSHA256": sha256_file(binding_path),
        "approvalSHA256": sha256_file(approval_path),
        "expectedArtifactManifestSHA256": sha256_file(expected_path),
        "invocationSHA256": hashlib.sha256(
            json.dumps(actual_invocation, separators=(",", ":")).encode()
        ).hexdigest(),
    }
    validate_sequence(command_id, expected, execution_gate)
    return execution_gate


def run_checked(argv: list[str], *, stdout_path: Path | None = None) -> str:
    try:
        result = subprocess.run(
            argv,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
    except OSError as error:
        raise EvidenceError(f"cannot execute {argv[0]}: {error}") from error
    output = result.stdout
    if stdout_path is not None:
        atomic_write(stdout_path, output)
    if result.returncode != 0:
        raise EvidenceError(
            f"command failed rc={result.returncode}: {json.dumps(argv)}"
        )
    return output.decode("utf-8", errors="replace")


def classify_skip(reason: str) -> str:
    lowered = reason.lower()
    if any(pattern in lowered for pattern in PROVENANCE_SKIP_PATTERNS):
        return "provenanceCommit"
    if any(pattern in lowered for pattern in ENVIRONMENT_SKIP_PATTERNS):
        return "environmentFixture"
    return "other"


def parse_xunit(path: Path, label: str) -> dict[str, Any]:
    try:
        root = ET.parse(path).getroot()
    except Exception as error:
        raise EvidenceError(f"invalid xunit {path}: {error}") from error

    testcases = list(root.iter("testcase"))
    skips: list[dict[str, str]] = []
    for testcase in testcases:
        skipped = testcase.find("skipped")
        if skipped is None:
            continue
        reason = skipped.get("message") or (skipped.text or "")
        skips.append(
            {
                "test": testcase.get("name", "unknown"),
                "classification": classify_skip(reason),
                "coverage": "NotObserved",
            }
        )

    declared_skipped = 0
    for suite in root.iter("testsuite"):
        declared_skipped += int(suite.get("skipped", "0"))
    if declared_skipped != len(skips):
        raise EvidenceError(
            f"xunit skip mismatch for {label}: declared={declared_skipped} parsed={len(skips)}"
        )

    failures = sum(1 for testcase in testcases if testcase.find("failure") is not None)
    errors = sum(1 for testcase in testcases if testcase.find("error") is not None)
    return {
        "label": label,
        "total": len(testcases),
        "passed": len(testcases) - len(skips) - failures - errors,
        "failed": failures + errors,
        "skipped": len(skips),
        "skips": skips,
    }


def sanitize_xcresult_summary(raw_path: Path, output_path: Path, label: str) -> dict[str, Any]:
    raw = read_json(raw_path)
    required = (
        "totalTestCount",
        "passedTests",
        "failedTests",
        "skippedTests",
        "result",
        "startTime",
        "finishTime",
    )
    if any(key not in raw for key in required):
        raise EvidenceError(f"xcresult summary missing fields: {raw_path}")
    value = {
        "schema": "CANARY-001-XCRESULT-COUNTS-v9",
        "label": label,
        "total": int(raw["totalTestCount"]),
        "passed": int(raw["passedTests"]),
        "failed": int(raw["failedTests"]),
        "skipped": int(raw["skippedTests"]),
        "result": str(raw["result"]),
        "startTime": float(raw["startTime"]),
        "finishTime": float(raw["finishTime"]),
    }
    if value["total"] != value["passed"] + value["failed"] + value["skipped"]:
        raise EvidenceError(f"xcresult count mismatch: {raw_path}")
    write_json(output_path, value)
    return value


def sanitize_swift_xctest_log(
    log_path: Path, output_path: Path, label: str
) -> dict[str, Any]:
    try:
        text = log_path.read_text(encoding="utf-8", errors="replace")
    except OSError as error:
        raise EvidenceError(f"cannot read Swift XCTest log {log_path}: {error}") from error
    # Unfiltered SwiftPM runs close with "All tests"; filtered runs close with
    # "Selected tests". Both are XCTest's aggregate suite for that invocation.
    pattern = re.compile(
        r"Test Suite '(All tests|Selected tests)' (passed|failed).*?"
        r"Executed (\d+) tests, with (\d+) failures? \((\d+) unexpected\)",
        re.DOTALL,
    )
    matches = list(pattern.finditer(text))
    if not matches:
        raise EvidenceError(f"missing XCTest aggregate summary: {log_path}")
    suite, result, total_value, failed_value, unexpected_value = matches[-1].groups()
    total = int(total_value)
    failed = int(failed_value)
    unexpected = int(unexpected_value)
    skips = parse_skip_log(log_path)
    skipped = len(skips)
    passed = total - failed - skipped
    if (
        result != "passed"
        or total <= 0
        or failed != 0
        or unexpected != 0
        or passed <= 0
    ):
        raise EvidenceError(f"Swift XCTest summary is not a non-empty pass: {label}")
    value = {
        "schema": "CANARY-001-SWIFT-XCTEST-COUNTS-v9",
        "label": label,
        "aggregateSuite": suite,
        "total": total,
        "passed": passed,
        "failed": failed,
        "unexpected": unexpected,
        "skipped": skipped,
        "result": "Passed",
    }
    write_json(output_path, value)
    return value


def parse_skip_log(path: Path) -> list[dict[str, str]]:
    current_test = "unknown"
    entries: list[dict[str, str]] = []
    started = re.compile(r"Test Case '([^']+)' started")
    skipped = re.compile(r"Test skipped - (.+)$")
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError as error:
        raise EvidenceError(f"cannot read skip log {path}: {error}") from error
    for line in lines:
        match = started.search(line)
        if match:
            current_test = match.group(1)
        match = skipped.search(line)
        if match:
            entries.append(
                {
                    "test": current_test,
                    "classification": classify_skip(match.group(1)),
                    "coverage": "NotObserved",
                }
            )
    return entries


def command_run(args: argparse.Namespace) -> int:
    command = list(args.command)
    if command and command[0] == "--":
        command = command[1:]
    if not command:
        raise EvidenceError("missing child command")

    log_path = Path(args.log)
    receipt_path = Path(args.receipt)
    quarantine_path = Path(args.quarantine_receipt)
    log_path.parent.mkdir(parents=True, exist_ok=True)
    start = now()
    child_status = 127
    capture_errors: list[str] = []

    try:
        result = subprocess.run(
            ["/usr/bin/script", "-q", str(log_path), *command],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT,
        )
        child_status = result.returncode
    except OSError as error:
        capture_errors.append(f"child-launch:{error}")
    end = now()

    artifacts: list[dict[str, Any]] = []
    for path_value in args.file + args.binary:
        path = Path(path_value)
        try:
            artifacts.append(artifact_identity(path))
        except EvidenceError as error:
            artifacts.append({"path": str(path), "status": "missing"})
            if child_status == 0:
                capture_errors.append(str(error))

    for source_value, archive_value in args.bundle:
        source = Path(source_value)
        archive = Path(archive_value)
        try:
            archive.parent.mkdir(parents=True, exist_ok=True)
            run_checked(
                [
                    "ditto",
                    "-c",
                    "-k",
                    "--sequesterRsrc",
                    "--keepParent",
                    str(source),
                    str(archive),
                ]
            )
            artifacts.append(
                {
                    "source": artifact_identity(source),
                    "archive": artifact_identity(archive),
                }
            )
        except EvidenceError as error:
            artifacts.append({"path": str(source), "status": "capture-failed"})
            capture_errors.append(str(error))

    for label, source_value, archive_value, raw_summary_value, counts_value in args.xcresult:
        source = Path(source_value)
        archive = Path(archive_value)
        raw_summary = Path(raw_summary_value)
        counts = Path(counts_value)
        try:
            archive.parent.mkdir(parents=True, exist_ok=True)
            run_checked(
                [
                    "ditto",
                    "-c",
                    "-k",
                    "--sequesterRsrc",
                    "--keepParent",
                    str(source),
                    str(archive),
                ]
            )
            run_checked(
                [
                    "xcrun",
                    "xcresulttool",
                    "get",
                    "test-results",
                    "summary",
                    "--path",
                    str(source),
                    "--compact",
                ],
                stdout_path=raw_summary,
            )
            sanitize_xcresult_summary(raw_summary, counts, label)
            artifacts.append(
                {
                    "source": artifact_identity(source),
                    "archive": artifact_identity(archive),
                    "rawSummary": artifact_identity(raw_summary),
                    "counts": artifact_identity(counts),
                }
            )
        except EvidenceError as error:
            artifacts.append({"path": str(source), "status": "capture-failed"})
            capture_errors.append(str(error))

    for label, log_value, counts_value in args.swift_xctest:
        log = Path(log_value)
        counts = Path(counts_value)
        try:
            sanitize_swift_xctest_log(log, counts, label)
            artifacts.append(artifact_identity(counts))
        except EvidenceError as error:
            artifacts.append({"path": str(counts), "status": "capture-failed"})
            capture_errors.append(str(error))

    quarantined: list[dict[str, Any]] = []
    for path_value in args.quarantine:
        try:
            identity = artifact_identity(Path(path_value))
            identity["disposition"] = "quarantined-not-publishable"
            quarantined.append(identity)
        except EvidenceError as error:
            capture_errors.append(str(error))

    quarantine_receipt = {
        "schema": "CANARY-001-RAW-QUARANTINE-v9",
        "commandID": args.command_id,
        "scope": quarantined,
        "verdict": "quarantined-not-publishable"
        if not capture_errors
        else "quarantine-capture-failed",
    }
    write_json(quarantine_path, quarantine_receipt)

    receipt = {
        "schema": "CANARY-001-QEF-COMMAND-RECEIPT-v9",
        "toolSHA256": sha256_file(Path(__file__)),
        "commandID": args.command_id,
        "startTime": start,
        "endTime": end,
        "timezone": "Asia/Shanghai",
        "exitCode": child_status,
        "argv": command,
        "artifacts": artifacts,
        "quarantineReceipt": artifact_identity(quarantine_path),
        "captureErrors": capture_errors,
        "executionGate": args.execution_gate,
    }
    write_json(receipt_path, receipt)

    if child_status != 0:
        return child_status
    if capture_errors:
        return 96
    return 0


def command_reconcile(args: argparse.Namespace) -> int:
    start = now()
    groups: list[dict[str, Any]] = []
    all_skips: list[dict[str, str]] = []
    for label, path_value in args.xunit:
        path = Path(path_value)
        assert_receipt_artifact(label, path, args.execution_gate)
        group = parse_xunit(path, label)
        groups.append({key: value for key, value in group.items() if key != "skips"})
        all_skips.extend(group["skips"])

    log_entries_by_label: dict[str, list[dict[str, str]]] = {}
    for label, path_value in args.skip_log:
        path = Path(path_value)
        assert_receipt_artifact(label, path, args.execution_gate)
        log_entries_by_label[label] = parse_skip_log(path)
    for label, path_value in args.counts:
        path = Path(path_value)
        assert_receipt_artifact(label, path, args.execution_gate)
        counts = read_json(path)
        if counts.get("schema") not in {
            "CANARY-001-XCRESULT-COUNTS-v9",
            "CANARY-001-SWIFT-XCTEST-COUNTS-v9",
        }:
            raise EvidenceError(f"invalid counts schema: {path_value}")
        skipped = int(counts["skipped"])
        entries = log_entries_by_label.get(label, [])
        if skipped != len(entries):
            raise EvidenceError(
                f"xcresult/log skip mismatch for {label}: summary={skipped} log={len(entries)}"
            )
        groups.append(
            {
                "label": label,
                "total": int(counts["total"]),
                "passed": int(counts["passed"]),
                "failed": int(counts["failed"]),
                "skipped": skipped,
            }
        )
        all_skips.extend(entries)

    unknown = [entry for entry in all_skips if entry["classification"] == "other"]
    output = {
        "schema": "CANARY-001-SKIP-RECONCILIATION-v9",
        "commandID": "P01V9",
        "startTime": start,
        "endTime": now(),
        "exitCode": 0 if not unknown else 98,
        "groups": groups,
        "skips": all_skips,
        "totalSkipped": len(all_skips),
        "unknownSkipped": len(unknown),
        "executionGate": args.execution_gate,
        "verdict": "pass" if not unknown else "blockedUnknownSkip",
    }
    write_json(Path(args.output), output)
    return 0 if not unknown else 98


def extract_active_conditions(show_build_settings: str) -> list[str]:
    conditions: list[str] = []
    for line in show_build_settings.splitlines():
        if "SWIFT_ACTIVE_COMPILATION_CONDITIONS" in line and "=" in line:
            conditions.append(line.split("=", 1)[1].strip())
    if not conditions:
        raise EvidenceError("missing SWIFT_ACTIVE_COMPILATION_CONDITIONS")
    return conditions


def command_restore(args: argparse.Namespace) -> int:
    app = Path(args.app)
    app_binary = app / "Universe Keyboard"
    extension_binary = app / "PlugIns/Keyboard.appex/Keyboard"
    output = Path(args.output)
    raw_dir = Path(args.raw_dir)
    raw_dir.mkdir(parents=True, exist_ok=True)
    start = now()

    receipt_summary(Path(args.build_receipt), args.execution_gate)
    assert_receipt_artifact("C11V9", app_binary, args.execution_gate)
    assert_receipt_artifact("C11V9", extension_binary, args.execution_gate)

    built_app_hash = sha256_file(app_binary)
    built_extension_hash = sha256_file(extension_binary)
    build_settings = run_checked(
        [
            "xcodebuild",
            "-project",
            "Universe Keyboard.xcodeproj",
            "-scheme",
            "Universe Keyboard",
            "-configuration",
            "Debug",
            "-destination",
            f"platform=iOS Simulator,id={args.udid}",
            "-showBuildSettings",
        ],
        stdout_path=raw_dir / "C11-ordinary-show-build-settings.log",
    )
    conditions = extract_active_conditions(build_settings)
    if any("T9_RESPONSIVE_CANARY_INTERNAL" in value for value in conditions):
        raise EvidenceError("ordinary restore build contains internal canary condition")

    run_checked(
        ["xcrun", "simctl", "install", args.udid, str(app)],
        stdout_path=raw_dir / "C11-simctl-install.log",
    )
    installed_path = run_checked(
        [
            "xcrun",
            "simctl",
            "get_app_container",
            args.udid,
            args.bundle_id,
            "app",
        ],
        stdout_path=raw_dir / "C11-installed-container.log",
    ).strip()
    installed_app = Path(installed_path)
    installed_app_hash = sha256_file(installed_app / "Universe Keyboard")
    installed_extension_hash = sha256_file(
        installed_app / "PlugIns/Keyboard.appex/Keyboard"
    )
    if built_app_hash != installed_app_hash:
        raise EvidenceError("installed App executable hash differs from ordinary build")
    if built_extension_hash != installed_extension_hash:
        raise EvidenceError("installed Extension executable hash differs from ordinary build")

    receipt = {
        "schema": "CANARY-001-ORDINARY-RESTORE-v9",
        "commandID": "P02V9",
        "startTime": start,
        "endTime": now(),
        "replacementOrder": [
            "ordinary build completed",
            "simctl install replaced containing App",
            "installed App and Extension hashes compared",
            "ordinary compilation condition verified",
            "main App intentionally not launched to avoid sync/deploy side effects",
        ],
        "bundleID": args.bundle_id,
        "simulatorUDID": args.udid,
        "builtAppSHA256": built_app_hash,
        "installedAppSHA256": installed_app_hash,
        "builtExtensionSHA256": built_extension_hash,
        "installedExtensionSHA256": installed_extension_hash,
        "ordinaryConditions": conditions,
        "internalConditionAbsent": True,
        "launchSmoke": "not-run(boundary-preserving install identity proof only)",
        "exitCode": 0,
        "executionGate": args.execution_gate,
        "verdict": "pass",
    }
    write_json(output, receipt)
    return 0


def validate_publishable(value: Any, path: str = "$") -> None:
    if isinstance(value, dict):
        for key, child in value.items():
            normalized = re.sub(r"[^a-z]", "", key.lower())
            if normalized in SENSITIVE_KEYS:
                raise EvidenceError(f"sensitive key in publishable JSON: {path}.{key}")
            validate_publishable(child, f"{path}.{key}")
    elif isinstance(value, list):
        for index, child in enumerate(value):
            validate_publishable(child, f"{path}[{index}]")
    elif isinstance(value, str):
        try:
            value.encode("ascii")
        except UnicodeEncodeError as error:
            raise EvidenceError(f"non-ASCII publishable value at {path}") from error
        lowered = value.lower()
        if any(f"{key}=" in lowered or f"{key}:" in lowered for key in SENSITIVE_KEYS):
            raise EvidenceError(f"sensitive labeled value at {path}")


def command_publish_scan(args: argparse.Namespace) -> int:
    start = now()
    expected_manifest = read_json(Path(args.expected_manifest))
    if expected_manifest.get("schema") != "CANARY-001-QEF-EXPECTED-ARTIFACTS-v9":
        raise EvidenceError("invalid expected-artifact manifest schema")
    expected_scopes = expected_manifest.get("publishable")
    if not isinstance(expected_scopes, list) or not expected_scopes:
        raise EvidenceError("expected publishable scope is missing or empty")
    if sorted(args.scope) != sorted(expected_scopes):
        raise EvidenceError("publication scan scope differs from frozen expected scope")
    scopes: list[dict[str, Any]] = []
    for path_value in args.scope:
        path = Path(path_value)
        value = read_json(path)
        validate_publishable(value)
        scopes.append(
            {
                "path": str(path),
                "sha256": sha256_file(path),
                "bytes": path.stat().st_size,
            }
        )
    output = {
        "schema": "T9RESP-CANARY-PRIVACY-v1/publication-scan-v9",
        "commandID": "P04V9",
        "startTime": start,
        "endTime": now(),
        "exitCode": 0,
        "scannerSHA256": sha256_file(Path(__file__)),
        "scope": scopes,
        "rawArtifacts": "quarantined-not-publishable",
        "executionGate": args.execution_gate,
        "verdict": "pass",
    }
    write_json(Path(args.output), output)
    return 0


def recorded_file_hashes(value: Any) -> dict[str, str]:
    hashes: dict[str, str] = {}
    if isinstance(value, dict):
        path = value.get("path")
        digest = value.get("sha256")
        if isinstance(path, str) and isinstance(digest, str):
            hashes[path] = digest
        for child in value.values():
            hashes.update(recorded_file_hashes(child))
    elif isinstance(value, list):
        for child in value:
            hashes.update(recorded_file_hashes(child))
    return hashes


def assert_receipt_artifact(
    command_id: str, path: Path, execution_gate: dict[str, Any]
) -> None:
    receipt_path = Path(f"evidence/CANARY-001-v9/receipts/{command_id}.receipt.json")
    receipt_summary(receipt_path, execution_gate)
    receipt = read_json(receipt_path)
    hashes = recorded_file_hashes(receipt.get("artifacts", []))
    if hashes.get(str(path)) != sha256_file(path):
        raise EvidenceError(f"artifact hash differs from {command_id} receipt: {path}")


def receipt_summary(path: Path, execution_gate: dict[str, Any]) -> dict[str, Any]:
    value = read_json(path)
    if value.get("schema") != "CANARY-001-QEF-COMMAND-RECEIPT-v9":
        raise EvidenceError(f"invalid command receipt schema: {path}")
    if value.get("exitCode") != 0 or value.get("captureErrors"):
        raise EvidenceError(f"non-passing command receipt: {path}")
    if value.get("toolSHA256") != sha256_file(Path(__file__)):
        raise EvidenceError(f"command receipt tool drift: {path}")
    receipt_gate = value.get("executionGate")
    if not isinstance(receipt_gate, dict) or receipt_gate.get("verdict") != "pass":
        raise EvidenceError(f"command receipt lacks passing execution gate: {path}")
    for key in (
        "manifestSHA256",
        "bindingSHA256",
        "approvalSHA256",
        "expectedArtifactManifestSHA256",
    ):
        if receipt_gate.get(key) != execution_gate.get(key):
            raise EvidenceError(f"command receipt gate drift for {key}: {path}")
    expected_invocation = manifest_command(GATE_MANIFEST, str(value["commandID"]))
    expected_invocation_hash = hashlib.sha256(
        json.dumps(expected_invocation, separators=(",", ":")).encode()
    ).hexdigest()
    if receipt_gate.get("invocationSHA256") != expected_invocation_hash:
        raise EvidenceError(f"command receipt invocation differs from manifest: {path}")
    return {
        "commandID": value["commandID"],
        "exitCode": value["exitCode"],
        "startTime": value["startTime"],
        "endTime": value["endTime"],
        "receiptSHA256": sha256_file(path),
    }


def command_render(args: argparse.Namespace) -> int:
    start = now()
    receipt_values = {read_json(Path(path))["commandID"]: read_json(Path(path)) for path in args.receipt}
    commands = [
        receipt_summary(Path(path), args.execution_gate) for path in args.receipt
    ]
    expected_command_ids = {f"C{number:02d}V9" for number in range(2, 12)}
    actual_command_ids = [command["commandID"] for command in commands]
    if len(actual_command_ids) != len(set(actual_command_ids)):
        raise EvidenceError("duplicate command receipt")
    if set(actual_command_ids) != expected_command_ids:
        raise EvidenceError("command receipt set differs from C02V9-C11V9")
    tests: list[dict[str, Any]] = []
    if args.xunit:
        raise EvidenceError("v9 formal result does not accept legacy xunit inputs")
    for label, path_value in args.xunit:
        path = Path(path_value)
        group = parse_xunit(path, label)
        if group["total"] <= 0 or group["passed"] <= 0 or group["failed"] != 0:
            raise EvidenceError(f"xunit group is not a non-empty pass: {label}")
        hashes = recorded_file_hashes(receipt_values[label].get("artifacts", []))
        if hashes.get(str(path)) != sha256_file(path):
            raise EvidenceError(f"xunit hash differs from command receipt: {label}")
        tests.append({key: value for key, value in group.items() if key != "skips"})
    count_labels: set[str] = set()
    for path_value in args.counts:
        path = Path(path_value)
        value = read_json(path)
        if value.get("schema") not in {
            "CANARY-001-XCRESULT-COUNTS-v9",
            "CANARY-001-SWIFT-XCTEST-COUNTS-v9",
        }:
            raise EvidenceError(f"invalid counts schema: {path_value}")
        label = value.get("label")
        if label not in {
            "C02V9", "C03V9", "C04V9", "C08V9", "C09V9", "C10V9"
        } or label in count_labels:
            raise EvidenceError("xcresult count labels are incomplete or duplicated")
        count_labels.add(label)
        if (
            int(value.get("total", 0)) <= 0
            or int(value.get("passed", 0)) <= 0
            or int(value.get("failed", 0)) != 0
            or str(value.get("result", "")).lower() != "passed"
        ):
            raise EvidenceError(f"xcresult group is not a non-empty pass: {label}")
        hashes = recorded_file_hashes(receipt_values[label].get("artifacts", []))
        if hashes.get(str(path)) != sha256_file(path):
            raise EvidenceError(f"counts hash differs from command receipt: {label}")
        tests.append(value)
    if count_labels != {"C02V9", "C03V9", "C04V9", "C08V9", "C09V9", "C10V9"}:
        raise EvidenceError("test count group set differs from frozen six groups")
    skips = read_json(Path(args.skip_reconciliation))
    restore = read_json(Path(args.restore))
    for prerequisite_name, prerequisite in (("skip", skips), ("restore", restore)):
        prerequisite_gate = prerequisite.get("executionGate")
        if not isinstance(prerequisite_gate, dict):
            raise EvidenceError(f"{prerequisite_name} prerequisite lacks execution gate")
        for key in (
            "manifestSHA256",
            "bindingSHA256",
            "approvalSHA256",
            "expectedArtifactManifestSHA256",
        ):
            if prerequisite_gate.get(key) != args.execution_gate.get(key):
                raise EvidenceError(f"{prerequisite_name} prerequisite gate drift")
    if (
        skips.get("schema") != "CANARY-001-SKIP-RECONCILIATION-v9"
        or skips.get("verdict") != "pass"
        or skips.get("unknownSkipped") != 0
    ):
        raise EvidenceError("skip reconciliation is not a passing v9 record")
    if (
        restore.get("schema") != "CANARY-001-ORDINARY-RESTORE-v9"
        or restore.get("verdict") != "pass"
        or restore.get("internalConditionAbsent") is not True
        or restore.get("launchSmoke")
        != "not-run(boundary-preserving install identity proof only)"
    ):
        raise EvidenceError("ordinary restore is not a passing v9 record")
    expected_groups = [
        {key: value for key, value in test.items() if key in {"label", "total", "passed", "failed", "skipped"}}
        for test in tests
    ]
    if skips.get("groups") != expected_groups:
        raise EvidenceError("skip reconciliation groups differ from current test inputs")
    if skips.get("totalSkipped") != sum(group["skipped"] for group in expected_groups):
        raise EvidenceError("skip reconciliation total differs from current test inputs")
    output = {
        "schema": "CANARY-001-QEF-RESULT-RECORD-v9",
        "commandID": "P03V9",
        "startTime": start,
        "endTime": now(),
        "exitCode": 0,
        "commands": commands,
        "tests": tests,
        "skipReconciliation": {
            "sha256": sha256_file(Path(args.skip_reconciliation)),
            "totalSkipped": skips["totalSkipped"],
            "unknownSkipped": skips["unknownSkipped"],
            "verdict": skips["verdict"],
        },
        "restore": {
            "sha256": sha256_file(Path(args.restore)),
            "verdict": restore["verdict"],
            "internalConditionAbsent": restore["internalConditionAbsent"],
            "launchSmoke": restore["launchSmoke"],
        },
        "claimBoundary": "automated build/test and Simulator only",
        "executionGate": args.execution_gate,
        "verdict": "pass",
    }
    write_json(Path(args.output), output)
    return 0


def command_inventory(args: argparse.Namespace) -> int:
    start = now()
    expected_manifest_path = Path(args.expected_manifest)
    expected_manifest = read_json(expected_manifest_path)
    if expected_manifest.get("schema") != "CANARY-001-QEF-EXPECTED-ARTIFACTS-v9":
        raise EvidenceError("invalid expected-artifact manifest schema")
    root = Path(args.root)
    required = [root / path for path in expected_manifest["local"]]
    missing = [str(path) for path in required if not path.exists()]
    if missing:
        raise EvidenceError(f"missing expected artifacts: {missing}")

    for receipt_path in expected_manifest["receipts"]:
        receipt_summary(root / receipt_path, args.execution_gate)

    post_run_local_only = expected_manifest.get("postRunLocalOnly")
    expected_post_run = [
        "evidence/CANARY-001-v9/derived/P04-publication-scan.json",
        str(Path(args.output)),
        f"{args.output}.sha256",
        f"{args.output}.verify.txt",
    ]
    if post_run_local_only != expected_post_run:
        raise EvidenceError("post-run local-only artifact set differs from frozen set")
    publication_scan = read_json(root / "derived/P04-publication-scan.json")
    if (
        publication_scan.get("schema")
        != "T9RESP-CANARY-PRIVACY-v1/publication-scan-v9"
        or publication_scan.get("verdict") != "pass"
    ):
        raise EvidenceError("publication scan is not a passing v9 record")
    scan_gate = publication_scan.get("executionGate")
    if not isinstance(scan_gate, dict) or any(
        scan_gate.get(key) != args.execution_gate.get(key)
        for key in (
            "manifestSHA256",
            "bindingSHA256",
            "approvalSHA256",
            "expectedArtifactManifestSHA256",
        )
    ):
        raise EvidenceError("publication scan gate differs from P05V9 gate")
    scanned_scope = publication_scan.get("scope")
    if not isinstance(scanned_scope, list):
        raise EvidenceError("publication scan scope is invalid")
    scanned_paths = [item.get("path") for item in scanned_scope if isinstance(item, dict)]
    if (
        len(scanned_paths) != len(scanned_scope)
        or len(scanned_paths) != len(set(scanned_paths))
        or sorted(scanned_paths) != sorted(expected_manifest["publishable"])
    ):
        raise EvidenceError("publication scan scope differs from frozen publishable set")
    for item in scanned_scope:
        path = Path(item["path"])
        if (
            sha256_file(path) != item.get("sha256")
            or path.stat().st_size != item.get("bytes")
        ):
            raise EvidenceError(f"publishable artifact drift after P04V9: {path}")
    validate_publishable(publication_scan)

    output = Path(args.output)
    excluded = {
        output.resolve(),
        Path(f"{output}.sha256").resolve(),
        Path(f"{output}.verify.txt").resolve(),
    }
    artifacts: list[dict[str, Any]] = []
    try:
        files = sorted(path for path in root.rglob("*") if path.is_file())
    except OSError as error:
        raise EvidenceError(f"cannot enumerate archive root: {error}") from error
    for path in files:
        if path.resolve() in excluded:
            continue
        identity = artifact_identity(path)
        identity["path"] = path.relative_to(root).as_posix()
        artifacts.append(identity)

    external = [
        artifact_identity(Path(path)) for path in expected_manifest["external"]
    ]
    external.append(artifact_identity(expected_manifest_path))
    value = {
        "schema": "CANARY-001-QEF-ARTIFACT-INVENTORY-v9",
        "commandID": "P05V9",
        "startTime": start,
        "endTime": now(),
        "exitCode": 0,
        "manifest": artifact_identity(Path(args.manifest)),
        "runHeaderBinding": artifact_identity(Path(args.binding)),
        "approvalReceipt": artifact_identity(Path(args.approval)),
        "expectedArtifactManifest": artifact_identity(expected_manifest_path),
        "requiredArtifactCount": len(required),
        "archiveArtifacts": artifacts,
        "externalArtifacts": external,
        "publicationScan": artifact_identity(root / "derived/P04-publication-scan.json"),
        "disposition": "local-only-not-publishable; canonical result was scanned by P04V9",
        "executionGate": args.execution_gate,
        "verdict": "pass",
    }
    validate_publishable(value)
    write_json(output, value)
    digest = sha256_file(output)
    sidecar = Path(f"{output}.sha256")
    atomic_write(sidecar, f"{digest}  {output}\n".encode())
    if sha256_file(output) != digest:
        raise EvidenceError("inventory self-verification failed")
    atomic_write(Path(f"{output}.verify.txt"), f"{output}: OK\n".encode())
    for path_value in post_run_local_only:
        if not Path(path_value).exists():
            raise EvidenceError(f"missing post-run local-only artifact: {path_value}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="subcommand", required=True)

    run_parser = subparsers.add_parser("run")
    run_parser.add_argument("--command-id", required=True)
    run_parser.add_argument("--log", required=True)
    run_parser.add_argument("--receipt", required=True)
    run_parser.add_argument("--quarantine-receipt", required=True)
    run_parser.add_argument("--file", action="append", default=[])
    run_parser.add_argument("--binary", action="append", default=[])
    run_parser.add_argument("--bundle", nargs=2, action="append", default=[])
    run_parser.add_argument("--xcresult", nargs=5, action="append", default=[])
    run_parser.add_argument("--swift-xctest", nargs=3, action="append", default=[])
    run_parser.add_argument("--quarantine", action="append", default=[])
    run_parser.add_argument("command", nargs=argparse.REMAINDER)

    reconcile = subparsers.add_parser("reconcile-skips")
    reconcile.add_argument("--xunit", nargs=2, action="append", default=[])
    reconcile.add_argument("--counts", nargs=2, action="append", default=[])
    reconcile.add_argument("--skip-log", nargs=2, action="append", default=[])
    reconcile.add_argument("--output", required=True)

    restore = subparsers.add_parser("restore")
    restore.add_argument("--udid", required=True)
    restore.add_argument("--app", required=True)
    restore.add_argument("--bundle-id", required=True)
    restore.add_argument("--build-receipt", required=True)
    restore.add_argument("--raw-dir", required=True)
    restore.add_argument("--output", required=True)

    publish_scan = subparsers.add_parser("publish-scan")
    publish_scan.add_argument("--scope", action="append", default=[])
    publish_scan.add_argument("--expected-manifest", required=True)
    publish_scan.add_argument("--output", required=True)

    render = subparsers.add_parser("render-result")
    render.add_argument("--receipt", action="append", default=[])
    render.add_argument("--xunit", nargs=2, action="append", default=[])
    render.add_argument("--counts", action="append", default=[])
    render.add_argument("--skip-reconciliation", required=True)
    render.add_argument("--restore", required=True)
    render.add_argument("--output", required=True)

    inventory = subparsers.add_parser("inventory")
    inventory.add_argument("--root", required=True)
    inventory.add_argument("--output", required=True)
    inventory.add_argument("--manifest", required=True)
    inventory.add_argument("--binding", required=True)
    inventory.add_argument("--approval", required=True)
    inventory.add_argument("--expected-manifest", required=True)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    dispatch = {
        "run": command_run,
        "reconcile-skips": command_reconcile,
        "restore": command_restore,
        "publish-scan": command_publish_scan,
        "render-result": command_render,
        "inventory": command_inventory,
    }
    try:
        args.execution_gate = validate_execution_gate(args)
        return dispatch[args.subcommand](args)
    except EvidenceError as error:
        output = getattr(args, "output", None)
        if output:
            write_json(
                Path(output),
                {
                    "schema": "CANARY-001-QEF-FAILURE-v9",
                    "commandID": {
                        "reconcile-skips": "P01V9",
                        "restore": "P02V9",
                        "render-result": "P03V9",
                        "publish-scan": "P04V9",
                        "inventory": "P05V9",
                    }.get(args.subcommand, args.subcommand),
                    "endTime": now(),
                    "exitCode": 99,
                    "reason": "evidence-tool-failure",
                },
            )
        print(f"QEF_TOOL_ERROR: {error}", file=sys.stderr)
        return 99
    except Exception as error:
        output = getattr(args, "output", None)
        if output:
            write_json(
                Path(output),
                {
                    "schema": "CANARY-001-QEF-FAILURE-v9",
                    "commandID": args.subcommand,
                    "endTime": now(),
                    "exitCode": 100,
                    "reason": "unexpected-evidence-tool-failure",
                },
            )
        print(f"QEF_TOOL_UNEXPECTED: {type(error).__name__}: {error}", file=sys.stderr)
        return 100


if __name__ == "__main__":
    raise SystemExit(main())
