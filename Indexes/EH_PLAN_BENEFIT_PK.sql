--
-- EH_PLAN_BENEFIT_PK  (Index) 
--
CREATE UNIQUE INDEX OLIVER.EH_PLAN_BENEFIT_PK ON OLIVER.EH_PLAN_BENEFIT
(EPB_PLAN, EPB_BEN_CODE, EPB_EFF_DATE)
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


