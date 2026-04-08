param(
  [Parameter(Mandatory = $true)]
  [string]$SourceDoc,
  [string]$DocsRoot,
  [string]$OverridesJson,
  [string]$OutputJson,
  [switch]$ShowItems
)

$ErrorActionPreference = 'Stop'

function Normalize-Text {
  param([string]$Text)
  if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
  $t = $Text
  $t = $t -replace '[`*_>#\[\]\(\)]', ' '
  $t = $t -replace '\|', ' '
  $t = $t -replace '[:：,，。；;！!？?~～\-—]+', ' '
  $t = $t -replace '\s+', ''
  return $t.Trim()
}

function Get-Tokens {
  param([string]$Text)
  $norm = Normalize-Text $Text
  if (-not $norm) { return @() }
  $matches = [regex]::Matches($norm, '[\p{L}\p{N}]{2,}')
  $tokens = @()
  foreach ($m in $matches) {
    if ($m.Value) { $tokens += $m.Value }
  }
  return @($tokens | Select-Object -Unique)
}

function Parse-TableCells {
  param([string]$Line)
  $trim = $Line.Trim().Trim('|')
  return @($trim.Split('|') | ForEach-Object { $_.Trim() })
}

function Is-SeparatorRow {
  param([string]$Line)
  $x = $Line.Trim()
  return $x -match '^\|[\-:\s|]+\|$'
}

function Get-DecisionMapRows {
  param([string[]]$Lines)
  $headerIdx = -1
  for ($i = 0; $i -lt $Lines.Count; $i++) {
    $line = $Lines[$i]
    if ($line -match '^\|.*需求条目.*目标模块文档.*\|$') {
      $headerIdx = $i
      break
    }
  }
  if ($headerIdx -lt 0) {
    throw '未找到“拆解落位索引表”表头（需求条目/目标模块文档）。'
  }

  $rows = @()
  for ($i = $headerIdx + 1; $i -lt $Lines.Count; $i++) {
    $line = $Lines[$i]
    if (-not $line.Trim().StartsWith('|')) { break }
    if (Is-SeparatorRow $line) { continue }
    $cells = Parse-TableCells $line
    if ($cells.Count -lt 3) { continue }
    $rows += [pscustomobject]@{
      Need   = $cells[0]
      Source = if ($cells.Count -ge 2) { $cells[1] } else { '' }
      Target = if ($cells.Count -ge 3) { $cells[2] } else { '' }
      Type   = if ($cells.Count -ge 4) { $cells[3] } else { '' }
      Status = if ($cells.Count -ge 5) { $cells[4] } else { '' }
    }
  }
  return $rows
}

function Expand-TargetRefs {
  param([string]$Raw)
  $refs = @()
  $currentPath = $null
  $parts = $Raw.Split('、')
  foreach ($part in $parts) {
    $token = $part.Trim(' ', '`')
    if (-not $token) { continue }

    if ($token.StartsWith('#')) {
      if (-not $currentPath) { continue }
      $refs += [pscustomobject]@{ Path = $currentPath; Anchor = $token.Substring(1) }
      continue
    }

    $path = $token
    $anchor = ''
    if ($token -match '^(.*)#(.+)$') {
      $path = $matches[1]
      $anchor = $matches[2]
    }

    $currentPath = $path
    $refs += [pscustomobject]@{ Path = $path; Anchor = $anchor }
  }
  return @($refs)
}

function Resolve-DocsRoot {
  param([string]$SourceDocPath, [string]$InputDocsRoot)
  if ($InputDocsRoot) {
    return (Resolve-Path $InputDocsRoot).Path
  }

  $full = (Resolve-Path $SourceDocPath).Path
  $norm = $full.Replace('\\', '/')
  $idx = $norm.IndexOf('/docs/')
  if ($idx -ge 0) {
    return $norm.Substring(0, $idx + 5)
  }

  $dir = Split-Path -Parent $full
  while ($dir -and (Test-Path $dir)) {
    $cand = Join-Path $dir 'docs'
    if (Test-Path $cand) { return (Resolve-Path $cand).Path }
    $parent = Split-Path -Parent $dir
    if ($parent -eq $dir) { break }
    $dir = $parent
  }

  throw '无法推断 docs 根目录，请显式传入 -DocsRoot。'
}

function Resolve-TargetPath {
  param([string]$DocsRootPath, [string]$RawPath)
  $path = $RawPath.Trim(' ', '`').Replace('\\', '/')
  if ($path.StartsWith('docs/')) {
    $path = $path.Substring(5)
  }
  $full = Join-Path $DocsRootPath $path
  return $full
}

function Get-SectionLines {
  param([string[]]$Lines, [string]$SourceToken)
  $token = $SourceToken.Trim(' ', '`')
  if (-not $token) { return @() }

  $start = -1
  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i].Trim() -eq $token) {
      $start = $i
      break
    }
  }

  if ($start -lt 0) {
    for ($i = 0; $i -lt $Lines.Count; $i++) {
      if ($Lines[$i] -like "*$token*") {
        $start = $i
        break
      }
    }
  }

  if ($start -lt 0) { return @() }

  $level = 4
  if ($token -match '^(#+)\s+') {
    $level = $matches[1].Length
  } elseif ($Lines[$start] -match '^(#+)\s+') {
    $level = $matches[1].Length
  }

  $out = @()
  for ($i = $start; $i -lt $Lines.Count; $i++) {
    $line = $Lines[$i]
    if ($i -gt $start -and $line -match '^(#+)\s+') {
      $nextLevel = $matches[1].Length
      if ($nextLevel -le $level) { break }
    }
    $out += $line
  }
  return $out
}

function Get-AtomicItems {
  param([string[]]$SectionLines)
  $items = @()
  $inCode = $false

  foreach ($line in $SectionLines) {
    $trim = $line.Trim()
    if (-not $trim) { continue }

    if ($trim.StartsWith('```')) {
      $inCode = -not $inCode
      continue
    }
    if ($inCode) { continue }

    $type = ''
    if ($trim.StartsWith('|')) {
      if (Is-SeparatorRow $trim) { continue }
      $type = 'table-row'
    } elseif ($trim -match '^[-*]\s+') {
      $type = 'bullet'
    } elseif ($trim -match '^\d+\.\s+') {
      $type = 'ordered'
    } elseif ($trim -match '^\*\*.+\*\*[:：]?$') {
      $type = 'rule-title'
    } elseif ($trim.Length -le 120 -and $trim -match '[:：]') {
      $type = 'rule-line'
    } else {
      continue
    }

    $norm = Normalize-Text $trim
    if ($norm.Length -lt 8) { continue }

    $items += [pscustomobject]@{
      Type = $type
      Text = $trim
      Norm = $norm
    }
  }

  $dedup = @{}
  $result = @()
  foreach ($it in $items) {
    if ($dedup.ContainsKey($it.Norm)) { continue }
    $dedup[$it.Norm] = $true
    $result += $it
  }

  return $result
}

function Test-ItemCovered {
  param(
    [string]$ItemNorm,
    [string[]]$TargetNorms,
    [string]$ItemText
  )

  foreach ($t in $TargetNorms) {
    if ($t.Contains($ItemNorm)) { return $true }
  }

  $tokens = Get-Tokens $ItemText
  if ($tokens.Count -lt 2) { return $false }

  $hit = 0
  foreach ($tok in $tokens) {
    $found = $false
    foreach ($t in $TargetNorms) {
      if ($t.Contains($tok)) {
        $found = $true
        break
      }
    }
    if ($found) { $hit++ }
  }

  $ratio = $hit / [math]::Max($tokens.Count, 1)
  return ($hit -ge 2 -and $ratio -ge 0.75)
}

function Get-OverrideMap {
  param([string]$OverridesPath)
  $map = @{}
  if (-not $OverridesPath) { return $map }
  if (-not (Test-Path $OverridesPath)) { throw "覆盖文件不存在: $OverridesPath" }

  $arr = Get-Content -Raw $OverridesPath | ConvertFrom-Json
  foreach ($x in $arr) {
    $k = "$(Normalize-Text $x.source)|$(Normalize-Text $x.item)"
    $map[$k] = [pscustomobject]@{
      Status = [string]$x.status
      Reason = [string]$x.reason
    }
  }
  return $map
}

if (-not (Test-Path $SourceDoc)) {
  throw "源文档不存在: $SourceDoc"
}

$docFull = (Resolve-Path $SourceDoc).Path
$docsRootFull = Resolve-DocsRoot -SourceDocPath $docFull -InputDocsRoot $DocsRoot
$lines = Get-Content $docFull
$rows = Get-DecisionMapRows $lines
$overrideMap = Get-OverrideMap $OverridesJson

$contentCache = @{}
function Get-TargetNorm {
  param([string]$Path)
  if ($contentCache.ContainsKey($Path)) { return $contentCache[$Path] }
  if (-not (Test-Path $Path)) {
    $contentCache[$Path] = ''
    return ''
  }
  $raw = Get-Content -Raw $Path
  $norm = Normalize-Text $raw
  $contentCache[$Path] = $norm
  return $norm
}

$matrix = @()
$reqId = 0
foreach ($row in $rows) {
  $reqId++
  $refs = Expand-TargetRefs $row.Target
  $targetPaths = @()
  foreach ($r in $refs) {
    $full = Resolve-TargetPath -DocsRootPath $docsRootFull -RawPath $r.Path
    if ($targetPaths -notcontains $full) { $targetPaths += $full }
  }

  $sectionLines = Get-SectionLines -Lines $lines -SourceToken $row.Source
  $items = Get-AtomicItems $sectionLines
  if ($items.Count -eq 0) {
    $fallback = Normalize-Text $row.Need
    $items = @([pscustomobject]@{ Type = 'fallback'; Text = $row.Need; Norm = $fallback })
  }

  $targetNorms = @()
  foreach ($tp in $targetPaths) {
    $targetNorms += Get-TargetNorm $tp
  }

  $itemIdx = 0
  foreach ($it in $items) {
    $itemIdx++
    $status = 'missing'
    $reason = ''

    $key = "$(Normalize-Text $row.Source)|$(Normalize-Text $it.Text)"
    if ($overrideMap.ContainsKey($key)) {
      $ov = $overrideMap[$key]
      $status = $ov.Status
      $reason = $ov.Reason
    } else {
      if (Test-ItemCovered -ItemNorm $it.Norm -TargetNorms $targetNorms -ItemText $it.Text) {
        $status = 'covered'
      }
    }

    if ($status -eq 'not-applicable' -and [string]::IsNullOrWhiteSpace($reason)) {
      $status = 'missing'
      $reason = 'not-applicable 未提供 reason，按 missing 处理'
    }

    $matrix += [pscustomobject]@{
      id          = ('R{0:D3}-I{1:D3}' -f $reqId, $itemIdx)
      need        = $row.Need
      source      = $row.Source
      targetDocs  = @($targetPaths)
      itemType    = $it.Type
      itemText    = $it.Text
      status      = $status
      reason      = $reason
    }
  }
}

$covered = @($matrix | Where-Object { $_.status -eq 'covered' }).Count
$missing = @($matrix | Where-Object { $_.status -eq 'missing' }).Count
$na = @($matrix | Where-Object { $_.status -eq 'not-applicable' }).Count
$total = $matrix.Count

Write-Output '=== PRD Coverage Matrix Summary ==='
Write-Output ("SourceDoc : {0}" -f $docFull)
Write-Output ("DocsRoot  : {0}" -f $docsRootFull)
Write-Output ("Total     : {0}" -f $total)
Write-Output ("covered   : {0}" -f $covered)
Write-Output ("missing   : {0}" -f $missing)
Write-Output ("not-applicable(with reason): {0}" -f $na)

if ($ShowItems) {
  Write-Output '=== Items ==='
  $matrix |
    Select-Object id, status, source, itemType, itemText, reason |
    Format-Table -AutoSize |
    Out-String -Width 4096 |
    Write-Output
}

if ($OutputJson) {
  $outObj = [pscustomobject]@{
    sourceDoc = $docFull
    docsRoot = $docsRootFull
    summary = [pscustomobject]@{
      total = $total
      covered = $covered
      missing = $missing
      notApplicableWithReason = $na
    }
    matrix = $matrix
  }
  $outObj | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputJson -Encoding UTF8
  Write-Output ("JSON written: {0}" -f $OutputJson)
}

if ($missing -gt 0) {
  exit 1
}

exit 0
