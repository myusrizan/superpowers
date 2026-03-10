---
name: find-skills
description: Use when looking for skills to install, discovering what skills exist on skills.sh, or when asked "is there a skill for X?". Invoke when the user wants to find, search, or browse available agent skills from the skills.sh marketplace.
---

# Find Skills

## Overview

Search skills.sh for agent skills that match a need. Use this before building a custom skill — the skill may already exist.

**Core principle:** Search before building. A skill found in 2 minutes beats a skill built in 2 hours.

---

## When to Use

- User asks "is there a skill for X?"
- You want a capability that isn't in the local skills collection
- Before writing a new skill — check if one exists
- Exploring what skills the community has published

---

## Process

### Step 1: Search skills.sh

Visit `https://skills.sh` to browse the marketplace. Search by:
- Keyword (e.g., "database", "testing", "design")
- Category (e.g., "agents", "coding", "meta")
- Install count (higher = more battle-tested)

### Step 2: Evaluate candidates

For each candidate skill:

| Criterion | Questions |
|-----------|-----------|
| **Relevance** | Does it solve the exact problem? |
| **Install count** | Is it widely used (>5K installs = established)? |
| **Source** | Reputable org or individual? (anthropics/, vercel-labs/, obra/ are well-known) |
| **Overlap** | Do we already have something equivalent? |

### Step 3: Inspect before installing

Before installing, read the skill's content:
```bash
# Skills are typically at:
# https://raw.githubusercontent.com/{owner}/{repo}/main/skills/{skill-name}/SKILL.md
```

Check:
- Is the content actionable or vague?
- Does it duplicate an existing local skill?
- Does it fit the project's philosophy?

### Step 4: Install or adapt

**If installing directly:** Follow the platform's plugin install mechanism.

**If adapting (preferred for custom collections):**
1. Copy the key patterns into a new local skill under `custom-skills/`
2. Adapt to local conventions and stack
3. Run `bash scripts/build-skills.sh` to rebuild the catalog

### Step 5: Report findings

Tell the user:
- What you found (skill name, source, install count)
- What it does in one sentence
- Whether to install directly or adapt locally
- If nothing good found: what the closest alternative is

---

## Common Searches

| Need | Search terms |
|------|-------------|
| Document processing | "pdf", "docx", "xlsx", "pptx" |
| Web development | "frontend", "react", "nextjs", "tailwind" |
| Database | "postgres", "supabase", "database" |
| AI/agents | "mcp", "agent", "llm", "swarm" |
| Security | "auth", "security", "owasp" |
| Testing | "testing", "e2e", "webapp" |

---

## Hard Rules

- **Check local skills first** — use `rg` to search `custom-skills/` before going to skills.sh
- **Read before recommending** — never recommend a skill you haven't inspected
- **Install count is signal, not guarantee** — a skill with 100K installs can still be low quality
- **Prefer adapting over blindly installing** — local adaptations fit the project better
