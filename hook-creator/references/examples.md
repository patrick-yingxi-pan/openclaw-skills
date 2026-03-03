# Example Hooks

This document provides example hooks for common use cases.

## Example 1: Simple Command Logger

A basic hook that logs all commands.

### HOOK.md

```markdown
---
name: simple-command-logger
description: "Log all commands to console"
metadata: { "openclaw": { "emoji": "📝", "events": ["command"] } }
---

# Simple Command Logger

Logs all command events to the console.

## What It Does

- Listens for all command events
- Logs command action, session key, and timestamp
- No configuration needed
```

### handler.ts

```typescript
import type { HookHandler } from "@openclaw/types";

const handler: HookHandler = async (event) => {
  if (event.type !== "command") {
    return;
  }

  console.log(`[simple-command-logger] Command: ${event.action}`);
  console.log(`  Session: ${event.sessionKey}`);
  console.log(`  Timestamp: ${event.timestamp.toISOString()}`);
  console.log(`  Source: ${event.context.commandSource || "unknown"}`);
};

export default handler;
```

---

## Example 2: Message Notifier

Sends a notification when messages are received or sent.

### HOOK.md

```markdown
---
name: message-notifier
description: "Send notifications for message events"
metadata: { "openclaw": { "emoji": "🔔", "events": ["message:received", "message:sent"] } }
---

# Message Notifier

Sends notifications when messages are received or sent.

## What It Does

- Listens for `message:received` and `message:sent` events
- Logs message details to console
- No configuration needed
```

### handler.ts

```typescript
import type { HookHandler } from "@openclaw/types";

const isMessageReceived = (event: { type: string; action: string }) =>
  event.type === "message" && event.action === "received";

const isMessageSent = (event: { type: string; action: string }) =>
  event.type === "message" && event.action === "sent";

const handler: HookHandler = async (event) => {
  if (isMessageReceived(event)) {
    console.log(`[message-notifier] Received from ${event.context.from}:`);
    console.log(`  Content: ${event.context.content?.substring(0, 100)}...`);
    console.log(`  Channel: ${event.context.channelId}`);
  } else if (isMessageSent(event)) {
    console.log(`[message-notifier] Sent to ${event.context.to}:`);
    console.log(`  Content: ${event.context.content?.substring(0, 100)}...`);
    console.log(`  Success: ${event.context.success}`);
  }
};

export default handler;
```

---

## Example 3: Workspace File Creator

Creates a file in the workspace when `/new` is issued.

### HOOK.md

```markdown
---
name: workspace-file-creator
description: "Create a file in workspace when /new is issued"
metadata:
  {
    "openclaw":
      {
        "emoji": "📄",
        "events": ["command:new"],
        "requires": { "config": ["workspace.dir"] },
      },
  }
---

# Workspace File Creator

Creates a timestamped file in the workspace when `/new` is issued.

## What It Does

- Listens for `/new` command
- Creates `workspace/new-session-YYYY-MM-DD-HH-MM-SS.txt`
- Writes session info to the file

## Requirements

- `workspace.dir` must be configured

## Configuration

No configuration needed.
```

### handler.ts

```typescript
import type { HookHandler } from "@openclaw/types";
import * as fs from "fs/promises";
import * as path from "path";

const handler: HookHandler = async (event) => {
  if (event.type !== "command" || event.action !== "new") {
    return;
  }

  const workspaceDir = event.context.workspaceDir;
  if (!workspaceDir) {
    console.error("[workspace-file-creator] No workspace dir configured");
    return;
  }

  try {
    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    const filename = `new-session-${timestamp}.txt`;
    const filepath = path.join(workspaceDir, filename);

    const content = `New Session Created
=================
Session Key: ${event.sessionKey}
Timestamp: ${event.timestamp.toISOString()}
Source: ${event.context.commandSource || "unknown"}
`;

    await fs.writeFile(filepath, content, "utf-8");
    console.log(`[workspace-file-creator] Created: ${filepath}`);
    
    event.messages.push(`📄 Created ${filename} in workspace`);
  } catch (err) {
    console.error("[workspace-file-creator] Failed:", err);
  }
};

export default handler;
```

---

## Example 4: Environment Checker

Verifies required environment variables are set.

### HOOK.md

```markdown
---
name: env-checker
description: "Check required environment variables on gateway startup"
metadata:
  {
    "openclaw":
      {
        "emoji": "✅",
        "events": ["gateway:startup"],
        "requires": { "env": ["MY_API_KEY", "MY_SECRET"] },
      },
  }
---

# Environment Checker

Verifies required environment variables are set when the gateway starts.

## What It Does

- Runs on gateway startup
- Checks for required environment variables
- Logs status to console

## Requirements

- `MY_API_KEY` environment variable
- `MY_SECRET` environment variable

## Configuration

Set the required environment variables before starting the gateway.
```

### handler.ts

```typescript
import type { HookHandler } from "@openclaw/types";

const handler: HookHandler = async (event) => {
  if (event.type !== "gateway" || event.action !== "startup") {
    return;
  }

  console.log("[env-checker] Checking environment variables...");
  
  const required = ["MY_API_KEY", "MY_SECRET"];
  const missing = required.filter(key => !process.env[key]);
  
  if (missing.length > 0) {
    console.error("[env-checker] Missing environment variables:", missing.join(", "));
  } else {
    console.log("[env-checker] All environment variables are set!");
  }
};

export default handler;
```

---

## Example 5: Bootstrap File Injector

Adds custom bootstrap files during agent bootstrap.

### HOOK.md

```markdown
---
name: custom-bootstrap-injector
description: "Inject custom bootstrap files during agent bootstrap"
metadata:
  {
    "openclaw":
      {
        "emoji": "📎",
        "events": ["agent:bootstrap"],
        "requires": { "config": ["workspace.dir"] },
      },
  }
---

# Custom Bootstrap Injector

Adds custom bootstrap files during agent bootstrap.

## What It Does

- Listens for `agent:bootstrap` event
- Injects custom `PROJECT.md` and `CHECKLIST.md` files
- Files are added to the workspace bootstrap

## Requirements

- `workspace.dir` must be configured

## Configuration

No configuration needed.
```

### handler.ts

```typescript
import type { HookHandler, WorkspaceBootstrapFile } from "@openclaw/types";

const handler: HookHandler = async (event) => {
  if (event.type !== "agent" || event.action !== "bootstrap") {
    return;
  }

  if (!event.context.bootstrapFiles) {
    event.context.bootstrapFiles = [];
  }

  // Add PROJECT.md
  const projectFile: WorkspaceBootstrapFile = {
    basename: "PROJECT.md",
    content: `# Project Context

This file is auto-injected by the custom-bootstrap-injector hook.

## Current Project

- **Name**: My Awesome Project
- **Status**: Active
- **Last Updated**: ${new Date().toISOString()}
`,
  };

  // Add CHECKLIST.md
  const checklistFile: WorkspaceBootstrapFile = {
    basename: "CHECKLIST.md",
    content: `# Daily Checklist

- [ ] Review yesterday's work
- [ ] Plan today's tasks
- [ ] Check for updates
- [ ] Commit changes
`,
  };

  event.context.bootstrapFiles.push(projectFile, checklistFile);
  console.log("[custom-bootstrap-injector] Injected 2 bootstrap files");
};

export default handler;
```

---

## Tips for Examples

When creating your own hooks:

1. **Start simple** - Get a basic version working first
2. **Add features incrementally** - Don't try to do everything at once
3. **Test often** - Test after each change
4. **Handle errors** - Always wrap risky operations
5. **Document everything** - Explain what it does and how to use it
6. **Use the templates** - Start from the templates in this skill
