--
-- AOP_TEMPLATE  (Table) 
--
CREATE TABLE OLIVER.AOP_TEMPLATE
(
  ID                NUMBER,
  TEMPLATE_BLOB     BLOB,
  FILENAME          VARCHAR2(200 BYTE),
  MIME_TYPE         VARCHAR2(200 BYTE),
  LAST_UPDATE_DATE  DATE,
  TEMPLATE_TYPE     VARCHAR2(20 BYTE),
  DESCRIPTION       VARCHAR2(4000 BYTE)
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


