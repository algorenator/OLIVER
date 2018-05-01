-- 
-- Non Foreign Key Constraints for Table DEMO_CONSTRAINT_LOOKUP 
-- 
ALTER TABLE OLIVER.DEMO_CONSTRAINT_LOOKUP ADD (
  PRIMARY KEY
  (CONSTRAINT_NAME)
  USING INDEX
    TABLESPACE CDATV5DATAFILE
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
  ENABLE VALIDATE);

