-- 
-- Non Foreign Key Constraints for Table DEMO_ORDERS 
-- 
ALTER TABLE OLIVER.DEMO_ORDERS ADD (
  CONSTRAINT DEMO_ORDER_TOTAL_MIN
  CHECK (order_total >= 0)
  ENABLE VALIDATE);

ALTER TABLE OLIVER.DEMO_ORDERS ADD (
  CONSTRAINT DEMO_ORDER_PK
  PRIMARY KEY
  (ORDER_ID)
  USING INDEX OLIVER.DEMO_ORDER_PK
  ENABLE VALIDATE);

