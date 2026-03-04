---
name: performance-profiling
description: Use when code is too slow, uses too much memory, or has resource usage problems — before making any optimization changes
---

# Performance Profiling

## Overview

Optimizing without measuring is guessing. The bottleneck is almost never where you think it is.

**Core principle:** Measure first. Identify the actual bottleneck. Fix only that. Measure again.

---

## When to Use

- Code is noticeably slow in production or tests
- Memory usage is growing unexpectedly
- A specific operation takes longer than acceptable
- Before and after a proposed optimization (to validate it worked)

**Do NOT start optimizing until you have:**
1. A reproducible, measurable case
2. A baseline measurement
3. Identified the specific bottleneck via profiler

---

## The Process

### Step 1: Define the problem precisely

Vague problems produce wasted optimization. Answer:

```
What is slow?        [specific function, endpoint, query, operation]
How slow is it?      [measured time or resource usage]
What is acceptable?  [target — e.g., "under 200ms", "under 50MB"]
When does it occur?  [load level, data size, specific input]
```

If you cannot answer all four, you do not have a measurable problem yet.

### Step 2: Create a reproducible benchmark

Write a benchmark or test that:
- Runs the slow code in isolation
- Takes a consistent, measurable input
- Can be run repeatedly to get stable numbers

This is your before/after comparison tool. Without it, you cannot tell if your optimization worked.

```bash
# Examples by runtime
hyperfine 'node script.js'          # CLI tools
ab -n 1000 -c 10 http://localhost/  # HTTP endpoints
pytest --benchmark-only             # Python (pytest-benchmark)
go test -bench=. ./...              # Go
criterion (in Cargo.toml)           # Rust
```

Record the baseline: **[X ms / Y MB / Z req/s]** before touching any code.

### Step 3: Profile — find the actual bottleneck

Run a profiler, not a timer. Timers tell you it's slow. Profilers tell you where.

| Runtime | Profiler |
|---------|---------|
| Node.js | `node --prof`, `clinic.js`, `0x`, Chrome DevTools performance tab |
| Python | `cProfile` + `snakeviz`, `py-spy`, `memory_profiler` |
| Go | `pprof` (`go tool pprof`), `trace` |
| Rust | `cargo flamegraph`, `perf` |
| Browser JS | Chrome DevTools → Performance tab → Record |
| Database | `EXPLAIN ANALYZE` (PostgreSQL), `EXPLAIN` (MySQL), query plan viewers |
| General | `flamegraph` — works across runtimes |

Read the profiler output:
- Find the function/query consuming the most time (the hotspot)
- Check if it is called far more often than expected (N+1 patterns, unnecessary loops)
- Check if it allocates far more memory than expected

**The bottleneck is the single biggest contributor. Fix that first.**

### Step 4: Form a hypothesis

Before writing any code:

```
Bottleneck:  [specific function/query/operation, % of total time]
Hypothesis:  [why it is slow — specific reason]
Fix:         [what change will address it]
Expected:    [how much improvement is realistic]
```

If you cannot explain why something is slow, you do not understand it well enough to fix it. Read more.

### Step 5: Make one change

Fix the bottleneck. One change at a time.

Common fixes by category:

**Algorithmic (biggest gains):**
- O(n²) loop → O(n log n) or O(n) algorithm
- Linear search → hash map lookup
- Repeated computation → memoize/cache result

**Database:**
- Missing index on queried column
- N+1 queries → eager load / join
- Fetching all columns when only 2 are needed (`SELECT *` → `SELECT id, name`)
- No pagination on large result sets

**I/O:**
- Sequential operations that can be parallel → `Promise.all`, `asyncio.gather`, goroutines
- Repeated disk reads of same file → cache in memory
- Uncompressed payloads → enable gzip/brotli

**Memory:**
- Object allocations in hot loops → reuse objects
- Large in-memory datasets → stream instead of load all
- Memory leaks → find and remove references that prevent GC

**Caching:**
- Expensive computation with same inputs → memoize
- Expensive API call with stable results → cache with TTL

### Step 6: Measure again

Run the same benchmark from Step 2.

```
Before: [X ms]
After:  [Y ms]
Change: [Z% improvement]
```

If improvement is negligible — your hypothesis was wrong. Undo the change. Profile again.

If improvement is significant — is the target met? If yes, done. If not, go to Step 3 and find the next bottleneck.

### Step 7: Verify correctness

Performance optimizations frequently introduce bugs (caching stale data, incorrect memoization keys, race conditions in parallel code).

- [ ] All existing tests pass
- [ ] Edge cases are covered (empty input, large input, concurrent access if applicable)
- [ ] The optimization does not introduce stale data, race conditions, or incorrect results under any known input

---

## Hard Rules

- **Never optimize without a measurement.** "I think this is faster" is not acceptable.
- **Never optimize without identifying the bottleneck via profiler.** Timers are not profilers.
- **One change at a time.** Multiple simultaneous optimizations cannot be individually attributed.
- **Always measure after.** If you cannot show the improvement in numbers, you do not know it worked.
- **Verify correctness after every optimization.** Run the full test suite.

---

## Red Flags — Stop and Reassess

- "This looks slow" → measure it before touching it
- "I'll just cache everything" → caching without profiling adds complexity with unknown benefit
- "I'll rewrite this in a faster language/framework" → profile first; rewrite is last resort
- "The algorithm is fine, it's probably the database" → profile confirms this, not intuition
- Tests failing after optimization → correctness was broken; revert and investigate

---

## Common Failures

| Failure | Consequence |
|---------|------------|
| Optimizing without profiling | Fixing the wrong thing, no improvement |
| No baseline measurement | Cannot tell if optimization helped |
| Multiple changes at once | Cannot identify which change caused which effect |
| Not verifying correctness | Optimization introduces bugs that appear later |
| Stopping after first improvement | Second bottleneck was the real problem |
| Micro-optimizing non-bottlenecks | Wasted effort, negligible real-world impact |
