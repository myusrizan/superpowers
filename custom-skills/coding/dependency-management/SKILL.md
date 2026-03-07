---
name: dependency-management
description: Use when evaluating whether to add a new dependency, auditing existing dependencies for security issues, managing version pinning, or resolving conflicts. Invoke whenever someone says "install X", "add X dependency", "use X library", or asks to upgrade a package.
---

# Dependency Management

## Overview

Every dependency is a liability: maintenance burden, security surface, license risk, and bundle weight. The question is never "can I add this?" — it's "should I, and how?"

**Core principle:** Add dependencies intentionally, maintain them actively, audit them regularly.

---

## Add vs. Build Decision

Before adding any dependency, evaluate these criteria:

| Criterion | Add if | Build if |
|-----------|--------|---------|
| **Functionality match** | Does 80%+ of what you need | Requires so much wrapping it's a rewrite |
| **Maintenance** | Active commits within 6 months | Last commit over a year ago |
| **Community** | npm: >10k/week; PyPI: >100k/week | No community, no issue responses |
| **Documentation** | Clear API docs, examples | Undocumented or source-only |
| **License** | MIT, Apache, BSD | GPL (check your license compatibility), proprietary |
| **Size** | Proportional to benefit | 500kb library for a 20-line function |
| **Dependencies** | Few transitive deps | Deep dependency tree, version conflicts |
| **Security history** | Clean or well-patched | Repeated unpatched CVEs |

**When to build:**
- The requirement is so specific that a library would need to be rewritten anyway
- Security/compliance requirements prohibit external dependencies
- The library would be larger than the code you'd write
- No suitable library exists (document the search — see `search-first` skill)

---

## Pinning Strategy

| Strategy | Format | Use when |
|----------|--------|---------|
| **Exact pin** | `1.2.3` | Production dependencies, security-sensitive code |
| **Patch range** | `~1.2.3` (allows `1.2.x`) | Stable libraries where patches are safe |
| **Minor range** | `^1.2.3` (allows `1.x.y`) | Well-maintained libraries with good semver discipline |
| **Loose** | `>=1.2.0` | Internal tools, development-only deps |

**Default recommendation:** Use exact pins for production dependencies in application code. Use ranges in library/package code (so consumers aren't forced onto a specific patch version).

**The tradeoff:**
- Exact pins: reproducible builds, manual upgrade effort
- Ranges: automatic patch/minor updates, risk of silent breaking changes if semver is violated

Regardless of pinning strategy: **always commit lock files** (`package-lock.json`, `Pipfile.lock`, `Cargo.lock`, `go.sum`). Lock files give you exact reproducibility even with range specs.

---

## Lock File Discipline

```bash
# CI: install from lockfile (never update it)
npm ci                          # Node
pip install --require-hashes    # Python (with pip-tools)
cargo build                     # Rust (Cargo.lock committed)

# Development: update lockfile explicitly
npm install                     # Updates lockfile after adding/upgrading
pip-compile requirements.in     # Regenerates requirements.txt
```

**Rules:**
- **Always commit lock files.** A committed lock file = reproducible builds everywhere.
- **Use `npm ci` (not `npm install`) in CI.** `npm install` can update the lockfile; `npm ci` refuses if the lockfile is out of date.
- **Review lock file diffs in PRs.** An unexpected transitive dependency appearing in the lockfile is a security signal.

---

## Auditing for Vulnerabilities

Run audits regularly and on every CI run:

```bash
# Node
npm audit                       # Show vulnerabilities
npm audit fix                   # Auto-fix where possible (check diff!)
npm audit fix --force           # Force major version bumps (review carefully)

# Python
pip-audit                       # pip install pip-audit
safety check                    # alternative: safety check -r requirements.txt

# Rust
cargo audit                     # cargo install cargo-audit

# Ruby
bundle audit                    # gem install bundler-audit

# Go
govulncheck ./...               # golang.org/x/vuln/cmd/govulncheck
```

**When a vulnerability is found:**

1. Check if it affects your usage path (many vulns only trigger in specific call patterns)
2. Look for a patched version — upgrade if available
3. If no patch: evaluate workaround, or replace the dependency
4. If no path to fix: document the risk and decision in an ADR

**Severity thresholds:**
- CRITICAL / HIGH: Fix before merging. Never ship with these unresolved.
- MEDIUM: Fix within the sprint, document if deferring.
- LOW: Triage — fix when upgrading anyway, not as standalone work.

---

## Removing Unused Dependencies

Unused dependencies add security surface and build weight without benefit.

```bash
# Node — find unused dependencies
npx depcheck

# Python — find unused imports (indirect signal)
pip install pylint
pylint --disable=all --enable=W0611 src/

# Manual search (any language)
rg "import.*lodash" src/          # Find if lodash is used
rg "from.*lodash" src/
```

Before removing:
1. Search for all import/require/using patterns in source
2. Check test files — some deps are test-only (should be in devDependencies)
3. Check build configs — some deps are referenced in webpack/rollup/vite configs, not source

---

## Resolving Transitive Dependency Conflicts

When two of your dependencies require incompatible versions of the same package:

**Step 1: Identify the conflict**
```bash
npm ls conflicting-package    # Shows the full dependency tree
pip check                     # Reports incompatibilities
```

**Step 2: Understand why**
- Which of your dependencies requires which version?
- Is one of them outdated and has a newer version that resolves the conflict?

**Step 3: Resolve options (in order of preference)**
1. Upgrade the dependency that's requesting the old version
2. Use package manager overrides/resolutions to force a specific version (check compatibility!)
3. Replace one of the conflicting dependencies with an alternative
4. Fork and patch (last resort — becomes your maintenance burden)

```json
// package.json — force a specific transitive version
{
  "overrides": {
    "transitive-package": "2.0.0"
  }
}
```

---

## Hard Rules

- **Evaluate before adding.** Run through the add-vs-build criteria before `npm install`. This takes 5 minutes and prevents months of maintenance.
- **Always commit lock files.** Never gitignore them for application code.
- **Use `ci` commands in CI.** `npm ci`, not `npm install`. Never update the lockfile in CI.
- **Audit on every CI run.** Vulnerabilities discovered in CI are free; in production they're incidents.
- **Review lockfile diffs in PRs.** New transitive dependencies deserve the same scrutiny as new direct dependencies.
- **Document why you built instead of adopted.** Future maintainers should not have to re-research a decision you've already made.
