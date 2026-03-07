---
name: api-design
description: Use when designing or reviewing REST API endpoints — URL structure, HTTP semantics, response formats, pagination, versioning, or authentication headers. Invoke whenever someone asks about endpoint naming, HTTP methods, status codes, request/response shapes, or API versioning strategy.
---

# API Design

## Overview

REST APIs must be predictable, consistent, and easy to use. A well-designed API communicates intent through its structure. A poorly-designed one requires reading source code to understand behavior.

**Core principle:** Use nouns for resources, HTTP methods for actions, HTTP status codes for outcomes.

---

## URL Design

### Rules

- **Plural nouns** for collections: `/users`, `/orders`, `/products`
- **kebab-case** for multi-word names: `/user-profiles`, `/order-items`
- **No verbs** in paths: not `/getUser` or `/createOrder`
- **Nested for relationships** (max 2 levels): `/users/:id/orders`
- **Versioning in the path**: `/api/v1/users`

### URL patterns

| Action | Method | URL |
|--------|--------|-----|
| List all | `GET` | `/api/v1/users` |
| Get one | `GET` | `/api/v1/users/:id` |
| Create | `POST` | `/api/v1/users` |
| Full replace | `PUT` | `/api/v1/users/:id` |
| Partial update | `PATCH` | `/api/v1/users/:id` |
| Delete | `DELETE` | `/api/v1/users/:id` |
| Sub-resource list | `GET` | `/api/v1/users/:id/orders` |

**Special actions that don't fit REST:** Use a verb as a sub-resource.
- `POST /api/v1/payments/:id/refund`
- `POST /api/v1/users/:id/verify-email`

---

## HTTP Status Codes

### Success

| Code | Meaning | When |
|------|---------|------|
| `200 OK` | Success with response body | GET, PUT, PATCH |
| `201 Created` | Resource created | POST — include `Location: /api/v1/users/123` header |
| `204 No Content` | Success, no body | DELETE |

### Client errors

| Code | Meaning | When |
|------|---------|------|
| `400 Bad Request` | Malformed request | Missing required field, invalid JSON |
| `401 Unauthorized` | Not authenticated | Missing or expired token |
| `403 Forbidden` | Authenticated but no permission | Wrong role, wrong owner |
| `404 Not Found` | Resource doesn't exist | Wrong ID |
| `409 Conflict` | State conflict | Duplicate email, concurrent edit |
| `422 Unprocessable Entity` | Validation failure | Invalid field value |
| `429 Too Many Requests` | Rate limit exceeded | Include retry headers |

### Server errors

| Code | Meaning |
|------|---------|
| `500 Internal Server Error` | Unexpected failure |
| `503 Service Unavailable` | Maintenance or overload |

**Rule:** Never return `200` with an error body. The status code is the status.

---

## Response Format

### Single resource

```json
{
  "id": "usr_123",
  "email": "user@example.com",
  "createdAt": "2024-01-15T10:00:00Z"
}
```

### Collection

```json
{
  "data": [...],
  "meta": {
    "total": 1247,
    "page": 1,
    "perPage": 20
  }
}
```

### Error

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Email is already in use",
    "field": "email"
  }
}
```

**Multiple errors (validation):**

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Request validation failed",
    "details": [
      { "field": "email", "message": "Invalid email format" },
      { "field": "age", "message": "Must be 18 or older" }
    ]
  }
}
```

---

## Pagination

### Offset-based

Use when: total count matters, users need to jump to a page number, dataset is small (<100k rows).

```
GET /api/v1/users?page=2&perPage=20
```

Response includes:
```json
"meta": {
  "total": 1247,
  "page": 2,
  "perPage": 20,
  "totalPages": 63
}
```

**Problem:** `OFFSET 1000000` on a large table is slow. Concurrent inserts shift items across pages.

### Cursor-based

Use when: real-time feeds, large datasets, consistent ordering matters.

```
GET /api/v1/posts?cursor=eyJpZCI6MTIzfQ&limit=20
```

Response includes:
```json
"meta": {
  "nextCursor": "eyJpZCI6MTQzfQ",
  "hasMore": true
}
```

Cursor is opaque (base64 encoded position marker). Never expose raw database IDs or timestamps as cursors.

**Decision table:**

| Need | Use |
|------|-----|
| Total count display | Offset |
| Jump to page N | Offset |
| Real-time feed | Cursor |
| Large dataset (>100k) | Cursor |
| Consistent pages with concurrent writes | Cursor |
| Public API | Cursor (safer by default) |

---

## Filtering, Sorting, and Search

### Filtering

Simple equality via query params:
```
GET /api/v1/users?status=active&role=admin
```

Range filters with suffixes:
```
GET /api/v1/orders?createdAt_gte=2024-01-01&createdAt_lte=2024-12-31
GET /api/v1/products?price_lt=100
```

### Sorting

```
GET /api/v1/users?sort=createdAt&order=desc
GET /api/v1/users?sort=-createdAt  (minus prefix = descending)
```

Multiple sort fields:
```
GET /api/v1/users?sort=lastName,firstName
```

### Search

```
GET /api/v1/users?q=alice
```

`q` is the universal search parameter. For structured search use `search[name]=alice`.

---

## Authentication

### Headers

```http
Authorization: Bearer <token>
```

API key alternative:
```http
X-API-Key: <key>
```

**Never** put tokens in URL query parameters — they appear in server logs.

### Rate limiting response headers

Always return these on rate-limited endpoints:

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1704067200
Retry-After: 60
```

---

## Versioning

### What is a breaking change?

**Breaking — requires new version:**
- Removing a field from response
- Renaming a field
- Changing a field's type
- Removing an endpoint
- Changing required/optional status of a request field

**Non-breaking — same version:**
- Adding a new optional field to response
- Adding a new optional request field
- Adding a new endpoint
- Adding a new enum value (if clients handle unknown values gracefully)

### Strategy

1. Start at `/api/v1/` always
2. When breaking change is required: create `/api/v2/` alongside v1
3. Run both versions in parallel
4. Set deprecation timeline: minimum 6 months notice
5. Add `Sunset` header to deprecated endpoints: `Sunset: Sat, 01 Jun 2025 00:00:00 GMT`
6. After sunset: return `410 Gone` (not 404) with migration message

### What NOT to version

Non-breaking additions don't need a new version. Adding a new field to a response is safe if clients are written to ignore unknown fields (they should be).

---

## Hard Rules

- **Status codes are the status.** Never return `200` with an error body.
- **No verbs in resource paths.** `/createUser` is not REST. `POST /users` is.
- **Tokens in headers only.** Never in URLs, never in response bodies without explicit need.
- **Paginate all collections.** Never return unbounded lists.
- **Cursor for public APIs.** Offset pagination is safe internally; cursor is safer for external consumers.
- **Deprecate before removing.** Minimum 6-month sunset window for breaking changes.
