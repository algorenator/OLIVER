--
-- TBL_REPORT_TAGS  (Table) 
--
CREATE TABLE OLIVER.TBL_REPORT_TAGS
(
  REPORT_ID  NUMBER,
  CLIENT_ID  VARCHAR2(15 BYTE),
  EMAIL      VARCHAR2(100 BYTE),
  TAGS       VARCHAR2(2000 BYTE)
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


