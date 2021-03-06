--
-- EBA_RESTDEMO_COLUMN_MAPPINGS  (Table) 
--
CREATE TABLE OLIVER.EBA_RESTDEMO_COLUMN_MAPPINGS
(
  ID                  NUMBER,
  SERVICE_ID          NUMBER                    NOT NULL,
  COLUMN_SEQ          NUMBER                    NOT NULL,
  COLUMN_NAME         VARCHAR2(30 BYTE)         NOT NULL,
  COLUMN_SELECTOR     VARCHAR2(500 BYTE)        NOT NULL,
  PRIMARY_KEY         CHAR(1 BYTE)              NOT NULL,
  DATA_TYPE           VARCHAR2(30 BYTE)         NOT NULL,
  DATA_TYPE_LEN       NUMBER,
  DATA_TYPE_PREC      NUMBER,
  DATA_TYPE_SCALE     NUMBER,
  DATA_FORMAT_MASK    VARCHAR2(255 BYTE),
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


