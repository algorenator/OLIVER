-- 
-- Non Foreign Key Constraints for Table TBL_FUNDS 
-- 
ALTER TABLE OLIVER.TBL_FUNDS ADD (
  CONSTRAINT TBL_FUNDS_PK
  PRIMARY KEY
  (FUND_CLIENT, FUND_PLAN, FUND_ID)
  USING INDEX OLIVER.TBL_FUNDS_PK
  ENABLE VALIDATE);
