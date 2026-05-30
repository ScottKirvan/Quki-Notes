# Dependencies

Versions are filled at the Phase 1 kickoff PR (which establishes `pubspec.yaml`). Pin to compatible-version ranges (`^x.y.z`).

**Rule**: do not add a new runtime dependency without first proposing an ADR in `decisions.md`. Dev-only dependencies (test, codegen) can be added inline.

## Runtime

### Core (Phase 0 / Phase 1 — required for MVP local capture)

| Package | Version | Purpose |
|---|---|---|
| `flutter` (sdk) | — | Framework |
| Dart SDK | `>=3.x <4.0.0` | Language |
| `flutter_riverpod` | TBD | State management runtime |
| `riverpod_annotation` | TBD | `@riverpod` annotation |
| `drift` | TBD | SQLite ORM runtime |
| `sqlite3_flutter_libs` | TBD | Bundled SQLite library |
| `path_provider` | TBD | App documents directory |
| `uuid` | TBD | UUID v4 generation |
| `super_editor` | TBD | WYSIWYG markdown editor |
| `super_clipboard` | TBD | Clipboard image paste |
| `shared_preferences` | TBD | Non-sensitive settings |
| `logging` | TBD | Structured logger |

### Transports (Phase 2 — for first built-in QuKi-Toss)

| Package | Version | Purpose |
|---|---|---|
| `share_plus` | TBD | Share-sheet transport (toss-to-share) |

Additional transport-specific packages (e.g. `dio`, `flutter_secure_storage`, `url_launcher` for any GitHub/HTTP transport) are added **with the plugin that needs them**, not preemptively. Authentication helper (`lib/core/auth/`) lands at the same time as the first OAuth-needing plugin.

### Share-in + GPS (Phase 3 polish)

| Package | Version | Purpose |
|---|---|---|
| `receive_sharing_intent` | TBD | Android share-in (receive intents) |
| `geolocator` | TBD | GPS capture (per-toss opt-in) |
| `geocoding` | TBD | Platform-native reverse geocoding (no API key) |

### Sync (Phase 4+ — first sync plugin)

| Package | Version | Purpose |
|---|---|---|
| `dio` | TBD | HTTP client (if not already brought in by an earlier transport) |
| `github` | TBD | GitHub API typed responses (if GitHub is the first sync backend) |
| `flutter_secure_storage` | TBD | Token storage (if not already brought in by an earlier transport) |
| `url_launcher` | TBD | OAuth device-flow verification URI launch |

## Dev / Build

| Package | Version | Purpose |
|---|---|---|
| `build_runner` | TBD | Code-generation runner |
| `riverpod_generator` | TBD | Generates providers from `@riverpod` |
| `drift_dev` | TBD | Generates drift code + schema verification |
| `flutter_lints` | TBD | Lint rules |
| `mocktail` | TBD | Test mocks (no codegen) |

## Notes

- **`super_editor` ↔ markdown round-trip** is a known open question (`open_questions.md` → OQ-1). If GFM features (task lists, tables) don't round-trip cleanly, fallback is `appflowy_editor`.
- **`super_clipboard` Windows + Linux support** — verify on each desktop target during Phase 3.
- **`flutter_secure_storage` on Linux** uses libsecret — see OQ-NEW-4 for the keyring availability problem.
- **GitHub API library** (when used): `github` package for typed response models only; actual HTTP through `dio` so we control retries, rate-limit handling, and header inspection.
- The `lib/core/` constraint (Flutter-free, ADR-16) means: packages that depend on `flutter:` material (e.g. `share_plus`, `super_clipboard`) live behind interfaces in `lib/features/` or `lib/ui/` — not directly imported from `lib/core/`.
- Do not add Firebase, Sentry, Crashlytics, Google Analytics, or any telemetry SDK. See ADR-12.
