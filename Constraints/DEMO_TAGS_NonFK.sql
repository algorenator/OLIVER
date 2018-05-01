-- 
-- Non Foreign Key Constraints for Table DEMO_TAGS 
-- 
ALTER TABLE OLIVER.DEMO_TAGS ADD (
  CONSTRAINT DEMO_TAGS_CK
  CHECK (content_type in ('CUSTOMER','ORDER','PRODUCT'))
  ENABLE VALIDATE);

ALTER TABLE OLIVER.DEMO_TAGS ADD (
  PRIMARY KEY
  (ID)
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

