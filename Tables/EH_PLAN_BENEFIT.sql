--
-- EH_PLAN_BENEFIT  (Table) 
--
CREATE TABLE OLIVER.EH_PLAN_BENEFIT
(
  EPB_PLAN         VARCHAR2(10 BYTE)            NOT NULL,
  EPB_BEN_CODE     NUMBER(10)                   NOT NULL,
  EPB_BEN_DESC     VARCHAR2(100 BYTE),
  EPB_LOB          NUMBER(3)                    DEFAULT 0,
  EPB_MOS_REVIEW   NUMBER(4)                    DEFAULT 0,
  EPB_ASSOC_CODE   NUMBER(10),
  EPB_EFF_DATE     DATE                         NOT NULL,
  EPB_TERM_DATE    DATE,
  EPB_AMT_ALLOWED  NUMBER(12,2)                 DEFAULT 0,
  EPB_CLIENT       VARCHAR2(20 BYTE)
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


