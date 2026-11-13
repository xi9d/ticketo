# Ticketo

![CI](https://github.com/xi9d/ticketo/actions/workflows/ci.yml/badge.svg)

A seat-reservation ticketing backend (venues, events, seat holds, orders,
payments, tickets), built as a project-based path through Java 21 and
Spring Boot. The code is a vehicle for the lessons: see `docs/decisions/`
for the reasoning behind each choice.

## Prerequisites

| Tool | Version | Check |
|---|---|---|
| Java (JDK) | 21 | `java -version` |
| Docker Engine, running | recent | `docker info` |
| Docker Compose plugin | v2 | `docker compose version` |
| make | any | `make --version` |

You do not need to install Gradle; the wrapper (`./gradlew`) does it.

## Quick start

```bash
git clone <repo-url> ticketo
cd ticketo

make up                      # Postgres and Kafka, waits until healthy (~1 min)
make seed verify-seed        # load the dataset and check it
./gradlew :api:bootRun       # start the API on http://localhost:8080
```

In a second terminal, confirm the API is up:

```bash
curl -s http://localhost:8080/actuator/health
```

Expected: `{"status":"UP"}`.

## Optional stacks

| Command | Starts | Then open |
|---|---|---|
| `make obs` | Prometheus, Grafana, Jaeger | Grafana http://localhost:3000 (admin / admin), Prometheus http://localhost:9090, Jaeger http://localhost:16686 |
| `make auth` | Keycloak | http://localhost:8081 (admin / admin) |
| `make all` | everything above | |

`make ps` lists containers. Only Postgres and Kafka have health checks; the
other containers are only waited on until they start.

## The seeded dataset

`make seed` rebuilds the schema and loads: 300 events (50 upcoming, 250
past), 600,000 seats, 50,000 customers, 500,000 historical orders.
It is deterministic, so every run produces identical data.
`make verify-seed` asserts the counts, integrity and a checksum.

`make seed` is **destructive**: it drops and recreates the tables. Use it
only on this local database.

## Everyday commands

| Command | What it does |
|---|---|
| `make down` | Stop containers, keep data |
| `make reset` | Wipe all data, restart, re-seed |
| `make logs` | Follow container logs |
| `./gradlew build` | Compile and run all tests |
| `make baseline LABEL=warm` | Time the baseline queries, append to `docs/baselines/README.md` |

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Cannot connect to the Docker daemon` / `docker.sock` missing | `sudo systemctl start docker` |
| `permission denied` on the Docker socket | `sudo usermod -aG docker $USER`, then log out and in |
| `unknown flag: --profile` | Install the Docker Compose v2 plugin |
| `port is already allocated` | Something else uses 5432, 29092, 8081, 3000, 9090 or 16686 |
| `make seed` fails after changing Postgres version | `make reset` (old volume has the wrong layout) |
| `./gradlew: Permission denied` | `chmod +x gradlew` |

## Repository layout

| Path | Purpose |
|---|---|
| `api/` | Spring Boot application |
| `domain/` | Framework-free domain model |
| `persistence/`, `messaging/` | Data access and Kafka modules |
| `docker/` | Compose configs, seed and baseline SQL |
| `docs/decisions/` | Architecture decision records |
| `docs/baselines/` | Measured baseline of the seeded database |
| `DONE.md` | The Definition of Done for every card |

## Author

Paul Webo

## License

TBD