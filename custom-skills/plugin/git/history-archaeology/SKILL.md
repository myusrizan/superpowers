---
name: history-archaeology
description: Use when you need to understand why code exists, when a bug was introduced, who changed a function, or what a file looked like before. Invoke whenever someone asks "why is this here?", "when did this break?", "who changed this?", or "find the commit that added X".
---

# History Archaeology

## Overview

Git history is a complete record of every change ever made. When you need to understand why code looks the way it does — or find the exact commit that introduced a bug — the history tells you.

**Core principle:** Read the git log before forming hypotheses about code intent or bug origin. The history is ground truth.

---

## The Toolkit

### `git blame` — Who last touched each line

```bash
# Show who changed each line and when
git blame src/auth.ts

# Limit to specific lines
git blame -L 45,65 src/auth.ts

# Ignore whitespace changes
git blame -w src/auth.ts

# Follow through renames
git blame --follow src/auth.ts
```

**Read it as:** "Who is the person to ask about this line?" Not necessarily "who is to blame" — they may have inherited it.

---

### `git log -p` — Full history of a file

```bash
# All commits that touched this file, with diffs
git log -p src/auth.ts

# Just the last 5
git log -p -5 src/auth.ts

# Track through renames
git log -p --follow src/auth.ts

# One-liners only (no diff)
git log --oneline src/auth.ts
```

**When to use:** When `blame` shows a refactoring commit ("moved to new file"), go deeper with `log -p` to find the original author.

---

### `git log -S` — Pickaxe: find when text appeared or disappeared

```bash
# Find commits that added or removed the exact string
git log -S "getAuthToken" --oneline

# Search across all branches
git log -S "getAuthToken" --all --oneline

# Show the diff when it appeared/disappeared
git log -S "getAuthToken" -p
```

**When to use:** You need to find the commit that introduced or deleted a function, variable, or string. The pickaxe searches diffs, not just commit messages.

---

### `git log -G` — Regex pickaxe

```bash
# Find commits where the diff matched this pattern
git log -G "authToken|auth_token" --oneline

# With diff
git log -G "TODO.*auth" -p
```

**Difference from `-S`:** `-S` finds commits where the count of a string changed (added or removed). `-G` finds commits where any line in the diff matched the regex — more powerful for patterns.

---

### `git log --grep` — Search commit messages

```bash
# Find commits mentioning "auth" in the message
git log --grep="auth" --oneline

# Case-insensitive
git log --grep="auth" -i --oneline

# Multiple terms (AND)
git log --grep="auth" --grep="token" --all-match --oneline
```

**When to use:** You remember the feature or ticket, not the file. Start here to find the relevant commit, then inspect it.

---

### `git show` — Inspect a specific commit

```bash
# Show the full diff of a commit
git show abc1234

# Just the files changed
git show abc1234 --name-only

# Show a specific file at that commit
git show abc1234:src/auth.ts
```

---

### `git bisect` — Binary search for bug introduction

When you know the bug exists now but didn't exist at some earlier commit:

```bash
# Start bisect
git bisect start

# Mark current commit as bad
git bisect bad

# Mark a known-good commit (e.g., last release tag)
git bisect good v2.1.0

# Git checks out the midpoint — test it
# If bug is present:
git bisect bad
# If bug is absent:
git bisect good

# Repeat until git identifies the introducing commit
# Then clean up:
git bisect reset
```

**Automated bisect** (when you have a test that reproduces the bug):

```bash
git bisect start
git bisect bad HEAD
git bisect good v2.1.0
git bisect run npm test -- --testNamePattern="failing test name"
```

Git runs the test at each midpoint automatically. The result is the exact commit that introduced the bug.

---

### `git log --all --graph` — Visual history

```bash
# Full graph of all branches
git log --all --oneline --graph --decorate

# Just recent history
git log --all --oneline --graph --decorate -20
```

**When to use:** You need to understand branch topology, when a merge happened, or what existed on a deleted branch.

---

## Workflows

### "Why does this function exist?"

1. `git blame src/file.ts` → find the commit that added the function
2. `git show <sha>` → read the full commit message and diff
3. If the message is vague: `git log --grep="ticket-number"` or check the PR

### "When was this bug introduced?"

1. Confirm the bug with a test or reproduction script
2. `git bisect` with the test — narrows to the exact commit
3. `git show <sha>` to understand what changed and why

### "Find where this constant was defined originally"

1. `git log -S "CONSTANT_NAME" --all --oneline` → find when it appeared
2. `git show <sha>` → see the original context

### "Who do I ask about this code?"

1. `git blame -L <lines> <file>` → find recent author
2. If the commit is "refactor" or "rename": `git log -p --follow <file>` → find deeper history

### "What did this file look like before the refactor?"

```bash
# View file at a specific commit
git show abc1234:src/auth.ts

# Diff between now and a past commit
git diff abc1234 -- src/auth.ts

# Diff between two past commits
git diff abc1234..def5678 -- src/auth.ts
```

---

## Hard Rules

- **Read the blame before asking.** The answer to "why is this here?" is almost always in the git history.
- **Follow through refactoring commits.** A commit that says "moved from X" is not the origin — trace further back with `--follow`.
- **Use bisect for regressions, not intuition.** "I think the bug is in this area" is slower and less reliable than binary search.
- **Check all branches with `--all`.** The commit you're looking for may be on a branch that was merged or deleted.
- **Read the full commit message.** The diff shows what changed; the message explains why.
