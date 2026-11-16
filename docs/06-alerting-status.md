# 06 — Alerting state, gaps and future validation

## Observed state

- Alertmanager pod `alertmanager-monitoring-kube-prometheus-alertmanager-0` was `2/2 Running`.
- Prometheus had built-in `PrometheusRule` resources in `monitoring`.
- The `/alerts` UI listed built-in `alertmanager.rules`; visible rules were `INACTIVE` at capture time.
- Grafana home showed no firing alerts at its captured moment.

## What this DOES NOT prove

- No tested SMTP, Slack, PagerDuty, webhook or other delivery receiver.
- No confirmed end-to-end synthetic alert was created and resolved.
- No measured alert evaluation/delivery latency.
- No pager rotation, escalation chain or runbook automation.
- No system under load or true failure was deliberately injected.

The correct chain is:

```text
PrometheusRule expression
    └── Prometheus evaluates alert
          └── Alertmanager routes/group/silences
                └── Receiver (requires separate configuration & tests)
```

## Safe future test plan (not implemented)

1. Decide on a receiver and authorize a secure secret mechanism.
2. Configure Alertmanager routing for a dedicated `severity=testing` label.
3. Create a short-lived `PrometheusRule` in a controlled test namespace, not by editing existing system rules.
4. Confirm Pending → Firing → Alertmanager received → receiver delivered → Resolved.
5. Clean up **only the test resources by exact name**, not the existing Helm release or notification data.
6. Save timestamped evidence and only then update portfolio claims.

Never share an SMTP password, webhook secret or bearer token in this repository. Do not disable TLS to make delivery work.

References: [Prometheus alerting](https://prometheus.io/docs/alerting/latest/overview/) and [Prometheus Operator design](https://prometheus-operator.dev/docs/getting-started/design/).
