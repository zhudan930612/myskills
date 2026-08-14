# tools — 技能管理脚本

`~/.agents` 技能仓库的 PowerShell 管理工具箱：覆盖技能「添加 → 同步 → 审计」全生命周期。所有脚本面向 Claude / Cursor / Gemini / Codex 四个客户端，pi 客户端的同步由 `skills/global-skill-sync` 技能内的脚本负责。

## 脚本清单

| 脚本 | 行数 | 作用 | 可单独执行 |
| --- | --- | --- | --- |
| `path-resolution.ps1` | 182 | 路径解析公共模块（各客户端目录默认值 + 参数覆盖） | ❌ 被其他脚本引用 |
| `skills-sync.ps1` | 135 | 将 `skills/` 同步到各客户端（建目录联接） | ✅ |
| `skills-add.ps1` | 118 | 添加新技能（本地目录 / GitHub 仓库） | ✅ |
| `skills-audit.ps1` | 327 | 一致性审计，输出分级报告 | ✅ |

## 工作流关系

```
skills-add.ps1  ──添加──►  skills/<name>/ + manifest + lock
skills-sync.ps1 ──同步──►  各客户端目录建 junction（指向同一份，改源即时生效）
skills-audit.ps1 ──审计──► 校验目录 / 联接 / manifest / lock 是否一致
```

核心机制：**同步 = 创建 Junction（目录联接），不是复制**。客户端目录 `~/.claude/skills/<name>` 等直接指向 `~/.agents/skills/<name>`，任何客户端读到的都是同一份文件。

## 各脚本说明

### path-resolution.ps1

解析各客户端技能目录的默认路径，支持命令行参数覆盖（`-HomeDir` / `-AgentsRoot` / `-ClaudePath` / `-CursorPath` / `-GeminiPath` / `-CodexPath`）。被其他脚本 `dot-source` 引入，**不要单独运行**。

### skills-sync.ps1 — 同步

读取 `skills-manifest.json`，取 `scope=shared` 且非 deprecated 的技能，对每个客户端目录：

1. 删除客户端中不在共享清单内的多余技能目录（Codex 额外保留 `.system` 与 `codex-only` 技能）
2. 为每个共享技能创建/修正 Junction 指向 `~/.agents/skills/<name>`

```powershell
# 实际同步
powershell -File tools/skills-sync.ps1

# 只预览，不写入
powershell -File tools/skills-sync.ps1 -DryRun

# 显示路径解析结果
powershell -File tools/skills-sync.ps1 -ShowPaths
```

### skills-add.ps1 — 添加技能

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| `-Source` | ✅ | 本地目录路径，或 GitHub 仓库（如 `owner/repo`） |
| `-Name` | ✅ | 技能名（目录名） |
| `-Scope` | | `shared`（默认）/ `codex-only` / `deprecated` |
| `-Owner` | | 所有者，默认当前用户名 |
| `-Force` | | 覆盖已存在的同名技能 |

- 本地来源：直接复制目录，要求目标含 `SKILL.md`
- GitHub 来源：走 `npx skills add <repo> -g -y`，仅支持 shared 作用域
- 自动写入 `skills-manifest.json`；shared 作用域同时写入 `.skill-lock.json`

```powershell
# 从本地目录添加
powershell -File tools/skills-add.ps1 -Source C:\path\to\my-skill -Name my-skill

# 从 GitHub 添加
powershell -File tools/skills-add.ps1 -Source owner/repo -Name my-skill
```

### skills-audit.ps1 — 审计

| 参数 | 说明 |
| --- | --- |
| `-Format markdown/json` | 报告格式，默认 markdown |
| `-Strict` | 严格模式（warning 也计为失败） |
| `-ShowPaths` | 输出路径解析结果 |
| 路径覆盖参数 | 同 path-resolution |

检查项：技能目录是否含 `SKILL.md`、客户端联接是否正确指向共享源、manifest 中 `lock:*` 技能是否在 `.skill-lock.json` 有记录。退出码 `0` = 通过。

```powershell
powershell -File tools/skills-audit.ps1          # markdown 报告
powershell -File tools/skills-audit.ps1 -Format json -Strict
```

## 维护约定

1. 新增技能后：`skills-add.ps1` → `skills-sync.ps1` → `skills-audit.ps1` 验证
2. 直接修改 `skills/<name>/SKILL.md` 后无需 sync（junction 即时生效）
3. 移除技能：用 `skills-add.ps1 -Scope deprecated` 标记废弃，再手动删目录与 manifest 条目
