--
-- APEX_MEMB_TEMP_TABLE  (Table) 
--
CREATE GLOBAL TEMPORARY TABLE OLIVER.APEX_MEMB_TEMP_TABLE
(
  MEM_ID   VARCHAR2(100 BYTE)                   NOT NULL,
  MEM_SIN  NUMBER,
  MEM_DOB  DATE,
  AGE      NUMBER
)
ON COMMIT DELETE ROWS
RESULT_CACHE (MODE DEFAULT);


