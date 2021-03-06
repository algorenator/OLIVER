--
-- BACKUP_USER_GROUPS  (Table) 
--
CREATE TABLE OLIVER.BACKUP_USER_GROUPS
(
  GROUPID          NUMBER,
  GROUP_DESC       VARCHAR2(1000 BYTE),
  G_CLIENT_ID      VARCHAR2(15 BYTE),
  G_PLAN_TYPE      VARCHAR2(10 BYTE),
  G_MODULE         VARCHAR2(100 BYTE),
  G_PAGE           VARCHAR2(100 BYTE),
  G_COMPONENT      VARCHAR2(100 BYTE),
  G_LEVEL          VARCHAR2(2 BYTE),
  G_MODIFIED_DATE  DATE
)
TABLESPACE CDATV5DATAFILE
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


