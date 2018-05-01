--
-- TBL_HW_BENEFICIARY_220318  (Table) 
--
CREATE TABLE OLIVER.TBL_HW_BENEFICIARY_220318
(
  HB_PLAN                VARCHAR2(10 BYTE)      NOT NULL,
  HB_ID                  VARCHAR2(15 BYTE)      NOT NULL,
  HB_BEN_NO              NUMBER,
  HB_LAST_NAME           VARCHAR2(100 BYTE),
  HB_FIRST_NAME          VARCHAR2(100 BYTE),
  HB_DOB                 DATE,
  HB_RELATION            VARCHAR2(100 BYTE),
  HB_BE_PER              NUMBER,
  HB_EFF_DATE            DATE,
  HB_TERM_DATE           DATE,
  HB_SEX                 VARCHAR2(1 BYTE),
  HB_LAST_MODIFIED_BY    VARCHAR2(70 BYTE),
  HB_LAST_MODIFIED_DATE  DATE,
  HB_KEY                 NUMBER,
  HB_BENEFIT             VARCHAR2(20 BYTE),
  HB_CLIENT              VARCHAR2(20 BYTE),
  HB_LATE_APPLICANT      VARCHAR2(1 BYTE)
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


