---
name: pre-commit-review
description: Mechanical pre-commit checklist for projects on the Vue 3 + Spring Boot + PostgreSQL + Flyway stack — staged-file hygiene, Vue/Pinia conventions, Spring Boot layering, JPA/Flyway discipline, Helm/Kubernetes sanity, docs sync. Run before /commit or when the user says "review before committing". This is a fast checklist pass in the main conversation, not a judgment review — for design fitness, architectural smells, or "is this abstraction earned", launch the pre-commit-reviewer agent instead.
---

# Pre-Commit Review (checklist pass)

Mechanical review of the current changeset for a project on the **Vue 3 + Spring Boot + PostgreSQL + Flyway** stack. Runs in the main conversation so findings and fixes share one warm context. This is NOT a judgment review — if the user wants fresh-eyes architectural feedback, stop and recommend the `pre-commit-reviewer` agent.

The authoritative description of the expected stack and layering lives in `docs/sample-architecture.md` (or equivalent architecture doc in the project). Treat that document as the source of truth for conventions; if the project deviates from it in a documented way (CLAUDE.md, README, ADRs), defer to the project's own conventions.

## Steps

1. Run `git status` and `git diff HEAD` in parallel. If the changeset is empty, report "nothing to review" and stop.
2. Categorize changed files: `frontend/`, `backend/` (Java sources, resources, migrations), `docker/`, `helm/`, `.devcontainer/`, `docs/` + `README.md`, config/other.
3. Walk the checklist below. Skip any section whose files aren't touched.
4. Emit the report in the exact format at the bottom.
5. If verdict is ❌, offer to apply fixes directly — you have warm context, don't re-launch a sub-agent.

## Checklist

### Always
- No secrets, API keys, tokens, `.env`, `application-*.yml` with real credentials, or keystore files in the diff.
- No `console.log`, `debugger`, `System.out.println`, `e.printStackTrace()`, or leftover debug statements.
- No commented-out code blocks.
- No unrelated drive-by changes (formatting sweep inside a bugfix, unrelated refactors).
- File list is coherent with the stated intent.

### Frontend — Vue 3 + Vite + Pinia + Vue Router + API client
- Composition API used correctly; reactivity not lost via destructuring of reactive objects.
- `v-for` has `:key`; no `v-if` + `v-for` on the same element.
- Listeners, timers, and subscriptions cleaned up in `onUnmounted`.
- **Layering respected**: Views → Components → Pinia stores → API client. Components don't call `axios`/`fetch` directly — they go through a store action, which goes through the central API client module.
- Pinia stores are well-scoped (one store per domain concept); no duplicate state held in components.
- `vue-router` routes registered centrally; route-level code-splitting (`() => import(...)`) used for non-critical views.
- API client module centralizes base URL, auth headers, and error normalization — new endpoints added there, not inline.
- Tests: new/changed code paths covered by Vitest + Vue Test Utils where reasonable.

### Backend — Spring Boot 3.x (Java 21)
- **Layering respected**: `Controller → Service → Repository → Entity`. No business logic in controllers; no JPA types in controllers/DTOs; no raw entities serialized to JSON.
- `@RestController` / `@Service` / `@Repository` used on the right classes.
- **Constructor injection only** — no `@Autowired` on fields.
- Request bodies annotated with `@Valid`; DTOs carry `jakarta.validation` constraints (`@NotNull`, `@Size`, `@Email`, etc.).
- `@Transactional` sits on service methods, not repositories or controllers. Read-only queries use `@Transactional(readOnly = true)`.
- Exceptions translated centrally via `@ControllerAdvice` / `@ExceptionHandler`, ideally returning RFC 7807 `application/problem+json`.
- HTTP status codes and RESTful semantics are correct (201 for create, 204 for delete, 404 vs 400, etc.).
- No `n+1` query patterns: look for `@OneToMany` / `@ManyToOne` access inside loops without `@EntityGraph` or fetch joins.
- Mappers (MapStruct or manual) kept out of controllers and services where they'd clutter business logic.
- DTOs live in their own package; entities are not leaked across the REST boundary.
- No unhandled checked exceptions bubbling out of public APIs.
- Tests: new/changed code paths covered by JUnit 5; integration tests use Testcontainers Postgres, not H2.

### PostgreSQL + Flyway
- Migrations live in `backend/src/main/resources/db/migration/`.
- Naming follows `V<version>__<description>.sql` (or `R__<name>.sql` for repeatable). Version increments don't collide with existing ones.
- **Forward-only discipline**: no edits to an already-applied migration. Schema changes go in a new `V` file.
- Destructive operations (`DROP`, `TRUNCATE`, `ALTER ... DROP COLUMN`) only appear when genuinely intended and ideally with a comment explaining why.
- Foreign keys have indexes. Frequently-queried columns have indexes. Unique constraints declared where the domain requires uniqueness.
- Column types are appropriate: `TEXT` over `VARCHAR(n)` unless a length limit is meaningful; `TIMESTAMPTZ` over `TIMESTAMP`; `NUMERIC` over `FLOAT` for money.
- `NOT NULL`, `CHECK`, `UNIQUE`, and `FOREIGN KEY` constraints present where invariants demand them.
- No raw SQL concatenation with user input — parameterized queries / `@Query` with bind parameters only.
- If a schema change was made, the matching JPA `@Entity` was updated. `ddl-auto: validate` would pass.
- Repeatable migrations (`R__*.sql`) are genuinely idempotent — views, functions, seed data, not structural changes.

### Docker / Helm / Kubernetes
- Dockerfiles are multi-stage; final image is slim (`eclipse-temurin:*-jre` or distroless for backend, `nginx:alpine` for frontend).
- No secrets baked into images. Credentials come from env vars or mounted secrets.
- `helm lint helm/<app>` would pass. Any new key in `values.yaml` is actually referenced in a template (and vice versa).
- Environment overlays (`values-<env>.yaml`) updated if the new config needs per-environment values.
- Liveness / readiness / startup probes still point at valid actuator endpoints if probe config changed.
- **If a Flyway migration was added**: the migration Job / ConfigMap / baked-migrations-image path that ships SQL to the cluster is updated. Don't let a migration land that never makes it into the pre-upgrade hook.
- `NetworkPolicy`, `PodDisruptionBudget`, and `HorizontalPodAutoscaler` updated if replica assumptions changed.
- `HTTPRoute` / `Ingress` paths still match the split between `/` (frontend) and `/api` (backend).

### Dev container (`.devcontainer/`)
- If toolchain versions changed, the Dockerfile and `devcontainer.json` features agree.
- Forwarded ports match the services actually running (Vite, Spring Boot, Postgres).
- `postCreateCommand` still warms the caches it's supposed to (Maven/Gradle offline, `npm ci`).
- No host-specific paths or absolute mounts snuck in.

### Docs sync (BLOCKING when stale)
- **`README.md`** — updated if setup, dev commands, env vars, prerequisites, or tech stack changed.
- **`docs/` folder** — updated if architecture, API contracts, data models, workflows, or domain concepts changed. In particular, `docs/sample-architecture.md` (or the project's equivalent architecture doc) must reflect any structural shift.
- **OpenAPI / Swagger spec** (if present) — updated if REST endpoints were added, changed, or removed.
- **`CLAUDE.md`** (if present) — updated if key files, commands, or conventions it cites have moved.
- **ADRs / decision logs** (if present) — a new ADR added if this change reflects a meaningful architectural decision.
- **Flyway migration notes** — if a migration changes behavior developers need to know about (data backfills, non-obvious invariants), a note belongs in `docs/` or the migration's header comment.

### Commit-message sanity (only if a message is already drafted)
- No debug trailers or co-author lines the user hasn't asked for.
- Style matches recent history — check with `git log --oneline -10`.

## Output format

```
# Pre-Commit Review

## Verdict
[ READY | READY WITH WARNINGS | FIX BEFORE COMMIT ]

## Blocking
- [file:line] issue -> fix

## Warnings
- [file:line] issue -> fix

## Docs sync
- README.md: [ok | needs: <what> | n/a]
- docs/: [ok | needs: <what> | n/a]
- OpenAPI / API docs: [ok | needs: <what> | n/a]
- CLAUDE.md / ADRs: [ok | needs: <what> | n/a]

## Next
<concrete actions, in order>
```

## After the report

- Verdict ❌: offer to apply the fixes directly. Trivial docs/typo fixes — just do them. Code changes — confirm first.
- Verdict ⚠️: summarize warnings, ask whether to address them now or defer.
- Verdict ✅: hand control back, ready for `/commit`.
