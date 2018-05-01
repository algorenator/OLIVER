--
-- APP_DEPLOYMENT  (Table) 
--
CREATE TABLE OLIVER.APP_DEPLOYMENT
(
  DEPLOYDATE         DATE                       DEFAULT NULL,
  ENV_FROM           VARCHAR2(20 BYTE),
  ENV_TO             VARCHAR2(20 BYTE),
  VERSION            VARCHAR2(20 BYTE),
  DEP_ID             NUMBER,
  APP_ID             NUMBER,
  LAST_UPDATED_DATE  DATE,
  NOTES              VARCHAR2(1000 BYTE)
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


