--
-- REPORT_ACTIVE_EMPLOYEES  (Table) 
--
CREATE TABLE OLIVER.REPORT_ACTIVE_EMPLOYEES
(
  CO_CLIENT        VARCHAR2(20 BYTE)            NOT NULL,
  CO_PLAN          VARCHAR2(15 BYTE)            NOT NULL,
  CO_NUMBER        VARCHAR2(100 BYTE)           NOT NULL,
  CO_NAME          VARCHAR2(100 BYTE),
  MEM_ID           VARCHAR2(100 BYTE)           NOT NULL,
  MEM_LAST_NAME    VARCHAR2(100 BYTE),
  MEM_FIRST_NAME   VARCHAR2(100 BYTE),
  MEM_ADDRESS1     VARCHAR2(100 BYTE),
  MEM_ADDRESS2     VARCHAR2(100 BYTE),
  MEM_CITY         VARCHAR2(100 BYTE),
  MEM_PROV         VARCHAR2(10 BYTE),
  MEM_POSTAL_CODE  VARCHAR2(20 BYTE),
  HW_EFF_DATE      DATE,
  HW_TERM_DATE     DATE
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


