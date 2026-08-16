# Project Handoff

## 1. Project Overview
- Purpose: Local wrapper/installer scripts to run Claude Code against Z.AI GLM models via per-model `CLAUDE_HOME` directories.
- Scope: Cross-platform install scripts + docs for `ccg` (GLM-5.3, default, 1M context), `ccg53` (GLM-5.3), `ccg5t` (GLM-5-Turbo), `ccg47` (GLM-4.7), `ccg46` (GLM-4.6), `ccg45` (GLM-4.5), and `ccg45v` (GLM-4.5V vision) — **6 wrappers, each verified to serve the model its name claims**. Each wrapper uses Z.AI's opus/sonnet/haiku tier scheme (opus+sonnet = its own model, haiku = glm-4.7). Installer manages GLM aliases only — the bare `claude` command and any user-curated `ccd`/`ccdD`/`claudeD` aliases are intentionally untouched.
- **Retired in Phase 17** (Z.AI silently reroutes these IDs while still returning HTTP 200): `ccg52`/`ccg51`/`ccg5` (served by glm-5.3), `ccg45air`/`ccf` (served by glm-4.7). The installer now deletes their wrapper scripts and strips their aliases on re-run.
- Last updated: 2026-08-16 08:50 CDT
- Last coding CLI used (informational): Claude Code (Opus 5)
- Current version: 2.5.0 (package.json)
- Latest commit on `main`: `a103f0b` (Phase 16: harness code review — settings.json chmod 600 + set-e guard + csh dedup, v2.4.2), pushed to origin. Recent lineage: `a103f0b` (Phase 16 review fixes) ← `a29600e` (Phase 15 auto-compact 900K) ← `d8c936d` (A variants) ← `7b2d009`/`92164c0` (remove redundant ./install bootstrap) ← `5e1eb62` (Phase 14 smart-dedup) ← `502411d` (Phase 13 GLM-5.2 + tier scheme). NOTE: the prior handoff incorrectly recorded `25ff837` as the tip; git history between that and Phase 13 also has `072a9c9` (Phase 11+12) plus a run of install.ps1 PS5.1 hardening commits (`ec387cb`, `4399507`, `03e7dfb`, `657b2c9`, `70ff1ff`) that were never logged in PROJECT_LOG.md. Those are pre-existing and left as-is.

## 2. Current State
- GLM-5 wrapper (`ccg5`): Completed
  - Completed in Session 2026-02-11 21:45 CST
- GLM-4.7 wrapper (`ccg47`): Completed
  - Completed in Session 2026-02-11 21:45 CST
- Removal of GLM-4.5 / GLM-4.6 commands: Completed
  - Completed in Session 2026-02-11 21:45 CST
- Removal of ccx multi-provider proxy: Completed
  - Completed in Session 2026-02-11 21:45 CST
- CHANGELOG consolidation into `PROJECT_LOG.md`: Completed
  - Completed in Session 2026-02-11 21:48 CST
- Danger-skip aliases for ccg5/ccg47: Completed
  - Completed in Session 2026-02-11 21:54 CST
- Installer update option to reset using existing API key: Completed
  - Completed in Session 2026-02-11 21:59 CST
- Restore GLM-4.5 wrapper + add Claude/model danger-skip aliases: Completed
  - Completed in Session 2026-03-08 13:33 CDT
- Add GLM-4.6 wrapper (`ccg46`) + GLM-5.1 wrapper (`ccg51`) with D/Dd variants: Completed
  - Completed in Session 2026-04-17 18:10 CDT
- Add GLM-4.5V (`ccg45v`), GLM-4.5-Air (`ccg45air`), GLM-5-Turbo (`ccg5t`) wrappers + smoke test + SMALL_FAST swap to glm-4.5-air: Completed
  - Completed in Session 2026-04-17 20:05 CDT
- Harness code review (4-agent: Orchestrator + Reviewer + Implementer + Reviewer) — SEC-01 chmod 700, SEC-02 read -rs, BUG-01 local-outside-fn, DEAD-01 orphan fn, PS-01 UTF-8 settings.json: Completed
  - Completed in Session 2026-04-17 20:40 CDT
- Add `ccg`/`ccgD`/`ccgDd` default GLM aliases pointing at GLM-5.1; remove claude-only alias creation/cleanup (installer no longer touches `ccd`, `ccdD`, `claudeD`, `claudeDd`); add legacy-block fingerprint migration (auto-scrub orphan claude aliases left by previous installer versions when both `ccdDd` and `claudeDd` self-references are detected); fix re-run duplicate bug (cleanup trigger now matches both legacy and current marker comments): Completed
  - Completed in Session 2026-04-28 19:00 CDT
- Harness code review fix — SMOKE-01: smoke_test_models.sh API key auto-detection extended to cover all 9 wrappers (added missing `claude-glm-5-turbo`, `claude-glm-4.5v`, `claude-glm-4.5-air` and their settings dirs): Completed
  - Completed in Session 2026-04-28 19:30 CDT
- Add GLM-5.2 wrapper (`ccg52`) as the new default (`ccg` repointed from GLM-5.1 to GLM-5.2 with `glm-5.2[1m]` 1M context + `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000`); migrate ALL wrappers from `ANTHROPIC_MODEL`+`ANTHROPIC_SMALL_FAST_MODEL` to the tier scheme `ANTHROPIC_DEFAULT_OPUS_MODEL`/`ANTHROPIC_DEFAULT_SONNET_MODEL`=own model, `ANTHROPIC_DEFAULT_HAIKU_MODEL`=glm-4.5-air (per Z.AI Claude Code doc); keep all existing wrappers; smoke test + README + version 2.4.0: Completed (commit `502411d`)
  - Completed in Session 2026-06-16 15:36 CDT
- bash alias write smart-dedup: write alias block to `~/.bashrc` only; for `~/.bashrc`-sourcing `~/.bash_profile`, strip any redundant installer block (de-dup on re-run); keep dual-write only when `~/.bash_profile` does NOT source `~/.bashrc` (login coverage). zsh/csh/PowerShell paths unchanged: Completed
  - Completed in Session 2026-06-16 15:36 CDT
- Add `A` (auto mode, `--permission-mode auto`) alias variant for every GLM alias (e.g. `ccgA`, `ccg52A`), alongside the existing `D`/`Dd` variants; mirrored in install.sh + install.ps1 + README; also fixed personal `~/.bashrc` `ccdA` (`--enable-auto-mode` → `--permission-mode auto`): Completed
  - Completed in Session 2026-06-16 16:13 CDT
- Lower GLM-5.2 wrapper `CLAUDE_CODE_AUTO_COMPACT_WINDOW` from 1000000 to 900000 (auto-compact fires ~747K, ~250K headroom below glm-5.2's 1M ceiling; fixes frequent "context over limit" errors). Used the WINDOW lever, not the flaky `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`. Only the 5.2 wrapper carries the var; install.sh + install.ps1 (both occurrences each) + README + v2.4.1; redeployed via `bash install.sh`: Completed (commit `a29600e`)
  - Completed in Session 2026-07-02 10:01 CDT
- Harness code review (harness-hur-code-review-and-fix) — 3 install.sh defects fixed: (SEC) `chmod 600` on the runtime-generated settings.json in all 10 wrappers (the plaintext API key was world-readable at 644 while wrappers were already 700); (BUG) `check_claude_installation || true` so the "continue anyway" path without `claude` no longer false-aborts under `set -eE`+ERR trap; (IDEMPOTENCY) csh space-format alias cleanup so `.cshrc` re-runs stop duplicating the alias block. install.ps1 unaffected (Unix-only exposure; PS path returns $false without throwing). v2.4.2; independently reviewed (evaluator-active) APPROVED: Completed (commit `a103f0b`)
  - Completed in Session 2026-07-03 00:57 CDT

- Add GLM-5.3 wrapper (`ccg53` + D/Dd/A) and consolidate the wrapper set to the 6 models that genuinely serve themselves; retire `ccg52`/`ccg51`/`ccg5`/`ccg45air`/`ccf`; haiku tier `glm-4.5-air` → `glm-4.7`; installer-side alias cleanup rewritten to full-line value-anchored matching; smoke test now detects silent model substitution; v2.5.0: Completed (uncommitted — see §7)
  - Completed in Session 2026-08-16 08:50 CDT

## 3. Execution Plan Status
- Phase 1: Add GLM-5 / adjust GLM-4.7 directories and mappings
  - Status: Completed
  - Last updated: 2026-02-11 21:45 CST
- Phase 2: Remove GLM-4.5/4.6 commands and documentation
  - Status: Completed
  - Last updated: 2026-02-11 21:45 CST
- Phase 3: Remove ccx (proxy + installers + docs + package deps)
  - Status: Completed
  - Last updated: 2026-02-11 21:45 CST
- Phase 4: Consolidate CHANGELOG into PROJECT_LOG
  - Status: Completed
  - Last updated: 2026-02-11 21:48 CST
- Phase 5: Add danger-skip aliases
  - Status: Completed
  - Last updated: 2026-02-11 21:54 CST
- Phase 6: Add reset-with-existing-key option
  - Status: Completed
  - Last updated: 2026-02-11 21:59 CST
- Phase 7: Restore GLM-4.5 + expand danger-skip aliases
  - Status: Completed
  - Last updated: 2026-03-08 13:33 CDT
- Phase 8: Add GLM-4.6 and GLM-5.1 wrappers + danger-skip variants
  - Status: Completed
  - Last updated: 2026-04-17 18:10 CDT
- Phase 9: Add GLM-4.5V, GLM-4.5-Air, GLM-5-Turbo wrappers; swap SMALL_FAST to glm-4.5-air; repoint ccf; ship smoke_test_models.sh
  - Status: Completed
  - Last updated: 2026-04-17 20:05 CDT
- Phase 10: Harness code review (SPEC_HARNESS_CODE_REVIEW_2026_04_17) — 5 surgical fixes across install.sh + install.ps1
  - Status: Completed
  - Last updated: 2026-04-17 20:40 CDT
- Phase 11: Add `ccg` default + drop installer-managed claude aliases + legacy migration
  - Status: Completed
  - Last updated: 2026-04-28 19:00 CDT
- Phase 12: Harness code review and fix — SMOKE-01 only (smoke_test_models.sh detection coverage)
  - Status: Completed
  - Last updated: 2026-04-28 19:30 CDT
- Phase 13: Add GLM-5.2 default (`ccg52`, `ccg`→5.2, 1M context) + tier-mapping migration across all wrappers + smoke test + README + v2.4.0
  - Status: Completed (implemented + independently reviewed; committed `502411d`, pushed)
  - Last updated: 2026-06-16 15:36 CDT
- Phase 14: bash alias write smart-dedup (aliases canonical in `~/.bashrc`; redundant `~/.bash_profile` copy stripped when it already sources `~/.bashrc`)
  - Status: Completed
  - Last updated: 2026-06-16 15:36 CDT
- Phase 15: lower GLM-5.2 `CLAUDE_CODE_AUTO_COMPACT_WINDOW` 1000000 -> 900000 (only the 5.2 wrapper) + v2.4.1 + redeploy
  - Status: Completed (implemented, verified, redeployed, committed `a29600e`, pushed)
  - Last updated: 2026-07-02 10:01 CDT
- Phase 16: harness code review + fix — SEC (settings.json chmod 600 ×10), BUG (set-e continue-anyway guard), IDEMPOTENCY (csh alias dedup) in install.sh + v2.4.2
  - Status: Completed (Implementer applied, independent evaluator-active Reviewer APPROVED, redeployed + runtime-verified 600, committed `a103f0b`, pushed)
  - Last updated: 2026-07-03 00:57 CDT
  - SPEC: `.moai/specs/SPEC_HARNESS_CODE_REVIEW_2026_07_02.md` (gitignored, local)

- Phase 17: GLM-5.3 wrapper + consolidation to genuinely-serving models + full-line alias matching + reroute-aware smoke test
  - Status: Completed (implemented, tested end-to-end in a sandbox HOME, redeployed to this machine, runtime-verified). **Not yet committed.**
  - Last updated: 2026-08-16 08:50 CDT

- Phase 18 harness code review + fix — 17 defects across 6 files, found by 3 independent reviewers + 10 Implementers. Includes 3 HIGH security fixes (API-key command injection in both installers; curl config injection introduced by our own argv fix; rc data-loss introduced by our own symlink fix), PowerShell ACL hardening at 12 sites, and a CRLF alias regression that silently defeated Phase 17's central purpose on Windows-style rc files: Completed (uncommitted — see §7)
  - Completed in Session 2026-08-16 (Phase 18)

## 4. Outstanding Work
- Windows-side verification of install.ps1 (now: 5.3 wrapper + tier scheme + ccg53 shims + Remove-RetiredWrappers) on a real Windows host.
  - Status: Open — standing gap across all phases.
  - **Correction (2026-08-16)**: the previous note "no Windows host in this environment" is wrong. Windows IS this same machine — `/mnt/c` is mounted, PowerShell 5.1 is at its standard path, and PowerShell 7 is installed at `C:\Program Files\PowerShell\7`.
  - **Correction to the correction (2026-08-16, Phase 18)**: an earlier claim in this file that "WSL interop is disabled" was ALSO wrong — it came from a bad probe. Verified: `/proc/sys/fs/binfmt_misc/WSLInterop` reads `enabled`, and invoking `powershell.exe` directly returns `5.1.26100.9168`. Windows PowerShell **is executable from this WSL session**; only `pwsh`/`powershell.exe` are absent from `PATH`.
  - **What this actually unblocks, and what it does not**: `install.ps1` can now be **parsed** safely (parsing does not execute) — done in Phase 18 via `[System.Management.Automation.Language.Parser]::ParseFile`, result **0 syntax errors, 4631 tokens**. First mechanical validation of install.ps1 in the project's history. **Running** it remains unsafe here: `install.ps1:29-36` anchors every path to `$env:USERPROFILE`, which resolves to the real Windows profile (`C:\Users\jung.hur`), and a bash-side `HOME` override cannot redirect it — so there is no safe sandbox for a full execution test. Full end-to-end Windows verification therefore stays OPEN.
  - Last updated: 2026-08-16 (Phase 18 code review)
  - Reference: PROJECT_LOG.md Session 2026-08-16 (Phase 17, Phase 18)
- The `[1m]` bracket model form cannot be validated against the raw Z.AI API.
  - Status: Open (structural — not fixable by testing harder)
  - Both `glm-5.2[1m]` and `glm-5.3[1m]` return HTTP 400 "modelCode does not exist" on `/v1/messages`; the bracket is a Claude-Code-side routing convention the client translates before sending. Reroute behavior for the bracket form is therefore INFERRED from the base model id, not observed.
  - Last updated: 2026-08-16 08:50 CDT
- Runtime confirmation that `glm-5.2[1m]` resolves inside a real Claude Code launch.
  - Status: Open
  - Last updated: 2026-06-16 15:36 CDT
  - Reference: PROJECT_LOG.md Session 2026-06-16 (Phase 13)
  - Note: the raw `/v1/messages` API 400s on the literal bracket form because `[1m]` is a Claude Code client-side routing convention, not a raw model id; base `glm-5.2` is confirmed reachable (HTTP 200). Recommend one live `ccg` launch to confirm.
- Clean the duplicate alias block currently on this machine's `~/.bash_profile`.
  - Status: Resolved (2026-07-02) — the Phase 15 redeploy re-ran `bash install.sh` (option 2); the Phase 14 smart-dedup stripped the redundant `~/.bash_profile` block (verified: no installer alias block remains there; it sources `~/.bashrc`). New GLM `A` aliases are now live in `~/.bashrc`.
  - Last updated: 2026-07-02 10:01 CDT
  - Reference: PROJECT_LOG.md Session 2026-07-02 (Phase 15)
- Optional: remove the stale `~/.local/bin/claude-glm-5.2.bak-1000000` stopgap backup (leftover from the pre-Phase-15 hand-patch; still contains 1000000; inert — not on any alias path; not created by an MoAI session so left in place).
  - Status: Open (optional user cleanup)
  - Last updated: 2026-07-02 10:01 CDT

## 5. Risks, Open Questions, and Assumptions
- Risk: TypeScript build / proxy code removed; `package.json` no longer includes TypeScript/dev deps.
  - Status: Resolved
  - Date opened: 2026-02-11
  - Resolution: This repo no longer ships or supports `ccx`, so proxy build tooling is intentionally removed.
- Risk: `npm install` in this repo fails due to `bin/preinstall.js` (npx-only enforcement), limiting local verification.
  - Status: Open
  - Date opened: 2026-02-11
  - Current assumption: Verification relies on installer script syntax checks and text search, not `npm` builds.

## 6. Verification Status
- Verified (Session 2026-08-16 08:50 CDT, Phase 17 GLM-5.3 + consolidation):
  - Live API, requested-vs-served comparison (3 confirmations each, deterministic): `glm-5.2`/`glm-5.1`/`glm-5` → served by **glm-5.3**; `glm-4.5-air` → served by **glm-4.7**. Serving themselves: glm-5.3, glm-5-turbo, glm-4.7, glm-4.6, glm-4.5, glm-4.5v. v5 namespace sweep (15 candidates): only 5/5.1/5.2/5.3/5-turbo exist; the rest HTTP 400.
  - `bash -n install.sh` => OK; `bash -n smoke_test_models.sh` => OK; `json.load(package.json)` => 2.5.0
  - install.sh counts: 6 wrapper functions, 18 call sites (6×3 paths), 12 haiku=glm-4.7 (6×2), 0 residual glm-4.5-air haiku, 0 retired wrapper functions, 0 generated retired aliases
  - install.ps1 counts (structural parity; PowerShell execution NOT run): 6 wrapper functions, 18 call sites, 7 `Set-Alias`, 28 `New-CmdShim`, 12 haiku=glm-4.7, 4 `Remove-RetiredWrappers` references
  - Alias-cleanup regexes extracted verbatim from install.sh and exercised in a child bash process (real /usr/bin/grep) against a fixture: all 12 installer-generated lines removed in both bash and csh format, while user-owned `ccg` / `ccg52` / `ccg53` aliases pointing elsewhere ALL survived. The superseded substring logic was run on the identical fixture and destroyed all three — contrast recorded.
  - End-to-end installer run in a sandboxed HOME: 11 pre-existing wrappers → 6; 5 retired deleted; 28 aliases written; user-owned colliding aliases preserved; idempotent over 3 consecutive runs (1 block header, no duplication)
  - Real redeploy (option 2, dotfiles backed up to `~/.bashrc.bak.glm53-*`): `~/.bashrc` diff vs backup shows ONLY 18 installer-generated retired alias lines removed + 5 added; no user alias touched. `~/.local/bin` wrappers 11 → 6
  - Deployed 5.3 wrapper runtime check (`claude` masked): settings.json is valid JSON with `glm-5.3[1m]` opus/sonnet, `glm-4.7` haiku, 900000 window; mode **600** on settings.json, **700** on the wrapper
  - Post-change smoke test: 6 shipped models PASS with matching served-by; 4 retired IDs flagged REROUTED; `glm-4.7-flashx` FAIL 429 (not plan-covered) as the control
  - Smoke-test defect found and fixed: at the old 15s timeout `glm-5.3` returned HTTP 000 and was reported as a **false FAIL** (it emits a thinking block before content). Raised to 60s; 3/3 HTTP 200 at 90s confirmed the model was always fine.
- Verified (Session 2026-07-03 00:57 CDT, Phase 16 harness review fixes):
  - `bash -n install.sh` => OK; `git diff` = install.sh only, +23/-2 (minimal)
  - FIX-1: 10 `chmod 600 "$CLAUDE_HOME/settings.json"` runtime lines (one per wrapper, after each SETTINGS heredoc); `chmod 700` on wrappers unchanged (10). Redeployed + launched the 5.2 wrapper (claude masked) → `~/.claude-glm-52/settings.json` went 644 → **600**, JSON still valid (6 keys, token present). Proactively chmod 600 on all remaining config dirs (now all 600)
  - FIX-2: reproduced the false-abort (bare `check_claude_installation` return 1 under `set -eE`+trap → handle_error) and the fix (`|| true` → main proceeds); decline path still `exit 1`
  - FIX-3: reproduced csh duplication (bash `=` filters leave `alias X 'v'` intact) and the fix (space-format `grep -vE` strips all 42 csh aliases, 0 false positives, bash format + user aliases untouched, idempotent across re-runs)
  - Independent evaluator-active Reviewer executed the real patched code (not paraphrased): APPROVED, no regressions, no scope creep, install.ps1/README untouched
- Verified (Session 2026-07-02 10:01 CDT, Phase 15 auto-compact 900000):
  - `grep -rn 'AUTO_COMPACT_WINDOW' install.sh install.ps1` => only `900000` (2 per file, 4 total); 0 residual `1000000` in either script
  - README.md line 122 documents `CLAUDE_CODE_AUTO_COMPACT_WINDOW=900000`
  - `bash -n install.sh` => OK; `json.load(package.json)` => 2.4.1
  - Deployed (after `bash install.sh` option-2 reset): `grep -n AUTO_COMPACT_WINDOW ~/.local/bin/claude-glm-5.2` => 2 lines, both `900000`. Scope confirmed — among live `~/.local/bin/claude-glm-*` wrappers, only `claude-glm-5.2` carries the var (a stale `claude-glm-5.2.bak-1000000` stopgap backup is the only other file with it; inert, left in place)
  - `~/.bash_profile`: no installer alias block (Phase 14 dedup applied; it sources `~/.bashrc`). `~/.bashrc` holds `ccg`/`ccgA`/`ccg52`/`ccg52A`. Dotfile backups taken first (`~/.bashrc.bak.acw-*`, `~/.bash_profile.bak.acw-*`)
- Verified (Session 2026-06-16 16:13 CDT, auto-mode `A` variants):
  - `bash -n install.sh` => OK; `claude --help` confirms `--permission-mode` accepts `auto` (old `--enable-auto-mode` is deprecated)
  - install.sh: 20 alias-`A` lines (10 csh + 10 bash blocks), 10 cleanup-list entries, 1 summary echo. install.ps1: 10 `A` profile functions (inside `$aliases` here-string), 10 `.cmd` shims, 10 cleanup function-regexes + 1 header pattern, 1 summary line
  - No `--enable-auto-mode` remains anywhere in the repo
  - End-to-end (child bash, real grep): first run generates all 10 `A` aliases (`ccgA` … `ccg52A` correct); re-run dedupes cleanly (10 `A` aliases, 1 block header — no duplication)
  - Personal `~/.bashrc`: `ccdA` flag corrected to `--permission-mode auto` (diff vs backup shows only that line changed; `claudeA` already correct). Backup at `~/.bashrc.bak.ccdA-fix`
- Verified (Session 2026-06-16, Phase 13 GLM-5.2):
  - `bash -n install.sh` => OK; `bash -n smoke_test_models.sh` => OK
  - `python3 json.load(package.json)` => version 2.4.0
  - Residual `ANTHROPIC_MODEL`/`ANTHROPIC_SMALL_FAST_MODEL` references: 0 in install.sh, 0 in install.ps1 (full migration to tier scheme)
  - Tier-scheme balance: OPUS=SONNET=HAIKU=20 in each of install.sh and install.ps1 (10 wrappers x 2 blocks each)
  - `glm-5.2[1m]` + `CLAUDE_CODE_AUTO_COMPACT_WINDOW` isolated strictly to the 5.2 wrapper in both files; no other wrapper carries them
  - Generated bash `claude-glm-5.2` settings.json extracted and parsed => VALID JSON with 6 expected env keys; PowerShell 5.2 settings.json line parsed => VALID
  - All 10 PowerShell `$Glm*ConfigDir` vars defined incl. `$Glm52ConfigDir`; summary config-dirs line brought to full parity with install.sh
  - Live `smoke_test_models.sh` vs Z.ai API: glm-5.2 PASS (HTTP 200); all wrapper models PASS; only `glm-4.7-flashx` 429s (plan quota, unchanged baseline, not a wrapper). Raw API rejects literal `glm-5.2[1m]` (HTTP 400 Unknown Model) — expected; bracket form is Claude-Code-side only.
  - Independent review by evaluator-active subagent: APPROVED (Functionality 96, Security 100, Craft 97, Consistency 98). One Low finding (PS config-dirs summary omission) fixed.
- Verified (Session 2026-04-28 19:30 CDT):
  - `bash -n install.sh` => OK
  - `bash -n install.ps1` (syntax not validated on Linux; PowerShell-specific structure unchanged from previous verified state)
  - `bash -n smoke_test_models.sh` => OK
  - `python3 -c "import ast; ast.parse(...)"` on `fix_hooks_config.py` => OK
  - `node --check bin/cli.js`, `node --check bin/preinstall.js` => OK
  - `python3 -c "json.load(...)"` on `package.json` => OK
  - Migration logic dry-run against user's actual `~/.bashrc`: claude aliases (`ccdD`, `claudeD`, `codexD`, `ccd`) PRESERVED; old GLM aliases (`ccg47`, `ccg5`, `ccg47D/Dd`, `ccg5D/Dd`, `ccf`) STRIPPED. Legacy fingerprint not triggered (correct — user's bashrc was customized).
  - Migration logic test against synthetic legacy auto-installed bashrc: full claude alias quintet (`ccd`, `ccdD`, `ccdDd`, `claudeD`, `claudeDd`) SCRUBBED. Fingerprint detected.
  - `smoke_test_models.sh` against live Z.ai API: 8/9 PASS (glm-5.1, glm-5, glm-5-turbo, glm-4.7, glm-4.6, glm-4.5, glm-4.5v, glm-4.5-air). FAIL on glm-4.7-flashx (HTTP 429, plan quota — unchanged from baseline). API key auto-detected from existing wrappers; SMOKE-01 fix verified working (no `--key` flag needed).
- Verified (earlier sessions):
  - `bash -n install.sh` => OK (2026-02-11 21:45 CST)
  - Grep for `ccx` / `claude-proxy` across key files => no matches in `README.md`, `install.sh`, `install.ps1`, `package.json`, `bin/*` (2026-02-11 21:45 CST)
  - `bash -n install.sh` => OK (2026-02-11 21:54 CST)
  - `bash -n install.sh` => OK (2026-02-11 21:59 CST)
  - `bash -n install.sh` => OK (2026-03-08 13:33 CDT)
  - `bash -n install.sh` => OK (2026-04-17 18:10 CDT)
  - Grep sanity for ccg46/ccg51: 2 new bash wrappers, 2 new PowerShell wrappers, all alias/function/shim pairs present (2026-04-17 18:10 CDT)
  - `bash -n install.sh` => OK (2026-04-17 20:05 CDT)
  - `smoke_test_models.sh` executed against live Z.ai API (2026-04-17 20:00 CDT): PASS for glm-5.1, glm-5, glm-5-turbo, glm-4.7, glm-4.6, glm-4.5, glm-4.5v, glm-4.5-air. FAIL for glm-4.7-flashx (HTTP 429 "Insufficient balance or no resource package").
  - Harness code review (2026-04-17 20:40 CDT): Reviewer APPROVED all 5 SPEC fixes; bash -n OK; smoke test re-run = identical 8/9 pass rate = zero regression.
- Not yet verified:
  - PowerShell script execution on Windows (reason: not run in this environment)

## 7. Restart Instructions
- Starting point:
  0. **Phase 17 is implemented, verified, and redeployed but NOT COMMITTED.** `git status` will show modified: install.sh, install.ps1, smoke_test_models.sh, README.md, package.json, PROJECT_HANDOFF.md, PROJECT_LOG.md. Backups of the pre-change installers are in the session scratchpad and dotfile backups at `~/.bashrc.bak.glm53-*`. Also still untracked from a prior MoAI tooling update: `.claudeignore`, `.git_hooks/`, `.github/` (unrelated to Phase 17; decision pending).
  1. Latest commit on `main` is `347801f` (docs end-of-session for Phase 16); the last substantive code commit is `a103f0b`. Project version now 2.5.0 in the working tree.
     - Phase 16 (harness review: settings.json chmod 600 + set-e guard + csh dedup, v2.4.2) → `a103f0b`
     - Phase 15 (GLM-5.2 auto-compact window 1000000 → 900000, v2.4.1) → `a29600e`
     - Phase 13 (GLM-5.2 default + tier-scheme migration) → `502411d`
     - Phase 14 (bash alias smart-dedup) → `5e1eb62`
     - Removed redundant `./install` bootstrap → `92164c0`
     - Auto-mode `A` alias variants → `d8c936d`
  2. `.moai/` is gitignored (local-only SPEC artifacts). The earlier `.gitignore`/`CLAUDE.md` upstream-drift question is closed — `CLAUDE.md` was committed (`03e7dfb`); nothing pending there.
  3. Note for testing: in the Claude Code Bash-tool sandbox, `grep` is a shell-function wrapper that `exec`s away subshells — run any test that pipes installer functions through grep as a child `bash` process (real `/usr/bin/grep`), not in an inline `( … )` subshell. Real users running `bash install.sh` are unaffected. Also: the Edit tool cannot write files outside the project dir (e.g. `~/.bashrc`); use an anchored `sed -i` after a backup.
- Recommended next actions (optional):
  1. Done this session (Phase 15 redeploy): `bash install.sh` (option 2) regenerated all wrappers (incl. `claude-glm-5.2` at the new 900000 window), installed the auto-mode `A` aliases (`ccgA` … `ccg52A`) into `~/.bashrc`, and triggered the Phase 14 dedup that stripped the leftover alias block from `~/.bash_profile`. Run `source ~/.bashrc` (or open a new shell) to pick up the refreshed aliases.
  2. Launch `ccg` once to confirm the 900000 window behaves as expected inside a real Claude Code session (the raw API cannot validate the `glm-5.2[1m]` bracket form; base `glm-5.2` is confirmed reachable). If heavy turns still occasionally hit "context over limit", lower the 5.2 window to 800000 (auto-compact ~664K, ~336K headroom) — the safer fallback value.
  3. Re-run `smoke_test_models.sh` whenever Z.ai changes plan availability (baseline 2026-06-16: glm-5.2 + all wrapper models PASS; only glm-4.7-flashx 429s).
  4. Windows-side execution of `install.ps1` remains unverified — run on a Windows host if convenient.
- Cross-project wiki: `~/PROJECTS/wiki/concept/claude-code-auto-compact-window-headroom.md` (auto-compact-window headroom — why the 5.2 window is 900000, 800000 as safer fallback); `~/PROJECTS/wiki/concept/set-e-err-trap-false-abort.md` (Phase 16 FIX-2 lesson — bare `return 1` under `set -e`+ERR trap false-aborts); `~/PROJECTS/wiki/concept/generated-secret-file-perms.md` (Phase 16 FIX-1 lesson — chmod the config a script generates, not just the script).
- Security note (Phase 16): wrappers now `chmod 600` their settings.json at runtime. This machine's existing config-dir settings.json were proactively hardened to 600; on any other machine, launching each wrapper once re-hardens its settings.json (previously 644).
- Last updated: 2026-07-04 15:00 CDT
