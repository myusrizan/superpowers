---
name: github-cli
description: Use when working with GitHub issues, CI runs, releases, or repository operations from the terminal. Invoke when someone asks to list/create/close issues, check CI status, create a release, or search GitHub — even if they don't say "gh".
---

# GitHub CLI

## Overview

`gh` is the GitHub CLI — it brings issues, pull requests, CI runs, releases, and search into the terminal without context-switching to the browser.

**Core principle:** Use `gh` for GitHub operations. It's faster than the browser, scriptable, and works in automated loops.

**Prerequisite:** `gh auth login` must be run once to authenticate.

---

## Issues

```bash
# List open issues (assigned to you)
gh issue list --assignee @me

# List all open issues
gh issue list --state open --limit 20

# View issue details
gh issue view 123

# Create an issue
gh issue create --title "Bug: login crashes" --body "Steps to reproduce..."

# Close an issue
gh issue close 123

# Reopen an issue
gh issue reopen 123

# Add a comment
gh issue comment 123 --body "Fixed in PR #456"
```

### Filtering issues

```bash
# By label
gh issue list --label "bug" --label "high-priority"

# By milestone
gh issue list --milestone "v2.0"

# Output as JSON for scripting
gh issue list --json number,title,assignees --jq '.[] | [.number, .title] | @tsv'
```

---

## Pull Requests

```bash
# List open PRs
gh pr list

# View PR details including checks
gh pr view 456

# Check CI status on a PR
gh pr checks 456

# Review a PR (approve/request-changes/comment)
gh pr review 456 --approve
gh pr review 456 --request-changes --body "Please fix X before merge"

# Merge a PR
gh pr merge 456 --squash --delete-branch

# Check out a PR locally
gh pr checkout 456
```

---

## CI Runs

```bash
# List recent runs for current branch
gh run list --branch=$(git branch --show-current) --limit=10

# List runs for a specific workflow
gh run list --workflow=ci.yml --limit=10

# Watch a run in real-time
gh run watch <run-id>

# View only the failed step logs
gh run view <run-id> --log-failed

# Re-run only failed jobs
gh run rerun <run-id> --failed

# Re-run the entire workflow
gh run rerun <run-id>

# Cancel a run
gh run cancel <run-id>

# Open in browser
gh run view <run-id> --web
```

---

## Releases

```bash
# List releases
gh release list

# Create a release
gh release create v1.2.0 --title "Release v1.2.0" --notes "Changelog here"

# Create a draft release
gh release create v1.2.0 --draft --title "Release v1.2.0"

# Upload assets to a release
gh release upload v1.2.0 dist/app.tar.gz

# View a release
gh release view v1.2.0

# Download release assets
gh release download v1.2.0 --dir ./downloads
```

### Release notes from git log

```bash
# Generate notes from commits since last tag
gh release create v1.2.0 --generate-notes
```

---

## Search

```bash
# Search issues across GitHub
gh search issues "memory leak" --repo owner/repo --state open

# Search PRs
gh search prs "authentication refactor" --repo owner/repo

# Search repositories
gh search repos "claude mcp" --language typescript --sort stars

# Search code (requires auth)
gh search code "getAuthToken" --repo owner/repo
```

---

## Repository Operations

```bash
# View repo details
gh repo view

# Clone a repo
gh repo clone owner/repo

# Fork a repo
gh repo fork owner/repo --clone

# Create a repo
gh repo create my-new-repo --public --description "Description"

# List collaborators
gh api repos/owner/repo/collaborators --jq '.[].login'
```

---

## Scripting with JSON output

Most `gh` commands accept `--json` and `--jq` for structured output:

```bash
# Get PR number and title as JSON
gh pr list --json number,title

# Extract specific fields with jq
gh pr list --json number,title --jq '.[] | "\(.number): \(.title)"'

# Get the most recent failed run ID
gh run list --status failure --limit 1 --json databaseId --jq '.[0].databaseId'
```

---

## Integration with autonomous-loops

`gh` enables automated PR workflows. See `autonomous-loops` skill Pattern 4 for an example using `gh pr list`, `gh pr checks`, and `gh pr merge` in a CI loop.

---

## Hard Rules

- **`gh auth status` to verify authentication.** If a command fails unexpectedly, check auth first.
- **Use `--json` + `--jq` for scripting.** Never parse human-readable `gh` output in scripts — it changes between versions.
- **Use `gh run rerun --failed` instead of re-running the whole workflow.** Faster and cheaper.
- **Prefer `gh issue comment` over closing/reopening.** Keep the audit trail intact.
