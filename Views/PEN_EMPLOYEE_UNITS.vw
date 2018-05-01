--
-- PEN_EMPLOYEE_UNITS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.PEN_EMPLOYEE_UNITS
(TD_CLIENT_ID, TD_PLAN_ID, TD_EMPLOYER, CO_NAME, TD_MEM_ID, 
 MEM_LAST_NAME, MEM_FIRST_NAME, TD_START_DATE, TD_END_DATE, TDT_PEN_UNITS, 
 TD_POSTED_DATE, TD_PERIOD, EE_CONTS, ER_CONTS, VOL_CONTS, 
 TD_RATE)
AS 
(select TD_CLIENT_ID,td_plan_id,td_employer,co_name,td_mem_id,mem_last_name,mem_first_name,td_START_DATE,TD_END_DATE,tdT_PEN_units,td_posted_date,td_period,tdt_ee_units ee_conts,tdt_er_units er_conts,td_vol_units vol_conts,td_rate from transaction_detail,tbl_compmast,tbl_member where CO_CLIENT=TD_CLIENT_ID AND CO_CLIENT=MEM_CLIENT_ID AND co_plan=mem_plan and NVL(TDT_PEN_UNITS,0)<>0  AND td_mem_id=mem_id and co_plan=td_plan_id and co_number=td_employer);


