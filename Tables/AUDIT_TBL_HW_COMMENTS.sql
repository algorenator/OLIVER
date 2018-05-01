--
-- AUDIT_TBL_HW_COMMENTS  (Table) 
--
CREATE TABLE OLIVER.AUDIT_TBL_HW_COMMENTS
(
  THC_ID        NUMBER                          NOT NULL,
  THC_DEC       VARCHAR2(1000 BYTE),
  THC_PLAN      VARCHAR2(10 BYTE)               NOT NULL,
  THC_BENEFIT   VARCHAR2(1 BYTE),
  THC_CLAIM     VARCHAR2(20 BYTE),
  THC_ISACTIVE  VARCHAR2(1 BYTE),
  THC_CLIENT    VARCHAR2(20 BYTE),
  AUDIT_ACTION  CHAR(1 BYTE),
  AUDIT_BY      VARCHAR2(2000 BYTE),
  AUDIT_AT      TIMESTAMP(6)
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


