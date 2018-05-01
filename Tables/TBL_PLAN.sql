--
-- TBL_PLAN  (Table) 
--
CREATE TABLE OLIVER.TBL_PLAN
(
  PL_ID                 VARCHAR2(10 BYTE)       DEFAULT 'A'                   NOT NULL,
  PL_ADMINISTRATOR      VARCHAR2(100 BYTE),
  PL_CONTACT            VARCHAR2(100 BYTE),
  PL_NAME               VARCHAR2(100 BYTE),
  PL_ADDRESS1           VARCHAR2(100 BYTE),
  PL_ADDRESS2           VARCHAR2(100 BYTE),
  PL_CITY               VARCHAR2(100 BYTE),
  PL_PROV               VARCHAR2(20 BYTE),
  PL_COUNTRY            VARCHAR2(100 BYTE)      DEFAULT 'CANADA',
  PL_PHONE1             VARCHAR2(100 BYTE),
  PL_PHONE2             VARCHAR2(100 BYTE),
  PL_FAX                VARCHAR2(100 BYTE),
  PL_EMAIL              VARCHAR2(100 BYTE),
  PL_POST_CODE          VARCHAR2(7 BYTE),
  PL_HW_MONTHEND        DATE,
  PL_EFF_DATE           DATE,
  PL_JURISDICTION       VARCHAR2(10 BYTE),
  PL_TERM_DATE          DATE,
  PL_CLIENT_ID          VARCHAR2(15 BYTE)       NOT NULL,
  PL_TYPE               VARCHAR2(10 BYTE)       NOT NULL,
  PL_STATUS             VARCHAR2(1 BYTE)        DEFAULT 'A',
  PL_MEMBER_IDENTIFIER  NUMBER(2)               DEFAULT 0,
  PL_GST_NUMBER         VARCHAR2(100 BYTE),
  PL_PAY_GRACE_PERIOD   NUMBER,
  PL_LOGO               BLOB,
  PL_VERIFY_SIN         VARCHAR2(1 BYTE)        DEFAULT 'Y'
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


