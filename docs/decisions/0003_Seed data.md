# ADR-0003: Seed 300 events with plain SQL, deterministic via hashtext()

- **Status:** Accepted
- **Date:** 2026-11-11
- **Ticket:** TIX-005

## Context
The guide asks for 50 events x 2,000 seats and 500k historical orders, but
that is only 100,000 seats. If each order buys at least one unique seat,
500k orders cannot exist. The dataset also has to rebuild from one command,
be identical on every run and in CI, and work before any domain or JPA code
exists (Sprints 1 and 3).

## Decision
I generate 300 events in plain SQL (`docker/postgres/seed/seed.sql`): events
1-50 are the live catalogue with AVAILABLE seats, and events 51-300 are past
events with every seat SOLD, giving 250 x 2,000 = 500,000 single-item
historical orders. Randomness comes from `hashtext()` of the row id, never
`random()`.

## Alternatives rejected
- **Multi-seat orders over the original 50 events.** Keeps the guide's
  numbers literal, but orders average about 5 line items, which inflates
  the item table and distorts the N+1 experiment in TIX-306. It also leaves
  no past events for cursor pagination and history queries.
- **Java/Kotlin seed generator.** Couples the seeder to domain code that
  does not exist yet, and row-by-row inserts are far slower than
  `generate_series`.
- **`random()` with `setseed()`.** Reproducible only while insertion order
  and query plans stay the same. A hash of the row id depends on neither.
- **Faker-style realistic data.** Realism adds nothing here. Row counts,
  skew and index selectivity are what make performance problems visible.
- **Committed `pg_dump` snapshot.** Tied to a Postgres version, can't be
  reviewed in a diff, and goes stale on every schema change.

## Consequences
**Easy:**
- One command (`make seed`) rebuilds the dataset, and CI can do the same, so
  every later card can run against full data as the Definition of Done
  requires.
- Ids are stable (seat ids 1..600,000; historical order id = seat id -
  100,000), so tests and queries can refer to them directly.
- Identity sequences are advanced with `setval`, so the app can insert new
  rows without colliding with seeded ids. Seats carry a `version` column
  ready for optimistic locking (TIX-401).

**Hard or expensive:**
- `hashtext()` is undocumented and not guaranteed stable across Postgres
  majors. Postgres must be pinned to one