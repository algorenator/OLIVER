--
-- TBL_COMPPEN  (Table) 
--
CREATE TABLE OLIVER.TBL_COMPPEN
(
  CP_NUMBER              VARCHAR2(100 BYTE)     NOT NULL,
  CP_DIV                 VARCHAR2(10 BYTE)      DEFAULT '00'                  NOT NULL,
  CP_CONTACT             VARCHAR2(100 BYTE),
  CP_ADDRESS1            VARCHAR2(100 BYTE),
  CP_ADDRESS2            VARCHAR2(100 BYTE),
  CP_CITY                VARCHAR2(100 BYTE),
  CP_PROV                VARCHAR2(10 BYTE),
  CP_COUNTRY             VARCHAR2(100 BYTE)     DEFAULT 'CANADA',
  CP_PHONE1              VARCHAR2(100 BYTE),
  CP_PHONE2              VARCHAR2(100 BYTE),
  CP_FAX                 VARCHAR2(100 BYTE),
  CP_EMAIL1              VARCHAR2(100 BYTE),
  CP_EMAIL2              VARCHAR2(100 BYTE),
  CP_LANG_PREF           VARCHAR2(1 BYTE)       DEFAULT 'E',
  CP_PLAN                VARCHAR2(10 BYTE)      DEFAULT 'A'                   NOT NULL,
  CP_LAST_MODIFIED_BY    VARCHAR2(100 BYTE),
  CP_LAST_MODIFIED_DATE  DATE,
  CP_OS_BAL              NUMBER,
  CP_EFF_DATE            DATE,
  CP_TERM_DATE           DATE,
  CP_LRD                 DATE,
  CP_WORK_PROV           VARCHAR2(30 BYTE),
  CP_CLIENT              VARCHAR2(20 BYTE)      NOT NULL,
  CP_CREATED_DATE        DATE,
  CP_CREATED_BY          VARCHAR2(100 BYTE),
  CP_POST_CODE           VARCHAR2(10 BYTE)
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


