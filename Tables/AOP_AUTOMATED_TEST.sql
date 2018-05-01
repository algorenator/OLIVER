--
-- AOP_AUTOMATED_TEST  (Table) 
--
CREATE TABLE OLIVER.AOP_AUTOMATED_TEST
(
  ID                     NUMBER,
  DESCRIPTION            VARCHAR2(4000 BYTE),
  DATA_TYPE              VARCHAR2(20 BYTE),
  TEMPLATE_TYPE          VARCHAR2(20 BYTE),
  OUTPUT_TYPE            VARCHAR2(20 BYTE),
  OUTPUT_FILENAME        VARCHAR2(200 BYTE),
  OUTPUT_BLOB            BLOB,
  EXPECTED_BYTES         NUMBER,
  RECEIVED_BYTES         NUMBER,
  RESULT                 VARCHAR2(4000 BYTE),
  PROCESSING_SECONDS     NUMBER,
  SEQ_NR                 NUMBER,
  DATA_SOURCE            VARCHAR2(4000 BYTE),
  TEMPLATE_SOURCE        VARCHAR2(4000 BYTE),
  FILENAME               VARCHAR2(221 BYTE),
  OUTPUT_TYPE_ITEM_NAME  VARCHAR2(100 BYTE),
  OUTPUT_TO              VARCHAR2(100 BYTE),
  SPECIAL                VARCHAR2(100 BYTE),
  PROCEDURE_             VARCHAR2(100 BYTE),
  CREATED_DATE           DATE                   DEFAULT sysdate,
  RUN_DATE               DATE,
  APP_ID                 NUMBER,
  PAGE_ID                NUMBER,
  INIT_CODE              VARCHAR2(4000 BYTE),
  ACTIVE                 VARCHAR2(1 BYTE)
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


