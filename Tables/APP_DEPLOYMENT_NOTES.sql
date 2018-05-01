--
-- APP_DEPLOYMENT_NOTES  (Table) 
--
CREATE TABLE OLIVER.APP_DEPLOYMENT_NOTES
(
  DEP_ID      VARCHAR2(20 BYTE),
  NOTES       VARCHAR2(4000 BYTE),
  CREATED_BY  VARCHAR2(100 BYTE),
  CREATED_ON  DATE                              DEFAULT sysdate
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


