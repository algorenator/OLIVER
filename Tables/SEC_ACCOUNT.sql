--
-- SEC_ACCOUNT  (Table) 
--
CREATE TABLE OLIVER.SEC_ACCOUNT
(
  ID            NUMBER Generated as Identity ( START WITH 384 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP GLOBAL) NOT NULL,
  ACCOUNT_NAME  VARCHAR2(255 BYTE)              NOT NULL,
  PROJECT_ID    NUMBER                          NOT NULL,
  TYPE          VARCHAR2(255 BYTE),
  URL           VARCHAR2(255 BYTE),
  USERNAME      VARCHAR2(255 BYTE)              NOT NULL,
  PASSWORD      VARCHAR2(255 BYTE),
  CREATED_BY    VARCHAR2(255 BYTE)              DEFAULT user,
  CREATED_ON    DATE                            DEFAULT sysdate,
  UPDATED_BY    VARCHAR2(255 BYTE)              DEFAULT user,
  UPDATED_ON    DATE                            DEFAULT sysdate,
  COMMENTS      VARCHAR2(4000 BYTE)
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


