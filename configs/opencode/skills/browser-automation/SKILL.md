---
name: browser-automation
description: Control web browsers using tappi CLI. Start browsers with remote debugging, navigate pages, interact with elements, fill forms, capture screenshots, and automate web workflows. Use when you need to browse websites, test web apps, or extract web data.
---

# Browser Automation with Tappi CLI

Automate browser interactions using the tappi CLI, which connects to Chrome/Brave via Chrome DevTools Protocol (CDP).

## Prerequisites

### 1. Start the Browser

**Brave (Recommended)**
```bash
brave --remote-debugging-port=9222 --user-data-dir=$HOME/.tappi-data &
```

**Chrome**
```bash
google-chrome --remote-debugging-port=9222 --user-data-dir=$HOME/.tappi-data &
```

**Important:**
- Use `--user-data-dir` to maintain sessions, cookies, and logins
- Port 9222 is the default CDP port
- Run in background with `&` or in a separate terminal
- Only one browser instance can use a port at a time

---

## Core Workflow

### 1. Navigation

```bash
# Navigate to URL
uvx tappi open https://example.com

# Get current URL
uvx tappi url

# Go back/forward
uvx tappi back
uvx tappi forward

# Refresh page
uvx tappi refresh
```

### 2. Find Elements

```bash
# List all interactive elements (links, buttons, inputs)
uvx tappi elements

# List elements matching the selector
uvx tappi elements [selector]
```

**Output:** Returns numbered list of elements with indices for clicking/typing.

### 3. Interact with Elements

```bash
# Focus element without triggering click
uvx tappi focus 5

# Read current value of element
# Returns: {value, char_count, has_focus}
uvx tappi check 5
```

```bash
# Click element by index (from tappi elements output)
uvx tappi click 5

# Type short text into input
uvx tappi type 3 "hello@example.com"

# Paste long content (emails, comments, posts)
uvx tappi paste 7 "Long text content..."

# Or paste from file
uvx tappi paste 7 --file message.txt

# Upload file
uvx tappi upload [path] [selector]
```

**Smart Features:**
- `tappi type`: Auto-focuses, clears, types, verifies (for short fields)
- `tappi paste`: Handles everything + JS fallback (for long content)
- `tappi click`: Auto-re-indexes if page changed, reports what happened

### 4. Extract Information

```bash
# Get visible text from page
uvx tappi text

# Extract from specific element
uvx tappi text [selector]

# Get HTML of element
uvx tappi html [selector]

# Take screenshot
uvx tappi screenshot [path]
```

### 5. Wait and Timing

```bash
# Wait for milliseconds
uvx tappi wait 2000  # Wait 2 seconds

# Use after navigation-triggering actions
uvx tappi click 5
uvx tappi wait 1500  # Wait for page load
```

---

## Advanced Features

### Tab Management

```bash
# List all open tabs
uvx tappi tabs

# Switch to tab by index
uvx tappi tab 2

# Open new tab
uvx tappi newtab https://example.com

# Close tab (current if no index)
uvx tappi close 2
```

### Low-Level Interactions

**For canvas apps (Google Sheets, Docs, Figma):**

```bash
# Send keyboard events (bypasses DOM, works on canvas)
uvx tappi keys "Revenue" --tab "Q1" --tab "Q2" --enter

# Keyboard shortcuts
uvx tappi keys --combo "cmd+b"  # Bold (Mac)
uvx tappi keys --combo "ctrl+a" --delete  # Select all + delete

# Navigation keys
uvx tappi keys --up --down --left --right
uvx tappi keys --enter --tab --escape --space

# Custom delay per character
uvx tappi keys --delay 50 "slow typing"
```

**Coordinate-based interactions:**

```bash
# Click at specific coordinates
uvx tappi click-xy 150 300

# Double-click
uvx tappi click-xy 150 300 --double-click

# Right-click
uvx tappi click-xy 150 300 --right-click

# Hover
uvx tappi hover-xy 150 300

# Drag
uvx tappi drag-xy 100 200 300 400
```

**For cross-origin iframes:**

```bash
# Get iframe position and size
uvx tappi iframe-rect "iframe#captcha"

# Then click inside iframe using coordinates (parse output for center_x, center_y)
uvx tappi click-xy <center_x> <center_y>
```


### Execute JavaScript

```bash
# Run arbitrary JavaScript
uvx tappi eval "document.title"

# More complex example
uvx tappi eval "Array.from(document.querySelectorAll('.item')).map(el => el.textContent)"
```

---

## Best Practices

1. **Always wait after navigation** - Pages need time to load
2. **Use `--grep` to filter elements** - More reliable than index guessing
3. **Prefer `tappi paste` for long content** - More reliable than type
4. **Use `tappi keys` for canvas apps** - Only way to interact with canvas
5. **Handle dynamic content** - Re-query elements after page changes
6. **Verify with screenshots** - Visual confirmation of success
7. **Use persistent profile** - `--user-data-dir` keeps logins/cookies

---

## Quick Reference

| Action | Command | Example |
|--------|---------|---------|
| Navigate | `uvx tappi open` | `uvx tappi open https://site.com` |
| Find elements | `uvx tappi elements` | `uvx tappi elements --grep "login"` |
| Click | `uvx tappi click` | `uvx tappi click 5` |
| Type (short) | `uvx tappi type` | `uvx tappi type 3 "hello"` |
| Paste (long) | `uvx tappi paste` | `uvx tappi paste 3 "..."` |
| Extract text | `uvx tappi text` | `uvx tappi text --grep "success"` |
| Screenshot | `uvx tappi screenshot` | `uvx tappi screenshot` |
| Wait | `uvx tappi wait` | `uvx tappi wait 2000` |
| Execute JS | `uvx tappi eval` | `uvx tappi eval "..."` |

---

## Troubleshooting

### Browser won't start

```bash
# Check if port is already in use
lsof -i :9222

# Kill existing process
kill -9 <PID>

# Or use different port
brave --remote-debugging-port=9223 --user-data-dir=$Home/.tappi-data &
```

### Can't find element

```bash
# Wait for page to load
uvx tappi wait 2000

# Try different selectors
uvx tappi elements "button"
uvx tappi elements ".btn-primary"

# Use grep for text search
uvx tappi elements | grep "submit"
```

### Click doesn't work

```bash
# Try using coordinates (get via eval)
uvx tappi eval "document.querySelector('#button').getBoundingClientRect()"

# Then click at coordinates
uvx tappi click-xy <x> <y>

# Or try JavaScript click
uvx tappi eval "document.querySelector('#button').click()"
```

### Focus issues

```bash
# Manually focus element
uvx tappi focus 5

# Then retry typing
uvx tappi type 5 "content"
```

---

## Resources

- **Chrome DevTools Protocol**: https://chromedevtools.github.io/devtools-protocol/
- **Tappi CLI**: Run `uvx tappi --help` for command reference
