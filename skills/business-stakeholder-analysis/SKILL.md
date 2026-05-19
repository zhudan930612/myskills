---
name: business-stakeholder-analysis
description: Use when analyzing stakeholders for a business, product, platform, commercial model, or product architecture discussion, and when the user asks to 生成相关方分析文档. Use especially when the user provides source materials and needs a Markdown document that identifies stakeholder roles, needs, scenarios, architecture requirements, relationships, business rules, and boundary notes before creating a product architecture diagram, PRD, or business blueprint.
---

# Business Stakeholder Analysis

## Purpose

Create a stakeholder analysis working draft from business materials. The output should clarify who participates, who is responsible, who benefits, who pays, who regulates, who delivers, and what each party requires from the product architecture.

This skill is for analysis and discussion groundwork. It does not create a full PRD, draw an architecture diagram, or force a past domain pattern onto the current business.

## Workflow

1. Read the source materials first.
   - Use all files explicitly named by the user.
   - If the user provides meeting notes, policy materials, PRD drafts, architecture drafts, or business analysis files, extract stakeholder evidence from the actual wording.
   - Keep source names visible in the output header.

2. Clarify the product relationship before listing stakeholders.
   Decide whether the business is:
   - one platform;
   - multiple coordinated platforms;
   - a platform plus external systems;
   - a service process supported by tools;
   - a business ecosystem with regulators, operators, service providers, and customers.

   Write this first. A stakeholder analysis that skips product relationship boundaries usually becomes a shallow organization list.

3. Identify stakeholders by business role, not only by organization name.
   Common role types include:
   - regulator or policy driver;
   - responsibility owner;
   - customer or payer;
   - end user or service recipient;
   - service executor;
   - platform operator;
   - technical provider;
   - standard setter or credibility backer;
   - data provider or data user;
   - channel partner or ecosystem partner.

4. Create a stakeholder overview table.
   Required columns:
   - Stakeholder;
   - Position in the system;
   - Core needs;
   - Participation depth.

5. Analyze each stakeholder with the same four sections.
   - Role positioning;
   - Core needs;
   - Core scenarios;
   - Requirements for product architecture.

6. Analyze key relationships between stakeholders.
   Focus on responsibility, data flow, service flow, money or settlement flow, evaluation flow, and compliance or governance boundaries.

7. Extract preliminary business rules.
   Include only rules supported by source materials or clearly marked as inferred. Useful groups:
   - subject responsibility rules;
   - data flow rules;
   - service execution rules;
   - quality or evaluation rules;
   - fee, revenue, or settlement rules;
   - compliance, regulation, or risk expression rules;
   - platform priority and boundary rules.

8. Prepare the next architecture-diagram inputs.
   Summarize what a later product architecture diagram should show:
   - stakeholder layer;
   - business flow layer;
   - capability module layer;
   - data asset layer;
   - boundary warnings.

## Output Template

Use Markdown. Follow this structure unless the user asks for a different format:

```markdown
# {Business or Product Name}相关方分析

**日期**：YYYY-MM-DD
**来源**：`source file or material name`
**用途**：用于后续生成产品架构图 / 业务架构图 / PRD / 方案讨论，先明确相关方、诉求、场景和边界。

---

## 一、先明确产品关系

Explain the product, platform, service, or ecosystem relationship before listing stakeholders.

---

## 二、相关方总览

| 相关方 | 在体系中的定位 | 核心诉求 | 参与深度 |
|---|---|---|---|

---

## 三、{相关方A}

### 3.1 角色定位

### 3.2 核心诉求

### 3.3 核心场景

### 3.4 对产品架构的要求

---

## 四、{相关方B}

Repeat the same four-section structure for each important stakeholder.

---

## 十、相关方之间的关键关系

### 10.1 {相关方A} 与 {核心平台 / 相关方B}

---

## 十一、核心业务规则初稿

### 11.1 主体责任规则

### 11.2 数据流转规则

### 11.3 服务执行规则

### 11.4 质量评价规则

### 11.5 费用 / 收益 / 结算规则

### 11.6 合规 / 监管 / 风险表述规则

### 11.7 平台优先 / 边界规则

---

## 十二、下一步生成架构图时应体现的内容

### 12.1 相关方层

### 12.2 业务流层

### 12.3 能力模块层

### 12.4 数据资产层

### 12.5 边界提示

---

## 十三、当前建议的架构图主标题
```

Adjust section numbering when the stakeholder count differs. Keep the same logical order.

## Writing Rules

- Write in Chinese unless the user asks otherwise.
- Start with product relationship boundaries; do not jump directly into a stakeholder list.
- Core needs must be concrete business verbs or outcomes, such as "拿业务", "控风险", "做合规", "少负担", "能结算", "有证明", "可评价", "可上报", or equivalent domain-specific expressions.
- Product architecture requirements must translate into modules, permissions, data, workflows, evaluation mechanisms, integrations, or boundaries.
- Distinguish responsibility owner, platform capability provider, service executor, regulator, payer, and beneficiary. Do not merge them because one organization participates in multiple roles.
- If source evidence is insufficient, write "待确认" instead of inventing facts.
- Mark material-derived conclusions separately from inferred recommendations when the distinction matters.
- Keep the tone suitable for internal product and business architecture discussion: clear, structured, and decision-oriented.

## Boundary Rules

- Do not turn this into a full PRD with fields, states, and validation rules.
- Do not draw the architecture diagram unless the user asks for it.
- Do not assume the central platform replaces the responsibility of regulators, insurers, service organizations, government departments, or other external parties.
- Do not hard-code roles from one domain into another domain. Re-identify stakeholders from the current source material.
- Do not describe external compliance conclusions as final legal or regulatory determinations unless the source explicitly supports that.

## Quality Check

Before finalizing, verify:

- The first section explains the product relationship clearly.
- Every major stakeholder in the source material appears in the overview table or is intentionally excluded with a reason.
- Every stakeholder has role positioning, needs, scenarios, and architecture requirements.
- Key relationships explain responsibility and flow, not only cooperation slogans.
- Business rules are traceable to source material or clearly marked as inferred.
- Boundary warnings prevent likely architecture mistakes.

