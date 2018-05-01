--
-- TBL_BENEFITS  (Table) 
--
CREATE TABLE OLIVER.TBL_BENEFITS
(
  BEN_PLAN        VARCHAR2(10 BYTE)             NOT NULL,
  BEN_ID          VARCHAR2(10 BYTE)             NOT NULL,
  BEN_VOLUME      NUMBER(12,4),
  BEN_NMAX        NUMBER(12,2),
  BEN_ADMIN_RATE  NUMBER(14,6),
  BEN_RATE        NUMBER(12,6),
  BEN_UNIT        NUMBER(12,6),
  BEN_EFF_DATE    DATE                          NOT NULL,
  BEN_CARRIER     VARCHAR2(100 BYTE),
  BEN_POLICT_NO   VARCHAR2(100 BYTE),
  BEN_CLIENT      VARCHAR2(20 BYTE)
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


