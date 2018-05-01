--
-- TBL_HW_EMPLOYER_RATES  (Table) 
--
CREATE TABLE OLIVER.TBL_HW_EMPLOYER_RATES
(
  HER_ID        VARCHAR2(100 BYTE)              NOT NULL,
  HER_PLAN      VARCHAR2(10 BYTE)               NOT NULL,
  HER_EFF_DATE  DATE                            NOT NULL,
  HER_BENEFIT   VARCHAR2(100 BYTE)              NOT NULL,
  HER_RATE_ER   NUMBER(12,6),
  HER_RATE_EE   NUMBER(12,6),
  HER_DIV       VARCHAR2(10 BYTE)
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


