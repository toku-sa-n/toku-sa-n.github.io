---
name: refine-article
description: Refine readability of existing Zola blog articles in this repository by locating `content/blog/slug/index.md` from user keywords (title/slug), asking clarifying questions one by one, and rewriting Markdown while preserving meaning, tone, language, code, and links. Use when a user asks to improve/refine/rewrite an existing article (e.g., “improve the pan article”) rather than creating a new post.
---

# Refine Article

## Overview

Refine an existing Markdown post for readability while keeping its original meaning, tone, and language. Update the original `content/blog/<slug>/index.md` in place and provide a short summary of changes.

## Workflow

### 1) Ask questions one by one

Ask exactly one question per turn until all are answered. Keep questions short and sequential.

Required questions:
1. Ask for the article identifier keyword the user is referring to (e.g., "pan").
2. Ask whether to match by title, slug, or both (default to both if the user says "whatever").
3. Ask what to do if multiple matches are found (default to ask the user to choose).
4. Ask the target audience (default: general audience).
5. Ask the readability goals (e.g., clarity, structure, shorter sentences).
6. Ask how to handle length (default: adjust as needed for readability).
7. Ask if restructuring headings is allowed (default: allowed).
8. Ask how to treat code blocks/commands/terminology (default: do not alter code; add explanations around if needed).
9. Ask whether front matter can be adjusted (default: allow edits that improve clarity; keep date unless requested).
10. Ask whether to reorder links/images/lists for readability (default: allowed).
11. Confirm that the original file will be updated in place and a summary will be provided.

### 2) Locate the article

Search the repository for `content/blog/**/index.md`. Match the user keyword against:
- Folder slug (directory name)
- `title` in TOML front matter
- Optional: `description` if present

If multiple matches exist, present a short list (slug + title) and ask the user to choose. If none, ask for a different keyword.

### 3) Refine for readability

Apply edits to improve readability while preserving meaning and original tone/language:
- Prefer shorter sentences and clearer transitions.
- Use headings and lists where helpful.
- Fix typos, tense/voice inconsistencies, and repeated words.
- Keep code blocks, commands, and identifiers intact; do not change their content.
- Keep relative links and asset paths valid.
- Keep Markdown structure valid and include language tags on code fences.
- Keep `draft` status as-is.
- Do not edit `public/` or anything under `licenses/`.

### 4) Update in place and summarize

Overwrite the original `index.md` and provide a brief summary (3–5 bullets) of the improvements made.
