--
-- TBL_EMPLOYER_AGREEMENTS_160118  (Table) 
--
CREATE TABLE OLIVER.TBL_EMPLOYER_AGREEMENTS_160118
(
  TEA_CLT_ID        VARCHAR2(20 BYTE),
  TEA_PLAN_ID       VARCHAR2(20 BYTE),
  TEA_ER_ID         VARCHAR2(100 BYTE),
  TEA_AGREEMENT_ID  VARCHAR2(20 BYTE),
  TEA_EFF_DATE      DATE,
  TEA_TERM_DATE     DATE,
  TEA_CREATED_BY    VARCHAR2(100 BYTE),
  TEA_CREATED_DATE  DATE,
  TEA_ID            NUMBER,
  IS_DELETED        VARCHAR2(1 BYTE)
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


