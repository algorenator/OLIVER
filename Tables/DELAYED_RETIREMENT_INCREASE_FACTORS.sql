--
-- DELAYED_RETIREMENT_INCREASE_FACTORS  (Table) 
--
CREATE TABLE OLIVER.DELAYED_RETIREMENT_INCREASE_FACTORS
(
  AGE_AT_DATE_OF_CALCULATION                                 NUMBER(4),
  IMMEDIATE1                                                 NUMBER(8,4),
  IMMEDIATE_FACTOR_AT_NRD                                    NUMBER(20,6),
  IMMEDIATE_FACTOR_AT_NRD_WITH_INTEREST_TO_CALCULATION_DATE  NUMBER(38,20),
  DELAYED_RETIREMENT_INCREASE_FACTOR                         NUMBER(38,20),
  CLIENT                                                     VARCHAR2(26 BYTE),
  PLAN                                                       VARCHAR2(26 BYTE),
  DRIF_EFF_FROM_DATE                                         DATE,
  DRIF_EFF_TO_DATE                                           DATE
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


