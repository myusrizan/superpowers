# How to Install Superpowers

> Source: `README.md`, `hooks/hooks.json`, `hooks/session-start`, `docs/`

---

## Option A — Claude Code Plugin Marketplace (Recommended)

The simplest install path. Two commands, no manual setup.

```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

After installation, start a new Claude Code session. The `hooks/session-start` hook fires automatically and:
1. Rebuilds the `skills/` directory from `custom-skills/`
2. Injects the `using-superpowers` skill into your session context
3. Loads your most recent session log (if ≤150 lines) for session continuity

---

## Option B — Local Fork in Another Project

Use this if you want to customise skills or install from a local clone.

```bash
# Clone the repo
git clone https://github.com/obra/superpowers.git

# Install into Claude Code from local path
/plugin install /path/to/superpowers
```

After cloning, build the skills directory manually once:

```bash
bash scripts/build-skills.sh
```

This copies `custom-skills/` → `skills/` and regenerates the catalog in `custom-skills/meta/using-superpowers/SKILL.md`.

---

## Option C — Other Platforms

| Platform | Command |
|----------|---------|
| **Cursor** | `/plugin-add superpowers` |
| **Codex** | Fetch and follow `https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md` — or see `docs/README.codex.md` |
| **OpenCode** | Fetch and follow `https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md` — or see `docs/README.opencode.md` |

---

## Verifying the Install

Start a new Claude Code session and ask for something that matches a skill, e.g.:

- "Help me plan this feature" → should trigger `brainstorming` and then `writing-plans`
- "Let's debug this issue" → should trigger `systematic-debugging`
- "Review this code" → should trigger `requesting-code-review`

If skills don't fire, check:

```bash
# Confirm skills directory exists and is populated
ls skills/

# Re-run the build script
bash scripts/build-skills.sh

# Check hook registration
cat hooks/hooks.json
```

---

## How the Hook Works

**File:** `hooks/session-start`

The SessionStart hook fires on the patterns: `startup | resume | clear | compact`

It outputs JSON with `additional_context` that Claude Code injects into the session. This is how the `using-superpowers` skill becomes active without you manually invoking it every session.

**Windows users:** The hook is wrapped by `hooks/run-hook.cmd` for reliable bash discovery. See `docs/windows/` for details.

---

## Keeping Skills Up to Date

If you installed via the marketplace, update with:

```bash
/plugin update superpowers
```

If you installed from a local fork, pull and rebuild:

```bash
git pull
bash scripts/build-skills.sh
```

The build script warns you if the skill count reaches 60 (cognitive overload threshold). If you see this warning after an update, review `investigation-report/05-missing-skills-and-gaps.md` for guidance.
