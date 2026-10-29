# koha-dev-scripts

Personal Koha development workflow scripts. A single `kd` command wraps git worktree and KTD instance management.

## Usage

```
kd up   <name> [--plugin PATH] [--plugins] [--search-engine ENGINE]
               [--selenium] [--smtp] [--sso] [--persistent-db]
               [--bz] [--tmux] [--track UPSTREAM]
               [--non-interactive] [--follow-status STATUS]
kd wt   <name> [--bz] [--track UPSTREAM] [--non-interactive] [--follow-status STATUS]
kd down <name> [--keep] [--rm=full]
kd tmux <name>
kd shell <name> [--root] [--run 'cmd']
kd logs <name>
kd list [--refresh]
kd prune [--older-than DAYS] [--no-containers] [-n|--dry-run] [-y|--yes]
kd proxy [start|stop|status]
```

| Command | Purpose |
|---------|---------|
| `kd up` | Create worktree (if needed) and start a KTD instance. `--bz` applies the bug's patches (`git bz apply`, bug number taken from a `bug_NNNNN` name) before booting; `--tmux` waits for KTD to be ready then opens the tmux session; `--track UPSTREAM` creates a new branch tracking an upstream ref (e.g. `origin/master`) instead of branching from `main`. With `--bz`, `--non-interactive` and `--follow-status STATUS` are passed to `git bz apply` for unattended use (the exit status is git bz's own; 3 means a dependency isn't in a followable state) — `koha-reviewer` drives `kd wt`/`kd up` this way. The remaining flags are passed through to `ktd` |
| `kd wt` | Create the worktree only (no KTD). Takes `--bz` and `--track` like `kd up` |
| `kd down` | Stop the KTD instance **and remove its worktree** (the branch is kept). `--keep` leaves the worktree in place; `--rm=full` also deletes the branch. (`--rm` is accepted for compatibility; it is now the default) |
| `kd tmux` | Attach or create the `koha-<name>` tmux session: a `container` window (docker logs + KTD shell) and a `dev` window running your agent CLI in the worktree. See [tmux sessions](#tmux-sessions) |
| `kd shell` | Drop into the KTD container shell (`--root` for root, `--run 'cmd'` to run one command) |
| `kd logs` | Follow the KTD container logs |
| `kd list` | Table of local branches with Bugzilla title/status, last-worked date, and worktree/container status (alias: `kd branches`). See [kd list](#kd-list) |
| `kd prune` | Reclaim disk from worktrees and KTD containers nothing uses any more. Lists the plan and asks first (`-n` only lists, `-y` skips the question). A worktree is removed only if it is **clean** (or an abandoned half-applied `git am`, which is aborted first), idle for `--older-than DAYS` (default 7), has no running KTD instance, and no process has its cwd inside it — so a worktree an agent session is working in is never pulled out from under it. Removal is never forced, and branches are never deleted. Also removes KTD containers whose worktree is gone (`--no-containers` to skip); named volumes such as `--persistent-db` are kept. Directories git no longer knows about are reported, not removed (a container may have left root-owned files in them), except ones holding only an empty `.remember/` |
| `kd proxy` | Manage the shared Traefik proxy (started automatically by `kd up` if it isn't running) |

Versioned branch names (`NN.NN.TAG`, e.g. `24.11.etf`) are automatically mapped to a Docker-safe project name (`etf24`) and the correct `KOHA_IMAGE`.

Every worktree that `kd up` / `kd wt` creates is also made usable and tidy:

- **Bare-repo fix.** KTD enables `extensions.worktreeConfig` on the shared bare clone, which makes every worktree inherit `core.bare=true` and breaks `git status`/`git am`/`git commit`. `kd` sets a per-worktree `core.bare=false` override.
- **Shared Claude memory.** If a root memory store exists under `~/.claude/projects/`, each worktree's memory directory is symlinked to it so accumulated Koha knowledge follows every session (existing real memory dirs are never replaced). Honours `CLAUDE_CONFIG_DIR`.

### tmux sessions

`kd tmux <name>` builds the session `koha-<name>` (re-running it just re-attaches, or switches client when already inside tmux):

- **`container`** window: docker logs on the left, `ktd --shell` on the right.
- **`dev`** window: `$KD_AGENT` (default `claude`) on the left, an empty terminal on the right, all with the worktree as cwd.

Every pane gets `KTD_INSTANCE`, `SYNC_REPO`, `KTD_HOME` and `KOHA_DIR`, so tests, builds and git target the right instance and branch. `KD_AGENT` may include arguments (`KD_AGENT="opencode --foo"`); its binary is checked before the session is created. `kd` also keeps a detached `_anchor` tmux session rooted at `$HOME` so that removing a worktree can never leave the tmux server with a stale working directory.

If your shell rc exports `SYNC_REPO`, only *default* it (`export SYNC_REPO=${SYNC_REPO:-…}`) or it will overwrite the per-worktree value in the terminal pane.

### kd list

Bugzilla title and status come from `bugs.koha-community.org`, cached in `${XDG_CACHE_HOME:-~/.cache}/kd/bugzilla.json`; `--refresh` forces a fresh lookup (an unreachable server falls back to the cache). With [fzf](https://github.com/junegunn/fzf) and a terminal it opens interactively, otherwise it prints through `$PAGER`.

| Key | Action |
|-----|--------|
| `enter` | Action menu for the row (up, tmux, shell, logs, down, ...) |
| `tab` | Multi-select rows for bulk up / down |
| `ctrl-t` / `ctrl-u` / `ctrl-d` | tmux / up + tmux / down |
| `alt-t` / `alt-b` / `alt-l` / `alt-c` | Sort by title / Bugzilla status / last worked / container |
| `alt-r` | Reset to branch order |

The list refreshes after each action. Rows are colour-coded by Bugzilla status.

## Workspace docs (`workspace/`)

`workspace/` mirrors the shared, machine-agnostic Koha workspace config — the
`AGENTS.md` / `CLAUDE.md` files and `core/docs/*.md` — under the same layout they occupy at
`$KOHA_DIR`. `install.sh` symlinks each one into place, so the repo is the single
source of truth: edit here, commit, push, and `git pull && ./install.sh` on the
other machine picks it up. (Machine-specific `core/notes/` is deliberately not
synced.)

```
workspace/
├── AGENTS.md            → $KOHA_DIR/AGENTS.md   (shared, any agent)
├── CLAUDE.md            → $KOHA_DIR/CLAUDE.md   (imports AGENTS.md)
└── core/
    ├── AGENTS.md        → $KOHA_DIR/core/AGENTS.md
    ├── CLAUDE.md        → $KOHA_DIR/core/CLAUDE.md (imports AGENTS.md + docs/*.md)
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
- `docker`, `git`
- `tmux`
- `curl` and `jq` (Bugzilla lookups in `kd list`)
- `fzf` (optional — interactive `kd list`; falls back to `$PAGER` without it)
- `git-bz` (only for `--bz`)
- An agent CLI for the dev window in `kd tmux` (default `claude`; set `KD_AGENT` to use another, e.g. `opencode`)

## Environment

| Variable | Default | Purpose |
|----------|---------|---------|
| `KOHA_DIR` | `~/Projects/koha` | Root of the Koha workspace |
| `KTD_HOME` | `$KOHA_DIR/tooling/koha-testing-docker` | KTD checkout location |
| `KD_AGENT` | `claude` | Agent CLI (optionally with arguments) launched in `kd tmux`'s dev window |
| `XDG_CACHE_HOME` | `~/.cache` | Location of the `kd/bugzilla.json` cache |
| `PAGER` | `less -FRSX` | Pager for `kd list` when fzf isn't used |
| `CLAUDE_CONFIG_DIR` | `~/.claude` | Where shared Claude memory is linked |
