--
-- CDAT_CALENDAR  (Table) 
--
CREATE TABLE OLIVER.CDAT_CALENDAR
(
  NAME         VARCHAR2(50 BYTE),
  TYPE         VARCHAR2(20 BYTE),
  YOURDATE     DATE,
  YOURTIME     DATE,
  DATECREATED  VARCHAR2(20 BYTE)                DEFAULT sysdate,
  ID           NUMBER,
  NOTE         VARCHAR2(255 BYTE)
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


