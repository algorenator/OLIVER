--
-- TBL_OPTION_FACTORS_LO_G_TEMP  (Table) 
--
CREATE TABLE OLIVER.TBL_OPTION_FACTORS_LO_G_TEMP
(
  AGE                                   NUMBER(4),
  LIFETIME_PENSION_WITH_NO_GUARANTEE    NUMBER(20,10),
  LIFE_PENSION_GUARANTEED_FOR_15_YEARS  NUMBER(20,10),
  CLIENT                                VARCHAR2(26 BYTE),
  PLAN                                  VARCHAR2(26 BYTE),
  EFF_FROM                              DATE,
  EFF_TO                                DATE
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


