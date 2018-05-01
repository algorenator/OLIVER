--
-- EXPORT_QUERY  (Table) 
--
CREATE TABLE OLIVER.EXPORT_QUERY
(
  ID            NUMBER Generated as Identity ( START WITH 561 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP GLOBAL) NOT NULL,
  TABLE_NAME    VARCHAR2(200 BYTE),
  WHERE_STRING  VARCHAR2(2000 BYTE)
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

