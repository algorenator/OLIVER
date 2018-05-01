--
-- EARLY_EXIT_RED_FACTORS_TEMP  (Table) 
--
CREATE TABLE OLIVER.EARLY_EXIT_RED_FACTORS_TEMP
(
  AGE_AT_DATE_OF_CALCULATION         NUMBER(4),
  IMMEDIATE1                         NUMBER(20,6),
  DEFERRED_TO_65                     NUMBER(20,6),
  ACTUARIAL_EQUIVALENT_TO_65_FACTOR  NUMBER(20,6),
  EARLY_RETIREMENT_REDUCTION         NUMBER(38,20),
  CLIENT                             VARCHAR2(26 BYTE),
  PLAN                               VARCHAR2(26 BYTE),
  EERF_EFF_FROM_DATE                 DATE,
  EERF_EFF_TO_DATE                   DATE
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


