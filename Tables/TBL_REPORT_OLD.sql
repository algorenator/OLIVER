--
-- TBL_REPORT_OLD  (Table) 
--
CREATE TABLE OLIVER.TBL_REPORT_OLD
(
  REPORT_ID    NUMBER                           NOT NULL,
  PLAN_ID      VARCHAR2(10 BYTE),
  CATEGORY     VARCHAR2(100 BYTE),
  REPORT_NAME  VARCHAR2(100 BYTE),
  DESCRIPTION  VARCHAR2(255 BYTE),
  PAGE_ID      INTEGER,
  ISACTIVE     VARCHAR2(1 BYTE),
  PLAN_GROUP   VARCHAR2(20 BYTE),
  PLAN_TYPE    VARCHAR2(20 BYTE)
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


