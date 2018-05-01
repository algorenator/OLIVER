--
-- TBL_HR_BANK_T2_INDEX1  (Index) 
--
CREATE INDEX OLIVER.TBL_HR_BANK_T2_INDEX1 ON OLIVER.TBL_HR_BANK_T2
(THB_ID)
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


