-- 
-- Non Foreign Key Constraints for Table TBL_HW_BENEFICIARY 
-- 
ALTER TABLE OLIVER.TBL_HW_BENEFICIARY ADD (
  CONSTRAINT TBL_HW_BEN_PK1
  PRIMARY KEY
  (HB_KEY)
  USING INDEX OLIVER.TBL_HW_BEN_PK1
  ENABLE VALIDATE);

