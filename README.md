# Mac config backup

Snapshot of dotfiles and tool configs from this machine.

**Generated:** 2026-07-02

## Layout

| Path | Source |
|------|--------|
| `dotfiles/` | Shell, git, and home-level dotfiles (`~/.zshrc`, `~/.gitconfig`, etc.) |
| `.config/yabai/` | Yabai window manager (`~/.config/yabai/`) |
| `.config/skhd/` | skhd hotkeys + helper scripts (`~/.config/skhd/`) |
| `.config/karabiner/` | Karabiner-Elements (`~/.config/karabiner/`) |
| `.hammerspoon/` | Hammerspoon Lua config |
| `.cursor/` | Cursor rules, skills, MCP config (secrets redacted) |
| `cursor/` | Cursor/VS Code `settings.json` and `keybindings.json` |
| `.spicetify/` | Spicetify themes and config |
| `.config/zed/` | Zed editor settings |
| `.config/neofetch/`, `.config/nnn/` | Terminal utilities |
| `.config/gh/config.yml` | GitHub CLI preferences (no auth tokens) |
| `library/Preferences/` | iTerm2, Raycast, Hammerspoon, Karabiner plists |
| `Brewfile` | Homebrew packages (`brew bundle dump`) |

## Intentionally excluded

- **Secrets:** `~/.ssh/`, `gh/hosts.yml`, API keys in `mcp.json` (redacted copy included)
- **Cookies/tokens:** yt-dlp cookies, 1Password CLI config, perplexity token
- **Cache/state:** Cursor projects/chats, configstore, Karabiner automatic backups
- **Installed apps, not config:** Raycast extensions (~500MB), superpowers git worktrees (~1GB)

## Restore examples

```bash
# Yabai + skhd
cp -r .config/yabai ~/.config/yabai
cp -r .config/skhd ~/.config/skhd
yabai --restart-service
skhd --restart-service

# Shell
cp dotfiles/.zshrc dotfiles/.zprofile ~/. 

# Karabiner
cp .config/karabiner/karabiner.json ~/.config/karabiner/

# Homebrew
brew bundle --file=Brewfile
```

## Notes

- Live yabai config is `~/.config/yabai/yabairc`. The `~/.yabairc` stub in `dotfiles/` is ignored when that file exists.
- skhd config is `~/.config/skhd/skhdrc` (no `~/.skhdrc` on this machine).
- After restoring `.cursor/mcp.json`, paste API keys back from your live copy.
