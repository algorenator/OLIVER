--
-- TBL_DOCUMENT_SEARCH  (Table) 
--
CREATE TABLE OLIVER.TBL_DOCUMENT_SEARCH
(
  SEARCHTERM  VARCHAR2(100 BYTE),
  PLANID      VARCHAR2(20 BYTE),
  CLIENTID    VARCHAR2(20 BYTE)
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


