--
-- EBA_RESTDEMO_LOG_PK  (Index) 
--
CREATE UNIQUE INDEX OLIVER.EBA_RESTDEMO_LOG_PK ON OLIVER.EBA_RESTDEMO_LOG
(ID)
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


