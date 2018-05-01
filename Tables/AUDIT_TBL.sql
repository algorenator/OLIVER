--
-- AUDIT_TBL  (Table) 
--
CREATE TABLE OLIVER.AUDIT_TBL
(
  ID         NUMBER,
  TIMESTAMP  DATE,
  WHO        VARCHAR2(30 BYTE),
  TNAME      VARCHAR2(30 BYTE),
  CNAME      VARCHAR2(30 BYTE),
  OLD        VARCHAR2(2000 BYTE),
  NEW        VARCHAR2(3000 BYTE),
  RID        ROWID
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


