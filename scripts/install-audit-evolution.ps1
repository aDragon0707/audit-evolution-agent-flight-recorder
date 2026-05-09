param(
  [string]$TargetWorkspace = (Get-Location).Path,
  [ValidateSet("generic", "codex", "openclaw")]
  [string]$Agent = "generic",
  [switch]$NoAgentsUpdate,
  [switch]$Force
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

function Resolve-FullPath {
  param([string]$Path)
  return [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
}

function Copy-Directory {
  param(
    [string]$Source,
    [string]$Destination
  )
  New-Item -ItemType Directory -Force -Path $Destination | Out-Null
  Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
    $target = Join-Path $Destination $_.Name
    if ($_.PSIsContainer) {
      Copy-Directory -Source $_.FullName -Destination $target
    } else {
      Copy-Item -LiteralPath $_.FullName -Destination $target -Force
    }
  }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$workspace = Resolve-FullPath $TargetWorkspace
$skillDir = Join-Path $workspace "skills\audit-evolution"
$hookDir = Join-Path $workspace ".audit-evolution\hooks"
$agentsPath = Join-Path $workspace "AGENTS.md"

if ((Test-Path $skillDir) -and (-not $Force)) {
  throw "Target skill already exists: $skillDir. Re-run with -Force to overwrite."
}

New-Item -ItemType Directory -Force -Path $skillDir | Out-Null

$include = @(
  "SKILL.md",
  "README.md",
  "SKILLHUNT_COPY_ZH.md",
  "FIELD_NOTE_TEMPLATE.md",
  "dirty_log.md",
  "clean_snapshot.md",
  "DESIGN_REVIEW_ZH.md",
  "index.html",
  "agents",
  "assets",
  "examples",
  "scripts"
)

foreach ($name in $include) {
  $source = Join-Path $repoRoot $name
  if (-not (Test-Path $source)) { continue }
  $destination = Join-Path $skillDir $name
  if ((Get-Item $source).PSIsContainer) {
    if (Test-Path $destination) { Remove-Item -LiteralPath $destination -Recurse -Force }
    Copy-Directory -Source $source -Destination $destination
  } else {
    Copy-Item -LiteralPath $source -Destination $destination -Force
  }
}

New-Item -ItemType Directory -Force -Path $hookDir | Out-Null
Copy-Item -LiteralPath (Join-Path $repoRoot "scripts\invoke-audit-evolution-hook.ps1") -Destination (Join-Path $hookDir "invoke-audit-evolution-hook.ps1") -Force
if (Test-Path (Join-Path $repoRoot "scripts\invoke-audit-evolution-hook.sh")) {
  Copy-Item -LiteralPath (Join-Path $repoRoot "scripts\invoke-audit-evolution-hook.sh") -Destination (Join-Path $hookDir "invoke-audit-evolution-hook.sh") -Force
}

$agentsBlock = @(
  '<!-- AUDIT_EVOLUTION_START -->',
  '## Audit Evolution Auto-Use',
  '',
  'Use `skills/audit-evolution/SKILL.md` when any of these happen:',
  '',
  '- The user says: `开始调用 Audit Evolution`, `进化`, `保存`, `暂停`, `跑分`, `继续`, or `详情`.',
  '- A benchmark, scan, profile, worklog, handoff, task, or local test completes.',
  '- The user points out an error, corrects a fact, or questions your conclusion.',
  '- A task fails, times out, retries, gets blocked, or reads more than 5 files.',
  '- Context pressure is over 60%, or your output contains uncertainty language such as "大概", "可能", "我理解为", or "不确定".',
  '- You add or modify a skill, config, gear, route, prompt pattern, or answer pattern.',
  '',
  'Default behavior:',
  '',
  '1. First create or read `.audit-evolution/run-records/latest.md` when available.',
  '2. Output: Evidence Pack, Snapshot, Evolution Card, Memory Ledger Entry, Minimal Skill Patch Proposal, Field Note, Next-Run Bootstrap, Short Command Menu.',
  '3. Do not publish, upload, install, vote, comment, message, spend, claim, or run official benchmark without explicit human approval.',
  '4. If you do not know where to save memory, use `write_target: proposed_only`.',
  '',
  'Hook examples:',
  '',
  'Windows:',
  '```powershell',
  'powershell -ExecutionPolicy Bypass -File .\.audit-evolution\hooks\invoke-audit-evolution-hook.ps1 -EventType task_failed_or_timeout_or_retry -Summary "任务失败，需要审计"',
  '```',
  '',
  'macOS/Linux:',
  '```bash',
  'bash ./.audit-evolution/hooks/invoke-audit-evolution-hook.sh --event task_failed_or_timeout_or_retry --summary "任务失败，需要审计"',
  '```',
  '<!-- AUDIT_EVOLUTION_END -->'
) -join [Environment]::NewLine

if (-not $NoAgentsUpdate) {
  if (Test-Path $agentsPath) {
    $existing = Get-Content -LiteralPath $agentsPath -Raw -Encoding UTF8
    if ($existing -match "<!-- AUDIT_EVOLUTION_START -->[\s\S]*?<!-- AUDIT_EVOLUTION_END -->") {
      $updated = [regex]::Replace($existing, "<!-- AUDIT_EVOLUTION_START -->[\s\S]*?<!-- AUDIT_EVOLUTION_END -->", $agentsBlock.Trim())
    } else {
      $updated = $existing.TrimEnd() + "`r`n" + $agentsBlock
    }
    Set-Content -LiteralPath $agentsPath -Value $updated -Encoding UTF8
  } else {
    Set-Content -LiteralPath $agentsPath -Value ("# AGENTS.md`r`n" + $agentsBlock) -Encoding UTF8
  }
}

$quickstartPath = Join-Path $workspace ".audit-evolution\QUICKSTART_ZH.md"
$quickstart = @(
  '# Audit Evolution Quickstart',
  '',
  '已安装到：',
  '',
  '```text',
  $skillDir,
  '```',
  '',
  '立刻复制给你的 Agent：',
  '',
  '```text',
  '开始调用 Audit Evolution。',
  '',
  '请先读取 skills/audit-evolution/SKILL.md；如果存在 .audit-evolution/run-records/latest.md，也优先读取它。',
  '目标：检查最近一次任务后，是否应该继续自进化。',
  '边界：先审计和提出建议，不要直接修改系统，不要执行外部动作。',
  '```',
  '',
  '短指令：',
  '',
  '```text',
  '进化 / 保存 / 暂停 / 跑分 / 继续 / 详情',
  '```'
) -join [Environment]::NewLine
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $quickstartPath) | Out-Null
Set-Content -LiteralPath $quickstartPath -Value $quickstart -Encoding UTF8

$result = [ordered]@{
  status = "installed"
  agent = $Agent
  target_workspace = $workspace
  skill_dir = $skillDir
  agents_md = if ($NoAgentsUpdate) { "skipped" } else { $agentsPath }
  hook_dir = $hookDir
  quickstart = $quickstartPath
}

$result | ConvertTo-Json -Depth 4
