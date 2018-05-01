-- 
-- Non Foreign Key Constraints for Table DEMO_TAGS_TYPE_SUM 
-- 
ALTER TABLE OLIVER.DEMO_TAGS_TYPE_SUM ADD (
  CONSTRAINT DEMO_TAGS_TYPE_SUM_PK
  PRIMARY KEY
  (TAG, CONTENT_TYPE)
  USING INDEX OLIVER.DEMO_TAGS_TYPE_SUM_PK
  ENABLE VALIDATE);

