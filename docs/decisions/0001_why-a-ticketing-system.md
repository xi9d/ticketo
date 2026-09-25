# ADR-0001: Build a seat-reservation ticketing backend as the learning project

- **Status:** Accepted
- **Date:** 2026-09-25
- **Ticket:** TIX-002

## Context

I want to learn Java 21, Kotlin and Spring Boot properly — concurrency,
transactions, messaging, resilience and observability — rather than reading
about them. That needs a project where those topics are unavoidable, not
optional extras I can skip when they get hard.

A domain only forces them if it has three properties:

1. Contended mutable state, so correctness under concurrency is a real
   business requirement and not an exercise.
2. An external paid dependency I can make fail on demand, so timeouts,
   retries and circuit breakers have something to protect me from.
3. State changes other systems would care about, so messaging and the
   outbox pattern are justified rather than bolted on.

## Decision

Build a seat-reservation ticketing backend: venues, events, seat inventory,
holds, orders, payments, tickets.

Two people wanting seat 14C is a genuine race condition with a business
consequence, which makes concurrency mandatory rather than decorative.

## Alternatives rejected

- **A generic e-commerce backend** — rejected as too close to tutorial
  material. The solutions are all pre-written online, which removes the
  part where I work it out and get it wrong first.

## Consequences

- Good: every topic on my backend map has a natural home in this domain.
  Nothing needs to be shoehorned in.

- Bad: I have to build a fake payment gateway and a load harness before
  anything user-visible exists. There is no demo for months, and that
  will be demotivating around sprint 5.

- Bad: seat inventory at realistic volume (50 events x 2,000 seats) makes
  local development slower than a toy dataset would. Accepted deliberately —
  performance problems are invisible at 100 rows.

- Risk: if I lose interest, I have nothing shippable. Mitigation is the
  proof index in Appendix B — the artifacts have value even if the
  application never runs in anger.
