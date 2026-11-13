DO $$
DECLARE
  bad bigint;
  chk bigint;
BEGIN
  -- row counts
  IF (SELECT count(*) FROM events)      <> 300    THEN RAISE EXCEPTION 'events count wrong';      END IF;
  IF (SELECT count(*) FROM seats)       <> 600000 THEN RAISE EXCEPTION 'seats count wrong';       END IF;
  IF (SELECT count(*) FROM customers)   <> 50000  THEN RAISE EXCEPTION 'customers count wrong';   END IF;
  IF (SELECT count(*) FROM orders)      <> 500000 THEN RAISE EXCEPTION 'orders count wrong';      END IF;
  IF (SELECT count(*) FROM order_items) <> 500000 THEN RAISE EXCEPTION 'order_items count wrong'; END IF;

  -- every order item's seat belongs to the order's event
  SELECT count(*) INTO bad
  FROM order_items i
  JOIN orders o ON o.id = i.order_id
  JOIN seats  s ON s.id = i.seat_id
  WHERE s.event_id <> o.event_id;
  IF bad <> 0 THEN RAISE EXCEPTION 'order/seat event mismatch: % rows', bad; END IF;

  -- reproducibility
  SELECT sum(hashtext(id::text || customer_id::text || status)) INTO chk FROM orders;
  IF chk <> -173899215972 THEN
    RAISE EXCEPTION 'seed checksum changed: got %', chk;
  END IF;
END $$;