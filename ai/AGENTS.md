## Language

- Chat: zh-TW
- Commits, PRs, code comments, docs: English (unless the repo already uses another language)
- Keep code and technical terms in English
- Be concise; no filler

## Workflow

Default to autonomy: keep going until the task is done; stop only when noted below.

- Unclear requirements -> make a reasonable assumption, state it, continue
  - Stop and ask only if a wrong guess would be costly to undo
- Hard-to-reverse changes -> propose first, wait for confirmation
  - e.g. DB migrations, breaking public API, new paid services or heavy dependencies
  - Everything else: state the plan in one line, then implement
- Verify APIs / data models by reading code or docs; ask only if they can't be confirmed
- Unrecoverable actions -> always ask first
  - e.g. force push, drop DB, deleting untracked files, `reset --hard` with uncommitted changes
  - Committed work is recoverable; no need to ask
- Behavior changes -> add or update tests
- Before claiming done -> run the repo's existing test / lint / typecheck; report failures as-is
  - No tests -> do a minimal smoke check
  - No runtime behavior change (docs, comments, styling) -> skip, and say so

## Git / GitHub

- Commit and push automatically once a task is complete and verified
- Personal projects (remote owner is GitHub `HyperSoWeak`): push directly to main
- Other repos: work on a branch
- Use Conventional Commits (`feat:`, `fix:`, etc.)
- PR titles follow the same convention
- One commit per completed task (including its tests/docs)
  - Split only when the task bundles unrelated changes, e.g. an unrelated refactor
- Branch: `type/issue-id-name`; without an issue, `type/name`

## Code Style

- No over-engineering
- Avoid new abstractions unless reused >=2 times
- Follow existing naming and patterns strictly
- Add comments only for non-obvious WHY
- No extra error handling or fallbacks for scenarios that can't happen

## Preferred Tech Stack

Applies to new projects only. In existing repos, follow what's already there.

- Frontend: React + TypeScript (Vite / Next.js)
- Backend: Node.js/TypeScript or Python/FastAPI
- Database: PostgreSQL + Prisma
- Package manager: pnpm, uv
- Deployment: Docker on own VPS

## Miscellaneous

- When asked to "just explain" or "just propose", do not write or edit any files
- Dev servers / background processes: OK to start for verification; stop them when done
- If a repeated pattern indicates a stable workflow preference, proactively suggest a prompt update

## Local

Machine-specific rules live in `~/.config/AGENTS.local.md` (untracked, may not exist). If it exists and its content isn't already in context, read it first: @~/.config/AGENTS.local.md
