---
name: author-agents-md
description: 当用户提出"生成agents""写agents""生成 AGENTS.md""审查agents""检查 AGENTS.md""重写 agents"等类似请求，且目标是依据 OpenAI 官方 harness engineering 文档生成或审查仓库 AGENTS.md 时使用。
---

# 生成与审查 AGENTS.md

这个技能只做两件事：

1. 根据 OpenAI 官方 `harness engineering` 文档要求生成 `AGENTS.md`
2. 审查现有 `AGENTS.md` 是否符合该文档要求

## 触发词

- 生成agents / 写agents / 生成 AGENTS.md / 新建 AGENTS.md
- 重写 agents / 收敛 agents / 瘦身 AGENTS.md
- 审查agents / 检查 agents / 审查 AGENTS.md / 检查 AGENTS.md
- 看看 agents 对不对 / 这个 AGENTS.md 合规吗

## 核心原则

- 地图不是手册：`AGENTS.md` 是给智能体的导航图，仓库本身才是记录系统
- 越小越好：短、平、快，可快速扫描；论证与细节放 references，不堆在主文件
- 渐进式披露：大领域指向索引文档，细节回到版本化文档
- 规则可锚定：每条规则指向文件、命令或检查器，拒绝空泛口号
- 先落盘再写规则：只存在于聊天、会议纪要里的稳定规则，先沉淀到仓库文件才能进 `AGENTS.md`
- 禁止自动生成：不要用初始化脚本生成 `AGENTS.md`，会塞满"通用有用"内容

## 任务一：生成 AGENTS.md

1. 查看仓库根目录、现有顶层文档和关键脚本
2. 找出真实 source of truth：架构 / 产品需求 / 计划 / 质量验证 / 安全约束
3. 缺少关键文档就记录 gap，不要靠写长来补
4. 生成简短 `AGENTS.md`，约 60 到 120 行
5. 每条规则锚定到：版本化文档 / 脚本命令 / lint-CI-checker / 稳定本地约定
6. 某条规则经常出错时，建议升级为脚本、lint 或 CI 检查
7. 输出：新 `AGENTS.md` + 缺失信息清单 + 可选后续治理建议

推荐结构：仓库目的 / 仓库地图 / 事实来源 / 工作闭环 / 硬约束 / 不应写在这里

## 任务二：审查 AGENTS.md

逐项检查：

1. 是"地图"不是"手册"
2. 是否明确告诉智能体下一步去哪个文件看细节
3. 主要规则是否都能指向真实文件、命令或检查器
4. 是否重复了 deeper docs 该持有的长内容
5. 是否依赖未落盘的人类记忆或外部聊天上下文
6. 是否缺少架构、产品、计划、验证这些高频入口
7. 是否存在陈旧、无法校验或无 owner 的规则
8. 每条规则归属是否恰当：根 `AGENTS.md`（全仓库通用）/ 独立文件（单一领域）/ 嵌套文档树（可分层）；归属错了给出迁移建议

审查输出三部分：结论（通过/不通过/部分符合）+ 问题清单（按严重度）+ 修订建议（迁移到哪里、补什么链接、补什么校验）

## 参考文件

- `references/harness-engineering-agents-md.md`：官方要求提炼、"为什么大文件失败"的论证、规则归属决策
- `assets/AGENTS.template.md`：生成 `AGENTS.md` 的起始模板
