function Normalize-SkillSyncPath {
  param([string]$PathValue)

  if ([string]::IsNullOrWhiteSpace($PathValue)) {
    return ''
  }

  try {
    return [IO.Path]::GetFullPath($PathValue).TrimEnd('\')
  } catch {
    return $PathValue.TrimEnd('\')
  }
}

function Get-SkillSyncFirstValue {
  param([string[]]$Values)

  foreach ($value in $Values) {
    if (-not [string]::IsNullOrWhiteSpace($value)) {
      return $value
    }
  }

  return ''
}

function Get-SkillSyncDefaultPaths {
  param([string]$ScriptPath)

  $scriptFile = Get-Item -LiteralPath $ScriptPath -ErrorAction Stop
  $scriptDir = Split-Path -Parent $scriptFile.FullName
  $scriptDirName = Split-Path -Leaf $scriptDir

  $skillDir = ''
  $sharedPath = ''
  $agentsRoot = ''
  $homeDir = ''

  if ($scriptDirName -ieq 'scripts') {
    $skillDir = Split-Path -Parent $scriptDir
    $sharedPath = Split-Path -Parent $skillDir
    $agentsRoot = Split-Path -Parent $sharedPath
    $homeDir = Split-Path -Parent $agentsRoot
  } elseif ($scriptDirName -ieq 'tools') {
    $agentsRoot = Split-Path -Parent $scriptDir
    $sharedPath = Join-Path $agentsRoot 'skills'
    $homeDir = Split-Path -Parent $agentsRoot
  } else {
    $agentsRoot = Split-Path -Parent $scriptDir
    $sharedPath = Join-Path $agentsRoot 'skills'
    $homeDir = Split-Path -Parent $agentsRoot
  }

  [pscustomobject]@{
    scriptPath = $scriptFile.FullName
    scriptDir = $scriptDir
    skillDir = $skillDir
    sharedPath = $sharedPath
    agentsRoot = $agentsRoot
    homeDir = $homeDir
  }
}

function Resolve-SkillSyncPaths {
  param(
    [string]$ScriptPath,
    [string]$HomeDir,
    [string]$AgentsRoot,
    [string]$SharedPath,
    [string]$ClaudePath,
    [string]$CursorPath,
    [string]$GeminiPath,
    [string]$CodexPath
  )

  $defaults = Get-SkillSyncDefaultPaths -ScriptPath $ScriptPath
  $fallbackHome = [Environment]::GetFolderPath('UserProfile')

  $resolvedHomeDir = Get-SkillSyncFirstValue @(
    $HomeDir,
    $env:SKILL_SYNC_HOME_DIR,
    $defaults.homeDir,
    $fallbackHome
  )
  $resolvedHomeDir = Normalize-SkillSyncPath $resolvedHomeDir

  $resolvedAgentsRoot = Get-SkillSyncFirstValue @(
    $AgentsRoot,
    $env:AGENTS_HOME,
    $env:SKILL_SYNC_AGENTS_ROOT,
    $(if ($resolvedHomeDir) { Join-Path $resolvedHomeDir '.agents' }),
    $defaults.agentsRoot
  )
  $resolvedAgentsRoot = Normalize-SkillSyncPath $resolvedAgentsRoot

  $resolvedSharedPath = Get-SkillSyncFirstValue @(
    $SharedPath,
    $env:SKILL_SHARED_ROOT,
    $env:SKILL_SYNC_SHARED_PATH,
    $(if ($resolvedAgentsRoot) { Join-Path $resolvedAgentsRoot 'skills' }),
    $defaults.sharedPath
  )
  $resolvedSharedPath = Normalize-SkillSyncPath $resolvedSharedPath

  $resolvedClaudePath = Get-SkillSyncFirstValue @(
    $ClaudePath,
    $env:CLAUDE_SKILLS_DIR,
    $env:SKILL_SYNC_CLAUDE_PATH,
    $(if ($resolvedHomeDir) { Join-Path $resolvedHomeDir '.claude/skills' })
  )
  $resolvedClaudePath = Normalize-SkillSyncPath $resolvedClaudePath

  $resolvedCursorPath = Get-SkillSyncFirstValue @(
    $CursorPath,
    $env:CURSOR_SKILLS_DIR,
    $env:SKILL_SYNC_CURSOR_PATH,
    $(if ($resolvedHomeDir) { Join-Path $resolvedHomeDir '.cursor/skills' })
  )
  $resolvedCursorPath = Normalize-SkillSyncPath $resolvedCursorPath

  $resolvedGeminiPath = Get-SkillSyncFirstValue @(
    $GeminiPath,
    $env:GEMINI_SKILLS_DIR,
    $env:SKILL_SYNC_GEMINI_PATH,
    $(if ($resolvedHomeDir) { Join-Path $resolvedHomeDir '.gemini/skills' })
  )
  $resolvedGeminiPath = Normalize-SkillSyncPath $resolvedGeminiPath

  $resolvedCodexPath = Get-SkillSyncFirstValue @(
    $CodexPath,
    $env:CODEX_SKILLS_DIR,
    $env:SKILL_SYNC_CODEX_PATH,
    $(if ($resolvedHomeDir) { Join-Path $resolvedHomeDir '.codex/skills' })
  )
  $resolvedCodexPath = Normalize-SkillSyncPath $resolvedCodexPath

  [pscustomobject]@{
    scriptPath = $defaults.scriptPath
    scriptDir = $defaults.scriptDir
    skillDir = $defaults.skillDir
    homeDir = $resolvedHomeDir
    agentsRoot = $resolvedAgentsRoot
    sharedPath = $resolvedSharedPath
    manifestPath = $(if ($resolvedAgentsRoot) { Join-Path $resolvedAgentsRoot 'skills-manifest.json' } else { '' })
    lockPath = $(if ($resolvedAgentsRoot) { Join-Path $resolvedAgentsRoot '.skill-lock.json' } else { '' })
    claudePath = $resolvedClaudePath
    cursorPath = $resolvedCursorPath
    geminiPath = $resolvedGeminiPath
    codexPath = $resolvedCodexPath
  }
}

function Convert-SkillSyncResolvedPathsToMap {
  param([pscustomobject]$ResolvedPaths)

  [ordered]@{
    homeDir = $ResolvedPaths.homeDir
    agentsRoot = $ResolvedPaths.agentsRoot
    sharedPath = $ResolvedPaths.sharedPath
    manifestPath = $ResolvedPaths.manifestPath
    lockPath = $ResolvedPaths.lockPath
    claudePath = $ResolvedPaths.claudePath
    cursorPath = $ResolvedPaths.cursorPath
    geminiPath = $ResolvedPaths.geminiPath
    codexPath = $ResolvedPaths.codexPath
  }
}

function Write-SkillSyncResolvedPaths {
  param([pscustomobject]$ResolvedPaths)

  Write-Output '## Resolved Paths'
  Write-Output "- homeDir: $($ResolvedPaths.homeDir)"
  Write-Output "- agentsRoot: $($ResolvedPaths.agentsRoot)"
  Write-Output "- sharedPath: $($ResolvedPaths.sharedPath)"
  Write-Output "- manifestPath: $($ResolvedPaths.manifestPath)"
  Write-Output "- lockPath: $($ResolvedPaths.lockPath)"
  Write-Output "- claudePath: $($ResolvedPaths.claudePath)"
  Write-Output "- cursorPath: $($ResolvedPaths.cursorPath)"
  Write-Output "- geminiPath: $($ResolvedPaths.geminiPath)"
  Write-Output "- codexPath: $($ResolvedPaths.codexPath)"
}
