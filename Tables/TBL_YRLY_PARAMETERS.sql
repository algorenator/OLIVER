--
-- TBL_YRLY_PARAMETERS  (Table) 
--
CREATE TABLE OLIVER.TBL_YRLY_PARAMETERS
(
  TYP_CLIENT      VARCHAR2(20 BYTE),
  TYP_PLAN        VARCHAR2(20 BYTE),
  TYP_YEAR        DATE,
  TYP_SALARY_CAP  NUMBER(12,2)                  DEFAULT 0,
  TYP_DB_LIMIT    NUMBER(12,2)                  DEFAULT 0,
  RRSP_LIMIT      NUMBER(12,2)                  DEFAULT 0,
  DPSP_LIMIT      NUMBER(12,2)                  DEFAULT 0,
  CONTRIB_CAP     NUMBER(12,2)
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


