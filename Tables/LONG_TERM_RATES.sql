--
-- LONG_TERM_RATES  (Table) 
--
CREATE TABLE OLIVER.LONG_TERM_RATES
(
  LTI_EFF_DATE      DATE,
  LTI_RATE          NUMBER(12,6),
  LTI_CREATED_DATE  DATE                        DEFAULT SYSDATE,
  LTI_CREATED_BY    VARCHAR2(100 BYTE)
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


