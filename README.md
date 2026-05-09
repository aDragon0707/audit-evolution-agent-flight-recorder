# Audit Evolution

Agent Flight Recorder for self-evolving agents.

中文一句话：**让你的 Agent 每跑一轮，都变得更聪明。**

Audit Evolution 不是崩溃急救包，而是 Agent 自进化飞行记录仪。它把跑分报告、任务记录、失败日志、普通输出，转成下一轮可执行的进化卡片。

适合现场传播的一句话：

```text
Paste one agent run. Get a snapshot, an evolution card, a minimal skill patch, and a field note.
```

Audit Evolution turns any agent run into the next improvement loop. It can read a benchmark report, worklog, task output, failure log, or handoff note, then produce a compact snapshot, an evolution card, a minimal skill patch, and a field note for community testing.

## Why This Exists

Most agents do not fail only because the base model is weak. They fail because their operating state is invisible:

- They mix historical scores with current authority.
- They read more files after the task boundary is already unclear.
- They treat stale claims as verified facts.
- They finish one task but do not convert the experience into a reusable skill.

Audit Evolution gives agents a repeatable post-run loop:

```text
Run record -> Snapshot -> Evolution Card -> Minimal Skill Patch -> Verification Gate -> Field Note
```

## Demo Proof

These screenshots are public-safe BotLearn evidence from two agents trained with this method:

![Jobs evolution path](assets/jobs-evolution.png)

![Longju evolution path](assets/longju-evolution.png)

Observed paths:

- Jobs: `76.4 -> 78.8 -> 88.8`, single-day gain `+12.4`.
- Longju: later-stage improvement ending at `93.0`, with latest gain `+9.0`.

The point is not a single lucky high score. The point is a reusable loop that turns feedback into the next skill repair.

## What The Skill Produces

Given any agent run record, Audit Evolution returns:

```text
Snapshot:
  current_goal
  trusted_state
  uncertain_state
  files_read
  next_small_action
  stop_condition
  verification_plan

Evolution Card:
  score_delta
  weak_dimension
  evidence
  minimal_patch
  promotion_gate

Field Note:
  input
  what_changed
  evidence_kept
  evidence_discarded
  next_test
```

## 30-Second Try Prompt

Paste this into your agent after any benchmark, task run, or failed attempt:

```text
Use Audit Evolution.

Input:
<paste my benchmark report, worklog, task output, or failure log here>

Return:
1. Snapshot
2. Evolution Card
3. Minimal Skill Patch
4. Field Note

Rules:
- Separate verified_fact, user_feedback, stale_claim, model_inference, and unknown.
- Do not claim completion without evidence.
- Recommend only one next skill patch.
- If an external action is needed, mark it as human_approval_required.
```

## Offline Demo

Open `index.html` directly in a browser. It is fully offline.

Files:

```text
index.html
dirty_log.md
clean_snapshot.md
assets/jobs-evolution.png
assets/longju-evolution.png
```

## Public-Safe Boundary

Audit Evolution should not ingest private keys, credentials, cookies, raw customer data, private directories, or unpublished strategy. Redact first, then produce the snapshot.

When evidence is missing, the skill must say `unknown` instead of guessing.

## Name

Product name: `Audit Evolution`

Demo metaphor: `Agent Flight Recorder`

Protocol kernel: `SACP`, a lightweight state, evidence, handoff, and promotion pattern.
