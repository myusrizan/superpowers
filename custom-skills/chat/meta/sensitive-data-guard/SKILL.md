---
name: sensitive-data-guard
description: Use when shared content may contain sensitive data — API keys, passwords, tokens, private keys, credentials, PII, or connection strings — before proceeding with any task involving that content
---

# Sensitive Data Guard

## Overview

Sensitive data in shared content is a security risk. It can leak into logs, context files, responses, or external services. This skill stops the workflow, identifies what was found, and resolves it before any work proceeds.

**Core principle:** Never repeat a sensitive value. Flag the type and location — not the value itself.

---

## When to Use

**Trigger immediately when you detect:**
- `.env` files, config files, or settings with real values
- Code containing hardcoded credentials or tokens
- Database or service connection strings with embedded credentials
- Log output, error messages, or stack traces containing secrets
- Any paste that includes a key, token, or password field with a non-placeholder value

**Also trigger when:**
- User shares a file and the filename suggests sensitivity (`.env`, `secrets.yml`, `credentials.json`, `*.pem`, `*.key`)
- User asks to debug something and shares config that contains credentials

---

## Detection Patterns

### Credentials & Tokens

| Type | Indicators |
|------|-----------|
| OpenAI / Anthropic keys | `sk-`, `sk-ant-`, `claude-` prefixes |
| AWS credentials | `AKIA`, `ASIA` prefixes; `aws_access_key_id`, `aws_secret_access_key` |
| GitHub tokens | `ghp_`, `gho_`, `ghs_`, `ghr_` prefixes |
| Google / GCP | `AIza`, service account JSON with `private_key` field |
| Generic API keys | Fields named `api_key`, `apiKey`, `API_KEY`, `token`, `secret` with non-placeholder values |
| Bearer tokens | `Authorization: Bearer <value>` where value is not a placeholder |
| Private keys | `-----BEGIN RSA PRIVATE KEY-----`, `-----BEGIN EC PRIVATE KEY-----`, `-----BEGIN OPENSSH PRIVATE KEY-----` |
| Passwords | Fields named `password`, `passwd`, `pwd`, `pass` with non-placeholder values |

### Connection Strings

| Type | Pattern |
|------|---------|
| Database URLs | `postgres://user:pass@host`, `mysql://user:pass@host`, `mongodb+srv://user:pass@` |
| Redis | `redis://:password@host` |
| Generic | Any URL with `user:password@` embedded |

### PII

| Type | Indicators |
|------|-----------|
| Email addresses | `user@domain.com` patterns in data (not in comments or docs) |
| Phone numbers | Numeric patterns matching phone formats in data fields |
| SSN / National ID | 9-digit patterns in fields named `ssn`, `national_id`, `tax_id` |
| Credit card numbers | 16-digit numeric sequences |
| Full names + identifiers | Name + ID/DOB combinations in data |

### Placeholder vs. Real Value

These are safe (placeholders):
```
API_KEY=your-api-key-here
password=<PASSWORD>
token=REPLACE_ME
secret=xxxxxxxx
```

These are not safe (real values):
```
API_KEY=sk-proj-abc123xyz789...
password=MySuperSecret!2024
token=ghp_Abc123DefGhiJkl456
```

---

## Required Actions

### Step 1: STOP

Do not proceed with the requested task. Do not reference, quote, or repeat any detected value.

### Step 2: Flag what was found

Report the **type** and **location** — never the value itself.

```
⚠️ Sensitive data detected before proceeding:

- [API Key] Line 3 of .env — field: OPENAI_API_KEY
- [Database password] src/config.ts:12 — connection string contains embedded credentials
- [Private key] id_rsa — RSA private key (full file)

I have not included these values in my response.
```

### Step 3: Issue revocation warning — ALWAYS, regardless of next steps

This warning is mandatory. Issue it even if the user says the data is test data or proceeds anyway.

```
🔑 ACTION REQUIRED — Treat this credential as compromised:

This value was already transmitted to an AI model. It may appear in:
- Conversation history
- Model provider logs
- This session's context

Redacting it going forward does NOT undo the exposure.

For each credential detected:
→ Revoke or rotate it now at the issuing service
→ Generate a new credential after revoking
→ Update any systems using the old value

Revocation links (common services):
- OpenAI keys:    platform.openai.com/api-keys
- Anthropic keys: console.anthropic.com/settings/keys
- GitHub tokens:  github.com/settings/tokens
- AWS keys:       console.aws.amazon.com/iam/home#/security_credentials
- GCP keys:       console.cloud.google.com/iam-admin/serviceaccounts
```

Do not continue until the user has acknowledged this warning.

### Step 4: Offer resolution for the current task

Present three options:

```
How would you like to proceed with the current task?

A) Redact now — I'll replace sensitive values with descriptive placeholders
   and continue with the task using the redacted version.

B) You'll redact — share the redacted version and I'll continue then.

C) Proceed anyway — you acknowledge the data is intentional test/dummy data
   or you accept the risk.
```

### Step 5: If redacting (Option A)

Replace each sensitive value with a descriptive placeholder in `<UPPER_SNAKE_CASE>` format:

| Original | Placeholder |
|----------|------------|
| `sk-proj-abc123...` | `<OPENAI_API_KEY>` |
| `MySuperSecret!2024` | `<DATABASE_PASSWORD>` |
| `ghp_Abc123...` | `<GITHUB_TOKEN>` |
| `postgres://user:pass@host/db` | `postgres://<DB_USER>:<DB_PASSWORD>@<DB_HOST>/<DB_NAME>` |
| *(full private key block)* | `<RSA_PRIVATE_KEY>` |

Show the redacted version to the user for confirmation before proceeding.

---

## Hard Rules

**Never:**
- Repeat a sensitive value in any response, suggestion, or code example
- Include sensitive values in context logs (`logs/`), plans, or generated files
- Use a real credential as an example — always use the placeholder form
- Proceed silently when sensitive data is detected

**Always:**
- Flag before acting
- Report type + location, not the value
- Confirm with the user before continuing after redaction

---

## After Resolution

Once the user has acknowledged or redaction is complete, proceed with the original task using only the redacted form. If the task requires actual credential values to run (e.g., testing an API call), note:

```
Note: The task requires a real value for <OPENAI_API_KEY> to execute.
Set it in your environment (e.g., export OPENAI_API_KEY=...) and run the command yourself,
or provide it in a way that won't be logged here.
```

---

## Common Failures

| Failure | Consequence |
|---------|------------|
| Proceeding without flagging | Sensitive value gets quoted in response, logged in context |
| Flagging the value itself ("I see your key is sk-abc...") | Repeats the secret unnecessarily |
| Only flagging `.env` files | Misses hardcoded secrets in source code |
| Treating all non-placeholder strings as sensitive | False positives — check for patterns, not just non-empty fields |
| Assuming test data is safe without confirmation | Test environments sometimes use real credentials |
| Skipping revocation warning because "user seems in a hurry" | User never rotates the key; exposed credential stays active |
| Skipping revocation warning because user picks Option C | Exposure already happened — rotation is still required regardless of what they do next |
| Treating redaction as sufficient | Redacting going forward does not undo past exposure; rotation is always needed |
