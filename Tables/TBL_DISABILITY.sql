--
-- TBL_DISABILITY  (Table) 
--
CREATE TABLE OLIVER.TBL_DISABILITY
(
  DIS_PLAN           VARCHAR2(100 BYTE),
  DIS_ID             NUMBER(10),
  DIS_TYPE           VARCHAR2(10 BYTE),
  DIS_START_DATE     DATE,
  DIS_RECOVERY_DATE  DATE,
  DIS_COMMENT        VARCHAR2(3000 BYTE),
  DIS_CLIENT         VARCHAR2(20 BYTE)
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


