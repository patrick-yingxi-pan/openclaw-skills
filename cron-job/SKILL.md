---
name: cron-job
description: "Manage OpenClaw Gateway cron jobs - create, list, edit, run, and remove scheduled tasks with main session or isolated execution, delivery options, and retry policies."
license: Apache-2.0
compatibility: "OpenClaw Gateway 2026.2.27+"
metadata:
  author: OpenClaw
  version: "1.0"
  category: automation
---

# OpenClaw Cron Job Skill

Manage OpenClaw Gateway cron jobs - create, list, edit, run, and remove scheduled tasks.

## Quick Start

### Create a One-Shot Reminder
```bash
openclaw cron add \
  --name "Reminder" \
  --at "2026-03-05T16:00:00Z" \
  --session main \
  --system-event "Check the cron docs" \
  --wake now \
  --delete-after-run
```

### Create a Recurring Isolated Job
```bash
openclaw cron add \
  --name "Morning brief" \
  --cron "0 7 * * *" \
  --tz "America/Los_Angeles" \
  --session isolated \
  --message "Summarize overnight updates." \
  --announce \
  --channel feishu \
  --to "user:ou_1234567890abcdef"
```

## Concepts

### Job Types
- **Main Session**: Enqueue system event, runs on next heartbeat
- **Isolated**: Dedicated agent turn in `cron:<jobId>` session

### Schedule Kinds
- `at`: One-shot timestamp (ISO 8601)
- `every`: Fixed interval (milliseconds)
- `cron`: 5-field cron expression with optional timezone

### Delivery Modes
- `announce`: Deliver to channel
- `webhook`: POST to URL
- `none`: Internal only

## CLI Usage

### List Jobs
```bash
openclaw cron list
```

### Run Job Now
```bash
openclaw cron run <job-id>
```

### View Run History
```bash
openclaw cron runs --id <job-id> --limit 50
```

### Edit Existing Job
```bash
openclaw cron edit <job-id> \
  --message "Updated prompt" \
  --model "opus" \
  --thinking low
```

### Remove Job
```bash
openclaw cron remove <job-id>
```

## Common Examples

### Hourly Status Check (Feishu)
```bash
openclaw cron add \
  --name "Caixin Mirror Status" \
  --cron "0 * * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "Check Caixin Mirror crawl progress and report status." \
  --announce \
  --channel feishu \
  --to "user:ou_1234567890abcdef"
```

### Every 30 Minutes (Exact Timing)
```bash
openclaw cron add \
  --name "Quick check" \
  --cron "*/30 * * * *" \
  --exact \
  --session isolated \
  --message "Run quick status check." \
  --announce
```

### One-Shot in 20 Minutes
```bash
openclaw cron add \
  --name "Reminder" \
  --at "20m" \
  --session main \
  --system-event "Check calendar." \
  --wake now
```

## Storage & Maintenance

- Job store: `~/.openclaw/cron/jobs.json`
- Run history: `~/.openclaw/cron/runs/<jobId>.jsonl`
- Session retention: Default 24h (configurable)

## Troubleshooting

- Check cron enabled: `cron.enabled` and `OPENCLAW_SKIP_CRON`
- Verify Gateway is running continuously
- For cron schedules: Confirm timezone vs host timezone
- Recurring jobs have exponential backoff after failures: 30s → 1m → 5m → 15m → 60m

## References

- [Official Cron Docs](https://docs.openclaw.ai/automation/cron-jobs)
- [Cron vs Heartbeat](https://docs.openclaw.ai/automation/cron-vs-heartbeat)
- [Troubleshooting](https://docs.openclaw.ai/automation/troubleshooting)
