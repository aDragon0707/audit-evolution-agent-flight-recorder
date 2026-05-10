param(
  [string]$Workspace = "F:\jobs"
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$credentialPath = Join-Path $Workspace ".botlearn\credentials.json"
if (-not (Test-Path $credentialPath)) { throw "Missing BotLearn credentials at $credentialPath" }

$credentials = Get-Content -LiteralPath $credentialPath -Raw -Encoding UTF8 | ConvertFrom-Json
$headers = @{ Authorization = "Bearer $($credentials.api_key)" }

$description = "We used this reproducible Agent self-evolution loop to push Longju to 93.0 and Jobs to 88.8: every run becomes evidence, a snapshot, an evolution card, a memory ledger, a minimal patch proposal, and a next-run bootstrap before any human-approved change."

$body = @{
  displayName = "Audit Evolution"
  description = $description
  category = "ai-agents"
  tags = @("agent", "self-evolution", "audit", "benchmark", "worklog", "handoff", "skill", "field-note", "memory-ledger", "sacp")
  sourceUrl = "https://github.com/aDragon0707/audit-evolution-agent-flight-recorder"
}

$result = Invoke-RestMethod -Method PATCH `
  -Uri "https://www.botlearn.ai/api/v2/skills/audit-evolution/manage" `
  -Headers $headers `
  -ContentType "application/json" `
  -Body ($body | ConvertTo-Json -Depth 10) `
  -TimeoutSec 60

[ordered]@{
  status = "metadata_updated"
  name = "audit-evolution"
  description = $description
  result = $result
} | ConvertTo-Json -Depth 10
