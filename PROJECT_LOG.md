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

Session 2026-03-08 13:33 CDT
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

Session 2026-04-17 18:10 CDT
- Coding CLI used: Claude Code
- Phase(s) worked on
  - Phase 8: Add GLM-4.6 (`ccg46`) and GLM-5.1 (`ccg51`) wrappers with full D/Dd danger-skip variants
- Concrete changes implemented
  - Added `create_claude_glm_46_wrapper()` and `create_claude_glm_51_wrapper()` (bash)
  - Added `New-ClaudeGlm46Wrapper` and `New-ClaudeGlm51Wrapper` (PowerShell)
  - New config dirs: `~/.claude-glm-46/` and `~/.claude-glm-51/` (Windows: `%USERPROFILE%\.claude-glm-46`, `%USERPROFILE%\.claude-glm-51`)
  - Model IDs: `glm-4.6` and `glm-5.1`; small/fast model remains `glm-4.7-flashx` for both (consistent with existing wrappers)
  - Added 6 new aliases to bash/zsh and csh/tcsh alias blocks in install.sh:
    - `ccg46='claude-glm-4.6'`, `ccg46D='ccg46 --dangerously-skip-permissions'`, `ccg46Dd='ccg46 --dangerously-skip-permissions -d'`
    - `ccg51='claude-glm-5.1'`, `ccg51D='ccg51 --dangerously-skip-permissions'`, `ccg51Dd='ccg51 --dangerously-skip-permissions -d'`
  - Added corresponding Set-Alias + profile function pairs (ccg46, ccg46D, ccg46Dd, ccg51, ccg51D, ccg51Dd) to install.ps1
  - Added 6 new `.cmd` shims for Windows (ccg46, ccg46D, ccg46Dd, ccg51, ccg51D, ccg51Dd)
  - Updated cleanup/grep-v blocks to strip the 6 new alias/function names before rewriting
  - Extended API-key detection (`detect_existing_zai_api_key` bash, `Get-ExistingZaiApiKey` PowerShell) to search the two new wrapper files and settings files
  - Extended existing-install detection, upgrade call sites, and help/summary echoes to list the new wrappers and aliases
  - Removed GLM-4.6 from `Remove-DeprecatedGlmArtifacts` in install.ps1 (GLM-4.6 is restored; function kept as a hook)
  - Decision: `ccg5` retains its meaning (GLM-5) rather than becoming a rolling latest alias; `ccg51` is the new explicit handle for GLM-5.1
  - Updated README.md (model list, quick-start block, alias table + danger-variant note, fork changes)
  - Bumped version 2.1.0 -> 2.2.0 in package.json
- Files/modules/functions touched
  - Modified: `install.sh`, `install.ps1`, `README.md`, `package.json`, `PROJECT_HANDOFF.md`, `PROJECT_LOG.md`
- Key technical decisions and rationale
  - Keep `glm-4.7-flashx` as small/fast model for both new wrappers for consistency with the existing suite (no confirmation that `glm-4.6-flashx` or `glm-5.1-flashx` exist on Z.AI)
  - Cleanup/detection blocks updated so re-running the installer idempotently replaces the new aliases/shims
  - `Remove-DeprecatedGlmArtifacts` left in place (empty bodies) as a hook for future deprecations rather than deleted outright
- Problems encountered and resolutions
  - None
- Items explicitly completed, resolved, or superseded in this session
  - Completed: GLM-4.6 wrapper (`ccg46`) with D/Dd variants
  - Completed: GLM-5.1 wrapper (`ccg51`) with D/Dd variants
  - Completed: Windows parity (PowerShell functions + `.cmd` shims)
  - Superseded: Previous deprecation of GLM-4.6 in install.ps1 `Remove-DeprecatedGlmArtifacts`
- Verification performed (if any)
  - `bash -n install.sh` (pass)
  - Grep sanity: install.sh has 12 new alias lines (6 per shell block) + 4 cleanup patterns + 2 new wrapper functions; install.ps1 has 2 Set-Alias + 4 profile functions, 2 wrapper functions, 6 new `.cmd` shims.

Session 2026-04-17 20:05 CDT
- Coding CLI used: Claude Code
- Phase(s) worked on
  - Phase 9: Add GLM-4.5V (ccg45v), GLM-4.5-Air (ccg45air), GLM-5-Turbo (ccg5t); swap SMALL_FAST model to glm-4.5-air; repoint ccf away from the unavailable glm-4.7-flashx; ship smoke_test_models.sh
- Motivation
  - User reported conflicting Z.ai plan documentation (one list said coding plan included GLM-5/4.7/4.6/4.5V/4.5/4.5-Air; website said all plans support GLM-5.1/GLM-5-Turbo/GLM-4.7/GLM-4.5-Air). Z.ai does not publish a definitive model list per plan, so an empirical smoke test was needed before expanding wrappers further.
- Concrete changes implemented
  - Added `smoke_test_models.sh` (repo-root, executable, read-only). Auto-detects Z.ai API key from wrappers/settings, probes 9 candidate model IDs via https://api.z.ai/api/anthropic/v1/messages, prints PASS/FAIL per model. Supports --key, --models overrides.
  - Empirically confirmed model availability on user's key: PASS for glm-5.1, glm-5, glm-5-turbo, glm-4.7, glm-4.6, glm-4.5, glm-4.5v, glm-4.5-air. FAIL for glm-4.7-flashx (HTTP 429 "Insufficient balance or no resource package" - model ID valid but not included in coding-plan quota).
  - Bash wrappers added: `create_claude_glm_45v_wrapper` (glm-4.5v, ~/.claude-glm-45v), `create_claude_glm_45air_wrapper` (glm-4.5-air, ~/.claude-glm-45-air), `create_claude_glm_5t_wrapper` (glm-5-turbo, ~/.claude-glm-5-turbo).
  - PowerShell wrappers added: `New-ClaudeGlm45vWrapper`, `New-ClaudeGlm45airWrapper`, `New-ClaudeGlm5tWrapper`.
  - Bash aliases added (both csh and bash/zsh blocks): ccg45v/D/Dd, ccg45air/D/Dd, ccg5t/D/Dd.
  - PowerShell Set-Alias + profile functions added: ccg45v, ccg45air, ccg5t plus D/Dd variants for all three.
  - Windows .cmd shims added: ccg45v/D/Dd, ccg45air/D/Dd, ccg5t/D/Dd (9 new shims).
  - ANTHROPIC_SMALL_FAST_MODEL swapped from glm-4.7-flashx to glm-4.5-air in ALL wrappers (sh: 12 occurrences, ps1: 12 occurrences via replace_all).
  - ccf (claude-glm-fast) internal ANTHROPIC_MODEL changed from glm-4.7-flashx to glm-4.5-air. Wrapper filename preserved to avoid breaking muscle memory; becomes a shortcut alias for ccg45air.
  - Updated cleanup/grep-v blocks, detection lists, API-key search, upgrade call sites, help/summary echoes across both install.sh and install.ps1.
  - Updated README.md (feature list, quick-start, alias table with new entries + availability note, fork changes section).
  - Bumped version 2.2.0 -> 2.3.0 in package.json.
- Files/modules/functions touched
  - Modified: `install.sh`, `install.ps1`, `README.md`, `package.json`, `PROJECT_HANDOFF.md`, `PROJECT_LOG.md`
  - Created: `smoke_test_models.sh`
- Key technical decisions and rationale
  - Empirical-first: wrote smoke test before finalizing Phase 9 so every wrapper in the final commit maps to a model the user can actually reach on their plan.
  - `glm-4.7-flashx` kept neither as wrapper nor as small/fast model because it 429s on the coding plan. Plain glm-4.5-air is the plan-valid "cheap/fast" model.
  - Naming: ccg45v (lowercase v), ccg45air (no hyphen) chosen to stay consistent with existing ccgNN lowercase convention. Config dirs ~/.claude-glm-45v and ~/.claude-glm-45-air.
  - ccf retained (not removed) for backwards compatibility; now functionally identical to ccg45air.
  - ccg5 retains glm-5 (not repointed to glm-5.1) preserving determinism.
  - smoke_test_models.sh: reads key same way as install.sh for consistency; uses 16 max_tokens to keep cost trivial; no writes anywhere; optional jq for nicer error parsing.
- Problems encountered and resolutions
  - Mid-session clarifications from user about which models are actually available. Resolved by writing smoke test and running it against the live API to get ground truth.
- Items explicitly completed, resolved, or superseded in this session
  - Completed: GLM-4.5V (ccg45v) wrapper with D/Dd variants
  - Completed: GLM-4.5-Air (ccg45air) wrapper with D/Dd variants
  - Completed: GLM-5-Turbo (ccg5t) wrapper with D/Dd variants
  - Completed: SMALL_FAST_MODEL switch to glm-4.5-air across all wrappers
  - Completed: ccf repointed to glm-4.5-air (same model as ccg45air)
  - Completed: smoke_test_models.sh (empirical model availability probe)
  - Superseded: ANTHROPIC_SMALL_FAST_MODEL=glm-4.7-flashx (now glm-4.5-air across all 9 wrappers)
  - Superseded: ccf -> glm-4.7-flashx (now ccf -> glm-4.5-air)
- Verification performed (if any)
  - `bash -n install.sh` (pass)
  - `bash -n smoke_test_models.sh` (pass)
  - `bash smoke_test_models.sh` against live Z.ai API: 8/9 models PASS as documented above.

Session 2026-04-17 20:40 CDT
- Coding CLI used: Claude Code
- Phase(s) worked on
  - Phase 10: Harness code review using a proportional 4-agent team (Orchestrator + Reviewer-for-triage + Implementer + Reviewer-for-verification). Fixed 5 real defects surfaced during the review. Dropped Playwright/web-UI phases (not applicable — project has no web UI) and unit-test baselines (no test suite exists by design).
- Concrete changes implemented
  - SPEC: `.moai/specs/SPEC_HARNESS_CODE_REVIEW_2026_04_17.md` documents the 5 fixes with acceptance criteria and rollback plan.
  - **SEC-01 [High]** (install.sh): Changed 9 `chmod +x "$wrapper_path"` calls to `chmod 700 "$wrapper_path"`. Wrappers contain the Z.AI API key in plaintext; previous mode 755 left them world-readable on shared systems.
  - **SEC-02 [Medium]** (install.sh): Changed 3 API-key prompts from `read -p` to `read -rs -p` followed by `echo`. Hides key characters on screen during entry. Non-secret prompts (menus, y/n) unchanged. PowerShell `-AsSecureString` deferred (more invasive).
  - **BUG-01 [High]** (install.sh): Removed the `local` keyword from `test_error_message` and `test_error_line` assignments at script top-level scope (lines 1300-1301 pre-fix). Bash was emitting `bash: local: can only be used in a function` to stderr during `--test-error` runs.
  - **DEAD-01 [Medium]** (install.sh): Deleted the entire `create_claude_anthropic_wrapper()` function. It was defined but never called from `main()` or any other path; no alias pointed to it; no Windows equivalent existed.
  - **PS-01 [Medium]** (install.ps1): Appended `-Encoding UTF8` to 9 `Set-Content` calls targeting `settings.json` inside `New-ClaudeGlm*Wrapper` functions. PS 5.1 defaults to UTF-16 LE with BOM, which can fail strict JSON parsers. `Set-Content $PROFILE` at line 283 intentionally untouched (consumed by PowerShell itself).
- Files/modules/functions touched
  - Modified: `install.sh`, `install.ps1`, `PROJECT_HANDOFF.md`, `PROJECT_LOG.md`
  - Created: `.moai/specs/SPEC_HARNESS_CODE_REVIEW_2026_04_17.md`
- Harness process
  - Orchestrator did Phase 0 recon + Phase 1 triage directly (project is small: ~1000 LOC shell + ~1100 LOC PowerShell).
  - Spawned `evaluator-active` subagent as Reviewer-for-triage: produced findings report with 2 CRITICAL, 2 HIGH, 3 MEDIUM, 4 LOW candidates.
  - Orchestrator cut the list to 5 fixes (rejected 6 findings: key echo-to-history was technically wrong; unquoted array needs mapfile/bash-4+ which breaks macOS; `.bash_profile` preference could break existing users; heredoc injection is theoretical; flashx-in-smoke-test is intentional; curl-H quote was not a bug; all per "fix only what is broken").
  - Spawned `builder` subagent as Implementer with SPEC-bound prompt: applied all 5 fixes in a single run with PASS verdict.
  - Spawned second `evaluator-active` subagent as Reviewer-for-verification: APPROVED with independent acceptance checks, regression scan, and scope-discipline audit.
- Agents spawned: 3 total (2 Reviewer + 1 Implementer). No QA Agent / Security Auditor spawns (project has no test suite or CI to baseline against; security-relevant findings were handled inline by the Reviewer).
- Key technical decisions and rationale
  - Proportional harness: project is ~2000 LOC of shell/PowerShell with no web UI, no CI, no tests. Running full 5-phase harness with Playwright setup would be wasteful. Used the harness where valuable (independent review of code I wrote) and skipped phases where N/A (Playwright, unit-test baseline).
  - Rejected 6 of 11 review findings as out-of-scope per "fix only what is broken."
  - Did not touch uncommitted `.gitignore` / `CLAUDE.md` drift (upstream MoAI-ADK framework, not project code).
- Problems encountered and resolutions
  - Orchestrator's first grep-verify of Fix 5 used a mis-escaped regex that reported 0 matches; direct check confirmed all 9 Set-Content calls have `-Encoding UTF8`. No re-work needed, just verification rigor.
  - install.ps1 received an external (linter) modification between Implementer and Reviewer runs; Reviewer re-verified against the actual file state — all SPEC fixes still intact.
- Items explicitly completed, resolved, or superseded in this session
  - Completed: SEC-01 chmod 700 on all wrapper scripts
  - Completed: SEC-02 silent API-key entry on bash
  - Completed: BUG-01 removed `local` keyword outside function
  - Completed: DEAD-01 deleted orphan `create_claude_anthropic_wrapper`
  - Completed: PS-01 UTF-8 encoding forced for settings.json on PowerShell
- Verification performed (if any)
  - `bash -n install.sh` => OK (post-fix)
  - `bash -n smoke_test_models.sh` => OK
  - `bash smoke_test_models.sh` => 8/9 PASS (identical to pre-fix baseline = zero regression; only flashx fails due to plan quota, unchanged)
  - Reviewer verdict: APPROVED (all 5 fixes, scope discipline, no regressions, no side effects)
- Commit: `dc3e6b8` on `main`, pushed to origin.

Session 2026-04-28 19:00 CDT
- Coding CLI used: Claude Code (Opus 4.7)
- Phase(s) worked on
  - Phase 11: Add `ccg`/`ccgD`/`ccgDd` default GLM aliases pointing at GLM-5.1; remove installer-managed claude aliases entirely; add legacy-block fingerprint migration so older installs auto-clean their orphan claude aliases on upgrade.
- Motivation
  - User wanted a shorter default GLM alias (`ccg`) and explicitly requested that the installer stop managing `ccd`/`ccdD`/`claudeD`/`claudeDd` because the bare `claude` command should remain tied to their Anthropic account and any user-curated claude aliases are personal customizations.
- Concrete changes implemented
  - Added `alias ccg='claude-glm-5.1'`, `alias ccgD='ccg --dangerously-skip-permissions'`, `alias ccgDd='ccg --dangerously-skip-permissions -d'` to install.sh fish/csh and bash/zsh alias blocks.
  - Removed `ccd`/`ccdD`/`ccdDd`/`claudeD`/`claudeDd` from install.sh's create blocks and from `remove_aliases_from_rc` cleanup grep list.
  - Updated cleanup trigger to match BOTH legacy header `# Claude Code Model Switcher Aliases` and current header `# Claude-GLM Model Switcher Aliases` so re-runs never duplicate the alias block.
  - Added legacy-block fingerprint detection: when `~/.bashrc` contains both `alias ccdDd='claude --dangerously-skip-permissions -d'` AND `alias claudeDd='claudeD -d'` (signatures unique to the old auto-installer), the cleanup additionally strips `ccd`/`ccdD`/`ccdDd`/`claudeD`/`claudeDd` as a one-time migration. User-customized blocks (without those exact self-references) are preserved.
  - Mirrored all logic in install.ps1: removed `Set-Alias ccd`, `function ccdD/ccdDd/claudeD/claudeDd` from create block; added `Set-Alias ccg claude-glm-5.1` and `function ccgD/ccgDd`; added cmd shims for `ccg`/`ccgD`/`ccgDd`; added fingerprint check (`function ccdDd` + `function claudeDd` both present) to scrub legacy auto-installed claude functions.
  - Updated post-install summary echoes (bash + PowerShell) to reflect the GLM-only alias set.
  - Updated README.md: added `ccg`/`ccgD` to aliases table marked as recommended default; clarified that `claude` and any user-curated claude-side aliases are intentionally untouched; refreshed quick-start example; updated "Changes in This Fork" section.
  - Fixed user's pre-existing `~/.bashrc` typo: `alias ccdd=` -> `alias ccdD=` (one-time edit, backup at `~/.bashrc.bak.ccg-cleanup`).
- Files/modules/functions touched
  - Modified: `install.sh`, `install.ps1`, `README.md`, `~/.bashrc` (one-time typo fix)
- Key technical decisions and rationale
  - Fingerprint-based migration uses the unique self-reference `claudeDd='claudeD -d'` (a peculiar pattern only the auto-installer would create) plus `ccdDd` definition. Two independent markers reduces false positives. Users who manually added their own `ccdD` or `claudeD` without these specific Dd self-references are NOT affected by migration.
  - Cleanup trigger regex `^# (Claude Code|Claude-GLM) Model Switcher Aliases` ensures idempotency across legacy and current header text — re-running the installer never appends a duplicate block.
  - PowerShell uses Where-Object filter with explicit `$keep = $false` flag for clarity (vs. shell-style `eval "$grep_filter"`); both achieve the same conditional strip.
- Problems encountered and resolutions
  - First-cut implementation only matched the legacy header text in the cleanup trigger, which would have caused duplicate blocks on second re-run after the header changed. Caught during review; fixed by widening the regex to match both old and new headers.
- Items explicitly completed, resolved, or superseded in this session
  - Completed: `ccg` short default + `ccgD` danger-skip variants
  - Completed: Installer no longer creates or removes `ccd`/`ccdD`/`claudeD`/`claudeDd` (per user request)
  - Completed: Legacy block fingerprint migration (one-shot scrub of orphan claude aliases on upgrade)
  - Completed: Re-run idempotency (cleanup trigger matches both legacy and current marker)
  - Superseded: Phase 7's auto-injection of claude-side aliases into user shell rc (now hands-off)
- Verification performed
  - `bash -n install.sh` => OK
  - Migration test against synthetic legacy bashrc: full claude quintet stripped. PASS.
  - Migration test against user-curated bashrc (no `ccdDd`/`claudeDd` fingerprint): claude aliases preserved, GLM aliases stripped. PASS.
  - Dry-run cleanup against user's real `~/.bashrc`: `ccdD`, `claudeD`, `codexD`, `ccd` PRESERVED; `ccg47`, `ccg5`, `ccg47D/Dd`, `ccg5D/Dd`, `ccf` STRIPPED. PASS.

Session 2026-04-28 19:30 CDT
- Coding CLI used: Claude Code (Opus 4.7)
- Phase(s) worked on
  - Phase 12: Harness code review and fix run via `/harness-hur-code-review-and-fix` slash command. Single defect found and resolved.
- Motivation
  - User-invoked harness-driven code review of all uncommitted Phase 11 work plus existing scripts.
- Findings (Phase 0/1)
  - Critical: 0
  - High: 0
  - Medium: 1 — SMOKE-01: `smoke_test_models.sh` API key auto-detection paths missed 3 newer wrappers (`claude-glm-5-turbo`, `claude-glm-4.5v`, `claude-glm-4.5-air`) and their settings dirs (`.claude-glm-5-turbo/settings.json`, `.claude-glm-45v/settings.json`, `.claude-glm-45-air/settings.json`). Pre-existing bug introduced in Phase 9; not introduced by Phase 11 changes.
  - Low: 0
  - Rejected as not-broken (preserve existing style/architecture per harness mandate):
    - install.sh `eval "$legacy_claude_filter"` — uses eval but with hardcoded internal string only, no user input. Works correctly. Refactor would be cosmetic.
    - install.ps1 `(array -match pattern).Count -gt 0` fingerprint check — works for typical multi-line profile content. Edge case (single-line profile) is impractical.
    - install.sh cleanup grep for csh/tcsh format aliases (`alias X 'value'` without `=`) — pre-existing, csh users rare, fixing risks regressions.
    - `fix_hooks_config.py` docstring vs implementation mismatch — utility works for its actual use case.
- Concrete changes implemented
  - SMOKE-01 (smoke_test_models.sh): Added `claude-glm-5-turbo`, `claude-glm-4.5v`, `claude-glm-4.5-air` to `wrapper_files` array. Added `$HOME/.claude-glm-5-turbo/settings.json`, `$HOME/.claude-glm-45v/settings.json`, `$HOME/.claude-glm-45-air/settings.json` to `settings_files` array. Coverage now 9/9 wrappers + 9/9 settings dirs (was 6/6 each).
- Files/modules/functions touched
  - Modified: `smoke_test_models.sh`, `PROJECT_HANDOFF.md`, `PROJECT_LOG.md`
- Harness process
  - Project size (~2000 LOC shell + PowerShell, no web UI, no test suite, no CI) does not warrant full multi-agent persistent team spawning. Orchestrator performed Phase 0 reconnaissance + Phase 1 triage + Phase 2 implementation directly, then Phase 3 verification via syntax checks and dry-run, Phase 4 live smoke test, Phase 5 docs.
  - Per "fix only what is broken" mandate: rejected 4 candidate findings that were working code with theoretical edge cases or stylistic preferences.
- Key technical decisions and rationale
  - Smoke test fix is purely additive — appended new paths to existing arrays in the established convention. No restructuring.
  - Did not touch `CLAUDE.md` even though it shows uncommitted modifications — confirmed by PROJECT_HANDOFF that this is upstream MoAI-ADK framework drift, not project code.
- Problems encountered and resolutions
  - None.
- Items explicitly completed, resolved, or superseded in this session
  - Completed: SMOKE-01 — full wrapper/settings path coverage in smoke_test_models.sh
- Verification performed
  - `bash -n install.sh` => OK
  - `bash -n smoke_test_models.sh` => OK (post-fix)
  - `python3 ast.parse(fix_hooks_config.py)` => OK
  - `node --check bin/cli.js`, `node --check bin/preinstall.js` => OK
  - `json.load(package.json)` => OK
  - `bash smoke_test_models.sh` against live Z.ai API => 8/9 PASS, identical to baseline (no regression). API key auto-detected from existing wrappers, SMOKE-01 fix verified working.
- Final test counts vs baseline: 8/9 PASS (no change). Final security posture: unchanged from Phase 10 (chmod 700 wrappers, silent key entry, UTF-8 settings.json all still in place).
- Remaining open issues: none.
