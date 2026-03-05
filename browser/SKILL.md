---
name: browser
description: "Control OpenClaw-managed Chrome/Brave/Edge/Chromium browser. Use for opening tabs, reading pages, clicking, typing, taking screenshots, and more."
license: Apache-2.0
compatibility: "Requires OpenClaw Gateway with browser support enabled"
metadata:
  author: OpenClaw
  version: "1.0"
  category: browser-automation
---

# Browser Skill

Control an OpenClaw-managed Chrome/Brave/Edge/Chromium browser for automation tasks.

## Quick Start

### Check Browser Status

Check if browser is enabled and running.

### Start Browser

Start the browser if it's not running.

### Open a URL

Open a URL in a new tab.

### Take Screenshot

Take a screenshot of the current page (full page or viewport).

### Take Snapshot

Take an interactive snapshot of the page for element selection.

### Click Element

Click an element using ref from snapshot.

### Type Text

Type text into an input field using ref from snapshot.

### Press Key

Press a keyboard key (Enter, Escape, etc.).

### Wait

Wait for text, URL, load state, or JS predicate.

## Profiles

- `openclaw`: Managed, isolated browser (no extension required)
- `chrome`: Extension relay to your system browser (requires OpenClaw extension attached to a tab)

## References

- Official documentation: https://docs.openclaw.ai/tools/browser
- Chrome extension guide: https://docs.openclaw.ai/tools/chrome-extension
