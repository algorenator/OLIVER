--
-- TBL_AGREEMENT_DETAILS_160118  (Table) 
--
CREATE TABLE OLIVER.TBL_AGREEMENT_DETAILS_160118
(
  TAD_AGREE_ID    VARCHAR2(20 BYTE),
  TAD_ER_ID       VARCHAR2(20 BYTE),
  TAD_OCCUP_ID    VARCHAR2(20 BYTE),
  TAD_YEAR_ID     VARCHAR2(20 BYTE),
  TAD_EFF_DATE    DATE,
  TAD_UNIT_TYPE   VARCHAR2(20 BYTE),
  TAD_RATE        NUMBER,
  TAD_CLIENT_ID   VARCHAR2(20 BYTE),
  TAD_PLAN_ID     VARCHAR2(20 BYTE),
  TAD_FUND        VARCHAR2(30 BYTE),
  TAD_EE_PORTION  NUMBER(12,6),
  TAD_ER_PORTION  NUMBER(12,6)
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


