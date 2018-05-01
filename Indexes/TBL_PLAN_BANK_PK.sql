--
-- TBL_PLAN_BANK_PK  (Index) 
--
CREATE UNIQUE INDEX OLIVER.TBL_PLAN_BANK_PK ON OLIVER.TBL_PLAN_BANK
(TPB_CLIENT, TPB_PLAN, TPB_PLAN_TYPE)
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


