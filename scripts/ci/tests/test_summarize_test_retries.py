import importlib.util
import unittest
from pathlib import Path

path = Path(__file__).resolve().parents[1] / 'summarize_test_retries.py'
spec = importlib.util.spec_from_file_location('summarize_test_retries', path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

# Result lines copied from the local xcodebuild retry run.
FAIL_ONCE = "Test Case '-[UniverseKeyboardTests.CIRetryTemporaryTests testFailsOnce]' failed (0.002 seconds)."
PASS_ONCE = "Test Case '-[UniverseKeyboardTests.CIRetryTemporaryTests testFailsOnce]' passed (0.001 seconds)."
FAIL_ALWAYS = "Test Case '-[UniverseKeyboardTests.CIRetryTemporaryTests testAlwaysFails]' failed (0.450 seconds)."
FAIL_AGAIN = "Test Case '-[UniverseKeyboardTests.CIRetryTemporaryTests testAlwaysFails]' failed (0.003 seconds)."

class RetrySummaryTests(unittest.TestCase):
    def test_empty_or_unrelated(self):
        for text in ('', 'Build succeeded'):
            self.assertEqual(module.summarize(text), ([], []))

    def test_no_retry(self):
        self.assertEqual(module.summarize(PASS_ONCE), ([], []))

    def test_retry_passes(self):
        self.assertEqual(module.summarize(FAIL_ONCE + '\n' + PASS_ONCE), (['UniverseKeyboardTests.CIRetryTemporaryTests.testFailsOnce'], []))

    def test_retry_fails(self):
        self.assertEqual(module.summarize(FAIL_ALWAYS + '\n' + FAIL_AGAIN), ([], ['UniverseKeyboardTests.CIRetryTemporaryTests.testAlwaysFails']))
