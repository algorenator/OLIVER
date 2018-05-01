--
-- AUDIT_TBL_COMPMAST  (Table) 
--
CREATE TABLE OLIVER.AUDIT_TBL_COMPMAST
(
  CO_NUMBER              VARCHAR2(100 BYTE)     NOT NULL,
  CO_DIV                 VARCHAR2(10 BYTE)      NOT NULL,
  CO_NAME                VARCHAR2(100 BYTE),
  CO_PLAN                VARCHAR2(15 BYTE)      NOT NULL,
  CO_LAST_MODIFIED_BY    VARCHAR2(100 BYTE),
  CO_LAST_MODIFIED_DATE  DATE,
  CO_ATTACHMENT          BLOB,
  CO_FILE_NAME           VARCHAR2(100 BYTE),
  CO_MIME_TYPE           VARCHAR2(100 BYTE),
  CO_CLIENT              VARCHAR2(20 BYTE)      NOT NULL,
  CO_TYPE                VARCHAR2(20 BYTE),
  CO_CREATED_DATE        DATE,
  CO_CREATED_BY          VARCHAR2(100 BYTE),
  CO_EDITED_DATE         DATE,
  CO_EDITED_BY           VARCHAR2(100 BYTE),
  AUDIT_ACTION           CHAR(1 BYTE),
  AUDIT_BY               VARCHAR2(2000 BYTE),
  AUDIT_AT               TIMESTAMP(6)
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


