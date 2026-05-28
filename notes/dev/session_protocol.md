# Session Protocol for Implementation Claude

What to do at the **start** and **end** of every implementation session, and the hard rules that apply throughout.

## At session start

1. **Read in this order:**
   - `CLAUDE.md` (repo root) — high-level context + locked decisions table
   - `notes/dev/design_spec.md` — full spec; jump to the section relevant to today's task
   - `notes/dev/decisions.md` — rationale behind every locked decision; do not relitigate without discussing with Scott
   - `notes/dev/open_questions.md` — if your task touches an open question, propose a resolution before implementing

2. **Check repo state:**
   - `git status` — working tree should be clean before you start
   - `git branch --show-current` — confirm you are **not** on `main`; create a new branch if needed
   - `gh pr list` — see what is already open; do not duplicate work
   - `gh run list -L 5` — confirm CI on `main` is green; if red, fix that first or ask

3. **Confirm scope:**
   - Which phase? Which task from the design_spec Development Pipeline checklist?
   - One PR = one logical unit. If the assigned task is bigger than one PR's worth, split it before writing code.
- If the task is a **bug fix** (PR title will start `fix:`), follow the protocol in `testing.md` → Bug-fix protocol: write the failing regression test **before** the fix. Commit the test separately so the diff proves it catches the bug.

## While working

- Branch name: `feat/phase<N>-<short-slug>` or `fix/<short-slug>` or `chore/<slug>`.
- Run `just lint` and `just test` before every commit.
- After any drift schema change: `just gen`, then add/update the schema snapshot under `test/db/schemas/` and write a migration test.
- Add a comment in code only when the logic is not self-evident from the code itself. Do not add docstrings or comments to code you didn't change.
- If you need a new runtime dependency, **stop and propose an ADR entry first**.

## At session end

1. Open a PR using `notes/dev/pr_template.md`.
2. Title = conventional commit message; it will become the squash commit on merge.
3. If you made a non-trivial implementation decision during the session (one of two viable approaches, novel pattern), add an entry to `decisions.md` and link it from the PR body.
4. If you discovered a new open question (couldn't be resolved without more info from Scott), add it to `open_questions.md`.
5. **Never** commit or push to `main`. **Never** force-push. **Never** use `--no-verify`.

## Hard rules (do not violate without explicit instruction)

| Rule | Source |
|---|---|
| OAuth token lives in `flutter_secure_storage`, never in `shared_preferences` or files | ADR-2 |
| Workflow target file SHAs are always re-fetched, never cached | ADR-7 |
| Images are lazy-fetched on note open, never bulk-downloaded | ADR-11 |
| No analytics, no crash reporting, no telemetry SDK | ADR-12 |
| `build-ios.yml` is a stub and must NOT be wired to trigger automatically | CLAUDE.md |
| OAuth tokens and full note contents are never logged | ADR-12 |
| Image base64-embedding in markdown is forbidden | ADR-4 |
| `deletedAt` is the only correct way to delete a note; do not hard-delete a synced note directly | ADR-5 |
| Save and Push are separate; only the 2s idle debounce, foreground, and manual button trigger push | ADR-6 |
| Tests ship with the code in every feature PR — not retrofitted later | ADR-13 |
| Bug fixes: failing regression test **first**, verify it fails, then write the fix | ADR-13 |
| Flaky tests are tagged and fixed within one session — never left to accumulate | ADR-13 |

## Tooling expectations

- `just` is the task runner. Common targets: `just android`, `just windows`, `just test`, `just lint`, `just gen`, `just docs`.
- `gh` (GitHub CLI) is available for PR/issue/run operations. Prefer it over the web UI when scripting.
- Scott runs the app on a physical Android device for manual test. Claude does not need to run the app — but `flutter analyze` and `flutter test` must pass locally before opening a PR.

## When in doubt

Ask Scott. The cost of one clarifying question is much lower than the cost of a PR that misses the intent.
