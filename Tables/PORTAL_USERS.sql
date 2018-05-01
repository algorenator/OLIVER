--
-- PORTAL_USERS  (Table) 
--
CREATE TABLE OLIVER.PORTAL_USERS
(
  USER_ID            NUMBER,
  EMAIL              VARCHAR2(60 BYTE)          NOT NULL,
  PASSWORD           VARCHAR2(50 BYTE)          NOT NULL,
  USER_FIRST_NAME    VARCHAR2(60 BYTE),
  USER_LAST_NAME     VARCHAR2(60 BYTE),
  DATE_CREATED       DATE,
  CLIENT_ID          VARCHAR2(15 BYTE)          NOT NULL,
  MEM_ID             VARCHAR2(20 BYTE),
  ISACTIVE           VARCHAR2(1 BYTE)           DEFAULT 'N',
  PLAN_ID            VARCHAR2(20 BYTE),
  HW_VERIFY          VARCHAR2(20 BYTE)          DEFAULT 'Y',
  PEN_VERIFY         VARCHAR2(20 BYTE)          DEFAULT 'N',
  VERIFICATION_CODE  VARCHAR2(200 BYTE),
  ISADMIN            VARCHAR2(1 BYTE)           DEFAULT 'N'
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


