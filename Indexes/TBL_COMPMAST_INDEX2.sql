--
-- TBL_COMPMAST_INDEX2  (Index) 
--
CREATE INDEX OLIVER.TBL_COMPMAST_INDEX2 ON OLIVER.TBL_COMPMAST
(CO_CLIENT, CO_PLAN)
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


