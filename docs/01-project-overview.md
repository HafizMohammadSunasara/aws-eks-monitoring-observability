# 01 — Project overview

## Objective

Extend an already functioning Amazon EKS GitOps lab with a separately managed monitoring stack and demonstrate **measurable runtime observability**, not merely Kubernetes pod readiness.

## Existing components

- AWS EKS `gitops-eks-cluster`, Kubernetes 1.37, us-east-1.
- One managed worker nodegroup, `gitops-eks-workers-1`, two c7i-flex.large On-Demand nodes.
- Existing `gitops-demo` Flask Deployment with two available replicas.
- Argo CD controllers in `argocd`. They are **not** installed or reconfigured by this portfolio.
- CloudWatch Observability managed EKS add-on plus independent Helm monitoring stack.

## What we built

1. Activated AWS-native Container Insights with CloudWatch Agent and Fluent Bit.
2. Kept blanket Application Signals auto-monitoring off to avoid surprising GitOps instrumentation.
3. Installed EBS CSI as a managed add-on with EKS Pod Identity.
4. Created encrypted `gp3-monitoring` StorageClass and proved dynamic provisioning with a disposable PVC/pod.
5. Installed pinned `kube-prometheus-stack` 93.3.0 through Helm.
6. Verified monitoring pods and three GP3 PVCs.
7. Opened EKS-hosted Grafana via loopback port-forward and inspected GitOps Flask metrics.
8. Confirmed selected Prometheus scrape targets `UP`, no `up==0` results at one instant, and alert rules loaded.

## What it proves

- Ability to integrate cloud-native telemetry with Kubernetes exporters.
- Correct distinction between AWS Container Insights and the Prometheus metrics path.
- Understanding of CSI drivers, IAM Pod Identity, storage lifecycle and resource requests.
- Evidence-led verification via Helm, kubectl, Grafana and Prometheus.
- Willingness to report untested areas honestly.

## Not claimed

- No sustained availability/SLO benchmark.
- No synthetic notification has reached email, Slack or webhook.
- No publicly accessible HTTPS Grafana endpoint.
- No fully automated EKS creation or production disaster recovery.
- No guarantee that all targets remain `UP` after the capture time.

See [the deep dive](../DEEP-DIVE.md) and [evidence](../EVIDENCE-INDEX.md).
