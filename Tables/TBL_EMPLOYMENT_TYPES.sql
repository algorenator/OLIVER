--
-- TBL_EMPLOYMENT_TYPES  (Table) 
--
CREATE TABLE OLIVER.TBL_EMPLOYMENT_TYPES
(
  TET_CLIENT     VARCHAR2(20 BYTE),
  TET_PLAN       VARCHAR2(20 BYTE),
  TET_CODE       VARCHAR2(20 BYTE),
  TET_DESC       VARCHAR2(100 BYTE),
  TET_EFF_DATE   DATE,
  TET_TERM_DATE  DATE
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

