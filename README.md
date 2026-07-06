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

## Workspace docs (`workspace/`)

`workspace/` mirrors the shared, machine-agnostic Koha workspace config — the
`CLAUDE.md` files and `core/docs/*.md` — under the same layout they occupy at
`$KOHA_DIR`. `install.sh` symlinks each one into place, so the repo is the single
source of truth: edit here, commit, push, and `git pull && ./install.sh` on the
other machine picks it up. (Machine-specific `core/notes/` is deliberately not
synced.)

```
workspace/
├── CLAUDE.md            → $KOHA_DIR/CLAUDE.md
└── core/
    ├── CLAUDE.md        → $KOHA_DIR/core/CLAUDE.md
    └── docs/*.md        → $KOHA_DIR/core/docs/*.md
```

## Install

```bash
git clone <repo-url> ~/Projects/koha/tooling/koha-dev-scripts
~/Projects/koha/tooling/koha-dev-scripts/install.sh
```

`install.sh` is re-runnable and idempotent. It symlinks everything in `bin/` into
`~/.local/bin/` and everything in `workspace/` into `$KOHA_DIR`, and removes any
legacy `koha-feature-*` symlinks.

Symlinks already pointing at the repo are left alone. A **real file** found at a
target is handled safely:

- **identical content** → adopted (replaced with the symlink; nothing is lost);
- **differing content** → a diff is printed and the file is **left in place**.
  Re-run with `--force` to replace it — the original is backed up to `<path>.bak`
  first. Without `--force`, the run exits non-zero and changes nothing else.

## Sync between machines

```bash
git pull
./install.sh            # or: ./install.sh --force  to overwrite divergent local files
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
