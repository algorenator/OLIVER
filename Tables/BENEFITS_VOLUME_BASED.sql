--
-- BENEFITS_VOLUME_BASED  (Table) 
--
CREATE TABLE OLIVER.BENEFITS_VOLUME_BASED
(
  BVB_BENEFIT         VARCHAR2(20 BYTE)         NOT NULL,
  BVB_VOLUME          NUMBER,
  BVB_NEM             NUMBER,
  BVB_MAX             NUMBER,
  BVB_RATE            NUMBER(12,6),
  BVB_AGENT           VARCHAR2(30 BYTE),
  BVB_ADMIN_RATE      NUMBER,
  BVB_EFFECTIVE_DATE  DATE                      NOT NULL,
  BVB_TERM_DATE       DATE,
  BVB_CLASS           VARCHAR2(10 BYTE)         NOT NULL,
  BVB_UNIT            NUMBER(12,2),
  BVB_CLIENT_ID       VARCHAR2(20 BYTE)         NOT NULL,
  BVB_PLAN_ID         VARCHAR2(20 BYTE)         NOT NULL,
  BVB_AGENT_RATE      NUMBER(12,6)              DEFAULT 0,
  BVB_ID              NUMBER,
  VOLUME_SELECT       VARCHAR2(2 BYTE),
  BVB_CARRIER         VARCHAR2(100 BYTE)
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


