--
-- TBL_CLAIM_NOTES  (Table) 
--
CREATE TABLE OLIVER.TBL_CLAIM_NOTES
(
  CN_KEY                 NUMBER,
  CN_ID                  NUMBER,
  CN_DATE                DATE,
  CN_LAST_MODIFIED_BY    VARCHAR2(80 BYTE)      NOT NULL,
  CN_LAST_MODIFIED_DATE  DATE,
  CN_NOTE                VARCHAR2(1000 BYTE),
  CN_PLAN_ID             VARCHAR2(10 BYTE),
  CN_TYPE                VARCHAR2(20 BYTE)
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


