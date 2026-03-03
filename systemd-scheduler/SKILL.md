---
name: systemd-scheduler
description: Set up and manage persistent, reliable task scheduling on Linux using systemd timers. Features missed-task catch-up, structured logging, dependency management, and security sandboxing. Superior to cron for production workloads.
---

# Systemd Scheduler Skill

Create and manage production-grade scheduled tasks on Linux using **systemd timers** - the modern, reliable alternative to cron.

## When to Use

- You need **persistent scheduling** (tasks catch up if the system reboots)
- You want **structured logging** with `journalctl`
- You need **dependency management** (wait for network, databases, etc.)
- You want **security sandboxing** and resource limits
- You're on a **Linux system** with systemd (most modern distributions)

## Quick Start

### 1. Create Service + Timer Pair

Create two files in `/etc/systemd/system/`:

**`my-task.service`**:
```ini
[Unit]
Description=My Scheduled Task
After=network.target

[Service]
Type=oneshot
User=your-user
WorkingDirectory=/path/to/your/project
ExecStart=/usr/bin/node /path/to/your/script.js
StandardOutput=journal
StandardError=journal

# Security sandboxing
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=/path/to/your/project
```

**`my-task.timer`**:
```ini
[Unit]
Description=My Task Timer

[Timer]
# Run daily at 2 AM
OnCalendar=02:00

# ⭐ CATCH UP MISSED TASKS ON BOOT
Persistent=true

# Add random delay (0-300 seconds) to be polite
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
```

### 2. Install and Start

```bash
# Copy to systemd directory
sudo cp my-task.service /etc/systemd/system/
sudo cp my-task.timer /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable on boot + start now
sudo systemctl enable my-task.timer
sudo systemctl start my-task.timer
```

### 3. Verify

```bash
# List active timers
sudo systemctl list-timers my-task.timer

# Check timer status
sudo systemctl status my-task.timer

# View service logs
journalctl -u my-task.service -f

# Run once manually (for testing)
sudo systemctl start my-task.service
```

## Core Concepts

### Service vs Timer

- **Service** (`.service`): What to run (the actual task)
- **Timer** (`.timer`): When to run it (the schedule)

### Why systemd timer > cron?

| Feature | systemd timer | cron |
|---------|---------------|------|
| Missed task catch-up | ✅ `Persistent=true` | ❌ Manual |
| Structured logging | ✅ journalctl | ❌ Manual files |
| Dependency management | ✅ `After=`, `Wants=` | ❌ No |
| Status monitoring | ✅ `systemctl list-timers` | ❌ No |
| Randomized delay | ✅ `RandomizedDelaySec=` | ❌ No |
| Security sandboxing | ✅ Yes | ❌ No |
| Resource limits | ✅ CPU/memory/IO | ❌ No |

## Scheduling Syntax (OnCalendar)

```ini
# Every hour
OnCalendar=*:00

# Daily at 2 AM
OnCalendar=02:00

# Every Monday at 3 AM
OnCalendar=Mon 03:00

# Every 15 minutes
OnCalendar=*:0/15

# Multiple times
OnCalendar=02:00
OnCalendar=14:00

# Every weekday at 8:30 AM
OnCalendar=Mon..Fri 08:30
```

## Persistent = true (⭐ Killer Feature)

```ini
[Timer]
Persistent=true
```

**What it does:**
- If the system is off when the timer should trigger...
- It runs **immediately on boot**!
- No more missed tasks!
- No custom state tracking needed!

**Example:**
```
Scheduled: 04:00 AM
Actual:    System off from 03:55 to 04:10
Result:    Runs at 04:10 when system boots ✅
```

## Management Commands

### Timer Management

```bash
# View all timers
sudo systemctl list-timers

# View specific timer
sudo systemctl list-timers my-task.timer

# Start timer now
sudo systemctl start my-task.timer

# Stop timer
sudo systemctl stop my-task.timer

# Enable on boot
sudo systemctl enable my-task.timer

# Disable on boot
sudo systemctl disable my-task.timer

# Check timer status
sudo systemctl status my-task.timer
```

### Service Management

```bash
# Run service once (manual trigger)
sudo systemctl start my-task.service

# Check service status
sudo systemctl status my-task.service

# View service logs
journalctl -u my-task.service -f

# View last 100 log lines
journalctl -u my-task.service -n 100

# View logs since last boot
journalctl -u my-task.service -b

# Search logs
journalctl -u my-task.service | grep "error"
```

## Security Sandboxing

Systemd provides excellent security sandboxing:

```ini
[Service]
# No new privileges
NoNewPrivileges=true

# Private /tmp
PrivateTmp=true

# Read-only file system (except explicit paths)
ProtectSystem=strict

# Allow writing only to these paths
ReadWritePaths=/path/to/your/project
ReadWritePaths=/path/to/your/data
```

## Dependencies

Ensure your task runs only when dependencies are ready:

```ini
[Unit]
Description=My Task
After=network.target postgresql.service
Wants=postgresql.service
```

- `After=`: Order (start after these are ready)
- `Wants=`: Requirement (start these too if possible)

## Troubleshooting

### Timer not triggering

```bash
# Check timer is loaded
sudo systemctl list-timers my-task.timer

# Check timer status
sudo systemctl status my-task.timer

# View system logs
journalctl -u my-task.timer -f
```

### Service failing

```bash
# Check service status
sudo systemctl status my-task.service

# View service logs
journalctl -u my-task.service -n 100 --no-pager

# Test the script manually
cd /path/to/your/project
node your-script.js
```

### Permission issues

```bash
# Check file permissions
ls -la /etc/systemd/system/my-task.*

# Check user exists
id your-user

# Check working directory
ls -la /path/to/your/project
```

## Reference: Complete Example

See [references/complete-example.md](references/complete-example.md) for a full, production-ready example including:
- Multiple timers for different tasks
- Database dependencies
- Log rotation
- Resource limits
- Full security sandboxing

## Comparison: All 3 Methods

| Aspect | System Cron | PM2 | Systemd Timer |
|--------|-------------|-----|---------------|
| Ease of setup | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Missed task catch-up | ❌ | ❌ | ✅ Built-in |
| Log management | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Dependency management | ❌ | ❌ | ✅ |
| Status monitoring | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Security | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Built-in to Linux | ✅ | ❌ | ✅ |
| **Recommended** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

## Final Recommendation

**Use systemd timer** - it's the best choice for Linux systems!

### Why?
1. ✅ **Built-in missed task catch-up** (no custom code needed)
2. ✅ **Great logging** with journalctl
3. ✅ **Dependency management** (wait for network/databases)
4. ✅ **Status monitoring** with systemctl list-timers
5. ✅ **Security sandboxing** built-in
6. ✅ **Randomized delay** to be polite
7. ✅ **Built-in to Linux** (no extra software)

## Quick Setup Recap

```bash
# 1. Create service + timer files
# (see examples above)

# 2. Copy to systemd
sudo cp my-task.service /etc/systemd/system/
sudo cp my-task.timer /etc/systemd/system/

# 3. Reload, enable, start
sudo systemctl daemon-reload
sudo systemctl enable my-task.timer
sudo systemctl start my-task.timer

# 4. Verify
sudo systemctl list-timers my-task.timer
journalctl -u my-task.service -f
```

That's it! 🎉
