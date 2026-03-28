param(
  [switch]$DryRun,
  [switch]$ShowPaths,
  [string]$HomeDir,
  [string]$AgentsRoot,
  [string]$SharedPath,
  [string]$ClaudePath,
  [string]$CursorPath,
  [string]$GeminiPath,
  [string]$CodexPath
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'path-resolution.ps1')

$resolvedPaths = Resolve-SkillSyncPaths `
  -ScriptPath $PSCommandPath `
  -HomeDir $HomeDir `
  -AgentsRoot $AgentsRoot `
  -SharedPath $SharedPath `
  -ClaudePath $ClaudePath `
  -CursorPath $CursorPath `
  -GeminiPath $GeminiPath `
  -CodexPath $CodexPath

$agentsSkills = $resolvedPaths.sharedPath
$manifestPath = $resolvedPaths.manifestPath
$claudeSkills = $resolvedPaths.claudePath
$cursorSkills = $resolvedPaths.cursorPath
$geminiSkills = $resolvedPaths.geminiPath
$codexSkills = $resolvedPaths.codexPath

# 技能忽略列表 - 这些技能会被同步脚本完全忽略
$IgnoreSkills = @('superpowers')

function Invoke-Change {
  param(
    [string]$Message,
    [scriptblock]$Action
  )
  if ($DryRun) {
    Write-Output "[DRYRUN] $Message"
  } else {
    & $Action
    Write-Output "[APPLY] $Message"
  }
}

function Ensure-DirLink {
  param(
    [string]$LinkPath,
    [string]$TargetPath
  )

  if (-not (Test-Path $TargetPath)) {
    Write-Warning "Target missing, skip link: $TargetPath"
    return
  }

  $existingItem = Get-Item -Force $LinkPath -ErrorAction SilentlyContinue
  if ($existingItem) {
    $ok = $false
    if ($existingItem.LinkType -eq 'Junction') {
      $target = ($existingItem.Target | Select-Object -First 1)
      if ($target) {
        $ok = (Normalize-SkillSyncPath $target) -ieq (Normalize-SkillSyncPath $TargetPath)
      }
    }
    if ($ok) {
      return
    }
    Invoke-Change "Remove existing $LinkPath" { Remove-Item -Recurse -Force $LinkPath }
  }

  Invoke-Change "Create junction $LinkPath -> $TargetPath" {
    New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath | Out-Null
  }
}

function Sync-Client {
  param(
    [string]$ClientPath,
    [string[]]$SharedNames,
    [string[]]$AllowedExtraNames = @()
  )

  $existing = Get-ChildItem -Path $ClientPath -Directory -Force -ErrorAction SilentlyContinue
  foreach ($item in $existing) {
    # 跳过忽略列表中的技能
    if ($IgnoreSkills -contains $item.Name) { continue }
    if (($SharedNames -notcontains $item.Name) -and ($AllowedExtraNames -notcontains $item.Name)) {
      Invoke-Change "Remove extra client skill $($item.FullName)" { Remove-Item -Recurse -Force $item.FullName }
    }
  }

  foreach ($name in $SharedNames) {
    # 跳过忽略列表中的技能
    if ($IgnoreSkills -contains $name) { continue }
    $target = Join-Path $agentsSkills $name
    $link = Join-Path $ClientPath $name
    Ensure-DirLink -LinkPath $link -TargetPath $target
  }
}

if ($ShowPaths -or $DryRun) {
  Write-SkillSyncResolvedPaths -ResolvedPaths $resolvedPaths
  Write-Output ''
}

if (-not (Test-Path $manifestPath)) {
  throw "Manifest not found: $manifestPath"
}

$manifest = Get-Content -Raw $manifestPath | ConvertFrom-Json
$shared = @($manifest.skills | Where-Object { $_.scope -eq 'shared' -and $_.status -ne 'deprecated' -and ($IgnoreSkills -notcontains $_.name) } | ForEach-Object { $_.name })
$codexOnly = @($manifest.skills | Where-Object { $_.scope -eq 'codex-only' -and $_.status -ne 'deprecated' -and ($IgnoreSkills -notcontains $_.name) } | ForEach-Object { $_.name })

$clientDefs = @(
  @{ name = 'Claude'; path = $claudeSkills; extras = @() },
  @{ name = 'Cursor'; path = $cursorSkills; extras = @() },
  @{ name = 'Gemini'; path = $geminiSkills; extras = @() },
  @{ name = 'Codex'; path = $codexSkills; extras = @('.system') + $codexOnly }
)

$syncedClients = New-Object System.Collections.Generic.List[string]
$skippedClients = New-Object System.Collections.Generic.List[string]

foreach ($client in $clientDefs) {
  if (-not (Test-Path $client.path)) {
    $skippedClients.Add($client.name) | Out-Null
    Write-Output "[SKIP] Missing client skills directory: $($client.name) -> $($client.path)"
    continue
  }

  Sync-Client -ClientPath $client.path -SharedNames $shared -AllowedExtraNames $client.extras
  $syncedClients.Add($client.name) | Out-Null
}

Write-Output "Sync completed. shared=$($shared.Count), codex-only=$($codexOnly.Count), dryRun=$($DryRun.IsPresent), synced=$(@($syncedClients).Count), skipped=$(@($skippedClients).Count)"
Write-Output "Synced clients: $(if ($syncedClients.Count -gt 0) { $syncedClients -join ', ' } else { 'none' })"
Write-Output "Skipped clients (missing dir): $(if ($skippedClients.Count -gt 0) { $skippedClients -join ', ' } else { 'none' })"
