param(
  [string]$Workspace = "F:\jobs",
  [string]$SkillDir = "F:\demo",
  [string]$PackedZip = "F:\demo\dist\audit-evolution-0.3.2-skillhunt.zip",
  [string]$NodePath = "C:\Users\86181\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$credentialPath = Join-Path $Workspace ".botlearn\credentials.json"
$statePath = Join-Path $Workspace ".botlearn\state.json"
$skillPath = Join-Path $SkillDir "SKILL.md"

if (-not (Test-Path $credentialPath)) { throw "Missing BotLearn credentials at $credentialPath" }
if (-not (Test-Path $skillPath)) { throw "Missing SKILL.md at $skillPath" }
if (-not (Test-Path $PackedZip)) { throw "Missing packed zip at $PackedZip" }

$credentials = Get-Content -LiteralPath $credentialPath -Raw -Encoding UTF8 | ConvertFrom-Json
$apiKey = $credentials.api_key
if (-not $apiKey) { throw "credentials.json does not contain api_key" }

$skillText = Get-Content -LiteralPath $skillPath -Raw -Encoding UTF8
function Read-FrontmatterValue([string]$Name) {
  $match = [regex]::Match($skillText, "(?m)^$([regex]::Escape($Name)):\s*(.+?)\s*$")
  if ($match.Success) { return $match.Groups[1].Value.Trim().Trim('"') }
  return ""
}

$name = Read-FrontmatterValue "name"
$version = Read-FrontmatterValue "version"
$displayName = Read-FrontmatterValue "displayName"
$description = Read-FrontmatterValue "description"
$category = Read-FrontmatterValue "category"
$skillType = Read-FrontmatterValue "skillType"
$tagsRaw = Read-FrontmatterValue "tags"
$tags = @()
if ($tagsRaw -match '^\[(.*)\]$') {
  $tags = $Matches[1].Split(",") | ForEach-Object { $_.Trim().Trim('"').Trim("'") } | Where-Object { $_ }
}

if (-not $name -or -not $version) { throw "SKILL.md must contain name and version" }

$headers = @{ Authorization = "Bearer $apiKey" }

function Invoke-BotLearnJson {
  param(
    [string]$Method,
    [string]$Uri,
    [object]$Body = $null
  )
  $params = @{
    Method = $Method
    Uri = $Uri
    Headers = $headers
    TimeoutSec = 120
  }
  if ($null -ne $Body) {
    $params.ContentType = "application/json"
    $params.Body = ($Body | ConvertTo-Json -Depth 10)
  }
  return Invoke-RestMethod @params
}

Write-Host "Checking existing skill: $name"
$existing = $null
try {
  $existing = Invoke-BotLearnJson -Method GET -Uri "https://www.botlearn.ai/api/v2/skills/$name/manage"
} catch {
  if ($_.Exception.Response.StatusCode.value__ -ne 404) { throw }
}

Write-Host "Uploading archive..."
$form = @{
  archive = Get-Item -LiteralPath $PackedZip
}
$upload = Invoke-RestMethod -Method POST -Uri "https://www.botlearn.ai/api/v2/skills/upload" -Headers $headers -Form $form -TimeoutSec 120
if (-not $upload.success) { throw "Upload failed: $($upload | ConvertTo-Json -Depth 10)" }
if ($upload.data.validation -and -not $upload.data.validation.passed) {
  throw "Upload validation failed: $($upload.data.validation | ConvertTo-Json -Depth 10)"
}
$uploadId = $upload.data.uploadId
if (-not $uploadId) { throw "Upload did not return uploadId" }

if ($existing -and $existing.data) {
  Write-Host "Publishing new version $version..."
  $body = @{
    version = $version
    changelog = "SkillHunt-ready v${version}: added 60-second quickstart, demo playbook, install test checklist, cross-platform installer package coverage, and reproducible packaging."
    uploadId = $uploadId
  }
  $result = Invoke-BotLearnJson -Method POST -Uri "https://www.botlearn.ai/api/v2/skills/$name/versions/publish" -Body $body
  $mode = "version"
} else {
  Write-Host "Creating new skill $name v$version..."
  $body = @{
    name = $name
    displayName = $displayName
    description = $description
    category = $category
    skillType = $skillType
    version = $version
    sourceUrl = "https://github.com/aDragon0707/audit-evolution-agent-flight-recorder"
    tags = $tags
    uploadId = $uploadId
  }
  $result = Invoke-BotLearnJson -Method POST -Uri "https://www.botlearn.ai/api/v2/skills" -Body $body
  $mode = "publish"
}

if (Test-Path $statePath) {
  try {
    $state = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $state.skills) { $state | Add-Member -MemberType NoteProperty -Name skills -Value ([pscustomobject]@{}) }
    if (-not $state.skills.published) { $state.skills | Add-Member -MemberType NoteProperty -Name published -Value ([pscustomobject]@{}) }
    $published = [pscustomobject]@{
      version = $version
      publishedAt = (Get-Date).ToUniversalTime().ToString("s") + "Z"
      source = "codex-powershell"
    }
    $state.skills.published | Add-Member -MemberType NoteProperty -Name $name -Value $published -Force
    Set-Content -LiteralPath $statePath -Value ($state | ConvertTo-Json -Depth 20) -Encoding UTF8
  } catch {
    Write-Warning "Published remotely, but could not update local state.json: $($_.Exception.Message)"
  }
}

$pageUrl = "https://www.botlearn.ai/skillhunt/v2/s/$name"
[ordered]@{
  status = "published"
  mode = $mode
  name = $name
  version = $version
  pageUrl = $pageUrl
  uploadId = $uploadId
} | ConvertTo-Json -Depth 10
