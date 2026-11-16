#Requires -Version 5.1
<#
.SYNOPSIS
Collects read-only diagnostics for private local review.
.NOTES
Output may contain cluster names, internal IP addresses and AWS identifiers.
Review and redact before any public commit. Directory is gitignored.
#>
param(
    [string]$OutputDirectory = "local-evidence",
    [string]$ClusterName = "gitops-eks-cluster",
    [string]$Region = "us-east-1"
)

$ErrorActionPreference = "Stop"
New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null

$checks = [ordered]@{
    "nodes.txt" = { kubectl get nodes -o wide }
    "monitoring-pods.txt" = { kubectl get pods -n monitoring -o wide }
    "monitoring-pvcs.txt" = { kubectl get pvc -n monitoring }
    "monitoring-storageclass.txt" = { kubectl get storageclass gp3-monitoring -o wide }
    "monitoring-helm.txt" = { helm list -n monitoring }
    "gitops-flask.txt" = { kubectl get pods,deployments -n gitops-demo }
    "prometheus-rules.txt" = { kubectl get prometheusrules -n monitoring }
}
foreach ($item in $checks.GetEnumerator()) {
    $path = Join-Path $OutputDirectory $item.Key
    & $item.Value 2>&1 | Out-File -FilePath $path -Encoding UTF8
    if ($LASTEXITCODE -ne 0) {
        throw "Evidence command for $($item.Key) failed (exit $LASTEXITCODE); inspect $path."
    }
    Write-Host "Wrote $path"
}

$path = Join-Path $OutputDirectory "eks-addon-status.json"
aws eks list-addons --region $Region --cluster-name $ClusterName --output json | Out-File -FilePath $path -Encoding UTF8
if ($LASTEXITCODE -ne 0) {
    throw "AWS add-on listing failed (exit $LASTEXITCODE); inspect $path."
}
Write-Host "Wrote $path"
Write-Warning "DO NOT commit local-evidence until identifiers and confidential information are reviewed."
