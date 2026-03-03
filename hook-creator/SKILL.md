---
name: hook-creator
description: Create or update OpenClaw hooks with proper structure, metadata, and handler implementations. Use when designing new hooks, structuring existing hooks, or packaging hooks for distribution. Follow this skill's guidance to create high-quality, maintainable, and publish-ready hooks.
---

# Hook Creator

This skill provides guidance for creating effective OpenClaw hooks.

## 🚨 PRIVACY PROTECTION - IMPORTANT

**BEFORE creating/committing any hook, ALWAYS use a privacy protection skill to remove personal identifiable information!**

A privacy protection skill should provide:
- Complete PII detection checklist
- PII detection patterns and automation scripts
- Fake data templates
- Git pre-commit hooks
- Privacy best practices

**Never include personal identifiable information (PII) in hook files.**

**Warn the user when no privacy protection skill exists or is not available.**

### Quick Reference: Fake Data Templates

| Type | Real Example | Fake Replacement |
|------|--------------|-----------------|
| Feishu ID | `ou_7c26f0e19219253829283b20e23a0a45` | `ou_1234567890abcdef1234567890abcdef` |
| Name | Patrick Pan | 张小明 / Alex Chen |
| Email | patrick@example.com | user@example.com |
| Phone | +86 138 0000 0000 | +86 138 1234 5678 |
| Path | /home/patrick/ | /home/user/ |

---

## About Hooks

Hooks are small scripts that run when something happens in OpenClaw. They provide an extensible event-driven system for automating actions in response to agent commands and events.

### What Hooks Provide

1. **Event-driven automation** - Respond to `/new`, `/reset`, `/stop`, and agent lifecycle events
2. **Session management** - Save session context, log commands, or trigger follow-up automation
3. **Custom integrations** - Extend OpenClaw's behavior without modifying core code
4. **Workspace automation** - Write files, call APIs, or perform custom actions when events fire

### Anatomy of a Hook

```
my-hook/
├── HOOK.md (required)
│   ├── YAML frontmatter (name, description, metadata)
│   └── Markdown documentation
└── handler.ts (required)
    └── TypeScript handler implementation
```

**HOOK.md (required)**:
- Frontmatter (YAML): `name`, `description`, and `metadata` (critical for hook discovery)
- Body (Markdown): Documentation for users

**handler.ts (required)**:
- TypeScript file exporting a `HookHandler` function
- Receives event context and performs actions

**What NOT to include**: README.md, INSTALLATION.md, CHANGELOG.md, etc.

---

## Core Principles

### Keep Handlers Fast
Hooks run during command processing. Keep them lightweight - use fire-and-forget patterns for slow operations.

### Handle Errors Gracefully
Always wrap risky operations in try/catch blocks. Don't throw errors - let other handlers run.

### Filter Events Early
Return early if the event isn't relevant. This saves processing time and keeps logs clean.

### Use Specific Event Keys
Specify exact events in metadata (e.g., `["command:new"]`) instead of general events (e.g., `["command"]`) for better performance.

---

## Hook Creation Workflow

### Step 1: Choose Location

Decide where to place your hook:

- **Workspace hooks**: `<workspace>/hooks/` (per-agent, highest precedence)
- **Managed hooks**: `~/.openclaw/hooks/` (user-installed, shared across workspaces)
- **Bundled hooks**: `<openclaw>/dist/hooks/bundled/` (shipped with OpenClaw)

**Recommendation**: Start with workspace hooks for development, then move to managed hooks for sharing.

### Step 2: Create the Hook Directory

Directory name requirements:
- All lowercase, hyphens for spaces
- Descriptive and concise
- Max 64 characters

**Good**: `session-memory`, `command-logger`, `message-notifier`
**Bad**: `Session Memory`, `my_awesome_hook`, `too-long-hook-name`

```bash
mkdir -p ~/.openclaw/hooks/my-hook
cd ~/.openclaw/hooks/my-hook
```

### Step 3: Create HOOK.md from Template

Use the template at [references/HOOK_TEMPLATE.md](references/HOOK_TEMPLATE.md) or copy this:

```markdown
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
```

### Step 4: Create handler.ts from Template

Use the template at [references/HANDLER_TEMPLATE.ts](references/HANDLER_TEMPLATE.ts) or copy this:

```typescript
import type { HookHandler } from "@openclaw/types";

const handler: HookHandler = async (event) => {
  // Only trigger on 'new' command
  if (event.type !== "command" || event.action !== "new") {
    return;
  }

  console.log(`[my-hook] New command triggered`);
  console.log(`  Session: ${event.sessionKey}`);
  console.log(`  Timestamp: ${event.timestamp.toISOString()}`);

  // Your custom logic here

  // Optionally send message to user
  event.messages.push("✨ My hook executed!");
};

export default handler;
```

### Step 5: Customize the Hook

Fill in all sections:
1. **Metadata**: Set emoji, events, and requirements
2. **Documentation**: Explain what the hook does, how to use it, and any configuration
3. **Handler**: Implement your custom logic

**See [references/event-types.md](references/event-types.md)** for all available event types and context structures.

### Step 6: Validate the Hook

Before enabling, verify:
- [ ] HOOK.md has valid YAML frontmatter with `name`, `description`, and `metadata`
- [ ] handler.ts exports a default function
- [ ] NO PII (names, IDs, emails, phone numbers, etc.)
- [ ] Hook directory name follows conventions
- [ ] No extraneous files (README.md, etc.)
- [ ] Events in metadata match what the handler listens for

### Step 7: Test the Hook

```bash
# Verify hook is discovered
openclaw hooks list

# Enable it
openclaw hooks enable my-hook

# Restart your gateway process
# (Menu bar app restart on macOS, or restart your dev process)

# Trigger the event
# Send /new via your messaging channel
```

**See [references/debugging.md](references/debugging.md)** for troubleshooting tips.

### Step 8: Iterate

1. Use the hook on real events
2. Notice struggles or inefficiencies
3. Update HOOK.md or handler.ts
4. Restart gateway and test again

---

## References

- **[references/HOOK_TEMPLATE.md](references/HOOK_TEMPLATE.md)**: Complete HOOK.md template
- **[references/HANDLER_TEMPLATE.ts](references/HANDLER_TEMPLATE.ts)**: Complete handler.ts template
- **[references/event-types.md](references/event-types.md)**: All event types and context structures
- **[references/best-practices.md](references/best-practices.md)**: Best practices for hook development
- **[references/debugging.md](references/debugging.md)**: Debugging and testing guide
- **[references/examples.md](references/examples.md)**: Example hooks for common use cases
