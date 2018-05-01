--
-- UQ_BENEFITS_CLASS_KEY  (Index) 
--
CREATE UNIQUE INDEX OLIVER.UQ_BENEFITS_CLASS_KEY ON OLIVER.TBL_BENEFITS_CLASS
(BC_KEY)
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


