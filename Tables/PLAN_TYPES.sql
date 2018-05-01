--
-- PLAN_TYPES  (Table) 
--
CREATE TABLE OLIVER.PLAN_TYPES
(
  PT_ID          VARCHAR2(10 BYTE),
  PT_DESC        VARCHAR2(100 BYTE),
  PT_EFF_DATE    DATE,
  PT_TERM_DATE   DATE,
  PT_GROUP_TYPE  VARCHAR2(20 BYTE)
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


