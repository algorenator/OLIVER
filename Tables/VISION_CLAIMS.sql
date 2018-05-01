--
-- VISION_CLAIMS  (Table) 
--
CREATE TABLE OLIVER.VISION_CLAIMS
(
  EH_CLAIM_NO       CHAR(8 BYTE),
  EH_UNIQUE         NUMBER(2),
  EH_DATE_RECD      DATE,
  EH_PLAN_NO        NUMBER(3),
  EH_SIN            VARCHAR2(10 BYTE),
  EH_DEP_NO         NUMBER(2),
  EH_BEN_CODE       NUMBER(2),
  EH_ENTRY_CODE     VARCHAR2(3 BYTE),
  EH_SERVICE_DATE   DATE,
  EH_DESC           VARCHAR2(10 BYTE),
  EH_COMM           NUMBER(3),
  EH_LOB            NUMBER(3),
  EH_AMT            NUMBER(7,2),
  EH_DISALLOW       NUMBER(7,2),
  EH_DED            NUMBER(7,2),
  EH_ACCEPT         NUMBER(7,2),
  EH_PAY            NUMBER(7,2),
  EH_OP_INITS       VARCHAR2(3 BYTE),
  EH_HIST_FLG       NUMBER(1),
  EH_PHARM_BEN_IND  VARCHAR2(5 BYTE),
  EH_LCA_IND        VARCHAR2(1 BYTE),
  EH_DIN            NUMBER(8),
  EH_DRUG_COST      NUMBER(12,2),
  EH_DISP_FEE       NUMBER(5,2),
  EH_LCA_COST       NUMBER(7,2),
  YEAR              NUMBER(4),
  EH_FOR_APPVL_FLG  NUMBER(1),
  EH_SUPER_FLG      NUMBER(1),
  EH_REJ_FLG        NUMBER(1),
  EH_CHEQ_FLG       NUMBER(1),
  EH_SPARE_FLG      NUMBER(1),
  EH_DUMMY          VARCHAR2(2 BYTE)
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


