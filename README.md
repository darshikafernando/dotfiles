# Dotfiles

Zsh configuration with Oh My Zsh, Powerlevel10k, and useful plugins. Designed for devcontainers.

## Quick Install

```bash
./install.sh
```

Then open a new terminal to start using zsh.

## What's Included

**Shell & Theme**
- [zsh](https://www.zsh.org/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) (Pure style)

**Plugins**
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Fish-like autosuggestions
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - Syntax highlighting for commands
- [autojump](https://github.com/wting/autojump) - Quick directory navigation

**Aliases**
| Alias | Command |
|-------|---------|
| `ll` | `ls -la` |
| `la` | `ls -A` |
| `l` | `ls -CF` |

## Customization

- Edit `~/.zshrc` for shell configuration
- Run `p10k configure` to customize the prompt
- Edit `~/.p10k.zsh` for manual prompt tweaks

## Requirements

- Linux with `apt` package manager
- `sudo` access
- `curl` and `git`
