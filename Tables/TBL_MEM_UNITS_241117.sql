--
-- TBL_MEM_UNITS_241117  (Table) 
--
CREATE TABLE OLIVER.TBL_MEM_UNITS_241117
(
  MPU_ID            VARCHAR2(100 BYTE),
  MPU_PLAN          VARCHAR2(10 BYTE),
  MPU_UNITS         NUMBER(12,2),
  MPU_FUND          VARCHAR2(30 BYTE),
  MPU_RATE          NUMBER(12,6),
  MPU_AMT           NUMBER(12,2),
  MPU_FROM          DATE,
  MPU_TO            DATE,
  MPU_PERIOD        DATE,
  MPU_ENTERED_DATE  DATE,
  MPU_EMPLOYER      VARCHAR2(100 BYTE),
  MPU_USER          VARCHAR2(60 BYTE),
  MU_BATCH          VARCHAR2(100 BYTE),
  MU_DESC           VARCHAR2(1000 BYTE),
  MU_CLIENT         VARCHAR2(20 BYTE),
  TRANS_TYPE        VARCHAR2(20 BYTE),
  UNITS_TYPE        VARCHAR2(20 BYTE),
  MU_EE_UNITS       NUMBER(12,2),
  MU_ER_UNITS       NUMBER(12,2),
  MU_VOL_UNITS      NUMBER(12,2),
  MU_RECD_DATE      DATE
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


