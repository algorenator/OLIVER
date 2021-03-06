--
-- NO_HRS_18_MTHS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.NO_HRS_18_MTHS
(MEM_CLIENT_ID, MEM_PLAN, MEM_ID, MEM_LAST_NAME, MEM_FIRST_NAME, 
 EMPLOYER, HR_BANK, ER_NAME)
AS 
(select MEM_CLIENT_ID,mem_plan,mem_id,mem_last_name,mem_first_name,HR_BANK_PKG.GET_EMPLOYER(HW_CLIENT,HW_PLAN,HW_ID,SYSDATE) EMPLOYER,HR_BANK_PKG.GET_HR_BANK(MEM_CLIENT_ID,mem_plan,mem_ID ,sysdate) hr_bank,CO_NAME ER_NAME from tbl_member ,tbl_hw,tbl_compmast,TBL_PLAN  where MEM_CLIENT_ID=HW_CLIENT AND MEM_CLIENT_ID=CO_PLAN AND MEM_CLIENT_ID=PL_CLIENT_ID AND MEM_PLAN=PL_ID AND mem_plan=hw_plan and mem_id=hw_id and MEM_PLAN=CO_PLAN   and HR_BANK_PKG.GET_EMPLOYER(HW_CLIENT,HW_PLAN,HW_ID,SYSDATE)=co_number   AND HR_BANK_PKG.GET_HB_LRD(HW_CLIENT,HW_PLAN,NULL,HW_ID ,PL_HW_MONTHEND)<ADD_MONTHS(SYSDATE,-18));


