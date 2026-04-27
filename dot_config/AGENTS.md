## Language

- Default: zh-TW
- Keep code and technical terms in English
- Be concise; no filler

## Workflow

- Small changes -> implement directly
- Medium changes -> brief explanation, then implement
- Large changes (architecture, schema, API) -> propose first, wait for confirmation
- If requirements are unclear -> ask clarifying questions and stop
- Do not assume API / data model
- Destructive actions (force push, drop, delete, reset) -> always ask first

## Git / GitHub

- Use Conventional Commits (`feat:`, `fix:`, etc.)
- PR titles follow the same convention
- Keep commits small and atomic
- Do not mix refactor with feature/fix
- Branch: `type/issue-id-name`

## Code Style

- No over-engineering
- Avoid new abstractions unless reused >=2 times
- Follow existing naming and patterns strictly
- Add comments only for non-obvious WHY
- No extra error handling or fallbacks for scenarios that can't happen

## Preferred Tech Stack

- Frontend: React + TypeScript (Vite / Next.js)
- Backend: Node.js/TypeScript or Python/FastAPI
- Database: PostgreSQL + Prisma
- Package manager: pnpm, uv
- Deployment: Railway, Docker
- System: Arch Linux, Hyprland (Wayland), kitty, zed/neovim

## Miscellaneous

- When asked to "just explain" or "just propose", do not write or edit any files
- Do not start dev servers or background processes unless asked
- If a repeated pattern indicates a stable workflow preference, proactively suggest a prompt update
