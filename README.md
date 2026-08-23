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
- ⚡ **Multiple GLM models**: GLM-5.3 (default, 1M context), GLM-5-Turbo, GLM-4.7, GLM-4.6, GLM-4.5, and GLM-4.5V (vision) — the base model ID behind each shipped wrapper is verified to serve itself, not a silent stand-in
- 🔒 **No sudo/admin required**: Installs to user's home directory
- 🖥️ **Cross-platform**: Works on Windows, macOS, and Linux
- 📁 **Isolated configs**: Each model uses its own config directory — no conflicts!
- 🔧 **Shell aliases**: Quick access with simple commands

## Prerequisites

1. **Claude Code**: Install from [anthropic.com/claude-code](https://www.anthropic.com/claude-code)
2. **Z.AI API Key**: Get your free key from [z.ai/manage-apikey/apikey-list](https://z.ai/manage-apikey/apikey-list)

## Installation

### Any platform (npx)

Runs the right installer for your OS — no clone, no global install:

```bash
npx @windysky/claude-glm-installer
```

This package is npx-only by design: `npm install -g` is refused, so you always
run the current version rather than a stale copy.

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

**Anaconda/cmd:** Run the PowerShell installer once (as above). It now creates `.cmd` shims in `AppData\Local\Microsoft\WindowsApps`, so `ccg`, `ccgD`, `ccgDd`, `ccgA`, `ccg53`, `ccg5t`, `ccg47`, `ccg46`, `ccg45`, and `ccg45v` work in `cmd.exe` and Anaconda prompts.

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
ccg              # Claude Code with GLM-5.3 (default GLM model, 1M context)
ccgD             # ccg --dangerously-skip-permissions
ccg53            # Claude Code with GLM-5.3 (same as ccg)
ccg5t            # Claude Code with GLM-5-Turbo
ccg47            # Claude Code with GLM-4.7
ccg46            # Claude Code with GLM-4.6
ccg45            # Claude Code with GLM-4.5
ccg45v           # Claude Code with GLM-4.5V (vision)
```

### Available Commands & Aliases

The installer creates these commands and aliases. **The installer only manages GLM aliases — your `claude` command and any `ccd`/`ccdD`/`claudeD` aliases for the regular Anthropic Claude Code CLI are left untouched, so you can manage them yourself.**

| Alias | Full Command | What It Does | When to Use |
|-------|--------------|--------------|-------------|
| `ccg` | `claude-glm-5.3` | **GLM-5.3 (default, 1M context)** | Recommended default — shortest alias, points at the latest GLM model with 1M-token context |
| `ccgD` | `ccg --dangerously-skip-permissions` | GLM-5.3 (skip permissions) | Default GLM with auto-approved tool calls |
| `ccg53` | `claude-glm-5.3` | GLM-5.3 (same as `ccg`) | Explicit version alias |
| `ccg5t` | `claude-glm-5-turbo` | GLM-5-Turbo | Faster, lighter model — note it burns 2–3× plan quota per prompt |
| `ccg47` | `claude-glm-4.7` | GLM-4.7 | Stable GLM version |
| `ccg46` | `claude-glm-4.6` | GLM-4.6 | GLM-4.6 point release |
| `ccg45` | `claude-glm-4.5` | GLM-4.5 | Older GLM version |
| `ccg45v` | `claude-glm-4.5v` | GLM-4.5V (vision) | Multimodal / image understanding |

Each GLM alias also has variant suffixes:
- `D` / `Dd` → `--dangerously-skip-permissions` (and `-d` debug), e.g. `ccgD`, `ccg53Dd`
- `A` → `--permission-mode auto` (auto mode), e.g. `ccgA`, `ccg53A`

These apply to every GLM alias: `ccgD/Dd/A`, `ccg53D/Dd/A`, `ccg5tD/Dd/A`, `ccg47D/Dd/A`, `ccg46D/Dd/A`, `ccg45D/Dd/A`, `ccg45vD/Dd/A`.

**Model tiers:** each wrapper maps Claude Code's Opus and Sonnet tiers to its own GLM model, and the Haiku (background/fast) tier to `glm-4.7`. The default `ccg`/`ccg53` wrapper uses `glm-5.3[1m]` for the 1M-token context window (with `CLAUDE_CODE_AUTO_COMPACT_WINDOW=900000`, ~250K headroom below the 1M ceiling).

### Retired aliases (and why)

Z.AI **silently reroutes** retired model IDs: a request still returns HTTP 200, but a *different* model answers. Verified against the live API on 2026-08-16:

| You ask for | What actually answers |
|-------------|----------------------|
| `glm-5.2`, `glm-5.1`, `glm-5` | **`glm-5.3`** |
| `glm-4.5-air` | **`glm-4.7`** |

Because a wrapper named after those IDs no longer runs the model its name promises, `ccg52`, `ccg51`, `ccg5`, `ccg45air` and `ccf` have been removed. Re-running the installer deletes their wrapper scripts and strips their aliases from your shell rc file. Their config directories (`~/.claude-glm-52` etc.) are **left alone** — they hold your own session state, not installer output.

If you used one of these, the replacement is: `ccg52`/`ccg51`/`ccg5` → **`ccg`** (or `ccg53`), and `ccg45air`/`ccf` → **`ccg47`**.

**Note on availability:** not every model is in every Z.ai billing plan, and reachability alone is not proof a model is real. `smoke_test_models.sh` compares the model you request against the model that answers, and reports `PASS` / `UNKNOWN` / `REROUTED` / `FAIL` accordingly.

**What "verified" covers:** the smoke test probes base model IDs (`glm-5.3`), not the bracketed context-route form the wrappers send (`glm-5.3[1m]`). The bracket suffix is a Claude Code routing convention that the client translates before the request leaves your machine — the raw API rejects it outright with `HTTP 400 [1214][modelCode: does not exist]` — so the `[1m]` variant cannot be probed directly. What is verified is that the base model ID each wrapper is built on serves itself instead of being rerouted.

**💡 Tip**: Use the short aliases! They're faster to type and easier to remember.

### How It Works

Each command starts a **separate Claude Code session** with different configurations:
- `ccg`, `ccg53`, `ccg5t`, `ccg47`, `ccg46`, `ccg45`, and `ccg45v` use Z.AI's API with your Z.AI key
- `claude` (and any `ccd`/`ccdD`/`claudeD` aliases you set up yourself) uses Anthropic's API with your Anthropic key — completely untouched by this installer
- Your configurations **never conflict** — they're stored in separate directories

### Basic Examples

**Start a coding session with the latest GLM (default):**
```bash
ccg
# Opens Claude Code using GLM-5.3 (1M context)
```

**Use GLM-4.7:**
```bash
ccg47
# Opens Claude Code using GLM-4.7
```

**Need faster responses? Use the turbo model:**
```bash
ccg5t
# Opens Claude Code using GLM-5-Turbo (note: 2–3× plan quota per prompt)
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
ccg "quick question about Python"
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
- **Alias Update**: short `ccg` is the default (GLM-5.3, 1M context); plus `ccg53`, `ccg5t`, `ccg47`, `ccg46`, `ccg45`, `ccg45v` for explicit versions
- **Default GLM alias**: `ccg` → `claude-glm-5.3` (`glm-5.3[1m]` with 1M context); `ccgD` → `ccg --dangerously-skip-permissions`
- **Consolidated to models that actually serve themselves**: Z.AI silently reroutes retired IDs (`glm-5.2`/`glm-5.1`/`glm-5` → `glm-5.3`, `glm-4.5-air` → `glm-4.7`) while still returning HTTP 200, so wrappers named after them were misleading. `ccg52`, `ccg51`, `ccg5`, `ccg45air` and `ccf` are removed, and re-running the installer cleans up their scripts and aliases
- **Tier mapping**: each wrapper sets `ANTHROPIC_DEFAULT_OPUS_MODEL` and `ANTHROPIC_DEFAULT_SONNET_MODEL` to its own GLM model and `ANTHROPIC_DEFAULT_HAIKU_MODEL` to `glm-4.7` (the model that answers a `glm-4.5-air` request anyway)
- **Claude untouched**: this installer no longer creates or removes `ccd`/`ccdD`/`claudeD`/`claudeDd` aliases; the bare `claude` command and any aliases you set up yourself for it are left alone
- **Danger-skip and auto-mode aliases**: per-model `D`/`Dd`/`A` variants for every GLM alias
- **Safer alias cleanup**: the installer removes an alias only when the alias name **and its full definition** match a line it generated, so your own alias of the same name pointing somewhere else survives a re-run. That preserves the *line*, not the *binding*: the managed block is appended below yours and shell aliases are last-definition-wins, so a colliding name still resolves to the installer's target at runtime — rename your alias if you want it to keep taking effect
- **Smoke test**: `smoke_test_models.sh` compares the model you request against the model that actually answers, reporting `PASS` / `UNKNOWN` / `REROUTED` / `FAIL` — a status code alone cannot detect a silent substitution

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- 🙏 **[JoeInnsp23](https://github.com/JoeInnsp23)** for the original [claude-glm-wrapper](https://github.com/JoeInnsp23/claude-glm-wrapper)
- 🙏 [Z.AI](https://z.ai) for providing GLM model API access
- 🙏 [Anthropic](https://anthropic.com) for Claude Code
