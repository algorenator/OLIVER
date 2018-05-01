--
-- PENSION_MEMBERS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.PENSION_MEMBERS
(PENM_CLIENT, PENM_PLAN, CO_NUMBER, CO_NAME, MEM_ID, 
 MEM_LAST_NAME, MEM_FIRST_NAME, MEM_ADDRESS1, MEM_ADDRESS2, MEM_CITY, 
 MEM_PROV, MEM_POSTAL_CODE, PENM_STATUS, PENM_STATUS_DATE)
AS 
(SELECT 
  penm_client,PENM_PLAN,
   co_number,
    co_name,
    mem_id,
    mem_last_name,
    mem_first_name,
    mem_address1,
    mem_address2,
    mem_city,
    mem_prov,
    mem_postal_code,
      tps_status_desc PENM_STATUS,
    PENM_STATUS_date
    
  
  FROM tbl_member,
    TBL_PENMAST,
  tbl_compmast,tbl_pension_status 
  WHERE mem_client_id=tps_client and mem_plan=tps_plan and penm_status=tps_status and  mem_client_id=penm_client and mem_plan                                     =PENM_plan
  AND mem_id                                         =PENM_id
 AND CO_PLAN (+)                                       =PENM_PLAN
 AND CO_NUMBER(+)=PENM_EMPLOYER
  
  );


