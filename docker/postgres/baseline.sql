\echo '--- Q1 upcoming events list'
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM events WHERE starts_at > now() ORDER BY starts_at LIMIT 20;

\echo '--- Q2 seat map for one event'
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, section, row_label, seat_number, status, price_cents
FROM seats WHERE event_id = 7;

\echo '--- Q3 availability summary for one event'
EXPLAIN (ANALYZE, BUFFERS)
SELECT status, count(*) FROM seats WHERE event_id = 7 GROUP BY status;

\echo '--- Q4 order history for one customer'
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders WHERE customer_id = 42 ORDER BY created_at DESC LIMIT 20;

\echo '--- Q5 order history with items (the N+1 shape, as one join)'
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.id, o.status, i.seat_id, i.price_cents
FROM orders o JOIN order_items i ON i.order_id = o.id
WHERE o.customer_id = 42;

\echo '--- Q6 offset pagination, deep page (this will hurt in TIX-209)'
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders WHERE event_id = 77 ORDER BY id OFFSET 1500 LIMIT 20;

\echo '--- Q7 revenue per event (full scan)'
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, sum(total_cents) FROM orders WHERE status = 'PAID' GROUP BY event_id;

\echo '--- Q8 unindexed filter'
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM orders WHERE status = 'REFUNDED' AND created_at > now() - interval '1 year';