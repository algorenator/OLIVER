--
-- TBL_MEMBER_NOTES  (Table) 
--
CREATE TABLE OLIVER.TBL_MEMBER_NOTES
(
  MN_KEY                 NUMBER,
  MN_ID                  VARCHAR2(30 BYTE),
  MN_DATE                DATE,
  MN_LAST_MODIFIED_BY    VARCHAR2(80 BYTE),
  MN_LAST_MODIFIED_DATE  DATE,
  MN_NOTE                VARCHAR2(3000 BYTE),
  MN_PLAN_ID             VARCHAR2(10 BYTE),
  MN_TYPE                VARCHAR2(50 BYTE),
  TMN_CLIENT             VARCHAR2(20 BYTE)
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


