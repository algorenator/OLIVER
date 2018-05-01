--
-- LM_MEMBERS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.LM_MEMBERS
(PB_CLIENT, PB_PLAN, LM_LAST_NAME, LM_FIRST_NAME, LM_DOB, 
 LM_GENDER, LM_EFF_DATE, MPE, WITHDRAWN_AMT, WITHDRAWN_DATE, 
 MEM_ID, MEM_LAST_NAME, MEM_FIRST_NAME, MEM_ADDRESS1, MEM_ADDRESS2, 
 MEM_CITY, MEM_PROV, MEM_POSTAL_CODE, MEM_STATUS, MEM_STATUS_DATE)
AS 
(
SELECT DISTINCT 
  pB_client,PB_PLAN,
  PB_LAST_NAME LM_LAST_NAME,
  PB_FIRST_NAME LM_FIRST_NAME,
  PB_DOB LM_DOB,
  PB_SEX LM_GENDER,
  PB_TERM_DATE LM_EFF_DATE,
  PB_MPE MPE,
  PB_WITHDRAW WITHDRAWN_AMT,
  PB_WITHDRAW_DATE WITHDRAWN_DATE,
  mem_id,
    mem_last_name,
    mem_first_name,
    PB_ADDRESS1 mem_address1,
   NULL mem_address2,
    PB_CITY mem_city,
    PB_PROV mem_prov,
    PB_POSTAL_CODE mem_postal_code,
      tps_status_desc MEM_STATUS,
    PENM_STATUS_date MEM_STATUS_DATE
    
  
  FROM tbl_member,
    TBL_PENMAST,
  tbl_compmast,TBL_PEN_BENEFICIARY,tbl_pension_status
  WHERE mem_client_id =tps_client and mem_plan=tps_plan and penm_status=tps_status and mem_client_id=penm_client and mem_plan                                     =PENM_plan AND MEM_CLIENT_ID=PB_CLIENT AND MEM_PLAN=PB_PLAN AND MEM_ID=PB_ID AND NVL(LTRIM(RTRIM(PB_RELATION)),'XX')='LM' 
  AND mem_id                                         =PENM_id
 AND CO_PLAN (+)                                       =PENM_PLAN
 AND CO_NUMBER(+)=PENM_EMPLOYER);


