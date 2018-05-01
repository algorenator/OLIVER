--
-- PLAN_ASSUMPTIONS  (Table) 
--
CREATE TABLE OLIVER.PLAN_ASSUMPTIONS
(
  P_MORT        VARCHAR2(1000 BYTE),
  P_PROJSCALE   VARCHAR2(100 BYTE),
  P_PROJGEN     NUMBER,
  P_BASEYEAR    NUMBER,
  P_ATRATE1     NUMBER,
  P_PCTMALE     NUMBER,
  P_CLIENTMALE  NUMBER,
  P_PCTMARR     NUMBER,
  P_NFPCTMARR   NUMBER,
  P_NFGTEEMARR  NUMBER,
  P_NFPCTSING   NUMBER,
  P_NFGTEESING  NUMBER,
  P_DB          NUMBER,
  P_NRA         NUMBER
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


