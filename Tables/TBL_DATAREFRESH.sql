--
-- TBL_DATAREFRESH  (Table) 
--
CREATE TABLE OLIVER.TBL_DATAREFRESH
(
  CLIENT_ID    VARCHAR2(20 BYTE),
  PLAN_ID      VARCHAR2(20 BYTE),
  REFRESHDATE  DATE
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


