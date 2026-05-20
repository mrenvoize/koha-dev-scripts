# koha-dev-scripts

Personal Koha development workflow scripts. A single `kd` command wraps git worktree and KTD instance management.

## Usage

```
kd up <name> [--plugin PATH] [--plugins] [--search-engine ENGINE]
             [--selenium] [--smtp] [--sso] [--persistent-db]
kd down <name> [--rm]
kd tmux <name>
kd shell <name> [--root] [--run 'cmd']
kd logs <name>
kd list
kd proxy [start|stop|status]
```

| Command | Purpose |
|---------|---------|
| `kd up` | Create worktree (if needed) and start a KTD instance |
| `kd down` | Stop a KTD instance; `--rm` also removes the worktree |
| `kd tmux` | Attach or create a tmux dev session (container + dev windows) |
| `kd shell` | Drop into the KTD container shell |
| `kd logs` | Follow the KTD container logs |
| `kd list` | Show all worktrees with KTD container name and status |
| `kd proxy` | Manage the shared Traefik proxy |

Versioned branch names (`NN.NN.TAG`, e.g. `24.11.etf`) are automatically mapped to a Docker-safe project name (`etf24`) and the correct `KOHA_IMAGE`.

## Install

```bash
git clone <repo-url> ~/Projects/koha/tooling/koha-dev-scripts
~/Projects/koha/tooling/koha-dev-scripts/install.sh
```

Re-run `install.sh` after pulling — it symlinks everything in `bin/` into `~/.local/bin/` and removes any legacy `koha-feature-*` symlinks.

## Sync between machines

```bash
git pull
./install.sh
```

## Dependencies

- `ktd` / `ktd_proxy` — [koha-testing-docker](https://gitlab.com/koha-community/koha-testing-docker)
- `docker`
- `tmux`
- `claude` (for the dev window in `kd tmux`)

## Environment

| Variable | Default | Purpose |
|----------|---------|---------|
| `KOHA_DIR` | `~/Projects/koha` | Root of the Koha workspace |
| `KTD_HOME` | `$KOHA_DIR/tooling/koha-testing-docker` | KTD checkout location |
