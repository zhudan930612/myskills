---
name: product-blueprint-architecture
description: Use when creating, revising, or explaining a reusable product blueprint, business blueprint, or product architecture diagram for different business domains, especially when the work needs to connect product subjects, entry carriers, core capability modules, interaction relationships, data assets, and a companion source-explanation document.
---

# Product Blueprint Architecture

## Overview

Create reusable, audience-aware product blueprints that explain product subjects, entry carriers, capability modules, interaction relationships, and data assets without collapsing into PRD detail or pure system architecture.

## Workflow

1. Read the current source documents first.
   Required sources usually include product context, product planning, module docs, workflow notes, and any normative or policy documents explicitly named by the user.

2. Decide the blueprint type before drawing.
   Common distinctions:
   - Product blueprint: business subjects, entry carriers, capabilities, data flow, data foundation
   - System architecture: technical layers, middleware, deployment, interfaces
   - PRD structure: detailed rules, fields, states, validations

3. Lock five things before producing the blueprint.
   - Audience: leadership, sales, PM, implementation, regulator
   - Scope: current state, future plan, or both
   - Main subjects: single platform, dual subjects, or value-chain view
   - Abstraction level: capability level, secondary capability level, or cross-system relationship
   - Output shape: only the blueprint, blueprint plus explanation document, or blueprint plus speaking notes

4. Choose the blueprint pattern that matches the business, instead of forcing one structure.
   Common patterns:
   - Single-subject platform: one main product with layered capabilities
   - Dual-subject coordination: two coordinated business subjects with interaction in the middle
   - Value-chain view: upstream, operating core, downstream, and supporting layers
   - Ecosystem view: product core plus partners, external systems, and support services

   For each pattern, decide whether to show:
   - Entry/carrier layer
   - Capability layer
   - Support/intelligence layer
   - Data or asset layer
   - External collaboration or integration layer

5. Keep blueprint content at blueprint granularity.
   Include:
   - Product subjects
   - Entry carriers such as H5, mini-program, app, terminal, PC backend
   - Core capability modules
   - Key labels that help understand module scope
   - Interaction or flow direction between subjects
   - Data foundations, data assets, or operating assets

   Do not include:
   - Full PRD rules
   - Field-level validation logic
   - Backend implementation details
   - Invented platform layers with no source basis
   - Domain-specific modules that cannot be traced to the current business

6. Treat labels as source-controlled content.
   For every module or tag, classify it into one of three buckets:
   - Direct source term from current documents
   - Stable productized abstraction derived from current documents
   - User-confirmed addition in the current discussion

   Avoid imagined labels. If a label cannot be traced, either remove it or mark it as a user-confirmed addition in the explanation document.

7. Build a companion explanation document when source traceability matters.
   The explanation document should be easy to scan when leadership asks “why is this module here?” or “where did this label come from?”.
   Use a structure that matches the blueprint pattern:
   - Overall blueprint sources
   - Main subject or main layer source basis
   - Interaction, external collaboration, or data layer source basis
   - Which labels are direct source terms vs productized abstractions vs user-confirmed additions

8. When normative documents are cited, include the original wording in the explanation document.
   Do not only write the document name. Add the original text excerpt that supports the module or label so the explanation document can be read independently.

9. Generate the blueprint in the format that matches the need.
   - Use HTML for a visual deliverable that will be reviewed, iterated, or presented
   - Use Markdown outline when the user only needs a text blueprint
   - Use both when the user needs a visual artifact and a traceability note

   When generating HTML, keep the layout presentation-oriented, not like a generic admin page.

10. Check consistency before finishing.
   Verify:
   - All main areas use comparable granularity
   - Interaction labels read correctly in the chosen layout
   - Entry carriers are realistic for the business scenario
   - Data foundation terms do not imply nonexistent shared platforms unless confirmed
   - The explanation document and the blueprint use the same names
   - The chosen pattern actually matches the business, rather than mirroring a past case

## Blueprint Patterns

### Dual-subject pattern

Use when the product contains two clearly different but coordinated business subjects.

Recommended sections:
- Subject A
- Data flow and interaction
- Subject B
- Local data foundation under each subject

### Single-subject pattern

Use when the product is one main platform and the goal is only to show modules, entries, and support layers.

Recommended sections:
- Entry/carrier layer
- Capability layer
- Support/intelligence layer
- Data foundation
- External integrations if needed

### Value-chain pattern

Use when the product is better understood as a continuous business chain instead of separate subjects.

Recommended sections:
- Upstream inputs or partners
- Core operating platform
- Downstream service or customer touchpoints
- Support and intelligence layer
- Data assets or operational assets

### Ecosystem pattern

Use when the main question is how the product coordinates with external parties and surrounding systems.

Recommended sections:
- Product core
- Internal support capabilities
- External systems and partners
- Exchange or interaction relationships
- Shared or local data assets

## Explanation Document Rules

Write the explanation document for lookup, not for storytelling.

Include:
- Why the overall structure is used
- Source file names for each module or layer group
- Original wording when a normative document is cited
- Notes for labels that are productized abstractions
- Notes for labels explicitly added by the user during the discussion

Do not rely on clickable links. The document must still make sense when printed or copied elsewhere.

## Common Mistakes

- Treating a product blueprint like a technical architecture diagram
- Using abstract labels that do not map to any source
- Mixing current-state modules with future ideas without visual or textual distinction
- Letting one area show capability modules while another area shows backend menus
- Writing a source explanation document that only points to file names but does not quote the supporting normative text
