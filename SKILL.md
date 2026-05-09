---
name: audit-evolution
displayName: Audit Evolution
description: Automatically trigger after agent runs, benchmark reports, worklogs, task outputs, failures, handoffs, user corrections, context pressure, or skill/config changes, then turn the run record into a compact audit snapshot, evolution card, minimal skill patch, verification gate, and field note so agents improve after each run.
category: agent-self-evolution
skillType: prompt
tags: [agent, self-evolution, audit, benchmark, worklog, handoff, skill, field-note, sacp]
version: 0.1.1
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

## 自动触发规则

不要只等用户手动说 `Use Audit Evolution`。当出现以下任一事件时，Agent 必须主动调用 Audit Evolution：

```text
benchmark_completed
user_corrected_agent
task_failed_or_timeout_or_retry
context_over_60_percent
more_than_5_files_read
uncertainty_language_detected
skill_config_or_gear_changed
```

对应的人类可读触发条件：

1. benchmark 完成。
2. 用户指出错误、纠正事实、质疑结论。
3. 任务失败、超时、重试、被阻塞。
4. 上下文超过 60%。
5. 本轮读取文件超过 5 个。
6. 输出里出现“大概、可能、我理解为、不确定”等不可靠表达。
7. 新增或修改 skill、config、gear、路由、答题范式后。

如果当前环境支持 hook / wrapper / runtime guard，把这些事件接到任务结束、上下文检查、外部动作前检查、skill 修改后的检查点。  
如果当前环境不支持自动 hook，Agent 也必须在这些事件后主动生成一次 run record，再调用本 skill。

## 自动进化闭环

```text
event -> run_record -> Snapshot -> Evolution Card -> Minimal Skill Patch -> Verification Gate -> Field Note -> next_run_bootstrap
```

自动化边界：

- 可以自动保存 run record、生成 evolution card、提出 minimal patch、跑本地 dry-run、写 receipt。
- 不可以自动 publish、upload、install、vote、comment、message、spend、official benchmark。
- 外部动作只能输出 `human_approval_required`。

没有现成 run record 时，先写一个最小记录：

```text
event_type:
current_goal:
what_happened:
evidence_kept:
evidence_missing:
files_read:
context_pressure:
user_feedback:
next_small_action:
```

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

如果是自动触发，还要额外输出：

```text
Next-Run Bootstrap
```

内容是下一轮 Agent 启动时必须优先读取或执行的 3-5 条最短指令。

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

## Next-Run Bootstrap

```text
read_first:
do_first:
avoid:
verify:
stop_if:
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
