--
-- TBL_MEM_PEN_STATUS_HIST  (Table) 
--
CREATE TABLE OLIVER.TBL_MEM_PEN_STATUS_HIST
(
  TMPSH_CLIENT        VARCHAR2(20 BYTE),
  TMPSH_PLAN          VARCHAR2(20 BYTE),
  TMPSH_MEM_ID        VARCHAR2(100 BYTE),
  TMPSH_STATUS        VARCHAR2(10 BYTE),
  TMPSH_STATUS_DATE   DATE,
  TMPSH_CREATED_DATE  DATE,
  TMPSH_CREATED_BY    VARCHAR2(100 BYTE)
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


