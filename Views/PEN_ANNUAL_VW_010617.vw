--
-- PEN_ANNUAL_VW_010617  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.PEN_ANNUAL_VW_010617
(TD_CLIENT_ID, TD_PLAN_ID, TD_EMPLOYER, CO_NAME, TD_MEM_ID, 
 MEM_LAST_NAME, MEM_FIRST_NAME, YEAR, EARNINGS, EE_CONTS, 
 ER_CONTS)
AS 
(select TD_CLIENT_ID,td_plan_id,td_employer,co_name,td_mem_id,mem_last_name,mem_first_name,TO_NUMBER(TO_CHAR(TD_PERIOD,'RRRR')) Year,SUM(DECODE(NVL(TD_UNITS_TYPE,'X'),'E',tdT_PEN_units,0)) EARNINGS,SUM(tdT_EE_units) EE_CONTS,SUM(tdT_ER_units) ER_CONTS from transaction_detail,tbl_compmast,tbl_member where co_plan=mem_plan and NVL(TDT_PEN_UNITS,0)<>0  AND td_mem_id=mem_id and co_plan=td_plan_id and co_number=td_employer GROUP BY TD_CLIENT_ID,td_plan_id,td_employer,co_name,td_mem_id,mem_last_name,mem_first_name,TO_NUMBER(TO_CHAR(TD_PERIOD,'RRRR')));


