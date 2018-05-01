-- 
-- Foreign Key Constraints for Table TBL_DOCUMENT_REPO 
-- 
ALTER TABLE OLIVER.TBL_DOCUMENT_REPO ADD (
  CONSTRAINT TBL_DOCUMENT_REPO_FK1 
  FOREIGN KEY (DOCUMENT_REPO_TYPE_ID) 
  REFERENCES OLIVER.TBL_DOCUMENT_REPO_TYPE (DOCUMENT_REPO_TYPE_ID)
  ENABLE VALIDATE);

