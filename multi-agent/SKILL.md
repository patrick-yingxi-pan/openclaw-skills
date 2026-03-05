---
name: multi-agent
description: |
  Multi-agent routing and management - set up multiple isolated agents with separate workspaces, channel accounts, and bindings. Manage agent personas, tool restrictions, and sandbox configurations.
license: Apache-2.0
compatibility: "OpenClaw Gateway 2026.1.6+"
metadata:
  author: OpenClaw
  version: "1.0"
  category: automation
---

# Multi-Agent Skill

Manage multiple isolated agents with separate workspaces, channel accounts, and bindings.

## What is "One Agent"?

An **agent** is a fully scoped brain with its own:
- **Workspace** (files, AGENTS.md/SOUL.md/USER.md, local notes, persona rules)
- **State directory** (`agentDir`) for auth profiles, model registry, and per-agent config
- **Session store** (chat history + routing state) under `~/.openclaw/agents/<agentId>/sessions`

## Quick Start

### Add Agents with Wizard

```bash
openclaw agents add coding
openclaw agents add social
```

### Verify Bindings

```bash
openclaw agents list --bindings
```

## Concepts

| Term | Description |
|------|-------------|
| `agentId` | One "brain" (workspace, per-agent auth, per-agent session store) |
| `accountId` | One channel account instance (e.g. WhatsApp account "personal" vs "biz") |
| `binding` | Routes inbound messages to an `agentId` by `(channel, accountId, peer)` |

## Paths

- Config: `~/.openclaw/openclaw.json`
- State dir: `~/.openclaw`
- Workspace: `~/.openclaw/workspace` (or `~/.openclaw/workspace-<agentId>`)
- Agent dir: `~/.openclaw/agents/<agentId>/agent`
- Sessions: `~/.openclaw/agents/<agentId>/sessions`

## Single-Agent Mode (Default)

If you do nothing, OpenClaw runs a single agent:
- `agentId` defaults to **`main`**
- Sessions are keyed as `agent:main:<mainKey>`
- Workspace defaults to `~/.openclaw/workspace`

## Complete Setup Flow

### Step 1: Create Each Agent Workspace

Use the wizard or create workspaces manually:
```bash
openclaw agents add coding
openclaw agents add social
```

Each agent gets its own workspace with `SOUL.md`, `AGENTS.md`, and optional `USER.md`, plus a dedicated `agentDir` and session store.

### Step 2: Create Channel Accounts

Create one account per agent on your preferred channels:

```bash
openclaw channels login --channel whatsapp --account work
```

### Step 3: Add Agents, Accounts, and Bindings

Add agents under `agents.list`, channel accounts under `channels.<channel>.accounts`, and connect them with `bindings`.

### Step 4: Restart and Verify

```bash
openclaw gateway restart
openclaw agents list --bindings
openclaw channels status --probe
```

## Routing Rules

Bindings are **deterministic** and **most-specific wins**:

1. `peer` match (exact DM/group/channel id)
2. `parentPeer` match (thread inheritance)
3. `guildId + roles` (Discord role routing)
4. `guildId` (Discord)
5. `teamId` (Slack)
6. `accountId` match for a channel
7. channel-level match (`accountId: "*"`)
8. fallback to default agent

## Platform Examples

### Discord Bots per Agent

```json5
{
  agents: {
    list: [
      { id: "main", workspace: "~/.openclaw/workspace-main" },
      { id: "coding", workspace: "~/.openclaw/workspace-coding" },
    ],
  },
  bindings: [
    { agentId: "main", match: { channel: "discord", accountId: "default" } },
    { agentId: "coding", match: { channel: "discord", accountId: "coding" } },
  ],
  channels: {
    discord: {
      accounts: {
        default: { token: "DISCORD_BOT_TOKEN_MAIN" },
        coding: { token: "DISCORD_BOT_TOKEN_CODING" },
      },
    },
  },
}
```

### Telegram Bots per Agent

```json5
{
  agents: {
    list: [
      { id: "main", workspace: "~/.openclaw/workspace-main" },
      { id: "alerts", workspace: "~/.openclaw/workspace-alerts" },
    ],
  },
  bindings: [
    { agentId: "main", match: { channel: "telegram", accountId: "default" } },
    { agentId: "alerts", match: { channel: "telegram", accountId: "alerts" } },
  ],
  channels: {
    telegram: {
      accounts: {
        default: { botToken: "123456:ABC..." },
        alerts: { botToken: "987654:XYZ..." },
      },
    },
  },
}
```

### WhatsApp Numbers per Agent

Link each account before starting the gateway:
```bash
openclaw channels login --channel whatsapp --account personal
openclaw channels login --channel whatsapp --account biz
```

Config:
```json5
{
  agents: {
    list: [
      {
        id: "home",
        default: true,
        name: "Home",
        workspace: "~/.openclaw/workspace-home",
      },
      {
        id: "work",
        name: "Work",
        workspace: "~/.openclaw/workspace-work",
      },
    ],
  },
  bindings: [
    { agentId: "home", match: { channel: "whatsapp", accountId: "personal" } },
    { agentId: "work", match: { channel: "whatsapp", accountId: "biz" } },
  ],
}
```

## Per-Agent Sandbox & Tools

```json5
{
  agents: {
    list: [
      {
        id: "personal",
        workspace: "~/.openclaw/workspace-personal",
        sandbox: { mode: "off" },
      },
      {
        id: "family",
        workspace: "~/.openclaw/workspace-family",
        sandbox: {
          mode: "all",
          scope: "agent",
        },
        tools: {
          allow: ["read"],
          deny: ["exec", "write", "edit"],
        },
      },
    ],
  },
}
```

## References

- **[Official Multi-Agent Docs](https://docs.openclaw.ai/concepts/multi-agent)**: Complete official documentation
- **[Multi-Agent Sandbox & Tools](https://docs.openclaw.ai/tools/multi-agent-sandbox-tools)**: Detailed sandbox examples
