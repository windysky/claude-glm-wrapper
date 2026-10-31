# Next session — nothing mandatory

Saved 2026-10-31 11:30 CDT. No-paste resume: when the user says **"resume"**, **"start"** or **"continue where we left off"**, do this and nothing else first:

1. Read this file and give a **one-line summary** of the saved state.
2. **Confirm with the user before executing anything** — never auto-run.
3. Verify each precondition mechanically and report any drift.
4. Then run the saved prompt. A leading `ultrathink.` cannot fire from a file read, so apply maximum reasoning effort yourself.

Superseded: every earlier prompt (the 2026-08-17 three-SPEC prompt; the 2026-10-31 prompts to land the install.ps1 fix, decide the npx package, and commit the npm removal — all done and pushed). Do not re-run any of them.

---

## THE SAVED PROMPT (execute verbatim)

```text
ultrathink. claude-glm-wrapper: Phase 20 is closed and pushed (npm distribution dropped). The alias-wildcard fix (SPEC_ALIAS_GLM_WILDCARD_OVERMATCH) was implemented, committed and pushed on 2026-10-31 — confirm nothing is pending, then offer the optional decisions that remain.
applied lessons: wiki/concept/a-tool-absent-from-path-is-not-an-absent-tool.md, wiki/concept/a-key-rotation-is-finished-only-after-a-fingerprint-sweep-of-every-store.md, PROJECT_HANDOFF.md §4-§7
source_session_id: eb9d3761-ec17-4bca-98a9-92b80313ce41

Preconditions:
1) `git status --short` → empty (nothing uncommitted)
2) `git merge-base --is-ancestor 1fdd906 HEAD; echo $?` → `0`; `git rev-list --count --left-right origin/main...HEAD` → `0 0` once pushed
3) `grep -vE '^[[:space:]]*#' install.sh install.ps1 | grep -c 'claude-glm\[A-Za-z0-9'` → `0` (comments are excluded on purpose: they quote the old pattern), and `grep -c managedWrappers install.ps1` → at least `1`
4) `gh repo view windysky/claude-glm-wrapper --json visibility -q .visibility` → `PUBLIC` (unless the user changed it)

Run: If anything is modified, show `git diff --stat` and wait for the user's go-ahead before committing; if nothing is modified, report that nothing is pending.

Follow-up: optional only — the repo is PUBLIC although the user said they do not want others to have the installer: ask whether to make it private (the README's raw.githubusercontent.com one-line installers then stop working for unauthenticated machines); whether install.sh should also update the Windows side; whether to untrack NEXT_SESSION.md.
```
