# Project Handoff

## 1. Project Overview
- Purpose: Local wrapper/installer scripts to run Claude Code against Z.AI GLM models via per-model `CLAUDE_HOME` directories.
- Scope: Cross-platform install scripts + docs for `ccg` (GLM-5.3, default, 1M context), `ccg53` (GLM-5.3), `ccg5t` (GLM-5-Turbo), `ccg47` (GLM-4.7), `ccg46` (GLM-4.6), `ccg45` (GLM-4.5), and `ccg45v` (GLM-4.5V vision) — **6 wrappers, each verified to serve the model its name claims**. Each wrapper uses Z.AI's opus/sonnet/haiku tier scheme (opus+sonnet = its own model, haiku = glm-4.7). Installer manages GLM aliases only — the bare `claude` command and any user-curated `ccd`/`ccdD`/`claudeD` aliases are intentionally untouched.
- **Retired in Phase 17** (Z.AI silently reroutes these IDs while still returning HTTP 200): `ccg52`/`ccg51`/`ccg5` (served by glm-5.3), `ccg45air`/`ccf` (served by glm-4.7). The installer now deletes their wrapper scripts and strips their aliases on re-run.
- Last updated: 2026-10-31 10:19 CDT
- Last coding CLI used (informational): Claude Code CLI (Opus 5, switched to Opus 5.5 mid-session)
- Current version: 2.5.0 (package.json)
- Latest commit on `main`: `819f3a9`, pushed to origin (CI `ShellCheck Gate` green on that push). **Working tree is not clean**: `install.ps1` carries a verified but **uncommitted** fix, and the three session docs are modified by the 2026-10-31 close-out. Lineage (newest first): `819f3a9` (Phase 20: MoAI-ADK `GLM_API_KEY` sync) ← `55802a0`/`058f9d5`/`424369c`/`a546d33`/`fce0361` (2026-09-30 MoAI tooling housekeeping; no installer, package or README change) ← `56ce6f4` (npm republish under `@windysky`) ← `62dc201` (Phase 19 follow-up docs) ← `5e7964d` (ccx gate + fingerprint tighten, mis-scoped).

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

- Add GLM-5.3 wrapper (`ccg53` + D/Dd/A) and consolidate the wrapper set to the 6 models that genuinely serve themselves; retire `ccg52`/`ccg51`/`ccg5`/`ccg45air`/`ccf`; haiku tier `glm-4.5-air` → `glm-4.7`; installer-side alias cleanup rewritten to full-line value-anchored matching; smoke test now detects silent model substitution; v2.5.0: Completed (committed `02c4bd4`, pushed)
  - Completed in Session 2026-08-16 08:50 CDT
- Phase 18 adversarial code review — 18 defects fixed across 6 files (3 HIGH security), 7 commits pushed, 0 CRITICAL/HIGH open at close: Completed (`02c4bd4` … `b0ff602`)
  - Completed in Session 2026-08-16 → closed 2026-08-17 06:50 CEST
- Phase 19 planning — 4 SPECs authored for the remaining open items, then reduced to 3 (the install.ps1 end-to-end SPEC was dropped by user decision): Completed
  - Completed in Session 2026-08-17 11:43 CEST
- Phase 19 execution — independent review of the four orchestrator fixes (verdict APPROVED ×4), LOW-defects cleanup (`10a3dbe`), ShellCheck baseline with Option B adopted: Completed
  - Completed in Session 2026-08-17 (Phase 19 execution)
- Phase 19 follow-up — `--debug` flag implemented, `ccx` deletion gated on its proxy markers, retired-wrapper fingerprint tightened to assignment-only, ShellCheck CI gate (`.github/workflows/shellcheck.yml`, blocking on NEW findings) with a tracked baseline, npx claim dropped and then re-pointed at the `@windysky` scope (`56ce6f4`): Completed — each shipped item re-checked in the code on 2026-10-31 (§6)
  - Completed in Session 2026-08-23 (Phase 19 follow-up)
- MoAI-ADK key sync — `install.sh` (`sync_moai_env_glm`) and `install.ps1` (`Sync-MoaiEnvGlm`) now rewrite `GLM_API_KEY` in `~/.moai/.env.glm` to the wrapper key on all three key paths (never creating the file, skipping on the placeholder); README section; live `~/.moai/.env.glm` repaired; retired key swept from local config: Completed (`819f3a9`). The follow-up `install.ps1` UTF-8-read fix is verified (21/21 under real PowerShell 5.1) but **not yet committed**.
  - Completed in Session 2026-10-31 10:19 CDT (Phase 20)

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

- Phase 18 harness code review + fix — 17 defects across 6 files, found by 3 independent reviewers + 10 Implementers. Includes 3 HIGH security fixes (API-key command injection in both installers; curl config injection introduced by our own argv fix; rc data-loss introduced by our own symlink fix), PowerShell ACL hardening at 12 sites, and a CRLF alias regression that silently defeated Phase 17's central purpose on Windows-style rc files: Completed (committed `02c4bd4`, pushed)
  - Completed in Session 2026-08-16 (Phase 18)

- Phase 19: independent review + LOW defects + ShellCheck policy (2026-08-17), then follow-up fixes and the CI gate (2026-08-23)
  - Status: Completed
  - Last updated: 2026-08-23
  - Remaining from its findings queue: `SPEC_ALIAS_GLM_WILDCARD_OVERMATCH` (§4)

- Phase 20: keep MoAI-ADK's `GLM_API_KEY` in step with the wrapper key (both installers) + retired-key sweep
  - Status: Completed and pushed (`819f3a9`); **one follow-up fix to `install.ps1` is verified but uncommitted**
  - Last updated: 2026-10-31 10:19 CDT

## 4. Outstanding Work

> **The Phase 19 SPEC queue is executed, apart from one item** (status as of 2026-10-31). `.moai/specs/` is gitignored and local-only.
> **Done** — `SPEC_INDEPENDENT_REVIEW_ORCHESTRATOR_FIXES.md` (verdict APPROVED ×4) · `SPEC_LOW_DEFECTS_CLEANUP.md` (4 fixes, `10a3dbe`) · `SPEC_SHELLCHECK_BASELINE.md` (Option B) · and, from the findings queue, `SPEC_CCX_UNCONDITIONAL_DELETE` · `SPEC_FINGERPRINT_COMMENT_MATCH` · `SPEC_DEBUG_FLAG_DEAD` (shipped 2026-08-23; each re-checked in `install.sh` on 2026-10-31 — `debug_log` at :57, assignment-only fingerprint match at :925, `ccx` proxy-marker gate at :956).
> **Still open** — `SPEC_ALIAS_GLM_WILDCARD_OVERMATCH.md` (LOW-MEDIUM; the wildcard is still in `managed_value`, `install.sh:1165`; **must not be fixed by reverting R1**) and the items below.
> `SPEC_SECURITY_APIKEY_INJECTION.md` is marked IMPLEMENTED in its own header — retained as a record, **do not re-execute**.

- **ShellCheck lint policy: Option B — baseline as accepted debt, gate only NEW findings.**
  - Status: **Decided and in effect** (2026-08-17, Phase 19)
  - Update 2026-10-31: the CI gate is live and green — `ShellCheck Gate` passed on the pushes of 2026-08-23, 2026-09-30 and 2026-10-29 (`819f3a9`, run 40859512543, 11 s). `install.sh` counts after Phase 20's +84 lines are identical to `.github/shellcheck-baseline/install.sh.counts` (SC2001 1, SC2016 1, SC2086 1, SC2155 8, SC2162 8 = 19). The `pull_request` trigger has still never fired.
  - Baseline: 22 findings across 4 files — `install.sh` 20, `.git_hooks/pre-push` 2, and **`smoke_test_models.sh` + `.git_hooks/pre-commit` both clean**. Severity: warning 11, info 10, style 1, **error 0**. Artifact: `.moai/specs/shellcheck-baseline-2026-08-17.md`; machine-readable: `.moai/baselines/shellcheck-2026-08-17/`.
  - Rationale: the `set -e` masking class the linter was wanted for came back **clean** — all 8 `SC2155` hits were checked at the site, and `detect_shell_rc` (4 of them) cannot fail. The remaining 20 are style debt in code that is end-to-end verified. Option A would convert a cheap win into a mass edit of a 1,559-line installer that writes user dotfiles.
  - Existing findings are addressed opportunistically, when a change already touches those lines. The NEW-finding comparison procedure is in the baseline artifact.
  - Tooling caveat: `shellcheck` 0.9.0 is a **static release binary** at `.moai/tmp/tools/shellcheck`, not an apt install — `sudo -n` exits 1 in this environment, so the package route is unavailable without an interactive password. The version matches the apt candidate (`0.9.0-1`) so a future apt-installed run stays comparable.
  - Last updated: 2026-08-17 (Phase 19)
  - Reference: PROJECT_LOG.md Session 2026-08-17 (Phase 19 execution)

- **`package.json` advertises an npx entry point that fetches somebody else's package.**
  - Status: Open (LOW — nothing user-facing is broken today)
  - Discovered 2026-08-17 while resolving the Windows-user question. `package.json` `description` says *"Run with: npx claude-glm-installer"*, and `bin` declares that name — but `npm view claude-glm-installer` resolves to **upstream JoeInnsp23's v1.0.3** (`repository.url = JoeInnsp23/claude-glm-wrapper`), not this fork's v2.5.0. Anyone following that instruction runs a different, older codebase and would not know.
  - Not currently harmful: `README.md` only documents `git clone` + `bash install.sh`; the stale npx claim exists solely in `package.json`'s description field.
  - Options: drop the npx claim from the description, or publish under a distinct name. Not decided.
  - **Update 2026-10-31:** commit `56ce6f4` re-pointed the package at the author's own scope — `package.json` is now `@windysky/claude-glm-installer`, and both its description and `README.md:39` say `npx @windysky/claude-glm-installer` — but `npm view @windysky/claude-glm-installer` returns **E404** (nothing published at registry.npmjs.org, checked 2026-10-31). The instruction now fails loudly instead of running somebody else's code. Decision needed: publish the package, or drop the npx claim from both places.
  - Last updated: 2026-08-17 11:43 CEST
  - Reference: PROJECT_LOG.md Session 2026-08-17 (planning)
- ~~Windows-side end-to-end verification of `install.ps1`.~~ **CLOSED — will not do (user decision, 2026-08-17 11:43 CEST).**
  - Status: **Closed / won't-do.** The SPEC that covered it (`SPEC_INSTALLPS1_E2E_WINDOWS.md`) was deleted, not deferred.
  - Rationale: the cost/benefit collapsed once the user population was measured. The repo has **0 stars, 0 forks**, and the npm name resolves to upstream — so this fork's `install.ps1` reaches essentially one Windows user, the repo owner, who has decided not to spend the effort. Running it would have required either a throwaway Windows account, a VM, or accepting writes to the real `%USERPROFILE%` (there is no sandbox — `install.ps1` anchors 14 paths to it and a bash-side `HOME` override cannot redirect them).
  - **`install.ps1` itself is untouched and still shipped** (1386 lines). What was dropped is the *verification task*, not the code. It retains the Phase 18 static assurance: AST parse 0 errors, `Test-ZaiApiKey` unit-tested 10/10 under real PowerShell 5.1, `Protect-KeyFile` executed against a real file, one generated wrapper executed against a temp `CLAUDE_HOME`, and a close line-by-line review that found no defects.
  - If a real Windows user ever appears, reopen this: the bash counterpart produced two data-loss regressions in a single review, and the PowerShell side has never had that scrutiny.
  - Last updated: 2026-08-17 11:43 CEST
  - Last updated: 2026-08-17 11:43 CEST (Phase 18)
  - Reference: PROJECT_LOG.md Session 2026-08-16 → closed 2026-08-17 (Phase 18)
- The `[1m]` bracket model form cannot be validated against the raw Z.AI API, and one live `ccg` launch is still the only way to confirm it end-to-end.
  - Status: Open (structural — not fixable by testing harder)
  - Both `glm-5.2[1m]` and `glm-5.3[1m]` return HTTP 400 "modelCode does not exist" on `/v1/messages`; the bracket is a Claude-Code-side routing convention the client translates before sending. Reroute behaviour for the bracket form is therefore INFERRED from the base model id, not observed. The base ids ARE verified to serve themselves (live, Phase 17 + 18).
  - README and `smoke_test_models.sh` now both state this limitation explicitly (Phase 18), so the "verified" claim no longer overreaches.
  - Recommended: launch `ccg` once and confirm the session reports GLM-5.3 with the 1M window.
  - Last updated: 2026-08-17 11:43 CEST
  - Consolidates the former separate "Runtime confirmation that `glm-5.2[1m]` resolves" item, which was the same gap for the superseded 5.2 default.
- ~~Remove the stale `~/.local/bin/claude-glm-5.2.bak-1000000` stopgap backup.~~ **RESOLVED 2026-08-17** — verified absent from `~/.local/bin`; already cleaned up. No action needed.
  - Status: Resolved
  - Last updated: 2026-08-17 11:43 CEST
- Blank line accumulates one per installer run in the user's rc file.
  - Status: Open (LOW, cosmetic, PRE-EXISTING — not introduced by Phase 17/18)
  - Confirmed by two independent reviewers: alias lines themselves never duplicate (28 stays 28, one header stays one); only a blank line grows. The removal filter strips header/comment/alias lines but not the blank line preceding the block.
  - Deliberately not fixed: the tidy fix (filtering blank lines) risks eating a blank line the user wrote.
  - Last updated: 2026-08-17 11:43 CEST
- Minor review findings accepted but not fixed (all LOW, all recorded with reproductions in PROJECT_LOG Phase 18).
  - Status: Open (LOW)
  - `install.sh` unquoted `all_wrappers=($(find_all_installations))` word-splits on a wrapper path containing a space; the printed pipe-to-bash install hint differs from the safe process-substitution form used everywhere else; `smoke_test_models.sh` `validate_key` accepts an empty string where its `install.sh` sibling rejects it (unreachable today — `detect_key` guards it); `.bak` symlink following during rc rewrite (same-user, grants no privilege).
  - Last updated: 2026-08-17 11:43 CEST
- `install.ps1`: commit the verified UTF-8-read fix.
  - Status: Open — **uncommitted in the working tree** (9 insertions, 4 deletions). Committing and pushing waits on the user.
  - Defect: commit `819f3a9` shipped `Sync-MoaiEnvGlm` reading `.env.glm` with `Get-Content`, which decodes a BOM-less file with the ANSI codepage under Windows PowerShell 5.1 — a non-ASCII comment came back as mojibake (`ED 82 A4` → `C3 AD E2 80 9A C2 A4`). The MoAI-generated header is ASCII, so the default file is unaffected; a hand-edited Korean comment would be corrupted. Fix: `[System.IO.File]::ReadAllLines($envFile, UTF8Encoding($false))`, which also consumes a BOM. Verified 21/21 under real PowerShell 5.1 (§6).
  - Last updated: 2026-10-31 10:19 CDT
  - Reference: PROJECT_LOG.md Session 2026-10-31 10:19 CDT
- Key rotation needs one installer run per OS (decision needed — optional).
  - Status: Open (not requested; nothing is broken)
  - `install.sh` has no WSL awareness (no `/mnt/c`, `wslpath` or `powershell.exe` reference), so rotating the key from WSL leaves the Windows wrappers on the old one until `install.ps1` is run in Windows PowerShell. Observed 2026-10-29: all six Windows wrappers still carried the retired key. A WSL→Windows bridge in `install.sh` would be a moderate change whose Windows half can only be tested through `powershell.exe` interop.
  - Last updated: 2026-10-31 10:19 CDT
- ~~Windows-side wrappers still carry the retired GLM key.~~ **RESOLVED (observed 2026-10-31 10:18 CDT).**
  - Status: Resolved. All six `%USERPROFILE%\.local\bin\claude-glm-*.ps1` were rewritten at 10:18 and their `ANTHROPIC_AUTH_TOKEN` equals the WSL wrappers' (compared by sha256 prefix; the key was never printed). Which `install.ps1` revision the user ran is unknown; `%USERPROFILE%\.moai\.env.glm` does not exist on Windows, so `Sync-MoaiEnvGlm` was a no-op there either way.
  - Last updated: 2026-10-31 10:19 CDT
- `NEXT_SESSION.md` is tracked in git although it is machine-local by design.
  - Status: Open (LOW, repo hygiene)
  - `git ls-files NEXT_SESSION.md` lists it, so the `/endsession` step that appends `/NEXT_SESSION.md` to `.gitignore` would be inert — an ignore rule does not untrack a tracked file — and every close dirties the tree. Left unchanged. If wanted: `git rm --cached NEXT_SESSION.md`, then add `/NEXT_SESSION.md` **at the end of `.gitignore`, below `# User Custom Patterns (preserved by moai update)`** (rules placed higher are deleted by `moai update`).
  - Last updated: 2026-10-31 10:19 CDT

## 5. Risks, Open Questions, and Assumptions
- Risk: TypeScript build / proxy code removed; `package.json` no longer includes TypeScript/dev deps.
  - Status: Resolved
  - Date opened: 2026-02-11
  - Resolution: This repo no longer ships or supports `ccx`, so proxy build tooling is intentionally removed.
- Risk: `npm install` in this repo fails due to `bin/preinstall.js` (npx-only enforcement), limiting local verification.
  - Status: Open
  - Date opened: 2026-02-11
  - Current assumption: Verification relies on installer script syntax checks and text search, not `npm` builds.
- Risk: `install.ps1` is shipped but has never been executed end-to-end, on any machine, in this project's history.
  - Status: Open (mitigated, not resolved)
  - Date opened: 2026-06-16 (Phase 13); materially mitigated 2026-08-17 (Phase 18)
  - Mitigation in effect: AST parse (0 errors) + isolated execution of its two security-critical functions under real Windows PowerShell 5.1 + close line-by-line review by an independent reviewer, which found no defects and confirmed 28 profile aliases match 28 `.cmd` shims exactly in both directions. Assumption: structural symmetry with the bash side (which IS end-to-end verified) carries the rest.
  - Update 2026-10-31 (Phase 20): the whole file still parses with 0 errors (5441 tokens), and `Sync-MoaiEnvGlm` + `Protect-KeyFile` were executed in isolation under real Windows PowerShell 5.1.26100.9818 (21/21 checks, throwaway directories under `%TEMP%`, the real profile untouched). The installer's *end-to-end* flow is still not run by this project's tooling; the user's own run on Windows at 10:18 rewrote all six wrappers correctly (observed), but which revision ran is unknown.
- Risk: the charset guard `^[A-Za-z0-9._-]+$` would reject a legitimate Z.AI key containing other characters.
  - Status: Open (accepted trade-off)
  - Date opened: 2026-08-16 (Phase 18)
  - Assumption in effect: observed real keys are hex + `.` + alphanumerics and pass. A base64-style key containing `+`, `/`, or `=` would be rejected, and there is no override flag. The failure is loud and actionable (clear message, exit 1, no partial install), not silent. Widening the charset would reopen the injection vector, so this is deliberate.
- Risk: the reroute behaviour Phase 17 is built on could be reversed by Z.AI at any time.
  - Status: Open (monitored)
  - Date opened: 2026-08-16 (Phase 17)
  - Detection in effect: `smoke_test_models.sh` probes the retired IDs on purpose and reports REROUTED. If one ever flips back to PASS, Z.AI un-retired it and it may deserve a wrapper again.
- Risk: three of the four final fixes carry no independent review.
  - Status: **Resolved** 2026-08-17 (Phase 19)
  - Date opened: 2026-08-17 (Phase 18 close)
  - Context: the Implementer agents died on an account session limit and then `SSL certificate hostname mismatch`, so the orchestrator implemented the last four itself. Each was *diagnosed* by an independent reviewer, and each was verified behaviourally with before/after evidence — but implementation and verification share an author, which the rest of this session deliberately avoided.
  - Resolution: `SPEC_INDEPENDENT_REVIEW_ORCHESTRATOR_FIXES` executed by a non-author reviewer. All four fixes (R1 CRLF alias matching, R2 `managed_value` tightening, R3 fingerprint gate, R4 `umask`/`chmod`) **APPROVED** — each claim reproduced from scratch against the real code in sandboxed `HOME`s, both directions, with the named attack attempted and its outcome reported whether or not it succeeded. Verdict + evidence: `.moai/reports/review/SPEC_INDEPENDENT_REVIEW_ORCHESTRATOR_FIXES-verdict.md`; re-runnable harnesses under `.moai/tmp/review-phase18/`.
- Risk: `install.sh:1333` deletes `~/.local/bin/ccx` unconditionally, including on the Cancel path.
  - Status: **Resolved** 2026-08-23 — the `ccx` removal is gated on the proxy wrapper's own markers (`CLAUDE_PROXY_PORT|ANTHROPIC_UPSTREAM_URL`) and runs inside `remove_retired_wrappers`, which the Cancel branch never reaches (`install.sh:956`, re-read 2026-10-31; the Cancel-path behaviour itself was tested by the 2026-08-23 session and not re-run).
  - Date opened: 2026-08-17 (Phase 19 review, finding F2)
  - Context: no fingerprint gate, no prompt, no authorship check — the hazard class R3 fixed 450 lines earlier. The line sits above the existing-installation menu, so choosing "4) Cancel" deletes the user's file anyway; reproduced. The R3 gate could not be reused because the historical `ccx` wrapper pointed at `http://127.0.0.1:${PORT}` and is the only wrapper form in project history lacking the Z.AI fingerprint.
- Risk: `managed_value`'s `claude-glm[A-Za-z0-9._-]*` wildcard deletes a user's own alias line.
  - Status: Open — filed as `SPEC_ALIAS_GLM_WILDCARD_OVERMATCH` (LOW-MEDIUM)
  - Date opened: 2026-08-17 (Phase 19 review, finding F1)
  - Context: `alias ccg='claude-glm-wrapper-mine'` is removed, contradicting the guarantee at `install.sh:995-999`. Pre-dates R1 (verified by differential against the pre-R1 regex); R1 extended its reach to CRLF rc files, which is unavoidable when closing the under-match. **R1 must not be reverted** — reverting restores 28 permanently stale aliases on every CRLF rc.
- Risk: the retired-wrapper fingerprint matches a comment, not only an executable reference.
  - Status: **Resolved** 2026-08-23 — the gate now matches only where a wrapper assigns the endpoint (`install.sh:925`, re-read 2026-10-31).
  - Date opened: 2026-08-17 (Phase 19 review, finding F3)
  - Context: `grep -q 'api\.z\.ai/api/anthropic'` matches anywhere in the file, so a user script carrying a retired name *and* mentioning the endpoint in a comment is deleted. Narrow precondition; tightening risks the worse failure of leaving a key-bearing retired wrapper undeletable.
- Risk: the removal-failure warning path at `install.sh:889-890` cannot be exercised.
  - Status: Open (informational — not filed as a SPEC)
  - Date opened: 2026-08-17 (Phase 19 review, finding F4)
  - Context: making a wrapper unremovable requires removing write permission from the *directory* (`rm -f` needs directory write, not file write), and that same change aborts the install earlier at wrapper creation (`install.sh:552`). Reaching the warning needs an immutable attribute or a foreign-owned sticky directory — root-only setups. The path is not shown defective, only untestable; do not rely on that warning as a safety net.
- Risk: until the `install.ps1` fix is committed, `main` carries the `Get-Content` ANSI-decode defect in `Sync-MoaiEnvGlm`.
  - Status: Open (LOW — the MoAI-generated header is ASCII; only a hand-edited non-ASCII comment is affected)
  - Date opened: 2026-10-31
  - Mitigation: fix verified in the working tree (§4); commit pending.
- Assumption: the retired Z.AI key remains in five append-only Claude Code logs (`~/.claude/history.jsonl` and four project transcripts).
  - Status: Accepted (the user chose to leave them, 2026-10-29). Rewriting those files risks session history for no gain against a retired key; revisit only if the key is ever un-retired.
  - Date opened: 2026-10-29

## 6. Verification Status
- Verified (Session 2026-10-31 10:19 CDT, Phase 20 MoAI-ADK key sync + retired-key sweep):
  - **Bash side**: `bash -n install.sh` clean. ShellCheck 0.10.0 (static release binary, session scratch) gives SC-code counts byte-identical before and after the change and equal to `.github/shellcheck-baseline/install.sh.counts` (SC2001 1, SC2016 1, SC2086 1, SC2155 8, SC2162 8). CI `ShellCheck Gate` green on the push of `819f3a9` (`gh run list`, run 40859512543, 11 s). `sync_moai_env_glm` run over six sandboxed cases — file absent (nothing created) · stale key replaced with comments and order kept · duplicate `GLM_API_KEY` lines collapsed · missing key appended · placeholder key leaves a real key untouched · no trailing newline — each result at mode 600; a Korean comment survives byte-for-byte under `LC_ALL=C.UTF-8`, `C` and `POSIX`.
  - **PowerShell side** (real Windows PowerShell 5.1.26100.9818, reached at `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`): whole-file AST parse 0 errors / 5441 tokens; `Sync-MoaiEnvGlm` extracted via the AST and run against throwaway directories — 21/21 checks: the six cases above plus CRLF input normalised to LF, a BOM-less non-ASCII comment preserved, a BOM-bearing input healed, an empty file, ACL = protected with one ACE for the current user, no leftover temp file, and a control showing that `Set-Content -Encoding UTF8` really writes `EF-BB-BF` on this machine. The first run scored 17/19: one **real defect** (case 8 — `Get-Content` ANSI decoding mojibake'd the Korean comment; fixed, §4) and one **harness bug** (case 9 — `byte[] + byte[]` is `object[]` in PowerShell, so the "BOM file" was written as text). The harness lived in session scratch and is not kept.
  - **Live system**: `~/.moai/.env.glm` `GLM_API_KEY` now equals the wrappers' `ANTHROPIC_AUTH_TOKEN` (sha256 prefixes compared; before, they differed), mode 600, both header comments intact. A `grep -F` sweep for the retired key finds **0** hits in config files; 5 `*.jsonl` session logs still contain it (accepted, §5). Windows wrappers: all six equal the WSL key (observed 10:18).
  - **HANDOFF reconciliation** (earlier sections had drifted from the 2026-08-23 LOG entry): re-read in the code — `debug_log()` `install.sh:57`; assignment-only fingerprint match `:925`; `ccx` proxy-marker gate `:956`; the `claude-glm[...]*` wildcard still present at `:1165` (so `SPEC_ALIAS_GLM_WILDCARD_OVERMATCH` stays open); `.github/workflows/shellcheck.yml` and four baseline files exist; `package.json` name `@windysky/claude-glm-installer`, version 2.5.0.
  - **Not verified**: which `install.ps1` revision the user ran on Windows at 10:18; the `pull_request` trigger of the CI gate; the installer's full end-to-end flow on Windows; any publication of the `@windysky` package other than at registry.npmjs.org (it is not there — E404).
- Verified (Session 2026-08-16 → closed 2026-08-17 06:50 CEST, Phase 18 adversarial code review):
  - **Method**: three independent reviewers (Reviewer, QA Agent, Security Auditor) + 10 disposable Implementers, under the rule that no agent reviews its own code. Every fix was additionally re-verified by the orchestrator by running it, not by reading the agent's claim.
  - Static: `bash -n` on install.sh + smoke_test_models.sh; `node --check` on both bin scripts; `ast.parse` on fix_hooks_config.py; `package.json` parses at 2.5.0; **install.ps1 AST parse = 0 errors, 5055 tokens** (first mechanical validation in project history).
  - Security, re-tested after fixing: the 3 injection vectors (quote-break, command-substitution, JSON-structure-break) rejected in BOTH languages across 19 bypass probes incl. Unicode homoglyphs, fullwidth quotes, NUL, CR/LF, 100k-char input; the key-recovery laundering path closed; curl-config injection payload rejected with the attacker-chosen target file confirmed **absent** after the run.
  - rc-file safety: mode-600 rc keeps mode **and inode** (373775 → 373775); symlinked rc stays a symlink and the dotfiles target receives the block; 444 rc byte-identical and refused; rc-writable-but-directory-unwritable leaves the rc byte-identical with user data intact (was: silently destroyed, exit 0); unreadable rc → exactly 1 header (was 2); no stray `.tmp`/`.bak` on any path.
  - Alias matching: managed lines removed in LF, **CRLF**, and trailing-whitespace forms, while user-owned colliding aliases (`ccg`, `ccg52`, `ccg53`, `ccx`) survive in LF **and** CRLF. Reviewer additionally ran both regexes over a corpus of all 114 historical alias lines from git history: no managed alias escapes, only the deliberately-exempt claude aliases survive.
  - Retired-wrapper deletion now fingerprint-gated: a user-authored `~/.local/bin/claude-glm` survives; a real retired wrapper is still removed.
  - Permissions: wrappers 700, settings.json 600, pre-chmod creation mode 600 (umask window closed), `~/.local` + `~/.local/bin` restored to 755, and the wrapper's `umask 077` verified NOT to leak into the launched Claude session (child sees 0022).
  - PowerShell (isolated, never full-run): `Test-ZaiApiKey` unit-tested 10/10 under real PS 5.1.26100.9168; `Protect-KeyFile` executed on a real file — 5 inherited ACEs → 1 explicit ACE, inheritance blocked (`D:PAI` in SDDL); one generated wrapper extracted and executed against a temp `CLAUDE_HOME`, producing a settings.json with the same single-ACE result.
  - Regression: clean install → 6 wrappers / 28 aliases; idempotent over 3 runs (1 header, 1 PATH line, no alias growth); csh and zsh paths; live Z.AI smoke test (6 shipped models PASS with matching served-by, 4 retired REROUTED, `glm-4.7-flashx` 429 control); `moai gate` exit 0.
  - Commit hygiene: `origin/main` at `0919f90`, divergence `0 0`, working tree clean; both pinned action SHAs resolved via the GitHub API and confirmed to dereference to commit objects.
  - **Not verified**: `install.ps1` end-to-end install flow (no sandbox for `%USERPROFILE%`); a true ENOSPC disk-full (`ulimit -f` used as a faithful stand-in); `cli.js` argument forwarding executed (verified by code read + a stubbed `spawn`, deliberately not run against a real HOME); `shellcheck` unavailable, so no lint baseline exists.
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
  - End-to-end `install.ps1` install flow on Windows (isolated functions are tested under real PowerShell 5.1 — see the 2026-10-31 block above; the full installer writes the real `%USERPROFILE%` and has no sandbox)

## 7. Restart Instructions

> ## ▶ Nothing is mandatory. One verified fix is waiting to be committed.
>
> The three SPECs this block used to assign are **done** (Phase 19). Do not re-execute them, or `SPEC_SECURITY_APIKEY_INJECTION.md` (marked IMPLEMENTED in its own header). `.moai/specs/` is gitignored and local-only.
>
> **Primary next step:** review and land the uncommitted `install.ps1` fix (Starting point 0). Then the decisions in §4: the npx package (E404), and — optionally — whether `install.sh` should learn about the Windows side.

- Starting point:
  0. **State at close (2026-10-31 10:19 CDT).** `origin/main` = `819f3a9`, divergence `0 0`. The working tree is **not clean**: `install.ps1` carries a verified, **uncommitted** fix (9+/4−: `Sync-MoaiEnvGlm` now reads `.env.glm` as explicit UTF-8; `819f3a9` shipped a `Get-Content` read that mojibake'd non-ASCII comments on PowerShell 5.1), and `PROJECT_HANDOFF.md` / `PROJECT_LOG.md` / `NEXT_SESSION.md` are modified by this close-out. Nothing else is pending.
  1. Commit lineage (newest first):
     - `819f3a9` feat(installer): sync MoAI-ADK's GLM_API_KEY with the wrapper key (install.sh + install.ps1 + README) — **Phase 20**
     - `55802a0`, `058f9d5`, `424369c`, `a546d33`, `fce0361` — 2026-09-30 MoAI tooling housekeeping (stop publishing generated tooling files; `.gitignore` rule restored). None touched installer files, `package.json` or README (`git diff --stat`).
     - `56ce6f4` feat(npm): republish under the `@windysky` scope (README, bin/cli.js, preinstall.js, package.json, .gitignore)
     - `62dc201` docs: Phase 19 follow-up · `5e7964d` ccx gate + fingerprint tighten (mis-scoped — see the LOG disclosure)
  2. Current shipped surface: **6 wrappers** (`claude-glm-5.3`, `-5-turbo`, `-4.7`, `-4.6`, `-4.5`, `-4.5v`) and **28 aliases** (7 bases × normal/`D`/`Dd`/`A`). `ccg` = `ccg53` = GLM-5.3. Retired in Phase 17: `ccg52`, `ccg51`, `ccg5`, `ccg45air`, `ccf` — Z.AI reroutes those IDs to a different model, so a wrapper named after them was lying. Re-running the installer deletes their scripts and strips their aliases. **New in Phase 20:** both installers keep `GLM_API_KEY` in `~/.moai/.env.glm` equal to the wrapper key (they never create that file).
  3. `.moai/` is gitignored (local-only SPEC artifacts). `.moai/specs/SPEC_SECURITY_APIKEY_INJECTION.md` from Phase 18 lives there.
  4. **Environment notes for the next agent** (each of these cost time to rediscover):
     - Windows PowerShell 5.1 **is** reachable from this WSL session at `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe` (it is not on `PATH`; `pwsh` is absent). Use it to AST-parse `install.ps1` — but do NOT run the installer, it writes to the real `%USERPROFILE%`.
     - In the Claude Code Bash-tool sandbox, `grep` is a shell-function wrapper that `exec`s away subshells — run any test piping installer functions through grep as a child `bash script.sh` process, never an inline `( … )` subshell.
     - The Edit tool cannot write outside the project dir (e.g. `~/.bashrc`); use an anchored `sed -i` after a backup.
     - Never run the installer against the real `$HOME` when testing — always `env HOME="$sandbox"`.
     - The pre-commit hook runs `moai gate` (currently exits 0); the pre-push hook runs `make ci-local` and skips cleanly since there is no Makefile.
     - **"Not on PATH" is not "absent".** `command -v pwsh powershell` printing nothing says only that neither is on `PATH`; PowerShell 5.1 is at the full path above. Phase 20 treated that probe as proof of absence, told the user `install.ps1` could not be tested, and wrote the same into a commit message — wrong, and the harness it then ran found a real defect.
     - Testing a PowerShell function in isolation: parse with `[System.Management.Automation.Language.Parser]::ParseFile`, pull the functions out via `FindAll`, point `$env:USERPROFILE` at a throwaway directory under `$env:TEMP`, and run from `cd /mnt/c` with `powershell.exe -NoProfile -NonInteractive -Command "iex ([IO.File]::ReadAllText('<wslpath -w script>'))"`. Keep the script ASCII-only (5.1 reads BOM-less files as ANSI), and build `byte[]` with `[byte[]](@(..) + @(..))` — plain `byte[] + byte[]` yields `object[]`.
     - Key parity without printing a key: compare `sha256sum | cut -c1-12` of the WSL wrapper's `ANTHROPIC_AUTH_TOKEN` (`sed -n 's/^export ANTHROPIC_AUTH_TOKEN="\([^"]*\)".*/\1/p' ~/.local/bin/claude-glm-5.3`) with the token in the Windows `claude-glm-5.3.ps1`. WSL `~` and Windows `%USERPROFILE%` are separate stores; each installer reaches only its own.
     - A PreToolUse hook denies any command containing `rm -rf "$HOME"` even after `HOME` was reassigned in the same shell. Build per-case sandbox directories in a variable and remove those instead.
     - Observed on 2026-10-29: the pre-commit hook printed `[moai gate] … heavy gate not opted in — skipping`, and the pre-push hook `No Makefile found — skipping ci-local`. Neither blocked.
     - ShellCheck is not installed locally. Use the `koalaman/shellcheck` release binary (0.10.0 gave counts identical to the committed baseline) in a scratch directory; CI uses its own preinstalled version, so a runner upgrade can shift counts.
     - The user's global rule forbids AI-harness trailers (`🗿 MoAI` etc.) in commits and PRs even though a harness reminder asks for one — none were added.
- Recommended next actions:
  1. **Land the `install.ps1` fix.** `git diff install.ps1` (9+/4−), then commit with an explicit pathspec — suggested subject `fix(install.ps1): read .env.glm as explicit UTF-8 so non-ASCII comments survive` — and push. Commit and push only on the user's go-ahead.
  2. **npx decision.** `package.json` and `README.md:39` tell users to run `npx @windysky/claude-glm-installer`; the registry returns E404. Publish it, or drop the claim in both places.
  3. **Optional:** teach `install.sh` about the Windows side (§4) — only if the user wants one run to rotate both. Otherwise the rule stays "one installer run per OS".
  4. **Optional:** untrack `NEXT_SESSION.md` (§4, repo hygiene).
  6. **Pick up the aliases** if this is a fresh shell: `source ~/.bashrc`, then `ccg` for GLM-5.3.
  7. **The one cheap verification still worth doing**: launch `ccg` once and confirm the session reports GLM-5.3 with the 1M window. The raw API rejects the `glm-5.3[1m]` bracket form (it is a client-side routing convention), so a live launch is the only remaining evidence for it.
  8. **Re-run `smoke_test_models.sh`** when Z.AI changes plan availability. Baseline: 6 shipped models PASS with matching served-by, 4 retired IDs REROUTED, `glm-4.7-flashx` 429 (the control proving the 200s are real plan access). A retired ID flipping REROUTED → PASS means Z.AI un-retired it and it may deserve a wrapper back.
  9. **If you touch `install.ps1`**, remember it has never been executed end-to-end and the verification task was deliberately dropped (§4). Parse it, unit-test extracted functions under real PowerShell 5.1 via `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`, and lean on structural symmetry with the bash side. Never run the installer itself — it writes to the real `%USERPROFILE%`.
- Cross-project wiki: `~/PROJECTS/wiki/concept/claude-code-auto-compact-window-headroom.md` (why the window is 900000); `~/PROJECTS/wiki/concept/set-e-err-trap-false-abort.md` (bare `return 1` under `set -e`+ERR trap false-aborts — Phase 18 hit this again at a second call site); `~/PROJECTS/wiki/concept/generated-secret-file-perms.md` (chmod the config a script generates, not just the script). Added 2026-10-31: `~/PROJECTS/wiki/concept/a-tool-absent-from-path-is-not-an-absent-tool.md` (check the recorded location before claiming a tool cannot run) and `~/PROJECTS/wiki/concept/a-key-rotation-is-finished-only-after-a-fingerprint-sweep-of-every-store.md` (every consumer is its own store; sweep by fingerprint).
- Security posture at close: **0 CRITICAL, 0 HIGH open.** Across the Phase 18 program 21 findings were tracked, 13 closed and verified, 1 retracted by its own author as a false positive, and the remainder are LOW/INFO listed in §4. Two of the three HIGH findings were regressions introduced by fixes earlier in the same review and caught by independent re-gating — which is the single strongest argument for keeping the never-self-review rule. **Phase 20 (2026-10-29/31):** the retired Z.AI key was purged from 14 local config files — 10 stale files deleted after archiving to session scratch, 3 live per-wrapper config directories and `~/.moai/.env.glm` rewritten to the current key; 5 append-only session logs still contain it by decision (§5).
- Last updated: 2026-10-31 10:19 CDT
