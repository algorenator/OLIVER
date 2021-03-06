--
-- AUTH_TESTING  (Table) 
--
CREATE TABLE OLIVER.AUTH_TESTING
(
  CONDITION    VARCHAR2(200 BYTE),
  PLANID       VARCHAR2(200 BYTE),
  CLIENTID     VARCHAR2(200 BYTE),
  USERID       VARCHAR2(200 BYTE),
  PAGENAME     VARCHAR2(200 BYTE),
  COMPNAME     VARCHAR2(200 BYTE),
  COMPTYPE     VARCHAR2(200 BYTE),
  COMPID       VARCHAR2(200 BYTE),
  DATECREATED  TIMESTAMP(6)                     DEFAULT systimestamp
)
TABLESPACE USERS
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


