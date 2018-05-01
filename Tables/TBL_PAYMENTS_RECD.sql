--
-- TBL_PAYMENTS_RECD  (Table) 
--
CREATE TABLE OLIVER.TBL_PAYMENTS_RECD
(
  TPR_CLIENT_ID       VARCHAR2(20 BYTE),
  TPR_PLAN_ID         VARCHAR2(20 BYTE),
  TPR_ER_ID           VARCHAR2(30 BYTE),
  TPR_EE_ID           VARCHAR2(30 BYTE),
  TPR_RECD_DATE       DATE,
  TPR_PAYMENT_TYPE    VARCHAR2(20 BYTE),
  TPR_PAYMENT_NUMBER  VARCHAR2(100 BYTE),
  TPR_PAYMENT_DATE    DATE,
  TPR_PAYMENT_AMT     NUMBER(12,2)              DEFAULT 0,
  TPR_COMMENT         VARCHAR2(3000 BYTE),
  TPR_USER            VARCHAR2(100 BYTE)
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


