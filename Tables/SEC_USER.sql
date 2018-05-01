--
-- SEC_USER  (Table) 
--
CREATE TABLE OLIVER.SEC_USER
(
  ID                 NUMBER Generated as Identity ( START WITH 66 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP GLOBAL) NOT NULL,
  FIRST_NAME         VARCHAR2(255 BYTE)         NOT NULL,
  LAST_NAME          VARCHAR2(255 BYTE)         NOT NULL,
  EMAIL              VARCHAR2(255 BYTE)         NOT NULL,
  USER_NAME          VARCHAR2(255 BYTE)         NOT NULL,
  PASSWORD           VARCHAR2(255 BYTE)         NOT NULL,
  IS_INTERNAL_ADMIN  VARCHAR2(1 BYTE)           NOT NULL,
  ENABLED            VARCHAR2(1 BYTE)           NOT NULL,
  CREATED_BY         VARCHAR2(255 BYTE)         DEFAULT user,
  CREATED_ON         DATE                       DEFAULT sysdate,
  UPDATED_BY         VARCHAR2(255 BYTE)         DEFAULT user,
  UPDATED_ON         DATE                       DEFAULT sysdate
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


