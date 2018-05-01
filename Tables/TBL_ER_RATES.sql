--
-- TBL_ER_RATES  (Table) 
--
CREATE TABLE OLIVER.TBL_ER_RATES
(
  TER_ID        VARCHAR2(100 BYTE)              NOT NULL,
  TER_PLAN      VARCHAR2(10 BYTE)               NOT NULL,
  TER_EFF_DATE  DATE                            NOT NULL,
  TER_RATE      NUMBER(12,6)                    DEFAULT 0,
  TER_EE_RATE   NUMBER(12,6)                    DEFAULT 0,
  TER_HW_RATE   NUMBER(12,6)                    DEFAULT 0,
  TER_CLIENT    VARCHAR2(20 BYTE)               NOT NULL
)
TABLESPACE CDATV5DATAFILE
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


