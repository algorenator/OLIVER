--
-- BCGEU_EMPLOYERS_OLD  (Table) 
--
CREATE TABLE OLIVER.BCGEU_EMPLOYERS_OLD
(
  CONTRACT_AREA          VARCHAR2(26 BYTE),
  CONTACT                VARCHAR2(32 BYTE),
  EMAIL                  VARCHAR2(128 BYTE),
  ADDRESS                VARCHAR2(128 BYTE),
  TELEPHONE_FAX_NUMBERS  VARCHAR2(128 BYTE)
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


