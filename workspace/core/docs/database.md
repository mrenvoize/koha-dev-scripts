# Database Schema Updates

## Workflow for Schema Changes

When adding new system preferences or database changes:

1. Update `installer/data/mysql/kohastructure.sql`
2. Create `installer/data/mysql/atomicupdate/bug_XXXXX.pl`
3. Apply changes inside KTD: `ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'perl installer/data/mysql/updatedatabase.pl'`
4. Regenerate DBIC schema files: `ktd --name "${KTD_INSTANCE:-kohadev}" --shell --run 'dbic --force'`
5. Commit as `Bug XXXXX: Automated Schema Update`
6. Add `koha_object_class`, relationships BELOW the `# DO NOT MODIFY THIS OR ANYTHING ABOVE!` line
7. Commit those manually as a separate commit

**Never manually edit the auto-generated portion of DBIC schema files.**

## Atomicupdate File

- **Location**: `/installer/data/mysql/atomicupdate/` named `bug_XXXXX.pl`
- **Release**: Release manager migrates to `/installer/data/mysql/db_revs/` with increment numbers
- Use `Koha::Installer::Output` for error handling and success messages

## System Preferences Format

```perl
# In atomicupdate file
$dbh->do(q{
    INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
    VALUES ('PrefName', 'defaultvalue', 'option1|option2', 'Explanation text', 'Choice')
});
```

Fields: `variable`, `value`, `options`, `explanation`, `type`
