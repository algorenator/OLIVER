--
-- BCGEU_MEMBER_DATA  (Table) 
--
CREATE TABLE OLIVER.BCGEU_MEMBER_DATA
(
  SIN                    VARCHAR2(128 BYTE),
  KEY_IDENTIFIER         VARCHAR2(12 BYTE),
  STATUS_IN_AIR_MEM_REC  VARCHAR2(100 BYTE),
  CURR_STATUS            VARCHAR2(100 BYTE),
  LAST_NAME              VARCHAR2(100 BYTE),
  MIDDLE_NAME            VARCHAR2(100 BYTE),
  FIRST_NAME             VARCHAR2(100 BYTE),
  ADDR1                  VARCHAR2(100 BYTE),
  ADDR2                  VARCHAR2(100 BYTE),
  CITY                   VARCHAR2(100 BYTE),
  PROV                   VARCHAR2(100 BYTE),
  ZIP                    VARCHAR2(100 BYTE),
  COUNTRY                VARCHAR2(100 BYTE),
  DOB                    VARCHAR2(11 BYTE),
  ERNAME                 VARCHAR2(100 BYTE),
  ERCODE                 VARCHAR2(9 BYTE),
  DOE                    VARCHAR2(11 BYTE),
  DPE                    VARCHAR2(11 BYTE),
  SPOUSE_LAST_NAME       VARCHAR2(100 BYTE),
  SPOUSE_MIDDLE_NAME     VARCHAR2(100 BYTE),
  SPOUSE_FIRST_NAME      VARCHAR2(100 BYTE),
  SPOUSE_DOB             VARCHAR2(100 BYTE),
  BENNAME_1              VARCHAR2(100 BYTE),
  BENNAME_2              VARCHAR2(100 BYTE),
  BENNAME_3              VARCHAR2(100 BYTE),
  BENNAME_4              VARCHAR2(100 BYTE),
  BENNAME_5              VARCHAR2(100 BYTE),
  BENNAME_6              VARCHAR2(100 BYTE),
  BENNAME_7              VARCHAR2(100 BYTE),
  CONVERSION_TLI_AMT     NUMBER(12,2)           DEFAULT 0,
  EOY_EE_POST            VARCHAR2(18 BYTE),
  EOY_EE_PRE             VARCHAR2(18 BYTE),
  EOY_VOL                VARCHAR2(18 BYTE),
  EOY_ER_POST            VARCHAR2(18 BYTE),
  EOY_ER_PRE             VARCHAR2(18 BYTE),
  EOY_TOTAL              VARCHAR2(18 BYTE),
  TB_NLI                 VARCHAR2(18 BYTE),
  TB_LI                  VARCHAR2(26 BYTE),
  GENDER                 VARCHAR2(26 BYTE),
  EOY_TNLI               VARCHAR2(8 BYTE),
  EOY_TLI                VARCHAR2(8 BYTE)
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


