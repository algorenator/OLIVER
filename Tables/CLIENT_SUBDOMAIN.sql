--
-- CLIENT_SUBDOMAIN  (Table) 
--
CREATE TABLE OLIVER.CLIENT_SUBDOMAIN
(
  CLIENT         VARCHAR2(100 BYTE),
  SUBDOMAIN      VARCHAR2(100 BYTE),
  CLIENT_ID      VARCHAR2(100 BYTE),
  TABLESPACE_ID  VARCHAR2(100 BYTE),
  PLAN_ID        VARCHAR2(100 BYTE),
  DISPLAY        VARCHAR2(1000 BYTE),
  APPID          NUMBER,
  LINK           VARCHAR2(1000 BYTE),
  DOMAIN         VARCHAR2(100 BYTE)
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


