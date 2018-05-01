--
-- TBL_PLAN_PK  (Index) 
--
CREATE UNIQUE INDEX OLIVER.TBL_PLAN_PK ON OLIVER.TBL_PLAN
(PL_CLIENT_ID, PL_ID, PL_TYPE)
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


