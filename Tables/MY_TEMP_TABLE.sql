--
-- MY_TEMP_TABLE  (Table) 
--
CREATE GLOBAL TEMPORARY TABLE OLIVER.MY_TEMP_TABLE
(
  MEM_ID   VARCHAR2(100 BYTE)                   NOT NULL,
  MEM_SIN  NUMBER(9)
)
ON COMMIT DELETE ROWS
RESULT_CACHE (MODE DEFAULT);


