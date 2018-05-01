--
-- USERS  (Table) 
--
CREATE TABLE OLIVER.USERS
(
  USER_ID                NUMBER                 NOT NULL,
  USER_NAME              VARCHAR2(60 BYTE),
  PASSWORD               VARCHAR2(50 BYTE)      NOT NULL,
  FILE_NAME              VARCHAR2(100 BYTE),
  MIME_TYPE              VARCHAR2(100 BYTE),
  ATTACHMENT             BLOB,
  USER_FIRST_NAME        VARCHAR2(60 BYTE),
  USER_LAST_NAME         VARCHAR2(60 BYTE),
  USER_EFFECTIVE_DATE    DATE,
  USER_TERMINATION_DATE  DATE,
  CLIENT_ID              VARCHAR2(15 BYTE)      NOT NULL,
  EMAIL                  VARCHAR2(100 BYTE)     NOT NULL,
  ISADMIN                VARCHAR2(1 BYTE)       DEFAULT 'N',
  VERIFICATION_CODE      VARCHAR2(200 BYTE)
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


