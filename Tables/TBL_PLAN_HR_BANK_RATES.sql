--
-- TBL_PLAN_HR_BANK_RATES  (Table) 
--
CREATE TABLE OLIVER.TBL_PLAN_HR_BANK_RATES
(
  PHBR_PLAN           VARCHAR2(10 BYTE)         NOT NULL,
  PHBR_EFF_DATE       DATE                      NOT NULL,
  PHBR_MIN_HRS        NUMBER(12,2)              DEFAULT 0,
  PHBR_MAX_HRS        NUMBER(12,2)              DEFAULT 0,
  PHBR_MONTHLY_HRS    NUMBER(12,2)              DEFAULT 0,
  PHBR_SELF_PAY_MTHS  NUMBER,
  PH_FORFEIT_MTHS     NUMBER,
  PHBR_CLIENT_ID      VARCHAR2(20 BYTE),
  PHBR_TOPUP_ALLOWED  VARCHAR2(1 BYTE)          DEFAULT 'N',
  PHBR_KEY            NUMBER
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


