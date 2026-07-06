# Architecture Overview

## Core Components

- **C4/** — Legacy procedural modules (being phased out)
- **Koha/** — Modern OOP modules using DBIx::Class ORM
- **REST API** — `/api/v1/` with OpenAPI documentation at `/api/v1/swagger/`
- **Templates** — Template Toolkit in `/koha-tmpl/` (separate staff/OPAC interfaces)

## Database Layer

- **Schema**: `Koha/Schema.pm` (DBIx::Class auto-generated from database)
- **Objects**: Modern `Koha::*` objects inherit from `Koha::Object` base class
- **Legacy**: `C4::*` modules use raw DBI queries (avoid for new code)

## Web Interface

- **Staff Interface**: `/koha-tmpl/intranet-tmpl/` (jQuery + Bootstrap 5 + Vue.js 3)
- **OPAC**: `/koha-tmpl/opac-tmpl/` (Public catalog interface)
- **Modern Components**: Vue.js 3 SPA applications in ERM, Preservation modules
- **Build Pipeline**: Rspack for Vue.js, Gulp for CSS/SCSS compilation

## Plugin System

- **Base Class**: `Koha::Plugins::Base`
- **Hook System**: Comprehensive plugin hooks for extending functionality
- **Vue Components**: `/koha-tmpl/intranet-tmpl/prog/js/vue/components/`

## Object Model Pattern

```perl
# Modern pattern (preferred)
my $patron = Koha::Patrons->find($borrowernumber);
$patron->update({ firstname => 'New Name' });

# Legacy pattern (avoid for new code)
my $patron = GetMember(borrowernumber => $borrowernumber);
ModMember(borrowernumber => $borrowernumber, firstname => 'New Name');
```

## REST API Structure

- **Controllers**: `Koha/REST/V1/` (Mojolicious-based)
- **OpenAPI Specs**: `api/v1/swagger/` (YAML definitions)
- **Authentication**: OAuth2, Basic Auth, Cookie sessions

## Background Jobs

Async processing via `Koha::BackgroundJob` framework:

- **Job Classes**: `Koha/BackgroundJob/`
- **Usage**: Large batch operations, imports, indexing

## Search Engine Integration

- **Default**: Zebra indexing (legacy)
- **Modern**: Elasticsearch support (recommended for new installations)
- **Index Management**: Background jobs handle search index updates

## Module Guidelines

- **New Code**: Use `Koha::*` objects, avoid `C4::*` for new features
- **Database**: Use DBIx::Class relationships, avoid raw SQL
- **Templates**: Use Template Toolkit, Bootstrap 5 classes, Vue.js 3 for SPAs
- **JavaScript**: ES6+, Vue 3 Composition API for new components

## Configuration Files

- **Main Config**: `koha-conf.xml` (database, search, paths)
- **Apache**: `etc/apache.conf`, `debian/templates/`
- **Assets**: `package.json`, `gulpfile.js`, `rspack.config.js`
- **Search**: `etc/zebradb/` for Zebra, `SearchEngine::Elasticsearch` for ES
