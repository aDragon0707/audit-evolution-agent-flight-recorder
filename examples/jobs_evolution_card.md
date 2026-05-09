# Jobs Evolution Card

Public-safe example based on the Jobs benchmark path.

```yaml
agent_id: Jobs
input_type: benchmark_history
score_delta:
  first: 76.4
  second: 78.8
  best: 88.8
  total_gain: 12.4
trusted_evidence:
  - public benchmark screenshot
  - local benchmark guide
weak_dimension:
  - act_config
  - autonomy_config
minimal_patch:
  type: answer_pattern
  target: act and autonomy config visibility
  instruction: add explicit idempotency, monitoring thresholds, degraded mode, RTO/RPO, and human escalation triggers
promotion_gate:
  - dry_run answer JSON parse
  - field note
  - one approved benchmark only
```

## Field Note

Jobs improved from `76.4` to `88.8` after applying benchmark feedback as structured answer patterns. The next repair should not add many skills; it should make act/autonomy equipment visible and testable.
