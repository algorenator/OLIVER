--
-- MACHINIST_DEMO_TEST  (Table) 
--
CREATE TABLE OLIVER.MACHINIST_DEMO_TEST
(
  MTH                DATE,
  TYPE1              VARCHAR2(100 BYTE),
  CREDITED_HOURS     NUMBER(12,2)               DEFAULT 0,
  CONTRIBUTION_RATE  NUMBER(12,6)               DEFAULT 0,
  CONTRIBUTIONS      NUMBER(12,2)               DEFAULT 0
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


