--
-- TBL_RELATIONS  (Table) 
--
CREATE TABLE OLIVER.TBL_RELATIONS
(
  R_KEY          NUMBER,
  R_CODE         VARCHAR2(20 BYTE),
  R_DESCRIPTION  VARCHAR2(100 BYTE),
  PLAN_ID        VARCHAR2(20 BYTE),
  CLIENT_ID      VARCHAR2(20 BYTE)
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


