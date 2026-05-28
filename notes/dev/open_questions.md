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
- (c) Fall back to `appflowy_editor` (already named as the secondary option in the design spec)

**Test plan when reached:** write a small fixture for each GFM feature, serialize → deserialize → compare AST.

---

## OQ-2: super_editor image node integration

The Image Handling section assumes the editor renders `![](../images/{file})` references by resolving each one to a local file path via the `images` table. The exact integration point in `super_editor` (custom image node? markdown post-processor? widget builder?) is to be confirmed during Phase 1 implementation.

**Constraints:**
- Must support lazy fetch (placeholder while `localPath` is null)
- Must support insertion via paste handler
- Must serialize back to the canonical `![](../images/...)` markdown form on save

**Surface during:** Phase 1, image paste task.

---

## OQ-3: GitHub OAuth App `client_id` distribution

Scott registers a GitHub OAuth App and captures the `client_id`. Where does it live in source?

- (a) Committed as a constant — simple, but ties the open-source repo to one specific OAuth App if the repo ever goes public
- (b) Injected via `--dart-define=QUKI_CLIENT_ID=...` at build time — cleaner, requires CI secret + local `.env`
- (c) Read from `assets/config.json` at runtime — extra plumbing, no real benefit over (b)

`client_id` is not secret per the OAuth spec (it's exposed during the auth flow regardless), so (a) is acceptable. Decide based on whether the repo will ever go public.

**Surface during:** Phase 2, OAuth implementation.

---

## OQ-4: Initial-sync progress UX threshold

The Rate Limiting section specifies a "Syncing N of M" banner during bulk pull. Should it appear:

- Always (even for M = 2)?
- Only when M > some threshold (e.g. 20)?
- Only when sync exceeds a wall-clock duration (e.g. 3 seconds)?

**Surface during:** Phase 2, initial-sync implementation.

**Likely resolution:** time-based — show banner if sync hasn't completed within 1–2 seconds. UI-side decision, low risk.

---

## OQ-5: Workflow JSON schema validation

Workflow definitions are pulled from `/workflows/*.json` and cached in the `workflows` table. Today the spec describes the format prose-only — there is no JSON Schema and no runtime validation.

**Risk:** a malformed workflow JSON (committed by hand) silently fails at execution time with a cryptic error.

**Options:**
- Write a JSON Schema and validate at pull time; reject the workflow with a clear error in Settings → Workflows.
- Validate via Dart class deserialization (`fromJson`); if deserialization throws, mark the workflow `error` with the exception message.

**Surface during:** Phase 3, workflow engine implementation.

**Likely resolution:** option (b) — leverages existing typed deserialization without adding a JSON Schema dependency.
