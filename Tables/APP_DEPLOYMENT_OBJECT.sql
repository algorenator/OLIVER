--
-- APP_DEPLOYMENT_OBJECT  (Table) 
--
CREATE TABLE OLIVER.APP_DEPLOYMENT_OBJECT
(
  VERSION        NUMBER,
  OBJECTTYPE     VARCHAR2(100 BYTE),
  CHANGEDBY      VARCHAR2(20 BYTE),
  CHANGEDON      DATE,
  NOTES          VARCHAR2(1000 BYTE),
  OBJECTNAME     VARCHAR2(100 BYTE),
  APP_ID         NUMBER,
  SCRIPTDETAILS  VARCHAR2(4000 BYTE),
  CH_STORIES     VARCHAR2(200 BYTE),
  SCRIPT_ID      NUMBER Generated as Identity ( START WITH 863 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP GLOBAL) NOT NULL
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

COMMENT ON COLUMN OLIVER.APP_DEPLOYMENT_OBJECT.CH_STORIES IS 'stories # in ClubHouse related with this object ';



