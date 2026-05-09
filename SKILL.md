---
name: audit-evolution
displayName: Audit Evolution
description: Turn any agent run record, benchmark report, worklog, task output, failure log, or handoff note into a compact audit snapshot, evolution card, minimal skill patch, verification gate, and field note so agents improve after each run.
category: agent-self-evolution
skillType: prompt
tags: [agent, self-evolution, audit, benchmark, worklog, handoff, skill, field-note, sacp]
version: 0.1.0
author: Solo AI Company OS
dimensions: [memory, autonomy, reason, guard, act, perceive]
capabilityClasses: [state_memory, autonomy_workflow, reasoning_review, safety_guard, action_tool, perception_tool]
evidenceFiles: [README.md, dirty_log.md, clean_snapshot.md, index.html]
smokeTests: [snapshot_from_run_record, evolution_card_from_benchmark, minimal_skill_patch_gate, field_note_generation]
coreSkill: true
---

# Audit Evolution

Use this skill after an agent completes a task, runs a benchmark, writes a worklog, times out, drifts, or receives user feedback.

The goal is not to write more logs. The goal is to turn one run into the next reusable improvement.

## Inputs

Accept any one of these:

```text
benchmark_report
worklog
task_output
failure_log
handoff_note
user_feedback
```

## Required Output

Always return these four sections.

```text
Snapshot
Evolution Card
Minimal Skill Patch
Field Note
```

### Snapshot

```text
current_goal:
trusted_state:
uncertain_state:
files_read:
next_small_action:
stop_condition:
verification_plan:
```

### Evolution Card

```yaml
score_delta:
  previous:
  current:
  gain:
weak_dimension:
  - perceive | reason | act | memory | guard | autonomy
trusted_evidence:
stale_or_uncertain_claims:
minimal_patch:
promotion_gate:
  - dry_run
  - payload_audit
  - receipt
  - next_test
```

### Minimal Skill Patch

Recommend exactly one smallest useful patch.

Good patch types:

```text
answer_pattern
field_schema
guardrail
verification_step
retrieval_key
context_stop_rule
handoff_brief
```

Avoid:

```text
install_many_skills
rewrite_the_system
read_all_logs
trust_stale_state
claim_completed_without_evidence
```

### Field Note

```text
input_summary:
what_changed:
evidence_kept:
evidence_discarded:
next_test:
shareable_claim:
```

## Trust Ledger

Classify every important claim:

```text
verified_fact: checked now or backed by reproducible evidence
user_feedback: user preference or correction
stale_claim: old claim needing revalidation
model_inference: reasoning, not evidence
unknown: not known in this run
```

## Stop Rules

Stop and write a snapshot when:

```text
more_than_5_files_needed
context_pressure_over_70_percent
score_authority_conflict
external_action_required
no_evidence_for_completed_claim
```

## Public-Safe Rules

- Do not expose API keys, credentials, cookies, private paths, or raw customer data.
- Redact sensitive evidence before writing field notes.
- External actions such as publish, upload, install, vote, comment, message, spend, and official benchmark require explicit human approval.
- If a claim cannot be verified, mark it `unknown` or `stale_claim`.

## 30-Second Prompt

```text
Use Audit Evolution.

Input:
<paste benchmark report, worklog, task output, failure log, or user feedback>

Return:
1. Snapshot
2. Evolution Card
3. Minimal Skill Patch
4. Field Note

Rules:
- Separate verified_fact, user_feedback, stale_claim, model_inference, and unknown.
- Recommend exactly one next patch.
- Do not claim completion without evidence.
- Mark external actions as human_approval_required.
```
