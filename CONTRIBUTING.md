# Contributing to RHYTHM Method

Thank you for your interest in contributing to RHYTHM Method! This methodology is designed to evolve based on real-world implementation experience, and your contributions are valuable.

## How to Contribute

There are two primary ways to contribute to RHYTHM Method:

### 1. Raise an Issue

If you have suggestions for improvements, found errors, or want to discuss potential changes:

1. Navigate to the [Issues](https://github.com/Conductus-Labs/RHYTHM-Method/issues) page
2. Click "New Issue"
3. Provide a clear, descriptive title
4. Include detailed information about:
   - What you're suggesting or what issue you found
   - Why this change would be beneficial
   - Any relevant context or examples
   - Potential impact on existing documentation

**Issue Types:**
- **Bug/Error**: Typos, broken links, incorrect information
- **Enhancement**: Suggestions for improving existing content
- **New Content**: Proposals for new documentation sections
- **Clarification**: Requests for clearer explanations
- **Question**: Questions about the methodology

### 2. Submit a Pull Request

If you'd like to directly contribute changes:

1. **Fork the repository**
2. **Create a feature branch** from `main`
   ```bash
   git checkout -b feature/your-descriptive-branch-name
   ```
3. **Make your changes**
4. **Write a detailed commit message** explaining your changes
5. **Ensure your changes pass markdown linting** (see below)
6. **Submit a Pull Request** with a detailed message

#### Pull Request Requirements

> [!IMPORTANT]
> All Pull Requests MUST pass markdown linting before they can be merged.

**PR Description Must Include:**
- **What**: Clear description of what you changed
- **Why**: Detailed explanation of why this change should be made
- **Impact**: How this affects existing documentation or methodology
- **Testing**: How you verified your changes (link checking, etc.)

**Example PR Message:**
```
## What
Updated token estimation formulas in 08-token-estimation.md to include 
overhead calculations for multi-agent coordination.

## Why
Current formulas don't account for coordination overhead when multiple 
agents work on the same Work Unit, leading to underestimation. Based on 
implementation experience with 5 projects, coordination adds ~8% overhead.

## Impact
- Changes estimation formulas in section "Token Roll-Up Hierarchy"
- Updates examples to show coordination overhead
- Affects how users calculate Work Unit estimates

## Testing
- Verified all internal links still work
- Passed markdown linting
- Reviewed by 2 team members
```

## Documentation Validation

All markdown files must pass validation checks before merging. We provide automated tools to ensure consistency and quality.

### Prerequisites

Install Node.js dependencies:

```bash
npm install
```

### Running Validation Locally

Before submitting a PR, run all validation checks:

```bash
# Run all validation (linting + link checking)
npm test

# Or run individually:
npm run lint              # Markdown linting
npm run lint:fix          # Auto-fix linting issues
npm run validate:links    # Check for broken links
```

### Validation Tools

#### 1. Markdown Linting

Ensures consistent markdown formatting and style.

**Configuration:** `.markdownlint.json`

**Common Rules:**
- **MD001**: Heading levels increment by one
- **MD003**: ATX-style headings (`#`)
- **MD004**: Dash-style lists (`-`)
- **MD007**: 2-space list indentation
- **MD013**: Line length (disabled for flexibility)
- **MD025**: One H1 per document
- **MD033**: HTML allowed (for mermaid diagrams)
- **MD040**: Fenced code blocks must specify language

**Auto-fix:** Many issues can be auto-fixed with `npm run lint:fix`

#### 2. Link Validation

Checks all internal markdown links for:
- File existence
- Valid anchor references
- No broken cross-references

**Script:** `scripts/validate-links.js`

**What it checks:**
- `[text](file.md)` - File exists
- `[text](file.md#heading)` - File exists AND heading exists
- `[text](#heading)` - Heading exists in current file

**Ignored:**
- External links (http://, https://)
- File protocol links (file://)
- Directories in .gitignore

### CI/CD Validation

All PRs automatically run validation via GitHub Actions:
- Markdown linting
- Link validation
- Results reported in PR checks

**Workflow:** `.github/workflows/validate-docs.yml`

## Style Guidelines

### Documentation Style

- **Clear and Concise**: Write clearly and avoid unnecessary jargon
- **Consistent Terminology**: Use terms as defined in the methodology
- **Examples**: Include practical examples where helpful
- **Formatting**: Use proper markdown formatting (headers, lists, code blocks, tables)
- **Links**: Use relative links for internal documentation references

### Terminology

Use consistent terminology as defined in RHYTHM Method:
- **User** (not "customer" or "stakeholder")
- **Agent Task** (not "Task")
- **Work Unit** (not "Unit of Work")
- **Execution Cycle** (not "Cycle")
- **Project Manifest** (not "Epic")

See [17-dictionary.md](17-dictionary.md) for complete terminology guide.

### File Naming

- Use lowercase with hyphens: `file-name.md`
- Numbered files use two digits: `01-filename.md`
- Be descriptive but concise

## What We're Looking For

We especially welcome contributions in these areas:

### Real-World Implementation Experience

- **What works well** in practice
- **What doesn't work** or needs clarification
- **Edge cases** or scenarios not covered
- **Practical examples** from your implementations
- **Lessons learned** from using RHYTHM Method

### Documentation Improvements

- **Clarifications** for confusing sections
- **Additional examples** for complex concepts
- **Better explanations** of difficult topics
- **Corrections** for errors or outdated information

### Methodology Enhancements

- **Process improvements** based on experience
- **New patterns** or best practices
- **Tool integrations** or automation ideas
- **Metrics and measurements** for effectiveness

## Code of Conduct

### Our Standards

- **Be Respectful**: Treat all contributors with respect
- **Be Constructive**: Provide constructive feedback
- **Be Collaborative**: Work together to improve the methodology
- **Be Patient**: Remember that everyone is learning

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Personal attacks or trolling
- Spam or off-topic discussions
- Sharing private information without permission

## Review Process

1. **Submission**: You submit a PR or issue
2. **Initial Review**: Maintainers review within 3-5 business days
3. **Discussion**: We may ask questions or request changes
4. **Approval**: Once approved, changes are merged
5. **Release**: Changes are included in the next documentation update

## Questions?

If you have questions about contributing:

1. Check existing [Issues](https://github.com/Conductus-Labs/RHYTHM-Method/issues) and [Pull Requests](https://github.com/Conductus-Labs/RHYTHM-Method/pulls)
2. Review this contributing guide
3. Open a new issue with your question

## License

By contributing to RHYTHM Method, you agree that your contributions will be licensed under the same [MIT License](LICENSE) that covers the project.

---

**Thank you for helping make RHYTHM Method better!**

We appreciate your contributions and look forward to learning from your implementation experience.
