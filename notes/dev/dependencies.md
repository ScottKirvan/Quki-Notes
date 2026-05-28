# Dependencies

Versions are filled at the Phase 1 kickoff PR (which establishes `pubspec.yaml`). Pin to compatible-version ranges (`^x.y.z`).

**Rule**: do not add a new runtime dependency without first proposing an ADR in `decisions.md`. Dev-only dependencies (test, codegen) can be added inline.

## Runtime

### Core (Phase 1)

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
| `logging` | TBD | Structured logger |

### Sync (Phase 2)

| Package | Version | Purpose |
|---|---|---|
| `dio` | TBD | HTTP client |
| `github` | TBD | GitHub API helpers (typed responses) |
| `flutter_secure_storage` | TBD | OAuth token storage |
| `shared_preferences` | TBD | Non-sensitive settings |
| `url_launcher` | TBD | Open device-flow verification URI |

### Workflows (Phase 3)

| Package | Version | Purpose |
|---|---|---|
| `geolocator` | TBD | GPS capture |
| `geocoding` | TBD | Platform-native reverse geocoding (no API key) |

### Sharing (Phase 4)

| Package | Version | Purpose |
|---|---|---|
| `share_plus` | TBD | Native share sheet (in + out) |

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
- **`super_clipboard` Windows support** is functional but newer than the mobile path; verify on Windows during Phase 5.
- **GitHub API library**: `github` package is used for typed response models only — actual HTTP goes through `dio` so we control retries, rate-limit handling, and header inspection.
- **`flutter_secure_storage` Linux** uses libsecret; not relevant until/unless a Linux target is added.
- Do not add Firebase, Sentry, Crashlytics, Google Analytics, or any telemetry SDK. See ADR-12.
