--
-- TBL_VERIFICATION_LINK  (Table) 
--
CREATE TABLE OLIVER.TBL_VERIFICATION_LINK
(
  EMAIL              VARCHAR2(50 BYTE)          NOT NULL,
  REGISTERED         TIMESTAMP(6),
  VERIFICATION_CODE  RAW(16)
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


