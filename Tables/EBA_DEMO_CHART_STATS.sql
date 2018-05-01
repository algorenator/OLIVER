--
-- EBA_DEMO_CHART_STATS  (Table) 
--
CREATE TABLE OLIVER.EBA_DEMO_CHART_STATS
(
  ID          NUMBER                            NOT NULL,
  NAME        VARCHAR2(2 BYTE),
  COUNTRY     VARCHAR2(30 BYTE),
  EMPLOYEE    NUMBER,
  EMPLOYER    NUMBER,
  TOTAL       NUMBER,
  CREATED     TIMESTAMP(6) WITH LOCAL TIME ZONE,
  CREATED_BY  VARCHAR2(255 BYTE),
  UPDATED     TIMESTAMP(6) WITH LOCAL TIME ZONE,
  UPDATED_BY  VARCHAR2(255 BYTE)
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

