# 02 — Prerequisites and safe access

This is a **reference runbook** for an operator with authorization on their own AWS account. Do not apply write commands to a shared/production cluster without change approval.

## Tools at the recorded lab

- Windows PowerShell 5.1.
- `kubectl` with a valid EKS kubeconfig and Kubernetes API access.
- AWS CLI configured for `us-east-1`.
- Helm 4.3.1 reported locally in the lab.
- Existing Amazon EKS cluster on Kubernetes 1.37.
- Working worker-node scheduling, DNS, networking and IAM permissions.

## Prerequisite checks (read-only)

```powershell
aws sts get-caller-identity
aws eks describe-cluster --region us-east-1 --name gitops-eks-cluster --query "cluster.{Status:status,Version:version}"
kubectl config current-context
kubectl get nodes -o wide
kubectl get ns
helm version --short
helm list -A
kubectl get csidrivers
kubectl get storageclass -o wide
```

Ensure your kubeconfig is pointing to the intended cluster **before** any `kubectl apply` or `helm install`.

## Access and least privilege

The user initially had EKS edit access scoped to `gitops-demo` and `argocd`. That did **not** permit installing cluster-scoped CRDs used by Prometheus Operator:

```powershell
kubectl auth can-i create customresourcedefinitions.apiextensions.k8s.io
```

The observed answer changed from `no` to `yes` after an authorized access-policy association. **Do not assume all users need permanent cluster-admin.** Grant only the required privileges for the installation window, then review and withdraw the **specific temporary grant**, preserving other legitimate policies.

## Pod Identity and CSI

EBS CSI requires appropriate AWS permissions, typically via EKS Pod Identity or a purpose-built role. The lab verified an associated identity for the EBS CSI add-on; the identity details, IAM role resources and trust policy are **not** recreated in this repository.

Reference: [AWS EBS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html).

## Capacity

Two small worker instances handled the observed lightweight stack. This does not prove safe headroom for arbitrary production loads. Check CPU, memory, requests, disk, scheduling, and EBS limits before deploying.

## Secret handling

Never commit `~/.aws`, kubeconfig, IAM keys, Helm values containing admin passwords, exported Kubernetes Secret YAML, tokens, or internal authentication files. Check screenshots for account identifiers and personal information before publishing.
