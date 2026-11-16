# 03 — Deployment runbook (reference)

> **Change safety:** The documented cluster already has the `monitoring` Helm release. Do **not** blindly re-run the installation there. This page explains how the original installation was performed and what would be required on a separate authorized environment.

## Stage A — Check baseline

```powershell
kubectl get nodes
kubectl get deployment,pods -n gitops-demo
kubectl get pods -n argocd
aws eks list-addons --region us-east-1 --cluster-name gitops-eks-cluster
helm list -A
```

Baseline outputs must be captured **before** changes so monitoring does not mask an unrelated GitOps incident.

## Stage B — AWS CloudWatch add-on

The lab installed `amazon-cloudwatch-observability` through EKS managed add-ons and associated EKS Pod Identity. After deployment it showed:

```text
Status: ACTIVE
Version: v7.0.1-eksbuild.1
Health issues: []
```

The add-on was configured with [cloudwatch-addon-config.json](../manifests/cloudwatch-addon-config.json), disabling blanket Application Signals auto-monitoring. The file is a **configuration fragment**, not a complete IAM/add-on provisioning script.

## Stage C — EBS CSI

Before installation the cluster only registered the EFS CSI driver. After adding `aws-ebs-csi-driver` as a managed add-on with suitable Pod Identity:

```text
Status: ACTIVE
Version: v1.68.0-eksbuild.1
Health issues: []
CSI registered: ebs.csi.aws.com
```

For a **fresh cluster**, a verified `gp3-monitoring` StorageClass can be created using [the manifest](../manifests/gp3-monitoring.storageclass.yaml):

```powershell
kubectl apply -f .\manifests\gp3-monitoring.storageclass.yaml
```

**Do not change/delete an existing class automatically.** The example has `reclaimPolicy: Delete`, so removing bound PVC/PV resources can destroy persistent data.

## Stage D — Separate GP3 smoke test

The operator deployed a disposable BusyBox pod and PVC, confirmed the PVC became `Bound`, and got `EBS_MOUNT_OK` from its logs. The disposable pod and PVC were then removed. Do not reproduce this test in an occupied namespace without inspecting names and authorizing resource creation and cleanup.

## Stage E — Install kube-prometheus-stack

For a **separate authorized cluster**, the corresponding reference sequence from the root of this repository would be:

```powershell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm search repo prometheus-community/kube-prometheus-stack
helm install monitoring prometheus-community/kube-prometheus-stack --version 93.3.0 --namespace monitoring --create-namespace -f .\manifests\monitoring-values.yaml --wait --timeout 15m
```

The included [monitoring-values.yaml](../manifests/monitoring-values.yaml) is a *reference reconstruction*. Before any future rollout, compare with the full released values:

```powershell
helm get values monitoring -n monitoring -o yaml
```

Only an authorized operator should decide whether a new `helm install`, `upgrade` or recovery operation is needed.

## Stage F — Verify without mutation

```powershell
helm list -n monitoring
kubectl get pods -n monitoring
kubectl get pvc -n monitoring
kubectl get storageclass gp3-monitoring -o wide
kubectl get deployment,pods -n gitops-demo
```

Use [verify.ps1](../scripts/verify.ps1) for the read-only status walk.

## Stage G — Open local-only UIs

```powershell
kubectl port-forward --address 127.0.0.1 -n monitoring svc/monitoring-grafana 3001:80
kubectl port-forward --address 127.0.0.1 -n monitoring svc/monitoring-kube-prometheus-prometheus 9091:9090
```

These commands run in separate terminal sessions. Grafana is at `http://localhost:3001` and Prometheus at `http://localhost:9091` **only while those tunnels remain open**. Never publish the admin password or use untrusted public endpoints.

## Stage H — Measure and inspect

- Grafana: `Kubernetes / Compute Resources / Pod` → namespace `gitops-demo` → `gitops-flask-...`.
- Prometheus: `Status > Target health` → inspect UP/DOWN.
- Prometheus Query: `up == 0` → interpret empty result narrowly.
- Prometheus Alerts: inspect loaded/inactive/firing rules.

See [verification](05-verification-and-promql.md) and [alerting status](06-alerting-status.md).
