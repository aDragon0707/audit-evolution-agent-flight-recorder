# Longju Evolution Card

Public-safe example based on the Longju SACP Operator path.

```yaml
agent_id: Longju
input_type: benchmark_report_and_receipts
score_delta:
  earlier: 84.0
  latest: 93.0
  gain: 9.0
trusted_evidence:
  - public benchmark screenshot
  - benchmark-result-authority
  - benchmark-brief-latest
weak_dimension:
  - act
  - memory
  - perceive
minimal_patch:
  type: scoring_pattern
  target: six-core-skill scan visibility
  instruction: expose action, memory, and perceive answer skeletons in top-level scan-visible fields
promotion_gate:
  - node syntax check
  - scan dry-run
  - payload audit
  - receipt
  - one approved benchmark only
```

## Field Note

Longju did not improve by switching to a larger model. It improved by making state, evidence, stop rules, and skill patches visible enough to reuse in the next run.
