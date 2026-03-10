---
name: supabase-postgres
description: Use when building with Supabase or PostgreSQL — for schema design, query optimization, RLS policies, and database best practices. Invoke when working with Supabase projects, PostgreSQL databases, or when asked about database schema, queries, or policies.
---

# Supabase & PostgreSQL Best Practices

## Overview

Patterns and pitfalls for building with Supabase and PostgreSQL. Covers schema design, Row Level Security, query performance, and common Supabase-specific patterns.

**Core principle:** The database is the source of truth. Enforce constraints and security at the database layer, not just in application code.

---

## Schema Design

### Naming Conventions

```sql
-- Tables: plural snake_case
CREATE TABLE user_profiles (...);
CREATE TABLE blog_posts (...);

-- Columns: singular snake_case
user_id, created_at, updated_at, is_published

-- Foreign keys: {singular_table_name}_id
post_id, user_id, category_id

-- Junction tables: {table1}_{table2} (alphabetical)
posts_tags, users_roles
```

### Always Include

```sql
CREATE TABLE examples (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON examples
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
```

### Data Types

| Use case | Type |
|----------|------|
| Primary key | `uuid` (default) or `bigint` (for high-insert-rate tables) |
| Timestamps | `timestamptz` (always timezone-aware) |
| Text | `text` (not `varchar(n)` unless enforcing length) |
| Money | `numeric(19,4)` (never `float`) |
| JSON | `jsonb` (indexed) not `json` |
| Boolean | `boolean` |
| Enum-like | `text` with CHECK constraint or a lookup table |

---

## Row Level Security (RLS)

**RLS is mandatory for tables accessed from the client.** Never rely on application logic alone for data access control.

```sql
-- 1. Enable RLS on every table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- 2. Default deny (no policy = no access)
-- This happens automatically when RLS is enabled

-- 3. Explicit allow policies
CREATE POLICY "Users can view own posts"
  ON posts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts"
  ON posts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 4. Service role bypasses RLS (use in server-side only)
-- Never expose service role key to client
```

### RLS Checklist

- [ ] RLS enabled on every table accessed from client
- [ ] Each operation (SELECT, INSERT, UPDATE, DELETE) has an explicit policy
- [ ] Policies use `auth.uid()` — not user-supplied values
- [ ] Service role key only used server-side
- [ ] Tested with actual client requests (not just SQL editor which runs as superuser)

---

## Query Performance

### Indexing Rules

```sql
-- Index foreign keys (always — Postgres doesn't auto-index FKs)
CREATE INDEX idx_posts_user_id ON posts (user_id);

-- Index columns used in WHERE, ORDER BY
CREATE INDEX idx_posts_created_at ON posts (created_at DESC);

-- Partial indexes for common filters
CREATE INDEX idx_posts_published ON posts (created_at DESC)
  WHERE is_published = true;

-- Index on JSON field
CREATE INDEX idx_profiles_metadata_role ON profiles
  USING gin ((metadata -> 'role'));
```

### Common Performance Pitfalls

```sql
-- ❌ N+1: fetching related records one at a time
SELECT * FROM posts;
-- then for each post: SELECT * FROM users WHERE id = post.user_id

-- ✅ Join: fetch everything at once
SELECT posts.*, users.name
FROM posts
JOIN users ON users.id = posts.user_id;

-- ❌ Fetching all columns when you need few
SELECT * FROM posts;

-- ✅ Select only needed columns
SELECT id, title, created_at FROM posts;

-- ❌ LIKE with leading wildcard can't use index
WHERE title LIKE '%search%'

-- ✅ Full-text search
WHERE to_tsvector('english', title) @@ plainto_tsquery('english', 'search')
```

---

## Supabase-Specific Patterns

### Client Setup

```typescript
import { createClient } from '@supabase/supabase-js'

// Client-side (uses anon key, subject to RLS)
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

// Server-side only (bypasses RLS — never expose to client)
const supabaseAdmin = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)
```

### Realtime Subscriptions

```typescript
const channel = supabase
  .channel('posts-changes')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'posts',
    filter: `user_id=eq.${userId}`
  }, (payload) => {
    console.log('Change received!', payload)
  })
  .subscribe()

// Always unsubscribe on cleanup
return () => { supabase.removeChannel(channel) }
```

### Edge Functions

```typescript
// Use for: sending emails, processing webhooks, calling external APIs
// NOT for: heavy computation or database queries that RLS handles

Deno.serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )
  // This client respects RLS based on the user's JWT
})
```

---

## Hard Rules

- **RLS on every client-accessible table.** No exceptions. Test it from the client.
- **Always `timestamptz`, never `timestamp`.** Timezone-naive timestamps cause subtle bugs across regions.
- **Never `float` for money.** Use `numeric(19,4)`.
- **Index all foreign keys manually.** PostgreSQL does not auto-index them.
- **Service role key is server-side only.** Never expose it in client code or env vars prefixed with `NEXT_PUBLIC_`.
- **Test RLS policies with actual client requests.** The Supabase SQL editor runs as superuser and bypasses RLS.
