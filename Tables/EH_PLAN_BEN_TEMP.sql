--
-- EH_PLAN_BEN_TEMP  (Table) 
--
CREATE TABLE OLIVER.EH_PLAN_BEN_TEMP
(
  PLAN           NUMBER(1),
  BEN_CODE       NUMBER(2),
  BEN_DESC       VARCHAR2(30 BYTE),
  LOB            NUMBER(3),
  MOS_OF_REVIEW  NUMBER(4),
  ASSOC_CODE     NUMBER(2)
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


