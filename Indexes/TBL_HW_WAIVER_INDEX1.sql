--
-- TBL_HW_WAIVER_INDEX1  (Index) 
--
CREATE INDEX OLIVER.TBL_HW_WAIVER_INDEX1 ON OLIVER.TBL_HW_WAIVER
(THW_CLIENT, THW_PLAN, THW_MEM_ID)
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


