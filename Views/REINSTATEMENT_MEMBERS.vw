--
-- REINSTATEMENT_MEMBERS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.REINSTATEMENT_MEMBERS
(MEM_CLIENT_ID, MEM_PLAN, MEM_ID, MEM_LAST_NAME, MEM_FIRST_NAME, 
 MEM_ADDRESS1, MEM_ADDRESS2, MEM_CITY, MEM_PROV, MEM_POSTAL_CODE, 
 HW_CLASS, HW_EMPLOYER, CO_NAME, BENEFIT_MONTH, MEM_GENDER, 
 MEM_DOB)
AS 
(SELECT mem_client_id,mem_plan,MEM_ID,MEM_LAST_NAME,MEM_FIRST_NAME,MEM_ADDRESS1,MEM_ADDRESS2,MEM_CITY,MEM_PROV,MEM_POSTAL_CODE,HW_CLASS,HW_EMPLOYER,CO_NAME,PL_HW_MONTHEND BENEFIT_MONTH,MEM_GENDER,MEM_DOB FROM TBL_MEMBER,TBL_HW,TBL_COMPMAST,TBL_PLAN WHERE pl_client_id =hw_client and PL_ID=MEM_PLAN AND mem_client_id=hw_client and mem_client_id=co_client and mem_plan=co_plan  and mem_client_id=pl_client_id and MEM_ID=HW_ID AND MEM_PLAN=HW_PLAN AND co_plan=hw_plan  AND HW_TERM_DATE IS NULL AND NVL(HW_EMPLOYER,HR_BANK_PKG.GET_EMPLOYER(HW_CLIENT,HW_PLAN,HW_ID,SYSDATE))=CO_NUMBER  AND HR_BANK_PKG.IS_ELIGIBLE(HW_CLIENT,HW_PLAN,NULL,HW_ID,ADD_MONTHS(PL_HW_MONTHEND,0))='Y' AND HR_BANK_PKG.IS_ELIGIBLE(HW_CLIENT,HW_PLAN,NULL,HW_ID,ADD_MONTHS(PL_HW_MONTHEND,-1))='N');


