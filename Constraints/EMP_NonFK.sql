-- 
-- Non Foreign Key Constraints for Table EMP 
-- 
ALTER TABLE OLIVER.EMP ADD (
  CONSTRAINT VALIDNAME
  CHECK (EName is not null)
  ENABLE VALIDATE);

ALTER TABLE OLIVER.EMP ADD (
  CONSTRAINT VALIDSALARY
  CHECK (Sal > 0)
  ENABLE VALIDATE);

ALTER TABLE OLIVER.EMP ADD (
  PRIMARY KEY
  (EMPNO)
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

