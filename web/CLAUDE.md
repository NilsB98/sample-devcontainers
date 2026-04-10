# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository status

This is a **devcontainer scaffold**, not a running application. No `frontend/`, `backend/`, `helm/`, `docker/`, or `db/migration/` directories exist yet. Build and test commands referenced in `docs/sample-architecture.md` are aspirational until application code lands. Update this section when it does.

## Intended stack

Vue 3 + Spring Boot 4.x (JDK 25) + PostgreSQL 16 + Flyway, deployed as a Helm 3 chart on Kubernetes.

**`docs/sample-architecture.md` is the authoritative source** for layering conventions, migration discipline, deployment shape, and cross-cutting concerns. Read it before proposing any non-trivial change to application code.

> Version note: the devcontainer installs **JDK 25** (`.devcontainer/devcontainer.json` lines 17–22). The `pre-commit-reviewer` agent's "Stack facts" section still references Java 21 — if they conflict, defer to `devcontainer.json` and `sample-architecture.md`.

## Devcontainer conventions

The container is defined entirely in `.devcontainer/devcontainer.json`. Key rules that must be preserved when editing it:

- **Features only, no Dockerfile.** Every tool comes from a `ghcr.io/devcontainers/features/*` feature.
- **OCI digest pins on every feature.** References use `@sha256:…` digests, not just tags. When upgrading a feature, replace the digest — never drop the pin. The comment block above the `features` map documents where to look up new digests.
- **Persistent named volumes** back `~/.zsh_history_dir` and `~/.claude` so a `Rebuild Container` doesn't lose shell history or Claude auth. The `postCreateCommand`/`postStartCommand` chain re-symlinks `~/.claude.json` after rebuilds — edit it carefully.
- **Claude Code is installed via the official native installer** (`curl … claude.ai/install.sh`). Do not replace this with `npm i -g @anthropic-ai/claude-code`.

## Pre-commit review workflow

Two complementary tools live under `.claude/` — they are not interchangeable:

| When | Tool | What it does |
|------|------|--------------|
| One-liner, docs-only, formatting, staged-file hygiene | `/pre-commit-review` skill | Fast mechanical checklist in the main conversation (layering, Flyway naming, Helm sanity, docs sync) |
| Non-trivial multi-layer feature (form + endpoint + migration) | `pre-commit-reviewer` agent | Independent cold-eyes judgment review — design fitness, earned abstractions, transaction boundaries, edge cases |

Don't run both for the same change. The agent will redirect you to the skill if you send it mechanical work.

## Commit conventions

Use **Conventional Commits** for all commit messages:

```
<type>(<optional scope>): <description>

[optional body]
```

Common types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `ci`.

Do **not** add a `Co-authored-by: Claude Code` trailer to commits.
