# Best Practices

This document provides best practices for developing high-quality OpenClaw hooks.

## Keep Handlers Fast

Hooks run during command processing. Keep them lightweight:

```typescript
// ✓ Good - async work, returns immediately
const handler: HookHandler = async (event) => {
  void processInBackground(event); // Fire and forget
};

// ✗ Bad - blocks command processing
const handler: HookHandler = async (event) => {
  await slowDatabaseQuery(event);
  await evenSlowerAPICall(event);
};
```

### Fire-and-Forget Pattern

For slow operations, use fire-and-forget:

```typescript
const processInBackground = async (event) => {
  try {
    await slowOperation(event);
  } catch (err) {
    console.error("[my-hook] Background task failed:", err);
  }
};

const handler: HookHandler = async (event) => {
  if (event.type !== "command" || event.action !== "new") {
    return;
  }
  
  void processInBackground(event); // Don't await
};
```

## Handle Errors Gracefully

Always wrap risky operations:

```typescript
const handler: HookHandler = async (event) => {
  try {
    await riskyOperation(event);
  } catch (err) {
    console.error("[my-hook] Failed:", err instanceof Error ? err.message : String(err));
    // Don't throw - let other handlers run
  }
};
```

### Don't Throw Errors

Throwing errors stops subsequent hooks from running. Always catch and log:

```typescript
// ✗ Bad - throws error
const handler: HookHandler = async (event) => {
  await riskyOperation(event); // Will throw if fails
};

// ✓ Good - catches and logs
const handler: HookHandler = async (event) => {
  try {
    await riskyOperation(event);
  } catch (err) {
    console.error("[my-hook] Failed:", err);
  }
};
```

## Filter Events Early

Return early if the event isn't relevant:

```typescript
const handler: HookHandler = async (event) => {
  // Only handle 'new' commands
  if (event.type !== "command" || event.action !== "new") {
    return;
  }

  // Your logic here
};
```

### Multiple Event Types

If handling multiple events, check at the top:

```typescript
const handler: HookHandler = async (event) => {
  if (
    (event.type !== "command" || event.action !== "new") &&
    (event.type !== "command" || event.action !== "reset")
  ) {
    return;
  }

  // Handle both /new and /reset
};
```

## Use Specific Event Keys

Specify exact events in metadata when possible:

```yaml
metadata: { "openclaw": { "events": ["command:new"] } } # Specific
```

Rather than:

```yaml
metadata: { "openclaw": { "events": ["command"] } } # General - more overhead
```

This reduces unnecessary handler invocations.

## Use Semantic Emojis

Choose an emoji that represents what your hook does:

- 💾 - Saving/storage (session-memory)
- 📝 - Logging (command-logger)
- 🚀 - Startup/initialization (boot-md)
- 📎 - File injection (bootstrap-extra-files)
- 🔔 - Notifications
- 🎯 - Targeted actions
- ✨ - Enhancements

## Document Thoroughly

Your HOOK.md should answer:

1. **What it does** - Clear description
2. **When it triggers** - Which events
3. **Requirements** - Binaries, config, env vars
4. **Configuration** - How to customize
5. **Example output** - What users can expect
6. **How to enable/disable** - CLI commands

## Keep Dependencies Minimal

If your hook needs dependencies:

1. Bundle them in a hook pack (npm package)
2. Use pure JS/TS dependencies (no native modules)
3. Avoid dependencies that need postinstall scripts

## Use Config Wisely

For configurable hooks:

1. Provide sensible defaults
2. Document all options
3. Validate config values
4. Use hook config instead of env vars when possible

```json
{
  "hooks": {
    "internal": {
      "entries": {
        "my-hook": {
          "enabled": true,
          "messages": 25,
          "outputDir": "custom/memory"
        }
      }
    }
  }
}
```

## Log Thoughtfully

Use consistent logging:

```typescript
console.log("[my-hook] Starting operation...");
console.log("[my-hook] Processing item:", itemId);
console.error("[my-hook] Failed:", error);
```

- Use `console.log` for normal operations
- Use `console.error` for errors
- Prefix with `[hook-name]` for easy filtering

## Test Edge Cases

Test:

- Missing requirements
- Invalid config
- Network failures
- Large input sizes
- Concurrent events

## Be a Good Citizen

- Don't modify files outside the workspace without explicit config
- Respect user privacy
- Clean up temporary files
- Don't spam the user with messages
- Coordinate with other hooks (don't duplicate work)
