--
-- DEMO_TAGS_TYPE_SUM  (Table) 
--
CREATE TABLE OLIVER.DEMO_TAGS_TYPE_SUM
(
  TAG           VARCHAR2(255 BYTE),
  CONTENT_TYPE  VARCHAR2(30 BYTE),
  TAG_COUNT     NUMBER
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


