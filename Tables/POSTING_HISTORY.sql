--
-- POSTING_HISTORY  (Table) 
--
CREATE TABLE OLIVER.POSTING_HISTORY
(
  PH_PLAN                 VARCHAR2(255 BYTE),
  PH_LAST_ELIG_PROC_DATE  DATE,
  PH_CLIENT_ID            VARCHAR2(20 BYTE)
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


