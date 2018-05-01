-- 
-- Non Foreign Key Constraints for Table TBL_PLAN 
-- 
ALTER TABLE OLIVER.TBL_PLAN ADD (
  CONSTRAINT TBL_PLAN_PK
  PRIMARY KEY
  (PL_CLIENT_ID, PL_ID, PL_TYPE)
  USING INDEX OLIVER.TBL_PLAN_PK
  ENABLE VALIDATE);
