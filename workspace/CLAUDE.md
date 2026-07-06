# CLAUDE.md

This tree contains Koha-related projects. Multiple tiers live here, each with their own command set — refer to the closest `CLAUDE.md` as you descend.

## Layout

- `core/` — the main Koha codebase. Single bare clone (`core/koha.git/`) shared by multiple worktrees under `core/worktrees/<branch>/`. See `core/CLAUDE.md` for Koha's commands.
- `plugins/` — Koha plugin packages. See `plugins/CLAUDE.md` for plugin-specific commands.
- `tooling/` — supporting infra: KTD (`tooling/koha-testing-docker/`), release-tools, qa-test-tools.
- `docs/` — Koha manuals, handbook, cookbook, advent, release notes. Documentation, not code.
- `core/notes/` — historical bug analysis, test plans, working notes. Not auto-loaded.

## Project context

Koha is the first open-source Integrated Library System (ILS). The main codebase is Perl (`Koha::*` objects on DBIx::Class, REST API via Mojolicious, Template Toolkit + Bootstrap 5 + Vue.js 3 frontend). Patches go to bugs.koha-community.org, not GitHub PRs.

## Workflow at a glance

The `kd` wrapper (`~/.local/bin/kd`) works on this machine and on `kohadev.home`:

```bash
kd up   <feature> [--bz] [--tmux]   # create worktree from main + boot a KTD instance
kd tmux <feature>                   # attach the dev tmux session (claude + shell + docker logs)
kd down <feature> [--rm]            # tear down the KTD instance (--rm also removes the worktree)
kd list                             # show all worktrees with KTD container name and status
kd shell <feature>                  # drop into the KTD container shell
kd logs <feature>                   # follow the KTD container logs
kd proxy [start|stop|status]        # manage the shared Traefik proxy
```

Start per-bug Claude Code sessions from `kd tmux`'s "dev" window — it launches
`claude` with cwd set to the worktree and `KTD_INSTANCE`/`SYNC_REPO` exported, so
tests, builds, and git all target the right instance and branch. Reserve a
root-level session (`~/Projects/koha`) for cross-bug triage and tooling.

Worktrees of the main codebase land at `core/worktrees/<feature>/`. `kd` sets `KTD_INSTANCE=<feature>` so the documented `ktd --name "${KTD_INSTANCE:-kohadev}" …` commands target the right container.

## External resources

- Bugzilla: <https://bugs.koha-community.org>
- Upstream git: <https://git.koha-community.org/Koha-community/Koha>
- Wiki: <https://wiki.koha-community.org>
- IRC: `#koha` on Libera.Chat
