--
-- APEX_PAGE_ACCESS  (Table) 
--
CREATE TABLE OLIVER.APEX_PAGE_ACCESS
(
  APP_ID       NUMBER,
  PAGE_ID      NUMBER,
  USER_ID      VARCHAR2(255 BYTE),
  CLIENT_ID    VARCHAR2(255 BYTE),
  ACCESS_DATE  DATE
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


