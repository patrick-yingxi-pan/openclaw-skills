# Debugging and Testing Guide

This document provides guidance for debugging and testing OpenClaw hooks.

## Debugging

### Enable Hook Logging

The gateway logs hook loading at startup:

```
Registered hook: session-memory -> command:new
Registered hook: bootstrap-extra-files -> agent:bootstrap
Registered hook: command-logger -> command
Registered hook: boot-md -> gateway:startup
```

### Check Discovery

List all discovered hooks:

```bash
openclaw hooks list
```

Verbose output (show missing requirements):

```bash
openclaw hooks list --verbose
```

JSON output:

```bash
openclaw hooks list --json
```

### Check Hook Information

Get detailed information about a hook:

```bash
openclaw hooks info my-hook
```

JSON output:

```bash
openclaw hooks info my-hook --json
```

### Check Eligibility

Show eligibility summary:

```bash
openclaw hooks check
```

JSON output:

```bash
openclaw hooks check --json
```

### Add Debug Logging

In your handler, log when it's called:

```typescript
const handler: HookHandler = async (event) => {
  console.log("[my-hook] Triggered:", event.type, event.action);
  console.log("[my-hook] Full event:", JSON.stringify(event, null, 2));
  
  // Your logic
};
```

### Verify Eligibility

Check why a hook isn't eligible:

```bash
openclaw hooks info my-hook
```

Look for missing requirements in the output:

- Binaries (check PATH)
- Environment variables
- Config values
- OS compatibility

## Testing

### Gateway Logs

Monitor gateway logs to see hook execution:

```bash
# macOS
./scripts/clawlog.sh -f

# Other platforms
tail -f ~/.openclaw/gateway.log
```

Filter for hook-related logs:

```bash
# macOS
./scripts/clawlog.sh | grep hook

# Other platforms
tail -f ~/.openclaw/gateway.log | grep hook
```

### Test Hooks Directly

Test your handlers in isolation:

```typescript
import { test } from "vitest";
import myHandler from "./hooks/my-hook/handler.js";

test("my handler works", async () => {
  const event = {
    type: "command",
    action: "new",
    sessionKey: "test-session",
    timestamp: new Date(),
    messages: [],
    context: { 
      workspaceDir: "/tmp/test-workspace",
      commandSource: "test"
    },
  };

  await myHandler(event);

  // Assert side effects
  expect(event.messages).toContain("✨ My hook executed!");
});
```

### Manual Testing Workflow

1. **Verify hook is discovered**:
   ```bash
   openclaw hooks list
   ```

2. **Enable the hook**:
   ```bash
   openclaw hooks enable my-hook
   ```

3. **Restart your gateway process**:
   - Menu bar app restart on macOS
   - Restart your dev process
   - Or: `openclaw gateway restart`

4. **Check gateway logs for registration**:
   ```
   Registered hook: my-hook -> command:new
   ```

5. **Trigger the event**:
   - Send `/new` via your messaging channel
   - Or use the CLI to simulate

6. **Check logs for execution**:
   ```
   [my-hook] Triggered: command new
   ```

## Troubleshooting

### Hook Not Discovered

1. Check directory structure:
   ```bash
   ls -la ~/.openclaw/hooks/my-hook/
   # Should show: HOOK.md, handler.ts
   ```

2. Verify HOOK.md format:
   ```bash
   cat ~/.openclaw/hooks/my-hook/HOOK.md
   # Should have YAML frontmatter with name and metadata
   ```

3. List all discovered hooks:
   ```bash
   openclaw hooks list
   ```

4. Check for YAML syntax errors:
   ```bash
   # Look for invalid YAML in frontmatter
   # Common issues: missing colons, incorrect indentation
   ```

### Hook Not Eligible

Check requirements:
```bash
openclaw hooks info my-hook
```

Look for missing:
- Binaries (check PATH with `which node`)
- Environment variables (check with `echo $VAR_NAME`)
- Config values (check `~/.openclaw/config.json`)
- OS compatibility (check `metadata.openclaw.requires.os`)

Fix missing requirements or update the hook's metadata.

### Hook Not Executing

1. Verify hook is enabled:
   ```bash
   openclaw hooks list
   # Should show ✓ next to enabled hooks
   ```

2. Restart your gateway process so hooks reload.

3. Check gateway logs for errors:
   ```bash
   ./scripts/clawlog.sh | grep hook
   ```

4. Verify event type matches:
   - Check `metadata.openclaw.events` in HOOK.md
   - Check what events the handler actually listens for

### Handler Errors

Check for TypeScript/import errors:

```bash
# Test import directly (Node.js 20+)
node -e "import('./path/to/handler.ts').then(console.log).catch(console.error)"
```

Common issues:
- Missing type imports
- Incorrect file paths
- Syntax errors
- Missing dependencies

### No Messages Showing Up

If `event.messages.push()` isn't working:

1. Verify you're pushing strings, not objects
2. Check that the event flow completes
3. Look for errors in gateway logs
4. Verify the hook is actually being called

### Performance Issues

If your hook is slow:

1. Use fire-and-forget for slow operations
2. Move heavy processing to background
3. Check for unnecessary work
4. Profile your handler
5. Consider batching operations

## Quick Debug Checklist

When a hook isn't working:

- [ ] Is the hook discovered? (`openclaw hooks list`)
- [ ] Is the hook enabled? (✓ in list output)
- [ ] Is the hook eligible? (`openclaw hooks info my-hook`)
- [ ] Have you restarted the gateway?
- [ ] Are the events in metadata correct?
- [ ] Is the handler listening for the right events?
- [ ] Are there errors in the gateway logs?
- [ ] Is your handler actually being called? (Add debug logging)
- [ ] Are you handling errors in your handler?
