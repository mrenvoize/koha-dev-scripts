# Build & Asset Processing

All build commands run inside the KTD container.

## Development Builds

```bash
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'yarn build'          # Full build (CSS + JS + API docs)
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'yarn css:build'       # CSS compilation for both interfaces
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'yarn js:build'        # JavaScript bundling
```

## Production Builds

```bash
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'yarn build:prod'      # Optimized production build
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'yarn css:build:prod'  # Production CSS with minification
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'yarn js:build:prod'   # Production JS with optimization
```

## Watch Mode

```bash
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'yarn css:watch'       # Watch CSS files
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'yarn js:watch'        # Watch JS files
```

## Swagger/OpenAPI Development

**IMPORTANT**: After editing `.yaml` files in `api/v1/swagger/`, you must rebuild and restart:

```bash
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'yarn build'
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'restart_all'

# Then run API tests
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'prove t/db_dependent/api/v1/yourtest.t'
```

Changes to swagger YAML are not reflected until `yarn build` + `restart_all` — the build compiles the OpenAPI spec and services must reload it.

## JS/CSS Linting

```bash
npx eslint .               # JavaScript/TypeScript/Vue linting
npx prettier --write .     # Code formatting
npx stylelint "**/*.scss"  # CSS/SCSS linting
```
