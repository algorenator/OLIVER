--
-- MEM_ACTIVE_PLANS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.MEM_ACTIVE_PLANS
(CLIENT_ID, PLAN_ID, MEM_ID, PLAN_NAME, EFFECTIVE_DATE, 
 TERM_DATE, PLAN_TYPE, PLAN_GROUP, GROUP_TYPE_DESC)
AS 
select hw_client client_id,
         hw_plan plan_id,
         hw_id mem_id,
         pl_name plan_name,
         hw_eff_date effective_date,
         hw_term_date term_date,
         pl_type plan_type,
         pt_group_type plan_group,
         dim_pkg.get_group_type_desc(pt_group_type) group_type_desc
    from tbl_hw, tbl_plan, plan_types
   where hw_client = pl_client_id
     and hw_plan = pl_id
     and pl_type = pt_id
     AND pt_group_type IN ('HW')
   union
  select penm_client,
         penm_plan,
         penm_id,
         pl_name,
         penm_status_date,
         null,
         pl_type,
         pt_group_type,
         dim_pkg.get_group_type_desc(pt_group_type) group_type_desc
    from tbl_penmast, tbl_plan, plan_types
   where penm_client = pl_client_id
     and penm_plan = pl_id
     and pl_type = pt_id
     AND pt_group_type IN ('PEN');


