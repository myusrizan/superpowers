---
name: security-review
description: Use when reviewing code for security vulnerabilities — before deploying features that handle user input, authentication, authorization, secrets, or external data. Invoke whenever code touches input validation, file uploads, tokens, database queries, or external APIs — even if security isn't explicitly mentioned.
---

# Security Review

## Overview

Find exploitable vulnerabilities before attackers do. A security review is systematic, not a quick scan — it follows the attack surface, then checks each threat category, then outputs findings with severity and concrete fixes.

**Core principle:** Every piece of untrusted input is a potential attack vector. Trace it from entry to storage/output.

---

## When to Use

**Required before:**
- Deploying anything that accepts user input
- Merging changes to auth, session, or permissions logic
- Shipping new API endpoints or webhooks
- Adding third-party integrations that receive external data
- Storing or transmitting sensitive data (PII, credentials, tokens)

**Also use when:**
- A user explicitly asks for a security review
- `code-reviewer` flags potential security concerns
- You added encryption, hashing, or token logic

---

## The Process

### Phase 1: Map the Attack Surface

Before checking vulnerabilities, identify what exists:

```
Inputs:  HTTP params, headers, cookies, file uploads, env vars,
         CLI args, IPC, message queues, database reads, API responses

Outputs: HTTP responses, files written, database writes, logs,
         emails, external API calls, shell commands

Trust boundaries: Where untrusted data crosses into trusted systems
```

List every input source and every place data flows to. This is your review scope.

### Phase 2: Check Each Threat Category

Work through each category against the attack surface you mapped. Don't skip categories because "this probably doesn't apply."

#### A1 — Injection

Applies wherever untrusted data is embedded in a query, command, or template.

- **SQL injection:** Parameterized queries only. No string concatenation into SQL.
- **Command injection:** Never pass user input to `exec()`, `shell()`, `subprocess`. If unavoidable, whitelist valid values.
- **XSS:** Output encoding at render time, not at input time. Framework escaping must be on by default.
- **Template injection:** User input must never be passed to template engines as template strings.
- **Path traversal:** Resolve paths and verify they're within allowed directory before any file operation.

#### A2 — Broken Authentication

- Sessions invalidated on logout? On password change?
- Tokens have expiry? Are they validated server-side on every request?
- Password reset flow: tokens single-use, time-limited, not guessable?
- Account enumeration possible through timing or error messages?
- MFA enforced on privileged accounts?

#### A3 — Broken Authorization

- Every endpoint checks authorization, not just authentication?
- IDOR: can user A access user B's resources by changing an ID?
- Horizontal privilege escalation: can a regular user call admin endpoints?
- Authorization checked in business logic, not just routing middleware?

#### A4 — Sensitive Data Exposure

- Secrets in source code, config files, or comments? (passwords, API keys, tokens)
- Sensitive data in logs? (PII, tokens, full request bodies)
- Sensitive data in URLs? (tokens in query strings appear in access logs)
- Data encrypted at rest if it requires protection?
- TLS enforced for all transport? No fallback to HTTP?

#### A5 — Security Misconfiguration

- Error messages reveal stack traces, SQL queries, or internal paths to users?
- Debug mode or verbose logging enabled in production config?
- Default credentials unchanged?
- CORS policy: `*` origin allowed? Credentials allowed with wildcard?
- Security headers present? (`Content-Security-Policy`, `X-Frame-Options`, `Strict-Transport-Security`)

#### A6 — Vulnerable Dependencies

- Any dependency with known CVEs in use?
- Dependencies pinned to specific versions?
- Lock files committed?

Check: `npm audit`, `pip-audit`, `bundler-audit`, `cargo audit`, or equivalent.

#### A7 — Input Validation

- All inputs validated for type, length, format, and range before use?
- File uploads: MIME type verified server-side (not just client-side or by extension)?
- Integer overflow/underflow possible?
- Null/undefined inputs cause unhandled errors?

#### A8 — Cryptography

- Weak algorithms in use? (`MD5`, `SHA1`, `DES`, `ECB` mode, `Math.random()` for security purposes)
- Hardcoded keys or IVs?
- Password hashing uses slow algorithm? (`bcrypt`, `argon2`, `scrypt` — not `SHA256`)
- Cryptographic randomness from `crypto.randomBytes()` / `secrets` module — not `Math.random()` / `random.random()`?

#### A9 — API Security

- Rate limiting on auth endpoints and expensive operations?
- Mass assignment: can a user set fields they shouldn't by including extra properties in a request?
- Pagination limits enforced? (prevent resource exhaustion via large `limit` params)

#### A10 — Business Logic

- Race conditions possible? (check-then-act patterns)
- Negative quantities, zero amounts, or out-of-range values handled?
- State transitions enforced? (can a user skip steps?)
- Replay attacks possible on actions that should be single-use?

---

## Output Format

Report every finding. Never omit a potential vulnerability because it seems unlikely — document it and assign the correct severity.

```
## Security Review Findings

### [CRITICAL] <Vulnerability Type>

**Location:** file.ts:line
**Attack:** How an attacker exploits this, concretely.
**Impact:** What they gain (data exfil, account takeover, RCE, etc.)
**Fix:**
\`\`\`language
// Concrete fixed code here — not "sanitize the input"
\`\`\`

---

### [HIGH] <Vulnerability Type>
...

### [MEDIUM] <Vulnerability Type>
...

### [LOW / INFORMATIONAL] <Vulnerability Type>
...

## Summary

| Severity | Count |
|----------|-------|
| Critical | N |
| High     | N |
| Medium   | N |
| Low      | N |

**Recommended action:** [Ship / Fix criticals before ship / Do not ship]
```

**Severity guide:**
- **Critical:** Exploitable remotely, no auth required, significant impact (RCE, mass data leak, auth bypass)
- **High:** Exploitable with low effort, significant impact (IDOR, SQLi, stored XSS)
- **Medium:** Requires specific conditions or user interaction, moderate impact
- **Low / Informational:** Defense-in-depth, best practice deviation, low exploitability

---

## Common Failures

| Failure | What it looks like | Consequence |
|---------|-------------------|-------------|
| **Happy path only** | Reviewed what the code does, not what an attacker would send | Misses all injection and validation issues |
| **Trusting client-side validation** | "We validate in the frontend" | Frontend is attacker-controlled |
| **Vague fixes** | "Sanitize the input" | Developer doesn't know what to do |
| **Skipping boring categories** | "This endpoint doesn't need auth checks" | Authorization bypass |
| **Missing trust boundaries** | Reviewed code in isolation | Misses where untrusted data originates |
| **"This is internal only"** | Skipping auth because it's behind VPN | Insider threat, SSRF, lateral movement |

---

## Red Flags — Stop and Escalate

These patterns are high-probability vulnerabilities regardless of context:

- String concatenation into any query, command, or shell invocation
- `eval()` / `exec()` with any variable input
- User-controlled file paths without canonicalization and boundary check
- `Math.random()` / `random.random()` for tokens, nonces, or session IDs
- Passwords stored as plain text or with `MD5`/`SHA1`
- `Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true`
- Any secret value hardcoded as a string literal
