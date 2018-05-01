--
-- PEN_INACTIVITY_MEMBERS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.PEN_INACTIVITY_MEMBERS
(MEM_CLIENT_ID, MEM_PLAN, MEM_ID, MEM_LAST_NAME, MEM_FIRST_NAME, 
 EMPLOYER, ER_NAME, LRD)
AS 
(select mem_client_id,mem_plan,mem_id,mem_last_name,mem_first_name,penm_EMPLOYER EMPLOYER,CO_NAME ER_NAME, PENSION_PKG.get_pen_lrd(PENM_CLIENT,penm_PLAN,penm_ID,SYSDATE) LRD from tbl_member ,tbl_penmast,tbl_compmast  where mem_plan=penm_plan and mem_id=penm_id and NVL(PENM_STATUS,'A') in ('A','C')  AND mem_client_id=co_client(+) and MEM_PLAN=CO_PLAN(+) and penm_client=co_client(+) and  penm_EMPLOYER=co_number(+)   AND PENSION_PKG.get_pen_lrd(PENM_CLIENT,penm_PLAN,penm_ID,SYSDATE)<ADD_MONTHS(SYSDATE,-18));


