# Event Types

This document describes all available hook event types and their context structures.

## Event Context Structure

Every event includes:

```typescript
{
  type: 'command' | 'session' | 'agent' | 'gateway' | 'message',
  action: string,              // e.g., 'new', 'reset', 'stop', 'received', 'sent'
  sessionKey: string,          // Session identifier
  timestamp: Date,             // When the event occurred
  messages: string[],          // Push messages here to send to user
  context: {
    // Event-specific context fields
  }
}
```

## Command Events

Triggered when agent commands are issued.

### `command:new`
- **When**: `/new` command is issued
- **Use case**: Save session context before reset

```typescript
context: {
  sessionEntry?: SessionEntry,
  sessionId?: string,
  sessionFile?: string,
  commandSource?: string,    // e.g., 'whatsapp', 'telegram'
  senderId?: string,
  workspaceDir?: string,
  cfg?: OpenClawConfig,
}
```

### `command:reset`
- **When**: `/reset` command is issued
- **Use case**: Same as `command:new`

### `command:stop`
- **When**: `/stop` command is issued
- **Use case**: Clean up resources, save final state

### `command` (general)
- **When**: Any command is issued
- **Use case**: Command logging, auditing

## Agent Events

### `agent:bootstrap`
- **When**: Before workspace bootstrap files are injected
- **Use case**: Inject additional bootstrap files

```typescript
context: {
  bootstrapFiles?: WorkspaceBootstrapFile[],
  workspaceDir?: string,
  cfg?: OpenClawConfig,
}
```

**Note**: You can mutate `context.bootstrapFiles` to add/remove files.

## Gateway Events

### `gateway:startup`
- **When**: After channels start and hooks are loaded
- **Use case**: Run initialization tasks, execute BOOT.md

## Message Events

Triggered when messages are received or sent.

### `message:received`
- **When**: An inbound message is received from any channel

```typescript
context: {
  from: string,           // Sender identifier (phone number, user ID, etc.)
  content: string,        // Message content
  timestamp?: number,     // Unix timestamp when received
  channelId: string,      // Channel (e.g., "whatsapp", "telegram", "discord")
  accountId?: string,     // Provider account ID for multi-account setups
  conversationId?: string, // Chat/conversation ID
  messageId?: string,     // Message ID from the provider
  metadata?: {            // Additional provider-specific data
    to?: string,
    provider?: string,
    surface?: string,
    threadId?: string,
    senderId?: string,
    senderName?: string,
    senderUsername?: string,
    senderE164?: string,
  }
}
```

### `message:sent`
- **When**: An outbound message is successfully sent

```typescript
context: {
  to: string,             // Recipient identifier
  content: string,        // Message content that was sent
  success: boolean,       // Whether the send succeeded
  error?: string,         // Error message if sending failed
  channelId: string,      // Channel (e.g., "whatsapp", "telegram", "discord")
  accountId?: string,     // Provider account ID
  conversationId?: string, // Chat/conversation ID
  messageId?: string,     // Message ID returned by the provider
}
```

### `message` (general)
- **When**: Any message event (received or sent)
- **Use case**: Message logging, analytics

## Tool Result Hooks (Plugin API)

### `tool_result_persist`
- **When**: Before tool results are written to session transcript
- **Type**: Synchronous (must return quickly)
- **Use case**: Transform tool results before persistence

**Note**: Must be synchronous; return the updated tool result payload or `undefined` to keep it as-is.

## Future Events (Planned)

- **`session:start`**: When a new session begins
- **`session:end`**: When a session ends
- **`agent:error`**: When an agent encounters an error

## Event Filtering Examples

### Filter by Command Type

```typescript
const handler: HookHandler = async (event) => {
  if (event.type !== "command" || event.action !== "new") {
    return;
  }
  // Handle /new command
};
```

### Filter by Message Type

```typescript
const isMessageReceived = (event: { type: string; action: string }) =>
  event.type === "message" && event.action === "received";

const isMessageSent = (event: { type: string; action: string }) =>
  event.type === "message" && event.action === "sent";

const handler: HookHandler = async (event) => {
  if (isMessageReceived(event)) {
    // Handle received message
  } else if (isMessageSent(event)) {
    // Handle sent message
  }
};
```
