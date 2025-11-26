# Testing Guide for GitHub Issue Types Setup Scripts

## Test Repositories

- **Bash Testing:** https://github.com/Conductus-Labs/test-repo-bash.git
- **PowerShell Testing:** https://github.com/Conductus-Labs/test-repo-powershell.git

## Prerequisites

Before testing, ensure you have:

1. **GitHub CLI installed and authenticated:**
   ```bash
   gh --version
   gh auth status
   ```

2. **Organization admin permissions** for `Conductus-Labs`

3. **YAML parser (yq) installed:**
   - macOS: `brew install yq`
   - Linux: `apt-get install yq` or download from https://github.com/mikefarah/yq
   - Windows: Download from https://github.com/mikefarah/yq/releases

## Testing Bash Script

### Setup

```bash
# Clone test repository
git clone https://github.com/Conductus-Labs/test-repo-bash.git
cd test-repo-bash

# Copy script and templates
cp /path/to/RHYTHM-Method/scripts/github/setup/setup-issue-types.sh .
cp -r /path/to/RHYTHM-Method/scripts/github/templates .
chmod +x setup-issue-types.sh
```

### Test Commands

```bash
# 1. Test help
./setup-issue-types.sh --help

# 2. Test dry-run (preview changes)
./setup-issue-types.sh --dry-run

# 3. Test verbose output
./setup-issue-types.sh --verbose --dry-run

# 4. Actual run (creates issue types)
./setup-issue-types.sh
```

## Testing PowerShell Script

### Setup

```powershell
# Clone test repository
git clone https://github.com/Conductus-Labs/test-repo-powershell.git
cd test-repo-powershell

# Copy script and templates
Copy-Item "C:\path\to\RHYTHM-Method\scripts\github\setup\setup-issue-types.ps1" .
Copy-Item -Recurse "C:\path\to\RHYTHM-Method\scripts\github\templates" .
```

### Test Commands

```powershell
# 1. Test help
.\setup-issue-types.ps1 -Help

# 2. Test dry-run (preview changes)
.\setup-issue-types.ps1 -DryRun

# 3. Test verbose output
.\setup-issue-types.ps1 -Verbose -DryRun

# 4. Actual run (creates issue types)
.\setup-issue-types.ps1
```

## Expected Behavior

### Dry-Run Mode
- Should show what would be created
- Should NOT actually create issue types
- Should validate prerequisites
- Should auto-detect organization

### Actual Run
- Should copy template to `.baton/github-config.yml` if not exists
- Should auto-detect organization from repository
- Should prompt for confirmation if auto-detection succeeds
- Should create all 4 issue types (Feature, Work Unit, Agent Task, Bug)
- Should skip issue types that already exist (idempotent)

### Error Handling
- Should show clear error if `gh` CLI not installed
- Should show clear error if not authenticated
- Should show clear error if missing org admin permissions
- Should show clear error if `yq` not installed (Bash) or YAML parser missing (PowerShell)

## Verification

After running the script, verify issue types were created:

```bash
# List issue types in organization
gh api orgs/Conductus-Labs/issue-types --jq '.[].name'
```

Expected output should include:
- Feature
- Work Unit
- Agent Task
- Bug

## Troubleshooting

### Issue: "yq not installed" (Bash)
**Solution:** Install yq:
- macOS: `brew install yq`
- Linux: `apt-get install yq` or download from https://github.com/mikefarah/yq

### Issue: "Not authenticated"
**Solution:** Run `gh auth login`

### Issue: "No organization admin permissions"
**Solution:** Request org admin access or have an org admin run the script

### Issue: "Could not auto-detect organization"
**Solution:** Script will prompt you to enter organization name manually

