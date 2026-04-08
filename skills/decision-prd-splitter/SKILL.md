---
name: decision-prd-splitter
description: 将决策文档严格逐条拆分到对应功能 PRD 并执行防遗漏校验。触发词：将文档进行拆分、文档拆分、拆分到PRD、按决策拆分到PRD。用于一个源决策文档需要落位到多个页面 PRD 且要求不遗漏的场景。
---

# Decision PRD Splitter

将“决策文档”拆分到对应模块/页面 PRD，并强制执行逐条覆盖校验。

## Trigger Phrases
- 将文档进行拆分
- 文档拆分
- 拆分到PRD
- 按决策拆分到PRD

## Input Contract
- 必填：源决策文档路径（Markdown）。
- 可选：目标范围（模块/页面）。
- 可选：仅检查不落盘（check-only）。
- 可选：覆盖例外文件（overrides JSON），用于 `not-applicable` 条目给出理由。

## Output Contract
- 迁移清单：新增/修改了哪些 PRD 文档。
- 遗漏清单：未覆盖条目、原因、建议落位。
- 最终核对结论：`通过` / `不通过`。
- 覆盖矩阵摘要：`covered / missing / not-applicable(with reason)` 计数。

## Hard Rules
- 默认执行“严格逐条迁移”，不是“规则级抽样迁移”。
- 固定流程：`抽取条目 -> 建立映射 -> 逐条迁移 -> 逐条回查 -> 出具缺口报告`。
- 条目粒度必须下沉到原子项：表格行、规则 bullet、状态规则、校验规则、交互规则。
- 映射优先级：
  - 先使用“拆解落位索引表”。
  - 无索引表时按模块地图和页面职责推断。
- 收尾门禁：存在任一“missing”或“未给出理由的 not-applicable”时，不得宣告完成。

## Workflow
1. 读取源决策文档，定位“拆解落位索引表”与来源段落。
2. 按来源段落抽取原子项，并给每项分配唯一 ID。
3. 依据目标模块文档建立映射，执行差异迁移。
4. 运行覆盖矩阵脚本，得到逐条状态。
5. 输出迁移清单、遗漏清单与最终结论。

## Coverage Script
- 脚本路径：`scripts/prd-coverage-matrix.ps1`
- 示例命令：
`powershell -ExecutionPolicy Bypass -File .\scripts\prd-coverage-matrix.ps1 -SourceDoc <决策文档路径> -DocsRoot <docs目录路径> -OutputJson <输出json路径>`

### Overrides（可选）
当条目确实不适用时，使用覆盖文件标注为 `not-applicable` 并写明理由。

JSON 示例：
```json
[
  {
    "source": "#### 某来源段落",
    "item": "某条原子项文本",
    "status": "not-applicable",
    "reason": "当前版本已下线对应端能力"
  }
]
```

## Completion Gate
- `missing > 0`：结论必须为“不通过”。
- `not-applicable` 无理由：结论必须为“不通过”。
- 仅当所有条目状态为 `covered` 或 `not-applicable(有理由)`，结论才可为“通过”。
