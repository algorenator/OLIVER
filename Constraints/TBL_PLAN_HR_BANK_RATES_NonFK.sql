-- 
-- Non Foreign Key Constraints for Table TBL_PLAN_HR_BANK_RATES 
-- 
ALTER TABLE OLIVER.TBL_PLAN_HR_BANK_RATES ADD (
  CONSTRAINT PK_RATE
  PRIMARY KEY
  (PHBR_PLAN, PHBR_CLIENT_ID)
  USING INDEX OLIVER.PK_RATE
  ENABLE VALIDATE);

