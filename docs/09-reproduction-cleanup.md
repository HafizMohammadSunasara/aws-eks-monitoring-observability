# 09 — Reproduction boundaries, handoff and cleanup

## Package intent

This repository records **what worked in one lab**, including authentic evidence and reference configuration. It is not a one-command EKS installer, does not create IAM roles and is not guaranteed to match a different Kubernetes minor version.

## Read-only preflight on a target cluster

```powershell
aws sts get-caller-identity
kubectl config current-context
kubectl get nodes
helm list -A
kubectl get storageclass
kubectl get csidrivers
kubectl get ns monitoring
```

An existing `monitoring` release must be inspected, not overwritten.

## Compare the actual values

Because the original `monitoring-values.yaml` was not available as an uploaded file, the included values were reconstructed from the verified discussion. The **authoritative** live values must be exported locally by the operator:

```powershell
helm get values monitoring -n monitoring -o yaml
```

Treat differences as a review task. Do not publish embedded passwords or secret material found in exports.

## Reference deployment order for a separate authorized environment

1. Provision and validate EKS nodes, networking and IAM **outside** this repository.
2. Install and authorize EBS CSI, and verify the CSI driver.
3. Review then apply the GP3 StorageClass manifest on a **new** intended target.
4. Verify EBS dynamic provisioning in a separate disposable namespace.
5. Review Helm values, resource requirements and cluster version compatibility.
6. Deploy the pinned chart version 93.3.0 to a clean namespace.
7. Verify pods, PVCs, ServiceMonitors and Pod/Service target health.
8. Validate actual workload metrics and alert evaluation.
9. Configure receivers and remote access only if requirements explicitly include them.

## Safe handoff checks

```powershell
.\scripts\verify.ps1
.\scripts\collect-evidence.ps1
.\scripts\port-forward.ps1 -Service grafana
```

The first script is read-only; the second writes **local-only evidence files** to a gitignored directory. The third opens a loopback port-forward (no cluster mutations). Review commands and context before running them.

## Cleanup is intentionally NOT automated

Deleting any of these can destroy data or affect unrelated workloads:
- `helm uninstall monitoring -n monitoring`
- Deleting `monitoring` namespace.
- Deleting `gp3-monitoring` PVCs/PVs or their backing EBS volumes.
- Changing/deleting cluster access entries.
- Removing EKS managed add-ons.
- Deleting worker nodes or the EKS cluster.

No cleanup script is shipped. The earlier disposable `gp3-smoke-test` pod/PVC were already deleted by the operator; that is different from deleting the real 17 GiB monitoring storage.

## Verify public portfolio quality

- Check all Markdown links and six SVG/PNG pairs.
- Check the 13 source screenshots without fake recreated data.
- Run static YAML/JSON validation; do not confuse linting with AWS deployment success.
- Search for passwords, keys, tokens, kubeconfigs and account identifiers.
- Review license, author name, and claims before pushing to a **new** repository.
