# RHYTHM Method

**R**apid, **H**igh-**Y**ield, **T**oken-based, **H**uman-in-loop, **M**anagement

A project management methodology specifically designed for agents with human integration.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

RHYTHM Method is a project management methodology that bridges the gap between traditional human-focused methodologies (Agile, Scrum, Kanban) and pure agentic processes. Unlike traditional methodologies that adapt human processes for agents, RHYTHM starts with agent capabilities and integrates human oversight strategically.

### The Music Metaphor

Just as a conductor (human) guides an orchestra (agents) to create harmonious music, RHYTHM Method ensures that agents work together in a coordinated, controlled flow—even when operating at fast **TEMPO**.

- **TEMPO**: The speed/pace at which agents operate (fast computational speeds)
- **RHYTHM**: The control, flow, and coordination that ensures quality and alignment

**Key Philosophy:** Agents work at a fast tempo, but RHYTHM ensures control, flow, and Human-in-the-Loop (HITL) integration.

## Core Differentiators

- **TEMPO**: Agents operate at fast computational speeds (hours, not weeks)
- **Flow**: Continuous execution with dependency-driven prioritization
- **Control**: Human-in-the-Loop checkpoints at critical decision points
- **Coordination**: Multi-agent collaboration with structured interfaces
- **Precision**: Token-based estimation replaces abstract story points
- **Adaptive**: Methodology evolves based on real-time learnings

## Quick Start

### For Developers

1. **Read the Documentation**: Start with the [Getting Started Guide](docs/02-getting-started.md)
2. **Understand the Concepts**: Review the [Dictionary](docs/03-dictionary.md) and [Principles](docs/04-principles.md)
3. **Set Up Your System**: Use the setup scripts for your project management tool:
   - [GitHub Setup](scripts/github/)
   - [Azure DevOps Setup](scripts/azure-devops/)
   - [Jira Setup](scripts/jira/)
   - [Custom Integration](scripts/custom/)

### For Project Managers

1. **Learn the Methodology**: Read the [Documentation Overview](docs/01-overview.md) and [Workflows](docs/06-workflows.md)
2. **Understand TEMPO**: Review [TEMPO documentation](docs/05-tempo.md) to understand agent speed
3. **Configure Your Tools**: Use the setup scripts to integrate RHYTHM into your existing tools

## Repository Structure

```
RHYTHM-Method/
├── docs/                    # Complete RHYTHM Method documentation
│   ├── overview.md          # Introduction and philosophy
│   ├── dictionary.md        # Key terms and concepts
│   ├── principles.md        # Core principles
│   ├── tempo.md             # Understanding TEMPO
│   ├── workflows.md         # RHYTHM Method workflows
│   ├── work-breakdown-structure.md  # WBS hierarchy
│   ├── estimation.md        # Token-based estimation
│   ├── dependency-management.md     # Dependency-driven prioritization
│   ├── getting-started.md   # Getting started guide
│   ├── best-practices.md    # Best practices and patterns
│   └── tooling.md           # Tools and integrations
│
├── scripts/                 # Setup scripts for different systems
│   ├── github/              # GitHub integration scripts
│   ├── azure-devops/        # Azure DevOps integration scripts
│   ├── jira/                # Jira integration scripts
│   └── custom/              # Custom integration templates
│
└── examples/                # Example implementations
    ├── overview.md         # Examples overview
    ├── github-example/      # GitHub workflow example
    ├── azure-devops-example/ # Azure DevOps example
    └── jira-example/        # Jira example
```

## Documentation

See the [Documentation Overview](docs/01-overview.md) for complete documentation index.

### Getting Started

- **[Getting Started Guide](docs/02-getting-started.md)** - How to adopt RHYTHM Method in your project
- **[Dictionary](docs/03-dictionary.md)** - Key terms and concepts
- **[Principles](docs/04-principles.md)** - Core principles of RHYTHM Method

### Core Concepts

- **[TEMPO](docs/05-tempo.md)** - Understanding TEMPO: the speed/pace at which agents operate
- **[Workflows](docs/06-workflows.md)** - RHYTHM Method workflows and processes

### Methodology

- **[Work Breakdown Structure](docs/07-work-breakdown-structure.md)** - WBS hierarchy (Epic, Feature, Work Unit, Task, Bug)
- **[Estimation](docs/08-estimation.md)** - Token-based estimation methodology
- **[Dependency Management](docs/09-dependency-management.md)** - Dependency-driven prioritization

### Best Practices

- **[Best Practices](docs/10-best-practices.md)** - RHYTHM Method best practices and patterns
- **[Tooling](docs/11-tooling.md)** - Tools and integrations for RHYTHM Method
- **[Common Challenges](docs/12-common-challenges.md)** - Common challenges and solutions

## Setup Scripts

RHYTHM Method can be integrated with various project management tools:

### GitHub

Setup scripts for GitHub Issues, Projects, and Actions:

- [GitHub Setup Guide](scripts/github/overview.md)
- [GitHub Issues Integration](scripts/github/issues/)
- [GitHub Projects Integration](scripts/github/projects/)
- [GitHub Actions Workflows](scripts/github/actions/)

### Azure DevOps

Setup scripts for Azure DevOps Boards, Pipelines, and Repos:

- [Azure DevOps Setup Guide](scripts/azure-devops/overview.md)
- [Azure Boards Integration](scripts/azure-devops/boards/)
- [Azure Pipelines Integration](scripts/azure-devops/pipelines/)

### Jira

Setup scripts for Jira Software, Jira Service Management, and Automation:

- [Jira Setup Guide](scripts/jira/overview.md)
- [Jira Software Integration](scripts/jira/software/)
- [Jira Automation Rules](scripts/jira/automation/)

### Custom Integration

Templates and guides for integrating RHYTHM Method with other tools:

- [Custom Integration Guide](scripts/custom/overview.md)
- [API Templates](scripts/custom/api-templates/)
- [Webhook Templates](scripts/custom/webhook-templates/)

## Key Features

### For Agents

- **Speed**: Execution cycles (hours) instead of sprints (weeks)
- **Precision**: Token-based estimation instead of abstract story points
- **Automation**: Automated dependency analysis and prioritization
- **Structure**: Machine-readable specifications and workflows
- **Efficiency**: No unnecessary meetings or delays

### For Humans

- **Human-in-the-Loop (HITL) Integration**: Human oversight at critical decision points
- **Strategic Input**: Human judgment for business decisions
- **Context**: Human-readable explanations and rationale
- **Control**: Configurable approval gates and overrides
- **Collaboration**: Human-AI partnership, not replacement

## Why RHYTHM Method?

Traditional project management methodologies were designed for human teams. When applied to AI agent teams, they create friction, overhead, and missed opportunities. Conversely, pure agentic processes designed for computational efficiency exclude humans and create information overload.

**RHYTHM Method bridges this gap** by creating a methodology that leverages agent capabilities while maintaining essential human oversight and strategic input.

## Alternative to Traditional Methodologies

RHYTHM Method is an **alternative** to:

- Spec-Driven Development (SDD)
- Scrum
- Agile
- Kanban
- Traditional project management

RHYTHM Method is **not** a modification of these methodologies—it's a new methodology designed specifically for agents with human integration.

## Contributing

Contributions are welcome! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- **[Baton Framework](https://github.com/Conductus-Labs/baton-framework)** - The foundational instruction architecture that underlies RHYTHM Method
- **[Baton CLI](https://github.com/Conductus-Labs/baton-framework)** - Tooling for scaffolding RHYTHM Method into projects
- **[Baton Platform](https://baton.conductuslabs.com)** - Full Agentic Development Environment with RHYTHM Method workflows

## About Conductus Labs

RHYTHM Method is developed by **Conductus Labs Ltd**, a UK-based AI application layer company.

- **Website**: [conductuslabs.com](https://conductuslabs.com)
- **Product**: [Baton Platform](https://baton.conductuslabs.com) - AI Orchestration Platform (SaaS)

---

**Built with ❤️ in the UK**
