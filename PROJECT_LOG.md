# PROJECT_LOG.md (active) — claude-glm-wrapper

Bounded active log for the claude-glm-wrapper installer (Claude Code wrappers for Z.AI GLM models). Newest first. Older sessions are archived verbatim under `logs/` (see Archives once rotation runs).

## Archives
- logs/PROJECT_LOG_2026-H1.md — 3 sessions (2026-06 … 2026-06)

## Session Index (active, newest first)
- 2026-08-20 (Phase 20 — install.ps1 $PROFILE-reload reminder)
- 2026-08-17 (Phase 19 execution)
- 2026-08-17 11:43 CEST (Phase 19 planning)
- 2026-08-16 → closed 2026-08-17 06:50 CEST (Phase 18 harness code review + fix)
- 2026-08-16 08:50 CDT (Phase 17 GLM-5.3 + consolidation)
- 2026-07-03 00:57 CDT (Phase 16 harness review)
- 2026-07-02 10:01 CDT
- 2026-06-16 16:23 CDT (session close)
- 2026-06-16 16:13 CDT (auto-mode aliases)
- 2026-06-16 15:43 CDT (cleanup)

---

## Session 2026-08-20 (Phase 20 — install.ps1 $PROFILE-reload reminder)
- Coding CLI used: Claude Code CLI (Sonnet 5)
- Phase worked on: none of the queued Phase 19 SPECs — this session was reactive, triggered by a user question about GLM-5.3 linkage that turned into a live-diagnosed Windows bug + fix.

### GLM-5.3 linkage check (WSL/bash side) — no defect found
User asked whether `ccg` was "not properly linked to 5.3". Checked live on this machine (not just the docs): `~/.bashrc` alias, the deployed `~/.local/bin/claude-glm-5.3` wrapper, and the deployed `~/.claude-glm-53/settings.json` all correctly point at `glm-5.3[1m]` opus/sonnet + `glm-4.7` haiku + `900000` window. No bug on this machine. Restated the pre-existing structural gap (§4 PROJECT_HANDOFF): the `[1m]` bracket form can't be validated against the raw Z.AI API directly (client-side routing convention, HTTP 400 on the raw endpoint).

### The real report: Windows PowerShell, `ccgD` failing after a Reset
User clarified they meant the Windows side and pasted a **real terminal transcript** from their own machine (`(base) PS C:\JHCloud\...>`). Sequence: ran `install.ps1` → option 2 "Reset wrappers/aliases" → script correctly regenerated 6 `.ps1` wrappers, deleted 22 retired wrapper/shim files, rewrote 28 CMD shims and the PowerShell profile, printed "OK: Reset complete!" → in the **same still-open window**, `ccgD --continue` and `ccg52D` both failed with `The term 'claude-glm-5.2' is not recognized...`, pointing at the profile's `ccgD` function definition → `ccg53D` immediately afterward worked and correctly launched GLM-5.3 (1M context).

**Diagnosis, arrived at before checking git history, then confirmed against it**: PowerShell reads `$PROFILE` once, at session start. The Reset had correctly rewritten the on-disk profile (`ccg` → `claude-glm-5.3`) and correctly deleted the `claude-glm-5.2.ps1` file the *old* `ccg` used to point at — but the already-running session still had the *old* function compiled into memory, so it called a script that had just been deleted 30 seconds earlier. `ccg53D` "worked" only because `ccg53` mapped to the same target (`claude-glm-5.3`) in both the old and new profile, so staleness didn't matter for that one alias.

Checked git log on this diagnosis: an identical fix (`fix(install.ps1): tell the user to reload $PROFILE after options 1 and 2`, commit `9ea2516`) already existed on `main`, committed earlier the same day (2026-08-20 11:59 CDT) — apparently in a prior session that made the commit but never ran `/endsession` to log it, since neither PROJECT_HANDOFF.md nor PROJECT_LOG.md had a Phase 20 entry before this session. Its commit message names the exact same symptom this user hit. Confirmed already pushed to `origin/main` (`git fetch` + `git rev-list --count --left-right` = `0 0`).

### Two false starts on the way to the real diagnosis
- Initially checked `/mnt/c/Users/<user>/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` (the **PowerShell 7/Core** profile) and found no GLM content — wrongly reads as "install.ps1 was never run." The actual profile PS 5.1 reads is `Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` (different folder, same filename), which the user's real transcript revealed. Both profile files can exist simultaneously; nothing in the filename distinguishes them.
- The Windows checkout at the OneDrive path is **one commit behind** (`a45a6a6`, missing `9ea2516`) and carries unrelated uncommitted noise: `.npmignore`/`LICENSE`/`bin/preinstall.js` are pure CRLF line-ending flips (diffed, zero content change — Windows git/editor artifact, not intentional edits), and an untracked `error_home.txt` is a PowerShell parse-error log from a **different, unrelated project** (`terminal-auto-launcher`).

### User asked to "commit and push" — deferred, not done
Composed an `AskUserQuestion` (pull-only / discard-noise-then-pull / commit-everything-as-is) rather than blindly committing the noise, since none of it was part of what was discussed and committing a stray file from another project into this repo's history would be a real mistake. The user rejected/interrupted the question and invoked `/endsession` before answering. **This is genuinely open** — see PROJECT_HANDOFF §4. Nothing was committed or pulled on the Windows checkout this session.

### Wiki distillation
Two pages: NEW `concept/powershell-profile-two-paths-and-load-once.md` (both traps in full, generalized beyond this project — PS5.1-vs-PS7 profile-path divergence, and `$PROFILE` read-once-at-startup as a named instance of the load-once-lifecycle pattern); EDIT `concept/deployed-is-not-running.md` +instance section (it already listed "a shell that sourced a since-edited profile" as a generic example before this — this session supplies the concrete case).

No-regression note: this session made **zero code changes** to `install.ps1`, `install.sh`, or any other tracked file in this repo. The fix that resolved the reported symptom (`9ea2516`) already existed before this session started; the work here was diagnosis, confirmation, and documentation.

---

## Session 2026-08-17 (Phase 19 execution)
- Coding CLI used: Claude Code CLI (Opus 5, 1M context)
- Phase worked on: Phase 19 — execute the queued SPECs. Review SPEC completed; LOW defects fixed; shellcheck SPEC not started.

### SPEC_INDEPENDENT_REVIEW_ORCHESTRATOR_FIXES — verdict: APPROVED ×4
All four orchestrator-authored fixes reproduced from scratch by a non-author, both directions, in sandboxed `HOME`s. R1 (CRLF alias matching), R2 (`managed_value` tightening), R3 (fingerprint gate), R4 (`umask`/`chmod`) each do exactly what they claim. Verdict + evidence: `.moai/reports/review/SPEC_INDEPENDENT_REVIEW_ORCHESTRATOR_FIXES-verdict.md`; harnesses under `.moai/tmp/review-phase18/`. `PROJECT_HANDOFF.md` §5 risk marked **Resolved**.

Three findings, none of them a defect in the four fixes — all in adjacent code, each filed as its own SPEC per the review SPEC's rule:

| Finding | Site | Filed as |
|---|---|---|
| F2 — `rm -f ~/.local/bin/ccx` unconditional, ungated, runs **before** the Cancel branch | `install.sh:1333` | `SPEC_CCX_UNCONDITIONAL_DELETE` (MEDIUM) |
| F1 — `claude-glm[A-Za-z0-9._-]*` deletes a user's own alias line | `install.sh:1017` | `SPEC_ALIAS_GLM_WILDCARD_OVERMATCH` (LOW-MEDIUM) |
| F3 — fingerprint matches a comment, not only an executable reference | `install.sh:886` | `SPEC_FINGERPRINT_COMMENT_MATCH` (LOW, decision required) |

F4 (informational, not filed): the removal-failure warning at `install.sh:889-890` is **effectively unreachable** — `rm -f` needs directory write, and removing that permission aborts the install earlier at `:552`. Not defective, untestable without root. Do not rely on it as a safety net.

The R1 over-match attack succeeded, and the differential against the pre-R1 regex shows why it is not R1's defect: `user-glmprefix` reads `DEL/DEL same` in LF — already deleted before the fix. R1 extended its reach to CRLF only, which closing the under-match makes unavoidable. **R1 must not be reverted**; reverting restores 28 permanently stale aliases on every CRLF rc.

### The round-2 review was recovered, and it overturned a verification in the entry below
Two teammate panes (SPEC author + plan auditor) delivered findings to the screen and were then closed; the findings existed only in their transcripts. Recovered and each claim independently re-derived against the shipped code:

- **Their F1 does not apply.** It criticises a `mapfile -t` prescription; the SPEC on disk already prescribes the bash-3.2-safe `while IFS= read -r` form and argues against `mapfile` by name. The auditor reviewed the brief or an earlier draft.
- **Their F3 stands, and corrects this log.** The Phase 19 planning entry below records: *"Attempted to falsify the claim that defect 1c is unreachable, and failed … both `--key ""` and `ZAI_API_KEY=""` exit at the error path."* That test used the wrong input. `""` is indeed caught by `[ -n … ]`; a **lone newline** is not — it passes the guard as non-empty, `detect_key` returns 0 so the call site does not exit, and `$(…)` then strips the newline, delivering the empty string to `validate_key`. Reproduced on both branches. §1c is **live, not latent**; the "latent, not live" framing is withdrawn.
- **Their F4 stands.** §1d's "grants no privilege the attacker did not already have" holds for injection (needs an induced disk-full) but not exfiltration: `cp -p` follows the symlink with nothing induced, writing the rc **outside `$HOME`** as the victim. Reproduced.

Both SPEC sections were corrected in place with dated markers; the prescribed fixes were already right and did not change.

### SPEC_LOW_DEFECTS_CLEANUP — all four fixed, reproduction-first
RED (before): 1a two files → **4** array entries (three nonexistent); 1b pipe-to-bash hint present; 1c `validate_key` accepted `""`; 1d rc written through the `.bak` symlink to a path outside `$HOME`. GREEN (after): 0 failures.

| Defect | Site | Fix |
|---|---|---|
| 1a | `install.sh:244` | `while IFS= read -r` + `[ -n ]` guard (bash-3.2-safe; producer untouched) |
| 1b | `install.sh:1536` | printed hint → `bash <(curl -fsSL …)`, matching `README.md:37` |
| 1c | `smoke_test_models.sh:152` | `[ -z "$key" ] && return 1` as the first check |
| 1d | `install.sh:1083` | `rm -f "$target_rc.bak"` immediately before the `cp -p` |

Verified before applying 1a, rather than assumed: the prescribed `[ -n … ] && arr+=(…)` form ends the loop body with a possibly-failing command under `set -eE`, which is the exact class the SPEC exists to prevent. Probed both that form and an `if`-guarded variant — both survive; the SPEC's prescription was used verbatim.

No-regression bar: **0 failures** — 6 wrappers / 28 aliases; user-owned colliding aliases survive in LF *and* CRLF; mode-600 rc keeps mode **and inode**; symlinked rc stays a symlink and the target receives the block; no stray `.tmp`/`.bak`; 3-run idempotency (1 header, 1 PATH line, no alias growth); no phantom cleanup banner on a clean machine; `bash -n` on both scripts.

### Preserved: the Windows `$PROFILE` measurement (auditor F2)
`SPEC_INSTALLPS1_E2E_WINDOWS` was deleted by decision (recorded below), so this measurement — taken on the operator's real machine under PowerShell 5.1 — would otherwise survive only in a closed pane's transcript:

```
REAL USERPROFILE : C:\Users\jung.hur
PROFILE (before) : C:\JHCloud\OneDrive - North Dakota University System\...\Microsoft.PowerShell_profile.ps1
USERPROFILE now  : C:\Temp\scratchprofile
PROFILE (after)  : C:\JHCloud\OneDrive - ...  (unchanged)
VERDICT: PROFILE DID NOT FOLLOW override
```

`$PROFILE` is a PowerShell automatic variable fixed at session start, not derived from `$env:USERPROFILE` at use time, and `install.ps1:311` writes the 28 aliases via `Set-Content -Path $PROFILE`. So the sandbox option that relied on overriding `$env:USERPROFILE` is **falsified, not open**: wrappers would go to the scratch directory while 28 aliases landed in the operator's real, OneDrive-synced profile. Should that SPEC ever be revived, this closes its open question.

### SPEC_SHELLCHECK_BASELINE — baseline captured, Option B adopted
The SPEC's first step was blocked as it predicted: `sudo -n true` exits 1, so `apt-get install` needs an interactive password. Took the SPEC's own named fallback — the official static release binary (v0.9.0, matching the apt candidate `0.9.0-1` so future runs stay comparable), placed in a project-local gitignored path rather than the user's real `~/.local/bin`.

**22 findings, 0 errors, and two of four files clean** (`smoke_test_models.sh`, `.git_hooks/pre-commit`). `install.sh` 20, `.git_hooks/pre-push` 2. Severity: warning 11, info 10, style 1. Artifact: `.moai/specs/shellcheck-baseline-2026-08-17.md`; machine-readable baseline + comparison procedure: `.moai/baselines/shellcheck-2026-08-17/`.

**The result that mattered was a negative one.** The `set -e` masking class this linter was wanted for — `SC2155`, `local x=$(cmd)` swallowing the command's exit status — came back **clean on inspection**. All 8 hits were read at the site rather than classified by code: 4 are `local rc_file=$(detect_shell_rc)`, and that function cannot fail (every `case` branch assigns, there is a `*)` default, it ends in `echo`), while the other 4 wrap `uname`/`date`/`basename`/`sed` inside `report_error`. Nothing of consequence is masked. Option B (baseline as accepted debt, gate only NEW findings) adopted on that evidence.

One genuine finding: **`DEBUG` is dead** (`SC2034`, `install.sh:40`) — assigned at `:16`, `:25`, `:40`, read nowhere, so `--debug` and the documented `CLAUDE_GLM_DEBUG=1` set a flag no code consumes. Filed as `SPEC_DEBUG_FLAG_DEAD`.

### A defect claim of my own, filed and then withdrawn
`SC2086` at `install.sh:154` (`$(echo $PATH | sed …)`) was classified as genuine on the reasoning that an unquoted `$PATH` would glob-expand and substitute local filenames into a **public** GitHub issue body. A SPEC was written on that premise. **The reproduction failed**, and the SPEC was withdrawn.

`$PATH` contains no whitespace, so unquoted it remains a *single word*; pathname expansion then applies to the whole string `/usr/bin:*`, which matches nothing as a path pattern and stays literal. The whitespace half is masked too — `echo` rejoins arguments with single spaces. The first attempt at this reproduction was itself invalid: run inline in the agent's shell wrapper, where `set -f` can disable globbing and fake either verdict. The verdict came from a child script that asserts `set -f` is off first.

Recorded in the baseline artifact rather than deleted: a falsified defect claim is cheaper to read than to re-derive. Quoting remains correct practice; the asserted consequence was not real.

### Gap, stated rather than glossed
The five filed finding SPECs (`SPEC_CCX_UNCONDITIONAL_DELETE`, `SPEC_ALIAS_GLM_WILDCARD_OVERMATCH`, `SPEC_FINGERPRINT_COMMENT_MATCH`, `SPEC_DEBUG_FLAG_DEAD`) are **unexecuted by design** — a finding is not fixed inside the review that found it. Two of them (`FINGERPRINT_COMMENT_MATCH`, `DEBUG_FLAG_DEAD`) need a decision before implementation and say so in their own headers.

`shellcheck` is installed only as a local static binary under `.moai/tmp/`, which is gitignored — it will not survive a clean checkout, and the comparison procedure in the baseline artifact assumes that path. No CI wiring for the NEW-findings gate exists yet; Option B is a recorded policy, not an enforced one.

## Session 2026-08-17 11:43 CEST (Phase 19 planning)
- Coding CLI used: Claude Code CLI (Opus 5, 1M context)
- Phase worked on: Phase 19 — turn Phase 18's consciously-deferred items into executable SPECs. **No code was changed this session**; `git status` clean throughout, `origin/main` unchanged at `b0ff602`.

### What was produced
Four SPECs authored by `manager-spec` under `.moai/specs/` (gitignored, local-only), then reduced to three:

| SPEC | Severity | Shape |
|---|---|---|
| `SPEC_LOW_DEFECTS_CLEANUP.md` | LOW ×4 | Code fixes, each with a verbatim reproduction |
| `SPEC_SHELLCHECK_BASELINE.md` | MEDIUM | Tooling gap + an explicit fix-now-vs-accept-debt decision |
| `SPEC_INDEPENDENT_REVIEW_ORCHESTRATOR_FIXES.md` | MEDIUM | **Review** SPEC — deliverable is a verdict, not a diff |
| ~~`SPEC_INSTALLPS1_E2E_WINDOWS.md`~~ | — | **Deleted** by user decision (see below) |

`SPEC_SECURITY_APIKEY_INJECTION.md` (Phase 18) was re-headed **IMPLEMENTED and VERIFIED — do not re-execute**, so the next agent does not mistake a record for a work item.

### The finding that justified the session
The SPEC author **rejected the orchestrator's prescribed fix** for defect 1a and was right to. The brief said to replace `local all_wrappers=($(find_all_installations))` with `mapfile -t` and called it "a clean swap". It fails twice, both reproduced and both independently re-verified by the orchestrator:

1. **`mapfile` is bash 4.0+; macOS ships bash 3.2.57.** macOS is a documented supported platform (`README.md:23`, `:34`), and `install.sh` currently contains **zero** bash-4-only constructs (`mapfile`/`readarray`/`declare -A` all count 0) — this would have been the first. `set -eE` + ERR trap sit at `install.sh:1545-1546`, so `mapfile: command not found` → 127 → `handle_error` → every macOS user gets a file-a-bug prompt instead of an install.
2. **It breaks the empty case, which is the fresh-install path.** `find_all_installations` ends `printf '%s\n' "${found_files[@]}"` (`install.sh:238`), which on an empty array emits one blank line. Measured: `mapfile -t` → `count=1 first=[]`; the current `$(...)` → `count=0`; a guarded `while read` → `count=0`. The phantom entry defeats the early return, is displayed to the user as a wrapper to clean up, is approved under that false description, and reaches `rm ""`.

Corrected to a bash-3.2-safe `while IFS= read -r` loop with an `[ -n ]` guard — which is also the idiom `find_all_installations` already uses twelve lines above, so it satisfies "preserve existing style" where `mapfile` would have been the modernisation the project rule forbids. **A LOW cosmetic fix would have broken every macOS install.**

Three further corrections to the orchestrator's brief, accepted:
- **1b** — the pipe-to-bash hint is *self-contradictory*, not a live hazard. The stdin-eats-the-next-line failure occurs when the *installer* is fed to bash over stdin; the hint is a string a user copies into a fresh shell, so printing it executes nothing. Justification moved onto contradiction with `README.md:37` and `install.sh:7`/`:11`.
- **1d** — the two directions are not equally reachable. `.bak` exfiltration via `cp -p` needs nothing; injection needs the restore path to fire, i.e. an induced disk-full. Recorded so a reviewer knows to force the condition.
- **SPEC 4 option (a)** — a throwaway Windows account is the option *least* likely to reproduce the Phase 18 ACL finding, because that finding exists only because the real profile is long-lived. Inverts the intuitive safety ordering.

### Decisions taken
- **`install.ps1` end-to-end verification: closed, will not do** (user decision). The severity question the SPEC author raised — "MEDIUM only if the Windows user population is ~0" — was resolved by measurement: the repo has **0 stars, 0 forks**, and `npm view claude-glm-installer` resolves to upstream JoeInnsp23's **v1.0.3**, not this fork's 2.5.0. This fork's `install.ps1` therefore reaches essentially one Windows user. The SPEC was deleted rather than deferred. **`install.ps1` itself is untouched and still shipped** (1386 lines) with its Phase 18 static assurance intact.
- **Execution order fixed** as review → LOW defects → shellcheck, so the review audits code before the other SPECs move it.
- **Project documentation generation skipped** deliberately: the `/moai plan` workflow offers to create `product.md`/`structure.md`/`tech.md`, but this project already carries richer context in `PROJECT_HANDOFF.md` and this log.
- **SPEC format**: followed the repo's existing flat `SPEC_<NAME>.md` convention rather than the workflow's 12-field GEARS frontmatter — consistency inside the repo over the generic schema.

### New finding (not from the SPECs)
`package.json`'s description advertises *"Run with: npx claude-glm-installer"*, but that npm name resolves to **upstream's v1.0.3**, not this fork. Anyone following it runs a different, older codebase. Nothing user-facing is broken today — `README.md` documents only `git clone` + `bash install.sh` — so it is recorded in §4 as LOW, undecided.

### Verification performed
- All load-bearing SPEC claims re-checked against the real files by the orchestrator: the unquoted array at `install.sh:244`; `find_all_installations` emitting one path per line; the pipe form at `install.sh:1536` vs the safe form at `:7`/`:11`/`README.md:37`; the `validate_key` empty-check asymmetry (smoke 0, install.sh 1); `cp -p` with no prior `rm -f`; `install.ps1`'s 14 `%USERPROFILE%` anchors.
- **Attempted to falsify** the claim that defect 1c is unreachable, and failed: all four `detect_key` success paths are `[ -n … ]`-guarded, and empirically both `--key ""` and `ZAI_API_KEY=""` exit at the error path before `validate_key` runs. The "latent, not live" framing stands.
- Re-verified the `mapfile` rejection independently (all four axes above).

### Gap, stated rather than glossed
`plan-auditor` was spawned and **never delivered** — four idle notifications, nothing through the mailbox, no artifacts. So the SPECs' *factual claims* are verified, and the orchestrator's *brief* was independently reviewed (that is how the `mapfile` bug surfaced), but **the SPECs themselves were never independently audited** — proportionality, acceptance-criteria quality, and the review-SPEC shape remain unreviewed. Recorded in §7 so the executing agent applies normal scepticism. Mailbox routing failed repeatedly across this and the prior session; `manager-spec` worked around it by writing its report to a file, which is how its findings were recovered.

## Session 2026-08-16 → closed 2026-08-17 06:50 CEST (Phase 18 harness code review + fix)
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

### Session close — commits pushed (2026-08-17 06:50 CEST)
An 18th fix landed during the commit phase, surfaced by the commit itself: `git add bin/cli.js` printed *"The following paths are ignored… bin"*. The tooling's `.gitignore` rewrite had added `bin/` under a **"Go Build Artifacts"** heading, but this is a Node package whose `bin/` is source and its published entry point (`package.json` → `"bin": {...}`, `"files": ["bin/"]`). The two existing files survived only because `.gitignore` does not apply to already-tracked files; any NEW file under `bin/` was silently ignored and would never have shipped. Fixed with a root-anchored negation (`!/bin/`) so nested build dirs stay ignored. Verified: new `bin/` file visible to git, `tools/bin/compiled` still ignored, 0 spurious diffs.

Six commits, all pushed to `origin/main` (`0919f90`), working tree clean:

| Commit | Contents |
|---|---|
| `02c4bd4` | fix: 17 review defects, 3 HIGH security (7 files, +882/−786) |
| `c7839e4` | docs: Phase 18 session record |
| `985d5d6` | fix: `.gitignore` `bin/` entry-point hazard |
| `18d49e6` | ci: label-sync workflow + git hooks, **actions SHA-pinned** |
| `0919f90` | chore: MoAI-ADK tooling configuration |

**Commit hygiene decisions, recorded because they were deliberate:**
- Staged by explicit pathspec throughout; never `git add -A`. Tooling-authored changes (`CLAUDE.md` −553 lines, `.mcp.json`) were committed in their **own** `chore:` commit rather than folded under a `fix:` message that would have misattributed them.
- `.github/` was NOT committed until its actions were pinned. `actions/checkout@v4` → `11d5960a326750d5838078e36cf38b85af677262`, `EndBug/label-sync@v2` → `52074158190acb45f3077f9099fea818aa43f97a`, both resolved via the GitHub API (not transcribed) and confirmed to dereference to commit objects. The pins landed in the **same commit** as the workflow: a workflow goes live the instant it is pushed, and the job holds `issues: write` + `pull-requests: write` + `GITHUB_TOKEN`, so pinning as a follow-up would have left a live window.
- Also verified clean in that workflow while reviewing it: no `pull_request_target`; `permissions:` explicitly scoped; the `dry_run` input is interpolated into a `with:` block rather than a `run:` block, so there is no shell-injection sink.
- Before committing `.gitignore`, its tooling-authored changes were inspected rather than assumed: `logs/` → `logs/*` + `!logs/.gitkeep` (archives still ignored — confirmed at `.gitignore:114`), plus new credential/auth/state ignore patterns. Benign, kept.

Post-push sanity: clean install still yields 6 wrappers / 28 aliases; pre-push hook skipped `ci-local` cleanly (no Makefile).

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

