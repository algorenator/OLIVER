--
-- PK_RATE  (Index) 
--
CREATE UNIQUE INDEX OLIVER.PK_RATE ON OLIVER.TBL_PLAN_HR_BANK_RATES
(PHBR_PLAN, PHBR_CLIENT_ID)
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


