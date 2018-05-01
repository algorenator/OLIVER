--
-- TBL_REPORT  (Table) 
--
CREATE TABLE OLIVER.TBL_REPORT
(
  REPORT_ID    NUMBER Generated as Identity ( START WITH 161 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP GLOBAL) NOT NULL,
  CATEGORY     VARCHAR2(100 BYTE)               NOT NULL,
  REPORT_NAME  VARCHAR2(100 BYTE)               NOT NULL,
  DESCRIPTION  VARCHAR2(255 BYTE)               NOT NULL,
  PAGE_ID      NUMBER                           NOT NULL,
  ISACTIVE     VARCHAR2(1 BYTE)                 NOT NULL,
  PLAN_GROUP   VARCHAR2(255 BYTE),
  PLAN_TYPE    VARCHAR2(255 BYTE),
  PLAN_ID      VARCHAR2(255 BYTE)
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


