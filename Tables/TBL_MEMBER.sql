--
-- TBL_MEMBER  (Table) 
--
CREATE TABLE OLIVER.TBL_MEMBER
(
  MEM_ID                  VARCHAR2(100 BYTE)    NOT NULL,
  MEM_SIN                 NUMBER,
  MEM_FIRST_NAME          VARCHAR2(100 BYTE),
  MEM_MIDDLE_NAME         VARCHAR2(100 BYTE),
  MEM_LAST_NAME           VARCHAR2(100 BYTE),
  MEM_GENDER              VARCHAR2(1 BYTE),
  MEM_DOB                 DATE,
  MEM_ADDRESS1            VARCHAR2(100 BYTE),
  MEM_ADDRESS2            VARCHAR2(100 BYTE),
  MEM_CITY                VARCHAR2(100 BYTE),
  MEM_PROV                VARCHAR2(10 BYTE),
  MEM_COUNTRY             VARCHAR2(100 BYTE),
  MEM_POSTAL_CODE         VARCHAR2(20 BYTE),
  MEM_EMAIL               VARCHAR2(100 BYTE),
  MEM_HOME_PHONE          VARCHAR2(100 BYTE),
  MEM_WORK_PHONE          VARCHAR2(100 BYTE),
  MEM_CELL_PHONE          VARCHAR2(100 BYTE),
  MEM_FAX                 VARCHAR2(100 BYTE),
  MEM_LANG_PREF           VARCHAR2(1 BYTE),
  MEM_LAST_MODIFIED_BY    VARCHAR2(100 BYTE),
  MEM_LAST_MODIFIED_DATE  DATE,
  MEM_PLAN                VARCHAR2(10 BYTE)     DEFAULT 'A'                   NOT NULL,
  MEM_ATTACHMENT          BLOB,
  MEM_FILE_NAME           VARCHAR2(100 BYTE),
  MEM_MIME_TYPE           VARCHAR2(100 BYTE),
  MEM_DOD                 DATE,
  MEM_TITLE               VARCHAR2(100 BYTE),
  MEM_CREATED_BY          VARCHAR2(100 BYTE),
  MEM_CREATED_DATE        DATE,
  MEM_CLIENT_ID           VARCHAR2(20 BYTE)     NOT NULL
)
NOCOMPRESS 
TABLESPACE USERS
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
PARTITION BY LIST (MEM_CLIENT_ID)
(  
  PARTITION DATOWNLEY VALUES ('DT')
    NOCOMPRESS 
    TABLESPACE DATOWNLEY
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION SUMA VALUES ('SUMA')
    NOCOMPRESS 
    TABLESPACE SUMA
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION TL938 VALUES ('TL938')
    NOCOMPRESS 
    TABLESPACE TL938
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION ICBA VALUES ('ICBA')
    NOCOMPRESS 
    TABLESPACE ICBA
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION CDAT VALUES ('CDAT')
    NOCOMPRESS 
    TABLESPACE CDAT
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION PBC VALUES ('PBC')
    NOCOMPRESS 
    TABLESPACE PBC
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION PBAS VALUES ('PBAS')
    NOCOMPRESS 
    TABLESPACE USERS
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
);


