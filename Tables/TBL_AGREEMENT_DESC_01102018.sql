--
-- TBL_AGREEMENT_DESC_01102018  (Table) 
--
CREATE TABLE OLIVER.TBL_AGREEMENT_DESC_01102018
(
  TADC_CODE    VARCHAR2(1000 BYTE),
  TADC_DESC    VARCHAR2(255 BYTE),
  TADC_PLAN    VARCHAR2(20 BYTE),
  TADC_CLIENT  VARCHAR2(20 BYTE)
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


