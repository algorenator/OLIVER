--
-- TRANSACTION_DETAIL_INDEX1  (Index) 
--
CREATE INDEX OLIVER.TRANSACTION_DETAIL_INDEX1 ON OLIVER.TRANSACTION_DETAIL
(TD_PLAN_ID, TD_TRAN_ID, "TD_PERIOD" DESC)
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


