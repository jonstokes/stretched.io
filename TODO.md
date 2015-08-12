# To Do

## Back end
 - Remove postgres and just use AR without a DB at all.
 - Clean up specs and make sure coverage is thorough
 - Monitor spec runs for unnecessary ES queries, and memoize all the things
 - RunFeedsService
 - Add support for irongrid features
 - Move over dictionary code from old stretched repo
 - Port over support for templating (was keyrefs) in adapters.

## Front-end
 - Basic HTTP auth
 - Views/scaffolding for all models
  - CRUD: domain, feed, rate_limit, schema, adapter
  - Read-only: page, session, document, extension, script
 - Dashboard for domains: num feeds, pages, docs, last read, session stats, etc.
