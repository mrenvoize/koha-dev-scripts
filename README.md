# koha-scripts

Personal Koha development workflow scripts. Each script lives in `bin/` and is installed via symlink.

## Scripts

| Command | Purpose |
|---------|---------|
| `koha-feature-up <name>` | Create/attach a worktree and bring up a KTD instance |
| `koha-feature-down <name> [--remove-worktree]` | Tear down a KTD instance, optionally remove the worktree |
| `koha-feature-tmux <name>` | Attach/create a tmux session with container and dev windows |

## Install

```bash
git clone <repo-url> ~/Projects/koha-scripts
~/Projects/koha-scripts/install.sh
```

Re-run `install.sh` after adding new scripts — it symlinks everything in `bin/` into `~/.local/bin/`.

## Sync between machines

```bash
git pull          # pull changes
./install.sh      # re-link (new scripts, renamed scripts, etc.)
```

## Dependencies

- `ktd` / `ktd_proxy` — [koha-testing-docker](https://gitlab.com/koha-community/koha-testing-docker)
- `docker`
- `tmux`
- `claude` (for the dev window in `koha-feature-tmux`)

## Environment

| Variable | Default | Purpose |
|----------|---------|---------|
| `KOHA_DIR` | `~/Projects/koha` | Root of the Koha workspace |
| `KTD_HOME` | `$KOHA_DIR/tooling/koha-testing-docker` | KTD checkout location |
