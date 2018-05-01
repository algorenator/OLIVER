--
-- TBL_EMPLOYER_FUND_RATES  (Table) 
--
CREATE TABLE OLIVER.TBL_EMPLOYER_FUND_RATES
(
  PFR_CLIENT_ID  VARCHAR2(100 BYTE)             NOT NULL,
  PFR_PLAN_ID    VARCHAR2(100 BYTE)             NOT NULL,
  PFR_EMPLOYER   VARCHAR2(100 BYTE)             NOT NULL,
  PFR_FUND_ID    NUMBER                         NOT NULL,
  PFR_EFF_DATE   DATE                           NOT NULL,
  PFR_RATE       NUMBER(12,6)                   DEFAULT 0,
  PFR_CLIENT     VARCHAR2(20 BYTE)
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


