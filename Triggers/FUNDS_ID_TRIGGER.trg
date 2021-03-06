--
-- FUNDS_ID_TRIGGER  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.FUNDS_ID_TRIGGER BEFORE INSERT ON OLIVER.TBL_FUNDS
FOR EACH ROW
WHEN (
new."FUND_ID" IS NULL
      )
BEGIN
  SELECT FUNDS_SEQ.NEXTVAL 
  INTO :NEW."FUND_ID" 
  FROM dual;
END;
/


