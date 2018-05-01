--
-- TBL_BENEFITS_MASTER  (Table) 
--
CREATE TABLE OLIVER.TBL_BENEFITS_MASTER
(
  BM_CODE           VARCHAR2(10 BYTE)           NOT NULL,
  BM_DESC           VARCHAR2(1000 BYTE),
  BM_PLAN           VARCHAR2(10 BYTE)           NOT NULL,
  BM_EFF_DATE       DATE                        NOT NULL,
  BM_CLIENT_ID      VARCHAR2(20 BYTE)           NOT NULL,
  BM_BEN_TYPE       VARCHAR2(1 BYTE),
  BM_TERM_DATE      DATE,
  BM_COVERAGE_TYPE  VARCHAR2(10 BYTE),
  BM_ID             NUMBER,
  BM_CARRIER        VARCHAR2(100 BYTE),
  BM_POLICY         VARCHAR2(100 BYTE),
  BM_BEN_GROUP      VARCHAR2(30 BYTE)
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


