--
-- AUDIT_TBL_COMPHW  (Table) 
--
CREATE TABLE OLIVER.AUDIT_TBL_COMPHW
(
  CH_NUMBER              VARCHAR2(100 BYTE)     NOT NULL,
  CH_DIV                 VARCHAR2(10 BYTE)      NOT NULL,
  CH_CONTACT             VARCHAR2(100 BYTE),
  CH_ADDRESS1            VARCHAR2(100 BYTE),
  CH_ADDRESS2            VARCHAR2(100 BYTE),
  CH_CITY                VARCHAR2(100 BYTE),
  CH_PROV                VARCHAR2(10 BYTE),
  CH_COUNTRY             VARCHAR2(100 BYTE),
  CH_PHONE1              VARCHAR2(100 BYTE),
  CH_PHONE2              VARCHAR2(100 BYTE),
  CH_FAX                 VARCHAR2(100 BYTE),
  CH_EMAIL1              VARCHAR2(100 BYTE),
  CH_EMAIL2              VARCHAR2(100 BYTE),
  CH_LANG_PREF           VARCHAR2(1 BYTE),
  CH_PLAN                VARCHAR2(10 BYTE)      NOT NULL,
  CH_LAST_MODIFIED_BY    VARCHAR2(100 BYTE),
  CH_LAST_MODIFIED_DATE  DATE,
  CH_OS_BAL              NUMBER,
  CH_EFF_DATE            DATE,
  CH_TERM_DATE           DATE,
  CH_CLIENT_ID           VARCHAR2(20 BYTE),
  CH_POSTAL_CODE         VARCHAR2(10 BYTE),
  CH_LRD                 DATE,
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


