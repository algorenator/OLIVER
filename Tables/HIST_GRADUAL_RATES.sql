--
-- HIST_GRADUAL_RATES  (Table) 
--
CREATE TABLE OLIVER.HIST_GRADUAL_RATES
(
  TGR_ER_ID               VARCHAR2(100 BYTE),
  TGR_CLIENT              VARCHAR2(20 BYTE),
  TGR_PLAN                VARCHAR2(10 BYTE),
  TGR_CLASS               VARCHAR2(10 BYTE),
  TGR_MTHS                NUMBER(6,2),
  TGR_EFF_DATE            DATE,
  TGR_ER_RRATE            NUMBER(12,6)          DEFAULT 0,
  TGR_EE_RATE             NUMBER(12,6)          DEFAULT 0,
  TGR_ACTION              VARCHAR2(20 BYTE),
  TGR_LAST_MODIFIED_BY    VARCHAR2(50 BYTE),
  TGR_LAST_MODIFIED_DATE  DATE
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


