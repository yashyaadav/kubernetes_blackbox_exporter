# Running on Minikube inside an EC2 instance

This is the original deployment story for this repo — Prometheus + Grafana + Blackbox Exporter running in a Minikube cluster on an EC2 instance, accessed from a local browser over SSH port-forwarding. The main README treats the manifests as generic Kubernetes resources; this appendix documents the specific EC2 + Minikube workflow.

## Prerequisites

- An EC2 instance with Minikube installed and running.
- SSH access to the instance.
- Prometheus and Grafana already deployed in the `monitoring` namespace.

## Exposing the exporter via NodePort

The default Service in `manifests/04-service.yaml` is `ClusterIP`. For NodePort access (which is how you'd reach Minikube services from outside the VM), patch or override the Service:

```bash
kubectl -n monitoring patch svc blackbox-exporter -p \
  '{"spec":{"type":"NodePort","ports":[{"port":9115,"targetPort":"http","nodePort":30500,"name":"http"}]}}'
```

Or maintain a local overlay file (`04-service.local.yaml`, gitignored) with `type: NodePort`.

Make sure your EC2 security group allows inbound traffic on the NodePort (30500 in this example), or keep it private and use SSH port-forwarding (below).

## SSH port-forwarding from your laptop

```bash
ssh -i your_ec2_key.pem \
    -L 9090:192.168.49.2:31062 \
    -L 3000:192.168.49.2:30717 \
    -L 9115:192.168.49.2:30500 \
    ubuntu@<ec2-public-ip>
```

Replace `192.168.49.2` with `minikube ip` from the EC2 instance, and the NodePorts with the actual values from `kubectl get svc -n monitoring`.

**Note:** do not put inline `# comments` on the same line as `\` continuations — the backslash escapes the newline but the `#` starts a comment, which breaks the command. Put comments on their own lines.

After the SSH session is up, the exporter is reachable at `http://localhost:9115`.

### Access from the EC2 instance directly

```
http://<minikube-ip>:<nodeport>
# or, if the EC2 instance has a public IP and the security group allows it:
http://<ec2-public-ip>:<nodeport>
```

## Quick-access table (typical NodePorts)

If you have the full kube-prometheus-stack + Elastic stack deployed alongside, the conventional NodePort layout used in this setup was:

| Service             | Local port | NodePort | Notes                         |
| ------------------- | ---------- | -------- | ----------------------------- |
| Prometheus          | 9090       | 31062    |                               |
| Grafana             | 3000       | 30717    |                               |
| Kube-State-Metrics  | 8080       | 30767    | `/metrics` only               |
| Elasticsearch       | 9200       | 30092    | optional                      |
| Kibana              | 5601       | 30000    | optional                      |
| Blackbox Exporter   | 9115       | 30500    |                               |

Replace these with the actual NodePorts in your cluster (`kubectl get svc -n monitoring`).
