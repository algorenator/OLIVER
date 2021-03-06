--
-- TBL_EMPLOYER_HR_BANK_RATES  (Table) 
--
CREATE TABLE OLIVER.TBL_EMPLOYER_HR_BANK_RATES
(
  EHBR_PLAN           VARCHAR2(10 BYTE)         NOT NULL,
  ENBR_EMPLOYER       VARCHAR2(100 BYTE)        NOT NULL,
  EHBR_EFF_DATE       DATE                      NOT NULL,
  EHBR_MIN_HRS        NUMBER(12,2)              DEFAULT 0,
  EHBR_MAX_HRS        NUMBER(12,2)              DEFAULT 0,
  EHBR_MONTHLY_HRS    NUMBER(12,2)              DEFAULT 0,
  EHBR_SELF_PAY_MTHS  NUMBER,
  PH_FORFEIT_MTHS     NUMBER,
  EHBR_DIV            VARCHAR2(10 BYTE),
  EHB_CLIENT_ID       VARCHAR2(20 BYTE)
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


