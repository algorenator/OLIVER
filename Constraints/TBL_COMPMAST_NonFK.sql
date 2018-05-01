-- 
-- Non Foreign Key Constraints for Table TBL_COMPMAST 
-- 
ALTER TABLE OLIVER.TBL_COMPMAST ADD (
  PRIMARY KEY
  (CO_CLIENT, CO_PLAN, CO_NUMBER, CO_DIV)
  USING INDEX
    TABLESPACE USERS
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

