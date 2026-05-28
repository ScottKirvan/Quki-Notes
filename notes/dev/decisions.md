# Architecture Decision Records

Compact log of every locked decision. Format: **what**, **why**, **rejected alternatives**. Order: most recent first.

When implementation surfaces a need to change one of these, propose an ADR update in the PR rather than deviating silently. New decisions made during implementation must be appended here.

Full detail for every entry lives in `design_spec.md`; this file is the index + rationale.

---

## ADR-13: Testing discipline — tests with code, regression tests for fixes

- **Tests ship with code, every PR.** No "tests come later in Phase 4" — that line is removed from the design_spec.
- **Bug fixes follow strict regression-test-first discipline**: write a failing test that reproduces the bug, commit it, then write the fix. The test stays in the suite permanently.
- Layers: unit (pure logic + services), widget (stateful UI), integration (DB + UI flows), drift migration (schema verification).
- Mock services with `mocktail`; never mock data classes or drift itself (use `NativeDatabase.memory()`).
- No coverage threshold — perverse incentive. PR review asks "where's the test?" instead.
- Flaky tests: zero tolerance. Tag and fix immediately; do not let them accumulate.
- **Rejected**: deferred testing (lets bugs land + locks in untestable architectures); coverage gates (incentivises noise tests); mocking the database (couples tests to ORM internals).
- Full operational detail: `notes/dev/testing.md`.

## ADR-12: Theme / Logging / Privacy posture

- **Theme**: follow system (`ThemeMode.system`); ship light + dark in v1; no manual override in MVP.
- **Logging**: `package:logging`; console in debug, in-memory ring buffer in release; per-feature hierarchical loggers; sensitive data never logged.
- **Privacy**: no analytics, no crash reporting, no telemetry. Network limited to `github.com` / `api.github.com`.
- **Rejected**: Sentry/Crashlytics/Firebase (privacy posture; revisit only if distribution broadens).

## ADR-11: Rate limiting & lazy image download

- GitHub auth limit: 5,000 req/hr. Throttle when `X-RateLimit-Remaining < 100`.
- Initial sync: notes pulled in full newest-first; **images lazy-fetched** on first note view (row inserted with `localPath = null`).
- **Why lazy for images**: notes are KB-sized, images can be MB each; bulk image pull would burn bandwidth + rate budget for files the user may never view.

## ADR-10: Cross-device timestamps on pull

- Pulling a remote-only note: generate fresh local UUID for `id`; capture `githubPath` verbatim; `createdAt` = filename date + `00:00:00` local; `modifiedAt` = pull time.
- Sub-day precision is lost cross-device — acceptable for MVP; revisit only if it bites.
- **Rejected**: YAML frontmatter (commits us to non-empty file content schema and adds parsing); extra `GET /commits` per file (rate-limit cost).

## ADR-9: OAuth — GitHub Device Flow on all platforms

- One auth path, all targets: Device Flow with `client_id` only (public client, no secret).
- Scopes: `repo`, `read:user`. No others.
- Deps added: `url_launcher` (open verification URI in system browser); flow implemented on `dio` directly (~50 lines, no dedicated OAuth library).
- **Rejected**: PKCE-per-platform via `flutter_appauth` (platform-specific URL scheme registration; Windows support immature); raw client-secret flow (cannot keep secret in a client app).

## ADR-8: Drift migration discipline

- Integer `schemaVersion` + `MigrationStrategy.onUpgrade`.
- Schema snapshots committed under `test/db/schemas/`; verified via `drift_dev schema verify`.
- Every version bump = a migration test that runs the upgrade against the prior snapshot.
- v1 = `notes` + `images` (Phase 1, with all sync columns); v2 adds `workflows` + `authorized_repos` (Phase 3). Phase 2 does not bump.
- **Why**: drift migrations are manual; without a snapshot test, additive changes silently work and destructive changes silently break.

## ADR-7: Workflow target SHAs — always re-fetch

- `append_to_github_file` always does `GET /contents/{path}` → modify → `PUT` with fresh SHA. Never cached.
- 409 → auto-retry read-modify-write once; if still fails, surface error to user.
- **Why**: target files (e.g. a shared daily log) are typically edited externally between fires; cached SHA would almost always be stale.

## ADR-6: Save vs Push — separate concerns

- **Save** (local SQLite): 2s idle debounce + 30s periodic + lifecycle `inactive`/`paused`/`detached`. Never blocks, never networks.
- **Push** (GitHub): 2s idle debounce + foreground + manual button only. Periodic/lifecycle saves do **not** trigger push.
- **Why**: protects against long-typing-run data loss without spamming GitHub. Max unsaved window ≈ 30s.

## ADR-5: Deletion model — soft delete then hard

- `notes.deletedAt` nullable column. Set on user delete; row hidden from queries; queued for push.
- Push: DELETE remote (if `githubPath != null`) → hard-delete local row + cascade to images. 404 = success.
- **Remote-side deletions out of scope for MVP** — only deletions originating in the app propagate.
- **Why**: clean offline-capable delete; preserves the option to undo before sync; symmetric with the existing sync-state model.

## ADR-4: Image storage — separate binary files, lazy fetch

- Binary files in `images/YYYY-MM-DD-{uuid8}.{ext}`; markdown reference `![](../images/{filename})`.
- Local: `<app docs>/images/{filename}`; tracked in `images` table with own sync state.
- Push order: image before referencing note (avoids broken-link window).
- Cascade delete on note delete.
- **Rejected**: base64-embed in markdown (file bloat, editor performance, unreadable on GitHub); threshold hybrid (complexity not worth MVP).

## ADR-3: Note IDs & filenames — UUID v4 + 8-hex suffix

- Note `id` = UUID v4 (`uuid` package).
- GitHub path = `notes/YYYY-MM-DD-{uuid8}.md`, deterministic from `createdAt` + `id` on the originating device only. Once set, `githubPath` is captured and never recomputed.
- **Rejected**: `YYYY-MM-DD-NNN.md` (offline-device collisions; requires GET-before-write to assign NNN); `YYYY-MM-DDTHHMMSS.md` (clock-skew collisions).
- 2^32 collision space per day = effectively zero collision risk without coordination.

## ADR-2: Token storage — `flutter_secure_storage` only

- OAuth token lives in OS-keystore-backed `flutter_secure_storage`. Nothing else goes there.
- All other settings stay in `shared_preferences` (plaintext is fine for non-secrets).
- **Why**: `repo`-scope token = read/write all user repos; plaintext on Android (`/data/data/.../shared_prefs/*.xml`) or Windows (`%APPDATA%`) is an unacceptable threat surface for ~zero implementation cost.

## ADR-1: State management — Riverpod (code-gen)

- `riverpod` + `riverpod_generator` with `@riverpod` annotation throughout.
- No global singletons, no manual `InheritedWidget`, no `setState` outside trivial widget-local state.
- Provider lives next to the feature it serves; cross-cutting providers live in `core/`.
- **Rejected**: Bloc (more ceremony than warranted for solo project); plain `provider` (Riverpod is the maintained successor); manual DI (loses testability and reactive streams).
