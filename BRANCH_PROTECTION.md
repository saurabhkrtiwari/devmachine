# Branch Protection Setup Guide

This guide will help you configure branch protection for your DevMachine repository.

## Option 1: Using GitHub CLI (Recommended)

If you have GitHub CLI installed:

```bash
# First, enable GitHub Actions in your repository
gh workflow enable .github/workflows/branch-protection.yml

# Then run the workflow
gh workflow run branch-protection.yml --field maintainer_username=saurabhkrtiwari
```

## Option 2: Manual Configuration via GitHub Web UI

### Step 1: Enable GitHub Actions
1. Go to your repository: https://github.com/saurabhkrtiwari/devmachine
2. Click on the "Actions" tab
3. Click "Set up a workflow yourself"
4. Delete any default content and paste:
   ```yaml
   name: Configure Branch Protection

   on:
     workflow_dispatch:
       inputs:
         maintainer_username:
           description: 'GitHub username of maintainer'
           required: true
           default: 'saurabhkrtiwari'

   jobs:
     configure-branch-protection:
       runs-on: ubuntu-latest
       steps:
         - name: Configure branch protection
           uses: actions/github-script@v7
           with:
             script: |
               const maintainer = '${{ inputs.maintainer_username }}';

               github.rest.repos.updateBranchProtection({
                 owner: context.repo.owner,
                 repo: context.repo.repo,
                 branch: 'main',
                 required_status_checks: null,
                 enforce_admins: true,
                 required_pull_request_reviews: {
                   required_approving_review_count: 1,
                   dismiss_stale_reviews: false,
                   require_code_owner_reviews: false
                 },
                 restrictions: {
                   users: [
                     maintainer
                   ],
                   teams: []
                 }
               });
   ```
5. Click "Commit changes"

### Step 2: Run the Workflow
1. Go to Actions tab
2. Click "Configure Branch Protection"
3. Click "Run workflow"
4. Keep the default maintainer username: `saurabhkrtiwari`
5. Click "Run workflow"

## Option 3: Direct API Call (Using GitHub CLI)

```bash
# Configure branch protection directly
gh api repos/:owner/:repo/branches/main/protection \
  -X PUT \
  -f required_status_checks=null \
  -f enforce_admins=true \
  -f required_pull_request_reviews='{"required_approving_review_count":1}' \
  -f restrictions='{"users":["saurabhkrtiwari"],"teams":[]}'
```

Replace `:owner` and `:repo` with your actual values.

## Expected Results

After configuration:

✅ **Only `saurabhkrtiwari` can:**
- Push directly to main branch
- Merge pull requests to main
- Force push to main

✅ **All other contributors must:**
- Create pull requests from feature branches
- Get approval for code changes
- Wait for review before merge

## Adding More Maintainers

To add additional maintainers, update the restrictions array:

```yaml
restrictions: {
  users: [
    "saurabhkrtiwari",
    "new-maintainer-username"
  ],
  teams: []
}
```

## Branch Protection Rules Summary

| Rule | Setting |
|------|---------|
| Status checks | None |
| Admin enforcement | Enabled |
| PR reviews | 1 approval required |
| Push restrictions | Only maintainers |
| Force push | Restrict maintainers only |

## Verification

After setting up:
1. Try to push directly to main (should fail)
2. Create a pull request (should work)
3. Only maintainers should see "Merge pull request" option

This ensures code quality and proper review process for your DevMachine project!