# ~/.agents — 全局 Agent 技能仓库

集中管理所有 AI 客户端（Claude / Cursor / Gemini / Codex / pi）共用的技能（skills），统一来源、统一版本、可审计、可回滚。本仓库是各客户端技能目录的**唯一事实来源（source of truth）**。

## 目录结构

```
~/.agents/
├── skills/                 # 技能本体（每个子目录一个技能，含 SKILL.md）
├── skills-manifest.json    # 技能清单：名称、作用域、来源、状态
├── .skill-lock.json        # 共享技能锁定信息（来源 URL / 哈希 / 安装时间）
├── tools/                  # PowerShell 管理脚本（详见 [tools/README.md](tools/README.md)）
│   ├── README.md           # 脚本使用说明
│   ├── skills-sync.ps1     # 将 skills/ 同步到各客户端（junction）
│   ├── skills-add.ps1      # 添加新技能
│   ├── skills-audit.ps1    # 审计技能目录一致性
│   └── path-resolution.ps1 # 路径解析公共模块（被其他脚本引用）
└── README.md
```

## 技能清单（36 个）

### 📋 需求与流程

| 技能 | 用途 |
| --- | --- |
| `prd-md` | 自由对话式需求收集，对抗歧义，产出可验收的需求文档 |
| `review-requirements` | 审查需求文档质量（8 维度），输出问题清单，只审查不重写 |
| `dev-flow` | 需求定稿后的开发流程编排：编码 subagent → 验收 subagent → 失败分类迭代 |
| `leader` | 把一句话想法拆成 agent 能独立跑完的目标任务书 |
| `author-agents-md` | 依据 OpenAI harness 工程文档生成 / 审查仓库 AGENTS.md |
| `grill-me` | 拷打方案、文档、设计，直到决策树每个分支达成共识 |

### 🎨 前端设计

| 技能 | 用途 |
| --- | --- |
| `frontend-design` | 生成有设计质感、避免 AI 模板感的前端界面与组件 |
| `design-taste-frontend` | 反模板（anti-slop）落地页 / 作品集 / 改版（v2 实验版） |
| `design-taste-frontend-v1` | design-taste-frontend 的 v1 存档版（需精确兼容时用） |
| `gpt-taste` | GPT/Codex 更激进变体：更高布局方差、强 GSAP 方向 |
| `image-to-code` | 先出参考图 → 分析 → 再实现前端 |
| `redesign-existing-projects` | 现有网站 / 应用升级到高级品质，不破坏功能 |
| `high-end-visual-design` | 高端代理级视觉设计：字体、留白、阴影、动效标准 |
| `minimalist-ui` | 编辑风格极简界面：暖色单色、排版对比、扁平 bento |
| `industrial-brutalist-ui` | 工业粗野风：瑞士排版、强对比、实验性布局 |
| `stitch-design-taste` | 迭代语义设计系统，产出 agent 友好的 DESIGN.md |
| `brandkit` | 品牌套件图：配色、字体、身份应用 |
| `imagegen-frontend-web` | 网页设计参考图（hero/落地/多 section，防 slop 美术方向） |
| `imagegen-frontend-mobile` | 移动端屏幕与流程设计参考图 |
| `full-output-enforcement` | 强制完整输出，禁止占位/截断 |
| `impeccable` | 前端全面打磨：UX 审查、视觉层级、可访问性、微交互 |

### 🏗️ 工程与架构

| 技能 | 用途 |
| --- | --- |
| `api-and-interface-design` | 稳定的 API / 模块边界 / 前后端契约设计 |
| `codebase-design` | 深模块（deep module）设计的共享词汇 |
| `code-simplification` | 简化代码提升可读性与可维护性，不改变行为 |
| `improve-codebase-architecture` | 扫描代码库加深机会，输出 HTML 报告并逐项拷打 |
| `security-and-hardening` | 对输入、认证、存储、第三方集成的安全加固 |
| `tdd` | 测试驱动开发（red-green-refactor）与集成测试 |
| `commit-work` | 高质量 git 提交：审阅、拆分、Conventional Commits |
| `merge-branch-to-main` | 功能分支合并到 main 的完整流程（管理员验收制协作） |

### 🔍 研究与检索

| 技能 | 用途 |
| --- | --- |
| `agent-reach` | 全网调研 / 多平台内容获取（小红书、X、B 站、Reddit、GitHub 等 15 平台） |
| `find-skills` | 发现并安装可用技能 |

### 🛠️ 工具与治理

| 技能 | 用途 |
| --- | --- |
| `global-skill-sync` | 跨客户端技能同步 + 一致性校验（触发词：同步技能） |
| `skills-governance-audit` | 检查跨模型技能治理是否符合统一管理规范 |

### 🧠 输出与习惯

| 技能 | 用途 |
| --- | --- |
| `i-have-adhd` | 面向 ADHD 读者的输出规则：行动先行、分步、时间估计、可见进度 |
| `herdr` | 控制 Herdr 终端复用器（要求 HERDR_ENV=1） |
| `neat-freak` | 知识治理收尾：文档、规则、记忆与代码实际状态对齐 |

## 技能来源

| 来源 | 数量 | 说明 |
| --- | --- | --- |
| `local:managed` | 27 | 直接在 `skills/` 下管理的技能，改完运行 `skills-sync.ps1` 同步 |
| `lock:find-skills` | 1 | 锁定自 `vercel-labs/skills`（GitHub） |
| `lock:frontend-design` | 1 | 锁定自 `anthropics/skills`（GitHub） |
| `lock:commit-work` | 1 | 锁定自 `softaworks/agent-toolkit`（GitHub） |
| `lock:leader`、`lock:neat-freak` | 2 | 锁定自 `KKKKhazix/khazix-skills`（GitHub） |
| `lock:design-taste-frontend` 等 4 个 | 4 | 锁定自 `Leonxlnx/taste-skill`（GitHub，重命名安装） |

锁定技能的内容与上游仓库逐字节一致（2026-08-14 校验），来源、目录映射（如 `design-taste-frontend` ← 上游 `taste-skill`）记录在 `.skill-lock.json`，升级需先更新锁定信息。最新的 9 个 taste-skill（`brandkit`、`design-taste-frontend-v1`、`full-output-enforcement`、`gpt-taste`、`image-to-code`、`imagegen-frontend-mobile`、`imagegen-frontend-web`、`industrial-brutalist-ui`、`stitch-design-taste`）于 2026-08-26 经 `npx skills add` 新增，来源哈希记录在 `skills-lock.json`（~/.pi 仓库）。

## 常用操作

```powershell
# 同步技能到 Claude / Cursor / Gemini / Codex（pi 由 global-skill-sync 技能负责）
powershell -File tools/skills-sync.ps1

# 预览同步（不实际写入）
powershell -File tools/skills-sync.ps1 -DryRun

# 添加新技能（本地目录或 GitHub 仓库）
powershell -File tools/skills-add.ps1

# 审计技能目录一致性
powershell -File tools/skills-audit.ps1
```

也可以直接对 pi 说「同步技能」触发 `global-skill-sync` 技能代跑。

## 维护约定

1. **改技能 = 改 `skills/<name>/SKILL.md`**，改完运行 `skills-sync.ps1` 同步。
2. 新增 / 移除技能后，同步更新 `skills-manifest.json` 与 `.skill-lock.json`。
3. 每次改动用 git 提交，提交信息遵循 Conventional Commits（如 `feat(skills): ...`、`fix(skills-xxx): ...`）。
4. 移除技能前先确认没有客户端正在使用（pi 侧使用记录：`~/.pi/agent/skill-usage.jsonl`）。
