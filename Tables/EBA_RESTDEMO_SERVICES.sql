--
-- EBA_RESTDEMO_SERVICES  (Table) 
--
CREATE TABLE OLIVER.EBA_RESTDEMO_SERVICES
(
  ID                   NUMBER,
  NAME                 VARCHAR2(200 BYTE)       NOT NULL,
  SERVICE_TYPE         VARCHAR2(10 BYTE)        NOT NULL,
  ENDPOINT             VARCHAR2(500 BYTE)       NOT NULL,
  AUTH_TYPE            VARCHAR2(10 BYTE)        NOT NULL,
  AUTH_BASIC_USERNAME  VARCHAR2(50 BYTE),
  AUTH_BASIC_PASSWORD  VARCHAR2(50 BYTE),
  OAUTH_TOKEN_URL      VARCHAR2(500 BYTE),
  OAUTH_CLIENTID       VARCHAR2(50 BYTE),
  OAUTH_CLIENTSECRET   VARCHAR2(50 BYTE),
  RESPONSE_CHARSET     VARCHAR2(50 BYTE),
  RESPONSE_TYPE        VARCHAR2(20 BYTE)        NOT NULL,
  DATA_ROW_SELECTOR    VARCHAR2(500 BYTE)       NOT NULL,
  DATA_ALLOW_INSERT    VARCHAR2(1 BYTE)         NOT NULL,
  DATA_ALLOW_UPDATE    VARCHAR2(1 BYTE)         NOT NULL,
  DATA_ALLOW_DELETE    VARCHAR2(1 BYTE)         NOT NULL,
  ROW_VERSION_NUMBER   NUMBER,
  CREATED              TIMESTAMP(6) WITH LOCAL TIME ZONE,
  CREATED_BY           VARCHAR2(255 BYTE),
  UPDATED              TIMESTAMP(6) WITH LOCAL TIME ZONE,
  UPDATED_BY           VARCHAR2(255 BYTE)
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

