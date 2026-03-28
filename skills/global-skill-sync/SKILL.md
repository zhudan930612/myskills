---
name: global-skill-sync
description: 执行跨客户端的全局技能同步并做一致性校验。触发词：同步技能、全局技能同步、global skill sync。用于在修改 ~/.agents/skills、skills-manifest.json 或 .skill-lock.json 后，将变更同步到 Claude、Cursor、Gemini、Codex。
---

# Global Skill Sync

将共享技能源 `~/.agents/skills` 的变更同步到所有客户端，并输出标准化结果：目录解析结果、各目录数量、专属技能、审计摘要和最终结论。

## Trigger Phrases
- 同步技能
- 全局技能同步
- global skill sync

## Bundled Scripts
- `scripts/global-skill-sync.ps1`（默认入口）
- `scripts/skills-sync.ps1`
- `scripts/skills-audit.ps1`
- `scripts/path-resolution.ps1`

## Workflow
1. 在技能目录执行默认命令：
`powershell -ExecutionPolicy Bypass -File .\scripts\global-skill-sync.ps1`

2. 若需要严格模式：
`powershell -ExecutionPolicy Bypass -File .\scripts\global-skill-sync.ps1 -Strict`

3. 若执行环境不是目标用户上下文，可显式传参覆盖目录：
`powershell -ExecutionPolicy Bypass -File .\scripts\global-skill-sync.ps1 -HomeDir C:\Users\YourName`

4. 若需要先检查解析路径与计划动作，使用：
`powershell -ExecutionPolicy Bypass -File .\scripts\global-skill-sync.ps1 -DryRun`

## Path Resolution Rules
- 优先级：显式参数 > 环境变量 > 基于脚本位置反推 > 当前运行用户目录兜底
- 共享技能根目录默认从脚本所在位置反推，不依赖当前运行账号
- 支持的显式参数：
  - `-HomeDir`
  - `-AgentsRoot`
  - `-SharedPath`
  - `-ClaudePath`
  - `-CursorPath`
  - `-GeminiPath`
  - `-CodexPath`
- 支持的环境变量：
  - `SKILL_SYNC_HOME_DIR`
  - `AGENTS_HOME`
  - `SKILL_SHARED_ROOT`
  - `CLAUDE_SKILLS_DIR`
  - `CURSOR_SKILLS_DIR`
  - `GEMINI_SKILLS_DIR`
  - `CODEX_SKILLS_DIR`

## Output Contract
- Resolved Paths（本次执行实际命中的目录）
- Sync Status（已同步客户端 / 未找到目录并跳过的客户端）
- Folder Counts（shared/claude/cursor/gemini/codex）
- Dedicated Skills（各客户端相对 shared 的专属技能）
- Audit Summary（blocking/warning/info/建议退出码）
- Conclusion（同步成功 / 存在问题）
- Client Skill Counts（各客户端技能数量与专属技能表格）

## 输出要求

执行脚本后，必须将脚本的完整输出原样展示给用户，不得省略任何部分，包括：
- Resolved Paths
- 同步状态
- 目录数量
- 专属技能
- 审计摘要
- 结论
- Client Skill Counts 表格

## Behavior Rules
- 默认执行“同步 + 审计 + 结果汇总”，不进行其他业务改动。
- `-DryRun` 仅做模拟同步并照常输出检查结果。
