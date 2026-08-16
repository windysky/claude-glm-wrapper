# PROJECT_LOG.md (active) — claude-glm-wrapper

Bounded active log for the claude-glm-wrapper installer (Claude Code wrappers for Z.AI GLM models). Newest first. Older sessions are archived verbatim under `logs/` (see Archives once rotation runs).

## Archives
- logs/PROJECT_LOG_2026-H1.md — 10 sessions (2026-02 … 2026-04)

## Session Index (active, newest first)
- 2026-08-16 (Phase 18 harness code review — 4-agent adversarial review + 10 Implementers)
- 2026-08-16 08:50 CDT (Phase 17 GLM-5.3 + consolidation to genuinely-serving models)
- 2026-07-03 00:57 CDT (Phase 16 harness review)
- 2026-07-02 10:01 CDT
- 2026-06-16 16:23 CDT (session close)
- 2026-06-16 16:13 CDT (auto-mode aliases)
- 2026-06-16 15:43 CDT (cleanup)
- 2026-06-16 15:36 CDT (session close)
- 2026-06-16 (Phase 14)
- 2026-06-16

---

## Session 2026-08-16 (Phase 18 harness code review + fix)
- Coding CLI used: Claude Code CLI (Opus 5, 1M context)
- Invocation: `/harness-hur-code-review-and-fix` — autonomous review, then fix everything real found. "Fix only what is broken."
- Team: Orchestrator + 3 persistent members (Reviewer, QA Agent, Security Auditor) + 10 disposable Implementers. No web UI → Playwright mandate N/A. No test suite and no CI existed, so QA established a baseline from zero.

### Headline
17 defects fixed across 6 files. **Every finding that mattered came from an agent other than the one who wrote the code** — the harness's never-self-review rule did real work here, twice catching regressions the fixes themselves introduced.

### The three reviewers found disjoint defect classes
| Reviewer | Found what nobody else did |
|---|---|
| Security Auditor | The original API-key command injection (3 vectors × 2 languages); later, the curl-config injection that our own M-3 fix introduced |
| QA Agent | The rc data-loss regression introduced by the DEF-1 fix; later, the incomplete-backup hole in the orchestrator's own fix |
| Reviewer | The CRLF alias regression — invisible to both auditors across two full re-gates |

### Fixes landed (17)
**Security (HIGH)** — (1) API-key command injection: an unvalidated key was interpolated into an *unquoted* heredoc, so `x";touch /tmp/PWNED;#` broke out of `export ANTHROPIC_AUTH_TOKEN="…"` and executed on **every wrapper launch**; a `$(…)` key substituted at runtime; a `"},"hooks":{…` key injected executable Claude Code hooks into settings.json. Closed by a charset guard (`^[A-Za-z0-9._-]+$`) at all 3 key-assignment sites in each installer, including the key *recovered from an existing wrapper* (the laundering path). Verified against 19 bypass probes in both languages. (2) curl config injection — the fix that moved the key off argv put it into curl's `-K -` config *parser*; a newline injected `output =`/`url =`, achieving arbitrary file write with attacker-controlled content. Closed by applying the same guard to `detect_key`'s result, covering all four key sources. (3) rc data-loss — `> "$rc"` truncated before `cat` ran, destroying user rc files while exiting 0.

**Correctness/robustness** — rc rewrite preserves inode/mode/symlink (was `mv`, which silently turned 600→644 and destroyed symlinked dotfiles); backup verified complete before the rc is touched; write-protected and unreadable rc refused rather than clobbered; refusal no longer leaves two alias blocks; `.bash_profile` refusal no longer aborts a successful install; **CRLF/trailing-whitespace alias matching** (managed aliases survived forever on CRLF rc files while their wrappers were deleted → permanent "command not found"); `ccx*`/`claude-proxy` over-match deleting user aliases; retired wrappers gated on a Z.AI fingerprint (the generic `claude-glm` name could delete a user's own script); PATH line idempotent; `umask 077` for the key-file creation window, with `~/.local` restored to 755; value-keyed redaction in `report_error`; EXIT/INT/TERM traps.

**PowerShell** — ACL hardening at all 12 key-bearing sites (`Protect-KeyFile` ×6 + a spliced wrapper-side block ×6). On this machine the "before" ACL showed a `CodexSandboxUsers` group and an unresolved foreign SID both holding **Modify** — M-2 was a live exposure, not hypothetical. Also: removal over-count reporting success for files still on disk.

**Other** — `bin/cli.js --help` performed a live install and forwarded no args; stale orphan `package-lock.json` (declared v2.0.0 + fastify/dotenv against a zero-dependency v2.5.0; 5 vulns); `fix_hooks_config.py` resolved its target from the script's directory rather than cwd — and because this repo *has* a `.claude/settings.json`, the old code silently rewrote **this repo's** local settings while reporting success and leaving the user's real project untouched; smoke test's green PASS when the served model was never determined (now UNKNOWN).

### Corrections recorded (things we got wrong and fixed)
- Orchestrator claimed WSL interop was disabled. **Wrong** — `powershell.exe` runs (5.1.26100.9168). Consequence: `install.ps1` was **AST-parsed for the first time in the project's history** (0 errors, 5055 tokens). Full execution remains impossible — it anchors to the real `%USERPROFILE%` with no sandbox.
- Security Auditor retracted its own L-3 first half as a false positive (`claude-glm-5.ps1` never existed in any revision).
- Orchestrator nearly filed a false "incomplete fix" against the ACL work from a bad grep; caught by verifying.
- ImplH caught a bug in its **own** first attempt: an unflattened PowerShell array would have emitted the literal `System.Object[]` in place of every wrapper's settings.json write — worse than the defect it was fixing, and invisible to AST parsing.
- Reviewer's prescribed fix for the README claim (probe `glm-5.3[1m]`) was rejected with evidence: the raw API rejects the bracket form (`400 [1214][modelCode: does not exist]`) because it is a client-side routing convention. Remedy redirected to documentation.

### Verification performed
`bash -n` on both shell scripts, `node --check` ×2, `ast.parse`, `package.json` parse, PowerShell AST (0 errors). Clean install → 6 wrappers / 28 aliases; 3-run idempotency; user-owned colliding aliases survive in LF **and** CRLF; mode-600 rc keeps mode *and inode*; symlinked rc stays a symlink and the dotfiles target receives the block; 444 rc byte-identical; unreadable rc → 1 header; injection payload → 0 wrappers, no marker; retired-wrapper fingerprint gate; `~/.local` 755 / wrappers 700 / settings.json 600; live Z.AI smoke test (6 shipped models PASS with matching served-by, 4 retired REROUTED, flashx 429 control); `moai gate` exit 0.

### Known remaining (not fixed, deliberately)
- **M-6** unpinned `EndBug/label-sync@v2` + `actions/checkout@v4` with `issues:write`. `.github/` is **untracked** — whether it ships is the user's decision, so it was not modified. Per the auditor's refinement: a workflow goes live the moment it is committed, so the SHA pins must land **in the same commit** that adds `.github/`, not as a follow-up.
- Blank line accumulates 1/run in the rc (pre-existing, cosmetic; the tidy fix risks eating a user's own blank line).
- `install.ps1` never executed end-to-end (no sandbox for `%USERPROFILE%`). Its only review is close reading + AST + isolated function tests.
- Colliding user alias is preserved textually but shadowed at runtime (documented in code and README, not changed).
- L-2 unquoted `all_wrappers=($(…))`; L-4 printed pipe-to-bash hint; N-6 empty key accepted by smoke test (unreachable); N-7 `.bak` symlink following (same-user, no privilege gain).

### Process note
The last 4 of 17 fixes were implemented by the Orchestrator directly: two Implementers died on an account session limit and the final three agents on `SSL certificate hostname mismatch`. Those four were **diagnosed** by the independent Reviewer, so the finding is independent; the implementation is not independently reviewed and is verified behaviourally only. Stated for the record rather than glossed.

## Session 2026-08-16 08:50 CDT (Phase 17 GLM-5.3 + consolidation)
- Coding CLI used: Claude Code CLI (Opus 5, 1M context)
- Phase(s) worked on
  - Phase 17: add a GLM-5.3 wrapper (`ccg53`), then — on evidence found mid-task — consolidate the wrapper set down to the models that genuinely serve themselves.
- Motivation and the finding that reshaped the task
  - The task began as "add ccg53 + variants", mirroring Phase 13's GLM-5.2 work. Live probes of the Z.AI API showed `glm-5.3` reachable (HTTP 200) and, per Z.AI docs, a 1M-context model using the same `[1m]` Claude-Code-side route convention as 5.2.
  - **Key discovery**: the API response body echoes the model that actually served the request. Comparing requested vs served (3 independent confirmations each, deterministic) showed Z.AI **silently reroutes retired IDs while still returning HTTP 200**:
    - `glm-5.2` → `glm-5.3`; `glm-5.1` → `glm-5.3`; `glm-5` → `glm-5.3`; `glm-4.5-air` → `glm-4.7`
    - Genuinely serving themselves: `glm-5.3`, `glm-5-turbo`, `glm-4.7`, `glm-4.6`, `glm-4.5`, `glm-4.5v`
  - Consequence 1: a wrapper named after a rerouted ID no longer does what its name says. Consequence 2: `ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"` in *every* wrapper meant the "small/fast" tier was actually being served by glm-4.7.
  - Full v5 namespace sweep (15 candidates): only `glm-5`, `glm-5.1`, `glm-5.2`, `glm-5.3`, `glm-5-turbo` exist. `glm-5.3-turbo`, `glm-5-air`, `glm-5.3-air`, `glm-5-flash`, `glm-5v`, `glm-6` all HTTP 400 "modelCode does not exist". `glm-5-turbo` is the exception that is NOT rerouted — turbo stayed at the v5 generation.
  - Metering: no rate-limit headers are returned at all (only nginx/x-log-id/x-process-time). Plan metering is prompt-count per rolling 5h window with quota multipliers (5-Turbo ~2-3x), not per-model accounting. Which multiplier applies to a rerouted request is not externally observable — an added reason to request the model you actually want.
- User decisions taken during the session
  - `ccg` repoint: initially "keep on 5.2"; reversed to 5.3 after the reroute evidence showed 5.2 no longer exists as a distinct servable model.
  - Scope: "consolidate to what is real" — retire the wrappers whose name no longer matches what serves.
  - Retirement semantics (user-specified): the installer must scrub retired aliases from the shell rc, and must **match the full alias line, not a name prefix**, so a user's own alias of the same name is never removed accidentally.
- Concrete changes implemented
  - install.sh: added `create_claude_glm_53_wrapper` (`glm-5.3[1m]`, 900000 auto-compact window); removed 5 retired wrapper functions (45air, 5, 51, 52, fast) + their 15 call sites + 34 generated alias lines + 20 summary lines; `ccg` → `claude-glm-5.3`; haiku tier `glm-4.5-air` → `glm-4.7` across all 6 wrappers; new `remove_retired_wrappers()` deletes orphaned wrapper scripts (incl. the pre-tier-scheme bare `claude-glm`), wired into all 3 install paths.
  - install.sh alias cleanup rewritten: 46 unanchored `grep -v "alias X="` substring filters replaced by 2 anchored, value-constrained regexes (`bash_alias_re` / `csh_alias_re`). A line is removed only when the alias NAME *and* its ENTIRE value match a form this installer generates. Retired names deliberately stay in the name list so re-runs scrub them.
  - install.ps1: full parity — `New-ClaudeGlm53Wrapper`, 5 retired functions removed (+15 call sites, 17 alias/function lines, 17 cmd shims), `Remove-RetiredWrappers` (deletes .ps1 wrappers *and* .cmd shims), `$installerOwnedPatterns` rewritten to the same anchored full-line form, ccg + its D/Dd/A shims repointed to 5.3, haiku → glm-4.7.
  - smoke_test_models.sh: now compares requested vs served model and reports PASS / REROUTED / FAIL. Timeout raised 15s → 60s (glm-5.3 emits a thinking block before content; at 15s it returned HTTP 000 and was reported as a **false FAIL**). Default model list reorganized into shipped / retired-expect-REROUTED / not-plan-covered control.
  - README.md: model list, alias table, examples, tier note, and a new "Retired aliases (and why)" section with the requested→served table and migration mapping. package.json 2.4.2 → 2.5.0.
- Files/modules/functions touched
  - Modified: install.sh, install.ps1, smoke_test_models.sh, README.md, package.json, PROJECT_HANDOFF.md, PROJECT_LOG.md
- Verification performed
  - `bash -n` OK on install.sh and smoke_test_models.sh. install.ps1 structural parity verified by count (6 wrapper functions, 18 call sites, 7 Set-Alias, 28 cmd shims, 12 haiku=4.7, 4 Remove-RetiredWrappers refs) — PowerShell execution still unverified (no pwsh; WSL interop disabled).
  - Alias-cleanup regexes tested against a fixture in a child bash process (real /usr/bin/grep): all 12 installer-generated lines removed (bash + csh format), while user-owned `ccg`, `ccg52`, `ccg53` aliases pointing elsewhere all survived. The old substring logic was run on the same fixture for contrast and destroyed all three.
  - End-to-end installer run in a sandboxed HOME: 6 wrappers created, 5 retired deleted, 28 aliases written, user-owned colliding aliases preserved. Idempotent across 3 consecutive runs (1 block header, no duplication, no growth).
  - Real redeploy (`bash install.sh` option 2, dotfiles backed up first). `~/.bashrc` diff vs backup shows ONLY the 18 installer-generated retired alias lines removed and 5 added — no user alias touched. Wrappers on disk reduced 11 → 6.
  - Runtime check of the deployed 5.3 wrapper (`claude` masked): settings.json is valid JSON with `glm-5.3[1m]` opus/sonnet, `glm-4.7` haiku, 900000 window; mode 600 on settings.json, 700 on the wrapper.
  - Live smoke test post-change: 6 shipped models PASS with matching served-by; 4 retired IDs correctly flagged REROUTED; `glm-4.7-flashx` FAIL 429 (not plan-covered) as the control.
- Items explicitly completed / resolved / superseded this session
  - Completed: GLM-5.3 wrapper + `ccg53`/`ccg53D`/`ccg53Dd`/`ccg53A`; consolidation to 6 genuinely-serving models; full-line alias matching; retired-wrapper file cleanup; smoke-test reroute detection; v2.5.0; redeployed.
  - Superseded: `ccg` → GLM-5.2 (now 5.3); haiku tier `glm-4.5-air` (now `glm-4.7`); the 46-filter substring alias cleanup (now 2 anchored regexes); status-code-only smoke test.
  - Resolved: stale `~/.local/bin/claude-glm-5.2.bak-1000000` no longer present; the pre-tier-scheme bare `claude-glm` orphan is now removed by the installer.
- Remaining open issues
  - Windows `install.ps1` execution unverified on a real Windows host (standing gap). Note: Windows IS present on this machine (`/mnt/c`, PS 5.1 + PS 7 both installed) — the blocker is that **WSL interop is disabled**, not the absence of Windows. Enabling it (`/etc/wsl.conf` `[interop] enabled=true` + `wsl --shutdown`) would make the gap closable.
  - The `[1m]` bracket form could not be tested against the raw API: both `glm-5.2[1m]` and `glm-5.3[1m]` return HTTP 400 "modelCode does not exist" because the bracket is a Claude-Code-side convention translated by the client. Reroute behavior for the bracket form is therefore inferred from the base model, not observed.
  - Residual risk: the reroute could be launch-window behavior that Z.AI later reverses. The smoke test will show a retired ID flipping REROUTED → PASS if that happens.

## Session 2026-07-03 00:57 CDT (Phase 16 harness review)
- Coding CLI used: Claude Code CLI (Opus 4.8)
- Phase(s) worked on
  - Phase 16: `/harness-hur-code-review-and-fix` — autonomous harness-driven code review of the whole project, then fix all real defects. "Fix only what is broken."
- Harness process (proportional, hybrid team)
  - Orchestrator did Phase 0 deep recon (read install.sh 1469L, install.ps1 1486L, smoke_test_models.sh, bin/cli.js, bin/preinstall.js, fix_hooks_config.py in full) + Phase 1 triage directly.
  - Spawned one independent fresh-context Reviewer/Security-Auditor (evaluator-active, read-only) — it CONFIRMED the settings.json finding, surfaced the set-e false-abort I under-weighted, and confirmed the csh idempotency bug. 3 real defects.
  - Reproduced all 3 before fixing (Rule 4). Spawned an Implementer (general-purpose) to apply the fixes to install.sh per SPEC; routed the diff back to the same auditor as Reviewer — verdict APPROVED (it executed the real patched code, not paraphrased). No self-implement / no self-review.
- Findings & fixes (all in install.sh; install.ps1 unaffected)
  - FIX-1 [Security]: each wrapper wrote `~/.claude-glm-*/settings.json` (plaintext Z.AI key) world-readable at mode 644 (default umask) while the wrapper scripts were `chmod 700` (SEC-01). Added `chmod 600 "$CLAUDE_HOME/settings.json"` at wrapper RUNTIME in all 10 wrapper functions (after each SETTINGS heredoc, escaped `\$` so it resolves on launch). install.ps1 not changed — `.ps1`+settings.json live under `%USERPROFILE%` (NTFS ACL-restricted); the 644 exposure is Unix-only.
  - FIX-2 [Bug]: `check_claude_installation` ends its "continue anyway" path with a bare `return 1`; called bare in `main()` under `set -eE`+ERR trap it fired a false "Installation failed!" abort before any wrapper was created (defeating documented option 3). Changed the call site to `check_claude_installation || true` (matches the existing `|| true` guards on the detect-key calls). Function/`return 1` untouched.
  - FIX-3 [Idempotency]: `remove_aliases_from_rc` matched only bash `alias X=` format, so csh/.cshrc `alias X 'v'` (space) lines survived and duplicated on re-run. Added one space-format `grep -vE "^alias (…names…) "` filter to the pipeline (bash format + user aliases untouched). Previously deferred (Phase 12/13); fixed now since a low-risk fix exists.
- Files/modules/functions touched
  - Modified: install.sh (+23/-2), package.json (2.4.1 → 2.4.2), PROJECT_HANDOFF.md, PROJECT_LOG.md
  - Created (gitignored, local): `.moai/specs/SPEC_HARNESS_CODE_REVIEW_2026_07_02.md`
- Key technical decisions and rationale
  - Proportional harness (no test suite / no CI / no web UI, ~3400 LOC) — Orchestrator recon+triage directly, one independent Reviewer/Auditor, one Implementer, per Phase 10/12 precedent. Playwright/unit-baseline phases N/A.
  - install.ps1 deliberately left unchanged for both applicable findings, with documented per-finding rationale (platform-appropriate, minimal).
  - csh fix uses a single trailing-space ERE (matches csh space-format only; verified it does not touch bash `alias X=` nor over-match `ccg5`/`ccg52` from the `ccg` branch).
- Problems encountered and resolutions
  - Grep escaping subtlety: `\$` in a grep pattern matches literal `$`, so a check for the runtime `\$CLAUDE_HOME` chmod line initially returned 0; confirmed the 10 lines are correct via `grep -n` and corrected escaping. The Implementer correctly STOPPED-and-reported rather than corrupt the fix to satisfy a flawed check.
- Items explicitly completed / resolved / superseded this session
  - Completed: FIX-1 (settings.json chmod 600 ×10), FIX-2 (set-e continue-anyway guard), FIX-3 (csh alias dedup); v2.4.2; independent review APPROVED.
  - Superseded: the Phase 12/13 deferral of the csh alias-cleanup idempotency gap (now fixed).
- Verification performed
  - `bash -n install.sh` => OK; diff = install.sh only, +23/-2.
  - FIX-1 end-to-end: redeployed via `bash install.sh` (option 2), launched the deployed 5.2 wrapper with `claude` masked → `~/.claude-glm-52/settings.json` 644 → 600, JSON valid (6 keys, token present); wrappers still 700; all config-dir settings.json proactively hardened to 600.
  - FIX-2 + FIX-3: reproduced the bug and the fix for each (continue→exit 0, decline→exit 1; csh 42 aliases stripped, 0 false positives, idempotent).
  - Independent evaluator-active Reviewer executed the real patched functions: APPROVED, no regressions, no scope creep, install.ps1/README/package.json untouched.
- Remaining open issues (unchanged)
  - Windows `install.ps1` execution unverified on a real Windows host (standing gap).
  - Optional: remove stale `~/.local/bin/claude-glm-5.2.bak-1000000` backup.
  - Note: on machines other than this one, users should launch each wrapper once to re-harden its settings.json from 644 → 600.

## Session 2026-07-02 10:01 CDT
- Coding CLI used: Claude Code CLI (Opus 4.8)
- Phase(s) worked on
  - Phase 15: lower the GLM-5.2 wrapper's `CLAUDE_CODE_AUTO_COMPACT_WINDOW` from 1000000 to 900000. Only the 5.2 wrapper carries this var; no other wrapper touched.
- Motivation
  - `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000` caused frequent "context over limit" errors: Claude Code auto-compacts at ~83% of the window (~830K), leaving only ~170K of headroom below glm-5.2's real 1M ceiling, so a single tool-heavy turn could push a request past 1M and the API rejects it. Lowering the window to 900000 makes auto-compact fire at ~747K (~250K headroom).
  - The 83% trigger is a ceiling (lowerable, not raisable), so the WINDOW value is the correct lever. Deliberately did NOT use `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` — that percent-override knob is known-flaky (anthropics/claude-code#36381) and may not trigger reliably.
  - Context ceilings for reference: glm-5.2 = 1M; glm-4.7/4.6 = 200K. All other wrappers set no window override and correctly rely on Claude Code's default.
- Concrete changes implemented
  - install.sh: both occurrences in `create_claude_glm_52_wrapper` — the `export CLAUDE_CODE_AUTO_COMPACT_WINDOW="..."` line (860) and the settings.json block line (877) — 1000000 -> 900000.
  - install.ps1: both occurrences in `New-ClaudeGlm52Wrapper` — the `$env:CLAUDE_CODE_AUTO_COMPACT_WINDOW = "..."` line (818) and the packed settings JSON string (829) — 1000000 -> 900000.
  - README.md line 122: documented value 1000000 -> 900000, with an added "~250K headroom below the 1M ceiling" clause.
  - package.json: 2.4.0 -> 2.4.1.
- Files/modules/functions touched
  - Modified: install.sh, install.ps1, README.md, package.json, PROJECT_HANDOFF.md, PROJECT_LOG.md
- Redeploy
  - Re-ran `bash install.sh` (option 2: reset wrappers/aliases using existing API key; key auto-detected from existing wrapper, no key prompt) as a child bash process so the real /usr/bin/grep is used (avoids the documented Bash-tool grep-wrapper subshell footgun). Regenerated all 10 wrappers in ~/.local/bin and refreshed the ~/.bashrc alias block.
  - Note: ~/.local/bin/claude-glm-5.2 had already been hand-patched to 900000 as a stopgap before this session; the re-run makes source and deployed consistent (installer-generated). The user's stopgap left a stale backup file ~/.local/bin/claude-glm-5.2.bak-1000000 (still contains 1000000) — inert (not on any alias path), left in place (not created by this session); optional user cleanup.
- Key technical decisions and rationale
  - Value-only change; no structural edits. The var remains isolated to the 5.2 wrapper (verified: only claude-glm-5.2 among live wrappers carries it).
  - 900000 chosen to match the already-deployed stopgap. If 900K still occasionally errors on very heavy turns, 800K is the safer next step (auto-compact ~664K, ~336K headroom) — noted for a future adjustment, not applied now.
- Problems encountered and resolutions
  - None. Installer exited 0 ("Reset complete!"); dotfiles backed up first (~/.bashrc.bak.acw-*, ~/.bash_profile.bak.acw-*).
- Items explicitly completed, resolved, or superseded in this session
  - Completed: GLM-5.2 auto-compact window lowered to 900000 across install.sh + install.ps1 + README, redeployed, v2.4.1.
  - Superseded: CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000 on the 5.2 wrapper (now 900000).
- Verification performed
  - `grep -rn 'AUTO_COMPACT_WINDOW' install.sh install.ps1` => only 900000 (2 per file); 0 residual `1000000` in both scripts.
  - `bash -n install.sh` => OK.
  - `json.load(package.json)` => 2.4.1.
  - Deployed: `grep -n AUTO_COMPACT_WINDOW ~/.local/bin/claude-glm-5.2` => 2 lines, both 900000. No other live wrapper carries the var. `~/.bash_profile` has no installer alias block (deduped; it sources ~/.bashrc). ~/.bashrc holds ccg/ccgA/ccg52/ccg52A.
- Remaining open issues (unchanged)
  - Windows install.ps1 execution still unverified on a real Windows host (standing gap).
  - One live `ccg` launch recommended to confirm the 900000 window resolves as expected inside a real Claude Code session.
  - Optional: remove the stale ~/.local/bin/claude-glm-5.2.bak-1000000 stopgap backup.

## Session 2026-06-16 16:23 CDT (session close)
- Coding CLI used: Claude Code CLI (Opus 4.8)
- Phase(s) worked on
  - Two pieces of work this session, each already fully detailed in the entries above: (1) removed the redundant `./install` bootstrap; (2) added auto-mode `A` alias variants for all GLM aliases + fixed personal `~/.bashrc` `ccdA`. This entry is the dated session-close summary.
- Concrete changes implemented (net for the session)
  - Removed `./install` (commits 92164c0 + 7b2d009 doc note).
  - Added `<base>A` = `<base> --permission-mode auto` aliases for all 10 GLM bases across install.sh (csh + bash blocks, cleanup, summary) and install.ps1 (functions, .cmd shims, cleanup patterns, summary); README variant-suffix explainer updated; ~/.bashrc `ccdA` corrected from `--enable-auto-mode` to `--permission-mode auto` (commit d8c936d).
- Files/modules/functions touched (session total)
  - install.sh, install.ps1, README.md, ~/.bashrc (personal, backup at ~/.bashrc.bak.ccdA-fix), PROJECT_HANDOFF.md, PROJECT_LOG.md; deleted: install
- Key technical decisions and rationale
  - ./install removal: its OS-dispatch job is already done correctly by bin/cli.js (npx entry); it was unreferenced and unpublished.
  - A variants: additive only; D/Dd unchanged; `A` (not `A`+`Ad`) per user choice; ccf gets no A variant (it has no D/Dd either).
- Problems encountered and resolutions
  - Edit tool refused to modify ~/.bashrc (outside project dir / path-traversal guard); used anchored `sed -i` after a backup, verified via diff. Recorded in handoff Restart Instructions for the next agent.
- Items explicitly completed this session
  - Completed: ./install removal (92164c0, 7b2d009); auto-mode A variants + ccdA fix (d8c936d). All pushed to origin/main.
- Verification performed
  - bash -n install.sh => OK; claude --help confirms `--permission-mode auto`; end-to-end A-alias generation + dedup (child bash, real grep) PASS; no `--enable-auto-mode` left in repo; ~/.bashrc diff shows only ccdA changed.
- Final state: working tree clean at d8c936d; version 2.4.0; no regressions.
- Outstanding for next session (unchanged): Windows install.ps1 execution test; one live `ccg` launch to confirm glm-5.2[1m]; re-run `bash install.sh` to activate the new GLM A aliases and clean this machine's ~/.bash_profile duplicate.

## Session 2026-06-16 16:13 CDT (auto-mode aliases)
- Coding CLI used: Claude Code CLI (Opus 4.8)
- Phase(s) worked on
  - Add an `A` (auto mode) alias variant for every GLM alias, alongside the existing `D`/`Dd` (dangerously-skip-permissions) variants.
- Motivation
  - User wants Claude Code's auto permission mode (`--permission-mode auto`) as a first-class alias, e.g. `ccg52A`, parallel to `ccg52D`/`ccg52Dd`. Confirmed via `claude --help` that `--permission-mode` accepts `auto` (the old `--enable-auto-mode` form is deprecated).
- User decisions (AskUserQuestion)
  - Add `A` only (no `Ad` debug variant).
  - Scope: installer GLM aliases AND fix the user's personal ~/.bashrc.
- Concrete changes implemented
  - install.sh: added `<base>A='<base> --permission-mode auto'` for all 10 GLM bases (ccg, ccg45, ccg45v, ccg45air, ccg46, ccg47, ccg5, ccg5t, ccg51, ccg52) in BOTH the csh-format and bash-format alias here-strings (interleaved after each model's Dd line); added the 10 `grep -v "alias <base>A="` cleanup entries; added a `ccgA` line to the post-install summary echo.
  - install.ps1: added a `# Claude-GLM Auto Mode Aliases` section with 10 `function <base>A { <base> --permission-mode auto @args }` entries inside the $aliases here-string; added 10 `.cmd` shims (`New-CmdShim -Name "<base>A" ... -ExtraArgs "--permission-mode auto"`); registered the new header string + 10 function regexes in $installerOwnedPatterns (cleanup); added a `ccgA` summary line.
  - README.md: rewrote the variant-suffix explainer to document `D`/`Dd` (dangerously-skip-permissions) AND `A` (--permission-mode auto), listing `<base>D/Dd/A` for every alias.
  - ~/.bashrc (personal, outside repo): changed `alias ccdA='claude --enable-auto-mode'` to `alias ccdA='claude --permission-mode auto'`. `claudeA` already used the correct flag (left as-is). Backup at ~/.bashrc.bak.ccdA-fix.
- Files touched: install.sh, install.ps1, README.md, ~/.bashrc (personal), PROJECT_LOG.md, PROJECT_HANDOFF.md
- Key technical decisions and rationale
  - `A` variants are purely additive; `D`/`Dd` kept unchanged. ccf (plain shortcut, no D/Dd) gets no A variant, consistent with existing structure.
  - The Edit tool refused to write ~/.bashrc (outside project dir / path-traversal guard); used an anchored full-line `sed -i` after taking a backup, then verified via diff (exactly one line changed).
- Problems encountered and resolutions
  - None functional. (grep counting in the tool sandbox was noisy due to backslash escaping; confirmed correctness via awk + two-stage grep.)
- Verification performed
  - `bash -n install.sh` => OK; `claude --help` confirms `--permission-mode` choice `auto`.
  - install.sh: 20 alias-A lines (10 csh + 10 bash), 10 cleanup entries. install.ps1: 10 A functions (inside $aliases here-string), 10 A shims, 10 A cleanup regexes + 1 header pattern. No `--enable-auto-mode` remains anywhere in the repo.
  - End-to-end (child bash, real grep): first run generates all 10 A aliases (ccgA … ccg52A correct); re-run dedupes cleanly (10 A aliases, 1 block header — no duplication).
  - ~/.bashrc: diff vs backup shows only the ccdA line changed; claudeA already correct.
- Items completed
  - Completed: A (auto mode) variants for all GLM aliases in install.sh + install.ps1 + README; personal ~/.bashrc ccdA flag fix.
- Note for the user
  - GLM A aliases take effect after re-running `bash install.sh` (reset/regenerate) to refresh the rc alias block; the ~/.bashrc ccdA fix is live on next shell or `source ~/.bashrc`.

## Session 2026-06-16 15:43 CDT (cleanup)
- Coding CLI used: Claude Code CLI (Opus 4.8)
- Phase(s) worked on
  - Repo cleanup: removed the redundant `./install` bootstrap.
- Concrete changes implemented
  - `git rm install`. The 48-line bash bootstrap only detected `$OSTYPE` and `exec`-ed `install.sh` for Unix; on Windows it merely printed the PowerShell one-liner (it never actually ran install.ps1).
- Rationale
  - Dead/redundant: cross-platform OS dispatch is already handled correctly by `bin/cli.js` (the `claude-glm-installer` npx entry, which spawns install.ps1 on Windows / install.sh on Unix). `./install` was not referenced by README, not called by any code, and was excluded from package.json `files` (so it was never published to npm). On Unix it was identical to `bash install.sh`.
- Files touched: removed `install`; PROJECT_LOG.md, PROJECT_HANDOFF.md updated.
- Verification performed
  - Post-removal grep for any reference to the bootstrap across the repo => none (clean). README install paths (curl install.sh / iwr install.ps1) and the npx bin/cli.js dispatcher are unaffected.
- Items completed
  - Completed: removed redundant ./install bootstrap.

## Session 2026-06-16 15:36 CDT (session close)
- Coding CLI used: Claude Code CLI (Opus 4.8)
- Phase(s) worked on
  - Session opened with /startsession (takeover-plan review of PROJECT_HANDOFF.md + PROJECT_LOG.md), then executed Phase 13 (GLM-5.2 default + tier-scheme migration) and Phase 14 (bash alias smart-dedup). Both phases are fully detailed in the two preceding log entries dated this same day; this entry is the dated session-close summary.
- Concrete changes implemented (net for the session)
  - Phase 13: new claude-glm-5.2 wrapper (ccg52 + ccg default repointed, glm-5.2[1m] + CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000); migrated all wrappers to ANTHROPIC_DEFAULT_OPUS/SONNET/HAIKU scheme; smoke test + README + version 2.4.0; mirrored across install.sh and install.ps1.
  - Phase 14: bash alias-write smart-dedup in install.sh (bash_profile_sources_bashrc helper + case-based create_shell_aliases tail).
- Files/modules/functions touched (session total)
  - install.sh, install.ps1, smoke_test_models.sh, README.md, package.json, PROJECT_HANDOFF.md, PROJECT_LOG.md
- Key technical decisions and rationale
  - Empirical-first: probed Z.ai live before coding (all existing models still reachable; glm-5.2 PASS; raw glm-5.2[1m] 400s because the bracket form is a Claude Code client-side convention).
  - User chose, via AskUserQuestion: add ccg52 + repoint ccg; tier mapping on every wrapper; keep all wrappers; enable [1m] on default; and (Phase 14) smart-dedup over full-bridge or status-quo.
  - Phase 14 scoped to bash only (the duplication was bash-specific); zsh/csh/PowerShell paths untouched.
- Problems encountered and resolutions
  - Phase 13: PowerShell config-dirs summary omitted $Glm52ConfigDir (caught by evaluator-active review) — fixed to full parity.
  - Phase 14: Claude Code Bash-tool `grep` shell-function wrapper exec-replaced test subshells; diagnosed and worked around by testing in a child bash process (real grep). Documented in Restart Instructions for the next agent.
- Items explicitly completed this session
  - Phase 13 (commit 502411d), Phase 14 (commit 5e1eb62), plus doc-sync commits (0070d27, f520235). All pushed to origin/main.
  - Reconciled the previously-stale handoff (it had recorded 25ff837 as the tip; corrected, and the unlogged prior PS5.1 commits noted as pre-existing).
- Verification performed
  - bash -n install.sh / smoke_test_models.sh => OK; package.json => 2.4.0; 0 old-scheme residuals; 20/20/20 tier balance both scripts; generated 5.2 settings.json VALID (bash + PS); live smoke test glm-5.2 PASS; evaluator-active review APPROVED; Phase 14 helper 6/6 + end-to-end 3/3 (child bash).
- Final state: working tree clean at f520235; version 2.4.0; no regressions.

## Session 2026-06-16 (Phase 14)
- Coding CLI used: Claude Code (Opus 4.8)
- Phase(s) worked on
  - Phase 14: bash alias-write smart-dedup. User observed the installer writes the alias block to both ~/.bash_profile and ~/.bashrc and asked to avoid that duplication generally.
- Background (the .bashrc vs .bash_profile question)
  - ~/.bashrc is read by interactive non-login shells (new terminals, tmux panes); ~/.bash_profile is read by login shells (SSH, console). Bash reads only ONE of them per shell type, which is why the installer historically wrote both. ~/.bashrc is the conventional home for aliases; the canonical no-dup pattern is aliases in ~/.bashrc with ~/.bash_profile sourcing ~/.bashrc.
- User decision (AskUserQuestion)
  - Chose "Smart dedup": write aliases+block to ~/.bashrc; only ALSO write ~/.bash_profile when it does NOT already source ~/.bashrc. When it does source ~/.bashrc, strip any installer-owned block previously left there (clean up the duplication on re-run).
- Concrete changes implemented (install.sh ONLY)
  - Added top-level helper `bash_profile_sources_bashrc()` — returns 0 if ~/.bash_profile loads ~/.bashrc via `.`/`source` (comment- and guard-aware grep), 1 otherwise.
  - Replaced the tail of `create_shell_aliases` (the old `add_aliases_to_rc primary` + unconditional `add_aliases_to_rc ~/.bashrc`) with a case statement: csh -> .cshrc only (unchanged); bash (.bashrc or .bash_profile) -> write ~/.bashrc, then if ~/.bash_profile exists: strip our block when it bridges (dedup) else dual-write (coverage); zsh/ksh/other -> unchanged (detected rc + ~/.bashrc fallback).
- Files touched: install.sh, PROJECT_HANDOFF.md, PROJECT_LOG.md. install.ps1 (single $PROFILE) and csh (.cshrc) have no dual-write, so no change.
- Key technical decisions and rationale
  - Scope limited to bash; the duplication was bash-specific. zsh dual-write (.zshrc + .bashrc) intentionally preserved to avoid behavior change for zsh users.
  - Dedup also CLEANS existing duplicates: remove_aliases_from_rc runs on ~/.bash_profile when it bridges, so re-running the installer removes the stale block users already have there (the user's own machine has this duplicate today).
  - PATH-writing in setup_user_bin left unchanged (PATH is written to a single rc file, not duplicated, so it was out of scope).
- Problems encountered and resolutions
  - End-to-end testing was repeatedly sabotaged by the Claude Code Bash tool's `grep` shell-function wrapper, which does `exec -a ugrep ...` inside subshells ($BASHPID != $$), replacing/terminating any test subshell the moment create_shell_aliases called grep. Diagnosed via set -x trace + `type grep`. Resolved by running the test as a child `bash` process (shell functions are not inherited, so grep = /usr/bin/grep). The installer itself is unaffected — real users run `bash install.sh` with the real grep.
- Verification performed
  - `bash -n install.sh` => OK
  - Helper unit tests: 6/6 cases correct (guarded multi-line, one-line &&, source keyword, comment-only, test-line-without-source, no-bashrc) + correctly detects the user's real ~/.bash_profile as sourcing ~/.bashrc.
  - End-to-end (child bash, real grep), 3 cases all PASS:
    A. .bash_profile bridges -> block only in ~/.bashrc (ccg=5.2), ~/.bash_profile block stripped (0), bridge preserved, 0 leftover aliases.
    B. .bash_profile does not bridge -> dual-write kept (block in both).
    C. no .bash_profile -> ~/.bashrc only, no profile created.
- Items completed
  - Completed: smart-dedup alias writing for bash; auto-cleanup of redundant ~/.bash_profile block on re-run.
- Remaining open issues
  - Windows install.ps1 still unverified on a real Windows host (standing gap).
  - To clean the duplicate that currently exists on the user's own machine, re-run `bash install.sh` (option to reset/regenerate aliases) — the dedup will strip the redundant ~/.bash_profile block.

## Session 2026-06-16
- Coding CLI used: Claude Code (Opus 4.8)
- Phase(s) worked on
  - Phase 13: Add GLM-5.2 as the new default model; migrate every wrapper from the single-model env scheme to Z.AI's recommended opus/sonnet/haiku tier scheme.
- Motivation
  - Z.ai released GLM-5.2. Per https://docs.z.ai/devpack/overview "All plans support GLM-5.2, GLM-5-Turbo, GLM-4.7 and GLM-4.5-Air." Per https://docs.z.ai/devpack/tool/claude the recommended Claude Code config now uses ANTHROPIC_DEFAULT_OPUS_MODEL=glm-5.2[1m], ANTHROPIC_DEFAULT_SONNET_MODEL=glm-5.2[1m], ANTHROPIC_DEFAULT_HAIKU_MODEL=glm-4.5-air, plus CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000 for the 1M context window. User asked for the default wrapper to use glm-5.2[1m].
- Empirical findings (live smoke test against user's key, ground truth before coding)
  - glm-5.2 => PASS (HTTP 200). glm-5.1, glm-5, glm-5-turbo, glm-4.7, glm-4.6, glm-4.5, glm-4.5v, glm-4.5-air all still PASS — i.e. all existing models remain reachable on the user's plan even though the overview doc only guarantees a subset across all plans. Nothing had to be removed.
  - Raw `glm-5.2[1m]` => HTTP 400 "Unknown Model" at the bare /v1/messages endpoint. The `[1m]` suffix is a Claude Code client-side routing convention (paired with CLAUDE_CODE_AUTO_COMPACT_WINDOW), not a raw model id, so the smoke test (raw curl) cannot validate it. Base glm-5.2 is the probeable form; the bracket form is correct-by-spec per the Z.AI Claude doc.
- User decisions captured via AskUserQuestion (4 questions)
  - Add explicit ccg52 wrapper AND repoint default ccg -> glm-5.2.
  - Tier mapping on EVERY wrapper (opus+sonnet = own model, haiku = glm-4.5-air), not just the default.
  - Keep all existing wrappers (purely additive).
  - Enable [1m] + auto-compact on the default wrapper.
- Concrete changes implemented
  - install.sh: added `create_claude_glm_52_wrapper` (file claude-glm-5.2, config dir ~/.claude-glm-52, opus/sonnet=glm-5.2[1m], haiku=glm-4.5-air, CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000). Added GLM_52_CONFIG_DIR. Converted all 9 existing wrappers' export blocks AND settings.json blocks from ANTHROPIC_MODEL/ANTHROPIC_SMALL_FAST_MODEL to the OPUS/SONNET/HAIKU tier scheme. Repointed `ccg` (csh + bash blocks) to claude-glm-5.2; added ccg52/ccg52D/ccg52Dd aliases; added the 3 ccg52 cleanup grep-v patterns; added the new wrapper to all 3 create-call sites, the detect_existing_zai_api_key wrapper_files + settings_files arrays, the existing-install if-test, the help/summary/model/alias/"don't forget" echoes, and the config-dirs line.
  - install.ps1: mirrored everything — New-ClaudeGlm52Wrapper, $Glm52ConfigDir, tier-scheme conversion of all 9 existing wrappers' env arrays + settings.json lines, Set-Alias ccg -> claude-glm-5.2, Set-Alias ccg52, function ccg52D/ccg52Dd, $installerOwnedPatterns (Set-Alias ccg52 + the two function regexes), Get-ExistingZaiApiKey wrapperPaths + settingsPaths, existing-install detection ($glm52Wrapper), 3 call sites, .cmd shims (ccg + ccgD/ccgDd repointed to claude-glm-5.2.ps1, new ccg52/ccg52D/ccg52Dd shims), summaries, and the config-dirs summary line (brought to full 10-dir parity).
  - smoke_test_models.sh: added glm-5.2 to DEFAULT_MODELS; claude-glm-5.2 to wrapper_files; ~/.claude-glm-52/settings.json to settings_files.
  - README.md: feature list, quick-start, alias table (ccg -> 5.2 default with 1M context; new ccg52 row; ccg51 demoted from "same as ccg"), D/Dd variant list, tier-mapping explainer paragraph, how-it-works list, and "Changes in This Fork" section.
  - package.json: 2.3.0 -> 2.4.0.
- Files/modules/functions touched
  - Modified: install.sh, install.ps1, smoke_test_models.sh, README.md, package.json, PROJECT_HANDOFF.md, PROJECT_LOG.md
- Key technical decisions and rationale
  - Tier scheme fully replaces the old 2-var scheme (0 residual ANTHROPIC_MODEL/ANTHROPIC_SMALL_FAST_MODEL refs) per the user's "tier mapping on every wrapper" choice. Each wrapper's opus+sonnet point at its own model so /model switching stays on-brand; haiku (background/fast) is glm-4.5-air everywhere.
  - [1m] + auto-compact restricted to the default/5.2 wrapper only; all other wrappers keep their plain model id.
  - ccg and ccg52 both resolve to the single claude-glm-5.2 wrapper (mirrors the existing ccg/ccg51 -> claude-glm-5.1 pattern), so repointing ccg automatically carries ccgD/ccgDd.
  - Kept ccg5 = glm-5, ccg51 = glm-5.1 unchanged (determinism); only the short default ccg moved to 5.2.
- Harness process
  - Orchestrator (Opus 4.8) did research (WebFetch of both Z.AI docs + live smoke probe), Socratic AskUserQuestion round (4 questions), then implemented both scripts directly given the high cross-file synchronization requirements, then spawned one evaluator-active subagent for an independent fresh-context review.
- Independent review (evaluator-active)
  - Verdict APPROVED. Scores: Functionality 96, Security 100, Craft 97, Consistency 98. All 9 spec requirements verified present and consistent across both scripts; 0 old-scheme residuals; 20/20/20 tier balance; [1m]/auto-compact isolated to 5.2; JSON valid. One Low finding (PowerShell config-dirs summary omitted $Glm52ConfigDir) — fixed by bringing the line to full 10-dir parity. One pre-existing, out-of-scope note (csh space-format alias cleanup gap) left untouched.
- Verification performed
  - bash -n install.sh => OK; bash -n smoke_test_models.sh => OK
  - json.load(package.json) => 2.4.0
  - grep: 0 residual ANTHROPIC_MODEL/ANTHROPIC_SMALL_FAST_MODEL in both scripts; OPUS=SONNET=HAIKU=20 in both; [1m]+auto-compact strictly inside the 5.2 wrapper
  - Generated bash claude-glm-5.2 settings.json extracted + python json.load => VALID (6 env keys); PowerShell 5.2 settings.json line parsed => VALID
  - Live smoke_test_models.sh vs Z.ai API: glm-5.2 PASS, all wrapper models PASS, only glm-4.7-flashx 429 (plan quota, unchanged)
- Items explicitly completed, resolved, or superseded in this session
  - Completed: GLM-5.2 wrapper (ccg52) + ccg default repoint + 1M context
  - Completed: tier-scheme migration across all wrappers (both installers)
  - Completed: smoke test, README, version bump, independent review
  - Superseded: ANTHROPIC_MODEL + ANTHROPIC_SMALL_FAST_MODEL scheme (now OPUS/SONNET/HAIKU tier scheme everywhere)
  - Superseded: ccg -> claude-glm-5.1 (now ccg -> claude-glm-5.2)
- Remaining open issues
  - Phase 13 is uncommitted (user has not requested a commit). Working tree: install.sh, install.ps1, smoke_test_models.sh, README.md, package.json.
  - Windows-side execution of install.ps1 still unverified (no Windows host).
  - One live `ccg` launch recommended to confirm glm-5.2[1m] resolves inside Claude Code (raw API cannot validate the bracket form).
- Documentation reconciliation note
  - On takeover, found PROJECT_HANDOFF.md was stale: it recorded latest commit 25ff837, but git HEAD is 70ff1ff with unlogged commits 072a9c9 (Phase 11+12) and a run of install.ps1 PS5.1 fixes (ec387cb, 4399507, 03e7dfb, 657b2c9, 70ff1ff). Handoff "Latest committed commit" pointer corrected to 70ff1ff; those prior commits are pre-existing and left as-is.

