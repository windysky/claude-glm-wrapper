# Next session — nothing mandatory

Saved 2026-10-31 11:19 CDT. No-paste resume: when the user says **"resume"**, **"start"** or **"continue where we left off"**, do this and nothing else first:

1. Read this file and give a **one-line summary** of the saved state.
2. **Confirm with the user before executing anything** — never auto-run.
3. Verify each precondition mechanically and report any drift.
4. Then run the saved prompt. A leading `ultrathink.` cannot fire from a file read, so apply maximum reasoning effort yourself.

Superseded: the 2026-08-17 prompt (three SPECs, done in Phase 19) and the earlier 2026-10-31 prompts (land the install.ps1 fix, done as `48c8f93`; decide the npx package, decided: dropped). Do not re-run any of them.

---

## THE SAVED PROMPT (execute verbatim)

```text
ultrathink. claude-glm-wrapper Phase 20 is closed and npm distribution was dropped on 2026-10-31. Check whether that change is committed, then offer the optional decisions that remain.
applied lessons: wiki/concept/a-tool-absent-from-path-is-not-an-absent-tool.md, wiki/concept/a-key-rotation-is-finished-only-after-a-fingerprint-sweep-of-every-store.md, PROJECT_HANDOFF.md §4 and §7
source_session_id: eb9d3761-ec17-4bca-98a9-92b80313ce41

Preconditions:
1) `git status --short` → empty, or only README.md, package.json, NEXT_SESSION.md, PROJECT_HANDOFF.md, PROJECT_LOG.md (the not-yet-committed npm removal)
2) `git merge-base --is-ancestor 48c8f93 HEAD; echo $?` → `0`; `git rev-list --count --left-right origin/main...HEAD` → `0 0` once pushed
3) `grep -c npx README.md` → `0`, and `grep -c '"private": true' package.json` → `1`
4) `gh repo view windysky/claude-glm-wrapper --json visibility -q .visibility` → `PUBLIC` (unless the user changed it)

Run: If those five files are modified, show `git diff --stat`, wait for the user's go-ahead, then commit by explicit pathspec (no AI-attribution trailer) and push; if nothing is modified, report that nothing is pending.

Follow-up: optional only — the repo is PUBLIC although the user said they do not want others to have the installer: ask whether to make it private (the README's raw.githubusercontent.com one-line installers then stop working for unauthenticated machines); whether install.sh should also update the Windows side; whether to untrack NEXT_SESSION.md.
```
