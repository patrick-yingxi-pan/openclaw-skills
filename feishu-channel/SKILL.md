---
name: feishu-channel
description: |
  Complete Feishu channel management including user preferences, session startup, delayed reporting, and official OpenClaw Feishu bot setup guide. Activate when the channel for current session is Feishu or when setting up Feishu integration.
version: 2.0
lastUpdated: 2026-03-05
---

# Feishu Channel Skill

Unified skill for Feishu channel management including user preferences, session startup, delayed reporting, and complete official setup guide.

## Overview

This skill provides complete Feishu channel functionality:
- User preference management and personalization
- Session startup automation
- New user onboarding
- Delayed reporting to specific users
- **Complete official OpenClaw Feishu bot setup guide** (new in v2.0)

---

## Part 1: Official Feishu Bot Setup (New!)

### Quick Start - Two Methods

#### Method 1: Onboarding Wizard (Recommended)

If you just installed OpenClaw, run the wizard:
```bash
openclaw onboard
```

The wizard guides you through:
1. Creating a Feishu app and collecting credentials
2. Configuring app credentials in OpenClaw
3. Starting the gateway

✅ **After configuration**, check gateway status:
- `openclaw gateway status`
- `openclaw logs --follow`

#### Method 2: CLI Setup

If you already completed initial install, add the channel via CLI:
```bash
openclaw channels add
```

Choose **Feishu**, then enter the App ID and App Secret.

✅ **After configuration**, manage the gateway:
- `openclaw gateway status`
- `openclaw gateway restart`
- `openclaw logs --follow`

---

## Step-by-Step Setup Guide

### Step 1: Create a Feishu App

#### 1. Open Feishu Open Platform
Visit [Feishu Open Platform](https://open.feishu.cn/app) and sign in.

Lark (global) tenants should use [https://open.larksuite.com/app](https://open.larksuite.com/app) and set `domain: "lark"` in the Feishu config.

#### 2. Create an App
1. Click **Create enterprise app**
2. Fill in the app name + description
3. Choose an app icon

#### 3. Copy Credentials
From **Credentials & Basic Info**, copy:
- **App ID** (format: `cli_xxx`)
- **App Secret**

❗ **Important:** keep the App Secret private.

#### 4. Configure Permissions
On **Permissions**, click **Batch import** and paste:
```json
{
  "scopes": {
    "tenant": [
      "aily:file:read",
      "aily:file:write",
      "application:application.app_message_stats.overview:readonly",
      "application:application:self_manage",
      "application:bot.menu:write",
      "cardkit:card:read",
      "cardkit:card:write",
      "contact:user.employee_id:readonly",
      "corehr:file:download",
      "event:ip_list",
      "im:chat.access_event.bot_p2p_chat:read",
      "im:chat.members:bot_access",
      "im:message",
      "im:message.group_at_msg:readonly",
      "im:message.p2p_msg:readonly",
      "im:message:readonly",
      "im:message:send_as_bot",
      "im:resource"
    ],
    "user": ["aily:file:read", "aily:file:write", "im:chat.access_event.bot_p2p_chat:read"]
  }
}
```

#### 5. Enable Bot Capability
In **App Capability** > **Bot**:
1. Enable bot capability
2. Set the bot name

#### 6. Configure Event Subscription
⚠️ **Important:** before setting event subscription, make sure:
1. You already ran `openclaw channels add` for Feishu
2. The gateway is running (`openclaw gateway status`)

In **Event Subscription**:
1. Choose **Use long connection to receive events** (WebSocket)
2. Add the event: `im.message.receive_v1`

⚠️ If the gateway is not running, the long-connection setup may fail to save.

#### 7. Publish the App
1. Create a version in **Version Management & Release**
2. Submit for review and publish
3. Wait for admin approval (enterprise apps usually auto-approve)

---

### Step 2: Configure OpenClaw

#### Configure with the wizard (recommended)
```bash
openclaw channels add
```

Choose **Feishu** and paste your App ID + App Secret.

#### Configure via config file
Edit `~/.openclaw/openclaw.json`:
```json5
{
  channels: {
    feishu: {
      enabled: true,
      dmPolicy: "pairing",
      accounts: {
        main: {
          appId: "cli_xxx",
          appSecret: "xxx",
          botName: "My AI assistant",
        },
      },
    },
  },
}
```

#### Lark (global) domain
If your tenant is on Lark (international), set the domain to `lark`:
```json5
{
  channels: {
    feishu: {
      domain: "lark",
      accounts: {
        main: {
          appId: "cli_xxx",
          appSecret: "xxx",
        },
      },
    },
  },
}
```

#### Quota optimization flags
You can reduce Feishu API usage with two optional flags:
- `typingIndicator` (default `true`): when `false`, skip typing reaction calls.
- `resolveSenderNames` (default `true`): when `false`, skip sender profile lookup calls.

---

### Step 3: Start + Test

#### 1. Start the gateway
```bash
openclaw gateway
```

#### 2. Send a test message
In Feishu, find your bot and send a message.

#### 3. Approve pairing
By default, the bot replies with a pairing code. Approve it:
```bash
openclaw pairing approve feishu <CODE>
```

After approval, you can chat normally.

---

## Part 2: Feishu User Management

### Quick Reference

| Task | Action |
|------|--------|
| **Session Startup** | Follow the Feishu Session Startup Checklist |
| **Identify User** | Extract user ID from inbound metadata (SenderId, user_id, or chat_id) |
| **New User Onboarding** | Follow the New User Onboarding Flow |
| **Apply Preferences** | Read and apply user preferences at session start |
| **Update Preferences** | Edit the corresponding Feishu_USER_&lt;user-id&gt;.md file |
| **Fix Format Issues** | Refer to the User File Format Specification |

### Quick Start

1. At Feishu session start: Read SOUL.md → USER.md → today/yesterday memory → MEMORY.md (if MAIN SESSION)
2. Extract Feishu user ID from inbound metadata
3. Check if user file exists:
   - If YES: Read and apply preferences
   - If NO: Start new user onboarding flow
4. Greet user and ask what they want to do

### Feishu Session Startup Checklist

**Follow this checklist at the start of EVERY Feishu session:**

#### 1. Read Base Files
- [ ] Read SOUL.md
- [ ] Read USER.md
- [ ] Read memory/YYYY-MM-DD.md (today + yesterday)
- [ ] If in MAIN SESSION: Read MEMORY.md

#### 2. Identify Feishu User
- [ ] Extract Feishu user ID from inbound metadata (try in this order):
  1. `SenderId` field (preferred)
  2. `user_id` field
  3. `chat_id` field (format: `user:ou_xxxxxxxxxx`, extract `ou_xxxxxxxxxx` part)
- [ ] Verify user ID format is `ou_xxxxxxxxxx`

#### 3. Handle User File
- [ ] Check if user file exists: `Feishu_USER_&lt;user-id&gt;.md`
- [ ] If file exists:
  - [ ] Read and parse the user file
  - [ ] Apply user preferences (see "User Preferences Application" section)
- [ ] If file does NOT exist:
  - [ ] Start the New User Onboarding Flow (see below)

#### 4. Complete Startup
- [ ] Greet the user using their preferred name
- [ ] Ask what they want to do

### User Identification and Error Handling

#### Extracting Feishu User ID

**Priority order for extracting user ID:**

1. **`SenderId` field** (recommended) - Direct sender open ID
2. **`user_id` field** - Alternative user ID field
3. **`chat_id` field** - Format: `user:ou_xxxxxxxxxx`, extract the `ou_xxxxxxxxxx` part

**Example inbound metadata:**
```json
{
  "chat_id": "user:ou_6eae500b759305b553934324445f8895",
  "channel": "feishu",
  "provider": "feishu",
  "surface": "feishu",
  "chat_type": "direct"
}
```

---

## Part 3: Access Control & Configuration

### Direct Messages

- **Default**: `dmPolicy: "pairing"` (unknown users get a pairing code)
- **Approve pairing**:
  ```bash
  openclaw pairing list feishu
  openclaw pairing approve feishu <CODE>
  ```
- **Allowlist mode**: set `channels.feishu.allowFrom` with allowed Open IDs

### Group Chats

**1. Group policy** (`channels.feishu.groupPolicy`):
- `"open"` = allow everyone in groups (default)
- `"allowlist"` = only allow `groupAllowFrom`
- `"disabled"` = disable group messages

**2. Mention requirement** (`channels.feishu.groups.<chat_id>.requireMention`):
- `true` = require @mention (default)
- `false` = respond without mentions

### Get Group/User IDs

#### Group IDs (chat_id)
Group IDs look like `oc_xxx`.

**Method 1 (recommended)**
1. Start the gateway and @mention the bot in the group
2. Run `openclaw logs --follow` and look for `chat_id`

#### User IDs (open_id)
User IDs look like `ou_xxx`.

**Method 1 (recommended)**
1. Start the gateway and DM the bot
2. Run `openclaw logs --follow` and look for `open_id`

---

## Part 4: Common Commands & Troubleshooting

### Common Commands
| Command   | Description       |
| --------- | ----------------- |
| `/status` | Show bot status   |
| `/reset`  | Reset the session |
| `/model`  | Show/switch model |

### Gateway Management Commands
| Command                    | Description                   |
| -------------------------- | ----------------------------- |
| `openclaw gateway status`  | Show gateway status           |
| `openclaw gateway install` | Install/start gateway service |
| `openclaw gateway stop`    | Stop gateway service          |
| `openclaw gateway restart` | Restart gateway service       |
| `openclaw logs --follow`   | Tail gateway logs             |

### Troubleshooting

#### Bot does not respond in group chats
1. Ensure the bot is added to the group
2. Ensure you @mention the bot (default behavior)
3. Check `groupPolicy` is not set to `"disabled"`
4. Check logs: `openclaw logs --follow`

#### Bot does not receive messages
1. Ensure the app is published and approved
2. Ensure event subscription includes `im.message.receive_v1`
3. Ensure **long connection** is enabled
4. Ensure app permissions are complete
5. Ensure the gateway is running: `openclaw gateway status`
6. Check logs: `openclaw logs --follow`

---

## References

- **[Official Feishu Docs](https://docs.openclaw.ai/channels/feishu)**: Complete official documentation
- **[Gateway Configuration](https://docs.openclaw.ai/gateway/configuration)**: Full config reference
