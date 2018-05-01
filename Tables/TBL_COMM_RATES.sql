--
-- TBL_COMM_RATES  (Table) 
--
CREATE TABLE OLIVER.TBL_COMM_RATES
(
  CLIENT_ID    VARCHAR2(20 BYTE),
  PLAN_ID      VARCHAR2(20 BYTE),
  FINDERS_FEE  NUMBER,
  OTHER_FEE    NUMBER,
  COMM_TYPE    VARCHAR2(20 BYTE),
  COMM_FEE     VARCHAR2(20 BYTE)
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


