#!/bin/bash

# Create an hourly cron job for Feishu notifications
# Usage: ./create-hourly-notification.sh <feishu-user-id> "<message>"

FEISHU_USER_ID="${1:-user:ou_1234567890abcdef}"
MESSAGE="${2:-Check project status and report.}"
JOB_NAME="${3:-Hourly Status Check}"

echo "Creating hourly cron job..."
echo "  User ID: $FEISHU_USER_ID"
echo "  Message: $MESSAGE"
echo "  Job Name: $JOB_NAME"
echo ""

openclaw cron add \
  --name "$JOB_NAME" \
  --cron "0 * * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "$MESSAGE" \
  --announce \
  --channel feishu \
  --to "$FEISHU_USER_ID"

echo ""
echo "✓ Cron job created successfully!"
echo "  It will run every hour on the hour (Shanghai time)."
