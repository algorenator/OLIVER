--
-- TBL_PEN_OPT_DETAILS  (Table) 
--
CREATE TABLE OLIVER.TBL_PEN_OPT_DETAILS
(
  TPO_CLIENT      VARCHAR2(20 BYTE),
  TPO_PLAN        VARCHAR2(20 BYTE),
  TPO_MEM_ID      VARCHAR2(30 BYTE),
  TPO_PEN_FORM    VARCHAR2(255 BYTE),
  TPO_PEN_AMT     NUMBER(12,2)                  DEFAULT 0,
  TPO_FACTOR      NUMBER(12,6),
  TPO_INT_AMT     NUMBER(12,2),
  TPO_INT_FACTOR  NUMBER(12,6),
  TPO_ID          VARCHAR2(20 BYTE),
  TPO_CODE        VARCHAR2(20 BYTE)
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


