--
-- TBL_EMPLOYER_NOTES  (Table) 
--
CREATE TABLE OLIVER.TBL_EMPLOYER_NOTES
(
  EN_KEY                 NUMBER,
  EN_ID                  VARCHAR2(10 BYTE),
  EN_DATE                DATE,
  EN_LAST_MODIFIED_BY    VARCHAR2(30 BYTE),
  EN_LAST_MODIFIED_DATE  DATE,
  EN_NOTE                VARCHAR2(3000 BYTE),
  EN_PLAN_ID             VARCHAR2(20 BYTE),
  EN_TYPE                VARCHAR2(50 BYTE),
  TEN_CLIENT             VARCHAR2(20 BYTE)
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


