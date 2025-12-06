# Claude-GLM Wrapper

> ## 🙏 This project is forked from [JoeInnsp23/claude-glm-wrapper](https://github.com/JoeInnsp23/claude-glm-wrapper)
>
> Full credit goes to **JoeInnsp23** for the original implementation. This fork includes bug fixes and modifications.

---

Use [Z.AI's GLM models](https://z.ai) with [Claude Code](https://www.anthropic.com/claude-code) — **without losing your existing Claude setup!**

Switch freely between multiple AI providers: GLM, OpenAI, Gemini, OpenRouter, and Anthropic Claude.

## Why This Wrapper?

**💰 Cost-effective**: Access to multiple providers with competitive pricing
**🔄 Risk-free**: Your existing Claude Code setup remains completely untouched
**⚡ Multiple options**: Two modes - dedicated wrappers or multi-provider proxy
**🔀 In-session switching**: With ccx, switch models without restarting
**🎯 Perfect for**: Development, testing, or when you want model flexibility

## Quick Start

### macOS / Linux / WSL2
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/windysky/claude-glm-wrapper/main/install.sh)
source ~/.zshrc  # or ~/.bashrc
```

### Windows (PowerShell)
```powershell
iwr -useb https://raw.githubusercontent.com/windysky/claude-glm-wrapper/main/install.ps1 | iex
. $PROFILE
```

After installation, commands also work in `cmd.exe`/Anaconda prompt via auto-created `.cmd` shims.

## Features

- 🚀 **Easy switching** between GLM and Claude models
- ⚡ **Multiple GLM models**: GLM-4.6 (latest), GLM-4.5, and GLM-4.5-Air (fast)
- 🔒 **No sudo/admin required**: Installs to user's home directory
- 🖥️ **Cross-platform**: Works on Windows, macOS, and Linux
- 📁 **Isolated configs**: Each model uses its own config directory — no conflicts!
- 🔧 **Shell aliases**: Quick access with simple commands

## Prerequisites

1. **Claude Code**: Install from [anthropic.com/claude-code](https://www.anthropic.com/claude-code)
2. **Z.AI API Key**: Get your free key from [z.ai/manage-apikey/apikey-list](https://z.ai/manage-apikey/apikey-list)
3. **Node.js** (v18+): Required for ccx multi-provider proxy - [nodejs.org](https://nodejs.org/)

## Installation

### macOS / Linux / WSL2

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/windysky/claude-glm-wrapper/main/install.sh)
source ~/.zshrc  # or ~/.bashrc
```

```bash
git clone https://github.com/windysky/claude-glm-wrapper.git
cd claude-glm-wrapper
bash install.sh
source ~/.zshrc
```

### Windows (PowerShell)

> ⚠️ **Do NOT use Git Bash or WSL** with `install.sh` on Windows. It creates files in virtual Unix paths that Windows cannot access. Always use PowerShell.

```powershell
iwr -useb https://raw.githubusercontent.com/windysky/claude-glm-wrapper/main/install.ps1 | iex
. $PROFILE
```

```powershell
git clone https://github.com/windysky/claude-glm-wrapper.git
cd claude-glm-wrapper
.\install.ps1
. $PROFILE
```

**Note:** If you get an execution policy error, run:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

**Anaconda/cmd:** Run the PowerShell installer once (as above). It now creates `.cmd` shims in `AppData\Local\Microsoft\WindowsApps`, so `ccg46`, `ccg45`, `ccf`, and `ccx` work in `cmd.exe` and Anaconda prompts.

### What the Installer Does

- Checks if Claude Code is installed
- Asks for your Z.AI API key
- Creates wrapper scripts in `~/.local/bin/`
- Adds convenient aliases to your shell profile
- Optionally installs ccx multi-provider proxy

## Usage

### Start Using GLM Models

```bash
ccg46            # Claude Code with GLM-4.6 (latest)
ccg45            # Claude Code with GLM-4.5
ccf              # Claude Code with GLM-4.5-Air (faster)
ccd              # Regular Claude Code (default)
```

### Available Commands & Aliases

The installer creates these commands and aliases:

| Alias | Full Command | What It Does | When to Use |
|-------|--------------|--------------|-------------|
| `ccd` | `claude` | Regular Claude Code | Default - your normal Claude setup |
| `ccg46` | `claude-glm` | GLM-4.6 (latest) | Best quality GLM model |
| `ccg45` | `claude-glm-4.5` | GLM-4.5 | Previous version of GLM |
| `ccf` | `claude-glm-fast` | GLM-4.5-Air (fast) | Quicker responses, lower cost |
| `ccx` | `ccx` | Multi-provider proxy | Switch between providers in-session |

**💡 Tip**: Use the short aliases! They're faster to type and easier to remember.

**🆕 New: ccx Multi-Provider Proxy**

The `ccx` command starts a local proxy that lets you switch between multiple AI providers in a single session:
- **OpenAI**: GPT-4o, GPT-4o-mini, and more
- **OpenRouter**: Access to hundreds of models
- **Google Gemini**: Gemini 1.5 Pro and Flash
- **Z.AI GLM**: GLM-4.6, GLM-4.5, GLM-4.5-Air
- **Anthropic**: Claude 3.5 Sonnet, etc.

Switch models mid-session using `/model <provider>:<model-name>`. Perfect for comparing responses or using the right model for each task!

### How It Works

Each command starts a **separate Claude Code session** with different configurations:
- `ccg46`, `ccg45`, and `ccf` use Z.AI's API with your Z.AI key
- `ccd` uses Anthropic's API with your Anthropic key (default Claude setup)
- Your configurations **never conflict** — they're stored in separate directories

### Basic Examples

**Start a coding session with the latest GLM:**
```bash
ccg46
# Opens Claude Code using GLM-4.6
```

**Use GLM-4.5:**
```bash
ccg45
# Opens Claude Code using GLM-4.5
```

**Need faster responses? Use the fast model:**
```bash
ccf
# Opens Claude Code using GLM-4.5-Air
```

**Use regular Claude:**
```bash
ccd
# Opens Claude Code with Anthropic models (your default setup)
```

**Pass arguments like normal:**
```bash
ccg46 --help
ccg46 "refactor this function"
ccf "quick question about Python"
```

## More Documentation

For detailed documentation on workflows, configuration, troubleshooting, and more, please refer to the original repository:

📖 **[JoeInnsp23/claude-glm-wrapper](https://github.com/JoeInnsp23/claude-glm-wrapper)**

### Quick Reference

| Topic | Link |
|-------|------|
| Common Workflows | [Workflows](https://github.com/JoeInnsp23/claude-glm-wrapper#common-workflows) |
| Using ccx (Multi-Provider Proxy) | [ccx Guide](https://github.com/JoeInnsp23/claude-glm-wrapper#using-ccx-multi-provider-proxy) |
| Configuration Details | [Configuration](https://github.com/JoeInnsp23/claude-glm-wrapper#configuration-details) |
| Troubleshooting | [Troubleshooting](https://github.com/JoeInnsp23/claude-glm-wrapper#troubleshooting) |
| Uninstallation | [Uninstall](https://github.com/JoeInnsp23/claude-glm-wrapper#uninstallation) |
| FAQ | [FAQ](https://github.com/JoeInnsp23/claude-glm-wrapper#faq) |

---

## Changes in This Fork

This fork includes the following modifications:

- **Bug Fix**: ccx proxy now properly installs npm dependencies (`fastify`, `dotenv`, `eventsource-parser`, `tsx`)
- **Security Fix**: Fixed command injection vulnerability in error reporting
- **Alias Renaming**: `cc` → `ccd`, `ccg` → `ccg46` for clarity

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- 🙏 **[JoeInnsp23](https://github.com/JoeInnsp23)** for the original [claude-glm-wrapper](https://github.com/JoeInnsp23/claude-glm-wrapper)
- 🙏 [Z.AI](https://z.ai) for providing GLM model API access
- 🙏 [Anthropic](https://anthropic.com) for Claude Code
