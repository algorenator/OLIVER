--
-- TBL_HW_WAIVER  (Table) 
--
CREATE TABLE OLIVER.TBL_HW_WAIVER
(
  THW_CLIENT           VARCHAR2(20 BYTE),
  THW_PLAN             VARCHAR2(20 BYTE),
  THW_MEM_ID           VARCHAR2(100 BYTE),
  THW_BENEFIT          VARCHAR2(20 BYTE),
  THW_START_DATE       DATE,
  THW_END_DATE         DATE,
  THW_WAIVER_COVERAGE  VARCHAR2(100 BYTE),
  THW_RATE             NUMBER(12,6),
  THW_ADMIN_RATE       NUMBER(12,6),
  THW_AGENT_RATE       NUMBER(12,6),
  THW_BILL             NUMBER(12,2),
  THW_REASON           VARCHAR2(3000 BYTE)
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


