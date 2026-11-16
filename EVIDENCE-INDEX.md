# Evidence index — authentic screenshots

All 13 images were taken from the supplied 16 November 2026 lab screenshots. They are evidence of a **particular observation time**, not a claim that the state is still live.

The two CloudWatch browser screenshots have the AWS account-menu identity covered by a small dark privacy box. **Charts, numeric results and workload identifiers have not been edited.** All other included screenshots were copied from the supplied capture files.

| # | File | What the screenshot actually demonstrates |
| --- | --- | --- |
| 01 | [EKS version](evidence/01-eks-cluster-version.png) | CLI reports cluster version 1.37 and existing add-on names |
| 02 | [CloudWatch Active](evidence/02-cloudwatch-addon-active.png) | Amazon CloudWatch Observability add-on Active, version visible |
| 03 | [Container Insights overview](evidence/03-cloudwatch-cluster-overview.png) | 1 EKS cluster, 2 available nodes, 27/27 pods at the recorded snapshot |
| 04 | [CloudWatch node graphs](evidence/04-cloudwatch-node-graphs.png) | CPU and memory utilization time series for both worker nodes |
| 05 | [CloudWatch pod CPU](evidence/05-grafana-cloudwatch-pod-cpu.png) | Grafana charts for an amazon-cloudwatch pod, proving metrics visualization |
| 06 | [CloudWatch pod memory](evidence/06-grafana-cloudwatch-pod-memory.png) | Grafana memory usage and requests for the selected system pod |
| 07 | [GitOps Flask CPU](evidence/07-grafana-gitops-cpu.png) | Existing Flask container CPU rate, resource requests/limits, throttling |
| 08 | [GitOps Flask memory](evidence/08-grafana-gitops-memory.png) | ~59.3 MiB observed usage vs 64 MiB request / 256 MiB limit |
| 09 | [GitOps Flask network](evidence/09-grafana-gitops-network.png) | Real inbound/outbound network data for Flask pod |
| 10 | [Prometheus: Grafana/Alertmanager](evidence/10-prometheus-grafana-alertmanager-targets.png) | Selected Grafana and Alertmanager scrape endpoints show UP |
| 11 | [Prometheus: kubelet](evidence/11-prometheus-kubelet-targets.png) | Selected kubelet cAdvisor/probe scrape targets show UP |
| 12 | [Prometheus: zero DOWN targets](evidence/12-prometheus-zero-down-query.png) | `up == 0` instant query returned an empty vector at capture time |
| 13 | [Prometheus alert rules](evidence/13-prometheus-alert-rules.png) | Built-in Alertmanager rules loaded; displayed rules inactive |

## What is not pictured

The user also supplied **terminal text output** confirming:

- `helm list -n monitoring`: release `monitoring` deployed, chart `93.3.0`.
- `kubectl get pods -n monitoring`: seven Running monitoring pods.
- `kubectl get pvc -n monitoring`: three Bound GP3 claims (10/5/2 GiB).
- EBS CSI add-on Active / no issues, with running controller and node pods.
- A temporary 1 GiB EBS smoke-test PVC Bound and pod output `EBS_MOUNT_OK`; both disposable resources were then deleted.

These were captured in chat as text, **not as standalone source screenshots**. They are quoted with provenance in [DEEP-DIVE.md](DEEP-DIVE.md), not redrawn as counterfeit terminal images.

## Integrity rules

1. Never recreate a screenshot in a graphics editor and call it proof.
2. Never replace actual metric values with visually attractive numbers.
3. Graphic illustrations in `graphics/` are **designs**, not evidence.
4. Treat every status as historical; re-run read-only verification for the live state.
5. Do not commit secrets, kubeconfigs, access keys or raw admin passwords.
