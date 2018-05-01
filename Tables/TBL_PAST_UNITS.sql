--
-- TBL_PAST_UNITS  (Table) 
--
CREATE TABLE OLIVER.TBL_PAST_UNITS
(
  TPU_ID            VARCHAR2(100 BYTE),
  TPU_PLAN          VARCHAR2(10 BYTE),
  TPU_UNITS         NUMBER(12,2)                DEFAULT 0,
  TPU_FUND          VARCHAR2(30 BYTE)           DEFAULT 'PEN',
  TPU_RATE          NUMBER(12,6)                DEFAULT 0,
  TPU_AMT           NUMBER(12,2)                DEFAULT 0,
  TPU_FROM          DATE,
  TPU_TO            DATE,
  TPU_PERIOD        DATE,
  TPU_ENTERED_DATE  DATE,
  TPU_EMPLOYER      VARCHAR2(100 BYTE),
  TPU_USER          VARCHAR2(60 BYTE),
  TPU_BATCH         VARCHAR2(100 BYTE),
  TPU_DESC          VARCHAR2(1000 BYTE),
  TPU_CLIENT        VARCHAR2(20 BYTE),
  TPU_TRANS_TYPE    VARCHAR2(20 BYTE),
  TPU_UNITS_TYPE    VARCHAR2(20 BYTE),
  TPU_EE_UNITS      NUMBER(12,2)                DEFAULT 0,
  TPU_ER_UNITS      NUMBER(12,2)                DEFAULT 0,
  TPU_VOL_UNITS     NUMBER(12,2)                DEFAULT 0,
  TPU_RECD_DATE     DATE
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


