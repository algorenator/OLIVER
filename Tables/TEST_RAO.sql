--
-- TEST_RAO  (Table) 
--
CREATE TABLE OLIVER.TEST_RAO
(
  CO_NUMBER  VARCHAR2(10 BYTE)                  NOT NULL,
  CO_DIV     VARCHAR2(10 BYTE),
  CO_NAME1   VARCHAR2(50 BYTE),
  PLAN1      CHAR(4 BYTE),
  CLIENT1    CHAR(4 BYTE)
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


