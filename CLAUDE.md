# QuKi — Claude Context

## What This Is

A personal writing/notetaking app inspired by iOS Drafts. Rapid capture first — app opens to a blank note, no friction. Notes sync across devices via GitHub. Workflows deliver notes to other destinations (e.g. daily log in a separate repo).

**Design phase: complete.** Full spec at `notes/dev/design_spec.md`.
**Next phase: Phase 1 implementation** — local capture on Android.

---

## Key Decisions (all locked)

| Decision                  | Choice                                                                                                                                                              |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Framework                 | Flutter (Dart)                                                                                                                                                      |
| State management / DI     | `riverpod` + `riverpod_generator` (code-gen, `@riverpod`)                                                                                                           |
| Active platforms          | Android first, then Windows                                                                                                                                         |
| Deferred platforms        | iPadOS / iOS / Mac (codebase supports; builds deferred — macOS runner cost)                                                                                         |
| Markdown flavor           | GFM                                                                                                                                                                 |
| WYSIWYG editor            | `super_editor` (fallback: `appflowy_editor`)                                                                                                                        |
| Local storage             | `drift` (SQLite ORM)                                                                                                                                                |
| GitHub API client         | `dio` + `github` Dart package                                                                                                                                       |
| Auth                      | GitHub OAuth 2.0 — **Device Flow** on all platforms (scopes: `repo`, `read:user`); no URL scheme registration                                                       |
| Token storage             | `flutter_secure_storage` (OS keystore — never `shared_preferences`)                                                                                                 |
| Note IDs / filenames      | UUID v4 (`uuid` package); GitHub path `notes/YYYY-MM-DD-{uuid8}.md` (first 8 hex chars of id)                                                                       |
| Image storage             | Separate binary files in `images/YYYY-MM-DD-{uuid8}.{ext}`; markdown ref `![](../images/...)`; never base64-embedded                                                |
| Deletion model            | Soft-delete via `deletedAt` column → hard-delete on successful remote DELETE; remote-side deletions out of scope for MVP                                            |
| Save vs push              | Save (local SQLite) and push (GitHub) are separate. Save: 2s debounce + 30s periodic + lifecycle paused/detached. Push: 2s idle debounce + foreground + manual only |
| Workflow target SHAs      | Always re-fetch at execution time (never cached); 409 → retry read-modify-write once                                                                                |
| Drift migrations          | Integer `schemaVersion` + `MigrationStrategy.onUpgrade`; schema snapshots in `test/db/schemas/`; migration test required per version bump                           |
| Cross-device timestamps   | On pull: `createdAt` derived from filename date prefix; `modifiedAt` = pull time; fresh local UUID for `id`; `githubPath` captured verbatim                         |
| Rate limiting             | Honour `X-RateLimit-Remaining` (<100 → pause until reset); newest-first note pull; images lazy-fetched on first view                                                |
| Theme / Logging / Privacy | Follow system theme; `logging` package (console in debug, in-memory ring buffer in release); **no analytics, no crash reporting**                                   |
| Conflict resolution       | SHA-based; user picks version (no merge)                                                                                                                            |
| Workflow engine           | In-app JSON DSL; workflows stored as files in GitHub repo                                                                                                           |
| Versioning                | Semantic versioning via release-please (`dart` type)                                                                                                                |
| Commits                   | Conventional commits; squash merge; PR title = commit message                                                                                                       |
| Task runner               | `just` (justfile)                                                                                                                                                   |
| Docs                      | VitePress → GitHub Pages                                                                                                                                            |

---

## Project Structure

```
QuKi-Notes/
├── lib/
│   ├── core/         ← database/, github/, sync/, settings/
│   ├── features/     ← editor/, documents/, workflows/, onboarding/, settings/
│   └── shared/       ← models/, widgets/
├── android/
├── ios/              ← present but not actively built
├── windows/
├── docs/             ← VitePress source
├── .github/
│   ├── workflows/    ← ci.yml, build-android.yml, build-windows.yml, build-ios.yml (stub), docs.yml
│   └── release-please.yml
└── justfile
```

Full layout in `notes/dev/design_spec.md` → Project Structure.

---

## Development Workflow

Claude opens focused PRs (one logical unit each). Scott tests on device and merges.

1. Claude opens PR with conventional commit title + test instructions
2. CI runs (`flutter analyze`, `flutter test`)
3. Scott tests on Android, squash merges
4. release-please accumulates commits → opens Release PR when ready
5. Scott merges Release PR → GitHub Release created → build workflows fire (APK + Windows)

**Branch naming**: `feat/phase1-drift-schema`, `fix/sync-conflict-409`
**PR size**: one screen, one service, or one action type — small enough to test in a session

---

## Development Pipeline Summary

| Phase | Goal                                           | Status      |
| ----- | ---------------------------------------------- | ----------- |
| 1     | Local capture on Android (no sync)             | Not started |
| 2     | GitHub sync (push/pull, conflict resolution)   | Not started |
| 3     | Workflow engine (daily log, geotagged entries) | Not started |
| 4     | Sharing + Polish (Android complete)            | Not started |
| 5     | Windows port                                   | Not started |
| 6     | iPadOS / iOS / Mac (deferred)                  | Deferred    |

---

## Workflow System — Key Concepts

- Workflows are **delivery actions** — notes stay in QuKi AND are sent to a destination
- Workflow definitions are JSON files in `/workflows/` of the GitHub repo — sync to all devices automatically
- Core action: `append_to_github_file` — read-modify-write to a dated file in **any** authorized GitHub repo (not just the notes repo)
- Two entry formats: **plain** (`---` + text) and **geotagged** (`---` + address + maps URL + altitude + text)
- Real-world example: `sk/02_Calendar/Daily/in/{{date}}_in.md` in `ScottKirvan/Vaults`
- GPS via `geolocator`; reverse geocoding via `geocoding` (platform-native, no API key)

---

## GitHub Repo Structure (runtime)

```
{notes_repo}/
├── notes/        ← YYYY-MM-DD-{uuid8}.md (one file per note; uuid8 = first 8 hex chars of note's UUID v4)
├── images/       ← YYYY-MM-DD-{uuid8}.{ext} (binaries — png/jpg/gif/webp; referenced from notes as ../images/...)
└── workflows/    ← daily-log.json, daily-log-geo.json, etc.
```

---

## Sync Model (summary)

Queue-based optimistic sync. Local writes are instant (SQLite). Push/pull async.

- `sync_status` per note: `synced` | `pending_push` | `conflict` | `error`
- Push triggered: after auto-save debounce (~2s), on foreground, on manual sync
- Pull triggered: on launch, on foreground after >5 min, on manual sync
- Conflict: GitHub 409 → fetch remote → user picks version → push with current SHA
- UI: persistent cloud icon with state; never blocks writing

---

## Notes for Implementation Claude

**Required reading at session start** (in order):

1. This file — high-level context + locked decisions table above
2. `notes/dev/design_spec.md` — full design spec (jump to the section relevant to today's task)
3. `notes/dev/decisions.md` — ADR-lite log of every locked decision with rationale and rejected alternatives
4. `notes/dev/open_questions.md` — unresolved items; resolve in the PR if your task touches one
5. `notes/dev/session_protocol.md` — start/end-of-session checklist + hard rules
6. `notes/dev/testing.md` — testing strategy, what must have a test, mandatory bug-fix protocol
7. `notes/dev/pr_template.md` — PR title format + body template (use for every PR)

`notes/dev/dependencies.md` is the canonical list of approved packages; do not add new runtime dependencies without proposing an ADR first.

**First session only:** `notes/dev/bootstrap.md` contains the step-by-step task list for the **Phase 0 scaffold PR** (project structure, pubspec, justfile, CI workflows, VitePress). Read it once at the very first session; after the bootstrap PR is merged it becomes reference-only.

**Scott's environment setup** lives at `notes/dev/dev_env_setup.md` — Sonnet does not run any of it; included here for context on the toolchain Scott uses.

**Hard rules** (full list in `session_protocol.md`):

- Do not commit or push without explicit instruction from Scott
- Open one PR per logical unit; include clear test instructions using `pr_template.md`
- Use conventional commit PR titles; Scott will squash merge
- `just gen` must be run after any drift schema change; migration test required for version bumps
- `build-ios.yml` exists as a stub but must NOT be wired to trigger — macOS runner cost
- The `geocoding` package uses platform-native geocoding — no API key needed
- No analytics, no crash reporting, no telemetry SDKs — ever (see ADR-12)
- OAuth tokens and full note contents are never logged

---

**Last Updated**: May 26, 2026
