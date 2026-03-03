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
#   --dry-run             Show what would be done without making changes
#   --json                Output in JSON format
#   --uninstall           Remove the service and timer
#   --help, -h            Show this help message
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
DRY_RUN=false
JSON_OUTPUT=false
UNINSTALL=false

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# JSON output function
output_json() {
    local status="$1"
    local message="$2"
    local data="${3:-}"
    
    local json="{\"status\":\"${status}\",\"message\":\"${message}\""
    if [ -n "$data" ]; then
        json="${json},\"data\":${data}"
    fi
    json="${json}}"
    
    echo "$json"
}

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
  --dry-run             Show what would be done without making changes
  --json                Output in JSON format
  --uninstall           Remove the service and timer
  -h, --help            Show this help message

Examples:
  # Daily at 2 AM
  $(basename "$0") --name my-task --script /path/to/script.js

  # Every hour
  $(basename "$0") --name my-task --script /path/to/script.js --schedule "*:00"

  # Every Monday at 3 AM, no random delay
  $(basename "$0") --name my-task --script /path/to/script.js --schedule "Mon 03:00" --random-delay 0

  # Dry run (show what would be done)
  $(basename "$0") --name my-task --script /path/to/script.js --dry-run

  # Uninstall
  $(basename "$0") --name my-task --uninstall
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
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            if [ "$JSON_OUTPUT" = true ]; then
                output_json "error" "Unknown option: $1"
            else
                echo -e "${RED}Error: Unknown option: $1${NC}"
                show_help
            fi
            exit 1
            ;;
    esac
done

# Uninstall mode
if [ "$UNINSTALL" = true ]; then
    if [ -z "$NAME" ]; then
        if [ "$JSON_OUTPUT" = true ]; then
            output_json "error" "--name is required for uninstall"
        else
            echo -e "${RED}Error: --name is required for uninstall${NC}"
            show_help
        fi
        exit 1
    fi

    SERVICE_PATH="/etc/systemd/system/$NAME.service"
    TIMER_PATH="/etc/systemd/system/$NAME.timer"

    if [ "$JSON_OUTPUT" = true ]; then
        output_json "info" "Uninstalling $NAME" "{\"service\":\"$SERVICE_PATH\",\"timer\":\"$TIMER_PATH\"}"
    else
        echo -e "${YELLOW}========================================${NC}"
        echo -e "${YELLOW}Uninstalling: $NAME${NC}"
        echo -e "${YELLOW}========================================${NC}"
        echo
        echo "Service: $SERVICE_PATH"
        echo "Timer:   $TIMER_PATH"
        echo
    fi

    # Ask for confirmation
    if [ "$DRY_RUN" = false ]; then
        if [ "$JSON_OUTPUT" = false ]; then
            read -p "Continue? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                if [ "$JSON_OUTPUT" = true ]; then
                    output_json "cancelled" "Uninstall cancelled by user"
                else
                    echo "Aborted."
                fi
                exit 0
            fi
        fi
    fi

    if [ "$DRY_RUN" = true ]; then
        if [ "$JSON_OUTPUT" = true ]; then
            output_json "dry-run" "Would uninstall" "{\"service\":\"$SERVICE_PATH\",\"timer\":\"$TIMER_PATH\"}"
        else
            echo -e "${BLUE}[DRY-RUN] Would stop and disable timer${NC}"
            echo -e "${BLUE}[DRY-RUN] Would remove service file: $SERVICE_PATH${NC}"
            echo -e "${BLUE}[DRY-RUN] Would remove timer file: $TIMER_PATH${NC}"
            echo -e "${BLUE}[DRY-RUN] Would reload systemd${NC}"
        fi
        exit 0
    fi

    # Stop and disable timer
    if [ "$JSON_OUTPUT" = false ]; then
        echo -e "${YELLOW}Stopping and disabling timer...${NC}"
    fi
    sudo systemctl stop "$NAME.timer" 2>/dev/null || true
    sudo systemctl disable "$NAME.timer" 2>/dev/null || true

    # Remove files
    if [ "$JSON_OUTPUT" = false ]; then
        echo -e "${YELLOW}Removing service and timer files...${NC}"
    fi
    sudo rm -f "$SERVICE_PATH" "$TIMER_PATH"

    # Reload systemd
    if [ "$JSON_OUTPUT" = false ]; then
        echo -e "${YELLOW}Reloading systemd...${NC}"
    fi
    sudo systemctl daemon-reload

    if [ "$JSON_OUTPUT" = true ]; then
        output_json "success" "Uninstalled successfully" "{\"name\":\"$NAME\"}"
    else
        echo
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Uninstall complete!${NC}"
        echo -e "${GREEN}========================================${NC}"
    fi

    exit 0
fi

# Validate required arguments for install mode
if [ -z "$NAME" ]; then
    if [ "$JSON_OUTPUT" = true ]; then
        output_json "error" "--name is required"
    else
        echo -e "${RED}Error: --name is required${NC}"
        show_help
    fi
    exit 1
fi

if [ -z "$SCRIPT" ]; then
    if [ "$JSON_OUTPUT" = true ]; then
        output_json "error" "--script is required"
    else
        echo -e "${RED}Error: --script is required${NC}"
        show_help
    fi
    exit 1
fi

# Check if script exists
if [ ! -f "$SCRIPT" ]; then
    if [ "$JSON_OUTPUT" = true ]; then
        output_json "error" "Script not found: $SCRIPT"
    else
        echo -e "${RED}Error: Script not found: $SCRIPT${NC}"
    fi
    exit 1
fi

# Make script absolute path
SCRIPT="$(realpath "$SCRIPT")"

# Set working directory if not provided
if [ -z "$WORKDIR" ]; then
    WORKDIR="$(dirname "$SCRIPT")"
fi

# Service and timer paths
SERVICE_PATH="/etc/systemd/system/$NAME.service"
TIMER_PATH="/etc/systemd/system/$NAME.timer"

# Show info
if [ "$JSON_OUTPUT" = true ]; then
    output_json "info" "Setting up timer" "{\"name\":\"$NAME\",\"script\":\"$SCRIPT\",\"schedule\":\"$SCHEDULE\",\"user\":\"$USER\",\"workdir\":\"$WORKDIR\",\"persistent\":$PERSISTENT,\"random_delay\":$RANDOM_DELAY,\"service\":\"$SERVICE_PATH\",\"timer\":\"$TIMER_PATH\"}"
else
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
fi

# Ask for confirmation
if [ "$DRY_RUN" = false ]; then
    if [ "$JSON_OUTPUT" = false ]; then
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            if [ "$JSON_OUTPUT" = true ]; then
                output_json "cancelled" "Setup cancelled by user"
            else
                echo "Aborted."
            fi
            exit 0
        fi
    fi
fi

# Dry run mode
if [ "$DRY_RUN" = true ]; then
    if [ "$JSON_OUTPUT" = true ]; then
        output_json "dry-run" "Would set up timer" "{\"name\":\"$NAME\",\"service\":\"$SERVICE_PATH\",\"timer\":\"$TIMER_PATH\"}"
    else
        echo -e "${BLUE}[DRY-RUN] Would create service file: $SERVICE_PATH${NC}"
        echo -e "${BLUE}[DRY-RUN] Would create timer file: $TIMER_PATH${NC}"
        echo -e "${BLUE}[DRY-RUN] Would reload systemd${NC}"
        echo -e "${BLUE}[DRY-RUN] Would enable and start timer${NC}"
    fi
    exit 0
fi

# Create service file
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${YELLOW}Creating service file...${NC}"
fi
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
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${GREEN}✓ Service file created: $SERVICE_PATH${NC}"
fi

# Create timer file
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${YELLOW}Creating timer file...${NC}"
fi
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
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${GREEN}✓ Timer file created: $TIMER_PATH${NC}"
fi

# Reload systemd
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${YELLOW}Reloading systemd...${NC}"
fi
sudo systemctl daemon-reload
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${GREEN}✓ Systemd reloaded${NC}"
fi

# Enable and start timer
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${YELLOW}Enabling and starting timer...${NC}"
fi
sudo systemctl enable "$NAME.timer"
sudo systemctl start "$NAME.timer"
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${GREEN}✓ Timer enabled and started${NC}"
fi

if [ "$JSON_OUTPUT" = true ]; then
    output_json "success" "Setup complete" "{\"name\":\"$NAME\",\"service\":\"$SERVICE_PATH\",\"timer\":\"$TIMER_PATH\"}"
else
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
    echo "  # Uninstall completely"
    echo "  $(basename "$0") --name $NAME --uninstall"
    echo
fi
