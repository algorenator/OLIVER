--
-- BCGEU_PENSIONERS  (Table) 
--
CREATE TABLE OLIVER.BCGEU_PENSIONERS
(
  NAME                  VARCHAR2(26 BYTE),
  SIN                   VARCHAR2(12 BYTE),
  DATE_OF_BIRTH         DATE,
  PENSION_TYPE          VARCHAR2(11 BYTE),
  COMPONENT             VARCHAR2(3 BYTE),
  SERVICE_END_DATE      DATE,
  PENSION_START         DATE,
  GTEE_END_DATE         DATE,
  ORIGINAL_PENSION      VARCHAR2(7 BYTE),
  PENSION_JAN_2018      VARCHAR2(26 BYTE),
  SPOUSE                VARCHAR2(20 BYTE),
  SPOUSE_DATE_OF_BIRTH  DATE,
  TEMP_ID               VARCHAR2(7 BYTE)
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


