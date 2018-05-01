--
-- INCOMPLETE_DATA_120717  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.INCOMPLETE_DATA_120717
(MEM_PLAN, EMPLOYER, CO_NAME, MEM_ID, MEM_SIN, 
 FULL_NAME, MEM_DOB, MEM_GENDER, ADDRESS, MEM_CITY, 
 MEM_POSTAL_CODE)
AS 
(SELECT  MEM_PLAN,HR_BANK_PKG.GET_EMPLOYER(mem_CLIENT_id,mem_PLAN,mem_ID,SYSDATE) EMPLOYER, CO_name,m.mem_id, m.mem_sin, m.mem_FIRST_NAME||' '||m.mem_last_name full_name,m.mem_dob,m.mem_gender,
 m.mem_ADDRESS1||' '||m.mem_ADDRESS2 address ,MEM_CITY,
 m.mem_POSTAL_CODE
FROM tbl_MEMBER m ,  tbl_COMPMAST c
WHERE mem_client_id=co_client and  CO_PLAN=MEM_PLAN 
and c.CO_NUMBER = GET_EMPLOYER_latest(mem_CLIENT_id,mem_PLAN,mem_ID,SYSDATE)
AND  ((mem_gender IS NULL ) 
   OR (mem_last_name IS NULL) 
   OR ltrim(rtrim( m.mem_ADDRESS1||' '||m.mem_ADDRESS2))  IS NULL  OR MEM_CITY IS NULL 
   OR (mem_dob is null) 
     OR (mem_postAL_code is null)  )
  
);


