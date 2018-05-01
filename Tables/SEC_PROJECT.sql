--
-- SEC_PROJECT  (Table) 
--
CREATE TABLE OLIVER.SEC_PROJECT
(
  ID            NUMBER Generated as Identity ( START WITH 143 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP GLOBAL) NOT NULL,
  PROJECT_NAME  VARCHAR2(255 BYTE)              NOT NULL,
  CREATED_BY    VARCHAR2(255 BYTE)              DEFAULT user,
  CREATED_ON    DATE                            DEFAULT sysdate,
  UPDATED_BY    VARCHAR2(255 BYTE)              DEFAULT user,
  UPDATED_ON    DATE                            DEFAULT sysdate
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


