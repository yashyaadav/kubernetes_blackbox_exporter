# Runbook: BlackboxProbeFailing

The blackbox exporter has been reporting `probe_success == 0` for a target for at least 5 minutes.

## Triage

1. **Is the target itself down?** Hit the URL from outside the cluster (browser, `curl` from your laptop). If it fails the same way, the issue is the target, not the prober.
2. **Is the exporter healthy?** Check the `BlackboxExporterDown` alert and `up{job="blackbox-exporter"}`. If the exporter is down, every probe will fail — fix that first.
3. **DNS resolution.** Exec into the exporter pod and try `nslookup <target-host>`. If DNS fails, check the NetworkPolicy egress rule for kube-dns.
4. **Network egress.** From the exporter pod, `wget -O- <target-url>`. If it hangs, the cluster's egress (NetworkPolicy, egress firewall, NAT gateway) is blocking the prober.
5. **Module mismatch.** A target probed with the wrong module (e.g. `http_2xx` against an HTTPS-only host) will fail. Confirm the module in the alert label matches what the target actually serves.

## Useful queries

```promql
# All currently failing probes
probe_success == 0

# Recent state changes for this instance
changes(probe_success{instance="$instance"}[1h])

# Status code observed
probe_http_status_code{instance="$instance"}
```

## Common causes

- Expired TLS certificate (cross-reference with `BlackboxSslCertExpiringCritical`).
- Target returning 5xx (cross-reference with `BlackboxProbeHttpFailure`).
- Probe target moved or was deleted; remove it from the scrape config.

## Resolution

If the target genuinely needs to be down, silence the alert in Alertmanager with a justification, then either fix the target or remove it from the probe list.
