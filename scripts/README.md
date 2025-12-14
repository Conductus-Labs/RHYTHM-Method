# Validation Tools

This directory contains validation scripts for RHYTHM Method documentation.

## Scripts

### validate-links.js

Validates all internal markdown links to ensure:
- Referenced files exist
- Anchor links point to valid headings
- No broken cross-references

**Usage:**
```bash
node scripts/validate-links.js
# or
npm run validate:links
```

**Features:**
- Recursively scans all markdown files
- Validates file paths and anchor links
- Ignores external links and gitignored directories
- Provides detailed error reports with file and line numbers
- Exit code 0 on success, 1 on errors (CI/CD friendly)

**Example Output:**
```
🔍 RHYTHM Method Documentation - Link Validator

Scanning for markdown files...
Found 17 markdown files

Validating links...

============================================================
VALIDATION RESULTS
============================================================

Total links checked: 245
Broken links found: 0

✅ All links are valid!

============================================================
```

## Adding New Validation Scripts

When adding new validation scripts:

1. Place them in this `scripts/` directory
2. Make them executable: `chmod +x scripts/your-script.js`
3. Add npm script in `package.json`
4. Update this README
5. Update `.github/workflows/validate-docs.yml` if needed
6. Document in `CONTRIBUTING.md`
