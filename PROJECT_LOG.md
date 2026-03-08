# Project Log

Session 2026-02-11 21:45 CST
- Coding CLI used: OpenCode
- Phase(s) worked on
  - GLM model update: add GLM-5 support; keep GLM-4.7; remove GLM-4.5/4.6 commands
  - Removal: delete ccx multi-provider proxy entirely
- Concrete changes implemented
  - Updated wrappers/aliases so:
    - `ccg5` uses GLM-5 with config dir `~/.claude-glm-5/` (Windows: `%USERPROFILE%\.claude-glm-5`)
    - `ccg47` uses GLM-4.7 with config dir `~/.claude-glm-47/` (Windows: `%USERPROFILE%\.claude-glm-47`)
    - Removed `ccg45`/`ccg46` commands and references
  - Removed `ccx` completely:
    - Deleted proxy code and ccx binaries
    - Removed ccx installer prompts/logic and documentation
    - Removed proxy-related deps/scripts from `package.json`
- Files/modules/functions touched
  - Modified:
    - `.gitignore`
    - `README.md`
    - `install.sh`
    - `install.ps1`
    - `package.json`
  - Deleted:
    - `bin/ccx`
    - `bin/ccx.ps1`
    - `adapters/` (all files under this directory)
    - `tsconfig.json`
- Key technical decisions and rationale
  - ccx removal includes removing all proxy build/runtime artifacts to keep the project focused on simple wrapper scripts.
  - Windows installer uses `claude-glm.ps1` for GLM-5 (latest) and introduces `claude-glm-4.7.ps1` for `ccg47` to keep stable config isolation.
- Problems encountered and resolutions
  - Local `npm install` is blocked by design (npx-only preinstall guard). Verification performed via script syntax checks and content search.
- Items explicitly completed, resolved, or superseded in this session
  - Completed: GLM-5 support + `ccg5`
  - Completed: Removed GLM-4.5/4.6 commands (`ccg45`, `ccg46`)
  - Completed: Removed ccx completely
- Verification performed (if any)
  - `bash -n install.sh` (pass)
  - Grep for `ccx` / `claude-proxy` in key files (no matches)

Session 2026-02-11 21:48 CST
- Coding CLI used: OpenCode
- Phase(s) worked on
  - Project history consolidation
- Concrete changes implemented
  - Imported the legacy `CHANGELOG.md` content into this file (verbatim)
  - Deleted `CHANGELOG.md`
- Files/modules/functions touched
  - Modified: `PROJECT_LOG.md`
  - Deleted: `CHANGELOG.md`
- Key technical decisions and rationale
  - Keep a single append-only history source (`PROJECT_LOG.md`) and avoid maintaining two parallel change history files.
- Problems encountered and resolutions
  - None.
- Items explicitly completed, resolved, or superseded in this session
  - Completed: CHANGELOG consolidation
- Verification performed (if any)
  - None.

---

Imported from `CHANGELOG.md` (verbatim)

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.3] - 2025-10-01

### Changed
- Removed global installation support - npx only
- Updated preinstall script to block ALL installation methods (local and global)
- Clearer error messaging emphasizing npx as the only supported method

## [1.0.2] - 2025-10-01

### Added
- Preinstall check to prevent incorrect installation method
- Error message directing users to use `npx` instead of `npm i`
- Support for global installation with `-g` flag

### Changed
- Installation now blocks when users try `npm i claude-glm-installer` locally
- Improved user guidance for correct installation method

## [1.0.1] - 2025-10-01

### Changed
- Updated package description to include npx usage instructions
- Clarified installation method in npm package listing

## [1.0.0] - 2025-10-01

### Added
- Windows PowerShell support with full feature parity
- Cross-platform npm package installer (`npx claude-glm-installer`)
- Automatic detection and cleanup of old wrapper installations
- GLM-4.6 model support as new default
- GLM-4.5 wrapper (ccg45) for backward compatibility
- Universal bootstrap script for OS auto-detection
- Comprehensive Windows documentation and troubleshooting
- Platform-specific installation paths and configuration
- Bash installer for Unix/Linux/macOS
- Support for GLM-4.5 and GLM-4.5-Air models
- Isolated configuration directories per model
- Shell aliases (ccg, ccg45, ccf, cc)
- No sudo/admin required installation
- Wrapper scripts in ~/.local/bin
- Z.AI API key integration
- Separate chat histories per model
- Error reporting system with GitHub issue integration
- Test mode for error reporting (`--test-error` flag)
- Debug mode (`--debug` flag)
- User consent prompts for error reporting

### Changed
- Updated default model from GLM-4.5 to GLM-4.6
- Renamed aliases: removed `cca`, kept `cc` for regular Claude
- Improved installation flow with old wrapper detection
- Enhanced README with collapsible platform-specific sections
- Updated cross-platform support documentation

### Fixed
- PATH conflicts when multiple wrapper installations exist
- Version mismatches from old wrapper files
- Installation detection across different locations
- PowerShell parsing errors when piping through `iex`
- Nested here-string issues in PowerShell
- Subexpression parsing errors in piped contexts
- Terminal/PowerShell window persistence after errors

[Unreleased]: https://github.com/windysky/claude-glm-wrapper/compare/v1.0.3...HEAD
[1.0.3]: https://github.com/windysky/claude-glm-wrapper/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/windysky/claude-glm-wrapper/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/windysky/claude-glm-wrapper/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/windysky/claude-glm-wrapper/releases/tag/v1.0.0

Session 2026-02-11 21:54 CST
- Coding CLI used: OpenCode
- Phase(s) worked on
  - Installer alias enhancements
- Concrete changes implemented
  - Added new convenience aliases for danger-skip-permissions:
    - Unix: ensure these are added as `alias` entries in `~/.bashrc` (and also in detected shell rc file):
      - `ccg47D='ccg47 --dangerously-skip-permissions'`
      - `ccg47Dd='ccg47 --dangerously-skip-permissions -d'`
      - `ccg5D='ccg5 --dangerously-skip-permissions'`
      - `ccg5Dd='ccg5 --dangerously-skip-permissions -d'`
    - Windows:
      - Added PowerShell profile functions with the same names
      - Added `.cmd` shims (argument-capable) for `ccg47D`, `ccg47Dd`, `ccg5D`, `ccg5Dd`
- Files/modules/functions touched
  - Modified:
    - `install.sh`
    - `install.ps1`
    - `PROJECT_HANDOFF.md`
    - `PROJECT_LOG.md`
- Key technical decisions and rationale
  - PowerShell `Set-Alias` cannot include fixed arguments, so the Windows implementation uses functions in the user profile.
  - `.cmd` shims are used on Windows so these commands also work in `cmd.exe`/Anaconda prompts.
- Problems encountered and resolutions
  - Pre-commit hook flagged memo-style comments in `install.sh`; removed those comments.
- Items explicitly completed, resolved, or superseded in this session
  - Completed: danger-skip alias support across Unix and Windows installers
- Verification performed (if any)
  - `bash -n install.sh` (pass)

Session 2026-02-11 21:59 CST
- Coding CLI used: OpenCode
- Phase(s) worked on
  - Installer UX for upgrades
- Concrete changes implemented
  - Added a new upgrade-path option when an existing installation is detected:
    - "Reset wrappers/aliases using existing API key" (no API key prompt if the key can be read from existing wrapper/settings)
  - Updated "Update API key only" to also refresh wrappers and alias/shim definitions so new commands (e.g. `ccg5`, danger-skip aliases) appear after upgrade.
- Files/modules/functions touched
  - Modified:
    - `install.sh`
    - `install.ps1`
    - `PROJECT_HANDOFF.md`
    - `PROJECT_LOG.md`
- Key technical decisions and rationale
  - The Z.AI key is read from existing wrapper scripts first (and config `settings.json` as fallback) to avoid requiring re-entry.
  - Windows mirrors the Unix behavior with a PowerShell helper (`Get-ExistingZaiApiKey`).
- Problems encountered and resolutions
  - None.
- Items explicitly completed, resolved, or superseded in this session
  - Completed: reset-with-existing-key installer option
- Verification performed (if any)
  - `bash -n install.sh` (pass)

Session 2026-03-08
- Coding CLI used: Claude Code
- Phase(s) worked on
  - Restore GLM-4.5 support and expand danger-skip aliases
- Concrete changes implemented
  - Added `create_claude_glm_45_wrapper()` function (bash) and `New-ClaudeGlm45Wrapper` (PowerShell)
  - Added GLM-4.5 config dir `~/.claude-glm-45/` (Windows: `%USERPROFILE%\.claude-glm-45`)
  - Added 7 new aliases across both installers:
    - `ccdD='claude --dangerously-skip-permissions'`
    - `ccdDd='claude --dangerously-skip-permissions -d'`
    - `claudeD='claude --dangerously-skip-permissions'`
    - `claudeDd='claudeD -d'`
    - `ccg45='claude-glm-4.5'`
    - `ccg45D='ccg45 --dangerously-skip-permissions'`
    - `ccg45Dd='ccg45 --dangerously-skip-permissions -d'`
  - Updated alias cleanup in both installers to handle all new aliases
  - Removed GLM-4.5 from deprecated artifact removal in PowerShell installer
  - Added `ccg45`, `ccg45D`, `ccg45Dd` CMD shims for Windows
  - Updated README with new model and alias documentation
  - Bumped version from 2.0.0 to 2.1.0
- Files/modules/functions touched
  - Modified: `install.sh`, `install.ps1`, `package.json`, `README.md`, `PROJECT_HANDOFF.md`, `PROJECT_LOG.md`
- Key technical decisions and rationale
  - GLM-4.5 restored per user request despite previous Phase 2 removal
  - `claudeD`/`ccdD` aliases provide danger-skip for plain Claude (non-GLM) usage
- Problems encountered and resolutions
  - None
- Items explicitly completed, resolved, or superseded in this session
  - Completed: GLM-4.5 wrapper restoration
  - Completed: Claude danger-skip aliases (ccdD, ccdDd, claudeD, claudeDd)
  - Completed: GLM-4.5 danger-skip aliases (ccg45D, ccg45Dd)
  - Superseded: Phase 2 removal of GLM-4.5 commands
- Verification performed (if any)
  - `bash -n install.sh` (pass)
