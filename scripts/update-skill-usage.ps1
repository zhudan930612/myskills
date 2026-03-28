param(
    [string]$SkillName,
    [string]$Client = "claude"
)

$usageFile = "$env:USERPROFILE\.agents\skill-usage.json"
$project = Split-Path $PWD.Path -Leaf
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"

# 读取现有数据
if (Test-Path $usageFile) {
    $json = Get-Content $usageFile -Raw
} else {
    $json = '{"version":1,"skills":{}}'
}

# 使用 ConvertFrom-Json 并转为哈希表
$data = $json | ConvertFrom-Json -AsHashtable

# 确保 skills 是哈希表
if (-not $data.skills) {
    $data.skills = @{}
}

# 检查技能是否存在
if (-not $data.skills.ContainsKey($SkillName)) {
    $data.skills[$SkillName] = @{
        count = 0
        lastUsedAt = ""
        lastClient = ""
        lastProject = ""
        byClient = @{}
    }
}

# 确保 byClient 是哈希表
if (-not $data.skills[$SkillName].byClient) {
    $data.skills[$SkillName].byClient = @{}
}

# 更新统计
$skill = $data.skills[$SkillName]
$skill.count++

if (-not $skill.byClient.ContainsKey($Client)) {
    $skill.byClient[$Client] = 0
}
$skill.byClient[$Client]++

$skill.lastUsedAt = $timestamp
$skill.lastClient = $Client
$skill.lastProject = $project

$data.updatedAt = $timestamp

# 保存
$data | ConvertTo-Json -Depth 10 | Set-Content $usageFile -Encoding UTF8