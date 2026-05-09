---
name: audit-evolution
displayName: Audit Evolution
description: Turn any agent run record, benchmark report, worklog, task output, failure log, handoff note, or user feedback into a compact audit snapshot, evolution card, minimal skill patch, verification gate, and field note so agents improve after each run.
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

让 Agent 每跑一轮，都变得更聪明。

当 Agent 完成任务、跑完 benchmark、写完 worklog、超时、漂移、失败，或收到用户反馈时，使用这个 skill。

目标不是写更多日志，而是把一次运行变成下一轮可复用的能力提升。

## 输入

可以输入任意一种：

```text
benchmark_report
worklog
task_output
failure_log
handoff_note
user_feedback
```

## 必须输出

始终输出四段：

```text
Snapshot
Evolution Card
Minimal Skill Patch
Field Note
```

## Snapshot

```text
current_goal:
trusted_state:
uncertain_state:
files_read:
next_small_action:
stop_condition:
verification_plan:
```

## Evolution Card

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

## Minimal Skill Patch

只推荐一个最小补丁。

推荐补丁类型：

```text
answer_pattern
field_schema
guardrail
verification_step
retrieval_key
context_stop_rule
handoff_brief
```

避免：

```text
install_many_skills
rewrite_the_system
read_all_logs
trust_stale_state
claim_completed_without_evidence
```

## Field Note

```text
input_summary:
what_changed:
evidence_kept:
evidence_discarded:
next_test:
shareable_claim:
```

## Trust Ledger

每个重要 claim 都要分类：

```text
verified_fact: 当前已验证，或有可复查证据支持
user_feedback: 用户偏好、纠错或反馈
stale_claim: 旧 claim，需要重新验证
model_inference: 模型推断，不是证据
unknown: 当前不知道
```

## Stop Rules

遇到这些情况，停止扩展并写 snapshot：

```text
more_than_5_files_needed
context_pressure_over_70_percent
score_authority_conflict
external_action_required
no_evidence_for_completed_claim
```

## Public-Safe Rules

- 不暴露 API keys、credentials、cookies、私有路径、原始客户数据。
- 写 field note 前先脱敏。
- publish、upload、install、vote、comment、message、spend、official benchmark 等外部动作，必须有人类明确批准。
- 无法验证的 claim 必须标为 `unknown` 或 `stale_claim`。

## 30 秒提示词

```text
Use Audit Evolution.

Input:
<粘贴 benchmark 报告、worklog、任务输出、失败日志或用户反馈>

Return:
1. Snapshot
2. Evolution Card
3. Minimal Skill Patch
4. Field Note

Rules:
- 区分 verified_fact、user_feedback、stale_claim、model_inference、unknown。
- 只推荐一个 next patch。
- 没有 evidence 不许声明 completed。
- 外部动作标记为 human_approval_required。
```
