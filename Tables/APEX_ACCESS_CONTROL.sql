--
-- APEX_ACCESS_CONTROL  (Table) 
--
CREATE TABLE OLIVER.APEX_ACCESS_CONTROL
(
  ID                NUMBER,
  ADMIN_PRIVILEGES  VARCHAR2(100 BYTE),
  CREATED_BY        VARCHAR2(100 BYTE),
  CREATED_ON        DATE,
  UPDATED_ON        DATE,
  UPDATED_BY        VARCHAR2(100 BYTE),
  PLAN_ID           VARCHAR2(15 BYTE),
  CLIENT_ID         VARCHAR2(15 BYTE),
  MODULE_ID         VARCHAR2(20 BYTE),
  COLUMN3           VARCHAR2(20 BYTE),
  PAGE_ID           VARCHAR2(10 BYTE),
  EMP_MEMBER_ID     VARCHAR2(15 BYTE),
  GROUP_ID          NUMBER,
  USER_ID           NUMBER
)
TABLESPACE CDATV5DATAFILE
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          16K
            NEXT             16K
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOCOMPRESS ;

