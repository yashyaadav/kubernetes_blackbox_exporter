# Runbook: BlackboxProbeSlowHttp

`probe_duration_seconds` for an HTTP target has exceeded 1s for 10 minutes.

## Triage

1. **Which phase is slow?** Query the phase breakdown to localize the issue:
   ```promql
   probe_http_duration_seconds{instance="$instance", job="blackbox"}
   ```
   The `phase` label is one of `resolve`, `connect`, `tls`, `processing`, `transfer`.
   - `resolve` slow → DNS issue (kube-dns, upstream resolver).
   - `connect` slow → network path or target accept queue.
   - `tls` slow → TLS handshake / cert chain / target CPU.
   - `processing` slow → target application latency.
   - `transfer` slow → target response size or network bandwidth.
2. **Is the target overloaded?** Cross-check the target's own metrics if you have them.
3. **Is it only one probe instance?** If only one exporter replica sees slowness, suspect that pod's node.

## Useful queries

```promql
# Phase breakdown for one instance
probe_http_duration_seconds{instance="$instance"}

# Compare across probe instances (which exporter pod scraped)
avg by (instance) (probe_duration_seconds{job="blackbox"})
```

## Resolution

If the slowness is on the target's side, escalate to the target's owner. If it is genuinely expected (the target is just slow), raise the alert threshold for that specific target rather than disabling the rule globally.
