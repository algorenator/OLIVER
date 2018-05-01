--
-- DEMO_TAGS  (Table) 
--
CREATE TABLE OLIVER.DEMO_TAGS
(
  ID            NUMBER,
  TAG           VARCHAR2(255 BYTE)              NOT NULL,
  CONTENT_ID    NUMBER,
  CONTENT_TYPE  VARCHAR2(30 BYTE),
  CREATED       TIMESTAMP(6) WITH LOCAL TIME ZONE,
  CREATED_BY    VARCHAR2(255 BYTE),
  UPDATED       TIMESTAMP(6) WITH LOCAL TIME ZONE,
  UPDATED_BY    VARCHAR2(255 BYTE)
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

