---
name: typescript-advanced-types
description: Use when writing complex TypeScript types — generics, conditional types, mapped types, template literals, or utility types. Invoke when TypeScript types are getting complex, when you need to derive a type from another, or when asked to "type this properly" in TypeScript.
---

# TypeScript Advanced Types

## Overview

Patterns for writing precise, maintainable TypeScript types. Covers generics, conditional types, mapped types, and common utility patterns.

**Core principle:** Types are documentation that the compiler checks. A type that's too loose defeats the purpose; a type that's too complex defeats readability.

---

## Generics

### Constrained generics

```typescript
// Without constraint — too permissive
function getProperty<T, K>(obj: T, key: K) { ... }

// With constraint — key must exist on obj
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key]
}
```

### Generic defaults

```typescript
interface ApiResponse<T = unknown> {
  data: T
  status: number
  message: string
}

// Usage without type arg (uses default)
const res: ApiResponse = { data: null, status: 200, message: "OK" }
// Usage with type arg
const res: ApiResponse<User> = { data: user, status: 200, message: "OK" }
```

---

## Conditional Types

```typescript
// Basic conditional
type IsString<T> = T extends string ? true : false

// Infer within conditional
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T
type UnwrapArray<T> = T extends Array<infer U> ? U : T

// Distributive conditional (applies to each member of a union)
type NonNullable<T> = T extends null | undefined ? never : T
// NonNullable<string | null | undefined> → string
```

---

## Mapped Types

```typescript
// Make all properties optional
type Partial<T> = { [K in keyof T]?: T[K] }

// Make all properties required
type Required<T> = { [K in keyof T]-?: T[K] }

// Make all properties readonly
type Readonly<T> = { readonly [K in keyof T]: T[K] }

// Pick specific keys
type Pick<T, K extends keyof T> = { [P in K]: T[P] }

// Transform values
type Nullable<T> = { [K in keyof T]: T[K] | null }

// Remap keys
type Prefixed<T, P extends string> = {
  [K in keyof T as `${P}${Capitalize<string & K>}`]: T[K]
}
// Prefixed<{ name: string }, "user"> → { userName: string }
```

---

## Template Literal Types

```typescript
type EventName = "click" | "focus" | "blur"
type HandlerName = `on${Capitalize<EventName>}`
// → "onClick" | "onFocus" | "onBlur"

type Route = `/api/${string}`
// Matches any string starting with /api/

type DeepKey<T, K extends keyof T = keyof T> =
  K extends string
    ? T[K] extends object
      ? `${K}.${DeepKey<T[K]>}`
      : K
    : never
// DeepKey<{ user: { name: string, age: number } }>
// → "user" | "user.name" | "user.age"
```

---

## Discriminated Unions

The most powerful pattern for type-safe state:

```typescript
type Result<T, E = Error> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: E }
  | { status: 'loading' }

function handle<T>(result: Result<T>) {
  switch (result.status) {
    case 'success': return result.data  // T — narrowed
    case 'error':   return result.error // E — narrowed
    case 'loading': return null
  }
}
```

---

## Utility Types Reference

| Type | What it does |
|------|-------------|
| `Partial<T>` | All properties optional |
| `Required<T>` | All properties required |
| `Readonly<T>` | All properties readonly |
| `Pick<T, K>` | Only the listed keys |
| `Omit<T, K>` | All keys except listed |
| `Record<K, V>` | Object with K keys and V values |
| `Exclude<T, U>` | Members of T not in U |
| `Extract<T, U>` | Members of T that are in U |
| `NonNullable<T>` | Remove null and undefined |
| `ReturnType<T>` | Return type of a function |
| `Parameters<T>` | Parameters tuple of a function |
| `Awaited<T>` | Unwrap nested Promise types |

---

## Common Patterns

### Builder pattern with type tracking

```typescript
class QueryBuilder<T extends object = {}> {
  private fields: T = {} as T

  select<K extends string, V>(key: K, value: V): QueryBuilder<T & Record<K, V>> {
    return new QueryBuilder<T & Record<K, V>>()
  }
}
```

### Exhaustive switch

```typescript
function assertNever(x: never): never {
  throw new Error(`Unhandled case: ${JSON.stringify(x)}`)
}

type Shape = { kind: 'circle' } | { kind: 'square' }

function area(s: Shape): number {
  switch (s.kind) {
    case 'circle': return Math.PI
    case 'square': return 1
    default: return assertNever(s) // compile error if case is missed
  }
}
```

---

## Hard Rules

- **Prefer discriminated unions over optional fields** for mutually exclusive states
- **Avoid `any` — use `unknown` and narrow** when the type is genuinely unknown
- **Don't over-type** — if `string` is correct, don't use `string & Brand<'UserId'>`
- **Generic names:** `T` for single type, `T, U` for two, `K` for key, `V` for value
- **Export types alongside implementations** — co-locate types with the code they describe
