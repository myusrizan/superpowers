---
name: better-auth
description: Use when implementing authentication — to apply auth best practices, avoid common security pitfalls, and choose the right auth pattern for the use case. Invoke when building login flows, session management, OAuth integration, or any auth-related feature.
---

# Better Auth Best Practices

## Overview

Implement authentication correctly the first time. Auth failures are security incidents.

**Core principle:** Auth is not a feature — it's a constraint. Every other feature must respect its rules.

---

## Auth Pattern Selection

| Requirement | Pattern |
|-------------|---------|
| Web app, server-side sessions | Session cookies (HttpOnly, Secure, SameSite) |
| SPA or mobile app, stateless | JWTs with refresh tokens |
| Third-party login (Google, GitHub) | OAuth 2.0 / OIDC |
| Service-to-service | API keys or mTLS |
| Temporary, scoped access | Signed URLs or short-lived tokens |

---

## Password Authentication

### Hashing

```typescript
import bcrypt from 'bcrypt'

// Hashing (at registration)
const SALT_ROUNDS = 12  // Never below 10; 12 is the 2025 standard
const hash = await bcrypt.hash(password, SALT_ROUNDS)

// Verification (at login)
const isValid = await bcrypt.compare(inputPassword, storedHash)
```

**Rules:**
- Never store plaintext passwords — not even temporarily
- Never use MD5 or SHA-1 for passwords
- Use bcrypt, argon2, or scrypt — never a general hash function
- Cost factor ≥ 12 for bcrypt; ≥ 2 for argon2id

### Password Requirements

```typescript
function validatePassword(password: string): { valid: boolean; errors: string[] } {
  const errors: string[] = []
  if (password.length < 12) errors.push("Must be at least 12 characters")
  if (!/[A-Z]/.test(password)) errors.push("Must contain uppercase")
  if (!/[0-9]/.test(password)) errors.push("Must contain a number")
  // Don't require special chars — length is more effective
  // Do check against breach databases (HaveIBeenPwned API)
  return { valid: errors.length === 0, errors }
}
```

---

## Session Management

### Cookie Configuration

```typescript
// Express / any Node.js server
res.cookie('session_id', sessionToken, {
  httpOnly: true,   // No JS access — prevents XSS theft
  secure: true,     // HTTPS only — set false only in dev
  sameSite: 'lax',  // CSRF protection; 'strict' for more sensitive apps
  maxAge: 7 * 24 * 60 * 60 * 1000,  // 7 days in ms
  path: '/',
})
```

### Session Invalidation

- On logout: delete the server-side session record
- On password change: invalidate ALL existing sessions
- On suspicious activity: invalidate the specific session
- Session IDs must be cryptographically random: `crypto.randomBytes(32).toString('hex')`

---

## JWT Best Practices

```typescript
import jwt from 'jsonwebtoken'

// Sign
const token = jwt.sign(
  { userId: user.id, role: user.role },  // Payload — minimal, no sensitive data
  process.env.JWT_SECRET!,               // ≥ 256 bits entropy
  { expiresIn: '15m', algorithm: 'HS256' }  // Short expiry for access tokens
)

// Verify
try {
  const payload = jwt.verify(token, process.env.JWT_SECRET!)
} catch (err) {
  // Handle: TokenExpiredError, JsonWebTokenError, NotBeforeError
  throw new AuthError('Invalid or expired token')
}
```

**JWT rules:**
- Access tokens: 15 minutes max
- Refresh tokens: 7–30 days, stored in HttpOnly cookie
- Never put sensitive data in the payload (it's base64, not encrypted)
- Always verify signature — don't just decode
- Rotate refresh tokens on use (refresh token rotation)

---

## OAuth 2.0 / OIDC

```typescript
// Authorization Code Flow (for web apps)
// Step 1: Redirect user to provider
const authUrl = `https://accounts.google.com/o/oauth2/auth?
  client_id=${CLIENT_ID}
  &redirect_uri=${REDIRECT_URI}
  &response_type=code
  &scope=openid email profile
  &state=${generateCSRFToken()}  // Prevent CSRF
  &code_challenge=${codeChallenge}  // PKCE for public clients
  &code_challenge_method=S256`

// Step 2: Exchange code for tokens (server-side)
const tokens = await exchangeCode(code, codeVerifier)

// Step 3: Verify and extract user info from ID token
const userInfo = await verifyIdToken(tokens.id_token)
```

---

## Common Auth Vulnerabilities

| Vulnerability | How to Prevent |
|---------------|---------------|
| Brute force | Rate limit login attempts (5/min per IP, 10/min per account) |
| Credential stuffing | Check against HaveIBeenPwned API on registration |
| Session fixation | Regenerate session ID after login |
| CSRF | SameSite cookies + CSRF token for state-changing requests |
| Token leakage | JWTs in HttpOnly cookies, not localStorage |
| Timing attacks | Use `crypto.timingSafeEqual` for token comparison |
| Enumeration | Same response for "user not found" and "wrong password" |

---

## Auth Checklist

- [ ] Passwords hashed with bcrypt/argon2 (cost ≥ 12)
- [ ] Cookies: HttpOnly, Secure, SameSite=Lax
- [ ] Session IDs: cryptographically random, rotated on privilege change
- [ ] Rate limiting on login endpoint
- [ ] Logout invalidates server-side session
- [ ] Password change invalidates all sessions
- [ ] JWT access tokens expire in ≤ 15 minutes
- [ ] No sensitive data in JWT payload
- [ ] OAuth state parameter validated (prevents CSRF)
- [ ] Error messages don't reveal user existence

---

## Hard Rules

- **Never store plaintext passwords.** This includes logs, caches, and analytics.
- **HttpOnly cookies for tokens.** localStorage is accessible to any script — it's one XSS away from compromise.
- **Rate limit auth endpoints.** No exceptions for "internal" endpoints.
- **Test the failure path, not just success.** An auth system that fails open is worse than one that fails closed.
- **Audit the auth surface with `coding/security`.** Auth code is the highest-value target — review it separately.
