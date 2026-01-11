# Tmux Shortcuts Reference Guide

**Prefix Key:** `Ctrl+a` (configured in your setup)

## 📋 Copy Mode & Pagination

### Entering and Navigating Copy Mode
- `Ctrl+a [` or `Ctrl+a Enter` - Enter copy mode (scroll/search mode)
- `q` or `Esc` - Exit copy mode
- `g` - Go to top of history
- `G` - Go to bottom of history
- `Ctrl+u` - Page up (half page)
- `Ctrl+d` - Page down (half page)
- `Ctrl+b` - Page up (full page)
- `Ctrl+f` - Page down (full page)

### Searching in Copy Mode
- `/` - Search forward
- `?` - Search backward
- `n` - Next match
- `N` - Previous match

### Selecting and Copying Text
- `v` - Start selection (visual mode)
- `Ctrl+v` - Toggle rectangle selection
- `y` - Copy selection and exit copy mode
- `H` - Move to start of line
- `L` - Move to end of line
- `Ctrl+a p` - Paste from tmux buffer

### Buffer Management
- `Ctrl+a b` - List all paste buffers
- `Ctrl+a P` (capital P) - Choose which buffer to paste from

## 🪟 Window Management

### Creating and Closing
- `Ctrl+a c` - Create new window
- `Ctrl+a &` - Kill current window (no confirmation prompt)
- `Ctrl+a ,` - Rename current window

### Navigation
- `Ctrl+a n` or `Ctrl+a Ctrl+l` - Next window
- `Ctrl+a p` or `Ctrl+a Ctrl+h` - Previous window
- `Ctrl+a 0-9` - Switch to window by number
- `Ctrl+a Tab` - Switch to last active window
- `Ctrl+a w` - Choose window from list

## 📐 Pane Management

### Splitting Panes
- `Ctrl+a -` - Split horizontally (new pane below)
- `Ctrl+a _` - Split vertically (new pane to the right)

### Navigation Between Panes
- `Ctrl+a h` - Move to left pane
- `Ctrl+a j` - Move to down pane
- `Ctrl+a k` - Move to up pane
- `Ctrl+a l` - Move to right pane
- `Ctrl+a q` - Show pane numbers (then press number to jump)
- `Ctrl+a o` - Cycle through panes

### Resizing Panes
- `Ctrl+a H` - Resize pane left by 2 units
- `Ctrl+a J` - Resize pane down by 2 units
- `Ctrl+a K` - Resize pane up by 2 units
- `Ctrl+a L` - Resize pane right by 2 units
(Hold prefix and repeat direction key for continuous resizing)

### Managing Panes
- `Ctrl+a x` - Kill current pane (no confirmation prompt)
- `Ctrl+a z` - Toggle pane zoom (fullscreen)
- `Ctrl+a +` - Maximize current pane
- `Ctrl+a !` - Break pane into new window
- `Ctrl+a >` - Swap with next pane
- `Ctrl+a <` - Swap with previous pane
- `Ctrl+a Space` - Toggle between layouts

## 🎯 Session Management

### Session Operations
- `Ctrl+a d` - Detach from session
- `Ctrl+a $` - Rename current session
- `Ctrl+a s` - List all sessions (interactive)
- `Ctrl+a (` - Switch to previous session
- `Ctrl+a )` - Switch to next session
- `Ctrl+a Shift+Tab` - Switch to last session

### Creating Sessions
- `Ctrl+a Ctrl+c` - Create new session
- `tmux new -s <name>` - Create named session (from terminal)
- `tmux attach -t <name>` - Attach to session (from terminal)

### Finding Sessions
- `Ctrl+a Ctrl+f` - Find and switch to session by name

## ⚙️ Configuration & System

### Tmux Commands
- `Ctrl+a :` - Enter command mode
- `Ctrl+a r` - Reload tmux configuration
- `Ctrl+a e` - Edit tmux local configuration
- `Ctrl+a ?` - Show all key bindings
- `Ctrl+a t` - Show clock

### Mouse Support
- `Ctrl+a m` - Toggle mouse mode on/off
- When mouse is enabled:
  - Click to select pane
  - Drag pane borders to resize
  - Scroll to enter copy mode and navigate
  - Double-click to select word
  - Triple-click to select line

### Display and Information
- `Ctrl+a i` - Display pane info
- `Ctrl+a Ctrl+l` - Clear screen and history

## 🔌 Plugin Management (TPM)

- `Ctrl+a I` (capital I) - Install plugins
- `Ctrl+a u` - Update plugins
- `Ctrl+a Alt+u` - Uninstall/clean plugins

## 💡 Pro Tips

### History & Performance
- Your history limit: **10,000 lines**
- Use copy mode to search through scrollback efficiently
- Clear history when needed: `Ctrl+a Ctrl+l`

### Copy/Paste Workflow
1. Enter copy mode: `Ctrl+a [`
2. Navigate to text (use `/` to search)
3. Start selection: `v`
4. Move cursor to select text
5. Copy: `y` (automatically exits copy mode)
6. Paste: `Ctrl+a p`

### Quick Pane Layout
- Create 3-pane development setup:
  1. `Ctrl+a -` (split horizontal)
  2. `Ctrl+a _` (split vertical on bottom)
  3. `Ctrl+a k` (move to top pane)

### Session Management Best Practices
- Name sessions by project: `tmux new -s myproject`
- Use `Ctrl+a s` to see all sessions at a glance
- Detach instead of closing when switching context

## 🎨 Visual Indicators

Your tmux shows these indicators in the status bar:
- **⌨** - Prefix key is active
- **↗** - Mouse mode enabled
- **⚇** - Multiple clients attached
- **⚏** - Panes synchronized
- **!** - Running as root (bold/blinking)

## 🖱️ Mouse Mode Features

With mouse mode enabled (default in your config):
- **Select text** - Click and drag to select (auto-enters copy mode)
- **Copy text** - After selecting, release mouse to copy
- **Paste** - Middle-click or `Ctrl+a p`
- **Switch panes** - Click on any pane
- **Resize panes** - Click and drag pane borders
- **Switch windows** - Click window names in status bar
- **Scroll history** - Use mouse wheel (auto-enters copy mode)

## ⌨️ Keyboard Navigation Tips

### Fast Window Switching
Instead of cycling through windows, jump directly:
- `Ctrl+a 1`, `Ctrl+a 2`, etc. for direct access
- `Ctrl+a '` then type window number for windows > 9

### Efficient Pane Navigation
- Use `Ctrl+a q` + number for instant pane jumping
- Set up vi-mode keys for even faster navigation (optional)

### Command History
In command mode (`Ctrl+a :`):
- `↑`/`↓` - Navigate through command history
- `Tab` - Auto-complete commands

---

**Quick Reference Card:**
```
PREFIX = Ctrl+a

Copy Mode:  [        Search:  / ?     Panes:  - _ hjkl    Windows:  c n p
Exit Copy:  q Esc    Select:  v y     Zoom:   z           Sessions: d s
Navigate:   hjkl     Paste:   p       Kill:   x &         Config:   r e
```

**Remember:** Most commands require pressing the prefix (`Ctrl+a`) first, then the command key!
