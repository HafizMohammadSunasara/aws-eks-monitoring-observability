#Requires -Version 5.1
<#
.SYNOPSIS
Read-only status check for the documented EKS monitoring lab.
.DESCRIPTION
Does not create, change, restart or delete any cluster resources.
#>
param(
    [string]$ClusterName = "gitops-eks-cluster",
    [string]$Region = "us-east-1",
    [string]$Namespace = "monitoring"
)

$ErrorActionPreference = "Stop"

function Assert-CommandSuccess([string]$Label) {
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE. Review the output above."
    }
}

foreach ($tool in @("aws", "kubectl", "helm")) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "Required command not installed: $tool"
    }
}

Write-Host "=== AWS identity (account metadata only) ==="
aws sts get-caller-identity --query "{Account:Account,Arn:Arn}" --output table
Assert-CommandSuccess "AWS identity lookup"

Write-Host "=== Current kubeconfig context ==="
kubectl config current-context
Assert-CommandSuccess "Current context check"

Write-Host "=== EKS cluster version/status ==="
aws eks describe-cluster --region $Region --name $ClusterName --query "cluster.{Name:name,Status:status,Version:version}" --output table
Assert-CommandSuccess "EKS cluster describe"

Write-Host "=== Worker nodes ==="
kubectl get nodes -o wide
Assert-CommandSuccess "Node listing"

Write-Host "=== Helm monitoring release ==="
helm list -n $Namespace
Assert-CommandSuccess "Helm release listing"

Write-Host "=== Monitoring pods ==="
kubectl get pods -n $Namespace
Assert-CommandSuccess "Monitoring pod listing"

Write-Host "=== Monitoring persistent volume claims ==="
kubectl get pvc -n $Namespace
Assert-CommandSuccess "Monitoring PVC listing"

Write-Host "=== Existing GitOps application (read-only) ==="
kubectl get deployment,pods -n gitops-demo
Assert-CommandSuccess "GitOps workload listing"

Write-Host "=== EKS add-on status ==="
foreach ($addon in @("amazon-cloudwatch-observability", "aws-ebs-csi-driver")) {
    aws eks describe-addon --region $Region --cluster-name $ClusterName --addon-name $addon --query "addon.{Name:addonName,Status:status,Version:addonVersion,Health:health.issues}" --output json
    Assert-CommandSuccess "EKS add-on check: $addon"
}

Write-Host "Verification commands completed. Review each result; this script does not certify application-level SLIs or outbound alerts."
