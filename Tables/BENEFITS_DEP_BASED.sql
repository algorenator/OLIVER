--
-- BENEFITS_DEP_BASED  (Table) 
--
CREATE TABLE OLIVER.BENEFITS_DEP_BASED
(
  BDB_CLIENT_ID   VARCHAR2(20 BYTE)             NOT NULL,
  BDB_PLAN_ID     VARCHAR2(20 BYTE)             NOT NULL,
  BDB_BENEFIT     VARCHAR2(20 BYTE)             NOT NULL,
  BDB_DEP_STATUS  VARCHAR2(2 BYTE)              NOT NULL,
  BDB_RATE        NUMBER(12,6)                  NOT NULL,
  BDB_AGENT       VARCHAR2(30 BYTE),
  BDB_ADMIN_RATE  NUMBER(12,6)                  DEFAULT 0,
  BDB_CLASS       VARCHAR2(10 BYTE)             NOT NULL,
  BDB_EFF_DATE    DATE                          NOT NULL,
  BDB_TERM_DATE   DATE,
  BDB_AGENT_RATE  NUMBER(12,6)                  DEFAULT 0,
  BDB_ID          NUMBER,
  BDB_CARRIER     VARCHAR2(100 BYTE)
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


