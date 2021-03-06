--
-- TBL_PEN_OPT_HEADER  (Table) 
--
CREATE TABLE OLIVER.TBL_PEN_OPT_HEADER
(
  TPH_CLIENT        VARCHAR2(20 BYTE),
  TPH_PLAN          VARCHAR2(20 BYTE),
  TPH_MEM_ID        VARCHAR2(30 BYTE),
  TPH_RET_DATE      DATE,
  TPH_OAS_AMT       NUMBER(12,2),
  TPH_CPP_AMT       NUMBER(12,2),
  TPH_RED_AMT       NUMBER(12,6),
  TPH_RET_TYPE      VARCHAR2(10 BYTE),
  TPH_NORM_FORM     VARCHAR2(20 BYTE),
  TPH_MEM_AGE       NUMBER(12,6),
  TPH_SP_AGE        NUMBER(12,6),
  TPH_CALC_DATE     DATE,
  TPH_CREATE_BY     VARCHAR2(100 BYTE),
  TPH_CREATED_DATE  DATE
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


