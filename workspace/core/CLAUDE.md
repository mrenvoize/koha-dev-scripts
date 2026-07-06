# CLAUDE.md — Koha core codebase

This is a Koha ILS (Integrated Library System) worktree:

- **Backend**: Perl 5, DBIx::Class, Mojolicious, Template Toolkit
- **Frontend**: Vue.js 3 + Bootstrap 5 + jQuery (on Template Toolkit pages)
- **Test Environment**: KTD (Koha Testing Docker)
- **Database**: MySQL/MariaDB with full test data

## Critical rules

- **Never run `prove` outside the container** — paths, DB, deps are KTD-internal.
- **Cypress runs from the host** — KTD exposes the web UI; the browser runs on your machine.
- **Database is reset between test runs** — don't rely on previous-run state.

## Container naming

Every command below uses `${KTD_INSTANCE:-kohadev}`:

- Single-instance setups (laptop default): falls back to `kohadev` → container `kohadev-koha-1`.
- Parallel worktrees (typical on `kohadev.home`): the `kd` wrapper sets `KTD_INSTANCE=<feature>` → container `<feature>-koha-1`.

## Quick test commands

```bash
# Perl tests (inside KTD)
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'prove t/path/to/test.t'
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'prove -r t/db_dependent/'

# Cypress (from the host — KTD exposes the UI on localhost / *.kohadev.home)
npx cypress run --spec "t/cypress/integration/path/to/spec.ts"
```

## Reference

@docs/testing.md — full test commands, `.only`/`.skip`, code quality checks
@docs/building.md — yarn build, CSS/JS compilation, Swagger/OpenAPI rebuild
@docs/architecture.md — C4 vs Koha/, DBIx::Class, REST API, Vue, plugins
@docs/database.md — schema updates, atomicupdate files, DBIC regeneration, system prefs
@docs/dev-workflow.md — `kd` wrapper, direct KTD commands, submission process
