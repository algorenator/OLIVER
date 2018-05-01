--
-- DEMO_ORDER_ITEMS_PK  (Index) 
--
CREATE UNIQUE INDEX OLIVER.DEMO_ORDER_ITEMS_PK ON OLIVER.DEMO_ORDER_ITEMS
(ORDER_ITEM_ID)
TABLESPACE CDATV5DATAFILE
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


