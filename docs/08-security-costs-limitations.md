# 08 — Security, costs and honest limitations

## IAM and Kubernetes permissions

The IAM principal `user/kubernetes` originally had namespace-scoped EKS edit access to `gitops-demo` and `argocd`. A later privileged policy association enabled cluster-wide CRD creation. This privilege is broader than necessary for day-to-day viewing.

**Post-install security task:** inventory policy associations, identify the exact temporary cluster-admin grant and revoke only that grant when no longer needed. Do not alter the AWS account root access entry, EKS node role, service-linked roles or legitimate namespace access.

Do not commit AWS account IDs, role ARNs, kubeconfig contents or credentials except when there is a documented, deliberate reason. CloudWatch browser screenshots in this repo mask the account-menu identity; private node IPs shown in certain Prometheus target screenshots are historical lab metadata, not credentials.

## Kubernetes and network exposure

- Grafana and Prometheus services use `ClusterIP`.
- `kubectl port-forward --address 127.0.0.1` makes local-only tunnels. It is **not** remote access when the PC is off.
- The project intentionally skipped publicly exposed HTTPS ingress, authentication proxy, custom domain and network load balancer setup.
- Do not change services to publicly open NodePort or LoadBalancer without an approved ingress/security architecture.
- Alertmanager receiver secrets were not configured or tested.

## Persistent data lifecycle

The `gp3-monitoring` StorageClass has `reclaimPolicy: Delete`. A PVC/PV deletion can trigger deletion of the AWS EBS volume and permanently lose the monitoring data. Treat this as **destructive**; do not run cleanup recipes on valuable data without backups and change authorization.

This project documented:
- Prometheus: 10 GiB
- Grafana: 5 GiB
- Alertmanager: 2 GiB
- Total: 17 GiB provisioned EBS GP3

Bound storage is **not** proof of backup or multi-AZ durability.

## AWS billing

Resource classes that can incur charges:
1. EKS control plane.
2. Two On-Demand EC2 `c7i-flex.large` workers.
3. EBS GP3 capacity and potentially volume snapshots.
4. CloudWatch metrics, ingestion and logs.
5. Network/data transfer and optional DNS integrations.

At capture, Container Insights log groups had `RetentionDays: None`. That can allow logs to remain indefinitely with accumulating cost. Changing retention is a destructive historical-data decision; obtain approval and a backup/retention requirement first.

## Current project limitations

| Area | Status |
| --- | --- |
| EKS and GitOps workload health at capture | Verified |
| AWS CloudWatch CPU/memory logs/metrics | Observed |
| Grafana workload metrics | Verified |
| Prometheus targets and query | Verified at capture |
| Prometheus built-in rules | Loaded |
| Outbound Alertmanager notifications | Not tested |
| HTTPS / PC-independent Grafana access | Skipped |
| Full Terraform/IaC EKS provisioning | Not included |
| Prometheus/Alertmanager HA | Single replica each |
| Backup/restore and disaster recovery | Not tested |
| Long-duration load/reliability benchmark | Not performed |

This is a well-verified learning/portfolio deployment, **not a production readiness certification**.

References: [AWS EKS EBS CSI](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html), [GitHub secret leakage risks](https://docs.github.com/en/code-security/concepts/secret-security/secret-leakage-risks).
