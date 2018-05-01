--
-- AUDIT_TABLES  (Table) 
--
CREATE TABLE OLIVER.AUDIT_TABLES
(
  "SCHEMA"  VARCHAR2(200 BYTE)                  NOT NULL,
  TNAME     VARCHAR2(200 BYTE)                  NOT NULL
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


