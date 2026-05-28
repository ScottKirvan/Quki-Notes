# QuKi — Design Spec

What is a QuKi?  A QuKi is a short note, a picture, a thought, a temporary list, or a rough draft waiting to be copy/pasted or sent elsewhere to become some other type of greater content, or to just be jotted down and left to drift away.  QuKi's live in the moment - their context is the now.  QuKi's don't live in a world where they're saved, treasured, organized, stored, and kept - QuKi's are ephemeral and may or may not become part of some greater idea.

Under the hood, a QuKi is a simple markdown file that can be sync'd across different devices or dispatched off to some other location or project.  You don't have to think about QuKi's - that's something else's job.  The biggest job a QuKi has is temporary.  It's goal is to be that for you, frictionlessly, effortlessly, quickly, and to do so when and where you want, on whatever device you have handy.
## Project Overview

A personal writing/notetaking application inspired by iOS Drafts, focusing on rapid capture and workflow integration. The app emphasizes minimal friction—opening directly to a blank note with no assumed formatting.

**Target Platforms** (Priority Order):
1. Android — active development target
2. Windows / Linux — active development target (after Android)
3. iPadOS / iOS / Mac — codebase supports these via Flutter; builds deferred (macOS GitHub Actions runners cost 10x minutes on Free tier)

The Flutter codebase targets all platforms from the start — no platform-specific rewrites needed later. Deferred platforms just need a build job added and platform testing when ready.

**Target User**: Personal use case—rapid note capture with workflow automation and GitHub syncing for cross-device access.

---

## Core Features

### 1. Note Capture & Editing
- **New Note on Launch**: App opens immediately to a blank, editable note
- **Minimal Assumptions**: No default headers, topic fields, filenames, or list formatting forced
- **Editor Style**: Markdown WYSIWYG interface
- **Formatting Toolbar**: Bottom toolbar with buttons for:
  - Bold, italic, strikethrough
  - Lists (bulleted, numbered)
  - Code blocks
  - Links
  - Other common markdown formatting
- **Image Support**: Copy/paste images into notes; stored as embedded content or file references
- **Device Sharing**: Native share menu integration (Android share sheet, iPadOS share sheet, Windows share)

### 2. Note Identification & Titling
- **Auto-Identification**: Document displayed in manager by first ~50-100 characters (truncated) from the first line of the note with any characters on it.  If the first two lines of the note are blank, and the 3rd line contains, "abc", the note will be auto-identified with the title, "abc"
- **Optional Title**: User *can* force the name displayed by adding a title/topic to the first line of the note, but it's optional
- **Display**: The truncated first line serves as the visual reference in document list -- the names listed may contain duplicates - this is allowed.

### 3. Document Manager
The Document Manger is a temporal queue, not a filing cabinet or a way to organize and collect notes -- it surfaces what's current and relevant, letting older notes age off screen. No folders.  There will be basic search, because sometimes memories or thoughts get lost in old notes ("old QuKi's") and need to be recalled, but nothing like integrated tags for grouping and categorizing.

- **CRUD Operations**: Create, read, update, delete notes
- **Sorting**: Most recent on top
- **List View**: Shows truncated first line of each note + metadata (date modified, etc.) - the only way to rename a note is to edit the first line of the note itself
- **No Complex Organization**: Keep it simple — a flat list

### 4. Workflow Integration
- **Workflow Actions**: Append current note to a workflow that can:
  - Insert TOD/TODO markers
  - Capture GPS location
  - Add timestamps
  - Format or rewrite content
- **Output Options**: Append or drop the formatted note into GitHub or other destinations
- **Extensibility**: Design to support custom workflows in the future

### 5. GitHub Integration
- **Primary Sync Backend**: GitHub as the source of truth for notes across devices
- **Sync Model**:
  - Notes stored as markdown files in a GitHub repository (`/notes/YYYY-MM-DD-NNN.md`)
  - Local device maintains a working copy in SQLite via `drift`
  - Bi-directional sync: queue-based optimistic — local writes instant, push async
  - Conflict resolution: GitHub SHA-based detection; user picks version (no merge)
- **Authentication**: GitHub OAuth 2.0
- **Repository Structure**: User's notes stored in a designated GitHub repo (e.g., `/notes/`)

---

## User Interface

### Main Screen
```
┌──────────────────────────────┐
│ [Document Manager] [Settings]│  (Header)
├──────────────────────────────┤
│                              │
│  [Blank note editor]         │
│  (Markdown WYSIWYG)          │
│  Cursor ready for typing     │
│                              │
├──────────────────────────────┤
│ [B] [I] [~] [•] [1.] [Code] │  (Formatting Toolbar)
│ [Link] [Image] [More] [✓]   │
└──────────────────────────────┘
```

### Document Manager Screen
```
┌──────────────────────────────┐
│ Documents          [+ New]   │  (Header)
├──────────────────────────────┤
│ [5 min ago] I went to the    │
│ [1 hour ago] Meeting notes:  │
│ [Yesterday] Grocery list:    │
│ [May 24] Project ideas for   │
│                              │
└──────────────────────────────┘
```

### Actions in Editor
- **Save**: Implicit auto-save (to local storage, queued for sync)
- **Share**: Native device share sheet
- **Workflow**: Button to append note to workflow (e.g., "To Workflow" or action menu)
- **Back/Done**: Return to Document Manager
### Visual Style
GitHub's Dark High Contrast appearance with official Primer colors and GitHub-style callouts. Enable both Dark High Contrast and Light Default modes and restyle UI components, form elements, and typography to match GitHub's visual language.

---

## Technical Architecture

### Tech Stack
- **Framework**: Flutter (Dart) — single codebase targeting Android, iPadOS, Windows, and beyond
- **Language**: Dart
- **State Management / DI**: `riverpod` + `riverpod_generator` (code-gen style, `@riverpod` annotation)
- **Markdown Editor**: `super_editor` (WYSIWYG, full-featured) — fallback: `appflowy_editor`
- **Markdown Flavor**: GFM (GitHub Flavored Markdown) — matches GitHub rendering of stored notes
- **Storage**:
  - Local: `drift` (type-safe SQLite ORM for Dart)
  - Cloud: GitHub REST API via `dio` HTTP client + `github` Dart package
- **Authentication**: GitHub OAuth 2.0 via **Device Flow** (token stored via `flutter_secure_storage`). Scopes: `repo` + `read:user`. No platform-specific URL schemes or library required — implemented directly on `dio`.
- **Key Plugins**:
  - `geolocator` — GPS capture
  - `share_plus` — native share sheet (Android, iPadOS, Windows)
  - `drift` — local SQLite with type-safe schema
  - `dio` — HTTP client for GitHub API calls
  - `flutter_secure_storage` — OS-backed secret storage for the OAuth token
  - `uuid` — note ID generation (v4)
  - `super_clipboard` — clipboard image paste (cross-platform: Android, Windows, iOS, Mac)
  - `path_provider` — locate app documents directory for local image storage
  - `url_launcher` — open GitHub device-flow verification URI in system browser
  - `logging` — structured logging (console in debug, in-memory ring buffer in release)

### State Management — Riverpod

All app state and service wiring goes through Riverpod providers. No global singletons, no manual `InheritedWidget`, no `setState` outside of trivial widget-local UI state (e.g. a text field's focus). Reasons:

- Reactive `drift` streams (`Stream<List<Note>>`) plug directly into `StreamProvider` → widgets auto-rebuild on DB changes
- Services (`GitHubClient`, `SyncService`, `WorkflowEngine`) are providers with declared dependencies — testable via `ProviderContainer` overrides
- Async UI states (`AsyncValue<T>`: loading / data / error) are first-class — no manual flag juggling for sync states

**Provider flavors and where they apply:**

| Flavor             | Used for                                                                                                                                     |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `Provider`         | Stateless services: `AppDatabase`, `GitHubClient`, `WorkflowEngine`                                                                          |
| `StreamProvider`   | `drift` queries: notes list, single note watch, workflow list                                                                                |
| `FutureProvider`   | One-shot async: initial auth check, repo validation                                                                                          |
| `NotifierProvider` | Stateful controllers with methods: `SyncController` (push/pull), `EditorController` (auto-save, formatting), `AuthController` (login/logout) |
| `StateProvider`    | Trivial mutable values: current document ID, search query                                                                                    |

**Conventions:**
- Use `@riverpod` annotation + `riverpod_generator`; do not hand-write `Provider<T>(...)` declarations
- Providers live next to the feature they belong to (`features/editor/editor_controller.dart`), not in a global `providers/` folder
- Cross-cutting providers (database, GitHub client) live in `core/` with their corresponding service
- Widgets that read providers extend `ConsumerWidget` or use `Consumer` — no `StatefulWidget` boilerplate for read-only state

### Application Flow

**First launch:**
1. Show onboarding screen — "Connect GitHub to sync notes across devices"
2. Primary CTA: "Connect GitHub" (OAuth flow)
3. Subtle secondary option below: "Work locally only" (skips GitHub entirely; sync can be enabled later in Settings)
4. If GitHub connected: repo selection (pick existing or create new; `quki-notes` suggested as default name)
5. Drop into blank note — ready to write

**Subsequent launches:**
1. Token valid → straight to blank note (or document manager, per `launch_behavior` setting)
2. Background pull triggered (if >5 min since last pull)
3. Push any `pending_push` notes

**Auth expiry handling:**
- On next sync attempt, 401 returned → silent re-auth attempt
- If re-auth fails (offline or revoked): stay in local-only mode, show `error` sync indicator
- Non-blocking — user can keep writing; sync resumes when re-authed

### GitHub OAuth — Device Flow

GitHub Device Flow is used on all platforms (Android, Windows, future iOS/Mac). Rationale: uniform UX across desktop and mobile; no custom URL scheme registration; no platform-specific OAuth library; works in any environment that can open a browser.

**Setup (one-time, by Scott as developer):**
- Register a GitHub OAuth App at `github.com/settings/developers` — note the `client_id`
- No client secret needed for Device Flow (it's a public client)
- Configure scopes in the App settings: `repo`, `read:user`

**Flow at runtime:**
1. App calls `POST https://github.com/login/device/code` with `client_id` and `scope=repo read:user`. GitHub returns `device_code`, `user_code`, `verification_uri` (`https://github.com/login/device`), `expires_in`, `interval`.
2. App displays an in-app screen: large-format `user_code`, "Open `github.com/login/device` and enter this code" button. Button uses `url_launcher` to open the verification URI in the system browser.
3. App polls `POST https://github.com/login/oauth/access_token` with the `device_code` every `interval` seconds (typically 5).
   - `authorization_pending` → keep polling
   - `slow_down` → increase poll interval per GitHub guidance
   - `access_token` returned → store via `flutter_secure_storage` and proceed to repo selection
   - `expired_token` / `access_denied` → show error, restart from step 1
4. After token is stored: `GET /user` validates and surfaces the connected username for the Settings screen.

**Re-auth:** when a sync call returns 401, run the same flow silently. If the app is foregrounded, surface the device-code screen; if backgrounded, queue and surface on next foreground.

**Scopes — keep minimal:**
- `repo` — required for read/write to private repos (notes repo may be private; workflow target repos may be private)
- `read:user` — for displaying the connected username

No other scopes. If the user later authorizes a workflow target repo that requires a broader scope (e.g. `admin:org`), the app surfaces an error explaining the limitation rather than silently escalating.

**Dependencies added:** `url_launcher` (to open the verification URI in the system browser). No dedicated OAuth library — the flow is ~50 lines on top of `dio`.

### Data Storage Model

#### Local Storage — `drift` SQLite Schema

Four tables. Settings stored separately via `shared_preferences` (not in SQLite).

**`notes` table** — core note store:
```dart
class Notes extends Table {
  TextColumn get id => text()();
  // UUID v4 (via `uuid` package) generated locally on creation — stable across devices once synced

  TextColumn get content => text()();
  // Full GFM markdown content

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get modifiedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  TextColumn get githubPath => text().nullable()();
  // Null until first push. e.g. "notes/2026-05-27-a3f9c2d1.md"
  // Generated deterministically from createdAt + id: notes/YYYY-MM-DD-{first 8 hex chars of id}.md
  // Path never changes once assigned (even if the note is edited on a different day).

  TextColumn get githubSha => text().nullable()();
  // SHA of last known remote version — used for conflict detection on push

  TextColumn get syncStatus => text().withDefault(Constant('pending_push'))();
  // Enum: synced | pending_push | conflict | error

  TextColumn get conflictRemoteContent => text().nullable()();
  // Populated during conflict resolution — holds the remote version for user comparison
  // Cleared once user resolves (keep mine / use remote)

  DateTimeColumn get deletedAt => dateTime().nullable()();
  // Soft-delete marker. When set:
  //   - Row is hidden from document list (queries filter WHERE deletedAt IS NULL)
  //   - syncStatus is forced to pending_push
  //   - Next push performs DELETE on remote (if githubPath != null), then hard-deletes the row
  //   - If never pushed (githubPath == null), the row is hard-deleted immediately
}
```

**`workflows` table** — cached workflow definitions (pulled from `/workflows/` in GitHub repo):
```dart
class Workflows extends Table {
  TextColumn get id => text()();
  // Matches the "id" field in the workflow JSON

  TextColumn get name => text()();
  // Display name shown in workflow picker UI

  TextColumn get definition => text()();
  // Full raw JSON blob — interpreted at execution time

  TextColumn get githubSha => text()();
  // Used during pull to detect changes to workflow definitions

  DateTimeColumn get syncedAt => dateTime()();
}
```

**`images` table** — binary attachments referenced from notes:
```dart
class Images extends Table {
  TextColumn get id => text()();
  // UUID v4 — used to build filename: YYYY-MM-DD-{uuid8}.{ext}

  TextColumn get noteId => text().references(Notes, #id)();
  // Owning note. Cascade-delete: deleting a note deletes its images.

  TextColumn get localPath => text().nullable()();
  // Absolute path within app documents directory (e.g. "<docs>/images/2026-05-27-b8c4f1a2.png")
  // NULL = remote-known but not yet downloaded locally (lazy fetch on first view).

  TextColumn get githubPath => text().nullable()();
  // Null until first push. e.g. "images/2026-05-27-b8c4f1a2.png"

  TextColumn get githubSha => text().nullable()();
  // SHA of last known remote version (binary file SHA from GitHub)

  TextColumn get syncStatus => text().withDefault(Constant('pending_push'))();
  // Enum: synced | pending_push | error (no conflict state — images are immutable once created)

  TextColumn get mimeType => text()();
  // e.g. "image/png", "image/jpeg"

  IntColumn get sizeBytes => integer()();

  DateTimeColumn get createdAt => dateTime()();
}
```

**`authorized_repos` table** — GitHub repos that workflows are permitted to write to:
```dart
class AuthorizedRepos extends Table {
  TextColumn get repo => text()();
  // Format: "owner/repo" e.g. "ScottKirvan/Vaults"

  DateTimeColumn get addedAt => dateTime()();
}
```

**Secrets** (via `flutter_secure_storage` — OS keystore-backed):
- `github_token` — OAuth access token (Android: Keystore-backed `EncryptedSharedPreferences`; Windows: Credential Manager / DPAPI; iOS/Mac: Keychain; Linux: libsecret)

The token is the only value stored here. All other settings are non-sensitive and live in `shared_preferences`.

**Settings** (via `shared_preferences` — simple key/value, not SQLite):
- `github_notes_repo` — the QuKi notes repo (`owner/repo`)
- `github_default_branch` — default: `main`
- `launch_behavior` — `new_note` (default) or `document_manager`
- `sync_pull_interval_minutes` — how long app must be backgrounded before pull on foreground (default: 5)

**Rationale for splitting:** an OAuth token with `repo` scope grants read/write access to all the user's authorized repos until revoked. Storing it in `shared_preferences` would leave it as plaintext on disk (Android: `/data/data/<app>/shared_prefs/*.xml`; Windows: `%APPDATA%\...\shared_preferences.json`). `flutter_secure_storage` provides a uniform API backed by each OS's hardware-rooted secret store. The cost is negligible (one extra dependency) and the threat surface reduction is meaningful for a token with broad GitHub scope.

---

#### Drift Migration Strategy

Drift schemas evolve via an integer `schemaVersion` on the database class and a `MigrationStrategy.onUpgrade` callback that handles each version step.

**Planned schema versions:**

| Version | Phase                   | Tables included                      |
| ------- | ----------------------- | ------------------------------------ |
| 1       | Phase 1 (local capture) | `notes`, `images`                    |
| 2       | Phase 3 (workflows)     | adds `workflows`, `authorized_repos` |

Phase 2 (GitHub sync) does **not** bump the schema version — all sync columns (`githubPath`, `githubSha`, `syncedAt`, `syncStatus`, `conflictRemoteContent`, `deletedAt`) ship in v1 and are simply unused in Phase 1.

**Conventions:**
- Every `schemaVersion` bump must include a matching `onUpgrade` step using `Migrator` (`m.createTable`, `m.addColumn`, etc.) — never destructive without an explicit reason.
- After any schema change: run `just gen` (which runs `dart run build_runner build --delete-conflicting-outputs`) to regenerate the `.g.dart` files.
- Schema diffs must be verified with drift's schema test tooling: `dart run drift_dev schema dump` captures a snapshot, and `dart run drift_dev schema verify` confirms the migration produces the expected new schema. Snapshots live under `test/db/schemas/`.
- A migration test must accompany every `onUpgrade` step — verify the upgrade succeeds against the previous snapshot and produces the new one without data loss.

**For the Phase 1 → v1 initial:** no `onUpgrade` needed (schema 0 → 1 is `createAll`). The first migration test is written when v2 lands in Phase 3.

---

#### GitHub Storage Structure

```
{notes_repo}/
├── notes/
│   ├── 2026-05-26-a3f9c2d1.md
│   ├── 2026-05-26-b71e04f8.md
│   └── ...
├── images/
│   ├── 2026-05-26-b8c4f1a2.png
│   ├── 2026-05-26-c1d05e9a.jpg
│   └── ...
└── workflows/
    ├── daily-log.json
    └── daily-log-geo.json
```

- **Note filename format**: `YYYY-MM-DD-{uuid8}.md` where `uuid8` is the first 8 hex chars of the note's UUID v4 (`id` column)
  - Date prefix from local `createdAt` — sortable and human-scannable on GitHub
  - UUID suffix gives 2^32 ≈ 4 billion possibilities per day — collision-free in practice without any coordination between devices
  - Filename is deterministic: same `id` + `createdAt` always produces the same path, so two devices that already share a note's UUID will push to the same file
  - Assigned at first push (kept in `githubPath`) and never changes afterward — even if the note is edited on a later date
- **Note file content**: raw GFM markdown — no frontmatter for MVP (keeps files clean and human-readable on GitHub)
- **Image files**: stored as binary files in `images/` (not embedded in markdown). Referenced from notes as `![](../images/{filename})` — renders correctly on GitHub and lets the in-app renderer resolve to the local copy.
- **Workflow files**: one JSON file per workflow definition

---

## Image Handling

Images are stored as **separate binary files**, never base64-embedded in the markdown. The markdown stays small and human-readable; GitHub renders the image inline when viewing the note in the browser.

### Capture

- **Paste** (primary): user pastes from clipboard via `super_clipboard`. App extracts the image, writes it to `<app docs>/images/`, inserts a markdown reference into the note at cursor position.
- **Future**: file picker / camera capture (deferred — paste covers the daily-use case).

### Local Storage

- Binaries live under `<app docs>/images/{filename}` — the OS-managed app documents directory (via `path_provider`), backed up by the OS the same way other app data is.
- The `images` table tracks each binary as a separate sync-able entity with its own SHA, status, and `note_id` foreign key.
- Filename format: `YYYY-MM-DD-{uuid8}.{ext}` — same date-prefix pattern as notes, derived from the image's own UUID v4. Extension preserved from the source (`png`, `jpg`, `gif`, `webp`).

### Markdown Reference

When an image is pasted, the editor inserts:

```markdown
![](../images/2026-05-27-b8c4f1a2.png)
```

The relative path resolves correctly in both contexts:
- **On GitHub**: renders inline when viewing the note file (siblings in the repo)
- **In-app**: the renderer maps `../images/{filename}` to the local file path via the `images` table lookup

### Sync

Images sync alongside notes but as independent units:

- **Push**: `PUT /repos/{owner}/{repo}/contents/images/{filename}` with the file's bytes **base64-encoded** in the request body (GitHub's Contents API requires base64 for binaries). New images push before the note that references them — otherwise GitHub would render the note with a broken image link until the next image push lands.
- **Pull**: image files in the tree response are detected by parent directory (`images/`) and downloaded as binary via `GET /repos/{owner}/{repo}/contents/images/{filename}` (returns base64 in JSON). Saved to local images dir; row inserted into `images` table.
- **Sync state**: no `conflict` state — images are treated as immutable once created (no edit-image flow in MVP). If a remote SHA differs unexpectedly, log + mark `error`; user can manually resolve.

### Deletion

- Deleting a note **cascades to its images** — both local files and remote files removed.
- Image-only deletion (removing an image reference from a note without deleting the note) is detected by markdown diff at save time: any `![](../images/{id}.{ext})` references that disappear trigger image deletion.
- Orphan-image cleanup (files in `images/` with no markdown reference anywhere) is **out of scope for MVP**.

### Phase Allocation

- **Phase 1 (local capture)**: paste-to-insert works end-to-end; binaries written to local `images/` directory; markdown reference inserted; in-editor rendering. No sync.
- **Phase 2 (sync)**: images sync alongside notes; image-before-note push ordering; pull on launch picks up remote images; cascade deletion across devices.

### Constraints

- **Max image size** (Phase 1): warn user if pasted image > 5 MB; reject if > 20 MB. Bypass would inflate the GitHub repo unboundedly.
- **Allowed MIME types** (MVP): `image/png`, `image/jpeg`, `image/gif`, `image/webp`. Other clipboard types ignored with a brief notice.

---

## Workflow Integration

### Core Principle

Workflows are **delivery actions**, not move operations. Firing a workflow sends the note to a destination; the note is always retained in QuKi' own document manager. A note can be sent via multiple workflows independently.

### Workflow Engine

In-app rules engine interpreting a JSON action DSL.

- Workflow definitions stored as JSON files in `/workflows/` in the QuKi GitHub repo
- Syncs to all devices automatically — define once, works everywhere
- App interprets and executes actions locally; no server required except for push steps
- New action types added via app updates; engine is additive by design

**Rejected alternatives**:
- GitHub Actions — 30-60s+ latency, requires internet, complex per-workflow setup
- IFTTT/Zapier — external dependency, privacy risk (notes leave device), cost

---

### Entry Formats

Workflows that write to a destination file use one of two entry formats:

**Plain entry:**
```
---
{note text}
```

**Geotagged entry:**
```
---
{street address}
{City State ZIP}
{Country}
https://maps.google.com/maps?q={lat},{lon} - {altitude_meters}

{note text}
```

GPS capture requires reverse geocoding (coordinates → human-readable address). The `geocoding` Flutter package uses platform-native geocoding — no external API key needed. If GPS is unavailable when a geotagged workflow fires, the app falls back to a plain entry.

---

### Workflow Definition Format

Stored in `/workflows/` in the QuKi GitHub repo:

**Plain daily log** (sends note to dated file in another repo, no GPS):
```json
{
  "id": "daily-log",
  "name": "Daily Log",
  "actions": [
    {
      "type": "append_to_github_file",
      "repo": "ScottKirvan/Vaults",
      "path": "sk/02_Calendar/Daily/in/{{date}}_in.md",
      "entry_format": "plain",
      "create_if_missing": true
    }
  ]
}
```

**Geotagged daily log** (captures GPS + address, appends geotagged entry):
```json
{
  "id": "daily-log-geo",
  "name": "Daily Log + Location",
  "actions": [
    {
      "type": "append_to_github_file",
      "repo": "ScottKirvan/Vaults",
      "path": "sk/02_Calendar/Daily/in/{{date}}_in.md",
      "entry_format": "geotagged",
      "gps_fallback": "plain",
      "create_if_missing": true
    }
  ]
}
```

---

### Built-in Action Types (MVP)

**`append_to_github_file`** — Core delivery action. Read-modify-write against a file in any authenticated GitHub repo.
- `repo` — target GitHub repo (`owner/repo`), can differ from the QuKi notes repo
- `path` — file path within that repo; supports `{{date}}` token (`YYYY-MM-DD`)
- `entry_format` — `"plain"` or `"geotagged"`
- `gps_fallback` — `"plain"` (default) or `"skip"` — behavior if GPS unavailable on geotagged entries
- `create_if_missing` — if `true`, creates the file on first entry of the day; if `false`, fails gracefully

**Implementation note**: `append_to_github_file` must:
1. **Always fetch** the current file content + SHA from GitHub (`GET /contents/{path}`) at execution time — or detect 404 for new file. SHAs of workflow target files are **never cached locally**; target files (e.g. a shared daily log in another repo) are typically edited externally between fires, so any cached SHA would almost always be stale. The extra GET is the cost of correctness.
2. Append the formatted entry (`---` separator + content block) to the fetched content.
3. `PUT /contents/{path}` with the freshly fetched SHA.
4. **On 409**: assume someone else just wrote to the file between our GET and PUT — retry the read-modify-write **once**, automatically. If it still fails, surface an inline error in the workflow result (toast/snackbar) — do not push silently and risk overwriting.

**`push_to_github`** — Overwrite/create a file at a path. Used when you want to replace rather than append.
- `repo`, `path` — same as above
- `entry_format` — `"plain"` or `"geotagged"`

**`prepend_template` / `append_template`** — Insert text into the note body before delivery.
- `template` — string with tokens: `{{date}}`, `{{time}}`, `{{gps}}`

**`insert_todo`** — Prepend `- [ ] ` to the note text.

---

### Template Tokens

| Token         | Resolves to                                          |
| ------------- | ---------------------------------------------------- |
| `{{date}}`    | `YYYY-MM-DD`                                         |
| `{{time}}`    | `HH:MM` (24h, local)                                 |
| `{{gps}}`     | `https://maps.google.com/maps?q={lat},{lon} - {alt}` |
| `{{address}}` | Reverse-geocoded address block (multi-line)          |

---

### GitHub Repo Authentication for Workflows

Workflows that target repos other than the QuKi notes repo require that repo to be authorized. Settings will allow the user to add additional GitHub repos (by `owner/repo`) that the app is permitted to write to. Auth reuses the same OAuth token if the user has access; no additional login required.

---

## GitHub Integration Details

### Sync Architecture: Queue-Based Optimistic Sync

The app never blocks on network. All writes go to local SQLite first; sync happens asynchronously.

#### Sync States

Each note carries a `sync_status` field:

| State          | Meaning                                            |
| -------------- | -------------------------------------------------- |
| `synced`       | Local content matches GitHub; SHA stored           |
| `pending_push` | Local change not yet pushed to GitHub              |
| `conflict`     | Push rejected (remote SHA changed since last pull) |
| `error`        | Permanent failure (auth expired, repo missing)     |

#### Save vs Push (Separate Concerns)

"Save" = write to local SQLite. "Push" = network call to GitHub. They have different triggers and frequencies. Save fires often and cheaply; push fires less often and is debounced/backgrounded.

**Save triggers** (always local-only, never blocks):
- **Idle debounce**: 2 seconds after last keystroke — primary
- **Periodic flush**: every 30 seconds during continuous typing — guards against losing a long uninterrupted writing run if the app crashes (max unsaved window ≈ 30s)
- **`AppLifecycleState.inactive` / `paused`**: best-effort flush when the app is backgrounded, screen-locked, or pulled into the multitasking switcher
- **`AppLifecycleState.detached`**: last-chance flush on app close (not guaranteed to complete on all platforms)

A save sets `syncStatus = pending_push` (if previously `synced`) and updates `modifiedAt`. Save does **not** itself trigger a network call.

#### Sync Triggers

**Push** (local → GitHub):
- Auto-save idle debounce completes (~2s after last keystroke) — single primary trigger; the periodic-flush and lifecycle saves do not trigger push to avoid spamming GitHub
- App comes to foreground
- User taps manual sync button

**Pull** (GitHub → local):
- App launches
- App comes to foreground after >5 minutes in background
- User taps manual sync button

#### Push Flow

1. For each note where `sync_status = pending_push`:
   - **If `deletedAt != null`** (local soft-deletion): `DELETE /repos/{owner}/{repo}/contents/{githubPath}` with stored SHA, then hard-delete the local row + any associated image rows (which trigger their own remote deletes — see Image Handling). 404 on delete is treated as success (already gone).
   - **Else (normal upsert)**: `PUT /repos/{owner}/{repo}/contents/notes/{file}` with stored SHA
     - **Success**: update local SHA, set `sync_status = synced`
     - **409 conflict**: set `sync_status = conflict` — surface to user (see Conflict Resolution)
     - **Network failure**: leave as `pending_push`, retry on next trigger (no exponential backoff for MVP)
     - **401 auth error**: set `sync_status = error`, prompt re-authentication

#### Pull Flow

1. `GET /repos/{owner}/{repo}/git/trees/{branch}?recursive=1` — fetch full file tree with SHAs
2. Compare each remote file SHA against local `github_sha`:
   - **SHA matches**: no action
   - **SHA differs, file exists locally**: fetch content, update local note, set `sync_status = synced`
   - **File exists remotely only**: insert as new local note, `sync_status = synced`
     - **`id`** — generate a fresh UUID v4 locally. The receiving device does not need to share the originating device's UUID; what matters for sync is that `githubPath` is captured verbatim from the observed filename so subsequent pushes go to the same file. (The "deterministic filename from `id` + `createdAt`" rule applies only at the *originating* device's first push; once `githubPath` is set, it is the source of truth and never recomputed.)
     - **`githubPath`** — the observed remote path verbatim (e.g. `notes/2026-05-27-a3f9c2d1.md`).
     - **`createdAt`** — derived from the filename date prefix (`YYYY-MM-DD` + `00:00:00` local time). Day-precision round-trips across devices; sub-day precision is lost on cross-device pull. Document list sort by `createdAt` remains stable.
     - **`modifiedAt`** = time of pull. Documented limitation: a note pulled to a new device sorts to the top of "recently modified" on first sync. Acceptable for MVP; if precision matters later, switch to YAML frontmatter to round-trip both timestamps.
   - **File exists locally only** (`pending_push`): leave alone — it hasn't been pushed yet
3. Remote deletions: out of scope for MVP. Deletions made on GitHub directly (web UI, another tool) are NOT detected on pull — the local copy persists. Only deletions originating in the app are propagated (local → remote). To fully delete a note, the user must delete it from inside the app.

#### Rate Limiting & Initial Bulk Sync

GitHub authenticated API limit: **5,000 requests/hour** per user token. Normal usage (one push every few minutes, occasional pulls) is nowhere near this. The risk is the **first sync** against an existing long-running notes repo with hundreds or thousands of files.

**Strategy:**

1. **Single tree call as the cheap manifest.** `GET /git/trees/{branch}?recursive=1` returns the full file list with SHAs in one request. Free relative to per-file calls. Always start here.
2. **Notes are pulled in full immediately**, sorted by filename date prefix descending (newest first) so the user sees recent notes appearing first. Per-file cost: 1 `GET /contents/{path}` request.
3. **Images are NOT bulk-downloaded.** When the tree response shows an `images/{filename}`, insert a row into the `images` table with `localPath = null`, `syncStatus = synced`, `githubSha = {sha}`, `mimeType` inferred from extension, and `sizeBytes = 0` placeholder (filled when fetched). The actual binary is fetched lazily the first time a note referencing the image is opened in the editor.
4. **Throttle via `X-RateLimit-Remaining` header.** Every GitHub response includes `X-RateLimit-Remaining` and `X-RateLimit-Reset`. The GitHub client wraps every request to read these and:
   - If `Remaining < 100`, pause the queue until `Reset` (the reset epoch).
   - Surface a sync indicator state: "Rate-limited; resumes at {time}".
   - Manual sync button is disabled during pause.
5. **Progress UI.** During bulk pull (initial sync or after long offline window), show a non-blocking banner: "Syncing notes — 250 of 700 done." User can keep writing in the meantime.

**Lazy image fetch behavior:**

- When the editor opens a note, the renderer walks the markdown for `![](../images/{filename})` references.
- For each referenced image where the `images` row has `localPath = null`, the renderer enqueues a fetch via `GET /contents/images/{filename}`, decodes the base64 body to bytes, writes to `<app docs>/images/{filename}`, updates the row with the actual `localPath` and `sizeBytes`.
- While fetching, the editor shows a placeholder (spinner or gray box) inline. Multiple concurrent fetches allowed within rate budget.
- Offline + null `localPath` → show a "image not yet downloaded" placeholder with a retry button.

**Why lazy fetch for images and not notes:** notes are tiny (kilobytes) and the user wants instant offline access to all their text. Images can be megabytes each — bulk-downloading on every new device install could mean hundreds of MB of bandwidth and significant rate-limit cost, mostly for images the user may never view again. Lazy-fetch defers that cost to actual use.

---

#### Conflict Resolution

When a push returns 409:
1. Fetch the remote version of the note
2. Present a bottom sheet to the user:
   - "This note was edited on another device"
   - Show both versions (scrollable preview)
   - "Keep mine" / "Use remote" — no merge
3. Chosen version becomes the new local content, pushed immediately with the current remote SHA

---

### Sync UI

Visible at all times — small sync status icon in the editor toolbar and document list header. Never a blocking modal except for conflict resolution.

| State          | Visual                                                |
| -------------- | ----------------------------------------------------- |
| `synced`       | ✓ cloud icon (neutral)                                |
| `pending_push` | ↑ cloud icon (muted — indicates queued or offline)    |
| `syncing`      | Animated spinner on cloud icon                        |
| `conflict`     | ⚠ icon — tapping opens conflict resolution sheet      |
| `error`        | ✕ icon — tapping shows error message + re-auth button |

The document list shows per-note sync state inline (small icon beside each row) so the user can see which notes are pending without opening them.

---

### API Endpoints Used

| Method   | Endpoint                                               | Purpose                         |
| -------- | ------------------------------------------------------ | ------------------------------- |
| `GET`    | `/user`                                                | Verify authentication           |
| `GET`    | `/repos/{owner}/{repo}/git/trees/{branch}?recursive=1` | Pull: get full file tree + SHAs |
| `GET`    | `/repos/{owner}/{repo}/contents/{path}`                | Fetch individual file content   |
| `PUT`    | `/repos/{owner}/{repo}/contents/{path}`                | Create or update note (push)    |
| `DELETE` | `/repos/{owner}/{repo}/contents/{path}`                | Delete note                     |

All API calls via `dio` with GitHub OAuth token in `Authorization` header.

---

## Non-functional Decisions

### Theme

- Follow system theme — `MaterialApp(themeMode: ThemeMode.system, ...)`. Light and dark themes both ship in v1.
- No manual theme override in Settings for MVP — adds UI surface area for marginal value.

### Logging

- Use the standard `logging` package (`package:logging`) — Dart's lightweight, idiomatic logger.
- **Debug builds**: log to console at `Level.ALL`.
- **Release builds**: log to an in-memory ring buffer (last ~500 entries) at `Level.INFO` and above. No logs written to disk in MVP.
- Per-feature loggers: `Logger('sync')`, `Logger('workflow')`, `Logger('github')`, `Logger('editor')`. Hierarchical naming so log levels can be tuned per subsystem.
- Sensitive data **never** logged: never log the OAuth token, full note contents, or workflow target file contents. Log only metadata (note IDs, SHAs, request paths, status codes).
- A hidden debug screen (long-press the version string in Settings) exposes the ring buffer for support purposes. Not in user-facing docs.

### Privacy & Telemetry (MVP)

- **No analytics. No crash reporting. No telemetry of any kind.** This is a personal-data app; the user's text never leaves their device except as explicit GitHub API calls they initiated.
- No Firebase, no Sentry, no Crashlytics, no Google Analytics, no anonymous usage stats.
- Network access is limited to `github.com` / `api.github.com`. The app does not ping any other host.
- This is a deliberate MVP posture; revisit if/when distribution broadens beyond personal use.

### Accessibility

- Honour platform text-scaling (do not hard-code font sizes).
- All formatting toolbar buttons must have semantic labels (screen reader support).
- Detailed accessibility audit deferred until after Phase 4.

---

## Settings

### In-App Settings Screen

| Setting           | Default      | Notes                                                       |
| ----------------- | ------------ | ----------------------------------------------------------- |
| GitHub account    | —            | Shows connected account; tap to re-auth or disconnect       |
| Notes repository  | `quki-notes` | Picker from user's GitHub repos                             |
| Default branch    | `main`       | Text field                                                  |
| Launch behavior   | New note     | Toggle: New note / Document manager                         |
| Pull interval     | 5 min        | How long app must be backgrounded before pull on foreground |
| Authorized repos  | —            | List of repos workflows can write to; add/remove            |
| Work locally only | off          | Disables all GitHub sync; notes saved to device only        |

Authorized repos list shows each `owner/repo` with a remove button. Adding a repo validates it exists and the OAuth token has write access before saving.

---

## Error Handling

### Principles
- Never block the user from writing — errors surface as indicators, not modals
- All errors are recoverable — the app retries automatically or waits for user action
- Local notes are never lost due to a sync error

### Error Scenarios

| Scenario                                  | Behavior                                                                                         | User-Facing                              |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------ | ---------------------------------------- |
| No network on push                        | Note stays `pending_push`, retries on next trigger                                               | ↑ sync icon                              |
| No network on pull                        | Skip pull, retry on next foreground                                                              | ↑ sync icon                              |
| 401 auth expired                          | Attempt silent re-auth; if fails, enter local-only mode                                          | ✕ icon → tap to re-auth                  |
| 409 push conflict                         | Mark note `conflict`, surface conflict resolution sheet                                          | ⚠ icon → tap to resolve                  |
| 404 on pull (file deleted remotely)       | Out of scope for MVP                                                                             | —                                        |
| Repo not found / no write access          | Mark `error`, show actionable message in Settings                                                | ✕ icon                                   |
| Workflow push fails (409 on append)       | Retry read-modify-write once automatically; if still fails, show inline error in workflow result | Toast/snackbar                           |
| GPS unavailable during geotagged workflow | Fall back to plain entry format                                                                  | Silent fallback                          |
| Reverse geocoding fails                   | Use raw coordinates only (no address block)                                                      | Silent fallback                          |
| Local DB corruption                       | Show error screen with option to reset local data (remote notes preserved on GitHub)             | Destructive action requires confirmation |

---

## Development Pipeline

### Phase 1: MVP — Local Capture (Android)
Goal: app works fully offline. No GitHub, no sync. Proves the core capture loop.

- [ ] Flutter project setup (Android target)
- [ ] `drift` schema: `notes` + `images` tables
- [ ] Blank note on launch (auto-save debounced ~2s)
- [ ] `super_editor` WYSIWYG markdown integration
- [ ] GFM formatting toolbar (bold, italic, strikethrough, lists, code, links)
- [ ] Document Manager: flat list sorted by `modified_at`, truncated first line as title
- [ ] CRUD: create, view, edit, delete (note delete cascades to its images locally)
- [ ] Image paste support via `super_clipboard` (write to local `<app docs>/images/`, insert markdown ref)
- [ ] In-editor image rendering (resolve `../images/{file}` to local path)
- [ ] Image size validation (warn >5 MB, reject >20 MB; restrict to png/jpeg/gif/webp)
- [ ] "Work locally only" mode fully functional

### Phase 2: GitHub Sync
Goal: notes persist to GitHub and sync across devices.

- [ ] GitHub OAuth 2.0 authentication flow
- [ ] Onboarding screen (connect GitHub / work locally only)
- [ ] Repo selection / creation (`quki-notes` default)
- [ ] `shared_preferences` settings store
- [ ] Settings screen (account, repo, branch, launch behavior, pull interval)
- [ ] Push flow: `PUT` note to GitHub with SHA, handle 409
- [ ] Pull flow: tree diff against local SHAs, fetch changed files
- [ ] Image sync: push images before referencing note; binary base64 PUT; pull binary via GET
- [ ] Image cascade deletion across devices (note delete → image deletes)
- [ ] Sync status indicators (editor toolbar + document list per-note icons)
- [ ] Conflict resolution bottom sheet (keep mine / use remote)
- [ ] Auth expiry handling (silent re-auth → local-only fallback)
- [ ] Manual sync button

### Phase 3: Workflow Engine
Goal: daily log and geotagged entry workflows fully functional.

- [ ] `workflows` table + pull from `/workflows/` in GitHub repo
- [ ] Workflow picker UI (action sheet on "Send to Workflow" button)
- [ ] `append_to_github_file` action: read-modify-write, create-if-missing
- [ ] `authorized_repos` table + settings UI for managing authorized repos
- [ ] Plain entry format
- [ ] Geotagged entry format: `geolocator` GPS + `geocoding` reverse geocode
- [ ] GPS unavailable fallback (plain entry)
- [ ] Reverse geocoding failure fallback (raw coordinates only)
- [ ] Workflow 409 retry (auto read-modify-write retry once)
- [ ] `push_to_github`, `prepend_template`, `append_template`, `insert_todo` action types
- [ ] Template token resolution (`{{date}}`, `{{time}}`, `{{gps}}`, `{{address}}`)

### Phase 4: Sharing & Polish (Android)
Goal: full Android feature set, polished UX.

- [ ] Native Android share sheet (`share_plus`) — receive shared content into new note
- [ ] Share *from* QuKi to other apps
- [ ] UI polish: transitions, empty states, loading skeletons
- [ ] Error handling UX for all error scenarios
- [ ] Phase 4 test audit: review coverage of Phase 1–3 features per `notes/dev/testing.md` → "What must have a test"; backfill anything missing. (Per ADR-13, tests ship with each feature PR — this is a final sweep, not a retrofit.)

### Phase 5: Windows Port
Goal: desktop form factor support.

- [ ] Flutter Windows build target (already in codebase — just needs testing + polish)
- [ ] Windows-appropriate keyboard shortcuts
- [ ] Windows share integration (`share_plus`)
- [ ] Desktop layout polish (window sizing, scroll behavior)
- [ ] Wire up `build-windows.yml` GitHub Actions job

### Phase 6: iPadOS / iOS / Mac (Deferred)
Goal: activate Apple platform builds when ready.

- [ ] Add self-hosted Mac runner or upgrade GitHub plan
- [ ] Activate `build-ios.yml`
- [ ] iPad layout adaptations (wider editor, split-view consideration)
- [ ] iPadOS/iOS share sheet integration
- [ ] TestFlight / sideload distribution
- [ ] Mac desktop layout polish

> Note: Flutter codebase already targets these platforms throughout development. This phase is purely about building, testing, and distributing — no code rewrites needed.

---

## Resolved Decisions

1. **Framework**: Flutter (Dart) — maximum code reuse, single codebase for all target platforms.

2. **Platform Priority**: Android first (active), then Windows (active after Android), then iPadOS/iOS/Mac (Flutter codebase supports all; builds deferred until macOS runner is available — self-hosted or paid plan).

3. **Conflict Resolution**: GitHub SHA-based detection.
   - On push, GitHub returns 409 if the remote SHA has changed since last pull
   - App detects this, fetches the remote version, presents both to user: "Your version / Remote version — keep which?"
   - No merge logic needed — user makes the call
   - Rationale: eliminates silent data loss with minimal implementation complexity; GitHub API provides this for free

4. **Offline Mode**: Yes — app functions fully offline. Notes save to local `drift` SQLite store. Sync is queued and runs when connectivity is available.

5. **File Naming**: `YYYY-MM-DD-{uuid8}.md` — date prefix from local `createdAt`, suffix is the first 8 hex chars of the note's UUID v4.
   - Human-readable and sortable on GitHub
   - Deterministic from local data — no GitHub round-trip needed to assign a filename
   - Collision-free without any coordination between offline devices (2^32 space per day)
   - Stored in `/notes/` directory in the GitHub repo
   - Rejected alternatives: `YYYY-MM-DD-NNN.md` with per-day index (collisions across offline devices, requires GET-before-write to assign NNN); `YYYY-MM-DDTHHMMSS.md` (clock-skew collisions still possible)

6. **Markdown Flavor**: GFM (GitHub Flavored Markdown) — consistent with how notes render on GitHub.

7. **Workflow Engine**: In-app rules engine. Workflows stored as JSON in `/workflows/` in the GitHub repo — defined once, synced to all devices automatically. See Workflow Integration section.

8. **Image Storage**: separate binary files in `images/`, referenced from markdown as `![](../images/{filename})`. Filename `YYYY-MM-DD-{uuid8}.{ext}` from the image's own UUID v4. Local copies in `<app docs>/images/`. Tracked in a dedicated `images` table with its own sync state.
   - Rejected alternatives: base64-embed in markdown (file size bloat, editor performance, unreadable on GitHub); hybrid threshold-based (added complexity not worth MVP).
   - Rationale: GFM renders external image references inline on GitHub; markdown stays small and diffable; binaries don't need to live in the editor's text buffer.

---

## Project Structure

### Repository Layout

```
QuKi-Notes/                   ← repo root
├── lib/                        ← all Dart source (shared across platforms)
│   ├── main.dart
│   ├── app.dart                ← app widget, routing, theme
│   ├── core/                   ← cross-cutting infrastructure
│   │   ├── database/           ← drift schema, DAOs, migrations
│   │   ├── github/             ← GitHub API client (dio wrapper)
│   │   ├── sync/               ← sync service, queue, state management
│   │   └── settings/           ← shared_preferences wrapper
│   ├── features/               ← one folder per screen/feature
│   │   ├── editor/             ← note editor, auto-save, formatting toolbar
│   │   ├── documents/          ← document manager list + CRUD
│   │   ├── workflows/          ← workflow engine, picker UI, action types
│   │   ├── onboarding/         ← first-run GitHub auth + repo selection
│   │   └── settings/           ← settings screen
│   └── shared/                 ← reusable widgets + data models
│       ├── models/             ← Note, Workflow, AuthorizedRepo, SyncStatus
│       └── widgets/            ← sync indicator, entry format renderers, etc.
├── android/                    ← Android platform project (Flutter-managed)
├── ios/                        ← iOS/iPadOS platform project (Flutter-managed)
├── windows/                    ← Windows platform project (Flutter-managed)
├── test/                       ← unit + widget tests
│   ├── core/
│   └── features/
├── integration_test/           ← device integration tests
├── docs/                       ← VitePress documentation source
│   ├── .vitepress/
│   │   └── config.ts
│   ├── index.md
│   ├── user-guide/
│   │   ├── getting-started.md
│   │   ├── workflows.md
│   │   └── sync.md
│   └── dev/
│       ├── architecture.md
│       └── contributing.md
├── .github/
│   ├── workflows/              ← GitHub Actions CI/CD
│   │   ├── ci.yml              ← lint, analyze, test (on every PR)
│   │   ├── build-android.yml   ← triggered on release tag
│   │   ├── build-windows.yml   ← triggered on release tag
│   │   ├── build-ios.yml       ← stub only — deferred, not triggered (macOS runner cost)
│   │   └── docs.yml            ← deploy VitePress to GitHub Pages
│   └── release-please.yml      ← release-please config
├── justfile                    ← common dev tasks (cross-platform)
├── pubspec.yaml
├── pubspec.lock
├── CHANGELOG.md                ← auto-generated by release-please
└── README.md
```

---

## Development Workflow

### Versioning & Commits

- **Semantic versioning**: `MAJOR.MINOR.PATCH` managed by release-please in `pubspec.yaml`
- **Conventional commits** (enforced via PR title):

| Prefix                                  | Effect                                |
| --------------------------------------- | ------------------------------------- |
| `feat:`                                 | Minor version bump                    |
| `fix:`                                  | Patch bump                            |
| `feat!:` / `BREAKING CHANGE:`           | Major bump                            |
| `chore:`, `docs:`, `refactor:`, `test:` | No version bump; appears in CHANGELOG |

- **Merge strategy**: squash merge — PR title becomes the single conventional commit message that release-please reads
- **Branch naming**: `feat/phase1-drift-schema`, `fix/sync-conflict-409`, `docs/workflow-guide`

---

### Release Please Integration

release-please monitors merged conventional commits on `main`, then:
1. Opens a "Release PR" with bumped version in `pubspec.yaml` + updated `CHANGELOG.md`
2. Accumulates new commits into the open release PR until you decide to ship
3. When release PR is merged → creates GitHub Release + tag (e.g. `v1.2.0`)
4. Release tag triggers platform build workflows (see below)

**`.github/release-please.yml`**:
```yaml
release-type: dart
package-name: quki_notes
bump-minor-pre-major: true
```

The `dart` release type knows to update the `version:` field in `pubspec.yaml`.

---

### GitHub Actions Pipelines

**CI (`ci.yml`)** — runs on every PR:
```
flutter analyze
flutter test
```

**Build workflows** — triggered on `push` to tags matching `v*`:

| Workflow            | Runner           | Minute cost | Output                                            |
| ------------------- | ---------------- | ----------- | ------------------------------------------------- |
| `build-android.yml` | `ubuntu-latest`  | 1x          | Signed APK + AAB → GitHub Release assets          |
| `build-windows.yml` | `windows-latest` | 2x          | Windows executable / MSIX → GitHub Release assets |
| `build-ios.yml`     | `macos-latest`   | 10x         | **Deferred** — not wired up initially             |

GitHub Free provides 2,000 Actions minutes/month (private repo). Android + Windows builds on release tags only will stay well within budget. macOS runner costs 10x — `build-ios.yml` will be added to the repo as a stub but not triggered until moving to a paid plan or using a self-hosted Mac runner.

Android signing keystore stored as GitHub Actions secret.

**Docs (`docs.yml`)** — runs on push to `main`:
```
npm run docs:build   ← VitePress build
→ deploy to GitHub Pages
```

---

### Local Development Tasks (`justfile`)

`just` is preferred over `make` for cross-platform compatibility (works natively on Windows without WSL).

```just
# Run app on connected Android device
android:
    flutter run -d android

# Run app on Windows
windows:
    flutter run -d windows

# Run all tests
test:
    flutter test

# Lint + analyze
lint:
    flutter analyze
    dart format --output=none --set-exit-if-changed lib/

# Build Android APK (debug)
build-android-debug:
    flutter build apk --debug

# Build Android APK (release)
build-android-release:
    flutter build apk --release

# Build Windows (release)
build-windows:
    flutter build windows --release

# Serve docs locally
docs:
    cd docs && npm run dev

# Generate drift database code
gen:
    dart run build_runner build --delete-conflicting-outputs
```

---

### Progressive PR Workflow (Claude + Scott)

Development proceeds phase by phase. Within each phase, Claude opens focused PRs — one per logical unit of work — using conventional commit PR titles. Scott tests on device and merges when satisfied.

**Rhythm per feature:**
1. Claude opens PR with focused change + description of what to test and how
2. CI runs automatically (lint, analyze, test)
3. Scott pulls branch, runs on Android device, verifies behavior
4. Scott merges (squash) → conventional commit lands on `main`
5. release-please accumulates the commit into the open release PR

**Releasing a version:**
1. When a phase is complete (or a stable subset), Scott merges the release-please PR
2. GitHub Release created automatically with tag
3. Build workflows fire → APK, Windows build uploaded as release assets
4. Scott downloads and tests the release build

**PR size guideline**: keep PRs small enough to test in one sitting — a single screen, a single service, a single action type. Avoid bundling unrelated concerns.

---

## Documentation (VitePress)

Deployed to GitHub Pages from `docs/`. Covers:

- **User guide**: getting started, writing notes, using workflows, sync behavior, settings
- **Workflow reference**: action types, template tokens, JSON format, example workflows
- **Dev guide**: architecture overview, contributing, local setup

The `design_spec.md` in this repo remains the living planning document; VitePress docs are the user/contributor-facing published output.

