--
-- TBL_MEMBER_EXP  (Table) 
--
CREATE TABLE OLIVER.TBL_MEMBER_EXP
(
  MEM_ID    VARCHAR2(200 BYTE),
  MEM_DOB   DATE,
  MEM_PLAN  VARCHAR2(200 BYTE)
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


