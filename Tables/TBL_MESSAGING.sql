--
-- TBL_MESSAGING  (Table) 
--
CREATE TABLE OLIVER.TBL_MESSAGING
(
  ID        NUMBER,
  SENTFROM  NUMBER,
  SENTTO    NUMBER,
  MESSAGE   VARCHAR2(1000 BYTE),
  DATESENT  DATE                                DEFAULT sysdate,
  STATUS    NUMBER                              DEFAULT 1,
  REPLYID   NUMBER
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


