# Monitoring and alerting

Each cloud offers a built-in service for metrics, logs, and alerts on
your resources. These examples watch CPU usage on the instance from
the `compute` category and notify an email address when it's high.

## Concepts and naming

| Concept                | AWS                          | GCP                              | Azure                          |
|---------------------------|--------------------------------|------------------------------------|------------------------------------|
| Service name                | CloudWatch                     | Cloud Monitoring / Cloud Logging   | Azure Monitor                      |
| Log storage                  | Log group                      | Log bucket (via Cloud Logging)     | Log Analytics workspace            |
| A rule that watches a metric  | Metric alarm                   | Alert policy                       | Metric alert                       |
| Where notifications go         | SNS topic (subscribed to the alarm) | Notification channel          | Action group                       |

## Design defaults used in this repo

- **Alerts go to an email address**, the simplest notification target
  every cloud supports directly, no chat or pager integration assumed.
- **The alarm watches an existing resource** (the compute instance),
  not a hypothetical one, so this category demonstrates wiring
  monitoring onto real infrastructure rather than as a standalone
  example.
- **Log retention is set explicitly**, not left at each cloud's
  default, since default retention varies and unlimited retention on
  a personal account can get expensive quietly.

## What differs enough to matter

- **AWS separates the alarm from the notification.** A CloudWatch
  alarm doesn't send anything anywhere on its own; it triggers an SNS
  topic, which has its own subscribers. GCP and Azure both bundle
  "who gets notified" more directly into the alert policy or metric
  alert resource via a notification channel / action group reference.
- **GCP's alerting is metric-query based** (a filter string against
  its metrics namespace) rather than picking a named metric off a
  dropdown, which is more like how AWS and Azure select metrics.
- **Azure's Log Analytics workspace is a separate resource** that
  logs get routed into; AWS's log group and GCP's log bucket are both
  closer to being the log storage itself, with fewer extra pieces.

## Files in this category

- `aws/monitoring/main.tf` — log group, SNS topic with an email subscription, a CPU alarm on the compute instance
- `gcp/monitoring/main.tf` — email notification channel, an alert policy watching instance CPU utilization
- `azure/monitoring/main.tf` — Log Analytics workspace, an action group with an email receiver, a metric alert on the VM

Each file expects an instance/VM ID from the `compute` category's
outputs.
