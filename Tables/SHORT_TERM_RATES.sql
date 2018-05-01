--
-- SHORT_TERM_RATES  (Table) 
--
CREATE TABLE OLIVER.SHORT_TERM_RATES
(
  STI_EFF_DATE      DATE,
  STI_RATE          NUMBER(12,6),
  STI_CREATED_DATE  DATE                        DEFAULT SYSDATE,
  STI_CREATED_BY    VARCHAR2(100 BYTE)
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


