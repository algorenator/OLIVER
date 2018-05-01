--
-- CONT_INT_RATES  (Table) 
--
CREATE TABLE OLIVER.CONT_INT_RATES
(
  EIR_EFF_DATE  DATE,
  EIR_RATE      NUMBER(9,6),
  EIR_CLIENT    VARCHAR2(20 BYTE),
  EIR_PLAN      VARCHAR2(20 BYTE)
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


