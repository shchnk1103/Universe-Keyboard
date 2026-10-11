# AUTH-TYPO-CORRECTION-002-F01-FIXED-INTEGRATION-REVIEW-001

Policy version 1.0.0

```kos-record
{
  "schema_version": {
    "major": 1,
    "minor": 0
  },
  "updated_at": "2026-10-11",
  "record_id": "AUTH-TYPO-CORRECTION-002-F01-FIXED-INTEGRATION-REVIEW-001",
  "record_type": "authorization",
  "decision_source": "Human continue previous recommended bounded independent delta review",
  "status": "live",
  "authorization": {
    "action": "one_independent_f01_delta_review",
    "target": "typo-correction-002-f01-fixed-integration-review-001",
    "scope": "One independent C1-C4 delta review of frozen five-path candidate/CI packet",
    "issuer_role": "Human Product Lead",
    "live_at": "2026-10-11T03:04:07.917071+00:00",
    "consumed_at": "2026-10-11T03:04:07.917071+00:00",
    "consumption_state": "consumed",
    "execution_state": "exhausted_success",
    "packet_sha256": "4c46f4f1ae270f37b6a609aba741391c32ac75a080b27395451bd1e77b10e654",
    "budget": {
      "tool_calls": 16,
      "input_tokens": 30000,
      "output_tokens": 15000,
      "elapsed_seconds": 900,
      "checkpoints": [
        "after identity",
        "half budget"
      ],
      "extension_owner": "Human Product Lead"
    },
    "publication": "not authorized",
    "result": {
      "packet_sha256": "4c46f4f1ae270f37b6a609aba741391c32ac75a080b27395451bd1e77b10e654",
      "report_path": "docs/reviews/TYPO-CORRECTION-002-F01-FIXED-INTEGRATION-REVIEW-001-quality-review-r1.original.json",
      "report_sha256": "6fcd8f8bcc6807d6b20b1c0bb51dd25ce1fd6f928c80fdb59d759133f5534552",
      "usage_path": "docs/reviews/TYPO-CORRECTION-002-F01-FIXED-INTEGRATION-REVIEW-001-quality-usage-r1.json",
      "usage_sha256": "ee391e6bced99f91e5cfb3c538e8085180f1a85a7596ded4edfb46404054155f",
      "review_runtime": "reused /root/p2_existing_run_quality_r1, independent F01 lane round1",
      "coverage": {
        "C1": "covered",
        "C2": "covered",
        "C3": "covered_with_executor_evidence_limits",
        "C4": "covered_with_disclosed_AUTH_order_boundary"
      },
      "outcome": "Scoped Pass with conditions",
      "blocking_code_findings": 0,
      "source5_matched_at_archive": true,
      "tool_calls": 12,
      "elapsed_seconds": 210.302983,
      "source_publication": "not authorized",
      "parent_lifecycle": "Active",
      "report_presentation_path": "docs/reviews/TYPO-CORRECTION-002-F01-FIXED-INTEGRATION-REVIEW-001-quality-review-r1.md",
      "report_presentation_sha256": "d54b2c6daf07e7b47379840a5e1d692edc15e39ad4404d6945e62e8b22a747e4",
      "report_original_decoded_sha256": "00f6c71ac7300dd3bc59b78b335deef7352205d4d9c3652aa371037bc828a576",
      "report_archive_encoding": "base64"
    }
  }
}
```
