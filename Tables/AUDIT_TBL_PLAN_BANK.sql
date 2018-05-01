--
-- AUDIT_TBL_PLAN_BANK  (Table) 
--
CREATE TABLE OLIVER.AUDIT_TBL_PLAN_BANK
(
  TPB_CLIENT     VARCHAR2(20 BYTE)              NOT NULL,
  TPB_PLAN       VARCHAR2(20 BYTE)              NOT NULL,
  TPB_SUB_PLAN   VARCHAR2(20 BYTE),
  TPB_EFF_DATE   DATE,
  TPB_TRANSIT    NUMBER,
  TPB_BRANCH     NUMBER,
  TPB_ACCOUNT    NUMBER,
  TPB_PLAN_TYPE  VARCHAR2(100 BYTE)             NOT NULL,
  AUDIT_ACTION   CHAR(1 BYTE),
  AUDIT_BY       VARCHAR2(2000 BYTE),
  AUDIT_AT       TIMESTAMP(6)
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


