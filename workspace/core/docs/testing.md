# Testing

## Perl Tests

All tests must be run inside the KTD container:

```bash
# Run all unit tests
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'prove -r t/'

# Run database-dependent tests
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'prove -r t/db_dependent/'

# Run specific test files/directories
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'prove t/Koha.t'
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'prove t/db_dependent/Circulation/'
```

## Cypress (End-to-End)

Cypress tests run from the **host** (outside container) — KTD exposes the web UI on localhost:

```bash
npx cypress run --spec "t/cypress/integration/"
npx cypress run --spec "t/cypress/integration/Biblio/bookingsModal_spec.ts"

# Alternative: run inside container
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'yarn cypress run --spec t/cypress/integration/'
```

To run a single test within a spec, add `.only`:

```javascript
it.only("only run this one", () => {
    // use it.skip(...) to skip a test
});

it("not this one", () => {});
```

## Test Architecture

- **Unit Tests**: `/t/` — Pure Perl logic testing
- **Database Tests**: `/t/db_dependent/` — Requires test database
- **Integration Tests**: `/t/cypress/` — End-to-end browser testing
- **Test Data**: `TestBuilder.pm` for creating test fixture objects

## Code Quality / Perl Standards

```bash
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'prove t/00-testcritic.t'  # Perl coding standards
ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'prove t/00-valid-xml.t'   # XML validation
```
