
# Kubernetes Blackbox Exporter Setup

This guide will walk you through setting up the Blackbox Exporter in a Kubernetes cluster running on Minikube in an EC2 instance, along with Prometheus, Grafana, and other related services.

## Prerequisites

Before you start, ensure that:
- You have access to an EC2 instance running Minikube.
- You have SSH access to the EC2 instance.
- Prometheus and Grafana are installed and running in the `monitoring` namespace.

---

## 📥 Apply Blackbox Exporter Manifests

1. **Apply the ConfigMap for Blackbox Exporter**:
   ```bash
   kubectl apply -f blackbox_cm.yaml -n monitoring
   ```

2. **Apply the Blackbox Exporter Deployment**:
   ```bash
   kubectl apply -f blackbox_deployment.yaml -n monitoring
   ```

3. **Apply the Blackbox Exporter Service**:
   ```bash
   kubectl apply -f blackbox_svc.yaml -n monitoring
   ```

---

## 🌐 Expose Blackbox Exporter on EC2

Make sure the security group for your EC2 instance allows traffic on port **30500** to access the Blackbox Exporter.

### Access Blackbox Exporter from Local Browser

To expose Prometheus, Grafana, Kube-state-metrics, Elasticsearch, Kibana, and Blackbox Exporter on your local machine, set up port forwarding:

```bash
# <minikube_ip> : 192.168.49.2
# For example
# Exclude Elastic Kibana and kube-state-metrics if not installed earlier
ssh -i "your_ec2_key.pem" -L 9090:192.168.49.2:31062 \  # Prometheus
-L 3000:192.168.49.2:30717 \  # Grafana
-L 8080:192.168.49.2:30767 \  # Kube-state-metrics
-L 9200:192.168.49.2:30092 \  # Elasticsearch
-L 5601:192.168.49.2:30000 \  # Kibana
-L 9115:192.168.49.2:30500 \  # Blackbox Exporter
ubuntu@<public_ip_ec2_instance>
```

### 🔗 Local Access to Blackbox Exporter

Access the Blackbox Exporter in your local browser using:

```
http://localhost:9115
```

---

### 🌍 Access Blackbox Exporter from EC2 Instance

Alternatively, you can access the Blackbox Exporter directly from the EC2 instance by visiting:

```
http://<public_ip_ec2_instance>:30500
```

---

## ⚙️ Configure Prometheus for Blackbox Exporter Scraping

1. **Edit the Prometheus ConfigMap to Add Scrape Configurations**:

   First, retrieve the list of ConfigMaps in the `monitoring` namespace:
   ```bash
   kubectl get configmaps -n monitoring
   ```

2. **Edit the Prometheus ConfigMap**:
   ```bash
   kubectl edit configmap <prometheus-cm-name> -n monitoring
   ```
   # Example changes to prometheus.yaml
   # This job is for scraping blackbox-exporter metrics
   ```bash
   - job_name: 'blackbox-exporter-metrics'
        metrics_path: /probe
        params:
          module: [http_endpoint]
        static_configs:
          - targets:
              - https://www.google.com
              - http://<service_name>.<namespace_name>.svc:3000/<endpoint_name>
        relabel_configs:
         - source_labels: [__address__]
           target_label: __param_target
         - source_labels: [__param_target]
           target_label: instance
         - target_label: __address__
           replacement: "blackbox-exporter.monitoring.svc:9115"
    ```

---

## 🔄 Restart Prometheus

After updating the Prometheus ConfigMap, you need to restart the Prometheus server to apply the changes.

- **For Prometheus as a Deployment**:
  ```bash
  kubectl rollout restart deployment <prometheus-deployment-name> -n monitoring
  ```

  Example:
  ```bash
  kubectl rollout restart deployment prometheus-server -n monitoring
  ```

- **For Prometheus as a StatefulSet**:
  ```bash
  kubectl rollout restart statefulset prometheus-server -n monitoring
  ```

---

## 🚀 Ready to Monitor!

You should now be able to access all services, including the Blackbox Exporter, through Prometheus and Grafana.

### Quick Access Links (If accessing from local browser and minikube on EC2 instance):
- **Prometheus**: `http://localhost:9090`
- **Grafana**: `http://localhost:3000`
- **Kube-State-Metrics**: `http://localhost:8080/metrics`
- **Elasticsearch**: `http://localhost:9200`
- **Kibana**: `http://localhost:5601`
- **Blackbox Exporter**: `http://localhost:9115`

### Quick Access Links (If accessing services from minikube clusters):
- **Blackbox Exporter**: `http://<minikube_ip:<node_port>`

---

Now you're all set up! 🎉 
