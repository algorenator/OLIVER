--
-- EE_CONTRIBUTIONS_240118  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.EE_CONTRIBUTIONS_240118
(TD_CLIENT_ID, TD_PLAN_ID, TD_MEM_ID, PERIOD, CONTRIBUTIONS_TYPE, 
 HOURS, RATE, CONTRIBUTIONS)
AS 
(select td_client_id,td_plan_id,td_mem_id,trunc(td_period,'mm') Period,'Required' contributions_type,sum(tdt_pen_units) Hours,avg(td_rate) Rate,sum(tdt_ee_units) Contributions from transaction_detail where nvl(tdt_ee_units,0)<>0  group by td_client_id,td_plan_id,td_mem_id,trunc(td_period,'mm'))
union all
(select td_client_id,td_plan_id,td_mem_id,trunc(td_period,'mm') Period,'Employer' contributions_type,sum(tdt_pen_units) Hours,avg(td_rate) Rate,sum(tdt_er_units) Contributions from transaction_detail where nvl(tdt_er_units,0)<>0  group by td_client_id,td_plan_id,td_mem_id,trunc(td_period,'mm')) 
union all
(select td_client_id,td_plan_id,td_mem_id,trunc(td_period,'mm') Period,'Voluntary' contributions_type,sum(tdt_pen_units) Hours,avg(td_rate) Rate,sum(td_vol_units) Contributions from transaction_detail where nvl(td_vol_units,0)<>0 group by td_client_id,td_plan_id,td_mem_id,trunc(td_period,'mm'));


