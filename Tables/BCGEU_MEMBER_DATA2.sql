--
-- BCGEU_MEMBER_DATA2  (Table) 
--
CREATE TABLE OLIVER.BCGEU_MEMBER_DATA2
(
  SIN                 VARCHAR2(26 BYTE),
  LAST_NAME           VARCHAR2(17 BYTE),
  MIDDLE_NAME         VARCHAR2(17 BYTE),
  FIRST_NAME          VARCHAR2(14 BYTE),
  ADDR1               VARCHAR2(30 BYTE),
  ADDR2               VARCHAR2(26 BYTE),
  CITY                VARCHAR2(20 BYTE),
  PROV                VARCHAR2(2 BYTE),
  ZIP                 VARCHAR2(7 BYTE),
  COUNTRY             VARCHAR2(6 BYTE),
  DOB                 VARCHAR2(10 BYTE),
  ERNAME              VARCHAR2(39 BYTE),
  ERCODE              VARCHAR2(9 BYTE),
  DOE                 VARCHAR2(11 BYTE),
  DPE                 VARCHAR2(11 BYTE),
  SPOUSE_LAST_NAME    VARCHAR2(17 BYTE),
  SPOUSE_MIDDLE_NAME  VARCHAR2(16 BYTE),
  SPOUSE_FIRST_NAME   VARCHAR2(10 BYTE),
  BENNAME_1           VARCHAR2(33 BYTE),
  BENNAME_2           VARCHAR2(30 BYTE),
  BENNAME_3           VARCHAR2(29 BYTE),
  BENNAME_4           VARCHAR2(23 BYTE),
  BENNAME_5           VARCHAR2(18 BYTE),
  ASSUMED_GENDER      VARCHAR2(1 BYTE)
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


