---
name: silent-failure-hunter
description: Use when reviewing code for error handling quality — especially before merging. Invoke whenever catch blocks, try/except, error callbacks, or fallback values appear in a diff or file. Even if the user just asks for a "code review", check for silent failures.
---

# Silent Failure Hunter

## Overview

A silent failure is an error that is caught but not meaningfully handled — it disappears without the user knowing, without a log entry, or with misleading fallback behavior. Silent failures cause the worst kind of bugs: ones that only surface hours or days later, far from the actual cause.

**Core principle:** Any error that occurs without proper logging and user feedback is a defect. The absence of noise is not the same as success.

---

## What Silent Failures Look Like

### CRITICAL — Must fix before merge

**Empty catch block**
```typescript
try {
  await saveData(payload);
} catch (e) {
  // nothing here
}
```
The operation failed. Nobody knows. The app continues as if nothing happened.

**Swallowed exception**
```python
try:
    process_payment(order_id)
except Exception:
    pass
```
`pass` or an empty block is never acceptable for a meaningful operation.

**Silent return on failure**
```typescript
async function getUser(id: string) {
  try {
    return await db.users.findById(id);
  } catch {
    return null;  // Caller doesn't know if null = "not found" or "database crashed"
  }
}
```
`null` / `undefined` / `false` returned from a catch block without logging loses the error context permanently.

---

### HIGH — Fix before merge

**Non-actionable user message**
```typescript
} catch (err) {
  showToast("Something went wrong");
}
```
"Something went wrong" gives the user no path to recovery and the developer no way to debug.

**Unjustified fallback**
```typescript
} catch {
  return DEFAULT_CONFIG;  // Why? Is this safe? What failed?
}
```
Fallbacks must be explicitly justified. If a default is returned on failure, document: what failed, why the default is safe, and how the caller can distinguish error from empty.

**Broad exception catching without re-throw or log**
```python
try:
    parse_response(data)
except Exception as e:
    logger.error("Failed")  # No exception details logged
```
Log the exception, not just a message. Include: error type, message, relevant context (IDs, inputs).

---

### MEDIUM — Fix in current sprint

**Missing context in log**
```typescript
} catch (err) {
  logger.error("Payment failed", err);
  // Missing: orderId, userId, amount, payment method
}
```
Logs without context can't be acted on during an incident.

**Catch block more specific than needed, but wrong scope**
```typescript
} catch (NetworkError) {
  // handles network but not: parsing errors, auth errors, timeout
}
```
Narrow catches are good — but verify the scope matches what the `try` block actually does.

---

## Review Checklist

For every `try/catch`, `try/except`, `.catch()`, `.on('error')`, or error callback in the diff:

- [ ] **Is the catch block non-empty?** Empty catch = CRITICAL.
- [ ] **Is the exception logged with context?** Logging "Failed" is not sufficient. Log the exception object + relevant IDs.
- [ ] **Is the user informed?** If the operation is user-initiated, they need feedback — not silence.
- [ ] **Is fallback behavior justified?** If returning a default value, is it explicitly safe and documented?
- [ ] **Is the catch scope appropriate?** Catching `Exception` / `Error` (base class) requires explicit justification.
- [ ] **Does the caller know the difference between "not found" and "error"?** `null` returns from catch blocks must be documented or replaced with typed errors.

---

## Good vs Bad Patterns

### Good — specific, logged, user-informed

```typescript
async function saveUserProfile(userId: string, data: ProfileData) {
  try {
    await db.profiles.upsert(userId, data);
    logger.info("profile.saved", { userId });
  } catch (err) {
    logger.error("profile.save_failed", { userId, error: err });
    throw new ServiceError("Failed to save profile. Please try again.", { cause: err });
  }
}
```

- Error logged with full context (`userId`, `err`)
- Exception re-thrown so caller can handle or surface to user
- User gets actionable message

### Good — documented fallback

```typescript
async function getFeatureFlags(): Promise<FeatureFlags> {
  try {
    return await fetchRemoteFlags();
  } catch (err) {
    // Remote flag service is unavailable — fall back to hardcoded defaults
    // This is intentional: the app must function even if flag service is down
    logger.warn("feature_flags.remote_unavailable", { error: err });
    return DEFAULT_FLAGS;
  }
}
```

- Fallback explicitly documented in comment
- Warning logged (not silent)
- Safe to fall back (defaults are conservative, not destructive)

---

## Language-Specific Patterns to Watch

### TypeScript / JavaScript
- `.catch(() => {})` — empty promise rejection handler
- `.catch(console.error)` — logs but swallows (doesn't re-throw, doesn't tell the user)
- `catch (e: unknown)` without type narrowing — may cause runtime errors in the handler

### Python
- `except: pass` — absolute minimum CRITICAL finding
- `except Exception as e: logger.error(str(e))` — string of exception loses type/stack
- Bare `except:` without `as e` — can't access exception at all

### Go
- `if err != nil { return }` without logging — error silently propagated or dropped
- Returning zero values (`nil`, `""`, `0`) on error without documenting the convention

---

## Output Format

```
## Silent Failure Review

### CRITICAL
- [file:line] Empty catch block in `savePayment()` — error is swallowed entirely
- [file:line] `except: pass` in `process_webhook()` — no logging, no user feedback

### HIGH
- [file:line] "Something went wrong" toast in `submitForm()` — not actionable
- [file:line] Returns `null` on DB failure in `getUser()` — caller cannot distinguish error from not-found

### MEDIUM
- [file:line] Missing orderId/userId context in payment failure log

### PASS
- `fetchConfig()` fallback to defaults is documented and intentional
- All network errors in `apiClient.ts` re-throw after logging
```

---

## Hard Rules

- **Empty catch blocks are forbidden.** There is no legitimate reason for a catch block with no body. If you truly want to ignore an error, document why explicitly.
- **Log the exception, not just a message.** `logger.error("Failed")` loses the error type and stack. Always pass the exception object.
- **Distinguish "not found" from "error"** in return types. Typed errors or Result types are better than ambiguous `null` returns.
- **Fallbacks must be documented.** A comment explaining why the default is safe is mandatory when returning defaults from catch blocks.
- **Broad catches (`Exception`, `Error`) require justification.** If you catch everything, you must explain what you're guarding against.
