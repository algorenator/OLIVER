--
-- TBL_CLAIMS  (Table) 
--
CREATE TABLE OLIVER.TBL_CLAIMS
(
  CL_PLAN            VARCHAR2(10 BYTE),
  CL_ID              VARCHAR2(20 BYTE),
  CL_DEP_NO          NUMBER,
  CL_CLAIM_NUMBER    VARCHAR2(100 BYTE),
  CL_CLAIM_TYPE      VARCHAR2(3 BYTE),
  CL_AMT_CLAIMED     NUMBER(12,2)               DEFAULT 0,
  CL_AMT_PAID        NUMBER(12,2)               DEFAULT 0,
  CL_USER            VARCHAR2(100 BYTE),
  CL_DATE_RECD       DATE                       DEFAULT sysdate,
  CL_DATE_PAID       DATE,
  CL_PAYMENT_NUMBER  VARCHAR2(50 BYTE),
  CL_BEN_CODE        NUMBER,
  CL_SERVICE_DATE    DATE,
  CL_COMMENT         NUMBER,
  CL_STATUS          VARCHAR2(1 BYTE)           DEFAULT 'I',
  CL_SERVICE_ID      NUMBER,
  CL_PAYMENT_TYPE    VARCHAR2(10 BYTE),
  CL_SELECTED        VARCHAR2(1 BYTE)           DEFAULT 'Y',
  CL_KEY             NUMBER,
  CL_OTHER_INS_AMT   NUMBER(12,2)               DEFAULT 0,
  CL_TRAN_DATE       DATE,
  CL_CLIENT_ID       VARCHAR2(20 BYTE),
  CL_REJECTED        VARCHAR2(1 BYTE)           DEFAULT 'N',
  POLICY             NUMBER,
  SUB_POLICY         NUMBER
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


