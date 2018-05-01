--
-- TBL_CONTMAST_HW  (Table) 
--
CREATE TABLE OLIVER.TBL_CONTMAST_HW
(
  TCH_ID                  VARCHAR2(100 BYTE),
  TCH_PLAN                VARCHAR2(10 BYTE)     DEFAULT 'A',
  TCH_BATCH_NO            NUMBER,
  TCH_MONTH               DATE,
  TCH_STRAT_DATE          DATE,
  TCH_END_DATE            DATE,
  TCH_POSTED_DATE         DATE,
  TCH_CHEQUE_NO           VARCHAR2(100 BYTE),
  TCH_DESC                VARCHAR2(1000 BYTE),
  TCH_METHOD              VARCHAR2(1 BYTE),
  TCH_HOURS_SUBMITTED     NUMBER(12,2)          DEFAULT 0,
  TCH_MILES_SUBMITTED     NUMBER(12,2)          DEFAULT 0,
  TCH_EARNINGS_SUBMITTED  NUMBER(12,2)          DEFAULT 0,
  TCH_EE_CONTS_SUBMITTED  NUMBER(12,2)          DEFAULT 0,
  TCH_ER_CONTS_SUBMITTED  NUMBER(12,2)          DEFAULT 0,
  TCH_RATE                NUMBER(12,6)          DEFAULT 0,
  TCH_AMOUNT_SUBMITTED    NUMBER(12,2)          DEFAULT 0,
  TCH_TYPE                VARCHAR2(1 BYTE)      DEFAULT '.',
  TCH_REMITTED            VARCHAR2(1 BYTE)      DEFAULT 'N',
  TCH_DIV                 VARCHAR2(10 BYTE)     DEFAULT '00'
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


