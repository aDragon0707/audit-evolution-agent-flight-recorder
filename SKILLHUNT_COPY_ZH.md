# SkillHunt 发布文案

## 标题

Audit Evolution: Agent 自进化飞行记录仪

## 一句话

让你的 Agent 每跑一轮，都变得更聪明。

## 简介

Audit Evolution 把一次 Agent 运行记录转成下一轮进化输入。你可以贴入 benchmark 报告、worklog、任务输出、失败日志或用户反馈，它会生成：

1. `Snapshot`: 当前可信状态、未知状态、停止条件。
2. `Evolution Card`: 本轮最该提升的能力维度和证据。
3. `Minimal Skill Patch`: 一个最小可执行 skill 补丁。
4. `Field Note`: 可发社区的测试记录。
5. `Next-Run Bootstrap`: 下一轮启动时必须优先读取或执行的短指令。

它不是只在 Agent 崩溃时救火，而是让 Agent 每一次完成任务后，都能沉淀一个可复用能力。

## 自动触发

装上以后，不应该每次都等用户手动说“Use Audit Evolution”。当出现以下任一事件时，Agent 应该主动调用：

- benchmark 完成。
- 用户指出错误、纠正事实、质疑结论。
- 任务失败、超时、重试、被阻塞。
- 上下文超过 60%。
- 本轮读取文件超过 5 个。
- 输出里出现“大概、可能、我理解为、不确定”等不可靠表达。
- 新增或修改 skill、config、gear、路由、答题范式后。

核心边界是：

```text
自动学习，半自动晋升，人工批准外部动作。
```

Agent 可以自动保存 run record、生成 evolution card、提出 minimal patch、跑本地检查、写 receipt。  
但 publish、upload、install、vote、comment、message、spend、official benchmark 等外部动作必须由人类批准。

## 适合谁

- 正在给 Agent 跑 BotLearn Benchmark 的开发者。
- 想让 Agent 越用越强的个人开发者。
- 做 Agent workflow / skill / prompt / automation 的团队。
- 需要可审计状态、交接和进化记录的人。

## 现场 Demo

我们用 Longju 和 Jobs 两只 Agent 做了测试：

- Jobs: `76.4 -> 78.8 -> 88.8`
- Longju: 后期仍提升到 `93.0`

核心不是单次高分，而是把每轮反馈压成下一轮可执行 skill 修复。
