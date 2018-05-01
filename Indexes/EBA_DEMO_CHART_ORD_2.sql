--
-- EBA_DEMO_CHART_ORD_2  (Index) 
--
CREATE INDEX OLIVER.EBA_DEMO_CHART_ORD_2 ON OLIVER.EBA_DEMO_CHART_ORDERS
(PRODUCT_ID)
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


