--
-- TBL_MEM_FUNDS  (Table) 
--
CREATE TABLE OLIVER.TBL_MEM_FUNDS
(
  TMF_ID            VARCHAR2(100 BYTE),
  TMF_PLAN          VARCHAR2(10 BYTE),
  TMF_UNITS         NUMBER(12,2)                DEFAULT 0,
  TMF_FUND          VARCHAR2(30 BYTE)           DEFAULT 'PEN',
  TMF_RATE          NUMBER(12,6)                DEFAULT 0,
  TMF_AMT           NUMBER(12,2)                DEFAULT 0,
  TMF_FROM          DATE,
  TMF_TO            DATE,
  TMF_PERIOD        DATE,
  TMF_ENTERED_DATE  DATE,
  TMF_EMPLOYER      VARCHAR2(100 BYTE),
  TMF_USER          VARCHAR2(60 BYTE),
  TMF_BATCH         VARCHAR2(1000 BYTE),
  TMF_DESC          VARCHAR2(1000 BYTE),
  TMF_CLIENT        VARCHAR2(20 BYTE)
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


