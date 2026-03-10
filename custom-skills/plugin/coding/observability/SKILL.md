---
name: observability
description: Use when adding logging, metrics, or tracing to a system; reviewing what a service emits in production; or designing alerting. Invoke whenever someone mentions logs, metrics, alerts, dashboards, monitoring, tracing, Datadog, CloudWatch, or Prometheus.
---

# Observability

## Overview

Observability answers "what is the system doing right now and why?" without requiring a code change to find out. It has three pillars: logs (events), metrics (aggregates), and traces (request paths). A system with good observability is debuggable in production. One without it requires guesswork.

**Core principle:** Instrument for the questions you'll need to answer during an incident, not for the questions you can answer now.

---

## The Three Pillars

| Pillar | What it answers | Example tool |
|--------|----------------|--------------|
| **Logs** | What happened? When? To which request? | ELK, Loki, CloudWatch Logs |
| **Metrics** | How often? How slow? How many? | Prometheus, Datadog, CloudWatch |
| **Traces** | Which services were involved? Where was the latency? | Jaeger, Zipkin, AWS X-Ray |

---

## Logging

### Always use structured logging (JSON)

```json
{
  "timestamp": "2024-03-15T10:23:45.123Z",
  "level": "INFO",
  "service": "payment-service",
  "trace_id": "abc-123-def-456",
  "user_id": "usr_789",
  "event": "payment.processed",
  "amount_cents": 4999,
  "currency": "USD",
  "duration_ms": 234
}
```

**Not this:**
```
[2024-03-15 10:23:45] Payment processed for user 789: $49.99 in 234ms
```

Structured logs are machine-parseable. Free-text logs require regex to query.

### Log levels — use them correctly

| Level | When | Example |
|-------|------|---------|
| `DEBUG` | Detailed diagnostic info — disable in production | "Entering payment validation, params: {...}" |
| `INFO` | Normal operations, business events | "Payment processed: order_id=123, amount=49.99" |
| `WARN` | Unexpected but handled — system continues | "Rate limit approaching: 80% of quota used" |
| `ERROR` | Failure requiring attention — request failed | "Payment gateway timeout after 30s" |
| `FATAL` / `CRITICAL` | System cannot continue | "Database connection pool exhausted" |

**Rule:** If it's not actionable, it's probably too noisy for ERROR. Use WARN. If it happens on every request, it's DEBUG, not INFO.

### What to include in logs

**Always include:**
- `timestamp` (ISO 8601, with milliseconds)
- `level`
- `service` / `component`
- `trace_id` / `request_id` (for correlation)
- `event` name (what happened)
- Relevant IDs (`user_id`, `order_id`, `session_id`)
- Duration for operations (`duration_ms`)

**Never include:**
- Passwords, tokens, API keys
- Full credit card numbers, SSNs, national IDs
- Private keys or secrets of any kind
- Excessive PII (name + address + DOB = GDPR risk)
- Request bodies that might contain the above

**Connection to `sensitive-data-guard`:** Before logging any user-submitted data, verify it cannot contain credentials or PII. Prefer logging IDs over logging values.

### Sampling

For high-volume events, sample rather than log everything:

```python
import random

def log_request(request, response, duration_ms):
    # Always log errors and slow requests
    if response.status >= 500 or duration_ms > 1000:
        logger.error("request.slow_or_failed", ...)
        return
    # Sample 1% of normal requests
    if random.random() < 0.01:
        logger.info("request.sampled", ...)
```

---

## Metrics

### The three metric types

| Type | Measures | Example |
|------|---------|---------|
| **Counter** | Total count of events (monotonically increasing) | `http_requests_total`, `errors_total` |
| **Gauge** | Current snapshot value (can go up or down) | `active_connections`, `queue_depth`, `memory_bytes` |
| **Histogram** | Distribution of values, with percentile calculation | `request_duration_seconds`, `payload_size_bytes` |

### What to measure

**For every HTTP service:**
- Request rate (requests/sec) — counter
- Error rate (5xx/sec, 4xx/sec) — counter
- Latency distribution (p50, p95, p99) — histogram
- Active connections — gauge

**For every background job:**
- Job enqueue rate — counter
- Job completion rate — counter
- Job failure rate — counter
- Queue depth — gauge
- Processing duration — histogram

**For every database:**
- Query duration by type — histogram
- Connection pool utilization — gauge
- Error rate — counter

### USE method for resources

For any resource (CPU, memory, disk, network), measure:
- **U**tilization: What % of capacity is in use?
- **S**aturation: Is there a queue building up?
- **E**rrors: What is the error rate?

---

## Distributed Tracing

Traces show the full request path across services. Each unit of work is a **span**.

### Trace structure

```
Request: GET /api/orders/123
├─ Span: api-gateway (5ms)
│   ├─ Span: auth-service.validate_token (2ms)
│   └─ Span: order-service.get_order (45ms)
│       ├─ Span: db.query (12ms)
│       └─ Span: inventory-service.check_stock (30ms)
```

### Propagate trace IDs across service boundaries

Every HTTP call between services must forward trace context:

```python
# Pass trace context in outgoing requests
headers = {
    "X-Trace-ID": current_trace_id(),
    "X-Span-ID": current_span_id(),
    "traceparent": format_w3c_traceparent()  # W3C standard
}
response = http_client.get(url, headers=headers)
```

### What to trace

- External API calls (duration, status code)
- Database queries (query type, table, duration)
- Cache hits/misses
- Queue publish/consume operations
- Any operation taking >10ms

---

## Alerting

### Alert on symptoms, not causes

| Alert on (symptoms) | Don't alert on (causes) |
|--------------------|------------------------|
| Error rate > 1% | CPU > 80% |
| p99 latency > 2s | Memory > 70% |
| Availability < 99.9% | Disk > 75% |
| Queue depth growing for 10+ min | Pod restart count |

Symptoms mean users are affected. Causes often self-resolve and create alert fatigue.

### SLO-based alerting

Define a Service Level Objective first, then alert when you're burning through it:

```yaml
# Example SLO
availability_target: 99.9%
error_budget_30d: 43.8 minutes

# Alert when burning error budget too fast
alert:
  - condition: error_rate > 1% for 5 minutes   # Burning fast
    severity: page
  - condition: error_rate > 0.1% for 1 hour    # Burning slow
    severity: ticket
```

### Alert fatigue prevention

**Page** (wake people up): System is down or severely degraded, users are affected.
**Ticket** (next business day): Trend is bad, will cause a page soon if not addressed.

If more than 5% of pages don't lead to a real action, the alert threshold is wrong.

---

## Hard Rules

- **Structured JSON logging only.** Free-text logs are unsearchable at scale.
- **Never log credentials or full PII.** Log IDs, not values. If it's user-submitted, verify before logging.
- **Include trace IDs in every log line.** Without correlation IDs, logs from multiple services are useless during an incident.
- **Use histograms for latency, not averages.** Average latency hides long tails. p99 shows what slow users experience.
- **Alert on symptoms, not causes.** High CPU doesn't mean users are affected. 5xx rate does.
- **Test your alerts.** An alert that never fires might be misconfigured. Chaos test your alerting in staging.
