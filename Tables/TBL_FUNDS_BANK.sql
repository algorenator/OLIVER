--
-- TBL_FUNDS_BANK  (Table) 
--
CREATE TABLE OLIVER.TBL_FUNDS_BANK
(
  FUND_ID       NUMBER,
  FUND_TRANSIT  NUMBER,
  FUND_BRANCH   NUMBER,
  FUND_ACCOUNT  VARCHAR2(100 BYTE)
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


