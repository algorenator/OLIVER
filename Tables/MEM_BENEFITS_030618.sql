--
-- MEM_BENEFITS_030618  (Table) 
--
CREATE TABLE OLIVER.MEM_BENEFITS_030618
(
  BM_BEN_GROUP    VARCHAR2(30 BYTE),
  EMPLOYER        VARCHAR2(4000 BYTE),
  BM_BEN_TYPE     VARCHAR2(1 BYTE),
  CLIENT_ID       VARCHAR2(20 BYTE),
  PLAN_ID         VARCHAR2(20 BYTE),
  MEM_ID          VARCHAR2(100 BYTE)            NOT NULL,
  BEN_CLASS       VARCHAR2(100 BYTE),
  CODE            VARCHAR2(20 BYTE),
  BENDESC         VARCHAR2(1000 BYTE),
  MEM_LAST_NAME   VARCHAR2(100 BYTE),
  MEM_FIRST_NAME  VARCHAR2(100 BYTE),
  MEM_DOB         DATE,
  MEM_GENDER      VARCHAR2(1 BYTE),
  COVERGAE        VARCHAR2(4000 BYTE),
  BEN_BILL        NUMBER,
  HW_SMOKER       VARCHAR2(1 BYTE),
  CARRIER_RATE    NUMBER,
  ADMIN_RATE      NUMBER,
  AGENT_RATE      NUMBER,
  ADMIN_AMT       NUMBER
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


