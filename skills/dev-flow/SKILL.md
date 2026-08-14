---
name: "dev-flow"
description: "开发流程编排技能（O1）。需求文档定稿后，在 goal 模式下编排编码→验收→判断循环：启动编码 subagent（只编码+tdd 自测+模块提交）、启动验收 subagent（独立验收出报告）、失败分类与迭代控制，直到验收清单全部通过。触发：开发启动、goal 声明走 dev-flow、按需求文档实施。不用于需求沟通（那是 prd-md）。"
version: 1
created: "2026-08-14"
updated: "2026-08-14"
---
## When to Use
goal 模式激活且目标指向已定稿需求文档时（goal 文本引用需求文档+验收清单+声明走 dev-flow）；需要编排编码/验收子 agent 完成需求实施时。不使用：需求沟通阶段（prd-md 负责）、纯单文件小改动。

## Procedure
1. 准备：读需求文档 + 验收清单，确认落盘位置（项目既有约定优先，见 references/agent-instructions.md），确认开发顺序（按 A2 依赖）
2. 编码阶段：启动编码 subagent（用 worker agent，async:true，fresh context，timeoutMs = 86400000ms（24 小时），禁止依赖默认 30 分钟），指令模板见 references/agent-instructions.md；编码 agent 只编码+自测+模块提交，禁止改需求文档和验收清单
3. 验收阶段：编码 subagent 报告完成后，启动验收 subagent（用 reviewer agent，async:true，fresh context，timeoutMs = 86400000ms（24 小时），禁止依赖默认 30 分钟），指令模板见 references/agent-instructions.md；验收 agent 只看验收清单+运行命令，不看实现
4. 判断阶段：主 agent 读验收报告 → 全部通过（人工项已确认）→ 阶段5；有失败 → 按失败分类（编码 bug / 需求缺陷 / 环境数据）+ 输出失败原因摘要 → 对应处理（回编码带失败清单 / 回 prd-md 变更 / 处理环境重验）
5. 完成：DoD 满足 → 验收报告归档（默认 <项目文档目录>/archive/验收记录-<名称>-V<N>.md）→ 向用户汇报 → goal 完成
6. 循环控制：编码→验收 ≤ 3 轮；同一验收项连续失败 2 次提前升级给用户；每轮必出失败原因摘要；超限停止循环汇总给用户决策
7. 并行：多个独立需求点可拆多编码 agent 并行（worktree 隔离），默认单 agent 按依赖顺序执行

## Pitfalls
- 主 agent 是编排者，不亲自写代码（防自证陷阱）
- 编码 agent 禁止改需求文档和验收清单；验收标准有疑问 → 回主 agent 走 prd-md 变更流程，不静默修改
- 验收 agent 必须 fresh context：只看验收清单+运行命令，不读实现代码、不读需求描述
- 验收 agent 禁止改实现代码和已有测试（允许新增独立补充测试文件）；[E2E-人工] 标待人工确认，附操作说明；禁止自称人工验证
- 涉及前端样式编码时，编码 agent 必须先读取前端设计技能与项目 DESIGN 规范（如 DESIGN.md），禁止模板化样式
- 涉及后端/API 编码时，编码 agent 必须先读取 api-and-interface-design / security-and-hardening 技能，API 端点遵循需求文档 B4 冻结的 seams
- 编码 agent 必须先读取 tdd 技能（~/.agents/skills/tdd/SKILL.md）再写测试：按需求文档 B4 冻结的 seams 写测试，测试期望值来自验收清单业务口径，不从实现倒推（防同义反复）；禁止实现耦合/同义反复/水平切片
- 不跳过验收直接宣称完成：goal 完成 = 验收清单全部通过（人工项已确认）
- 落盘位置：项目既有约定（AGENTS.md/docs README）优先，无约定用默认路径
- 验收不通过回编码时必须带失败项清单，不允许无目标重来

## Verification
1. 验收报告存在且逐条有状态（通过/失败/未执行）+ 证据（命令输出/截图/操作记录）
2. [E2E-人工] 项有待用户确认标记，未被 AI 自行声称通过
3. 失败分类正确（编码/需求/环境），每轮有失败原因摘要
4. 循环次数 ≤ 3，无死循环；连续失败 2 次的验收项已升级
5. 需求文档和验收清单未被编码 agent 修改（git 可查）
6. goal 完成时验收清单全部通过（或人工项已由用户确认）
7. 验收报告已归档，路径可查