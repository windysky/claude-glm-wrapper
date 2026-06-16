# Claude-GLM Wrapper

> ## 🙏 This project is forked from [JoeInnsp23/claude-glm-wrapper](https://github.com/JoeInnsp23/claude-glm-wrapper)
>
> Full credit goes to **JoeInnsp23** for the original implementation. This fork includes bug fixes and modifications.

---

Use [Z.AI's GLM models](https://z.ai) with [Claude Code](https://www.anthropic.com/claude-code) — **without losing your existing Claude setup!**

## Why This Wrapper?

**💰 Cost-effective**: Access to multiple providers with competitive pricing
**🔄 Risk-free**: Your existing Claude Code setup remains completely untouched
**⚡ Multiple options**: Dedicated wrappers for different models
**🎯 Perfect for**: Development, testing, or when you want model flexibility

## Features

- 🚀 **Easy switching** between GLM and Claude models
- ⚡ **Multiple GLM models**: GLM-5.2 (default, 1M context), GLM-5.1, GLM-5-Turbo, GLM-5, GLM-4.7, GLM-4.6, GLM-4.5, GLM-4.5V (vision), and GLM-4.5-Air (fast)
- 🔒 **No sudo/admin required**: Installs to user's home directory
- 🖥️ **Cross-platform**: Works on Windows, macOS, and Linux
- 📁 **Isolated configs**: Each model uses its own config directory — no conflicts!
- 🔧 **Shell aliases**: Quick access with simple commands

## Prerequisites

1. **Claude Code**: Install from [anthropic.com/claude-code](https://www.anthropic.com/claude-code)
2. **Z.AI API Key**: Get your free key from [z.ai/manage-apikey/apikey-list](https://z.ai/manage-apikey/apikey-list)

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

**Anaconda/cmd:** Run the PowerShell installer once (as above). It now creates `.cmd` shims in `AppData\Local\Microsoft\WindowsApps`, so `ccg`, `ccgD`, `ccgDd`, `ccg52`, `ccg51`, `ccg5t`, `ccg5`, `ccg47`, `ccg46`, `ccg45`, `ccg45v`, `ccg45air`, and `ccf` work in `cmd.exe` and Anaconda prompts.

### What the Installer Does

- Checks if Claude Code is installed
- Asks for your Z.AI API key
- Creates wrapper scripts in `~/.local/bin/`
- Adds convenient aliases to your shell profile
- Adds `~/.local/bin/` (or `%USERPROFILE%\.local\bin` on Windows) to your PATH and updates the current session; warns if it still isn't available

## Usage

### Start Using GLM Models

```bash
claude           # Regular Claude Code (Anthropic) — untouched by this installer
ccg              # Claude Code with GLM-5.2 (default GLM model, 1M context)
ccgD             # ccg --dangerously-skip-permissions
ccg52            # Claude Code with GLM-5.2 (same as ccg)
ccg51            # Claude Code with GLM-5.1
ccg5t            # Claude Code with GLM-5-Turbo
ccg5             # Claude Code with GLM-5
ccg47            # Claude Code with GLM-4.7
ccg46            # Claude Code with GLM-4.6
ccg45            # Claude Code with GLM-4.5
ccg45v           # Claude Code with GLM-4.5V (vision)
ccg45air         # Claude Code with GLM-4.5-Air (cheap/fast)
ccf              # Alias for GLM-4.5-Air
```

### Available Commands & Aliases

The installer creates these commands and aliases. **The installer only manages GLM aliases — your `claude` command and any `ccd`/`ccdD`/`claudeD` aliases for the regular Anthropic Claude Code CLI are left untouched, so you can manage them yourself.**

| Alias | Full Command | What It Does | When to Use |
|-------|--------------|--------------|-------------|
| `ccg` | `claude-glm-5.2` | **GLM-5.2 (default, 1M context)** | Recommended default — shortest alias, points at the latest GLM model with 1M-token context |
| `ccgD` | `ccg --dangerously-skip-permissions` | GLM-5.2 (skip permissions) | Default GLM with auto-approved tool calls |
| `ccg52` | `claude-glm-5.2` | GLM-5.2 (same as `ccg`) | Explicit version alias |
| `ccg51` | `claude-glm-5.1` | GLM-5.1 | Explicit version alias |
| `ccg5t` | `claude-glm-5-turbo` | GLM-5-Turbo | Faster variant of GLM-5 family |
| `ccg5` | `claude-glm-5` | GLM-5 | Previous latest GLM model |
| `ccg47` | `claude-glm-4.7` | GLM-4.7 | Stable GLM version |
| `ccg46` | `claude-glm-4.6` | GLM-4.6 | GLM-4.6 point release |
| `ccg45` | `claude-glm-4.5` | GLM-4.5 | Older GLM version |
| `ccg45v` | `claude-glm-4.5v` | GLM-4.5V (vision) | Multimodal / image understanding |
| `ccg45air` | `claude-glm-4.5-air` | GLM-4.5-Air | Cheap/fast lightweight model |
| `ccf` | `claude-glm-fast` | GLM-4.5-Air | Shortcut alias for the cheap/fast model |

Each GLM alias also has variant suffixes:
- `D` / `Dd` → `--dangerously-skip-permissions` (and `-d` debug), e.g. `ccgD`, `ccg52Dd`
- `A` → `--permission-mode auto` (auto mode), e.g. `ccgA`, `ccg52A`

These apply to every GLM alias: `ccgD/Dd/A`, `ccg52D/Dd/A`, `ccg51D/Dd/A`, `ccg5tD/Dd/A`, `ccg5D/Dd/A`, `ccg47D/Dd/A`, `ccg46D/Dd/A`, `ccg45D/Dd/A`, `ccg45vD/Dd/A`, `ccg45airD/Dd/A`.

**Model tiers:** each wrapper maps Claude Code's Opus and Sonnet tiers to its own GLM model and the Haiku (background/fast) tier to `glm-4.5-air`, following Z.AI's recommended Claude Code configuration. The default `ccg`/`ccg52` wrapper uses `glm-5.2[1m]` for the 1M-token context window (with `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000`).

**Note on availability:** Not every model is included in every Z.ai billing plan. The repo ships with `smoke_test_models.sh` — run it to see which models your key can actually hit.

**💡 Tip**: Use the short aliases! They're faster to type and easier to remember.

### How It Works

Each command starts a **separate Claude Code session** with different configurations:
- `ccg`, `ccg52`, `ccg51`, `ccg5t`, `ccg5`, `ccg47`, `ccg46`, `ccg45`, `ccg45v`, `ccg45air`, and `ccf` use Z.AI's API with your Z.AI key
- `claude` (and any `ccd`/`ccdD`/`claudeD` aliases you set up yourself) uses Anthropic's API with your Anthropic key — completely untouched by this installer
- Your configurations **never conflict** — they're stored in separate directories

### Basic Examples

**Start a coding session with the latest GLM (default):**
```bash
ccg
# Opens Claude Code using GLM-5.2 (1M context)
```

**Use GLM-4.7:**
```bash
ccg47
# Opens Claude Code using GLM-4.7
```

**Need faster responses? Use the fast model:**
```bash
ccf
# Opens Claude Code using GLM-4.5-Air
```

**Use regular Claude (your existing setup, not managed by this installer):**
```bash
claude
# Opens Claude Code with Anthropic models (your default setup)
```

**Pass arguments like normal:**
```bash
ccg47 --help
ccg47 "refactor this function"
ccf "quick question about Python"
```

## More Documentation

For detailed documentation on workflows, configuration, troubleshooting, and more, please refer to the original repository:

📖 **[JoeInnsp23/claude-glm-wrapper](https://github.com/JoeInnsp23/claude-glm-wrapper)**

### Quick Reference

| Topic | Link |
|-------|------|
| Common Workflows | [Workflows](https://github.com/JoeInnsp23/claude-glm-wrapper#common-workflows) |
| Configuration Details | [Configuration](https://github.com/JoeInnsp23/claude-glm-wrapper#configuration-details) |
| Troubleshooting | [Troubleshooting](https://github.com/JoeInnsp23/claude-glm-wrapper#troubleshooting) |
| Uninstallation | [Uninstall](https://github.com/JoeInnsp23/claude-glm-wrapper#uninstallation) |
| FAQ | [FAQ](https://github.com/JoeInnsp23/claude-glm-wrapper#faq) |

---

## Changes in This Fork

This fork includes the following modifications:

- **Security Fix**: Fixed command injection vulnerability in error reporting
- **Alias Update**: new short `ccg` is the default (GLM-5.2, 1M context); plus `ccg52`, `ccg51`, `ccg5t`, `ccg5`, `ccg47`, `ccg46`, `ccg45`, `ccg45v`, `ccg45air` for explicit versions
- **Default GLM alias**: `ccg` → `claude-glm-5.2` (latest GLM, `glm-5.2[1m]` with 1M context); `ccgD` → `ccg --dangerously-skip-permissions`
- **Model Update**: GLM-5.2 is the latest and the new default; `ccf` maps to GLM-4.5-Air (previous `glm-4.7-flashx` target is off most billing plans and returned HTTP 429)
- **Tier mapping**: each wrapper now sets `ANTHROPIC_DEFAULT_OPUS_MODEL` and `ANTHROPIC_DEFAULT_SONNET_MODEL` to its own GLM model and `ANTHROPIC_DEFAULT_HAIKU_MODEL` to `glm-4.5-air`, per Z.AI's recommended Claude Code configuration (replacing the prior `ANTHROPIC_MODEL` + `ANTHROPIC_SMALL_FAST_MODEL` scheme)
- **Claude untouched**: this installer no longer creates or removes `ccd`/`ccdD`/`claudeD`/`claudeDd` aliases; the bare `claude` command and any aliases you set up yourself for it are left alone
- **Danger-skip aliases**: per-model `D`/`Dd` variants for every GLM alias
- **Smoke test**: `smoke_test_models.sh` included to verify which models your Z.ai key can reach

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- 🙏 **[JoeInnsp23](https://github.com/JoeInnsp23)** for the original [claude-glm-wrapper](https://github.com/JoeInnsp23/claude-glm-wrapper)
- 🙏 [Z.AI](https://z.ai) for providing GLM model API access
- 🙏 [Anthropic](https://anthropic.com) for Claude Code
