--
-- DEMO_ORDER_ITEMS  (Table) 
--
CREATE TABLE OLIVER.DEMO_ORDER_ITEMS
(
  ORDER_ITEM_ID  NUMBER(3)                      NOT NULL,
  ORDER_ID       NUMBER                         NOT NULL,
  PRODUCT_ID     NUMBER                         NOT NULL,
  UNIT_PRICE     NUMBER(8,2)                    NOT NULL,
  QUANTITY       NUMBER(8)                      NOT NULL
)
TABLESPACE CDATV5DATAFILE
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
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
           )
NOCOMPRESS ;


