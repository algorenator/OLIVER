--
-- JEFF_TEST_LOAD  (Table) 
--
CREATE TABLE OLIVER.JEFF_TEST_LOAD
(
  MEMID  NUMBER,
  HOURS  NUMBER,
  JOB    VARCHAR2(20 BYTE),
  KEY    NUMBER
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


