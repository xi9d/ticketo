# ADR-0002: Four Gradle modules with a framework-free domain

- **Status:** Accepted
- **Date:** 2026-09-25
- **Ticket:** TIX-003

## Context

The learning goals for this project include understanding what Spring actually
does, rather than absorbing it as ambient magic. That is hard when framework
annotations are available everywhere, because the path of least resistance is
to reach for one without noticing.

I also want domain tests that run in milliseconds. A test that starts a Spring
context takes seconds, and slow tests get run less often, which defeats the
purpose of writing them.

Spring Initializr generates a single-module project, so any structure beyond
that is a decision I have to make and defend.

## Decision

Four Gradle modules, with dependencies pointing inward only:

    api ──> persistence ──┐
     ├────> messaging ────┼──> domain ──> (nothing)
     └─────────────────────┘

- `domain` — business types and logic. Declares no dependencies beyond JUnit
  and AssertJ. Defines ports (interfaces such as `OrderRepository`,
  `EventPublisher`) describing what it needs.
- `persistence` — JPA, Postgres and Flyway. Implements the persistence ports.
- `messaging` — Kafka. Implements the publishing ports.
- `api` — Spring Web, the `@SpringBootApplication` class, and all bean wiring.
  The composition root, and the only module permitted to know about all others.

The framework-free rule is enforced structurally, not by discipline:
`domain/build.gradle.kts` declares no Spring dependency, so a Spring import
there fails to compile. A `assertNoFramework` task wired into `check` asserts
the domain compile classpath contains no artifact whose name begins with
`spring`, `jakarta.persistence`, `jackson` or `hibernate`.

Build mechanics: Gradle 9.7.1 with the Kotlin DSL, a version catalog at
`gradle/libs.versions.toml`, and `platform(spring-boot-dependencies)` for
version alignment. The Spring Boot plugin is declared once at the root with
`apply false` and applied only in `api`.

## Alternatives rejected

- **Single module, boundaries by package convention** — rejected because
  nothing enforces it. The rule survives exactly until the first time I am
  tired and an annotation would solve my problem in ten seconds. Module
  boundaries are checked by the compiler; package conventions are checked by
  my memory, which is the weaker of the two.

- **Single module with ArchUnit rules instead of modules** — closer, and it
  would still fail the build. Rejected because the feedback arrives at test
  time rather than compile time, and because the library would still be on
  the classpath, so IDE autocomplete would keep offering me `@Service` in the
  domain. Removing the temptation beats resisting it. ArchUnit is still
  planned (TIX-108) as a complement, not a replacement.

- **Five modules, with a separate `app`/`bootstrap` composition root** — a
  legitimately cleaner separation between the web adapter and the wiring.
  Rejected as ceremony at this size: it adds a build file and an indirection
  to solve a problem I do not have yet. Revisit if `api` grows a second
  delivery mechanism, such as a CLI or a gRPC endpoint.

- **A `common` or `shared` module** — rejected preemptively. Everything ends
  up depending on it, which destroys the dependency direction above, and it
  accumulates unrelated code because nothing is clearly out of scope for a
  module named "common". If something feels shared, it belongs in `domain`.

- **`io.spring.dependency-management` plugin (the Initializr default)** —
  rejected in favour of Gradle's native `platform()` support, which supplies
  the same BOM with one fewer plugin. No functional difference; fewer moving
  parts when a version conflict needs debugging.

- **Applying the Spring Boot plugin to every module** — rejected because it
  switches library modules to producing a `bootJar` and disables the plain
  `jar`, so other modules cannot consume them. Also, its dependency management
  would reach `domain` and quietly defeat the whole decision.

## Consequences

- **Good:** the framework-free rule is enforced by the compiler and by
  `./gradlew check`. It cannot rot through inattention.

- **Good:** domain tests are plain JUnit with no context startup.

- **Good:** wiring is explicit `@Bean` methods in `api` rather than component
  scanning, which makes the object graph visible. This directly supports the
  bean lifecycle work in TIX-106.

- **Bad:** mapping boilerplate at every boundary. API DTOs map to domain
  types; domain types map to persistence entities. This is a real ongoing
  cost, paid on every feature, and it is the main thing that would make me
  reverse this decision.

- **Bad:** four build files instead of one, and Gradle multi-module has sharp
  edges. Setting this up cost roughly an hour across four failures worth
  recording, since I will hit them again:
    1. `Unresolved reference 'implementation'` — Kotlin DSL type-safe accessors
       are generated per script from its own `plugins { }` block. Applying
       `java` from the root `subprojects { }` is too late. Every module that
       references `implementation` declares `java` itself.
    2. `No matching variant of project ':domain'` — a module with no `java`
       plugin produces no artifacts at all. "No variants exist" means empty,
       not misconfigured.
    3. `:bootJar` failing on `mainClass` — the Boot plugin was still applied to
       the root project from the Initializr output. The missing `:api:` prefix
       in the task name was the clue.
    4. `Cannot find ...starter-actuator:` with an empty version — a leftover
       root `dependencies { }` block with no BOM to supply versions.

- **Bad:** every new dependency now requires deciding which module owns it.
  Mostly a feature, occasionally friction.

- **Open:** whether domain types may carry `jakarta.persistence` annotations
  is deliberately not settled here. It is a separate decision with its own
  tradeoff and gets its own ADR before the first entity is mapped in TIX-303.

## Revisit if

- The mapping boilerplate is measurably slowing feature work, rather than
  merely being annoying.
- A second delivery mechanism appears, at which point the five-module
  split becomes worth its cost.