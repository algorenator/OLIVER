--
-- TBL_HSA_ATTACHMENTS  (Table) 
--
CREATE TABLE OLIVER.TBL_HSA_ATTACHMENTS
(
  ID            NUMBER,
  CLAIM_NUMBER  VARCHAR2(20 BYTE),
  ATTACHMENT    BLOB,
  DATE_CREATED  DATE                            DEFAULT sysdate,
  PLAN_ID       VARCHAR2(20 BYTE),
  CLIENT_ID     VARCHAR2(20 BYTE),
  MIME_TYPE     VARCHAR2(255 BYTE),
  FILENAME      VARCHAR2(255 BYTE),
  CL_KEY        NUMBER
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


