--
-- TBL_BENEFITS_MASTER_PK  (Index) 
--
CREATE UNIQUE INDEX OLIVER.TBL_BENEFITS_MASTER_PK ON OLIVER.TBL_BENEFITS_MASTER
(BM_CLIENT_ID, BM_PLAN, BM_EFF_DATE, BM_CODE)
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


