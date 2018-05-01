--
-- TEMP_TEST  (Table) 
--
CREATE TABLE OLIVER.TEMP_TEST
(
  ID              NUMBER Generated as Identity ( START WITH 261 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP GLOBAL) NOT NULL,
  COL1            VARCHAR2(200 BYTE),
  COL2            VARCHAR2(2000 BYTE),
  COL3            CLOB,
  COL4            BLOB,
  MU_EE_ACCOUNT   VARCHAR2(10 BYTE),
  MU_ER_ACCOUNT   VARCHAR2(10 BYTE),
  MU_VOL_ACCOUNT  VARCHAR2(10 BYTE)
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


