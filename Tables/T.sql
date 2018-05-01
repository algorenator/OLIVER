--
-- T  (Table) 
--
CREATE TABLE OLIVER.T
(
  OBJECT_ID       NUMBER                        NOT NULL,
  SUBOBJECT_NAME  VARCHAR2(128 BYTE),
  DATA_OBJECT_ID  NUMBER,
  OBJECT_TYPE     VARCHAR2(23 BYTE),
  CREATED         DATE                          NOT NULL,
  OBJECT_NAME     VARCHAR2(128 BYTE)            NOT NULL,
  OWNER           VARCHAR2(128 BYTE)            NOT NULL
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


