-- 
-- Foreign Key Constraints for Table EBA_RESTDEMO_URLPARAMETERS 
-- 
ALTER TABLE OLIVER.EBA_RESTDEMO_URLPARAMETERS ADD (
  CONSTRAINT EBA_RESTDEMO_FK3_SERVICEID 
  FOREIGN KEY (SERVICE_ID) 
  REFERENCES OLIVER.EBA_RESTDEMO_SERVICES (ID)
  ON DELETE CASCADE
  ENABLE VALIDATE);

