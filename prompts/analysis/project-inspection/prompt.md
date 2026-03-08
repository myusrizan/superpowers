# Prompt: Project Inspection

**Purpose:** Inspect any project and produce a structured `project-inspection/` folder that helps a user decide whether to install or adopt it.

**Category:** analysis
**Use when:** You have a project (local path or GitHub repo) and want a complete, honest assessment of it — installation steps, advantages, caveats, prerequisites, and full feature catalog — all grounded in the actual files inside the project.

---

## Prompt

```
Inspect the project at [PROJECT_PATH_OR_URL] and create a folder called `project-inspection/` at the root of that project (or at [OUTPUT_PATH] if specified).

The folder must contain the following files. Every claim in every file must reference a specific file, script, or config inside the project — no invented information.

---

### project-inspection/README.md
- Index table linking to all files in this folder
- A "Quick Decision Guide": 3–5 bullet points for "Install if..." and "Think twice if..."
- Inspection date and the git commit/branch inspected

### project-inspection/overview.md
- What the project is in 2–3 sentences
- Who it is designed for (with a fit table: profile → Excellent / Good / Neutral / Poor)
- What categories of functionality it covers (with a summary table)
- License and attribution (source: LICENSE file)
- Support/community links (source: README or package files)

### project-inspection/prerequisites.md
- Everything that must be installed or configured BEFORE this project can work
- Organize into tiers: Required (project broken without it) / Per-use-case / Assumed standard
- For each prerequisite: what it enables, install command, verification command
- Any platform-specific notes (Windows, macOS, Linux differences)
- Source each item to the file that references it (README, scripts, config files)

### project-inspection/how-to-install.md
- Step-by-step install instructions for each supported install method
- Include verification steps: how to confirm the install worked
- Include update/upgrade instructions
- Include any post-install configuration required
- Source each step to the actual install script, config, or documentation file

### project-inspection/advantages.md
- At least 8 concrete advantages of installing this project
- Each advantage must: name the specific feature/file that provides it, explain what problem it solves, and show what changes for the user
- Do not write generic "saves time" claims — tie every advantage to a specific behavior in the code

### project-inspection/flaws-and-caveats.md
- Current open issues (check issue tracker references, TODO comments, known-issues files)
- Structural limitations that are by design (not bugs, but real constraints)
- Historical issues and how they were resolved (if the project has an audit/changelog)
- Anything that could cause the project to silently fail or behave unexpectedly
- Platform or environment constraints

### project-inspection/feature-catalog.md
- Complete catalog of every feature, skill, command, or module the project provides
- Organized by category
- For each item: name, trigger/use scenario, what it does in 1–2 sentences
- Source each item to its definition file

---

## Rules for the agent executing this prompt

1. Read the actual files — do not summarize from README alone. Read scripts, configs, and source files.
2. Every claim must cite a source file path (e.g., "Source: `scripts/build.sh`").
3. If a claim cannot be sourced to a specific file, do not include it.
4. Flaws section must be honest — do not omit limitations to make the project look better.
5. If the project is incomplete or has open TODOs, report them in flaws-and-caveats.md.
6. The Quick Decision Guide in README.md must be genuinely useful — if the project has a narrow fit, say so clearly.
```

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `[PROJECT_PATH_OR_URL]` | Local path or GitHub URL of the project to inspect | `/Users/me/projects/superpowers` or `https://github.com/obra/superpowers` |
| `[OUTPUT_PATH]` | Where to write `project-inspection/` (defaults to project root) | `/Users/me/Desktop/inspection-output` |

---

## Example Usage

```
Inspect the project at /Users/myusrizan/devspace/agentic-ai-related/superpowers and create a folder called project-inspection/ at the root of that project.
```

Or with a GitHub repo:

```
Inspect the project at https://github.com/obra/superpowers and create project-inspection/ at /tmp/superpowers-inspection.
```
