--
-- AUDIT_TBL_PENWD  (Table) 
--
CREATE TABLE OLIVER.AUDIT_TBL_PENWD
(
  PW_CLIENT             VARCHAR2(20 BYTE),
  PW_PLAN               VARCHAR2(10 BYTE),
  PW_MEM_ID             VARCHAR2(100 BYTE),
  PW_NLI_WDRAW_EE       NUMBER(8,2),
  PW_LI_WDRAW_EE        NUMBER(8,2),
  PW_LI_WDRAW_ER        NUMBER(8,2),
  PW_NLI_WDRAW_ER       NUMBER(8,2),
  PW_TERM_DATE          DATE,
  PW_PROCESS_DATE       DATE,
  PW_COMMENT            VARCHAR2(3000 BYTE),
  PW_CREATED_BY         VARCHAR2(50 BYTE),
  PW_CREATION_DATE      DATE,
  PW_LAST_UPDATED_BY    VARCHAR2(50 BYTE),
  PW_LAST_UPDATED_DATE  DATE,
  PW_SOL_RATIO          NUMBER(12,2),
  PW_EE_DUE             NUMBER(12,2),
  PW_ER_DUE             NUMBER(12,2),
  PW_DUE_DATE           DATE,
  PW_SHORT_INT_RATE     NUMBER(12,6),
  PW_LONG_INT_RATE      NUMBER(12,6),
  AUDIT_ACTION          CHAR(1 BYTE),
  AUDIT_BY              VARCHAR2(2000 BYTE),
  AUDIT_AT              TIMESTAMP(6)
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


