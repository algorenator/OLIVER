--
-- TBL_HR_BANK  (Table) 
--
CREATE TABLE OLIVER.TBL_HR_BANK
(
  THB_ID             VARCHAR2(100 BYTE)         NOT NULL,
  THB_PLAN           VARCHAR2(10 BYTE),
  THB_FROM_DATE      DATE,
  THB_TO_DATE        DATE,
  THB_MONTH          DATE,
  THB_HOURS          NUMBER(12,2)               DEFAULT 0,
  THB_DEDUCT_HRS     NUMBER(12,2)               DEFAULT 0,
  THB_CLOSING_HRS    NUMBER(12,2)               DEFAULT 0,
  THB_POSTED_DATE    DATE,
  THB_EMPLOYER       VARCHAR2(100 BYTE),
  THB_MODIFIED_BY    VARCHAR2(100 BYTE),
  THB_MODIFIED_DATE  DATE,
  THB_FUND_CODE      VARCHAR2(100 BYTE),
  THB_CLIENT_ID      VARCHAR2(20 BYTE)
)
TABLESPACE USERS
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


