# Project Setup

This document explains how to set up a project to use RHYTHM Method, including the two foundational configuration files.

---

## Overview

Every RHYTHM Method project requires two configuration files:

1. **Project.Manifest.md** - The WHAT, WHY, WHO, and SUCCESS METRICS
2. **project.config.yml** - Project configuration for agents

These files guide all agent activity throughout the project lifecycle.

---

## Project.Manifest

**Location:** `.baton/Project.Manifest.md`
**Format:** Markdown with structured sections
**Created By:** BA (Baton Agent) during Project Initialisation
**Updated:** Quarterly or when major project changes occur

### Purpose

High-level project understanding that captures:
- **WHAT**: What we're building
- **WHY**: Business value and objectives
- **WHO**: Stakeholders and team members
- **SUCCESS METRICS**: How we measure success

### Key Sections

1. **Project Overview**
   - What we're building
   - Why this project exists
   - Project type (web-app, cli, library, etc.)

2. **Stakeholders**
   - Primary users
   - Project team
   - Success stakeholders

3. **Goals & Success Metrics**
   - Primary goals
   - Key Performance Indicators (KPIs)
   - Success criteria

4. **Scope & Constraints**
   - In scope
   - Out of scope
   - Known constraints (technical, resource, business)

5. **Technical Standards**
   - Coding standards (reference to `.baton/standards/coding-standards.yml`)
   - Testing requirements
   - Security requirements
   - Documentation requirements

6. **Architecture Overview**
   - High-level architecture
   - Key architectural decisions
   - Technology stack

7. **Dependencies & Integration**
   - External dependencies
   - Integration points

8. **Risks & Mitigation**
   - Known risks with impact, probability, mitigation strategies

9. **Related Documents**
   - Links to Project.Config, standards, external resources

10. **Change Log**
    - Version history

### Template

See full template at: `baton-projects/src/templates/project.manifest.md`

### Example Snippet

```markdown
# Project Manifest: E-Commerce Platform

**Version:** 1.0.0
**Last Updated:** 2025-01-15
**Status:** Active

## Project Overview

### What We're Building

A modern e-commerce platform with real-time inventory management, AI-powered product recommendations, and seamless payment processing for small to medium-sized online retailers.

### Why This Project Exists

Small retailers lack affordable e-commerce solutions that provide enterprise-level features like real-time inventory sync and personalized recommendations. This platform democratizes advanced e-commerce capabilities for SMBs.

### Project Type

web-app

## Goals & Success Metrics

### Primary Goals

1. Launch MVP with 50 beta customers by Q2 2025
2. Achieve 99.9% uptime for payment processing
3. Reduce cart abandonment by 30% through AI recommendations

### Key Performance Indicators (KPIs)

| Metric | Target | Current | Measurement Method |
|--------|--------|---------|-------------------|
| Active Merchants | 50 | 12 | Database count |
| Transaction Success Rate | 99.9% | 98.5% | Payment gateway logs |
| Cart Conversion Rate | 45% | 32% | Analytics platform |
```

---

## Project.Config

**Location:** `.baton/project.config.yml`
**Format:** Pure YAML (no frontmatter)
**Created By:** BA (Baton Agent) during Project Initialisation
**Updated:** Frequently as project configuration changes

### Purpose

Operational configuration that agents use to understand:
- Available tools and resources
- Source control and project management integration
- GenAI configuration (models, token budgets)
- RHYTHM settings (TEMPO, loop thresholds, HITL triggers)
- Baton configuration (agents, workflows)

### Key Sections

```yaml
version: 1.0.0

project:
  name: "project-name"
  type: "web-app|cli|library|etc"

source_control:
  provider: "github|gitlab|bitbucket"
  repository: "url"
  default_branch: "main"

project_management:
  type: "RHYTHM-Method|Scrum|Agile|Kanban|Waterfall|none"
  provider: "github|jira|azure-devops|linear|local"
  integration: {}

genai:
  - name: "cursor|claude|gemini|openai"
    preferred_models:
      planning: "sonnet|opus"
      execution: "sonnet|haiku"
    integration_type: "ide-native|api|mcp"
    token_budgets: {}
    primary: true

mcp: {}

rhythm:
  default_tempo: "moderate"  # high | moderate | controlled
  max_challenge_loops: 3
  max_review_loops: 3
  max_quality_loops: 3
  hitl_triggers:
    - "quality_score < 80"
    - "challenge_conflict"
    - "dependency_conflict"

baton:
  inventory_path: ".baton/baton-inventory.yml"
  default_agents: ["rhythm-agent", "project-manager-agent"]

preferences:
  auto_save_context: true
  verbose_logging: false
  check_for_update: true
  send_feedback: false
  coding_standards: {}
  testing_requirements: {}

metadata:
  created: "timestamp"
  last_updated: "timestamp"
  team_members: []
```

### Template

See full template at: `baton-projects/src/templates/project.config.yml`

### RHYTHM Configuration Section

The `rhythm` section is critical for controlling RHYTHM Method behavior:

```yaml
rhythm:
  default_tempo: "moderate"        # Controls HITL checkpoint frequency
  max_challenge_loops: 3           # Threshold for Challenge Cycle HITL trigger
  max_review_loops: 3             # Threshold for Review loop HITL trigger
  max_quality_loops: 3            # Threshold for Quality loop HITL trigger
  hitl_triggers:                  # Conditions that trigger HITL checkpoints
    - "quality_score < 80"        # Quality score below threshold
    - "challenge_conflict"        # Unresolved challenge conflicts
    - "dependency_conflict"       # Dependency conflicts detected
    - "critical_path_blocked"     # Critical path work is blocked
```

**TEMPO Values:**
- `"high"`: ~3-5 HITL gates per feature cycle (fast, high autonomy)
- `"moderate"`: ~8-12 HITL gates per feature cycle (balanced, default)
- `"controlled"`: ~15-20 HITL gates per feature cycle (comprehensive oversight)

**Loop Thresholds:**
- Define how many iterations before HITL intervention
- Default: 3 for all loop types
- Adjustable based on team preference and work complexity

**HITL Triggers:**
- Define conditions that trigger HITL checkpoints
- Can be customized per project
- Supports quality scores, conflicts, blockers

---

## Setup Process

### For New Projects

1. **User initiates RHYTHM Method setup**
2. **BA runs Project Interview Process:**
   - Asks: "What is the end goal of this project?"
   - Generates dynamic follow-up questions
   - Creates Project.Manifest from template
   - Creates Project.Config from template
3. **HITL Checkpoint**: User reviews and approves both files
4. **BA creates `.baton/` directory structure**
5. **Project state set to OPEN**

### For Existing Projects

1. **User initiates RHYTHM Method setup**
2. **BA scans and analyzes existing project files:**
   - Source code structure
   - Existing documentation
   - Package files (package.json, requirements.txt, etc.)
   - Existing project management artifacts
3. **BA runs Project Interview Process with findings:**
   - Pre-populates answers based on scan
   - Asks clarifying questions
   - Creates Project.Manifest from template + scan data
   - Creates Project.Config from template + detected configuration
4. **HITL Checkpoint**: User reviews and approves both files
5. **BA creates `.baton/` directory structure**
6. **BA optionally imports existing work items** (Features, Work Units, etc.)
7. **Project state set to OPEN**

---

## Best Practices

### Project.Manifest

1. **Keep it stable**: Update quarterly or for major changes only
2. **Be specific in goals**: Measurable, time-bound objectives
3. **Document constraints early**: Technical, resource, business constraints
4. **Reference standards, don't duplicate**: Link to separate standards files
5. **Maintain change log**: Track major project evolution

### Project.Config

1. **Start with Moderate TEMPO**: Adjust based on experience
2. **Set realistic loop thresholds**: Too low = excessive HITL; too high = wasted cycles
3. **Configure HITL triggers for your domain**: Security-critical? Lower quality threshold
4. **Keep token budgets realistic**: Based on historical data or estimates
5. **Update frequently**: Operational config changes often

### Both Files

1. **Version control both files**: Track all changes
2. **Review during Cycle Review**: Ensure configuration still appropriate
3. **Keep machine-readable and human-readable**: YAML/JSON + markdown documentation
4. **Make them accessible to all agents**: All agents read these files frequently

---

## File Locations

```text
project-root/
├── .baton/
│   ├── Project.Manifest.md          # High-level project understanding
│   ├── project.config.yml           # Operational configuration
│   ├── baton-inventory.yml          # Installed agents, workflows, knowledge
│   └── standards/                   # Standards referenced by Manifest
│       ├── coding-standards.yml
│       ├── testing-requirements.yml
│       ├── security-requirements.yml
│       └── documentation-requirements.yml
```

---

## See Also

- [Project Initialisation Cycle](03-flow-cycles.md#cycle-project-initialisation)
- [Project Interview Process](05-processes.md#project-interview-process)
- [TEMPO Configuration](10-tempo-configuration.md)
- [Getting Started](12-getting-started.md)

---

## Navigation

**Previous:** [TEMPO Configuration](10-tempo-configuration.md) - TEMPO levels and configuration
**Next:** [Getting Started](12-getting-started.md) - How to adopt RHYTHM Method

---

## Change History

| Version | Date       | Author | Description                                                     |
| ------- | ---------- | ------ | --------------------------------------------------------------- |
| 1.0.0   | 2025-12-14 | Agent  | Complete project setup documentation with templates             |
