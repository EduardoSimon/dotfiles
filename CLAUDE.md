## Claude Settings Management

### Base vs Private Settings
Claude Code settings are split into two files:
- **`settings.base.json`** (tracked in dotfiles): Contains public, shareable settings like plugins, keybindings, and UI preferences
- **`settings.json`** (not tracked): Contains private settings like AWS profiles, credentials, and personal configurations

The private `settings.json` is merged with `settings.base.json` at runtime. This allows you to:
- Share common settings across machines via dotfiles
- Keep sensitive information out of version control
- Maintain machine-specific configurations

### What Goes Where
**Base settings** (public):
- Model preferences
- Default modes
- Enabled plugins
- UI configurations
- Notification hooks
- Tmux keybinding announcements

**Private settings** (not tracked):
- AWS profiles and auth commands
- Environment variables with credentials
- Machine-specific paths
- Custom status line commands

