param(
  [ValidateSet(
    "manual",
    "benchmark_completed",
    "user_corrected_agent",
    "task_failed_or_timeout_or_retry",
    "context_over_60_percent",
    "more_than_5_files_read",
    "uncertainty_language_detected",
    "skill_config_or_gear_changed"
  )]
  [string]$EventType = "manual",

  [string]$WorkspacePath = (Get-Location).Path,
  [string]$Summary = "",
  [int]$FilesRead = 0,
  [int]$ContextPercent = 0,
  [string]$EvidencePath = "",
  [string]$UserFeedback = "",
  [switch]$NoWrite
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

function Resolve-FullPath {
  param([string]$Path)
  $full = [System.IO.Path]::GetFullPath($Path)
  return $full.TrimEnd('\')
}

$workspace = Resolve-FullPath $WorkspacePath
$hookRoot = Join-Path $workspace ".audit-evolution"
$runDir = Join-Path $hookRoot "run-records"
$now = Get-Date
$stamp = $now.ToString("yyyyMMdd_HHmmss")
$recordPath = Join-Path $runDir ("run_{0}_{1}.md" -f $stamp, $EventType)
$latestPath = Join-Path $runDir "latest.md"

$summaryText = if ($Summary.Trim()) { $Summary.Trim() } else { "No summary provided. Agent should inspect current context and allowed files." }
$feedbackText = if ($UserFeedback.Trim()) { $UserFeedback.Trim() } else { "none" }
$evidenceText = if ($EvidencePath.Trim()) { $EvidencePath.Trim() } else { "unknown" }

$record = @(
  '---',
  'type: audit_evolution_run_record',
  'protocol: SACP/0.1',
  "event_type: $EventType",
  "created_at: $($now.ToString("s"))",
  "workspace: ""$workspace""",
  "files_read: $FilesRead",
  "context_percent: $ContextPercent",
  "evidence_path: ""$evidenceText""",
  'status: audit_needed',
  '---',
  '',
  '# Audit Evolution Run Record',
  '',
  '## Event',
  '',
  $EventType,
  '',
  '## What Happened',
  '',
  $summaryText,
  '',
  '## Evidence Candidate',
  '',
  $evidenceText,
  '',
  '## User Feedback',
  '',
  $feedbackText,
  '',
  '## Required Agent Action',
  '',
  '```text',
  '开始调用 Audit Evolution。',
  '',
  '请优先读取这个 run record，并在当前上下文和允许访问的文件里寻找最近任务记录、用户反馈、失败/超时/重试记录、benchmark 或评测结果、worklog、handoff、receipt、最近修改过的 skill/config/gear。',
  '',
  '必须输出：',
  '1. Evidence Pack',
  '2. Snapshot',
  '3. Evolution Card',
  '4. Memory Ledger Entry',
  '5. Minimal Skill Patch Proposal',
  '6. Field Note',
  '7. Next-Run Bootstrap',
  '8. Short Command Menu',
  '',
  '边界：',
  '- 最多读取 5 个最相关文件。',
  '- 没有 evidence 不许声明 completed。',
  '- 未经批准不得 publish/upload/install/vote/comment/message/spend/official benchmark。',
  '- 如果不知道 Memory Ledger 写到哪里，write_target 使用 proposed_only。',
  '```',
  '',
  '## Short Command Menu',
  '',
  '```text',
  '你可以直接回复：',
  '进化 / 保存 / 暂停 / 跑分 / 继续 / 详情',
  '```'
) -join [Environment]::NewLine

if (-not $NoWrite) {
  New-Item -ItemType Directory -Force -Path $runDir | Out-Null
  Set-Content -LiteralPath $recordPath -Value $record -Encoding UTF8
  Set-Content -LiteralPath $latestPath -Value $record -Encoding UTF8
}

$result = [ordered]@{
  event_type = $EventType
  workspace = $workspace
  record_path = if ($NoWrite) { "not_written" } else { $recordPath }
  latest_path = if ($NoWrite) { "not_written" } else { $latestPath }
  next_prompt = "开始调用 Audit Evolution。请优先读取 .audit-evolution/run-records/latest.md。"
}

$result | ConvertTo-Json -Depth 4
