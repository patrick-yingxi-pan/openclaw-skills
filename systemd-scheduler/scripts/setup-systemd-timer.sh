#!/bin/bash
#
# Systemd Timer Setup Script
#
# Usage:
#   ./setup-systemd-timer.sh --name my-task --script /path/to/script.js --schedule "02:00"
#
# Options:
#   --name NAME           Name of the service/timer (required)
#   --script PATH         Path to the script to run (required)
#   --schedule CRON       OnCalendar schedule (default: daily at 2 AM)
#   --user USER           User to run as (default: current user)
#   --workdir PATH        Working directory (default: script directory)
#   --persistent true/false  Catch up missed tasks (default: true)
#   --random-delay SECS   Random delay in seconds (default: 300)
#

set -euo pipefail

# Default values
NAME=""
SCRIPT=""
SCHEDULE="02:00"
USER="$(whoami)"
WORKDIR=""
PERSISTENT="true"
RANDOM_DELAY="300"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") --name NAME --script PATH [OPTIONS]

Set up a systemd timer for a script.

Required:
  --name NAME           Name of the service/timer
  --script PATH         Path to the script to run

Options:
  --schedule CRON       OnCalendar schedule (default: $SCHEDULE)
  --user USER           User to run as (default: $USER)
  --workdir PATH        Working directory (default: script directory)
  --persistent true/false  Catch up missed tasks (default: $PERSISTENT)
  --random-delay SECS   Random delay in seconds (default: $RANDOM_DELAY)
  -h, --help            Show this help message

Examples:
  # Daily at 2 AM
  $(basename "$0") --name my-task --script /path/to/script.js

  # Every hour
  $(basename "$0") --name my-task --script /path/to/script.js --schedule "*:00"

  # Every Monday at 3 AM, no random delay
  $(basename "$0") --name my-task --script /path/to/script.js --schedule "Mon 03:00" --random-delay 0
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            NAME="$2"
            shift 2
            ;;
        --script)
            SCRIPT="$2"
            shift 2
            ;;
        --schedule)
            SCHEDULE="$2"
            shift 2
            ;;
        --user)
            USER="$2"
            shift 2
            ;;
        --workdir)
            WORKDIR="$2"
            shift 2
            ;;
        --persistent)
            PERSISTENT="$2"
            shift 2
            ;;
        --random-delay)
            RANDOM_DELAY="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$NAME" ]]; then
    echo -e "${RED}Error: --name is required${NC}"
    show_help
    exit 1
fi

if [[ -z "$SCRIPT" ]]; then
    echo -e "${RED}Error: --script is required${NC}"
    show_help
    exit 1
fi

# Check if script exists
if [[ ! -f "$SCRIPT" ]]; then
    echo -e "${RED}Error: Script not found: $SCRIPT${NC}"
    exit 1
fi

# Make script absolute path
SCRIPT="$(realpath "$SCRIPT")"

# Set working directory if not provided
if [[ -z "$WORKDIR" ]]; then
    WORKDIR="$(dirname "$SCRIPT")"
fi

# Service and timer paths
SERVICE_PATH="/etc/systemd/system/$NAME.service"
TIMER_PATH="/etc/systemd/system/$NAME.timer"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Systemd Timer Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo
echo "Name:           $NAME"
echo "Script:         $SCRIPT"
echo "Schedule:       $SCHEDULE"
echo "User:           $USER"
echo "Working dir:    $WORKDIR"
echo "Persistent:     $PERSISTENT"
echo "Random delay:   $RANDOM_DELAY seconds"
echo
echo "Service:        $SERVICE_PATH"
echo "Timer:          $TIMER_PATH"
echo

# Ask for confirmation
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Create service file
echo -e "${YELLOW}Creating service file...${NC}"
sudo tee "$SERVICE_PATH" > /dev/null << EOF
[Unit]
Description=$NAME Scheduled Task
After=network.target

[Service]
Type=oneshot
User=$USER
WorkingDirectory=$WORKDIR
ExecStart=$SCRIPT
StandardOutput=journal
StandardError=journal

# Security sandboxing
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=$WORKDIR
EOF
echo -e "${GREEN}✓ Service file created: $SERVICE_PATH${NC}"

# Create timer file
echo -e "${YELLOW}Creating timer file...${NC}"
sudo tee "$TIMER_PATH" > /dev/null << EOF
[Unit]
Description=$NAME Timer

[Timer]
OnCalendar=$SCHEDULE
Persistent=$PERSISTENT
RandomizedDelaySec=$RANDOM_DELAY

[Install]
WantedBy=timers.target
EOF
echo -e "${GREEN}✓ Timer file created: $TIMER_PATH${NC}"

# Reload systemd
echo -e "${YELLOW}Reloading systemd...${NC}"
sudo systemctl daemon-reload
echo -e "${GREEN}✓ Systemd reloaded${NC}"

# Enable and start timer
echo -e "${YELLOW}Enabling and starting timer...${NC}"
sudo systemctl enable "$NAME.timer"
sudo systemctl start "$NAME.timer"
echo -e "${GREEN}✓ Timer enabled and started${NC}"

echo
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo
echo "Useful commands:"
echo
echo "  # List timers"
echo "  sudo systemctl list-timers $NAME.timer"
echo
echo "  # Check timer status"
echo "  sudo systemctl status $NAME.timer"
echo
echo "  # View service logs"
echo "  journalctl -u $NAME.service -f"
echo
echo "  # Run once manually"
echo "  sudo systemctl start $NAME.service"
echo
echo "  # Stop and disable"
echo "  sudo systemctl stop $NAME.timer"
echo "  sudo systemctl disable $NAME.timer"
echo
