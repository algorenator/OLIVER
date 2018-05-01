--
-- TBL_EMPLOYMENT_HIST_BCGEU  (Table) 
--
CREATE TABLE OLIVER.TBL_EMPLOYMENT_HIST_BCGEU
(
  TEH_ID                  VARCHAR2(100 BYTE)    NOT NULL,
  TEH_ER_ID               VARCHAR2(100 BYTE)    NOT NULL,
  TEH_EFF_DATE            DATE,
  TEH_TREM_DATE           DATE,
  TEH_SALARY              NUMBER(12,2)          DEFAULT 0,
  TEH_PROCESS_DATE        DATE                  DEFAULT SYSDATE,
  TEH_LAST_MODIFIED_BY    VARCHAR2(100 BYTE),
  TEH_LAST_MODIFIED_DATE  DATE,
  TEH_OCCU                VARCHAR2(100 BYTE),
  TEH_EMPLOYMENT_TYPE     VARCHAR2(10 BYTE),
  TEH_PLAN                VARCHAR2(10 BYTE),
  TEH_CLIENT              VARCHAR2(20 BYTE),
  TEH_UNION_LOCAL         VARCHAR2(100 BYTE),
  TEH_AGREE_ID            VARCHAR2(20 BYTE),
  TEH_HIRE_DATE           DATE
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

