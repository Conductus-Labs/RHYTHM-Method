# Getting Started with RHYTHM Method

**Version:** 1.0.0  
**Last Updated:** 2025-11-26  
**Status:** Initial Draft - For Review

## Overview

This guide will help you get started with RHYTHM Method in your project. Whether you're starting a new project or adopting RHYTHM Method in an existing project, this guide provides step-by-step instructions to get you up and running quickly.

**Summary:** Getting started with RHYTHM Method involves understanding the methodology, setting up your project management tool, initializing your project, and establishing a rhythm of continuous execution, planning, and improvement. Start small, maintain human oversight, use automation, and continuously improve your processes.

## Prerequisites

Before adopting RHYTHM Method, ensure you have:

- **Baton Framework**: Install Baton CLI or access Baton Platform (recommended)
- **AI Agents**: Access to AI agents capable of development work
- **Project Management Tool**: GitHub, Azure DevOps, Jira, or similar tool (optional, Baton Framework can manage)
- **Team Understanding**: Team members understand RHYTHM Method concepts

**Recommended: Use Baton Framework**

The **Baton Framework** is the recommended way to use RHYTHM Method. It provides:

- Consistent Agent-to-Agent (A2A) and Agent-to-User (A2U) communication
- Standardized message templates for all work items
- Automated RHYTHM Method workflows
- Integration with project management tools

See [Message Formats](../message-format/overview.md) for communication templates.

## Adoption Paths

### Path 1: New Project

Starting a new project with RHYTHM Method:

1. **Project Initialization**
   
   - Create Project Manifest
   - Configure RHYTHM settings
   - Initialize work queue

2. **First Feature**
   
   - Create Feature Specification
   - Break down into Work Units
   - Execute first execution cycle

3. **Iterate and Improve**
   
   - Review execution cycles
   - Refine processes
   - Improve estimation accuracy

### Path 2: Existing Project

Adopting RHYTHM Method in an existing project requires careful migration planning to minimize disruption while transitioning from traditional methodologies (Scrum, Kanban, Agile).

**Migration Overview:**

RHYTHM Method migration involves mapping existing work items to RHYTHM structure, handling in-progress work, and gradually transitioning processes. The migration can be done gradually, allowing teams to maintain existing processes while adopting RHYTHM Method incrementally.

**Step-by-Step Migration Guide:**

#### Phase 1: Assessment and Planning

1. **Assess Current State**
   
   - **Current Methodology**: Identify current methodology (Scrum, Kanban, Agile, etc.)
   - **Work Items**: Inventory all existing work items (User Stories, Tasks, Bugs, etc.)
   - **In-Progress Work**: Identify work currently in progress (active sprints, in-flight tasks)
   - **Team Structure**: Understand team structure and roles
   - **Tools**: Identify current project management tools

2. **Plan Migration Strategy**
   
   - **Timeline**: Define migration timeline (gradual vs. immediate)
   - **Scope**: Determine scope (entire project vs. new work only)
   - **Training**: Plan team training on RHYTHM Method
   - **Tool Setup**: Plan tool integration and setup

#### Phase 2: Work Item Mapping

**Mapping Traditional Work Items to RHYTHM Structure:**

| Traditional Item      | RHYTHM Equivalent           | Mapping Notes                                                                |
| --------------------- | --------------------------- | ---------------------------------------------------------------------------- |
| **Epic**              | Project Manifest            | Single Project Manifest replaces all Epics                                   |
| **Feature**           | Feature                     | User Stories map to Features (may combine multiple stories into one Feature) |
| **User Story**        | Work Unit                   | Tasks map to Work Units (may split large tasks into multiple Work Units)     |
| **Task**              | Agent Task                  | Sub-tasks map to Agent Tasks                                                 |
| **Bug (Development)** | Bug (Parented to Work Unit) | Bugs found during development parented to Work Unit                          |
| **Bug (Production)**  | Bug (Related to Feature)    | Production bugs related to Feature                                           |
| **Sprint**            | Execution Cycle             | Sprints replaced by execution cycles (up to 8 hours)                         |
| **Story Points**      | Tokens                      | Story points replaced by token estimation                                    |

**Mapping Guidelines:**

**Epic → Project Manifest:**

- **Single Manifest**: Create one Project Manifest for entire project
- **Consolidate Epics**: Combine multiple Epics into single Project Manifest
- **Decision Log**: Migrate architectural decisions to Project Manifest decision log
- **Project Info**: Migrate project documentation to Project Manifest

**Feature → Feature:**

- **Business Value**: Ensure Feature provides clear business value
- **Deployment**: Feature should be independently deployable
- **Validation**: Define clear validation criteria for Feature
- **Combination**: May combine multiple related User Stories into one Feature
- **Splitting**: May split large User Stories into multiple Features

**User Story → Work Unit:**

- **Execution Cycle**: Work Unit should fit in execution cycle (up to 8 hours)
- **Splitting**: Split large tasks into multiple Work Units if needed
- **Dependencies**: Identify dependencies between Work Units
- **Estimation**: Convert story points to tokens (see below)

**Task → Agent Task:**

- **Agent Assignment**: Assign to specialized agents
- **Clear Criteria**: Define clear completion criteria
- **Estimation**: Estimate tokens for each Agent Task

**Story Points → Tokens:**

**Conversion Approach:**

- **Historical Data**: Use historical data to map story points to tokens
- **Rough Mapping**: 1 story point ≈ 200-400 tokens (varies by team)
- **Re-estimate**: Re-estimate all work using token estimation
- **Calibration**: Calibrate conversion based on actual work

**Conversion Table (Starting Point):**

- **1 Story Point**: ~200-300 tokens (simple work)
- **2 Story Points**: ~400-600 tokens (moderate work)
- **3 Story Points**: ~600-900 tokens (complex work)
- **5 Story Points**: ~1000-1500 tokens (very complex work)
- **8 Story Points**: ~1500-2500 tokens (extremely complex work)

**Note:** These are starting points. Calibrate based on your team's historical data.

#### Phase 3: Handling In-Progress Work

**In-Progress Sprints:**

**Option A: Complete Current Sprint (Recommended)**

- **Complete Sprint**: Complete current sprint using existing methodology
- **Migrate After**: Migrate to RHYTHM Method after sprint completion
- **Clean Start**: Start RHYTHM Method with new work
- **Benefits**: Minimal disruption, clean transition

**Option B: Migrate Mid-Sprint**

- **Map Work**: Map in-progress work to RHYTHM structure
- **Convert Estimates**: Convert story points to tokens
- **Maintain Status**: Preserve work status during migration
- **Risks**: More complex, potential disruption

**In-Progress Tasks:**

1. **Assess Completion Status**
   
   - Identify tasks close to completion (complete using existing process)
   - Identify tasks early in progress (migrate to RHYTHM Method)
   - Identify blocked tasks (migrate and resolve blockers)

2. **Migration Decision**
   
   - **Near Completion**: Complete using existing process
   - **Early Stage**: Migrate to RHYTHM Method
   - **Blocked**: Migrate and address blockers in RHYTHM Method

#### Phase 4: Project Setup

1. **Create Project Manifest**
   
   - Consolidate existing project documentation
   - Create single Project Manifest
   - Migrate architectural decisions to decision log
   - Define project scope and objectives

2. **Map Features**
   
   - Map User Stories to Features
   - Define Feature specifications
   - Identify Feature dependencies
   - Set Feature priorities

3. **Organize Work Units**
   
   - Map Tasks to Work Units
   - Split large tasks if needed
   - Identify Work Unit dependencies
   - Convert story points to tokens

4. **Configure RHYTHM Settings**
   
   - Set TEMPO level (start with Moderate)
   - Configure HITL gates
   - Set up dependency tracking
   - Configure quality gates

#### Phase 5: Gradual Adoption

**Recommended Approach:**

- **Start with New Work**: Use RHYTHM Method for all new work
- **Migrate Existing Work**: Gradually migrate existing work as it's picked up
- **Maintain Existing Processes**: Keep existing processes for in-progress work
- **Parallel Operation**: Run both methodologies in parallel during transition

**Migration Timeline:**

- **Week 1-2**: Setup and training
- **Week 3-4**: Start using RHYTHM for new work
- **Month 2-3**: Gradually migrate existing work
- **Month 4+**: Full RHYTHM Method adoption

#### Phase 6: Team Training

**Training Requirements:**

1. **Core Concepts**
   
   - RHYTHM Method principles
   - TEMPO and RHYTHM concepts
   - Work Breakdown Structure
   - Token-based estimation

2. **Workflows**
   
   - Feature Specification
   - Work Unit Creation and Review
   - Execution cycles
   - Dependency management

3. **Tools and Processes**
   
   - Project management tool setup
   - HITL gate configuration
   - Quality gate configuration
   - Estimation processes

**Training Materials:**

- **Documentation**: Provide access to RHYTHM Method documentation
- **Workshops**: Conduct workshops on key concepts
- **Hands-On**: Hands-on practice with RHYTHM Method
- **Support**: Provide ongoing support during transition

#### Common Migration Pitfalls

**Pitfall 1: Trying to Migrate Everything at Once**

- **Problem**: Attempting to migrate all work immediately
- **Solution**: Gradual migration, start with new work

**Pitfall 2: Not Re-estimating Work**

- **Problem**: Using story points instead of converting to tokens
- **Solution**: Convert all estimates to tokens, re-estimate if needed

**Pitfall 3: Ignoring Dependencies**

- **Problem**: Not identifying dependencies during migration
- **Solution**: Analyze and map dependencies during migration

**Pitfall 4: Inadequate Training**

- **Problem**: Team doesn't understand RHYTHM Method
- **Solution**: Comprehensive training before migration

**Pitfall 5: Maintaining Old Processes**

- **Problem**: Continuing to use old processes alongside RHYTHM
- **Solution**: Fully adopt RHYTHM Method, don't mix methodologies

**Pitfall 6: Not Configuring TEMPO Appropriately**

- **Problem**: Using wrong TEMPO level for team/project
- **Solution**: Start with Moderate TEMPO, adjust based on experience

#### Migration Checklist

**Pre-Migration:**

- [ ] Assess current project state
- [ ] Plan migration strategy and timeline
- [ ] Train team on RHYTHM Method
- [ ] Set up project management tool
- [ ] Create Project Manifest

**Migration:**

- [ ] Map Epics to Project Manifest
- [ ] Map User Stories to Features
- [ ] Map Tasks to Work Units
- [ ] Convert story points to tokens
- [ ] Identify and map dependencies
- [ ] Handle in-progress work
- [ ] Configure RHYTHM settings

**Post-Migration:**

- [ ] Start using RHYTHM for new work
- [ ] Gradually migrate existing work
- [ ] Monitor and adjust processes
- [ ] Collect feedback and improve
- [ ] Complete full migration

#### Migration Support

**Resources:**

- **Documentation**: See [Dictionary](03-dictionary.md), [Principles](04-principles.md), [Workflows](06-workflows.md)
- **Best Practices**: See [Best Practices](10-best-practices.md)
- **Common Challenges**: See [Common Challenges](12-common-challenges.md)
- **Tooling**: See [Tooling](11-tooling.md) for tool setup

**Getting Help:**

- Review documentation for detailed guidance
- Start with small pilot projects
- Iterate and improve based on experience
- Seek support from RHYTHM Method community

## Step-by-Step Implementation

### Step 1: Understand RHYTHM Method

Before implementing, understand the core concepts:

- **Read the [Dictionary](03-dictionary.md)**: Understand key terms and concepts
- **Review the [Principles](04-principles.md)**: Understand the six core principles
- **Learn about [TEMPO](05-tempo.md)**: Understand agent speed and control
- **Study the [Workflows](06-workflows.md)**: Understand RHYTHM Method workflows

### Step 2: Set Up Your Project Management Tool

Use the setup scripts for your tool:

- **GitHub**: See [GitHub Setup](scripts/github/overview.md)
- **Azure DevOps**: See [Azure DevOps Setup](scripts/azure-devops/overview.md)
- **Jira**: See [Jira Setup](scripts/jira/overview.md)
- **Custom**: See [Custom Integration](scripts/custom/overview.md)

### Step 3: Project Initialization

Follow the [Project Initialization](06-workflows.md#1-project-initialization) workflow:

**Create Project Manifest:**

1. Define project scope and objectives
2. Document project information
3. Establish decision log
4. Validate with stakeholders

**Configure RHYTHM Settings:**

1. Set TEMPO level (High, Moderate, Controlled) - see [TEMPO](05-tempo.md)
2. Configure HITL gates
3. Define agent capacity
4. Set quality gate thresholds

**Initialize Work Queue:**

1. Set up dependency tracking
2. Configure prioritization rules
3. Establish validation criteria

### Step 4: First Feature

**Create Feature Specification:**

1. Define business value and objectives
2. Document user requirements
3. Define validation criteria
4. Analyze dependencies (see [Dependency Management](09-dependency-management.md))

**Break Down into Work Units:**

1. Identify Work Units (up to 8 hour execution cycles, some may be less than 2 hours) - see [Work Breakdown Structure](07-work-breakdown-structure.md)
2. Define Work Unit specifications
3. Identify dependencies
4. Estimate tokens (see [Estimation](08-estimation.md))

**Execute First Cycle:**

1. Pull Work Units from queue
2. Execute Agent Tasks
3. Validate quality
4. Review cycle

### Step 5: Establish Rhythm

**Continuous Execution:**

1. Maintain work queue
2. Execute cycles continuously
3. Track dependencies
4. Monitor quality

**Continuous Planning:**

1. Update plans in real-time
2. Replan when priorities change
3. Adjust capacity
4. Refine estimates

**Continuous Improvement:**

1. Review execution cycles
2. Analyze process effectiveness
3. Improve workflows
4. Refine methodology

## Examples and Case Studies

**End-to-End Workflow Example:**

- **[Workflow Example](14-workflow-example.md)** - Complete walkthrough of User Authentication System feature from specification to deployment, showing actual content and decisions at each step

**Additional Examples:**

- See [Estimation](08-estimation.md) for token estimation examples
- See [Dependency Management](09-dependency-management.md) for dependency examples
- See [Work Breakdown Structure](07-work-breakdown-structure.md) for WBS examples
- See [Quick Reference](15-quick-reference.md) for formulas and decision trees

## Next Steps

After getting started:

1. **See a Complete Example**: Review the [Workflow Example](14-workflow-example.md) to see RHYTHM Method in practice
2. **Understand Key Terms**: See [Dictionary](03-dictionary.md) for key terms and concepts
3. **Quick Reference**: Use the [Quick Reference](15-quick-reference.md) for formulas and decision trees
4. **Learn Best Practices**: See [Best Practices](10-best-practices.md) for detailed guidance
5. **Explore Tooling**: See [Tooling](11-tooling.md) for tool integrations
6. **Review Common Challenges**: See [Common Challenges](12-common-challenges.md) for solutions and FAQ
7. **Understand Error Handling**: See [Error Handling](13-error-handling.md) for failure recovery

---

## Navigation

**Previous:** [Overview](01-overview.md) - Documentation index
**Next:** [Dictionary](03-dictionary.md) - Key terms and concepts

---

## Change History

| Version | Date       | Author  | Description                   |
| ------- | ---------- | ------- | ----------------------------- |
| 1.0.0   | 2025-11-24 | Initial | Initial getting started guide |
