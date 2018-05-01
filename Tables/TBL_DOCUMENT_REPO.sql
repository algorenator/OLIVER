--
-- TBL_DOCUMENT_REPO  (Table) 
--
CREATE TABLE OLIVER.TBL_DOCUMENT_REPO
(
  DOCUMENT_REPO_ID       NUMBER,
  DOCUMENT_REPO_TYPE_ID  NUMBER,
  FILE_NAME              VARCHAR2(255 BYTE),
  FILE_SIZE              NUMBER,
  MIME_TYPE              VARCHAR2(255 BYTE),
  DOCUMENT               BLOB                   NOT NULL,
  CRE_BY                 VARCHAR2(255 BYTE)     NOT NULL,
  CRE_DATE               DATE                   NOT NULL,
  MOD_BY                 VARCHAR2(255 BYTE),
  MOD_DATE               DATE,
  CHARSET                VARCHAR2(255 BYTE),
  DOCUMENT_MOD_DATE      DATE
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


