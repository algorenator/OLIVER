--
-- TBL_ANNUAL_INDEX2  (Index) 
--
CREATE INDEX OLIVER.TBL_ANNUAL_INDEX2 ON OLIVER.TBL_ANNUAL
(ANN_CLIENT, ANN_PLAN, ANN_ID, ANN_YEAR, ANN_ACCOUNT, 
ANN_STATUS)
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


