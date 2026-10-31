# Next session — decide the npx package

Saved 2026-10-31 10:47 CDT. No-paste resume: when the user says **"resume"**, **"start"** or **"continue where we left off"**, do this and nothing else first:

1. Read this file and give a **one-line summary** of the saved state.
2. **Confirm with the user before executing anything** — never auto-run.
3. Verify each precondition mechanically and report any drift.
4. Then run the saved prompt. A leading `ultrathink.` cannot fire from a file read, so apply maximum reasoning effort yourself.

Superseded: the 2026-08-17 prompt ("execute the three SPECs", done in Phase 19) and the earlier 2026-10-31 prompt ("land the install.ps1 fix", done — commit `48c8f93`). Do not re-run either.

---

## THE SAVED PROMPT (execute verbatim)

```text
ultrathink. claude-glm-wrapper Phase 20 is closed and pushed — decide what to do about the unpublished npx package.
applied lessons: wiki/concept/a-tool-absent-from-path-is-not-an-absent-tool.md, wiki/concept/a-key-rotation-is-finished-only-after-a-fingerprint-sweep-of-every-store.md, PROJECT_HANDOFF.md §4 and §7
source_session_id: eb9d3761-ec17-4bca-98a9-92b80313ce41

Preconditions:
1) `git status --short` → empty (nothing uncommitted)
2) `git fetch origin main -q; git merge-base --is-ancestor 48c8f93 HEAD; echo $?` → `0`, and `git rev-list --count --left-right origin/main...HEAD` → `0 0`
3) `npm view @windysky/claude-glm-installer version` → still E404 (if it now prints a version, the package was published: just check package.json and README.md:39 agree with it)
4) `grep -n 'npx @windysky' package.json README.md` → matches in both files

Run: Ask the user (AskUserQuestion) whether to publish `@windysky/claude-glm-installer` to npm or drop the npx claim from package.json and README.md:39; then do the chosen one and nothing else.

Follow-up: optional only — whether install.sh should also update the Windows side (HANDOFF §4), and whether to untrack NEXT_SESSION.md.
```
