param(
  [Parameter(Mandatory = $true)]
  [string]$Source,
  [Parameter(Mandatory = $true)]
  [string]$Name,
  [ValidateSet('shared', 'codex-only', 'deprecated')]
  [string]$Scope = 'shared',
  [string]$Owner = $env:USERNAME,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

$agentsRoot = 'C:/Users/zhudan/.agents'
$agentsSkills = Join-Path $agentsRoot 'skills'
$codexSkills = 'C:/Users/zhudan/.codex/skills'
$manifestPath = Join-Path $agentsRoot 'skills-manifest.json'
$lockPath = Join-Path $agentsRoot '.skill-lock.json'

function Load-Manifest {
  param([string]$Path)
  if (Test-Path $Path) {
    return (Get-Content -Raw $Path | ConvertFrom-Json)
  }
  return [pscustomobject]@{ version = 1; updatedAt = ''; skills = @() }
}

function Save-Manifest {
  param($Manifest, [string]$Path)
  $Manifest.updatedAt = (Get-Date).ToString('s')
  $Manifest | ConvertTo-Json -Depth 8 | Set-Content -Path $Path -Encoding UTF8
}

if ($Scope -eq 'deprecated') {
  $manifest = Load-Manifest -Path $manifestPath
  $skills = @($manifest.skills | Where-Object { $_.name -ne $Name })
  $skills += [pscustomobject]@{
    name = $Name
    scope = 'shared'
    source = "deprecated:$Source"
    owner = $Owner
    status = 'deprecated'
  }
  $manifest.skills = @($skills | Sort-Object name)
  Save-Manifest -Manifest $manifest -Path $manifestPath
  Write-Output "Marked deprecated in manifest: $Name"
  exit 0
}

$destRoot = if ($Scope -eq 'shared') { $agentsSkills } else { $codexSkills }
$dest = Join-Path $destRoot $Name

if (Test-Path $dest) {
  if (-not $Force.IsPresent) {
    throw "Skill already exists: $dest ; use -Force to overwrite."
  }
  Remove-Item -Recurse -Force $dest
}

$sourceLabel = ''
$sourceType = 'local'

if (Test-Path $Source) {
  Copy-Item -Recurse -Force $Source $dest
  if (-not (Test-Path (Join-Path $dest 'SKILL.md'))) {
    throw "Source copied but SKILL.md not found in destination: $dest"
  }
  $sourceLabel = "local:$Source"
  $sourceType = 'local'
} else {
  if ($Scope -ne 'shared') {
    throw 'Remote install currently supports shared scope only.'
  }
  $cmd = "npx skills add $Source -g -y"
  Write-Output "Running: $cmd"
  cmd /c $cmd
  if ($LASTEXITCODE -ne 0) {
    throw "Install failed: $Source"
  }
  if (-not (Test-Path $dest)) {
    throw "Install completed but target skill path not found: $dest"
  }
  $sourceLabel = "remote:$Source"
  $sourceType = 'github'
}

$manifest = Load-Manifest -Path $manifestPath
$skills = @($manifest.skills | Where-Object { $_.name -ne $Name })
$skills += [pscustomobject]@{
  name = $Name
  scope = $Scope
  source = $sourceLabel
  owner = $Owner
  status = 'active'
}
$manifest.skills = @($skills | Sort-Object name)
Save-Manifest -Manifest $manifest -Path $manifestPath

if ($Scope -eq 'shared' -and (Test-Path $lockPath)) {
  $lock = Get-Content -Raw $lockPath | ConvertFrom-Json
  if (-not $lock.skills) {
    $lock | Add-Member -MemberType NoteProperty -Name skills -Value ([pscustomobject]@{})
  }
  $now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
  $entry = [pscustomobject]@{
    source = $Source
    sourceType = $sourceType
    sourceUrl = if ($Source -match '^https?://') { $Source } else { '' }
    skillPath = 'SKILL.md'
    skillFolderHash = ''
    installedAt = $now
    updatedAt = $now
  }
  $lock.skills | Add-Member -MemberType NoteProperty -Name $Name -Value $entry -Force
  $lock | ConvertTo-Json -Depth 12 | Set-Content -Path $lockPath -Encoding UTF8
}

Write-Output "Skill added: $Name (scope=$Scope)"
