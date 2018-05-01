--
-- TBL_EMPLOYER_CONTACTS_BCGEU  (Table) 
--
CREATE TABLE OLIVER.TBL_EMPLOYER_CONTACTS_BCGEU
(
  TEC_ID                  VARCHAR2(100 BYTE),
  TEC_DIV                 VARCHAR2(10 BYTE),
  TEC_LOC                 VARCHAR2(20 BYTE),
  TEC_CONTACT             VARCHAR2(100 BYTE),
  TEC_ADDRESS1            VARCHAR2(100 BYTE),
  TEC_ADDRESS2            VARCHAR2(100 BYTE),
  TEC_CITY                VARCHAR2(100 BYTE),
  TEC_POST_CODE           VARCHAR2(20 BYTE),
  TEC_COUNTRY             VARCHAR2(100 BYTE)    DEFAULT 'CANADA',
  TEC_PHONE1              VARCHAR2(100 BYTE),
  TEC_PHONE2              VARCHAR2(100 BYTE),
  TEC_EMAIL1              VARCHAR2(100 BYTE),
  TEC_EMAIL2              VARCHAR2(100 BYTE),
  TEC_FAX                 VARCHAR2(100 BYTE),
  TEC_PRIMARY             VARCHAR2(1 BYTE)      DEFAULT 'N',
  TEC_NOTE                VARCHAR2(3000 BYTE),
  TEC_PROV                VARCHAR2(10 BYTE),
  TEC_LAST_MODIFIED_BY    VARCHAR2(50 BYTE),
  TEC_LAST_MODIFIED_DATE  DATE,
  TEC_PLAN                VARCHAR2(10 BYTE),
  TEC_EFFECTIVE_DATE      DATE,
  TEC_TERM_DATE           DATE,
  TEC_KEY                 NUMBER                NOT NULL,
  TEC_CLIENT              VARCHAR2(20 BYTE),
  TEC_TITLE               VARCHAR2(100 BYTE)
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


