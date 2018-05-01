--
-- TBL_PORTAL_CLIENT_DETAILS  (Table) 
--
CREATE TABLE OLIVER.TBL_PORTAL_CLIENT_DETAILS
(
  CLIENTID         VARCHAR2(20 BYTE),
  PLANID           VARCHAR2(20 BYTE),
  DISCOUNTIMAGE    VARCHAR2(100 BYTE),
  BENDETAILS       VARCHAR2(255 BYTE),
  PLANDESCRIPTION  VARCHAR2(100 BYTE)
)
TABLESPACE CDATV5DATAFILE
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOCOMPRESS ;


