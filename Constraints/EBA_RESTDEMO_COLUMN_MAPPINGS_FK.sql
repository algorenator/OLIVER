-- 
-- Foreign Key Constraints for Table EBA_RESTDEMO_COLUMN_MAPPINGS 
-- 
ALTER TABLE OLIVER.EBA_RESTDEMO_COLUMN_MAPPINGS ADD (
  CONSTRAINT EBA_RESTDEMO_FK1_SERVICEID 
  FOREIGN KEY (SERVICE_ID) 
  REFERENCES OLIVER.EBA_RESTDEMO_SERVICES (ID)
  ON DELETE CASCADE
  ENABLE VALIDATE);
