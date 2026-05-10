param(
  [string]$OutputDir = (Join-Path (Get-Location).Path "dist"),
  [string]$Version = ""
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$skillPath = Join-Path $repoRoot "SKILL.md"

if (-not (Test-Path $skillPath)) {
  throw "Missing SKILL.md at $skillPath"
}

if (-not $Version) {
  $skillText = Get-Content -LiteralPath $skillPath -Raw -Encoding UTF8
  $match = [regex]::Match($skillText, "(?m)^version:\s*(.+?)\s*$")
  if (-not $match.Success) {
    throw "Could not find version in SKILL.md"
  }
  $Version = $match.Groups[1].Value.Trim()
}

$packageName = "audit-evolution-$Version"
$stagingRoot = Join-Path $OutputDir $packageName
$zipPath = Join-Path $OutputDir "$packageName.zip"

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
if (Test-Path $stagingRoot) {
  Remove-Item -LiteralPath $stagingRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $stagingRoot | Out-Null

$include = @(
  "SKILL.md",
  "README.md",
  "ADAPTERS_ZH.md",
  "QUICKSTART_60S_ZH.md",
  "DEMO_PLAYBOOK_ZH.md",
  "INSTALL_TEST_ZH.md",
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
  if (-not (Test-Path $source)) {
    throw "Package include is missing: $name"
  }

  $destination = Join-Path $stagingRoot $name
  if ((Get-Item -LiteralPath $source).PSIsContainer) {
    Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
  } else {
    Copy-Item -LiteralPath $source -Destination $destination -Force
  }
}

$forbidden = Get-ChildItem -LiteralPath $stagingRoot -Recurse -Force |
  Where-Object {
    $_.Name -match '(^\.env|credentials|cookie|secret|token|state\.json$)' -or
    $_.FullName -match '\\\.git(\\|$)'
  }

if ($forbidden) {
  $names = ($forbidden | Select-Object -ExpandProperty FullName) -join [Environment]::NewLine
  throw "Refusing to package potentially private files:$([Environment]::NewLine)$names"
}

if (Test-Path $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}
$stagingContent = Join-Path $stagingRoot "*"
Compress-Archive -Path $stagingContent -DestinationPath $zipPath -Force

if (-not (Test-Path $zipPath)) {
  throw "Package zip was not created: $zipPath"
}

$result = [ordered]@{
  status = "packaged"
  version = $Version
  staging_dir = $stagingRoot
  zip = $zipPath
}

$result | ConvertTo-Json -Depth 4
