--
-- TBL_ANNUAL  (Table) 
--
CREATE TABLE OLIVER.TBL_ANNUAL
(
  ANN_ID         VARCHAR2(30 BYTE),
  ANN_PLAN       VARCHAR2(30 BYTE),
  ANN_YEAR       NUMBER,
  ANN_STATUS     VARCHAR2(30 BYTE),
  ANN_COMP       VARCHAR2(30 BYTE),
  ANN_EE_CONTS   NUMBER(12,2)                   DEFAULT 0,
  ANN_ER_CONTS   NUMBER(12,2)                   DEFAULT 0,
  ANN_EARNINGS   NUMBER(12,2)                   DEFAULT 0,
  ANN_HRS        NUMBER(12,2)                   DEFAULT 0,
  ANN_CRED_SERV  NUMBER(12,6)                   DEFAULT 0,
  ANN_PA         NUMBER(12,2)                   DEFAULT 0,
  ANN_PEN_VALUE  NUMBER(12,2)                   DEFAULT 0,
  ANN_LRD        DATE,
  ANN_CLIENT     VARCHAR2(20 BYTE),
  ANN_VOL_UNITS  NUMBER(12,2)                   DEFAULT 0,
  EE_INT         NUMBER(12,2)                   DEFAULT 0,
  ER_INT         NUMBER(12,2)                   DEFAULT 0,
  VOL_INT        NUMBER(12,2)                   DEFAULT 0,
  ANN_ACCOUNT    VARCHAR2(10 BYTE)
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


