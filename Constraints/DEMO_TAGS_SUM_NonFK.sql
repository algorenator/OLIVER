-- 
-- Non Foreign Key Constraints for Table DEMO_TAGS_SUM 
-- 
ALTER TABLE OLIVER.DEMO_TAGS_SUM ADD (
  CONSTRAINT DEMO_TAGS_SUM_PK
  PRIMARY KEY
  (TAG)
  USING INDEX OLIVER.DEMO_TAGS_SUM_PK
  ENABLE VALIDATE);
