--
-- TBL_MEM_VOL_BENEFITS  (Table) 
--
CREATE TABLE OLIVER.TBL_MEM_VOL_BENEFITS
(
  MVB_CLIENT          VARCHAR2(20 BYTE),
  MVB_PLAN            VARCHAR2(20 BYTE),
  MVB_ID              VARCHAR2(100 BYTE),
  MVB_BENEFIT         VARCHAR2(20 BYTE),
  MVB_VOLUME          NUMBER(12,2),
  MVB_EFFECTIVE_DATE  DATE,
  MVB_TERM_DATE       DATE,
  MVB_POST_DATE       DATE
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


