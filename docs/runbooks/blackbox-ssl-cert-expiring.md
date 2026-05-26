# Runbook: BlackboxSslCertExpiring{Soon,Critical}

A TLS certificate observed by a blackbox probe expires within 14 days (`Soon`, warning) or 3 days (`Critical`, page).

## Triage

1. Confirm the instance and cert subject:
   ```promql
   probe_ssl_earliest_cert_expiry{instance="$instance"}
   (probe_ssl_earliest_cert_expiry{instance="$instance"} - time()) / 86400  # days remaining
   ```
2. Identify the cert's owner. For internal services, this is usually a cert-manager `Certificate` resource — look for the matching `Ingress` or `Service`.
3. Confirm renewal is configured (cert-manager, an external ACME client, or a manual rotation runbook).

## Common causes

- cert-manager renewal failing — check `Certificate` and `CertificateRequest` status, look for ACME challenge errors.
- Manual cert with no renewal automation — schedule the rotation immediately.
- Probe target updated to a new host whose cert has not yet been issued.

## Resolution

For `Critical` (≤3 days): page the owning team, force a renewal, and verify with the probe before silencing.

For `Soon` (≤14 days): file a ticket with the owning team, confirm a renewal is scheduled, and silence the alert until the renewal window closes.
