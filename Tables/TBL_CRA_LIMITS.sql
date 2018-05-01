--
-- TBL_CRA_LIMITS  (Table) 
--
CREATE TABLE OLIVER.TBL_CRA_LIMITS
(
  LIMITYEAR  VARCHAR2(20 BYTE),
  MPLIMIT    NUMBER,
  DBLIMIT    NUMBER,
  RRSPLIMIT  NUMBER,
  DPSPLIMIT  NUMBER,
  YMPE       NUMBER,
  CPP        NUMBER(7,2),
  OAS1       NUMBER(7,2),
  OAS2       NUMBER(7,2),
  OAS3       NUMBER(7,2),
  OAS4       NUMBER(7,2)
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


