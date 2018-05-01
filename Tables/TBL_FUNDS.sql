--
-- TBL_FUNDS  (Table) 
--
CREATE TABLE OLIVER.TBL_FUNDS
(
  FUND_ID           NUMBER                      NOT NULL,
  FUND_NAME         VARCHAR2(50 BYTE),
  FUND_TAXABLE      VARCHAR2(1 BYTE)            DEFAULT 'N',
  FUND_EFFECT_DATE  DATE,
  FUND_TERM_DATE    DATE,
  FUND_DESC         VARCHAR2(150 BYTE),
  FUND_CLIENT       VARCHAR2(100 BYTE)          NOT NULL,
  FUND_PLAN         VARCHAR2(100 BYTE)          NOT NULL
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


