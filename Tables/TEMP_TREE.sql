--
-- TEMP_TREE  (Table) 
--
CREATE TABLE OLIVER.TEMP_TREE
(
  NAME         VARCHAR2(255 BYTE),
  CODE         VARCHAR2(255 BYTE),
  PARENT_CODE  VARCHAR2(255 BYTE),
  VALUE        VARCHAR2(255 BYTE),
  PLAN_ID      VARCHAR2(255 BYTE),
  GROUP_ID     VARCHAR2(255 BYTE)
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


