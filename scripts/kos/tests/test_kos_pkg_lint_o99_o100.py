"""Behavior checks for packet hash and command guardrails."""
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / 'scripts/kos/kos-pkg-lint.py'
START = subprocess.check_output(['git', '-C', str(ROOT), 'rev-parse', 'HEAD'], text=True).strip()


def lint(text):
    with tempfile.TemporaryDirectory() as tmp:
        packet = Path(tmp) / 'packet.md'
        packet.write_text(text, encoding='utf-8')
        return subprocess.run([sys.executable, '-I', str(SCRIPT), '--start', START, str(packet)], capture_output=True, text=True).stdout


class PacketHardeningTests(unittest.TestCase):
    def test_short_explicit_sha_is_rejected(self):
        self.assertIn('E9', lint('SHA-256 `abcdef123456`\n'))

    def test_existing_file_hash_mismatch_is_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / 'input.md'
            source.write_text('input', encoding='utf-8')
            self.assertIn('E9', lint(f'输入 `{source}`（SHA-256 `{"a" * 64}`）\n'))

    def test_missing_allowed_file_is_rejected(self):
        self.assertIn('E10', lint('## 允许修改\n- `scripts/kos/not-a-real-script.py`\n'))

    def test_multiline_handoff_requires_arguments(self):
        self.assertIn('E10', lint('```bash\npython3 scripts/kos/kos_handoff.py relay-quality \\\n  --packet packet.md\n```\n'))

    def test_quality_focus_format_is_checked(self):
        self.assertIn('E10', lint('包头档位：`code-fix`\n**复核重点**：\n1. missing indentation\n'))
