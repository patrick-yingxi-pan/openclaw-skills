# Complete Systemd Timer Example

This is a full, production-ready example of systemd timer setup.

## Scenario

We have a Node.js project that needs:
- Hourly health checks
- Daily data processing at 2 AM
- Daily report generation at 8 AM
- Dependencies on PostgreSQL and network

---

## Step 1: Create Directory Structure

```
/etc/systemd/system/
├── myproject-healthcheck.service
├── myproject-healthcheck.timer
├── myproject-processing.service
├── myproject-processing.timer
├── myproject-report.service
└── myproject-report.timer
```

---

## Step 2: Create Shared Service Base

Create `/etc/systemd/system/myproject-common.env`:
```ini
# Environment variables for all myproject services
NODE_ENV=production
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
LOG_LEVEL=info
```

---

## Step 3: Health Check (Hourly)

**`myproject-healthcheck.service`**:
```ini
[Unit]
Description=MyProject Hourly Health Check
Documentation=https://docs.myproject.com
After=network.target postgresql.service
Wants=postgresql.service
RequiresMountsFor=/home/myproject

[Service]
Type=oneshot
User=myproject
Group=myproject
WorkingDirectory=/home/myproject
EnvironmentFile=/etc/systemd/system/myproject-common.env

# Exec path
ExecStart=/usr/bin/node /home/myproject/scripts/healthcheck.js

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myproject-healthcheck

# Resource limits
Nice=10
IOSchedulingClass=idle
CPUWeight=50
MemoryMax=256M

# Security
NoNewPrivileges=true
PrivateTmp=true
PrivateDevices=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/home/myproject/data
ReadWritePaths=/home/myproject/logs
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectKernelLogs=true
ProtectControlGroups=true
RestrictNamespaces=true
LockPersonality=true
MemoryDenyWriteExecute=true
RestrictRealtime=true
RestrictSUIDSGID=true
SystemCallFilter=@system-service
SystemCallErrorNumber=EPERM
```

**`myproject-healthcheck.timer`**:
```ini
[Unit]
Description=MyProject Health Check Timer
Documentation=https://docs.myproject.com

[Timer]
# Every hour at minute 0
OnCalendar=*:00

# Catch up if missed
Persistent=true

# Random delay 0-5 minutes
RandomizedDelaySec=300

# Don't run more than once per hour
AccuracySec=1min

[Install]
WantedBy=timers.target
```

---

## Step 4: Data Processing (Daily at 2 AM)

**`myproject-processing.service`**:
```ini
[Unit]
Description=MyProject Daily Data Processing
Documentation=https://docs.myproject.com
After=network.target postgresql.service myproject-healthcheck.service
Wants=postgresql.service
RequiresMountsFor=/home/myproject

[Service]
Type=oneshot
User=myproject
Group=myproject
WorkingDirectory=/home/myproject
EnvironmentFile=/etc/systemd/system/myproject-common.env

# Exec path
ExecStart=/usr/bin/node /home/myproject/scripts/processing.js
ExecStartPost=/usr/bin/node /home/myproject/scripts/processing-cleanup.js

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myproject-processing

# Resource limits
Nice=5
IOSchedulingClass=best-effort
CPUWeight=100
MemoryMax=1G
IOWeight=50

# Security (same as healthcheck)
NoNewPrivileges=true
PrivateTmp=true
PrivateDevices=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/home/myproject/data
ReadWritePaths=/home/myproject/logs
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectKernelLogs=true
ProtectControlGroups=true
RestrictNamespaces=true
LockPersonality=true
MemoryDenyWriteExecute=true
RestrictRealtime=true
RestrictSUIDSGID=true
SystemCallFilter=@system-service
SystemCallErrorNumber=EPERM
```

**`myproject-processing.timer`**:
```ini
[Unit]
Description=MyProject Processing Timer
Documentation=https://docs.myproject.com

[Timer]
# Daily at 2:00 AM
OnCalendar=02:00

# Catch up if missed
Persistent=true

# Random delay 0-15 minutes
RandomizedDelaySec=900

[Install]
WantedBy=timers.target
```

---

## Step 5: Report Generation (Daily at 8 AM)

**`myproject-report.service`**:
```ini
[Unit]
Description=MyProject Daily Report Generation
Documentation=https://docs.myproject.com
After=network.target postgresql.service myproject-processing.service
Wants=postgresql.service
RequiresMountsFor=/home/myproject

[Service]
Type=oneshot
User=myproject
Group=myproject
WorkingDirectory=/home/myproject
EnvironmentFile=/etc/systemd/system/myproject-common.env

# Exec path
ExecStart=/usr/bin/node /home/myproject/scripts/generate-report.js

# Email the report (optional)
ExecStartPost=/usr/bin/bash -c '/usr/bin/mail -s "Daily Report" admin@example.com < /home/myproject/reports/latest.pdf'

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myproject-report

# Resource limits
Nice=15
IOSchedulingClass=idle
CPUWeight=25
MemoryMax=512M

# Security (same as others)
NoNewPrivileges=true
PrivateTmp=true
PrivateDevices=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/home/myproject/data
ReadWritePaths=/home/myproject/logs
ReadWritePaths=/home/myproject/reports
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectKernelLogs=true
ProtectControlGroups=true
RestrictNamespaces=true
LockPersonality=true
MemoryDenyWriteExecute=true
RestrictRealtime=true
RestrictSUIDSGID=true
SystemCallFilter=@system-service
SystemCallErrorNumber=EPERM
```

**`myproject-report.timer`**:
```ini
[Unit]
Description=MyProject Report Timer
Documentation=https://docs.myproject.com

[Timer]
# Daily at 8:00 AM
OnCalendar=08:00

# Catch up if missed
Persistent=true

# Random delay 0-10 minutes
RandomizedDelaySec=600

[Install]
WantedBy=timers.target
```

---

## Step 6: Install and Start

```bash
# Copy all files
sudo cp myproject-*.service /etc/systemd/system/
sudo cp myproject-*.timer /etc/systemd/system/
sudo cp myproject-common.env /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable all timers
sudo systemctl enable myproject-healthcheck.timer
sudo systemctl enable myproject-processing.timer
sudo systemctl enable myproject-report.timer

# Start all timers
sudo systemctl start myproject-healthcheck.timer
sudo systemctl start myproject-processing.timer
sudo systemctl start myproject-report.timer
```

---

## Step 7: Verify

```bash
# List all timers
sudo systemctl list-timers myproject-*.timer

# Check status of all timers
sudo systemctl status myproject-healthcheck.timer
sudo systemctl status myproject-processing.timer
sudo systemctl status myproject-report.timer

# Follow all logs
journalctl -u myproject-healthcheck.service -u myproject-processing.service -u myproject-report.service -f
```

---

## Step 8: Monitoring

### Log Rotation (journalctl)

Journald handles log rotation automatically, but you can configure limits:

Create `/etc/systemd/journald.conf.d/myproject.conf`:
```ini
[Journal]
SystemMaxUse=10G
SystemMaxFileSize=100M
RuntimeMaxUse=2G
```

### Resource Monitoring

```bash
# Monitor service resource usage
systemd-cgtop

# Check specific service
systemctl status myproject-processing.service

# Check journal for errors
journalctl -u myproject-processing.service -p err -b
```

---

## Step 9: Maintenance

```bash
# Stop all timers
sudo systemctl stop myproject-*.timer

# Disable all timers
sudo systemctl disable myproject-*.timer

# Reload after changes
sudo systemctl daemon-reload

# Restart a specific timer
sudo systemctl restart myproject-processing.timer

# Run a service manually
sudo systemctl start myproject-processing.service
```

---

## Security Notes

The security settings in this example are quite strict. You may need to adjust based on your needs:

- If your script needs network access: remove `RestrictAddressFamilies` or add specific families
- If you need more write paths: add to `ReadWritePaths`
- If you need specific system calls: adjust `SystemCallFilter`

Always test thoroughly in a staging environment!
