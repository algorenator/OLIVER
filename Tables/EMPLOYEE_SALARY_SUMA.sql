--
-- EMPLOYEE_SALARY_SUMA  (Table) 
--
CREATE TABLE OLIVER.EMPLOYEE_SALARY_SUMA
(
  ID           VARCHAR2(9 BYTE),
  EFF_DATE     DATE,
  SALARY       NUMBER(12,2),
  UPDATE_BY    VARCHAR2(100 BYTE),
  UPDATE_DATE  DATE
)
TABLESPACE USERS
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
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
NOCOMPRESS ;


