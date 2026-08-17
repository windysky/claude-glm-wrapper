# Project Handoff

## 1. Project Overview
- Purpose: Local wrapper/installer scripts to run Claude Code against Z.AI GLM models via per-model `CLAUDE_HOME` directories.
- Scope: Cross-platform install scripts + docs for `ccg` (GLM-5.3, default, 1M context), `ccg53` (GLM-5.3), `ccg5t` (GLM-5-Turbo), `ccg47` (GLM-4.7), `ccg46` (GLM-4.6), `ccg45` (GLM-4.5), and `ccg45v` (GLM-4.5V vision) — **6 wrappers, each verified to serve the model its name claims**. Each wrapper uses Z.AI's opus/sonnet/haiku tier scheme (opus+sonnet = its own model, haiku = glm-4.7). Installer manages GLM aliases only — the bare `claude` command and any user-curated `ccd`/`ccdD`/`claudeD` aliases are intentionally untouched.
- **Retired in Phase 17** (Z.AI silently reroutes these IDs while still returning HTTP 200): `ccg52`/`ccg51`/`ccg5` (served by glm-5.3), `ccg45air`/`ccf` (served by glm-4.7). The installer now deletes their wrapper scripts and strips their aliases on re-run.
- Last updated: 2026-08-17 11:43 CEST
- Last coding CLI used (informational): Claude Code CLI (Opus 5, 1M context)
- Current version: 2.5.0 (package.json)
- Latest commit on `main`: `b0ff602`, pushed to origin. Working tree **clean**. Lineage: `b0ff602` (Phase 18 end-of-session docs) ← `0919f90` (tooling config) ← `18d49e6` (CI + SHA-pinned actions) ← `985d5d6` (.gitignore bin/ fix) ← `c7839e4` (Phase 18 docs) ← `02c4bd4` (17 review fixes, v2.5.0) ← `347801f` (Phase 16 docs).

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

## 4. Outstanding Work

> **Three SPECs are ready to execute.** They live in `.moai/specs/` (gitignored, local-only) and are the next agent's work queue. See §7 for the exact starting point.
> `SPEC_LOW_DEFECTS_CLEANUP.md` · `SPEC_SHELLCHECK_BASELINE.md` · `SPEC_INDEPENDENT_REVIEW_ORCHESTRATOR_FIXES.md`
> `SPEC_SECURITY_APIKEY_INJECTION.md` is marked IMPLEMENTED in its own header — retained as a record, **do not re-execute**.

- **`package.json` advertises an npx entry point that fetches somebody else's package.**
  - Status: Open (LOW — nothing user-facing is broken today)
  - Discovered 2026-08-17 while resolving the Windows-user question. `package.json` `description` says *"Run with: npx claude-glm-installer"*, and `bin` declares that name — but `npm view claude-glm-installer` resolves to **upstream JoeInnsp23's v1.0.3** (`repository.url = JoeInnsp23/claude-glm-wrapper`), not this fork's v2.5.0. Anyone following that instruction runs a different, older codebase and would not know.
  - Not currently harmful: `README.md` only documents `git clone` + `bash install.sh`; the stale npx claim exists solely in `package.json`'s description field.
  - Options: drop the npx claim from the description, or publish under a distinct name. Not decided.
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
  - Status: Open — filed as `SPEC_CCX_UNCONDITIONAL_DELETE` (MEDIUM)
  - Date opened: 2026-08-17 (Phase 19 review, finding F2)
  - Context: no fingerprint gate, no prompt, no authorship check — the hazard class R3 fixed 450 lines earlier. The line sits above the existing-installation menu, so choosing "4) Cancel" deletes the user's file anyway; reproduced. The R3 gate could not be reused because the historical `ccx` wrapper pointed at `http://127.0.0.1:${PORT}` and is the only wrapper form in project history lacking the Z.AI fingerprint.
- Risk: `managed_value`'s `claude-glm[A-Za-z0-9._-]*` wildcard deletes a user's own alias line.
  - Status: Open — filed as `SPEC_ALIAS_GLM_WILDCARD_OVERMATCH` (LOW-MEDIUM)
  - Date opened: 2026-08-17 (Phase 19 review, finding F1)
  - Context: `alias ccg='claude-glm-wrapper-mine'` is removed, contradicting the guarantee at `install.sh:995-999`. Pre-dates R1 (verified by differential against the pre-R1 regex); R1 extended its reach to CRLF rc files, which is unavoidable when closing the under-match. **R1 must not be reverted** — reverting restores 28 permanently stale aliases on every CRLF rc.
- Risk: the retired-wrapper fingerprint matches a comment, not only an executable reference.
  - Status: Open — filed as `SPEC_FINGERPRINT_COMMENT_MATCH` (LOW; decision required, may close WONTFIX)
  - Date opened: 2026-08-17 (Phase 19 review, finding F3)
  - Context: `grep -q 'api\.z\.ai/api/anthropic'` matches anywhere in the file, so a user script carrying a retired name *and* mentioning the endpoint in a comment is deleted. Narrow precondition; tightening risks the worse failure of leaving a key-bearing retired wrapper undeletable.
- Risk: the removal-failure warning path at `install.sh:889-890` cannot be exercised.
  - Status: Open (informational — not filed as a SPEC)
  - Date opened: 2026-08-17 (Phase 19 review, finding F4)
  - Context: making a wrapper unremovable requires removing write permission from the *directory* (`rm -f` needs directory write, not file write), and that same change aborts the install earlier at wrapper creation (`install.sh:552`). Reaching the warning needs an immutable attribute or a foreign-owned sticky directory — root-only setups. The path is not shown defective, only untestable; do not rely on that warning as a safety net.

## 6. Verification Status
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
  - PowerShell script execution on Windows (reason: not run in this environment)

## 7. Restart Instructions

> ## ▶ YOUR JOB: execute three SPECs
>
> They are in `.moai/specs/` (gitignored, local-only). Execute them **in this order** — the dependency is real, not cosmetic:
>
> 1. **`SPEC_INDEPENDENT_REVIEW_ORCHESTRATOR_FIXES.md`** — do this FIRST. It is a *review* SPEC: the deliverable is a verdict plus `file:line` findings, **not a diff**, and findings must be filed as new SPECs rather than fixed inline. It audits four fixes in `install.sh` that carry the same author for both implementation and verification. Running it first means the other two build on reviewed ground; running it last means possibly reviewing code that has already moved.
> 2. **`SPEC_LOW_DEFECTS_CLEANUP.md`** — four LOW defects, all with reproductions. **Read its §1a carefully**: an earlier prescription of `mapfile -t` was caught as defective (bash 4.0+ only; macOS ships 3.2.57, and `install.sh` currently uses zero bash-4 constructs — under `set -eE` it would 127 into the ERR trap and hand every macOS user a file-a-bug prompt; it also breaks the empty-array case into a phantom entry that reaches `rm ""`). The SPEC carries the corrected bash-3.2-safe `while read` form. **Do not "simplify" it back to `mapfile`.**
> 3. **`SPEC_SHELLCHECK_BASELINE.md`** — install shellcheck, lint 4 shell files at the correct per-file dialect (`install.sh`/`smoke_test_models.sh` are bash; `.git_hooks/pre-commit`/`pre-push` are `#!/bin/sh`), record a versioned baseline. It recommends accepting the existing findings as debt and gating only NEW ones — that recommendation is argued in the SPEC; read the argument before overriding it.
>
> `SPEC_SECURITY_APIKEY_INJECTION.md` is marked **IMPLEMENTED** in its own header. It is a record of Phase 18 work. **Do not re-execute it.**
>
> **Not audited:** these SPECs' proportionality, acceptance-criteria quality, and the shape of the review SPEC were never independently reviewed — `plan-auditor` was spawned and never delivered (mailbox routing failed four times). Their *factual claims* were verified against the real files. Treat the structure with normal scepticism.

- Starting point:
  0. **Nothing is in flight. Working tree is clean and everything is pushed.** `origin/main` = `b0ff602`, divergence `0 0`. Phases 17 and 18 are both fully committed. There is no half-finished work to resume and no uncommitted state to reconcile. The SPECs above are new work, not resumed work.
  1. Commit lineage (newest first):
     - `0919f90` chore: MoAI-ADK tooling configuration (CLAUDE.md condensed, .mcp.json, .claudeignore, .worktreeinclude, .agency.archived/)
     - `18d49e6` ci: label-sync workflow + git hooks, **actions SHA-pinned**
     - `985d5d6` fix: `.gitignore` no longer silently ignores this package's `bin/` entry point
     - `c7839e4` docs: Phase 18 session record
     - `02c4bd4` fix: **17 review defects, 3 HIGH security** (v2.5.0)
     - `347801f` docs: Phase 16 end-of-session ← previous session's tip
  2. Current shipped surface: **6 wrappers** (`claude-glm-5.3`, `-5-turbo`, `-4.7`, `-4.6`, `-4.5`, `-4.5v`) and **28 aliases** (7 bases × normal/`D`/`Dd`/`A`). `ccg` = `ccg53` = GLM-5.3. Retired in Phase 17: `ccg52`, `ccg51`, `ccg5`, `ccg45air`, `ccf` — Z.AI reroutes those IDs to a different model, so a wrapper named after them was lying. Re-running the installer deletes their scripts and strips their aliases.
  3. `.moai/` is gitignored (local-only SPEC artifacts). `.moai/specs/SPEC_SECURITY_APIKEY_INJECTION.md` from Phase 18 lives there.
  4. **Environment notes for the next agent** (each of these cost time to rediscover):
     - Windows PowerShell 5.1 **is** reachable from this WSL session at `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe` (it is not on `PATH`; `pwsh` is absent). Use it to AST-parse `install.ps1` — but do NOT run the installer, it writes to the real `%USERPROFILE%`.
     - In the Claude Code Bash-tool sandbox, `grep` is a shell-function wrapper that `exec`s away subshells — run any test piping installer functions through grep as a child `bash script.sh` process, never an inline `( … )` subshell.
     - The Edit tool cannot write outside the project dir (e.g. `~/.bashrc`); use an anchored `sed -i` after a backup.
     - Never run the installer against the real `$HOME` when testing — always `env HOME="$sandbox"`.
     - The pre-commit hook runs `moai gate` (currently exits 0); the pre-push hook runs `make ci-local` and skips cleanly since there is no Makefile.
- Recommended next actions:
  1. **Execute the three SPECs** in the order given above. That is the primary work.
  2. **Pick up the aliases** if this is a fresh shell: `source ~/.bashrc`, then `ccg` for GLM-5.3.
  3. **The one cheap verification still worth doing**: launch `ccg` once and confirm the session reports GLM-5.3 with the 1M window. The raw API rejects the `glm-5.3[1m]` bracket form (it is a client-side routing convention), so a live launch is the only remaining evidence for it.
  4. **Re-run `smoke_test_models.sh`** when Z.AI changes plan availability. Baseline: 6 shipped models PASS with matching served-by, 4 retired IDs REROUTED, `glm-4.7-flashx` 429 (the control proving the 200s are real plan access). A retired ID flipping REROUTED → PASS means Z.AI un-retired it and it may deserve a wrapper back.
  5. **If you touch `install.ps1`**, remember it has never been executed end-to-end and the verification task was deliberately dropped (§4). Parse it, unit-test extracted functions under real PowerShell 5.1 via `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`, and lean on structural symmetry with the bash side. Never run the installer itself — it writes to the real `%USERPROFILE%`.
- Cross-project wiki: `~/PROJECTS/wiki/concept/claude-code-auto-compact-window-headroom.md` (why the window is 900000); `~/PROJECTS/wiki/concept/set-e-err-trap-false-abort.md` (bare `return 1` under `set -e`+ERR trap false-aborts — Phase 18 hit this again at a second call site); `~/PROJECTS/wiki/concept/generated-secret-file-perms.md` (chmod the config a script generates, not just the script).
- Security posture at close: **0 CRITICAL, 0 HIGH open.** Across the Phase 18 program 21 findings were tracked, 13 closed and verified, 1 retracted by its own author as a false positive, and the remainder are LOW/INFO listed in §4. Two of the three HIGH findings were regressions introduced by fixes earlier in the same review and caught by independent re-gating — which is the single strongest argument for keeping the never-self-review rule.
- Last updated: 2026-08-17 11:43 CEST
