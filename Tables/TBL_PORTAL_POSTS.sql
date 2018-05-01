--
-- TBL_PORTAL_POSTS  (Table) 
--
CREATE TABLE OLIVER.TBL_PORTAL_POSTS
(
  ID           NUMBER,
  USERID       NUMBER,
  DATECREATED  DATE                             DEFAULT sysdate,
  CONTENT      CLOB,
  TITLE        VARCHAR2(255 BYTE),
  ISACTIVE     VARCHAR2(1 BYTE)
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


