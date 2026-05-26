# Runbook: BlackboxExporterDown

Prometheus has been unable to scrape `/metrics` on the blackbox exporter for 5 minutes (`up{job="blackbox-exporter"} == 0`). While this fires, *every* blackbox probe is implicitly broken — no probe metrics are being collected.

## Triage

1. **Are the pods running?**
   ```bash
   kubectl -n monitoring get pods -l app.kubernetes.io/name=blackbox-exporter
   ```
2. **Are probes failing health checks?** Check pod events for liveness/readiness probe failures:
   ```bash
   kubectl -n monitoring describe pod -l app.kubernetes.io/name=blackbox-exporter
   ```
3. **Is the Service routing?**
   ```bash
   kubectl -n monitoring get endpoints blackbox-exporter
   ```
   Empty endpoints means the Service selector does not match any pod labels.
4. **Is Prometheus's discovery seeing the target?** Visit Prometheus' `/targets` page and look for `blackbox-exporter` under "Service Discovery". If the target is `down`, the error column explains why (TLS, timeout, refused).
5. **NetworkPolicy.** If a NetworkPolicy is in place, verify it allows ingress from the Prometheus pod's labels on port 9115.

## Recent changes

The most common cause of this alert is a recent change to one of:

- The ServiceMonitor's `release:` label (kube-prometheus-stack ignores rules without it).
- The Service selector vs. Deployment pod labels.
- The NetworkPolicy ingress selector.
- A rollout that introduced a bad config (the readiness probe will fail and endpoints will go empty).

## Resolution

Restore the previous-known-good state of whichever resource you changed, or fix the new resource so endpoints populate and Prometheus can scrape again. The alert clears within one scrape interval (30s) once `up` returns to 1.
