--
-- MEMBER_PORTAL_MACHINIST_TEMP  (Table) 
--
CREATE TABLE OLIVER.MEMBER_PORTAL_MACHINIST_TEMP
(
  MEMBER_ID        NUMBER(6),
  ANNUAL_PEN_2016  NUMBER(20,2)                 DEFAULT 0
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


