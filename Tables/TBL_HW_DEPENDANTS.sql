--
-- TBL_HW_DEPENDANTS  (Table) 
--
CREATE TABLE OLIVER.TBL_HW_DEPENDANTS
(
  HD_PLAN                VARCHAR2(10 BYTE)      NOT NULL,
  HD_ID                  VARCHAR2(15 BYTE)      NOT NULL,
  HD_BEN_NO              NUMBER,
  HD_LAST_NAME           VARCHAR2(100 BYTE),
  HD_FIRST_NAME          VARCHAR2(100 BYTE),
  HD_DOB                 DATE,
  HD_RELATION            VARCHAR2(100 BYTE),
  HD_BE_PER              NUMBER,
  HD_EFF_DATE            DATE,
  HD_TERM_DATE           DATE,
  HD_SEX                 VARCHAR2(1 BYTE)       DEFAULT 'M',
  HD_LAST_MODIFIED_BY    VARCHAR2(70 BYTE),
  HD_LAST_MODIFIED_DATE  DATE,
  HD_KEY                 NUMBER,
  HD_LATE_APP            VARCHAR2(1 BYTE)       DEFAULT 'N',
  HD_LATE_EFF_DATE       DATE,
  HD_LATE_TERM_DATE      DATE,
  HD_CLIENT              VARCHAR2(20 BYTE)
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


