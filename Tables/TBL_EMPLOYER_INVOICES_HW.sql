--
-- TBL_EMPLOYER_INVOICES_HW  (Table) 
--
CREATE TABLE OLIVER.TBL_EMPLOYER_INVOICES_HW
(
  EIH_CLIENT_ID    VARCHAR2(20 BYTE),
  EIH_PLAN_ID      VARCHAR2(20 BYTE),
  EIH_ER_ID        VARCHAR2(100 BYTE),
  EIH_MTH          DATE,
  EIH_LIFE_EE      NUMBER(12,2)                 DEFAULT 0,
  EIH_LIFE_ER      NUMBER(12,2)                 DEFAULT 0,
  EIH_ADD_EE       NUMBER(12,2)                 DEFAULT 0,
  EIH_ADD_ER       NUMBER(12,2)                 DEFAULT 0,
  EIH_OL_EE        NUMBER(12,2)                 DEFAULT 0,
  EIH_OL_ER        NUMBER(12,2)                 DEFAULT 0,
  EIH_DL_EE        NUMBER(12,2)                 DEFAULT 0,
  EIH_DL_ER        NUMBER(12,2)                 DEFAULT 0,
  EIH_LTD_EE       NUMBER(12,2)                 DEFAULT 0,
  EIH_LTD_ER       NUMBER(12,2)                 DEFAULT 0,
  EIH_WI_EE        NUMBER(12,2)                 DEFAULT 0,
  EIH_WI_ER        NUMBER(12,2)                 DEFAULT 0,
  EIH_EH_EE        NUMBER(12,2)                 DEFAULT 0,
  EIH_EH_ER        NUMBER(12,2)                 DEFAULT 0,
  EIH_DENT_EE      NUMBER(12,2)                 DEFAULT 0,
  EIH_DENT_ER      NUMBER(12,2)                 DEFAULT 0,
  EIH_OPEN_BAL     NUMBER(12,2)                 DEFAULT 0,
  EIH_PAYMENTS     NUMBER(12,2)                 DEFAULT 0,
  EIH_MISC         NUMBER(12,2)                 DEFAULT 0,
  EIH_ADJ          NUMBER(12,2)                 DEFAULT 0,
  EIH_CURR         NUMBER(12,2),
  EIH_CLOSE_BAL    NUMBER(12,2)                 DEFAULT 0,
  EIH_INVOICE_NUM  VARCHAR2(50 BYTE),
  EIH_DESCRIPTION  VARCHAR2(500 BYTE),
  EIH_PAID_DATE    DATE,
  EIH_CHEQ_NO      VARCHAR2(3000 BYTE)
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


