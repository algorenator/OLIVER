--
-- CDATRESOURCES  (Table) 
--
CREATE TABLE OLIVER.CDATRESOURCES
(
  NAME         VARCHAR2(100 BYTE),
  LOCATION     VARCHAR2(200 BYTE),
  ICON         VARCHAR2(200 BYTE),
  INFO         VARCHAR2(200 BYTE),
  DATECREATED  DATE                             DEFAULT sysdate
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


