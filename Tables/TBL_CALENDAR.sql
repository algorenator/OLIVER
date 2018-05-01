--
-- TBL_CALENDAR  (Table) 
--
CREATE TABLE OLIVER.TBL_CALENDAR
(
  ID            NUMBER,
  EVENT         VARCHAR2(50 BYTE),
  NOTE          VARCHAR2(1000 BYTE),
  EVENTDATE     DATE,
  USERID        VARCHAR2(20 BYTE),
  PLAN_ID       VARCHAR2(20 BYTE),
  CLIENT_ID     VARCHAR2(20 BYTE),
  DATECREATED   DATE                            DEFAULT sysdate,
  DATEMODIFIED  DATE,
  MODIFIEDBY    VARCHAR2(20 BYTE),
  ISDELETED     VARCHAR2(1 BYTE)                DEFAULT 'N',
  STATUS        VARCHAR2(1 BYTE)
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


