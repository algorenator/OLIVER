--
-- CONT_INT_RATES_INDEX1  (Index) 
--
CREATE INDEX OLIVER.CONT_INT_RATES_INDEX1 ON OLIVER.CONT_INT_RATES
(EIR_CLIENT, EIR_PLAN, EIR_EFF_DATE)
TABLESPACE USERS
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


