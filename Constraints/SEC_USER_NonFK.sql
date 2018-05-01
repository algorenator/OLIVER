-- 
-- Non Foreign Key Constraints for Table SEC_USER 
-- 
ALTER TABLE OLIVER.SEC_USER ADD (
  PRIMARY KEY
  (ID)
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

ALTER TABLE OLIVER.SEC_USER ADD (
  CONSTRAINT UQ_SEC_USER_1
  UNIQUE (USER_NAME)
  USING INDEX OLIVER.UQ_SEC_USER_1
  ENABLE VALIDATE);

