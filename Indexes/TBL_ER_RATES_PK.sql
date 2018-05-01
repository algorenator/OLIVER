--
-- TBL_ER_RATES_PK  (Index) 
--
CREATE UNIQUE INDEX OLIVER.TBL_ER_RATES_PK ON OLIVER.TBL_ER_RATES
(TER_CLIENT, TER_PLAN, TER_ID, TER_EFF_DATE)
TABLESPACE CDATV5DATAFILE
PCTFREE    10
INITRANS   2
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
           );


