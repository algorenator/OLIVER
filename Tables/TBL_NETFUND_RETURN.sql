--
-- TBL_NETFUND_RETURN  (Table) 
--
CREATE TABLE OLIVER.TBL_NETFUND_RETURN
(
  TNR_CLIENT_ID          VARCHAR2(20 BYTE),
  TNR_PLAN_ID            VARCHAR2(20 BYTE),
  TNR_YEAR               NUMBER,
  TNR_RETURN_PERCENTAGE  NUMBER(12,6)
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


