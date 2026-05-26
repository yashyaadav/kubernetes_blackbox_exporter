# Security Policy

## Reporting a Vulnerability

If you discover a security issue in the manifests, configuration, or example code in this repository, please report it privately:

- **Email:** yashyadav34@gmail.com
- Include a description, reproduction steps, and the affected file or component.

Please do not open a public GitHub issue for security reports.

## Scope

This repository ships Kubernetes manifests and example configuration for deploying [`prom/blackbox-exporter`](https://github.com/prometheus/blackbox_exporter). Vulnerabilities in the upstream Blackbox Exporter image should be reported to the [Prometheus project](https://github.com/prometheus/blackbox_exporter/security).

In-scope for this repository:

- Insecure defaults in the Deployment, ConfigMap, Service, NetworkPolicy, ServiceMonitor, or PrometheusRule manifests.
- Documentation that leads users into insecure configurations.
- Example alert rules or scrape configurations that could be exploited.

## Supported Versions

Only the `main` branch is maintained. Tagged releases reflect snapshots of `main` at a point in time.
