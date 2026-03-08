---
name: diagnosing
description: Use when encountering any bug, test failure, or unexpected behavior before proposing fixes, or when code is too slow, uses too much memory, or has resource usage problems. Invoke whenever something "just stopped working", an error appears, behavior doesn't match expectations, or someone says "this is slow" / "optimize this".
---

# Diagnosing

Two modes in this skill. Read the mode that matches your situation.

---

## Mode A: Debugging (Bug / Failure / Unexpected Behavior)

**Core principle:** ALWAYS find root cause before attempting fixes. No fixes without root cause investigation first. Symptom fixes are failure.

### The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully** — Read stack traces completely. Note line numbers, file paths, error codes.

2. **Reproduce Consistently** — Can you trigger it reliably? If not reproducible → gather more data, don't guess.

3. **Check Recent Changes** — Git diff, recent commits, new dependencies, config changes.

4. **Gather Evidence in Multi-Component Systems**

   When system has multiple components, add diagnostic instrumentation before proposing fixes:
   ```bash
   # Log what data enters each component boundary
   # Log what data exits each component boundary
   # Verify environment/config propagation at each layer
   # Run once to gather evidence showing WHERE it breaks
   # THEN analyze evidence to identify failing component
   ```

5. **Trace Data Flow** — Where does bad value originate? What called this with bad value? Trace up until you find the source. Fix at source, not symptom.

   See `diagnosing/root-cause-tracing.md` for complete backward-tracing technique.

### Phase 2: Pattern Analysis

1. Find working examples of similar code in the same codebase
2. Read the reference implementation COMPLETELY — don't skim
3. Identify every difference, however small — don't assume "that can't matter"
4. Understand all dependencies, config, and environment assumptions

### Phase 3: Hypothesis and Testing

1. Form a single hypothesis: "I think X is the root cause because Y" — write it down
2. Make the SMALLEST possible change to test it — one variable at a time
3. Did it work? Yes → Phase 4. No → form NEW hypothesis. DON'T stack more fixes.
4. If you don't understand X: say so. Ask for help. Research more.

### Phase 4: Implementation

1. Create a failing test case first (use `superpowers:test-driven-development`)
2. Implement single fix addressing the root cause — ONE change at a time
3. Verify: test passes? No other tests broken?
4. **If fix doesn't work after 3+ attempts:** STOP. Question the architecture.

   Pattern indicating architectural problem: each fix reveals new coupling in a different place · fixes require "massive refactoring" · each fix creates new symptoms elsewhere.

   Discuss with your human partner before attempting more fixes.

See `diagnosing/defense-in-depth.md` and `diagnosing/condition-based-waiting.md` for supporting techniques.

### Red Flags — Return to Phase 1

Any of these thoughts mean STOP:
- "Quick fix for now" · "Just try changing X" · "Add multiple changes, run tests"
- "It's probably X, let me fix that" · "I don't fully understand but this might work"
- "One more fix attempt" (when already tried 2+) · each fix reveals new problem elsewhere

### Human Partner Signals You've Drifted

- "Is that not happening?" — you assumed without verifying
- "Will it show us...?" — you should have added evidence gathering
- "Stop guessing" — proposing fixes without understanding
- "Ultrathink this" — question fundamentals, not just symptoms

---

## Mode B: Performance Profiling (Slow / Memory / Resource)

**Core principle:** Optimizing without measuring is guessing. The bottleneck is almost never where you think it is. Measure first. Identify the actual bottleneck. Fix only that. Measure again.

### Step 1: Define the Problem Precisely

Answer all four before touching anything:
```
What is slow?        [specific function, endpoint, query, operation]
How slow is it?      [measured time or resource usage]
What is acceptable?  [target — e.g., "under 200ms", "under 50MB"]
When does it occur?  [load level, data size, specific input]
```

### Step 2: Create a Reproducible Benchmark

```bash
hyperfine 'node script.js'          # CLI tools
ab -n 1000 -c 10 http://localhost/  # HTTP endpoints
pytest --benchmark-only             # Python (pytest-benchmark)
go test -bench=. ./...              # Go
```

Record baseline: **[X ms / Y MB / Z req/s]** before touching any code.

### Step 3: Profile — Find the Actual Bottleneck

| Runtime | Profiler |
|---------|---------|
| Node.js | `node --prof`, `clinic.js`, `0x`, Chrome DevTools |
| Python | `cProfile` + `snakeviz`, `py-spy`, `memory_profiler` |
| Go | `pprof` (`go tool pprof`), `trace` |
| Rust | `cargo flamegraph`, `perf` |
| Browser JS | Chrome DevTools → Performance tab → Record |
| Database | `EXPLAIN ANALYZE` (PostgreSQL), `EXPLAIN` (MySQL) |

The bottleneck is the single biggest contributor. Fix that first.

### Step 4: Form a Hypothesis

```
Bottleneck:  [specific function/query, % of total time]
Hypothesis:  [why it is slow — specific reason]
Fix:         [what change will address it]
Expected:    [how much improvement is realistic]
```

### Step 5: Make One Change

Common fixes:
- **Algorithmic:** O(n²) → O(n log n) · linear search → hash map · repeated computation → memoize
- **Database:** missing index · N+1 queries → eager load · `SELECT *` → specific columns · no pagination
- **I/O:** sequential → parallel (`Promise.all`, `asyncio.gather`) · repeated disk reads → cache · add compression
- **Memory:** object allocations in hot loops → reuse · large datasets → stream

### Step 6: Measure Again

```
Before: [X ms]
After:  [Y ms]
Change: [Z% improvement]
```

If negligible: hypothesis was wrong. Undo. Profile again.
If significant: is target met? Yes → done. No → go to Step 3, find next bottleneck.

### Step 7: Verify Correctness

- [ ] All existing tests pass
- [ ] No stale data, race conditions, or incorrect results

### Hard Rules

- Never optimize without a measurement
- Never optimize without identifying the bottleneck via profiler
- One change at a time
- Always measure after
- Verify correctness after every optimization
