# Repository Guidelines

## Project Structure & Module Organization
- `config.toml`: Zola settings (default lang ja, Sass compile on).
- `content/`: Posts at `content/blog/<slug>/index.md`; assets stay beside them. `_index.md` controls the list.
- `templates/` Tera layouts; `sass/` styles; `static/` served as-is; `public/` build output—never edit. `licenses/` holds third-party notices.

## Authoring Workflow
- Create `content/blog/<slug>/` (lowercase snake_case) with `index.md`; TOML front matter, date `YYYY-MM-DD` (JST).
- Assets stay alongside; use relative links and compressed images.
- Use `draft = true` until ready to publish.

## Build, Test, and Development Commands
- Install the Zola CLI and put it on `PATH`.
- `zola serve`: dev server with live reload (http://127.0.0.1:1111).
- `zola check`: validate content, templates, and links; run before pushing.
- `zola build`: generate the static site into `public/`.

## Coding Style & Naming Conventions
- Front matter: include `title` and `date`; add `description` or `draft` when needed.
- Keep post filename `index.md`; use clear asset names (e.g., `top_screenshot.png`).
- Tera uses 2-space indent; CSS kebab-case. Sass keeps 4-space nesting.
- Set language on code fences for highlighting (e.g., ```c).
- Keep this guide in English; do not translate AGENTS.md.

## Testing Guidelines
- No shared test runner is maintained. Keep code samples lightweight and self-contained inside each post.

## Commit & Pull Request Guidelines
- Use Conventional Commits (e.g., `docs: add repository guidelines`, `feat: add new post`); keep summaries ≈72 chars.
- PR description: state why the change is needed; omit what/tests. Link issues; add screenshots if the UI changes.
- Default to Draft PRs; mark Ready for Review after checks pass.
- Merge gate: `zola check` passes; run `zola build` when deploying.
- When you change workflows, commands, or style rules, update `AGENTS.md` in the same PR so contributors stay in sync.
- Keep PRs single-commit; squash locally. Final commit message matches the PR title (Conventional).

## Security & Configuration Tips
- Do not edit `public/`; always regenerate with `zola build`.
- Never commit secrets. Only public-safe values belong in `config.toml`.
- Keep all files under `licenses/` untouched.
- CI is absent; treat local build and test results as mandatory checks.
