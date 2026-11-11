#!/usr/bin/env bash
set -euo pipefail

LABEL="${1:-warm}"                      # e.g. cold, warm, no-index
README="docs/baselines/README.md"
RAW="docs/baselines/db-baseline-${LABEL}.txt"
mkdir -p docs/baselines

docker compose exec -T postgres psql -U ticketo -d ticketo -v ON_ERROR_STOP=1 \
  -f - < docker/postgres/baseline.sql > "$RAW"

PGVER=$(docker compose exec -T postgres postgres --version | tr -d '\r')

{
  echo
  echo "### Run: ${LABEL} ($(date '+%Y-%m-%d %H:%M'))"
  echo
  echo "_${PGVER}, raw output: \`${RAW##*/}\`_"
  echo
  echo "| Query | Plan nodes | Execution ms | > 200 ms? |"
  echo "|---|---|---|---|"
  awk '
    function add(t) { if (index(plan, t) == 0) plan = plan (plan ? ", " : "") t }
    function flush() {
      if (name != "")
        printf "| %s | %s | %s | %s |\n", name, (plan == "" ? "-" : plan), ms, (ms + 0 > 200 ? "YES" : "no")
    }
    /^--- /            { flush(); name = substr($0, 5); plan = ""; ms = ""; next }
    /Seq Scan/         { add("Seq Scan") }
    /Index Only Scan/  { add("Index Only Scan") }
    /Index Scan/       { add("Index Scan") }
    /Bitmap Heap Scan/ { add("Bitmap Scan") }
    /Execution Time:/  { ms = $3 }
    END                { flush() }
  ' "$RAW"
} >> "$README"

echo "Appended '${LABEL}' results to $README"