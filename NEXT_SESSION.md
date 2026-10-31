# Next session — land the install.ps1 fix, then the npx decision

Saved 2026-10-31 10:19 CDT. No-paste resume: when the user says **"resume"**, **"start"** or **"continue where we left off"**, do this and nothing else first:

1. Read this file and give a **one-line summary** of the saved state.
2. **Confirm with the user before executing anything** — never auto-run. The Run step below commits and pushes; it needs their go-ahead.
3. Verify each precondition mechanically and report any drift.
4. Then run the saved prompt. A leading `ultrathink.` cannot fire from a file read, so apply maximum reasoning effort yourself.

Superseded: the 2026-08-17 prompt ("execute the three SPECs") — those were executed in Phase 19. Do not re-run it.

---

## THE SAVED PROMPT (execute verbatim)

```text
ultrathink. claude-glm-wrapper Phase 20 close-out entering — land the uncommitted install.ps1 fix, then the npx decision.
applied lessons: wiki/concept/a-tool-absent-from-path-is-not-an-absent-tool.md, wiki/concept/a-key-rotation-is-finished-only-after-a-fingerprint-sweep-of-every-store.md, PROJECT_HANDOFF.md §4 and §7
source_session_id: eb9d3761-ec17-4bca-98a9-92b80313ce41

Preconditions:
1) `git status --short` → exactly ` M install.ps1` plus the three session docs (PROJECT_HANDOFF.md, PROJECT_LOG.md, NEXT_SESSION.md); nothing else
2) `git fetch origin main -q; git rev-list --count --left-right origin/main...HEAD` → `0 0`, and `git rev-parse --short HEAD` → `819f3a9`
3) `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'` → 5.1.x (not on PATH; that is expected)
4) `git diff --stat install.ps1` → 9 insertions, 4 deletions, and the diff contains `ReadAllLines`

Run: Show `git diff install.ps1` and wait for the user's go-ahead; then commit it by explicit pathspec with subject "fix(install.ps1): read .env.glm as explicit UTF-8 so non-ASCII comments survive" (no AI-attribution trailer) and push.

Follow-up: package.json and README.md:39 advertise `npx @windysky/claude-glm-installer`, but npm returns E404 for it — ask whether to publish it or drop the claim.
```
