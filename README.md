# Audit Evolution

**让你的 Agent 每跑一轮，都变得更聪明。**

Audit Evolution 是一个 Agent 自进化飞行记录仪。用户只要说一句“开始调用 Audit Evolution”，Agent 就会先从当前上下文和允许访问的文件里自动寻找运行记录、反馈和失败证据，再把它们转成下一轮可执行的进化输入。

它会主动寻找：

- BotLearn 跑分报告
- worklog / 工作记录
- 任务输出
- 失败日志
- 用户反馈
- handoff / 交接记录
- 最近修改过的 skill / config / gear

它会输出：

- `Evidence Pack`: 找到了哪些证据、缺了哪些证据、可信度如何。
- `Snapshot`: 当前可信状态、未知状态、停止条件。
- `Evolution Card`: 本轮最该提升的能力维度和证据。
- `Minimal Skill Patch Proposal`: 一个最小可执行 skill 补丁提案。
- `Field Note`: 可发社区的测试记录。
- `Next-Run Bootstrap`: 下一轮启动时必须优先读取或执行的短指令。

一句话传播：

```text
说一句“开始调用 Audit Evolution”，让 Agent 自己找证据、审计自己、提出下一轮进化方案。
```

## 为什么做这个

很多 Agent 的问题不是模型不够聪明，而是运行状态不可见。

常见问题：

- 历史分数、当前分数、清洁复测分数混在一起。
- 任务边界已经不清楚，还继续读更多文件。
- 把过期 claim 当成 verified fact。
- 完成了一次任务，却没有沉淀成可复用 skill。
- 失败后只会重试，不能生成下一轮最小修复。

Audit Evolution 给 Agent 一个固定进化回路：

```text
事件 -> 自动找证据 -> Evidence Pack -> Snapshot -> Evolution Card -> Patch Proposal -> 人类批准 -> 本地测试 -> Field Note -> 下一轮启动指令
```

## 三阶段工作流

### 1. start_audit

先找证据，不修改系统。  
Agent 应该从当前上下文和允许访问的文件里寻找最近任务输出、用户反馈、失败/超时/重试记录、benchmark、worklog、handoff、receipt、skill/config/gear 修改记录。

### 2. propose_evolution

生成审计结果和进化建议。  
重点是一个最小补丁提案，而不是重写整个系统。

### 3. ask_human_approval

最后必须问人类是否批准开始进化：

```text
是否批准开始进化？
1. 只保存审计结果
2. 应用最小补丁并本地测试
3. 暂停，等待更多证据
```

在得到批准前，Agent 不应该修改 skill、config、gear，也不应该执行任何外部动作。

## 自动触发规则

装上 skill 以后，不应该每次都等用户说“Use Audit Evolution”。当出现以下任一事件时，Agent 应该主动调用 Audit Evolution：

1. benchmark 完成。
2. 用户指出错误、纠正事实、质疑结论。
3. 任务失败、超时、重试、被阻塞。
4. 上下文超过 60%。
5. 本轮读取文件超过 5 个。
6. 输出里出现“大概、可能、我理解为、不确定”等不可靠表达。
7. 新增或修改 skill、config、gear、路由、答题范式后。

如果你的 Agent 框架支持 hook / wrapper / runtime guard，就把这些事件接到任务结束、上下文检查、外部动作前检查和 skill 修改后的检查点。  
如果暂时不支持 hook，也可以要求 Agent 在触发事件后主动写一条 run record，再调用本 skill。

安全边界很简单：

```text
自动学习，半自动晋升，人工批准外部动作。
```

Agent 可以自动生成进化卡片和本地补丁候选，但不能自动发布、上传、安装、投票、评论、花钱或跑官方 benchmark。

## 真实进化证据

下面是两个 Agent 的公开安全证据：

![Jobs evolution path](assets/jobs-evolution.png)

![Longju evolution path](assets/longju-evolution.png)

观察到的路径：

- Jobs: `76.4 -> 78.8 -> 88.8`，单日提升 `+12.4`。
- Longju: 后期仍提升到 `93.0`，最近提升 `+9.0`。

重点不是一次高分，而是这套循环能把每轮反馈转成下一轮 skill 修复。

## 30 秒体验

把下面这段复制给你的 Agent：

```text
开始调用 Audit Evolution。

请先从当前上下文和允许访问的文件里自动寻找最近的任务记录、用户反馈、失败/超时/重试记录、benchmark 或评测结果、worklog、handoff、receipt、最近修改过的 skill/config/gear。

Return:
1. Evidence Pack
2. Snapshot
3. Evolution Card
4. Minimal Skill Patch Proposal
5. Field Note
6. Next-Run Bootstrap
7. 是否批准开始进化？

Rules:
- 区分 verified_fact、user_feedback、stale_claim、model_inference、unknown。
- 最多读取 5 个最相关文件。
- 没有 evidence 不许声明 completed。
- 只推荐一个 next skill patch proposal。
- 如果需要外部动作，标记为 human_approval_required。
- 未经批准不得修改 skill/config/gear。
```

## 输出格式

### Evidence Pack

```text
evidence_found:
evidence_missing:
files_or_context_checked:
authority_order:
privacy_notes:
audit_confidence:
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

### Field Note

```text
input_summary:
what_changed:
evidence_kept:
evidence_discarded:
next_test:
shareable_claim:
```

### Next-Run Bootstrap

```text
read_first:
do_first:
avoid:
verify:
stop_if:
```

## 离线 Demo

直接用浏览器打开：

```text
index.html
```

文件结构：

```text
index.html
dirty_log.md
clean_snapshot.md
assets/jobs-evolution.png
assets/longju-evolution.png
examples/
```

推荐先看：

```text
examples/closed_loop_case_zh.md
```

它展示完整闭环：一句话触发、Agent 自己找证据、生成进化提案、最后等待人类批准。

## 安全边界

不要把这些内容贴进 Audit Evolution：

- API key
- credentials
- cookies
- 原始客户数据
- 私有路径
- 未公开策略

如果证据缺失，必须标记为 `unknown`，不要猜。

## 名字说明

- 产品名：`Audit Evolution`
- 现场比喻：`Agent Flight Recorder`
- 协议内核：`SACP`

SACP 是一个轻量状态、证据、交接、晋升协议。用户不需要先理解协议，也能直接使用这个 skill。
