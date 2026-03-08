---
name: security
description: Use when reviewing code for security vulnerabilities before deploying features that handle user input, authentication, authorization, or external data, or when reviewing error handling quality before merging. Invoke whenever code touches input validation, file uploads, tokens, database queries, external APIs, catch blocks, try/except, or fallback values.
---

# Security

Two complementary reviews. Run both whenever reviewing code before merge or deploy.

---

## Part A: Vulnerability Review

**Core principle:** Every piece of untrusted input is a potential attack vector. Trace it from entry to storage/output.

### When Required

- Before deploying anything that accepts user input
- Before merging changes to auth, session, or permissions logic
- Adding new API endpoints or webhooks
- Adding third-party integrations that receive external data
- Storing or transmitting sensitive data (PII, credentials, tokens)

### Phase 1: Map the Attack Surface

```
Inputs:  HTTP params, headers, cookies, file uploads, env vars,
         CLI args, IPC, message queues, database reads, API responses

Outputs: HTTP responses, files written, database writes, logs,
         emails, external API calls, shell commands

Trust boundaries: Where untrusted data crosses into trusted systems
```

### Phase 2: Check Each Threat Category

Work through all 10. Don't skip because "this probably doesn't apply."

**A1 — Injection:** Parameterized queries only. No string concatenation into SQL, commands, or templates. Never pass user input to `exec()`/`shell()`. Path traversal: resolve and verify within allowed directory.

**A2 — Broken Authentication:** Sessions invalidated on logout and password change? Tokens have expiry, validated server-side? Password reset tokens single-use, time-limited, not guessable? Account enumeration possible through timing/errors?

**A3 — Broken Authorization:** Every endpoint checks authorization (not just auth)? IDOR: can user A access user B's resources by changing an ID? Authorization in business logic, not just routing middleware?

**A4 — Sensitive Data Exposure:** Secrets in source code or comments? Sensitive data in logs or URLs? Data encrypted at rest? TLS enforced for all transport?

**A5 — Security Misconfiguration:** Error messages reveal stack traces or internal paths? Debug mode enabled in production? Default credentials unchanged? CORS policy allows `*` with credentials? Security headers present?

**A6 — Vulnerable Dependencies:** Run `npm audit` / `pip-audit` / `bundler-audit` / `cargo audit`.

**A7 — Input Validation:** All inputs validated for type, length, format, range? File uploads: MIME verified server-side? Null inputs cause unhandled errors?

**A8 — Cryptography:** Weak algorithms (`MD5`, `SHA1`, `DES`, `ECB`, `Math.random()` for security)? Hardcoded keys? Password hashing uses `bcrypt`/`argon2`/`scrypt`?

**A9 — API Security:** Rate limiting on auth and expensive operations? Mass assignment: can user set fields via extra request properties? Pagination limits enforced?

**A10 — Business Logic:** Race conditions (check-then-act)? Negative quantities or out-of-range values handled? State transitions enforced? Replay attacks possible?

### Output Format

```
## Security Review Findings

### [CRITICAL] <Vulnerability Type>
**Location:** file.ts:line
**Attack:** How an attacker exploits this, concretely.
**Impact:** What they gain (data exfil, account takeover, RCE, etc.)
**Fix:**
```language
// Concrete fixed code here
```

### [HIGH] / [MEDIUM] / [LOW] ...

## Summary
| Severity | Count |
|----------|-------|
| Critical | N |
| High     | N |

**Recommended action:** [Ship / Fix criticals before ship / Do not ship]
```

**Severity:** Critical = exploitable remotely, no auth, significant impact · High = low effort, significant impact · Medium = specific conditions required · Low = defense-in-depth deviation

### Red Flags — Escalate Immediately

- String concatenation into any query, command, or shell invocation
- `eval()` / `exec()` with any variable input
- User-controlled file paths without canonicalization
- `Math.random()` / `random.random()` for tokens or session IDs
- Passwords stored as plain text or with `MD5`/`SHA1`
- `Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true`
- Any secret value hardcoded as a string literal

---

## Part B: Silent Failure Review

**Core principle:** Any error caught without proper logging and user feedback is a defect. Absence of noise is not success.

### Critical — Must Fix Before Merge

**Empty catch block:**
```typescript
try { await saveData(payload); } catch (e) { /* nothing */ }
```

**Swallowed exception:**
```python
try:
    process_payment(order_id)
except Exception:
    pass  # Never acceptable for meaningful operations
```

**Silent return on failure:**
```typescript
} catch {
    return null;  // Caller can't distinguish "not found" from "database crashed"
}
```

### High — Fix Before Merge

- Non-actionable user message: `"Something went wrong"` gives no recovery path
- Unjustified fallback: `return DEFAULT_CONFIG` in catch with no comment
- Broad exception catching without re-throw or log with exception details

### Medium — Fix This Sprint

- Missing context in log: error logged without orderId, userId, or relevant IDs
- Catch scope doesn't match try block's actual operations

### Review Checklist

For every `try/catch`, `try/except`, `.catch()`, `.on('error')`, or error callback:

- [ ] Non-empty catch block?
- [ ] Exception logged with context (not just a message string)?
- [ ] User informed if operation is user-initiated?
- [ ] Fallback behavior explicitly justified in a comment?
- [ ] Catch scope appropriate (not overly broad)?
- [ ] Does caller know difference between "not found" and "error"?
- [ ] Is this a critical path? (Zero tolerance — see below)

### Approved Overrides

Mark intentional suppressions with `[APPROVED_OVERRIDE]`. Valid only when ALL are true:
1. Error is expected and frequent (e.g., JSON parse on optional fields)
2. Logging would create too much noise
3. Explicit recovery logic exists (fallback value, retry, graceful degradation)
4. Justification is specific and technical

```typescript
// [APPROVED_OVERRIDE] JSON parse on optional user preferences field.
// Fails frequently on first-time users with no stored prefs.
// Logging would flood metrics; fallback to DEFAULT_PREFS is safe and documented.
try { return JSON.parse(rawPrefs); } catch { return DEFAULT_PREFS; }
```

**Bad justifications (always reject):** "Error is not important" · "Happens sometimes" · "Works fine without logging" · "Optional"

### Critical Paths — Zero Tolerance

Zero tolerance for error suppression on: core agent/orchestrator logic · auth/authorization handlers · payment processing · session store · data migration scripts · any code where silent failure corrupts persistent state.

On critical path files: flag EVERY suppressed exception as CRITICAL regardless of other heuristics.

### Output Format

```
## Silent Failure Review

### CRITICAL
- [file:line] Empty catch block in `savePayment()` — error swallowed entirely
- [file:line] `except: pass` in `process_webhook()` — no logging, no user feedback

### HIGH
- [file:line] "Something went wrong" toast in `submitForm()` — not actionable

### PASS
- `fetchConfig()` fallback to defaults is documented and intentional
```

### Hard Rules

- Empty catch blocks are forbidden — always
- Log the exception object, not just a message string
- Distinguish "not found" from "error" in return types
- Fallbacks must have a comment explaining why the default is safe
- Broad catches require justification
- Critical paths: zero tolerance
