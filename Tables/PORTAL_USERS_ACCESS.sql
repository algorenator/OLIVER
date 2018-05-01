--
-- PORTAL_USERS_ACCESS  (Table) 
--
CREATE TABLE OLIVER.PORTAL_USERS_ACCESS
(
  ID          NUMBER Generated as Identity ( START WITH 20 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP GLOBAL) NOT NULL,
  CLIENT_ID   VARCHAR2(20 BYTE)                 NOT NULL,
  PLAN_ID     VARCHAR2(20 BYTE)                 NOT NULL,
  PLAN_GROUP  VARCHAR2(20 BYTE)                 NOT NULL,
  PLAN_TYPE   VARCHAR2(20 BYTE)                 NOT NULL,
  USER_ID     NUMBER                            NOT NULL,
  PAGE_ID     NUMBER                            NOT NULL
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


