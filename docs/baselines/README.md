
### Run: warm (2026-11-11 16:38)

_postgres (PostgreSQL) 18.6 (Debian 18.6-1.pgdg13+2), raw output: `db-baseline-warm.txt`_

| Query | Plan nodes | Execution ms | > 200 ms? |
|---|---|---|---|
| Q1 upcoming events list | Seq Scan | 0.970 | no |
| Q2 seat map for one event | Bitmap Scan, Index Scan | 134.516 | no |
| Q3 availability summary for one event | Bitmap Scan, Index Scan | 3.021 | no |
| Q4 order history for one customer | Bitmap Scan, Index Scan | 8.625 | no |
| Q5 order history with items (the N+1 shape, as one join) | Bitmap Scan, Index Scan | 20.605 | no |
| Q6 offset pagination, deep page (this will hurt in TIX-209) | Bitmap Scan, Index Scan | 109.297 | no |
| Q7 revenue per event (full scan) | Seq Scan | 107.452 | no |
| Q8 unindexed filter | Seq Scan | 45.997 | no |

### Run: COLD (2026-11-11 19:38)

_postgres (PostgreSQL) 18.6 (Debian 18.6-1.pgdg13+2), raw output: `db-baseline-COLD.txt`_

| Query | Plan nodes | Execution ms | > 200 ms? |
|---|---|---|---|
| Q1 upcoming events list | Seq Scan | 1.600 | no |
| Q2 seat map for one event | Bitmap Scan, Index Scan | 166.223 | no |
| Q3 availability summary for one event | Bitmap Scan, Index Scan | 2.883 | no |
| Q4 order history for one customer | Bitmap Scan, Index Scan | 11.057 | no |
| Q5 order history with items (the N+1 shape, as one join) | Bitmap Scan, Index Scan | 26.714 | no |
| Q6 offset pagination, deep page (this will hurt in TIX-209) | Bitmap Scan, Index Scan | 130.814 | no |
| Q7 revenue per event (full scan) | Seq Scan | 115.375 | no |
| Q8 unindexed filter | Seq Scan | 48.685 | no |

### Run: WARM (2026-11-11 19:40)

_postgres (PostgreSQL) 18.6 (Debian 18.6-1.pgdg13+2), raw output: `db-baseline-WARM.txt`_

| Query | Plan nodes | Execution ms | > 200 ms? |
|---|---|---|---|
| Q1 upcoming events list | Seq Scan | 0.085 | no |
| Q2 seat map for one event | Bitmap Scan, Index Scan | 2.939 | no |
| Q3 availability summary for one event | Bitmap Scan, Index Scan | 2.205 | no |
| Q4 order history for one customer | Bitmap Scan, Index Scan | 0.041 | no |
| Q5 order history with items (the N+1 shape, as one join) | Bitmap Scan, Index Scan | 0.090 | no |
| Q6 offset pagination, deep page (this will hurt in TIX-209) | Bitmap Scan, Index Scan | 2.933 | no |
| Q7 revenue per event (full scan) | Seq Scan | 95.484 | no |
| Q8 unindexed filter | Seq Scan | 40.484 | no |
