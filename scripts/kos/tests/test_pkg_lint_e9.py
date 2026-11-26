"""Behavior tests for kos-pkg-lint E9: hardcoded simulator UDID in xcodebuild -destination."""
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "scripts/kos/kos-pkg-lint.py"
START = "a" * 40


def run(text: str) -> subprocess.CompletedProcess:
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / "task-package-impl.md"
        path.write_text(text, encoding="utf-8")
        return subprocess.run(
            [sys.executable, "-I", str(SCRIPT), "--start", START, str(path), "--no-git-check"],
            text=True, capture_output=True, check=False,
        )


UUID_36 = "12345678-1234-1234-1234-123456789abc"
UDID_40 = "a" * 40


class E9HardcodedUDIDTests(unittest.TestCase):
    """E9: xcodebuild -destination with a hardcoded UUID/UDID must be rejected."""

    def test_36char_uuid_in_destination_is_e9(self) -> None:
        """Standard 8-4-4-4-12 UUID in id= is rejected."""
        result = run(
            f'xcodebuild -scheme "Universe Keyboard" test'
            f' -destination "platform=iOS Simulator,id={UUID_36}"\n'
        )
        self.assertIn("E9", result.stdout, result.stdout)
        self.assertEqual(result.returncode, 1)

    def test_40char_hex_udid_in_destination_is_e9(self) -> None:
        """40-hex-char UDID in id= is rejected."""
        result = run(
            f'xcodebuild -scheme "Universe Keyboard" test'
            f' -destination "platform=iOS Simulator,id={UDID_40}"\n'
        )
        self.assertIn("E9", result.stdout, result.stdout)
        self.assertEqual(result.returncode, 1)

    def test_kos_sim_udid_variable_is_allowed(self) -> None:
        """id=$KOS_SIM_UDID must NOT trigger E9."""
        result = run(
            'xcodebuild -scheme "Universe Keyboard" test'
            ' -destination "platform=iOS Simulator,id=$KOS_SIM_UDID"\n'
        )
        self.assertNotIn("E9", result.stdout, result.stdout)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_mixed_variable_and_hardcoded_ids_are_rejected(self) -> None:
        """A variable in a destination must not hide a hardcoded id."""
        for variable in ("$KOS_SIM_UDID", "${KOS_SIM_UDID}"):
            for fixed in (UUID_36, UDID_40):
                for ids in (f"id={variable},id={fixed}", f"id={fixed},id={variable}"):
                    with self.subTest(variable=variable, fixed=fixed, ids=ids):
                        result = run(f'xcodebuild test -destination "platform=iOS Simulator,{ids}"\n')
                        self.assertIn("E9 ", result.stdout, result.stdout)
                        self.assertEqual(result.returncode, 1, result.stdout)

    def test_name_based_destination_is_allowed(self) -> None:
        """name= destinations must NOT trigger E9."""
        result = run(
            'xcodebuild -scheme "Universe Keyboard" test'
            ' -destination "platform=iOS Simulator,name=iPhone 15"\n'
        )
        self.assertNotIn("E9", result.stdout, result.stdout)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_e9_message_mentions_sim_slot(self) -> None:
        """E9 error message must reference kos-sim-slot.py."""
        result = run(
            f'xcodebuild -scheme "Universe Keyboard" test'
            f' -destination "platform=iOS Simulator,id={UUID_36}"\n'
        )
        self.assertIn("kos-sim-slot.py", result.stdout, result.stdout)

    def test_non_xcodebuild_command_uuid_is_not_e9(self) -> None:
        """UUID in a non-xcodebuild command must NOT trigger E9."""
        result = run(
            f'echo "udid={UUID_36}"\n'
        )
        self.assertNotIn("E9 ", result.stdout, result.stdout)

    def test_e1_to_e8_unaffected_by_e9_addition(self) -> None:
        """E1–E8 regression: wrong context SHA still fires E1."""
        wrong = "c" * 40
        result = run(f"起点提交 {wrong}\n")
        self.assertIn("E1 ", result.stdout, result.stdout)
        self.assertEqual(result.returncode, 1)

    def test_uppercase_uuid_in_destination_is_e9(self) -> None:
        """Case-insensitive: uppercase hex UUID in id= is also rejected."""
        uuid_upper = "AABBCCDD-AABB-AABB-AABB-AABBCCDDEEFF"
        result = run(
            f'xcodebuild -scheme "Universe Keyboard" test'
            f' -destination "platform=iOS Simulator,id={uuid_upper}"\n'
        )
        self.assertIn("E9", result.stdout, result.stdout)
        self.assertEqual(result.returncode, 1)

    def test_destination_without_id_is_allowed(self) -> None:
        """-destination without an id= field must NOT trigger E9."""
        result = run(
            'xcodebuild -scheme "Universe Keyboard" test'
            ' -destination "platform=iOS Simulator,OS=17.0"\n'
        )
        self.assertNotIn("E9 ", result.stdout, result.stdout)

    def test_kos_sim_udid_braced_is_allowed(self) -> None:
        """id=${KOS_SIM_UDID} (braced form) must NOT trigger E9."""
        result = run(
            'xcodebuild -scheme "Universe Keyboard" test'
            ' -destination "platform=iOS Simulator,id=${KOS_SIM_UDID}"\n'
        )
        self.assertNotIn("E9", result.stdout, result.stdout)
        self.assertEqual(result.returncode, 0, result.stdout)


if __name__ == "__main__":
    unittest.main()
