# Project instructions — .emacs.d

Mirrors the global preferences in `~/.codex/AGENTS.md`.

## Storing answers / outputs

- Default output store: `~/X-output`.
- When I ask you to **save / store / keep** an answer, or to produce a
  report, summary, or write-up as a document, save it there by default as a
  dated Markdown file named `YYYY-MM-DD-<short-topic>.md`
  (e.g. `2026-07-21-emacs-config-notes.md`), matching the existing outputs
  already in that directory.
- `~/X-output` is already a writable root (see `writable_roots` under
  `[sandbox_workspace_write]` in `~/.codex/config.toml`).
- If I don't explicitly ask to save, just answer in the chat as usual — only
  persist to `~/X-output` when saving is requested (or clearly implied).
