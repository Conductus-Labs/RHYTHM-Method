# Branch Protection Configuration

This directory contains branch protection rule configurations for the RHYTHM-Method repository.

## Current Configuration

### dev Branch

- **Status:** ✅ Protected
- **PR Requirements:** Required (1 approval)
- **Admin Bypass:** Allowed (`enforce_admins: false`)
- **CODEOWNERS Bypass:** Configured via user bypass (jnhaffey) and admin bypass
- **Force Push:** Disabled
- **Deletions:** Disabled

### main Branch

- **Status:** ⏳ Pending (branch does not exist yet)
- **PR Requirements:** Required (1 approval)
- **Admin Bypass:** NOT Allowed (`enforce_admins: true`)
- **CODEOWNERS Bypass:** NOT Allowed
- **Force Push:** Disabled
- **Deletions:** Disabled

## CODEOWNERS Bypass Configuration

### Current Setup

For the `dev` branch, CODEOWNERS bypass is configured with:
- `enforce_admins: false` (allows all admins to bypass)
- `bypass_pull_request_allowances.users: ["jnhaffey"]` (explicit user bypass)
- CODEOWNERS file created at `.github/CODEOWNERS` with `@jnhaffey` as code owner

This allows:
- Repository admins to bypass PR requirements
- Explicitly listed users (jnhaffey) to bypass PR requirements
- Users/teams listed in CODEOWNERS file to bypass PR requirements

### CODEOWNERS File

✅ Created at `.github/CODEOWNERS`

Current configuration:
- All paths owned by `@jnhaffey`
- Can be updated to include teams (e.g., `@Conductus-Labs/maintainers`)

### Updating Bypass Configuration

To add more users or teams to bypass, update `dev-branch-protection.json`:

```json
{
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "bypass_pull_request_allowances": {
      "users": ["jnhaffey", "username2"],
      "teams": ["maintainers"]
    }
  }
}
```

Then reapply:

```bash
gh api repos/Conductus-Labs/RHYTHM-Method/branches/dev/protection -X PUT --input .branch-protection/dev-branch-protection.json
```

### Restricting to CODEOWNERS Only

If you want to restrict bypass to only CODEOWNERS (not all admins), set `enforce_admins: true` and ensure all CODEOWNERS users/teams are in `bypass_pull_request_allowances`.

## Applying Protection Rules

### dev Branch

```bash
gh api repos/Conductus-Labs/RHYTHM-Method/branches/dev/protection -X PUT --input .branch-protection/dev-branch-protection.json
```

### main Branch

```bash
# First ensure main branch exists
git checkout -b main
git push origin main

# Then apply protection
gh api repos/Conductus-Labs/RHYTHM-Method/branches/main/protection -X PUT --input .branch-protection/main-branch-protection.json
```

## Verification

Check current protection status:

```bash
# dev branch
gh api repos/Conductus-Labs/RHYTHM-Method/branches/dev/protection | jq '{enforce_admins: .enforce_admins.enabled, required_pr: .required_pull_request_reviews}'

# main branch
gh api repos/Conductus-Labs/RHYTHM-Method/branches/main/protection | jq '{enforce_admins: .enforce_admins.enabled, required_pr: .required_pull_request_reviews}'
```

## Notes

- **dev branch:** Allows admins and explicitly listed users (jnhaffey) to bypass. CODEOWNERS file is created and configured.
- **main branch:** No bypass allowed - all changes must go through PRs from dev branch.
- Protection rules are applied via GitHub API and take effect immediately.
- CODEOWNERS file can be updated to include teams by replacing `@jnhaffey` with team slugs (e.g., `@Conductus-Labs/maintainers`).
