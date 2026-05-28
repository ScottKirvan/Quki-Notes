# Testing Strategy

Tests ship **with the code**, not as a later cleanup phase. Every feature PR includes its tests. Every bug fix includes a regression test written **before** the fix.

This file is the operational spec. The policy decision lives in `decisions.md` → ADR-13.

---

## Test layers

| Layer           | Tool                        | What goes here                                                                                                                                               |
| --------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Unit            | `flutter_test` + `mocktail` | Pure logic, services with substitutable deps, DAOs (against in-memory drift), serializers, workflow action types, template token resolution                  |
| Widget          | `flutter_test`              | UI behaviour where the widget has non-trivial state or transforms input (formatting toolbar, conflict resolution sheet, sync indicator, image-paste handler) |
| Integration     | `integration_test/`         | End-to-end flows across DB + UI on a real device or emulator (note CRUD round-trip, paste→render→save→reopen, sync push/pull cycle)                          |
| Drift migration | `drift_dev schema verify`   | Schema snapshots in `test/db/schemas/`. Required for every `schemaVersion` bump per ADR-8                                                                    |

---

## What must have a test

- Every workflow action type (`append_to_github_file`, `push_to_github`, `prepend_template`, `append_template`, `insert_todo`)
- Every template token resolution (`{{date}}`, `{{time}}`, `{{gps}}`, `{{address}}`)
- Sync state machine transitions (`pending_push` → `synced`, `pending_push` → `conflict`, etc.)
- Conflict resolution decision branches
- The save controller's debounce/periodic/lifecycle triggers
- Image paste validation (size limits, MIME type whitelist)
- Image-ref diff at save time (detecting removed `![](../images/...)` references for cascade delete)
- Filename generation (`YYYY-MM-DD-{uuid8}.md` format, deterministic from id + createdAt)
- Filename parsing on pull (reverse: extract date and store as `createdAt`)
- GitHub rate-limit throttle logic (pauses when `X-RateLimit-Remaining < 100`)
- Markdown round-trip through `super_editor` for every GFM feature in the toolbar (resolves OQ-1)
- Every `MigrationStrategy.onUpgrade` step (per ADR-8)

## What does NOT need a test

- Pure-render widgets with no state or logic (e.g. a `Text` wrapper)
- Third-party glue with no behaviour of our own added (e.g. `url_launcher` invocation)
- Generated code (`*.g.dart` files, drift output)
- Flutter framework internals
- Trivial getters/setters

If you're unsure: write the test. The cost of one unit test is much smaller than the cost of one production bug.

---

## Test layout

Mirror `lib/`:

```
test/
├── core/
│   ├── database/
│   │   ├── notes_dao_test.dart
│   │   └── ...
│   ├── github/
│   │   ├── github_client_test.dart
│   │   └── rate_limit_test.dart
│   ├── sync/
│   │   ├── sync_controller_test.dart
│   │   ├── save_controller_test.dart
│   │   └── conflict_resolver_test.dart
│   └── settings/
├── features/
│   ├── editor/
│   ├── documents/
│   └── workflows/
│       ├── action_append_to_github_file_test.dart
│       └── template_tokens_test.dart
├── shared/
└── db/
    └── schemas/        ← drift snapshots, do not edit by hand
integration_test/
├── note_crud_flow_test.dart
└── ...
```

**File naming:** `foo.dart` → `foo_test.dart` in the mirrored test path.

---

## Mocking discipline

- **`mocktail`** is the only mock library used. No `mockito` (deprecated codegen approach).
- **Mock services, not data.** `GitHubClient` is mocked; `Note` / `Workflow` are constructed directly.
- **Database tests use real drift** with `NativeDatabase.memory()` — never mock drift. The DAO layer is the boundary; mock it only when testing something built on top of it.
- **Network**: never make real HTTP in unit/widget tests. `dio` is mocked at the client wrapper level. Integration tests may hit a sandbox GitHub repo (deferred — for MVP, integration tests stop at the GitHubClient boundary).

---

## Bug-fix protocol (mandatory)

Every PR with `fix:` in the conventional commit title MUST follow this protocol:

1. **Reproduce the bug** in a test. The test fails on the current `main`.
   - Add the test in the file that mirrors the buggy code (e.g. a sync bug → `test/core/sync/...`).
   - Test name explicitly states the bug: `test('fires push after 30s periodic flush — regression: bug #42', () { ... })`.
2. **Commit the failing test on its own**, optionally with a `// FIXME: failing — fixes #42` comment. CI will be red. This is intentional and proves the test catches the bug.
3. **Implement the fix.** Now the test passes.
4. **Verify locally**: `just test` is green.
5. **PR body** must include:
   - Link to the issue / description of the bug
   - File:line of the regression test
   - One sentence on root cause (not just the symptom)

The regression test stays in the suite forever. **Never delete a regression test** without an ADR justifying it.

**Why two commits (failing test, then fix):** the diff explicitly shows the test catches the bug. If the test passed without the fix, it wouldn't be a valid regression test — it would be testing something the existing code already does, and a future regression could slip past it.

You may squash the two commits into one when merging if Scott prefers — release-please only reads the squash commit title. But the dev-time discipline of "red test first" is non-negotiable.

---

## Flaky tests

**Zero tolerance.** A test that passes intermittently is worse than no test — it teaches the team to ignore CI red.

- A test failing once on retry: investigate immediately, don't ignore.
- A test that can't be made deterministic in one session: add `@Tags(['flaky'])`, open an issue, exclude from CI via `dart test --exclude-tags=flaky`. **Then fix it within the next session** — don't let flaky tests accumulate.
- A test that depends on real network or wall-clock time: refactor to inject the clock / network — never `Future.delayed` in a test.

---

## CI expectations

`ci.yml` runs:

```
flutter analyze
dart format --output=none --set-exit-if-changed lib/ test/
flutter test
```

All three must be green for merge. No exceptions, no `--no-verify`, no `[skip ci]` for fixes.

**Coverage**: no threshold enforced. Coverage thresholds are a perverse incentive (write tests to chase the number, not the risk). The PR review is the gatekeeper — "where's the test for this code path?" is the right question, not "is coverage above 80%?".

Integration tests are **not** run in CI for MVP (they require a device/emulator). Scott runs them locally when merging significant Phase 1+ PRs:

```bash
flutter test integration_test/
```

---

## Phase-by-phase test focus

| Phase | Key tests to add |
|---|---|
| 0 (bootstrap) | Generated default widget test passes — proves CI toolchain works |
| 1 (local capture) | DAO tests (notes + images), save controller triggers, formatting toolbar widget tests, image paste validation, image-ref diff, super_editor round-trip |
| 2 (sync) | GitHubClient with mocked dio, sync state machine, conflict resolver, rate-limit throttle, OAuth device flow polling |
| 3 (workflows) | Each action type, template tokens, workflow engine dispatch, geocoding fallback |
| 4 (sharing/polish) | Native share roundtrip (widget), accessibility semantics, integration tests for full flows |
| 5 (windows port) | Platform-specific quirks (keyboard shortcuts, file path separators) |

Phase 4's "basic testing" line in `design_spec.md` is now obsolete — tests come with code from Phase 1.
