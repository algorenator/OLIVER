--
-- IDX$$_17440001  (Index) 
--
CREATE INDEX OLIVER.IDX$$_17440001 ON OLIVER.TBL_COMPPEN
(CP_NUMBER, CP_PLAN)
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


