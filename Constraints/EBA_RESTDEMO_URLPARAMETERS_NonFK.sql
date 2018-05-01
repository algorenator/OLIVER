-- 
-- Non Foreign Key Constraints for Table EBA_RESTDEMO_URLPARAMETERS 
-- 
ALTER TABLE OLIVER.EBA_RESTDEMO_URLPARAMETERS ADD (
  CONSTRAINT EBA_RESTDEMO_CK_URLPARAM_ACT
  CHECK ( param_active in ( 'Y', 'N' ) )
  ENABLE VALIDATE);

ALTER TABLE OLIVER.EBA_RESTDEMO_URLPARAMETERS ADD (
  CONSTRAINT EBA_RESTDEMO_URLPARAMS_PK
  PRIMARY KEY
  (ID)
  USING INDEX OLIVER.EBA_RESTDEMO_URLPARAMS_PK
  ENABLE VALIDATE);

