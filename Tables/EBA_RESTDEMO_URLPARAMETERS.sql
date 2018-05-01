--
-- EBA_RESTDEMO_URLPARAMETERS  (Table) 
--
CREATE TABLE OLIVER.EBA_RESTDEMO_URLPARAMETERS
(
  ID                  NUMBER,
  SERVICE_ID          NUMBER                    NOT NULL,
  PARAM_NAME          VARCHAR2(100 BYTE)        NOT NULL,
  PARAM_VALUE         VARCHAR2(100 BYTE)        NOT NULL,
  PARAM_ACTIVE        VARCHAR2(1 BYTE)          NOT NULL,
  PARAM_FOR           VARCHAR2(100 BYTE)        NOT NULL,
  ROW_VERSION_NUMBER  NUMBER,
  CREATED             TIMESTAMP(6) WITH LOCAL TIME ZONE,
  CREATED_BY          VARCHAR2(255 BYTE),
  UPDATED             TIMESTAMP(6) WITH LOCAL TIME ZONE,
  UPDATED_BY          VARCHAR2(255 BYTE)
)
TABLESPACE USERS
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOCOMPRESS ;


