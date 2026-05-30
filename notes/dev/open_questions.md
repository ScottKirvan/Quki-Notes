# Open Questions

Genuinely unresolved items. When implementation forces an answer, **move the entry to `decisions.md`** with the resolution and link the PR that settled it.

Do not implement past one of these without proposing a resolution in the PR body.

---

## OQ-1: super_editor ↔ GFM markdown round-trip fidelity

`super_editor` ships with markdown serializers, but full GFM coverage (task lists, tables, strikethrough, fenced code with language) is not guaranteed to round-trip cleanly through edit → save → reload.

**Surface during:** Phase 1, formatting toolbar implementation.

**Resolution options:**
- (a) Extend `super_editor` with missing serializers
- (b) Restrict the toolbar to features that survive round-trip
- (c) Fall back to `appflowy_editor`

**Test plan when reached:** write a small fixture for each GFM feature, serialize → deserialize → compare AST.

---

## OQ-2: super_editor image node integration

The Image Handling section assumes the editor renders `![](../images/{file})` references by resolving each one to a local file path via the `images` table. The exact integration point in `super_editor` (custom image node? markdown post-processor? widget builder?) is to be confirmed during Phase 1 implementation.

**Constraints:**
- Must support lazy fetch (placeholder while `localPath` is null) — relevant once a sync plugin can populate image rows ahead of file download
- Must support insertion via paste handler
- Must serialize back to the canonical `![](../images/...)` markdown form on save

**Surface during:** Phase 1, image paste task.

---

## OQ-3: GitHub OAuth App `client_id` distribution (deferred)

Defers to whichever plugin first needs GitHub OAuth (likely the GitHub sync plugin in Phase 4, or a GitHub-flavoured transport before that).

When that PR lands, decide:

- (a) Committed as a constant in the plugin
- (b) Injected via `--dart-define=QUKI_GH_CLIENT_ID=...` at build time
- (c) Read from `assets/config.json` at runtime

`client_id` is not secret per the OAuth spec; (a) is acceptable unless the repo goes public AND a different OAuth App is needed per fork.

**Surface during:** First PR that introduces an OAuth-needing plugin.

---

## OQ-4: Initial-sync progress UX threshold (deferred to sync work)

Bulk-pull progress banner: always, or only above some threshold? Decision belongs with the first sync plugin in Phase 4.

**Likely resolution:** time-based — show banner if sync hasn't completed within 1–2 seconds.

---

## OQ-NEW-1: Which built-in QuKi-Toss ships first?

MVP requires at least one built-in transport (ADR-14, manifesto). Candidates:

- (a) **Clipboard** — copy markdown to system clipboard. Zero deps, zero auth, proves the plugin loader + UI.
- (b) **Share sheet** — hand markdown to `share_plus` → native share. One dep, no auth.
- (c) **Append-to-GitHub-file** — the closest analogue to the original "daily log" use case. Needs OAuth (Phase 4 territory) — would push transports back unless an unauthenticated short-circuit (e.g. PAT pasted in settings) is acceptable for the first cut.

**Likely resolution:** ship (a) first as the architecture-proving transport, then (b) shortly after. Defer (c) until OAuth helper exists.

**Surface during:** Phase 2 kickoff.

---

## OQ-NEW-2: Plugin discovery model — built-in only vs pubspec-declared optional

In v1 plugins are built-in (registered at compile time in `lib/core/transports/registry.dart`). Should we support:

- (a) **Built-in only** — every transport ships in the same APK. Simplest. New transports require a new app version.
- (b) **Pubspec-declared optional packages** — `pubspec.yaml` lists optional dev deps; user opts in by reinstalling a flavour build. Half-measure.
- (c) **Runtime plugin loading** — Dart isn't built for this without effort (no shared libs, no isolate-based plugin model in stable Flutter). Probably not v1.

**Likely resolution:** (a) for MVP and probably v1.x. Re-evaluate if third parties start writing transports.

**Surface during:** Phase 2.

---

## OQ-NEW-3: Linux distribution format

Tarball, AppImage, Flatpak, or Snap for Linux release artifacts?

- **Tarball** — simplest, no signing, user runs `./quki_notes` from extracted dir. Good for testing.
- **AppImage** — single-file, broad distro support, no install required.
- **Flatpak** — sandboxed, Flathub distribution path, more ceremony.
- **Snap** — Ubuntu-first, snapd dep, controversial.

**Likely resolution:** ship a tarball in the first Linux build artifact; promote to AppImage if Linux usage justifies it. Flatpak/Snap only if a user explicitly asks.

**Surface during:** Phase 3 — Linux CI wiring.

---

## OQ-NEW-4: Linux `flutter_secure_storage` keyring matrix

`flutter_secure_storage` on Linux uses `libsecret`, which requires a Secret Service implementation (GNOME Keyring, KeePassXC's secret-service, KWallet bridge). On a vanilla server install or a headless WM there may be no Secret Service running.

**Risk:** plugins that store tokens (any OAuth-using transport, any sync backend) fail to initialise on Linux when no keyring is available.

**Options:**
- (a) Hard fail with clear error directing user to install + start gnome-keyring (or equivalent).
- (b) Fall back to an encrypted-at-rest file in the app docs dir (security ≈ zero against local-user attacker but workable for a personal app).
- (c) Refuse to install plugins that need secrets when keyring is absent.

**Surface during:** First plugin that calls `flutter_secure_storage` on Linux.

---

## Resolved / Removed

- **OQ-5: Workflow JSON schema validation** — **Removed.** Workflow JSON DSL dropped entirely per ADR-14. Transports are Dart code; no JSON schema to validate.

---

**Last Updated**: 2026-05-28
