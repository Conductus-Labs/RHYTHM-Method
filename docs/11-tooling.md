# RHYTHM Method Tooling

**Version:** 1.0.0  
**Last Updated:** 2025-11-26  
**Status:** Initial Draft - For Review

## Overview

RHYTHM Method can be integrated with various project management tools. This document provides an overview of available tooling and integration options.

## Supported Tools

### GitHub

GitHub integration provides RHYTHM Method workflows using:

- **GitHub Issues**: For work items (Features, Work Units, Agent Tasks)
- **GitHub Projects**: For project management and visualization
- **GitHub Actions**: For automation and workflows

**Setup**: See [GitHub Setup Guide](scripts/github/overview.md) *(Coming Soon)*

**Features**:
- Issue templates for RHYTHM Method work items
- Project templates for RHYTHM Method projects
- Actions workflows for automation
- Labels for work item types

### Azure DevOps

Azure DevOps integration provides RHYTHM Method workflows using:

- **Azure Boards**: For work items and project management
- **Azure Pipelines**: For automation and CI/CD
- **Azure Repos**: For version control integration

**Setup**: See [Azure DevOps Setup Guide](scripts/azure-devops/overview.md) *(Coming Soon)*

**Features**:
- Work item types for RHYTHM Method
- Board configuration for RHYTHM Method workflows
- Pipeline templates for automation
- Queries for RHYTHM Method work items

### Jira

Jira integration provides RHYTHM Method workflows using:

- **Jira Software**: For work items and project management
- **Jira Automation**: For workflow automation
- **Jira Service Management**: For service-based workflows

**Setup**: See [Jira Setup Guide](scripts/jira/overview.md) *(Coming Soon)*

**Features**:
- Issue types for RHYTHM Method
- Workflow configuration for RHYTHM Method
- Automation rules for RHYTHM Method processes
- Board configuration for RHYTHM Method

### Custom Integration

Custom integration templates for other tools:

- **REST API Templates**: For REST API integrations
- **GraphQL API Templates**: For GraphQL API integrations
- **Webhook Templates**: For webhook-based integrations

**Setup**: See [Custom Integration Guide](scripts/custom/overview.md) *(Coming Soon)*

## Tool Features

### Work Item Management

All tools support RHYTHM Method work items:

- **Project Manifest**: Top-level project container
- **Feature**: Deliverable functionality units
- **Work Unit**: Single execution cycle work
- **Agent Task**: Smallest executable units
- **Bug**: Defect tracking

### Dependency Tracking

Dependency tracking features:

- **Dependency Graph**: Visual dependency representation
- **Dependency Detection**: Automated dependency detection
- **Dependency Resolution**: Tracking dependency resolution
- **Critical Path**: Critical path identification

### Estimation

Token estimation features:

- **Token Calculation**: Calculate tokens for work items
- **Roll-Up Estimation**: Roll up from tasks to features
- **Throughput Tracking**: Track agent throughput rates
- **Capacity Planning**: Capacity planning based on tokens

### Quality Gates

Quality gate features:

- **Automated Checks**: Automated quality checks
- **HITL Integration**: Human-in-the-loop checkpoints
- **Quality Metrics**: Quality metrics tracking
- **Validation**: Specification and deliverable validation

### Reporting

Reporting features:

- **Real-Time Dashboards**: Real-time work status dashboards
- **Progress Tracking**: Progress tracking and metrics
- **Cycle Analysis**: Execution cycle analysis
- **Dependency Reports**: Dependency analysis reports

## Integration Patterns

### Pattern 1: Native Integration

Use native tool features for RHYTHM Method:

- **Work Item Types**: Use tool's work item types
- **Workflows**: Use tool's workflow features
- **Automation**: Use tool's automation features
- **Reporting**: Use tool's reporting features

**Benefits**: Leverages existing tool capabilities

### Pattern 2: Custom Integration

Build custom integration using APIs:

- **REST APIs**: Use REST APIs for integration
- **GraphQL APIs**: Use GraphQL APIs for integration
- **Webhooks**: Use webhooks for event-driven integration
- **Custom Scripts**: Use custom scripts for automation

**Benefits**: Full control over integration

### Pattern 3: Hybrid Integration

Combine native and custom integration:

- **Native Features**: Use native features where possible
- **Custom Extensions**: Extend with custom integrations
- **API Integration**: Use APIs for advanced features
- **Script Automation**: Use scripts for automation

**Benefits**: Best of both approaches

## Setup Scripts

Setup scripts are available for each tool:

### GitHub Scripts

- **Issue Templates**: Create RHYTHM Method issue templates
- **Labels**: Create RHYTHM Method labels
- **Project Templates**: Create project templates
- **Actions Workflows**: Set up automation workflows

### Azure DevOps Scripts

- **Work Item Types**: Create RHYTHM Method work item types
- **Board Configuration**: Configure boards for RHYTHM Method
- **Pipeline Templates**: Create pipeline templates
- **Queries**: Create RHYTHM Method queries

### Jira Scripts

- **Issue Types**: Create RHYTHM Method issue types
- **Workflow Configuration**: Configure workflows
- **Automation Rules**: Set up automation rules
- **Board Configuration**: Configure boards

### Custom Scripts

- **API Templates**: REST and GraphQL API templates
- **Webhook Templates**: Webhook integration templates
- **Integration Patterns**: Common integration patterns

## Tool Selection

### Choosing a Tool

Consider the following when choosing a tool:

- **Team Familiarity**: Team's familiarity with the tool
- **Integration Requirements**: Required integrations
- **Automation Needs**: Automation requirements
- **Reporting Needs**: Reporting and visibility needs
- **Cost**: Tool licensing and costs

### Tool Migration

Migrating between tools:

- **Assessment**: Assess current tool usage
- **Mapping**: Map current work items to RHYTHM Method
- **Migration**: Migrate work items and data
- **Validation**: Validate migration completeness

## Best Practices

### 1. Use Native Features

Leverage native tool features where possible:
- Reduces custom development
- Better tool support
- Easier maintenance

### 2. Automate Where Possible

Automate RHYTHM Method processes:
- Dependency detection
- Estimation calculation
- Quality gates
- Reporting

### 3. Maintain Consistency

Maintain consistency across tools:
- Standard work item types
- Consistent workflows
- Standard reporting
- Common automation patterns

### 4. Provide Training

Train team on tool integration:
- Tool-specific RHYTHM Method features
- Workflow usage
- Automation usage
- Reporting usage

## Summary

RHYTHM Method tooling provides integration with GitHub, Azure DevOps, Jira, and custom tools. Setup scripts are available for each tool, providing issue types, workflows, automation, and reporting features. Choose tools based on team familiarity, integration requirements, and automation needs. Use native features where possible, automate processes, maintain consistency, and provide team training.

---

## Navigation

**Previous:** [Best Practices](10-best-practices.md) - RHYTHM Method best practices  
**Next:** [Common Challenges](12-common-challenges.md) - Common challenges and solutions

---

## Change History

| Version | Date       | Author  | Description                    |
| ------- | ---------- | ------- | ------------------------------ |
| 1.0.0   | 2025-11-24 | Initial | Initial tooling documentation |

