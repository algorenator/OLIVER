-- 
-- Non Foreign Key Constraints for Table TBL_DOCUMENT_REPO_TYPE 
-- 
ALTER TABLE OLIVER.TBL_DOCUMENT_REPO_TYPE ADD (
  CONSTRAINT DOCUMENT_REPO_TYPE_ID_PK
  PRIMARY KEY
  (DOCUMENT_REPO_TYPE_ID)
  USING INDEX OLIVER.DOCUMENT_REPO_TYPE_ID_PK
  ENABLE VALIDATE);

ALTER TABLE OLIVER.TBL_DOCUMENT_REPO_TYPE ADD (
  CONSTRAINT TBL_DOCUMENT_REPO_TYPE_UN1
  UNIQUE (NAME)
  USING INDEX OLIVER.TBL_DOCUMENT_REPO_TYPE_UN1
  ENABLE VALIDATE);

