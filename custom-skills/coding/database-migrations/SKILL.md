---
name: database-migrations
description: Use when modifying database schemas — adding/removing columns or tables, renaming fields, adding indexes, or performing data migrations — especially in production environments
---

# Database Migrations

## Overview

Production databases cannot be modified by hand. Every change must be a migration: versioned, reviewable, reversible, and tested at production scale.

**Core principles:**

1. **Every change is a migration.** No manual `ALTER TABLE` in production. Ever.
2. **Migrations are immutable once deployed.** Never edit a migration that has run in any environment.
3. **Schema changes and data changes are separate migrations.** Never mix DDL and DML in the same migration.
4. **New columns must be nullable or have defaults.** Adding `NOT NULL` without a default locks the table.
5. **Test against production-sized data.** A migration that runs in 100ms on dev may take 45 minutes on 10M rows.

---

## Safe vs Unsafe Operations

### Always safe (non-locking)

- Adding a nullable column
- Adding a column with a default value
- Adding an index `CONCURRENTLY`
- Adding a table
- Adding a constraint as `NOT VALID` (validates later, separately)

### Potentially unsafe (may lock or fail)

| Operation | Risk | Safe alternative |
|-----------|------|-----------------|
| `ALTER COLUMN` type change | Full table lock | Add new column, backfill, drop old |
| `ADD COLUMN NOT NULL` without default | Fails on existing rows | Add nullable → backfill → add constraint |
| `CREATE INDEX` (standard) | Locks writes | Use `CREATE INDEX CONCURRENTLY` |
| `DROP COLUMN` in use by app | App crashes | Expand-contract pattern (see below) |
| `RENAME COLUMN` | App crashes | Expand-contract pattern |
| `RENAME TABLE` | App crashes | Expand-contract pattern |

---

## The Expand-Contract Pattern (Zero-Downtime)

For any breaking schema change, use expand-contract. Never deploy a rename or removal in one step.

### Example: Renaming `full_name` → `display_name`

**Deployment 1 — Expand**
```sql
ALTER TABLE users ADD COLUMN display_name TEXT;
```
- App still reads/writes `full_name`
- Deploy application code that writes to BOTH columns

**Deployment 2 — Backfill**
```sql
UPDATE users SET display_name = full_name WHERE display_name IS NULL;
```
- Run as batched migration (see batch pattern below)
- App now reads `display_name`, writes both columns

**Deployment 3 — Contract**
```sql
ALTER TABLE users DROP COLUMN full_name;
```
- App only uses `display_name`
- Drop the old column

**Rule:** Each deployment must be independently deployable. Never skip steps.

---

## Safe Index Creation (PostgreSQL)

Standard `CREATE INDEX` takes a write lock for the duration. For large tables, use `CONCURRENTLY`:

```sql
-- Run as a separate migration (not in a transaction)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

Important: `CONCURRENTLY` cannot run inside a transaction block. Most migration tools auto-wrap in transactions — disable that for this migration:

```python
# Django example
class Migration(migrations.Migration):
    atomic = False  # Required for CONCURRENTLY

    operations = [
        migrations.RunSQL(
            "CREATE INDEX CONCURRENTLY idx_users_email ON users(email);",
            reverse_sql="DROP INDEX idx_users_email;"
        )
    ]
```

---

## Batch Data Migrations

Never update millions of rows in a single statement. It locks the table and can fill the write-ahead log.

```python
# Python pseudocode — works with any ORM
def run_migration_in_batches(batch_size=1000):
    last_id = 0
    while True:
        batch = (
            db.query(User)
            .filter(User.id > last_id, User.display_name.is_(None))
            .order_by(User.id)
            .limit(batch_size)
            .all()
        )
        if not batch:
            break
        for user in batch:
            user.display_name = user.full_name
        db.commit()
        last_id = batch[-1].id
        time.sleep(0.01)  # Brief pause to reduce replication lag
```

**Rules:**
- Always use `WHERE id > $last_id` (cursor-based, not OFFSET)
- Commit after each batch, not at the end
- Add a brief sleep between batches in production
- Log progress for long-running migrations

---

## Multi-Tool Reference

### Prisma

```prisma
// schema.prisma
model User {
  id          Int      @id @default(autoincrement())
  displayName String?  // Add nullable first
}
```

```bash
npx prisma migrate dev --name add_display_name
```

For operations Prisma can't generate (e.g., CONCURRENTLY):
```sql
-- In the generated migration file, replace auto-generated SQL with:
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

### Drizzle

```typescript
// migrations/0001_add_display_name.ts
export async function up(db: Database) {
  await db.schema.alterTable('users').addColumn('display_name', 'text');
}
export async function down(db: Database) {
  await db.schema.alterTable('users').dropColumn('display_name');
}
```

### Django

```python
# migrations/0002_add_display_name.py
class Migration(migrations.Migration):
    operations = [
        migrations.AddField(
            model_name='user',
            name='display_name',
            field=models.TextField(null=True),
        ),
    ]
```

Data migration (separate from schema):
```python
# migrations/0003_backfill_display_name.py
def backfill_display_name(apps, schema_editor):
    User = apps.get_model('accounts', 'User')
    User.objects.filter(display_name__isnull=True).update(
        display_name=models.F('full_name')
    )

class Migration(migrations.Migration):
    operations = [
        migrations.RunPython(backfill_display_name, migrations.RunPython.noop),
    ]
```

### golang-migrate

```sql
-- migrations/000001_add_display_name.up.sql
ALTER TABLE users ADD COLUMN display_name TEXT;

-- migrations/000001_add_display_name.down.sql
ALTER TABLE users DROP COLUMN display_name;
```

```bash
migrate -path ./migrations -database "$DATABASE_URL" up
migrate -path ./migrations -database "$DATABASE_URL" down 1
```

---

## Rollback Strategy

Every migration must have a down/rollback path documented before it runs.

**Template:**
```
Migration: add_display_name
Up:   ADD COLUMN display_name TEXT
Down: DROP COLUMN display_name
Safe to rollback: YES (no data loss)
Data migration: NO
```

When a down migration would cause data loss:
```
Migration: drop_full_name
Up:   DROP COLUMN full_name
Down: ADD COLUMN full_name TEXT (data will be empty — loss!)
Safe to rollback: NO — requires restore from backup
```

Mark unsafe rollbacks explicitly. Never pretend a destructive migration is safe to reverse.

---

## Anti-Patterns

| Anti-pattern | Consequence |
|-------------|-------------|
| Editing a deployed migration | Diverged schema between environments |
| `ADD COLUMN NOT NULL` without default | Migration fails on non-empty table |
| `UPDATE` all rows in one query | Table lock, WAL overflow, replication lag |
| Standard `CREATE INDEX` on large table | Blocks writes for minutes to hours |
| Running schema change + data migration together | Long transaction, rollback complexity |
| Testing migration only on dev data | Works locally, fails at scale |
| No rollback plan | Incident with no recovery path |

---

## Hard Rules

- **Never edit a deployed migration.** Create a new migration to fix mistakes.
- **Nullable or default first, constraint later.** Never add `NOT NULL` in the same step as adding the column.
- **Schema and data in separate migrations.** Different failure modes, different rollback strategies.
- **CONCURRENTLY for indexes on live tables.** Disable the transaction wrapper when using it.
- **Batch large data updates.** Never update millions of rows in one statement.
- **Document rollback path.** If you can't reverse it safely, say so explicitly before running.
