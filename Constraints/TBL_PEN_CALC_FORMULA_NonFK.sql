-- 
-- Non Foreign Key Constraints for Table TBL_PEN_CALC_FORMULA 
-- 
ALTER TABLE OLIVER.TBL_PEN_CALC_FORMULA ADD (
  CONSTRAINT TBL_PEN_CALC_FORMULA_PK
  PRIMARY KEY
  (TPCF_CLIENT, TPCF_PLAN, TPCF_EFF_DATE)
  USING INDEX OLIVER.TBL_PEN_CALC_FORMULA_PK
  ENABLE VALIDATE);

