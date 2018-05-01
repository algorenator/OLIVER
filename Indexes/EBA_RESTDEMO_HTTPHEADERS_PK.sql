--
-- EBA_RESTDEMO_HTTPHEADERS_PK  (Index) 
--
CREATE UNIQUE INDEX OLIVER.EBA_RESTDEMO_HTTPHEADERS_PK ON OLIVER.EBA_RESTDEMO_HTTP_HEADERS
(ID)
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           );


