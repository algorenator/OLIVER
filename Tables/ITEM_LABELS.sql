--
-- ITEM_LABELS  (Table) 
--
CREATE TABLE OLIVER.ITEM_LABELS
(
  ITEM_NAME   VARCHAR2(255 BYTE),
  ITEM_LABEL  VARCHAR2(4000 BYTE),
  LANG        VARCHAR2(10 BYTE),
  ISVALUE     VARCHAR2(1 BYTE)                  DEFAULT 'Y'                   NOT NULL
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


