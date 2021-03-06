--
-- TBL_PENSION_STATUS  (Table) 
--
CREATE TABLE OLIVER.TBL_PENSION_STATUS
(
  TPS_CLIENT        VARCHAR2(20 BYTE),
  TPS_PLAN          VARCHAR2(20 BYTE),
  TPS_STATUS        VARCHAR2(10 BYTE),
  TPS_STATUS_DESC   VARCHAR2(1000 BYTE),
  TPS_EFF_DATE      DATE,
  TPS_TERM_DATE     DATE,
  TPS_CREATED_DATE  DATE,
  TPS_CREATED_BY    VARCHAR2(100 BYTE)
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


