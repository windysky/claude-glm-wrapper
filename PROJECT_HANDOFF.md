# Project Handoff

## 1. Project Overview
- Purpose: Local wrapper/installer scripts to run Claude Code against Z.AI GLM models via per-model `CLAUDE_HOME` directories.
- Scope: Cross-platform install scripts + docs for `ccg` (GLM-5.1, default), `ccg51` (GLM-5.1), `ccg5t` (GLM-5-Turbo), `ccg5` (GLM-5), `ccg47` (GLM-4.7), `ccg46` (GLM-4.6), `ccg45` (GLM-4.5), `ccg45v` (GLM-4.5V vision), `ccg45air` (GLM-4.5-Air), and `ccf` (alias for GLM-4.5-Air). Installer manages GLM aliases only — the bare `claude` command and any user-curated `ccd`/`ccdD`/`claudeD` aliases are intentionally untouched.
- Last updated: 2026-06-16
- Last coding CLI used (informational): Claude Code
- Current version: 2.4.0 (package.json)
- Latest committed commit on `main`: `70ff1ff` (install.ps1 PS5.1 fixes). NOTE: the prior handoff incorrectly recorded `25ff837` as the tip; git history actually has `072a9c9` (Phase 11+12) plus a run of install.ps1 PS5.1 hardening commits (`ec387cb`, `4399507`, `03e7dfb`, `657b2c9`, `70ff1ff`) that were never logged in PROJECT_LOG.md. Those are pre-existing and left as-is.
- Phase 13 (GLM-5.2) work is implemented and verified but NOT yet committed (working tree has modifications to install.sh, install.ps1, smoke_test_models.sh, README.md, package.json).

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
- Add GLM-5.2 wrapper (`ccg52`) as the new default (`ccg` repointed from GLM-5.1 to GLM-5.2 with `glm-5.2[1m]` 1M context + `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000`); migrate ALL wrappers from `ANTHROPIC_MODEL`+`ANTHROPIC_SMALL_FAST_MODEL` to the tier scheme `ANTHROPIC_DEFAULT_OPUS_MODEL`/`ANTHROPIC_DEFAULT_SONNET_MODEL`=own model, `ANTHROPIC_DEFAULT_HAIKU_MODEL`=glm-4.5-air (per Z.AI Claude Code doc); keep all existing wrappers; smoke test + README + version 2.4.0: Completed (implemented + reviewed, uncommitted)
  - Completed in Session 2026-06-16

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
  - Status: Completed (implemented + independently reviewed; uncommitted)
  - Last updated: 2026-06-16

## 4. Outstanding Work
- Commit + push Phase 13 (GLM-5.2). Working-tree changes to install.sh, install.ps1, smoke_test_models.sh, README.md, package.json are verified but not yet committed. User has not yet requested a commit.
- Windows-side verification of install.ps1 for the new 5.2 wrapper + tier scheme remains unrun (no Windows host in this environment) — same standing gap as prior phases.
- Runtime confirmation that `glm-5.2[1m]` resolves inside a real Claude Code launch (the raw `/v1/messages` API 400s on the bracket form because `[1m]` is a Claude Code client-side routing convention, not a raw model id; base `glm-5.2` is confirmed reachable HTTP 200). Recommend one live `ccg` launch to confirm.

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
  1. Tree is clean for project code. All phases 1-10 are committed and pushed to `main`.
     - Phase 8 → `b0acd38` (v2.1.0 preserved; 2.2.0 wrappers)
     - Phase 9 → `873b8a6` (v2.3.0, wrappers + smoke test)
     - Phase 10 → `dc3e6b8` (harness review fixes)
  2. SPEC artifact at `.moai/specs/SPEC_HARNESS_CODE_REVIEW_2026_04_17.md` is local-only (`.moai/` is gitignored).
  3. Pre-existing uncommitted drift on `.gitignore` and `CLAUDE.md` is unrelated to this project's code — it's upstream MoAI-ADK framework updates. Decide separately whether to commit, revert, or ignore.
- Recommended next actions (optional):
  1. Run `bash install.sh` locally, choose option 2 "Reset wrappers/aliases using existing API key" to regenerate wrappers under the new SEC-01 file mode. Verify `ls -l ~/.local/bin/claude-glm-*` shows `-rwx------`.
  2. Sanity-check silent API-key entry on the next fresh-key flow (read -rs).
  3. Re-run `smoke_test_models.sh` anytime Z.ai changes plan availability (last baseline 2026-04-17: 8/9 PASS, only glm-4.7-flashx 429s).
  4. Windows-side smoke test of `install.ps1` remains unverified — run on a Windows host if convenient.
- Last updated: 2026-04-17 21:10 CDT
