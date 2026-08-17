# Next session — execute the three SPECs

Saved 2026-08-17 11:43 CEST. Paste-ready: say **"resume"** and run this.

---

ultrathink. Execute the three queued SPECs in `.moai/specs/`, in this order. No code changed since they were written — `origin/main` is `b0ff602`, working tree clean.

**1. `SPEC_INDEPENDENT_REVIEW_ORCHESTRATOR_FIXES.md` — first, and it is a REVIEW, not a fix.**
Deliverable is a verdict plus `file:line` findings. Do **not** produce a diff; file any finding as a new SPEC rather than fixing inline. It audits four `install.sh` fixes that carry the same author for both implementation and verification — the one thing the Phase 18 review was built to avoid. Each of R1-R4 names a specific attack to attempt; report the outcome **whether or not the attack succeeded**, because an unreported negative is indistinguishable from not trying. R1 (the CRLF alias regex) is the one where a defect would be silent user-data loss — test both directions: managed lines must be removed in LF/CRLF/trailing-space form, AND user-owned colliding aliases must survive in LF *and* CRLF.

**2. `SPEC_LOW_DEFECTS_CLEANUP.md` — four LOW defects, all with reproductions.**
Read §1a before touching it. An earlier prescription of `mapfile -t` was caught as defective and must not come back: `mapfile` is bash 4.0+, macOS ships 3.2.57, macOS is supported, and `install.sh` has zero bash-4 constructs — under `set -eE` it 127s into the ERR trap and hands every macOS user a file-a-bug prompt. It also turns the empty-array case into a phantom entry that reaches `rm ""`. The SPEC carries the corrected bash-3.2-safe `while IFS= read -r` form with an `[ -n ]` guard.

**3. `SPEC_SHELLCHECK_BASELINE.md` — install shellcheck, lint 4 files, record a baseline.**
Per-file dialect matters: `install.sh` and `smoke_test_models.sh` are bash (`-s bash`); `.git_hooks/pre-commit` and `pre-push` are `#!/bin/sh` (`-s sh`). The SPEC recommends accepting existing findings as debt and gating only NEW ones — read its argument before overriding it.

**Do NOT re-execute `SPEC_SECURITY_APIKEY_INJECTION.md`.** It is marked IMPLEMENTED in its own header; it is a record of Phase 18, not a work item.

**Test discipline, non-negotiable:** never run the installer against the real `$HOME` — always `env HOME="$sandbox"`. Run test scripts as child `bash script.sh` processes; inline `( … )` subshells interfere with grep in this environment. Never print a real API key.

**No-regression bar for anything touching the installer:** clean install still yields 6 wrappers and 28 aliases; user-owned colliding aliases still survive in LF and CRLF; `bash -n install.sh` and `bash -n smoke_test_models.sh` pass; a mode-600 rc keeps its mode *and inode*; a symlinked rc stays a symlink.

**Known gap to carry:** these SPECs were never independently audited — `plan-auditor` was spawned and never delivered. Their factual claims were verified against the real files; their structure was not. Apply normal scepticism, and if something in a SPEC looks wrong, say so rather than executing it faithfully.

Context: `PROJECT_HANDOFF.md` §7 (starting point + environment notes) and `PROJECT_LOG.md` Phase 19 entry (why the `mapfile` prescription was rejected).
