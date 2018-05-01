--
-- PBAS_TEMP_MEM_CONTACTS  (Table) 
--
CREATE TABLE OLIVER.PBAS_TEMP_MEM_CONTACTS
(
  MEM_ID                  VARCHAR2(26 BYTE),
  MEM_FIRST_NAME          VARCHAR2(26 BYTE),
  MEM_MIDDLE_NAME         VARCHAR2(26 BYTE),
  MEM_LAST_NAME           VARCHAR2(26 BYTE),
  MEM_SIN                 VARCHAR2(26 BYTE),
  MEM_GENDER              VARCHAR2(26 BYTE),
  MEM_DOB                 DATE,
  MEM_ADDRESS1            VARCHAR2(150 BYTE),
  MEM_ADDRESS2            VARCHAR2(200 BYTE),
  MEM_CITY                VARCHAR2(128 BYTE),
  MEM_PROV                VARCHAR2(26 BYTE),
  MEM_COUNTRY             VARCHAR2(26 BYTE),
  MEM_POSTAL_CODE         VARCHAR2(26 BYTE),
  MEM_EMAIL               VARCHAR2(128 BYTE),
  MEM_HOME_PHONE          VARCHAR2(26 BYTE),
  MEM_WORK_PHONE          VARCHAR2(26 BYTE),
  MEM_CELL_PHONE          VARCHAR2(26 BYTE),
  MEM_FAX                 VARCHAR2(26 BYTE),
  MEM_LANG_PREF           VARCHAR2(26 BYTE),
  MEM_LAST_MODIFIED_BY    VARCHAR2(26 BYTE),
  MEM_LAST_MODIFIED_DATE  VARCHAR2(26 BYTE),
  MEM_PLAN                VARCHAR2(26 BYTE),
  MEM_ATTACHMENT          VARCHAR2(26 BYTE),
  MEM_FILE_NAME           VARCHAR2(26 BYTE),
  MEM_MIME_TYPE           VARCHAR2(26 BYTE),
  MEM_DOD                 VARCHAR2(26 BYTE),
  MEM_TITLE               VARCHAR2(26 BYTE),
  MEM_CREATED_BY          VARCHAR2(26 BYTE),
  MEM_CREATED_DATE        VARCHAR2(26 BYTE),
  MEM_CLIENT_ID           VARCHAR2(26 BYTE)
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


