# 07 — Real troubleshooting and operational lessons

These are **observed lab issues/decisions**, not invented incidents.

| Symptom/observation | Explanation | Action taken / outcome |
| --- | --- | --- |
| `kubectl auth can-i create customresourcedefinitions.apiextensions.k8s.io` → `no` | Existing namespace-scoped EKS edit access cannot create cluster-scoped CRDs | Authorized EKS access change; later returned `yes` |
| `kubectl get csidrivers` showed only EFS CSI | There was no installed standard EBS CSI driver to provision new GP3 EBS PVCs | Installed EKS managed `aws-ebs-csi-driver` with Pod Identity; Active |
| Legacy `gp2` provisioner present | In-tree StorageClass differs from EBS CSI `ebs.csi.aws.com` | Created separate non-default `gp3-monitoring` |
| Concern about storage persistence | Claim binding alone does not test mount | Disposable test pod logged `EBS_MOUNT_OK`, then test pod/PVC removed |
| Grafana already on Windows `localhost:3000` | Using it would defeat goal of an EKS-hosted monitoring stack | Installed separate Grafana in EKS and forwarded locally to port `3001` |
| CloudWatch add-on could auto-monitor all services | Blanket auto-monitoring might modify service behavior | Applied `monitorAllServices: false` |
| Prometheus target health needed proof | Pods Running does not prove scrape network/path works | Inspected `/targets` and queried `up == 0` |
| Alertmanager Running but no notifications | Startup and routing/delivery are independent stages | Documented as a known gap rather than a success claim |

## Root lessons

1. Scope Kubernetes permissions to operations. Being able to read/edit a namespace is not being an EKS cluster administrator.
2. Add-ons have a controller/data plane and an AWS IAM identity. Both matter.
3. Persistent storage is not just a YAML name: dynamic provision, bind, schedule and mount should be verified.
4. Validate data at the final consumer (Grafana) and at the collection point (Prometheus).
5. Avoid adding monitoring agents that silently auto-instrument GitOps workloads without a clear change plan.
6. Read any command's target namespace and object name before destructive operations.

## Investigation command set (read-only)

```powershell
kubectl get pods -n monitoring -o wide
kubectl get events -n monitoring --sort-by=.lastTimestamp
kubectl describe pvc -n monitoring
kubectl get csidrivers
kubectl get storageclass -o wide
helm status monitoring -n monitoring
kubectl get servicemonitors,prometheusrules -n monitoring
```

Avoid posting raw logs or secrets without inspection. See [verification](05-verification-and-promql.md).
