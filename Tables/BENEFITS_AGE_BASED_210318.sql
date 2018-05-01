--
-- BENEFITS_AGE_BASED_210318  (Table) 
--
CREATE TABLE OLIVER.BENEFITS_AGE_BASED_210318
(
  BAB_CLIENT_ID   VARCHAR2(20 BYTE)             NOT NULL,
  BAB_PLAN_ID     VARCHAR2(20 BYTE)             NOT NULL,
  BAB_BENEFIT     VARCHAR2(20 BYTE)             NOT NULL,
  BAB_CLASS       VARCHAR2(10 BYTE)             NOT NULL,
  BAB_EFF_DATE    DATE                          NOT NULL,
  BAB_TERM_DATE   DATE,
  BAB_SMOKER      VARCHAR2(1 BYTE)              NOT NULL,
  BAB_GENDER      VARCHAR2(1 BYTE)              NOT NULL,
  BAB_AGE         NUMBER(5,2)                   NOT NULL,
  BAB_RATE        NUMBER(12,6),
  BAB_ADMIN_RATE  NUMBER(12,6),
  BAB_AGENT       VARCHAR2(30 BYTE),
  BAB_AGENT_RATE  NUMBER(12,6),
  BAB_ID          NUMBER,
  BAB_CARRIER     VARCHAR2(100 BYTE)
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


