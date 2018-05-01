--
-- DB_ACTIVES  (Table) 
--
CREATE TABLE OLIVER.DB_ACTIVES
(
  PLANID                     VARCHAR2(300 BYTE),
  EMPLOYER                   VARCHAR2(300 BYTE),
  PERSON_ID                  VARCHAR2(300 BYTE),
  SIN                        VARCHAR2(300 BYTE),
  STATUS                     VARCHAR2(300 BYTE),
  LAST_NAME                  VARCHAR2(300 BYTE),
  FIRST_NAME                 VARCHAR2(300 BYTE),
  INITIAL1                   VARCHAR2(300 BYTE),
  GENDER                     VARCHAR2(300 BYTE),
  BIRTHDATE                  VARCHAR2(300 BYTE),
  HIREDATE                   VARCHAR2(300 BYTE),
  MARITAL                    VARCHAR2(300 BYTE),
  LANGUAGE1                  VARCHAR2(300 BYTE),
  SPOUSE_ID                  VARCHAR2(300 BYTE),
  SPOUSE_SIN                 VARCHAR2(300 BYTE),
  SPOUSE_BIRTHDATE           VARCHAR2(300 BYTE),
  ADDR1                      VARCHAR2(300 BYTE),
  CITY                       VARCHAR2(300 BYTE),
  PROV_STATE                 VARCHAR2(300 BYTE),
  COUNTRY                    VARCHAR2(300 BYTE),
  POSTALCODE                 VARCHAR2(300 BYTE),
  ACCRUED_PENSION_TO_2004    VARCHAR2(300 BYTE),
  ACCRUED_PENSION_FROM_2005  VARCHAR2(300 BYTE),
  PRE1995_HRS                VARCHAR2(300 BYTE),
  YR1995_CONTS               VARCHAR2(300 BYTE),
  YR1995_HRS                 VARCHAR2(300 BYTE),
  YR1996_CONTS               VARCHAR2(300 BYTE),
  YR1996_HRS                 VARCHAR2(300 BYTE),
  YR1997_CONTS               VARCHAR2(300 BYTE),
  YR1997_HRS                 VARCHAR2(300 BYTE),
  YR1998_CONTS               VARCHAR2(300 BYTE),
  YR1998_HRS                 VARCHAR2(300 BYTE),
  YR1999_CONTS               VARCHAR2(300 BYTE),
  YR1999_HRS                 VARCHAR2(300 BYTE),
  YR2000_CONTS               VARCHAR2(300 BYTE),
  YR2000_HRS                 VARCHAR2(300 BYTE),
  YR2001_CONTS               VARCHAR2(300 BYTE),
  YR2001_HRS                 VARCHAR2(300 BYTE),
  YR2002_CONTS               VARCHAR2(300 BYTE),
  YR2002_HRS                 VARCHAR2(300 BYTE),
  YR2003_CONTS               VARCHAR2(300 BYTE),
  YR2003_HRS                 VARCHAR2(300 BYTE),
  YR2004_CONTS               VARCHAR2(300 BYTE),
  YR2004_HRS                 VARCHAR2(300 BYTE),
  YR2005_CONTS               VARCHAR2(300 BYTE),
  YR2005_HRS                 VARCHAR2(300 BYTE),
  YR2006_CONTS               VARCHAR2(300 BYTE),
  YR2006_HRS                 VARCHAR2(300 BYTE),
  YR2007_CONTS               VARCHAR2(300 BYTE),
  YR2007_HRS                 VARCHAR2(300 BYTE),
  YR2008_CONTS               VARCHAR2(300 BYTE),
  YR2008_HRS                 VARCHAR2(300 BYTE),
  YR2009_CONTS               VARCHAR2(300 BYTE),
  YR2009_HRS                 VARCHAR2(300 BYTE),
  YR2010_CONTS               VARCHAR2(300 BYTE),
  YR2010_HRS                 VARCHAR2(300 BYTE),
  YR2011_CONTS               VARCHAR2(300 BYTE),
  YR2011_HRS                 VARCHAR2(300 BYTE),
  YR2012_CONTS               VARCHAR2(300 BYTE),
  YR2012_HRS                 VARCHAR2(300 BYTE),
  YR2013_CONTS               VARCHAR2(300 BYTE),
  YR2013_HRS                 VARCHAR2(300 BYTE),
  YR2014_CONTS               VARCHAR2(300 BYTE),
  YR2014_HRS                 VARCHAR2(300 BYTE),
  YR2015_CONTS               VARCHAR2(300 BYTE),
  YR2015_HRS                 VARCHAR2(300 BYTE)
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


