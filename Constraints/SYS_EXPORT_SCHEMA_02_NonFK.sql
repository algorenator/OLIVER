-- 
-- Non Foreign Key Constraints for Table SYS_EXPORT_SCHEMA_02 
-- 
ALTER TABLE OLIVER.SYS_EXPORT_SCHEMA_02 ADD (
  UNIQUE (PROCESS_ORDER, DUPLICATE)
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

