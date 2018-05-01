--
-- TBL_HW_BEN_PK1  (Index) 
--
CREATE UNIQUE INDEX OLIVER.TBL_HW_BEN_PK1 ON OLIVER.TBL_HW_BENEFICIARY
(HB_KEY)
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


