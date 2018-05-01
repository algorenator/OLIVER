--
-- TBL_PEN_CALC_FORMULA  (Table) 
--
CREATE TABLE OLIVER.TBL_PEN_CALC_FORMULA
(
  TPCF_CLIENT        VARCHAR2(20 BYTE)          NOT NULL,
  TPCF_PLAN          VARCHAR2(20 BYTE)          NOT NULL,
  TPCF_EFF_DATE      DATE                       NOT NULL,
  TPCF_TERM_DATE     DATE,
  TPCF_RATE          NUMBER(12,6)               DEFAULT 0,
  TPCF_UNIT_TYPE     VARCHAR2(100 BYTE),
  TPCF_UNIT_QTY      NUMBER(12,6),
  TPCF_CREATED_DATE  DATE
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


