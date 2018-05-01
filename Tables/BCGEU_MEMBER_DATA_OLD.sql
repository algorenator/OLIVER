--
-- BCGEU_MEMBER_DATA_OLD  (Table) 
--
CREATE TABLE OLIVER.BCGEU_MEMBER_DATA_OLD
(
  SIN                           VARCHAR2(128 BYTE),
  KEY_IDENTIFIER                VARCHAR2(12 BYTE),
  STATUS_IN_AIR_MEM_REC         VARCHAR2(1 BYTE),
  NEED_STATEMENT                VARCHAR2(10 BYTE),
  ON_EXCLUSION_LIST             VARCHAR2(13 BYTE),
  LAST_NAME                     VARCHAR2(17 BYTE),
  MIDDLE_NAME                   VARCHAR2(17 BYTE),
  FIRST_NAME                    VARCHAR2(18 BYTE),
  ADDR1                         VARCHAR2(37 BYTE),
  ADDR2                         VARCHAR2(50 BYTE),
  CITY                          VARCHAR2(20 BYTE),
  PROV                          VARCHAR2(10 BYTE),
  ZIP                           VARCHAR2(7 BYTE),
  COUNTRY                       VARCHAR2(6 BYTE),
  DOB                           VARCHAR2(11 BYTE),
  AGE                           VARCHAR2(18 BYTE),
  NRD                           VARCHAR2(10 BYTE),
  ERD                           VARCHAR2(10 BYTE),
  URD                           VARCHAR2(10 BYTE),
  PD                            VARCHAR2(10 BYTE),
  ERNAME                        VARCHAR2(42 BYTE),
  ERCODE                        VARCHAR2(9 BYTE),
  DOE                           VARCHAR2(11 BYTE),
  DPE                           VARCHAR2(11 BYTE),
  SPOUSE_LAST_NAME              VARCHAR2(16 BYTE),
  SPOUSE_MIDDLE_NAME            VARCHAR2(12 BYTE),
  SPOUSE_FIRST_NAME             VARCHAR2(14 BYTE),
  BENNAME_1                     VARCHAR2(29 BYTE),
  BENNAME_2                     VARCHAR2(22 BYTE),
  BENNAME_3                     VARCHAR2(21 BYTE),
  BENNAME_4                     VARCHAR2(20 BYTE),
  BENNAME_5                     VARCHAR2(13 BYTE),
  AHSEQ                         VARCHAR2(4 BYTE),
  FLAG                          VARCHAR2(5 BYTE),
  BOY_EE_POST                   VARCHAR2(18 BYTE),
  BOY_EE_PRE                    VARCHAR2(18 BYTE),
  BOY_VOL                       VARCHAR2(18 BYTE),
  BOY_TNLI_TLI                  VARCHAR2(18 BYTE),
  BOY_ER_POST                   VARCHAR2(18 BYTE),
  BOY_ER_PRE                    VARCHAR2(18 BYTE),
  BOY_IMMUNIZATION_IMM          VARCHAR2(9 BYTE),
  BOY_TOTAL                     VARCHAR2(18 BYTE),
  CONT_EE_POST                  VARCHAR2(18 BYTE),
  CONT_VOL                      VARCHAR2(18 BYTE),
  CONT_ER_POST                  VARCHAR2(18 BYTE),
  CONT_TOTAL                    VARCHAR2(18 BYTE),
  INT_EE_POST                   VARCHAR2(19 BYTE),
  INT_EE_PRE                    VARCHAR2(18 BYTE),
  INT_VOL                       VARCHAR2(20 BYTE),
  INT_TNLI_TLI                  VARCHAR2(19 BYTE),
  INT_ER_POST                   VARCHAR2(19 BYTE),
  INT_ER_PRE                    VARCHAR2(19 BYTE),
  INT_IMMUNIZATION_IMM          VARCHAR2(18 BYTE),
  INT_TOTAL                     VARCHAR2(18 BYTE),
  PAYOUT_EE_POST                VARCHAR2(18 BYTE),
  PAYOUT_EE_PRE                 VARCHAR2(18 BYTE),
  PAYOUT_VOL                    VARCHAR2(18 BYTE),
  PAYOUT_TNLI_TLI               VARCHAR2(18 BYTE),
  PAYOUT_ER_POST                VARCHAR2(18 BYTE),
  PAYOUT_ER_PRE                 VARCHAR2(18 BYTE),
  PAYOUT_IMMUNIZATION_IMM       VARCHAR2(9 BYTE),
  PAYOUT_TOTAL                  VARCHAR2(18 BYTE),
  EOY_EE_POST                   VARCHAR2(18 BYTE),
  EOY_EE_PRE                    VARCHAR2(18 BYTE),
  EOY_VOL                       VARCHAR2(18 BYTE),
  EOY_TNLI_TLI                  VARCHAR2(18 BYTE),
  EOY_ER_POST                   VARCHAR2(18 BYTE),
  EOY_ER_PRE                    VARCHAR2(18 BYTE),
  EOY_IMMUNIZATION_IMM          VARCHAR2(3 BYTE),
  EOY_TOTAL                     VARCHAR2(18 BYTE),
  PAYOUT_NLI                    VARCHAR2(18 BYTE),
  PAYOUT_LI                     VARCHAR2(18 BYTE),
  PAYOUT_NLI_WINT               VARCHAR2(18 BYTE),
  PAYOUT_LI_WINT                VARCHAR2(18 BYTE),
  PAYOUT_TOTAL_WINT             VARCHAR2(18 BYTE),
  TB_NLI                        VARCHAR2(18 BYTE),
  TB_LI                         VARCHAR2(18 BYTE),
  PSPB_PEN_JUNE_30              VARCHAR2(18 BYTE),
  PSPB_PEN_UNDER_65_JUNE_30     VARCHAR2(18 BYTE),
  PSPB_PEN_OVER_65_JUNE_30      VARCHAR2(18 BYTE),
  PSPB_PEN_JUNE_302             VARCHAR2(18 BYTE),
  EOY_NLI                       VARCHAR2(18 BYTE),
  EOY_LI                        VARCHAR2(18 BYTE),
  EOY_TNLI                      VARCHAR2(18 BYTE),
  EOY_TLI                       VARCHAR2(17 BYTE),
  PAYOUT_EE_POST_MB             VARCHAR2(8 BYTE),
  PAYOUT_EE_PRE_MB              VARCHAR2(3 BYTE),
  PAYOUT_VOL_MB                 VARCHAR2(3 BYTE),
  PAYOUT_TNLI_TLI_MB            VARCHAR2(3 BYTE),
  PAYOUT_ER_POST_MB             VARCHAR2(7 BYTE),
  PAYOUT_ER_PRE_MB              VARCHAR2(8 BYTE),
  PAYOUT_IMMUNIZATION_IMM_MB    VARCHAR2(3 BYTE),
  PAYOUT_TOTAL_MB               VARCHAR2(8 BYTE),
  PAYOUT_NLI_MB                 VARCHAR2(3 BYTE),
  PAYOUT_LI_MB                  VARCHAR2(8 BYTE),
  PAYOUT_NLI_WINT_MB            VARCHAR2(8 BYTE),
  PAYOUT_LI_WINT_MB             VARCHAR2(8 BYTE),
  PAYOUT_TOTAL_WINT_MB          VARCHAR2(8 BYTE),
  EE_CONT                       VARCHAR2(18 BYTE),
  ER_CONT                       VARCHAR2(18 BYTE),
  VOL_CONT                      VARCHAR2(19 BYTE),
  TB_PEN_UNDER_65_POST_JUNE_30  VARCHAR2(18 BYTE),
  TB_PEN_OVER_65_POST_JUNE_30   VARCHAR2(18 BYTE),
  TB_PEN_POST_JUNE_30           VARCHAR2(18 BYTE),
  INTEREST                      VARCHAR2(20 BYTE),
  EE_CONT_W_INTEREST            VARCHAR2(26 BYTE)
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


