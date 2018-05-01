--
-- DEMO_CUSTOMERS_UK  (Index) 
--
CREATE UNIQUE INDEX OLIVER.DEMO_CUSTOMERS_UK ON OLIVER.DEMO_CUSTOMERS
(CUST_FIRST_NAME, CUST_LAST_NAME)
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


