# 05 — Verification, dashboards and PromQL

## Read-only cluster checks

```powershell
helm list -n monitoring
kubectl get pods -n monitoring
kubectl get pvc -n monitoring
kubectl get deployment,pods -n gitops-demo
kubectl get prometheusrules -n monitoring
```

Expected at recorded time: deployed Helm release, seven Running monitoring pods and three Bound PVCs totalling 17 GiB. Current output can differ; investigate instead of overwriting.

## Prometheus target health

Visit `http://localhost:9091/targets` while the authorized loopback tunnel is active.

Targets captured `UP` included:
- Grafana and Alertmanager scrape endpoints.
- Kubernetes API server and CoreDNS endpoints.
- Kubelet/cAdvisor/probes on the two nodes.
- Node exporter and kube-state-metrics.

Do not infer that every possible metric endpoint was discovered just because visible scrape targets are UP.

## Query 1 — Down targets

```promql
up == 0
```

It returned an empty instant-vector in the supplied screenshot. This says **none of the currently discovered series had value zero at the evaluation instant**. Missing/unconfigured scrape jobs and future outages are not ruled out.

## Query 2 — Ready nodes

```promql
sum(kube_node_status_condition{condition="Ready",status="true"} == 1)
```

Only interpret the result if `kube-state-metrics` is present and scraping.

## Query 3 — Flask CPU

```promql
sum by (pod) (rate(container_cpu_usage_seconds_total{namespace="gitops-demo",pod=~"gitops-flask-.*",container!="",container!="POD"}[5m]))
```

## Query 4 — Flask memory

```promql
sum by (pod) (container_memory_working_set_bytes{namespace="gitops-demo",pod=~"gitops-flask-.*",container!="",container!="POD"})
```

## Query 5 — Available deployment replicas

```promql
kube_deployment_status_replicas_available{namespace="gitops-demo",deployment="gitops-flask"}
```

More queries: [cluster-health.promql](../queries/cluster-health.promql) and [gitops-flask.promql](../queries/gitops-flask.promql).

## Grafana

Select `Kubernetes / Compute Resources / Pod` then:
- `namespace=gitops-demo`
- `pod=gitops-flask-...`

Screenshots recorded ~0.000457 CPU cores, ~59.3 MiB memory, ~1.69 kb/s inbound and ~1.22 kb/s outbound traffic. They are not SLIs measured over a representative workload window.

## Alert rules

The `/alerts` page showed `alertmanager.rules` with displayed entries `INACTIVE`, which is typical when the condition does not hold. This alone does not verify delivery channels.

See [alerting limitations](06-alerting-status.md).
