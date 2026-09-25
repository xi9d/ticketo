1. The feature runs against the full seeded dataset, not a toy fixture.
2. The deliberate failure was reproduced and observed in a log, a metric, a trace or a flame graph.
3. An automated check exists that fails if the failure returns, and it runs in CI.
4. Any non-obvious decision has a one-page ADR in /docs/decisions naming the alternative you rejected.
5. Anything measured has its numbers written down, not just its conclusion.
6. If it surprised you, it is in a note by the end of the day.
