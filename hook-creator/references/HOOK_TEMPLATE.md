---
name: my-hook
description: "Short description of what this hook does"
homepage: https://docs.openclaw.ai/automation/hooks#my-hook
metadata:
  {
    "openclaw":
      {
        "emoji": "🎯",
        "events": ["command:new"],
        "requires": { "config": ["workspace.dir"] },
      },
  }
---

# My Hook

Detailed documentation goes here...

## What It Does

- Listens for `/new` commands
- Performs some action
- Logs the result

## Requirements

- Node.js must be installed

## Configuration

No configuration needed.
