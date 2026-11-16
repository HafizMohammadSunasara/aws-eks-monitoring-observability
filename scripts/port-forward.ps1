#Requires -Version 5.1
<#
.SYNOPSIS
Local-only access to the EKS-hosted monitoring UIs.
.DESCRIPTION
The UI tunnel stops when this PowerShell session ends. This is NOT a permanent
cloud-access URL and does not expose a public HTTPS endpoint.
#>
param(
    [ValidateSet("grafana", "prometheus", "alertmanager")]
    [string]$Service = "grafana"
)

$ErrorActionPreference = "Stop"
$services = @{
    "grafana" = @{ Name = "monitoring-grafana"; Local = 3001; Remote = 80 }
    "prometheus" = @{ Name = "monitoring-kube-prometheus-prometheus"; Local = 9091; Remote = 9090 }
    "alertmanager" = @{ Name = "monitoring-kube-prometheus-alertmanager"; Local = 9094; Remote = 9093 }
}

$selected = $services[$Service]
$forward = "{0}:{1}" -f $selected.Local, $selected.Remote
Write-Host ("Open http://localhost:{0} after the connection starts." -f $selected.Local)
kubectl port-forward --address 127.0.0.1 -n monitoring ("svc/{0}" -f $selected.Name) $forward
