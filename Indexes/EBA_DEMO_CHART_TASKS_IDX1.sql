--
-- EBA_DEMO_CHART_TASKS_IDX1  (Index) 
--
CREATE INDEX OLIVER.EBA_DEMO_CHART_TASKS_IDX1 ON OLIVER.EBA_DEMO_CHART_TASKS
(PROJECT)
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


