--
-- HW_EMPLOYEE_UNITS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.HW_EMPLOYEE_UNITS
(TD_CLIENT_ID, TD_PLAN_ID, TD_EMPLOYER, CO_NAME, TD_MEM_ID, 
 MEM_LAST_NAME, MEM_FIRST_NAME, TD_PERIOD, TD_UNITS, TD_AMOUNT, 
 TD_POSTED_DATE)
AS 
(select TD_CLIENT_ID,td_plan_id,td_employer,co_name,td_mem_id,mem_last_name,mem_first_name,td_period,td_units,td_amount,td_posted_date from transaction_detail,tbl_compmast,tbl_member where TD_CLIENT_ID=CO_CLIENT AND TD_CLIENT_ID=MEM_CLIENT_ID AND co_plan=mem_plan and td_mem_id=mem_id and co_plan=td_plan_id and co_number=td_employer);


