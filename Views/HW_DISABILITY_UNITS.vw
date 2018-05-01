--
-- HW_DISABILITY_UNITS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.HW_DISABILITY_UNITS
(TD_CLIENT_ID, TD_PLAN_ID, TD_EMPLOYER, CO_NAME, TD_MEM_ID, 
 MEM_LAST_NAME, MEM_FIRST_NAME, TD_PERIOD, TD_UNITS, TD_AMOUNT, 
 TD_POSTED_DATE)
AS 
(select TD_CLIENT_ID,td_plan_id,td_employer,co_name,td_mem_id,mem_last_name,mem_first_name,td_period,td_units,td_amount,td_posted_date from transaction_detail,tbl_compmast,tbl_member,TBL_DISABILITY where DIS_CLIENT=TD_CLIENT_ID AND DIS_CLIENT=MEM_CLIENT_ID AND DIS_CLIENT=CO_CLIENT AND DIS_PLAN=MEM_PLAN AND DIS_ID=MEM_ID AND  TD_PERIOD BETWEEN DIS_START_DATE AND NVL(DIS_RECOVERY_DATE,TD_PERIOD) AND co_plan=mem_plan and td_mem_id=mem_id and co_plan=td_plan_id and co_number=td_employer);


