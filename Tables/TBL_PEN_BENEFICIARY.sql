--
-- TBL_PEN_BENEFICIARY  (Table) 
--
CREATE TABLE OLIVER.TBL_PEN_BENEFICIARY
(
  PB_PLAN                 VARCHAR2(10 BYTE)     NOT NULL,
  PB_ID                   VARCHAR2(15 BYTE)     NOT NULL,
  PB_BEN_NO               NUMBER,
  PB_LAST_NAME            VARCHAR2(100 BYTE),
  PB_FIRST_NAME           VARCHAR2(100 BYTE),
  PB_DOB                  DATE,
  PB_RELATION             VARCHAR2(100 BYTE),
  PB_BE_PER               NUMBER,
  PB_EFF_DATE             DATE,
  PB_TERM_DATE            DATE,
  PB_SEX                  VARCHAR2(1 BYTE)      DEFAULT 'M',
  PB_LAST_MODIFIED_BY     VARCHAR2(70 BYTE),
  PB_LAST_MODIFIED_DATE   DATE,
  PB_KEY                  NUMBER,
  PB_BENEFIT              VARCHAR2(20 BYTE),
  PB_MPE                  NUMBER(12,2)          DEFAULT 0,
  PB_WITHDRAW             NUMBER(12,2)          DEFAULT 0,
  PB_WITHDRAW_DATE        DATE,
  PB_ADDRESS1             VARCHAR2(100 BYTE),
  PB_ADDESS2              VARCHAR2(100 BYTE),
  PB_CITY                 VARCHAR2(100 BYTE),
  PB_PROV                 VARCHAR2(20 BYTE),
  PB_COUNTRY              VARCHAR2(100 BYTE)    DEFAULT 'CANADA',
  PB_BEN_ID               VARCHAR2(1000 BYTE),
  PB_BEN_SIN              NUMBER(9),
  PB_CLIENT               VARCHAR2(20 BYTE),
  PB_MIDDLE_NAME          VARCHAR2(100 BYTE),
  PB_POSTAL_CODE          VARCHAR2(20 BYTE),
  PB_ESTATE               VARCHAR2(1 BYTE)      DEFAULT 'N',
  PB_SPOUSE_WAIVE_RIGHTS  VARCHAR2(1 BYTE)      DEFAULT 'N',
  PB_TRUSTEE_GUARDIAN     VARCHAR2(100 BYTE),
  PB_TTEE_GUA_EFF_DATE    DATE,
  PB_TTEE_GUA_TERM_DATE   DATE,
  PB_LATE_APPLICANT       VARCHAR2(1 BYTE)      DEFAULT 'N'
)
TABLESPACE CDATV5DATAFILE
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


