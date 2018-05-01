--
-- TRANSACTION_DETAIL_MACH_OLD  (Table) 
--
CREATE TABLE OLIVER.TRANSACTION_DETAIL_MACH_OLD
(
  TD_TRAN_ID       VARCHAR2(15 BYTE),
  TD_EMPLOYER      VARCHAR2(100 BYTE),
  TD_PLAN_ID       VARCHAR2(15 BYTE),
  TD_START_DATE    DATE,
  TD_END_DATE      DATE,
  TD_PERIOD        DATE,
  TD_UNITS         NUMBER(12,2),
  TD_AMOUNT        NUMBER(12,2),
  TD_COMMENT       VARCHAR2(3000 BYTE),
  TD_USER          VARCHAR2(100 BYTE),
  TD_DATE_TIME     DATE,
  TD_MEM_ID        VARCHAR2(15 BYTE)            NOT NULL,
  TD_KEY           NUMBER,
  TD_POSTED_DATE   DATE,
  TD_POSTED_USER   VARCHAR2(100 BYTE),
  TDT_PEN_UNITS    NUMBER(12,2),
  TDT_FUNDS_UNITS  NUMBER(12,2),
  TD_CLIENT_ID     VARCHAR2(20 BYTE),
  TDT_EE_UNITS     NUMBER(12,2),
  TDT_ER_UNITS     NUMBER(12,2),
  TD_UNITS_TYPE    VARCHAR2(3 BYTE),
  TD_OCCU          VARCHAR2(100 BYTE),
  TD_RATE          NUMBER(12,6),
  TD_EARNINGS      NUMBER(12,2),
  TD_VOL_UNITS     NUMBER(12,2),
  TD_HRS           NUMBER(12,2),
  TD_ER_RATE       NUMBER(12,2),
  TD_EE_RATE       NUMBER(12,2),
  TD_MEM_SIN       NUMBER(9),
  TD_EE_ACCOUNT    VARCHAR2(10 BYTE),
  TD_ER_ACCOUNT    VARCHAR2(10 BYTE),
  TD_VOL_ACCOUNT   VARCHAR2(10 BYTE)
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

