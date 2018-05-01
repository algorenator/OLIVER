--
-- INCOMPLETE_DATA_PEN  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.INCOMPLETE_DATA_PEN
(MEM_CLIENT_ID, MEM_PLAN, EMPLOYER, CO_NAME, MEM_ID, 
 MEM_SIN, FULL_NAME, MEM_DOB, MEM_GENDER, ADDRESS, 
 MEM_CITY, MEM_POSTAL_CODE, PENM_STATUS)
AS 
SELECT  MEM_CLIENT_ID,MEM_PLAN,H.PENM_EMPLOYER EMPLOYER, CO_name,m.mem_id, m.mem_sin, m.mem_FIRST_NAME||' '||m.mem_last_name full_name,m.mem_dob,m.mem_gender,
 m.mem_ADDRESS1||' '||m.mem_ADDRESS2 address ,MEM_CITY,
 m.mem_POSTAL_CODE,
 tps_status_desc PENM_STATUS
FROM tbl_MEMBER m , tbl_PENMAST h, tbl_COMPMAST c,tbl_pension_status 
WHERE m.mem_client_id=tps_client and m.mem_plan=tps_plan and h.penm_status=tps_status and M.MEM_CLIENT_ID=H.PENM_CLIENT AND M.MEM_CLIENT_ID=C.CO_CLIENT AND M.mem_id = h.PENM_id AND PENM_PLAN=MEM_PLAN AND CO_PLAN(+)=MEM_PLAN 
and c.CO_NUMBER(+) = H.PENM_EMPLOYER
AND  (PENM_EMPLOYER IS NULL OR (mem_gender IS NULL ) 
   OR (mem_last_name IS NULL) 
   OR ( m.mem_ADDRESS1||' '||m.mem_ADDRESS2)  IS NULL  OR MEM_CITY IS NULL 
   OR (mem_dob is null) 
   or (PENM_STATUS is null)
   OR (mem_postAL_code is null)  );


