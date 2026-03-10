---
name: architecture-patterns
description: Use when designing the high-level structure of a system — choosing between architectural patterns, defining module boundaries, or planning how components interact. Invoke when asked to "architect this", "design the system structure", or "what pattern should we use for this?".
---

# Architecture Patterns

## Overview

Select and apply the right architectural pattern for the problem at hand.

**Core principle:** Architecture is the set of decisions that are expensive to reverse. Get them right early or plan to live with them.

---

## Pattern Selection Guide

| Problem | Consider |
|---------|---------|
| CRUD app, small team, fast iteration | Monolith (layered) |
| Clear domain boundaries, multiple teams | Modular monolith |
| Services that need independent scaling | Microservices |
| Event-driven with async processing | Event-driven architecture |
| User-facing frontend + API | Client-Server / BFF |
| Plugin-based extensibility | Hexagonal (Ports & Adapters) |

---

## Core Patterns

### Layered (N-Tier)

```
Presentation Layer   → handles HTTP, GraphQL, WebSocket
Business Logic Layer → domain rules, use cases
Data Access Layer    → queries, ORM, cache
Database             → source of truth
```

**Rules:**
- Each layer only talks to the layer below it
- Business logic never imports from Presentation
- Data access never contains business logic

**Best for:** REST APIs, web applications, CRUD systems

### Modular Monolith

```
src/
  auth/        ← self-contained module
    routes.ts
    service.ts
    repository.ts
  billing/     ← no direct imports from other modules
    ...
  shared/      ← shared utilities (no business logic)
    ...
```

**Module contract:** Each module exposes a public API. Other modules import from `auth/index.ts`, never from `auth/service.ts` directly.

**Best for:** Teams of 3–10, business domains with clear boundaries, starting before you know if microservices are needed.

### Hexagonal (Ports & Adapters)

```
Core Domain
  ├── Ports (interfaces)         ← what the domain needs
  │     ├── UserRepository
  │     └── EmailSender
  └── Use Cases                  ← business logic

Adapters (implementations)
  ├── Inbound: HTTP, CLI, Queue  ← how the world talks to the domain
  └── Outbound: PostgreSQL, SMTP ← how the domain talks to the world
```

**Rule:** The core domain has zero knowledge of HTTP, databases, or any infrastructure. It only knows about its ports.

**Best for:** Complex domains where testing in isolation matters; systems that might switch infrastructure (e.g., swap PostgreSQL for DynamoDB).

### Event-Driven

```
Producer → Event Bus → Consumer(s)
           (Kafka, SNS, RabbitMQ)
```

**Patterns:**
- **Event notification:** "Something happened" — receiver fetches details
- **Event-carried state transfer:** Event contains all necessary data
- **Event sourcing:** State is derived from the event log

**Best for:** Decoupled services, audit requirements, async workflows

---

## Decision Framework

For any architectural decision, answer:

1. **Coupling** — Should these two things change together? If yes → same module. If no → separate module.
2. **Scalability** — Which components need to scale independently? If none → don't split.
3. **Team boundaries** — Can different teams own different parts? If yes → module/service boundary there.
4. **Reversibility** — How hard is it to undo? Start simple; split when the pain is real.

---

## Common Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Distributed monolith | Microservices that must deploy together | Merge into a monolith; or fix deployment independence |
| Anemic domain model | Business logic in service layer; domain objects are just data bags | Move logic into domain entities |
| Shotgun surgery | One change requires edits in 10 files | Extract cohesive module |
| God object | One class/module knows too much | Split by responsibility |
| Premature microservices | Microservices before product-market fit | Start as monolith; extract services when a boundary is proven |

---

## Output Format

When designing an architecture, produce:

```markdown
## Architecture Decision — [System Name]

### Selected Pattern
[Pattern name] — [one sentence why]

### Module/Service Map
[Diagram or list: what exists and what each component owns]

### Key Boundaries
- [Component A] and [Component B] are separated because: [reason]
- [Component C] is in the same module as [D] because: [reason]

### Interface Contracts
[What each module exposes to other modules]

### Rejected Alternatives
- [Alternative 1]: rejected because [reason]
- [Alternative 2]: rejected because [reason]

### Risks
- [What could force a rearchitecture later]
```

---

## Hard Rules

- **Name the pattern explicitly.** "We'll use a modular monolith" is a decision. "We'll organize things into folders" is not.
- **Document rejected alternatives.** The decision record is incomplete without explaining what wasn't chosen and why.
- **Simplest option that fits the constraints.** Don't introduce microservices for a team of 2.
- **Interfaces before implementation.** Define what each module exposes before building the internals.
