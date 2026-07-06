# Development Workflow

## Worktree-per-feature

The Koha codebase lives in a bare clone (`core/koha.git`) shared across multiple worktrees under `core/worktrees/<feature>/`. Each feature gets its own KTD instance, addressable at `http://<feature>.kohadev.home` (OPAC) and `http://<feature>-intra.kohadev.home` (staff).

The `kd` wrapper (`~/.local/bin/kd`, same on local and `kohadev.home`) manages worktrees and KTD instances:

```bash
kd up   <feature> [--bz] [--tmux]  # create worktree from main + boot KTD instance
                                   #   --bz applies the bug's patches before booting
                                   #   --tmux opens the dev tmux session once KTD is ready
kd wt   <feature> [--bz]           # create worktree only (no KTD)
kd tmux <feature>                  # attach/create the dev tmux session (claude | shell | logs)
kd down <feature> [--rm]           # tear down KTD instance (--rm also removes the worktree)
kd list                            # worktrees + KTD container status
kd branches                        # branches, worktrees, containers, upstream tracking
```

`kd tmux` launches a Claude Code session in the "dev" window with cwd set to the
worktree — start your per-bug Claude sessions there rather than launching `claude`
by hand, so `KTD_INSTANCE`/`SYNC_REPO` are exported and git targets the right branch.

Under the hood, `kd` sets `KTD_INSTANCE=<feature>` so the `ktd --name "${KTD_INSTANCE:-kohadev}"` form everywhere in these docs picks the right container.

## Direct KTD commands (when scripts aren't enough)

```bash
ktd --list                                                       # show running instances
ktd_proxy --start                                                # start the shared Traefik proxy
ktd --proxy --name "$KTD_INSTANCE" up -d                         # from inside a worktree, SYNC_REPO=$PWD
ktd --name "$KTD_INSTANCE" --shell                               # exec into the koha container as koha user
ktd --name "$KTD_INSTANCE" --root --shell                        # exec into the koha container as root
ktd --name "$KTD_INSTANCE" --dbshell                             # mysql client into the db container
ktd --name "$KTD_INSTANCE" --logs                                # follow koha-1 container logs
ktd --name "$KTD_INSTANCE" --shell --run '<cmd>'                 # run a command inside the container
ktd down "$KTD_INSTANCE"                                         # tear down one instance
ktd down --all                                                   # tear down everything (proxy stays)
```

For single-instance setups (no parallel work), omit `--name` or use `KTD_INSTANCE=kohadev` — the container will be `kohadev-koha-1`.

## Submission process

1. Create feature branch from main via `kd up <feature>` (or `kd up bug_XXXXX --bz --tmux`)
2. Run tests inside KTD (see `@docs/testing.md`)
3. Build assets: `ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'yarn build'`
4. Submit patches to [bugs.koha-community.org](https://bugs.koha-community.org) (not GitHub PRs)
5. Follow the [SubmittingAPatch wiki](https://wiki.koha-community.org/wiki/SubmittingAPatch) guidelines
