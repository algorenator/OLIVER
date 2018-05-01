--
-- DEMO_ORDERS  (Table) 
--
CREATE TABLE OLIVER.DEMO_ORDERS
(
  ORDER_ID         NUMBER                       NOT NULL,
  CUSTOMER_ID      NUMBER                       NOT NULL,
  ORDER_TOTAL      NUMBER(8,2),
  ORDER_TIMESTAMP  TIMESTAMP(6) WITH LOCAL TIME ZONE,
  USER_NAME        VARCHAR2(100 BYTE),
  TAGS             VARCHAR2(4000 BYTE)
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


