-- 
-- Non Foreign Key Constraints for Table TBL_DOCUMENT_REPO 
-- 
ALTER TABLE OLIVER.TBL_DOCUMENT_REPO ADD (
  CONSTRAINT TBL_DOCUMENT_REPO_PK
  PRIMARY KEY
  (DOCUMENT_REPO_ID)
  USING INDEX OLIVER.TBL_DOCUMENT_REPO_PK
  ENABLE VALIDATE);

ALTER TABLE OLIVER.TBL_DOCUMENT_REPO ADD (
  CONSTRAINT TBL_DOCUMENT_REPO_UN1
  UNIQUE (DOCUMENT_REPO_TYPE_ID, FILE_NAME)
  USING INDEX OLIVER.TBL_DOCUMENT_REPO_UN1
  ENABLE VALIDATE);
