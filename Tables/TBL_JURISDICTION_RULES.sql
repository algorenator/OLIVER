--
-- TBL_JURISDICTION_RULES  (Table) 
--
CREATE TABLE OLIVER.TBL_JURISDICTION_RULES
(
  TJR_PROV                 VARCHAR2(10 BYTE),
  TJR_EFF_DATE             DATE,
  TJR_ELIG_MIN_MTHS        NUMBER,
  TJR_VEST_LOCKED_MTHS     NUMBER,
  TJR_VESTING_AT_NRD       DATE,
  TJR_MIN_ER_CONTS         NUMBER(12,2),
  TJR_EXCESS_EE_CONTS      NUMBER(12,2),
  TJR_MIN_EE_CONTS_INT     NUMBER(12,6),
  TJR_PORT_TERMI_EMPL      VARCHAR2(100 BYTE),
  TJR_NRD_AGE              NUMBER,
  TJR_ERD_AGE              NUMBER,
  TJR_POSTPONE_PEN_CREDIT  VARCHAR2(1 BYTE)     DEFAULT 'N',
  TJR_INTEGRATION_ALLOWED  VARCHAR2(1 BYTE)     DEFAULT 'N',
  TJR_INDEING_PERCENT      NUMBER(12,2)         DEFAULT 0,
  TJR_AIR_REQD             VARCHAR2(1 BYTE)     DEFAULT 'Y',
  TJR_AIR_MTHS             NUMBER,
  TJR_PEN_PERCENT          NUMBER(12,6)         DEFAULT 0,
  TJR_CV_PERCENT           NUMBER(12,6)         DEFAULT 0
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


