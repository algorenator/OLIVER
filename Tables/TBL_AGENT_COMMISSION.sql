--
-- TBL_AGENT_COMMISSION  (Table) 
--
CREATE TABLE OLIVER.TBL_AGENT_COMMISSION
(
  AC_CLIENT_ID     VARCHAR2(30 BYTE),
  AC_PLAN_ID       VARCHAR2(30 BYTE),
  AC_AGENT_ID      NUMBER,
  AC_EMPLOYER      VARCHAR2(30 BYTE),
  AC_START_DATE    DATE,
  AC_END_DATE      DATE,
  AC_PERIOD        DATE,
  AC_HOURS         NUMBER(12,2)                 DEFAULT 0,
  AC_COMMISSION    NUMBER(12,2)                 DEFAULT 0,
  AC_FINDER_FEE    NUMBER(12,2)                 DEFAULT 0,
  AC_OTHER_FEE     NUMBER(12,2)                 DEFAULT 0,
  AC_CREATED_DATE  DATE                         DEFAULT SYSDATE,
  AC_CREATED_BY    VARCHAR2(100 BYTE)
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


