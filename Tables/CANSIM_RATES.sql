--
-- CANSIM_RATES  (Table) 
--
CREATE TABLE OLIVER.CANSIM_RATES
(
  CR_EFF_DATE  DATE,
  CR_RATE      NUMBER(9,6)
)
TABLESPACE CDATV5DATAFILE
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOCOMPRESS ;


