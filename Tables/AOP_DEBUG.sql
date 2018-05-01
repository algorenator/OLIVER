--
-- AOP_DEBUG  (Table) 
--
CREATE TABLE OLIVER.AOP_DEBUG
(
  ID             NUMBER,
  DEBUG_DATE     DATE                           DEFAULT SYSDATE,
  P_MESSAGE      VARCHAR2(4000 BYTE),
  P0             VARCHAR2(4000 BYTE),
  P1             VARCHAR2(4000 BYTE),
  P2             VARCHAR2(4000 BYTE),
  P3             VARCHAR2(4000 BYTE),
  P4             VARCHAR2(4000 BYTE),
  P5             VARCHAR2(4000 BYTE),
  P6             VARCHAR2(4000 BYTE),
  P7             VARCHAR2(4000 BYTE),
  P8             VARCHAR2(4000 BYTE),
  P9             VARCHAR2(4000 BYTE),
  P10            VARCHAR2(4000 BYTE),
  P11            VARCHAR2(4000 BYTE),
  P12            VARCHAR2(4000 BYTE),
  P13            VARCHAR2(4000 BYTE),
  P14            VARCHAR2(4000 BYTE),
  P15            VARCHAR2(4000 BYTE),
  P16            VARCHAR2(4000 BYTE),
  P17            VARCHAR2(4000 BYTE),
  P18            VARCHAR2(4000 BYTE),
  P19            VARCHAR2(4000 BYTE),
  P_LEVEL        NUMBER(1),
  P_DESCRIPTION  CLOB
)
TABLESPACE USERS
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


