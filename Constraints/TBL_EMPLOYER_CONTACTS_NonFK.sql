-- 
-- Non Foreign Key Constraints for Table TBL_EMPLOYER_CONTACTS 
-- 
ALTER TABLE OLIVER.TBL_EMPLOYER_CONTACTS ADD (
  CONSTRAINT TBL_EMPLOYER_CONTACTS_PK
  PRIMARY KEY
  (TEC_KEY)
  USING INDEX OLIVER.TBL_EMPLOYER_CONTACTS_PK
  ENABLE VALIDATE);

