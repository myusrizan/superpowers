# Custom Skills System — Part 5: Missing Skills and Gaps

> Updated: 2026-03-07

---

## Coverage Map

| Development Concern | Covered By | Gap? |
|--------------------|-----------|------|
| Design before code | `brainstorming` | ✅ |
| Test-driven development | `test-driven-development` | ✅ |
| Debugging | `systematic-debugging` | ✅ |
| Code review (requesting) | `requesting-code-review` | ✅ |
| Code review (executing) | `code-reviewer` (⚠️ template not skill) | Partial |
| Code review (receiving) | `receiving-code-review` | ✅ |
| Security | `security-review` | ✅ |
| Silent failures | `silent-failure-hunter` | ✅ |
| API design | `api-design` | ✅ |
| Database migrations | `database-migrations` | ✅ |
| E2E testing | `e2e-testing` | ✅ |
| Evaluation/AI testing | `eval-harness` | ✅ |
| Dependency management | `dependency-management` | ✅ |
| Observability | `observability` | ✅ |
| CI/CD | `ci-cd-pipeline` | ✅ |
| UI/UX design | `ui-ux-design` | ✅ (new) |
| Refactoring | `refactoring` | ✅ |
| Performance profiling | `performance-profiling` | ✅ |
| Onboarding to codebase | `onboarding-to-codebase` | ✅ |
| Git branching | `finishing-a-development-branch` | ✅ |
| Git worktrees | `using-git-worktrees` | ✅ |
| Multi-agent parallel work | `dispatching-parallel-agents` | ✅ |
| Multi-agent development | `subagent-driven-development` | ✅ |
| Autonomous loops | `autonomous-loops` | ✅ |
| Iterative search/retrieval | `iterative-retrieval` | ✅ |
| Session continuity | `capturing-context` + `session-resume` | ✅ |
| Skill creation | `skill-creator` | ✅ |
| Skill maintenance | `skill-stocktake` + `claude-md-improver` | ✅ |

---

## Remaining Gaps

### GAP-1: `code-reviewer` as a proper registered skill
**Priority:** Medium
**Description:** The code review execution step has a template file but no proper registered skill. A subagent dispatched by `requesting-code-review` has to use the template manually. See FLAW-19.

---

### GAP-2: Feature flags / progressive rollout
**Priority:** Low
**Description:** No skill covers feature flag strategy, gradual rollout patterns, or A/B testing infrastructure. Neither this system nor `affaan-m/everything-claude-code` covered it. The skills `ci-cd-pipeline` and `observability` touch adjacent concerns but don't cover flag management.

**Potential content:** LaunchDarkly/Unleash patterns, flag lifecycle (birth → mature → retire), kill switch design, percentage rollouts, flag debt cleanup.

---

### GAP-3: Incident response / postmortem
**Priority:** Low
**Description:** No skill covers: how to diagnose a production incident, what to do during an outage, how to write a postmortem. `systematic-debugging` covers local debugging but not production incident management.

**When relevant:** Once a project is deployed and operational. Not a gap for development-stage projects.

---

### GAP-4: Data modeling / schema design
**Priority:** Low
**Description:** `database-migrations` covers how to change a schema safely. No skill covers how to design a schema from scratch — entity relationships, normalization, indexing strategy, soft delete patterns.

---

### GAP-5: Accessibility audit (standalone)
**Priority:** Low
**Description:** `ui-ux-design` includes accessibility rules as part of the broader skill. There may be value in a focused `accessibility-audit` skill for reviewing existing UIs specifically against WCAG criteria — similar to how `silent-failure-hunter` focuses on one concern from `systematic-debugging`.

**Decision:** Don't create yet. `ui-ux-design` covers this adequately. Revisit after `ui-ux-design` is pressure-tested.

---

## Strategic Observations

### System is broadly complete
After the 2026-03-07 expansion to 48 skills, the main software development workflow is comprehensively covered. The remaining gaps (feature flags, incidents, data modeling) are specialized concerns, not core workflow gaps.

### Growth rate is high — quality control matters more now
The system grew from 20 to 48 skills in ~5 weeks. Quantity is no longer the constraint; quality assurance is. The `writing-skills` TDD process exists precisely for this — but 19 of the 48 skills haven't been through it. Pressure testing (OPT-A) is the highest-leverage action now.

### External repo mining is mostly exhausted
- `affaan-m/everything-claude-code`: 8 skills acquired. Remaining skills were language/framework-specific — not general enough.
- `anthropics/claude-plugins-official`: 3 skills acquired.
- `accomplish-ai/accomplish`: 0 skills — application, not patterns.
- `nextlevelbuilder/ui-ux-pro-max-skill`: 1 skill acquired (methodology distilled; infrastructure skipped).

Future acquisitions should focus on: official Anthropic releases, well-adopted community plugins (>5k stars), and domain-specific repos for areas identified in gaps above.
