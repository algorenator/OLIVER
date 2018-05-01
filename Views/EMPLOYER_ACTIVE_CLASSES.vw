--
-- EMPLOYER_ACTIVE_CLASSES  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.EMPLOYER_ACTIVE_CLASSES
(TEC_CLIENT_ID, TEC_PLAN_ID, TEC_ER_ID, TEC_CLASS, BC_DESC, 
 CLASS_KEY, BC_ROWID)
AS 
select a.tec_client_id, a.tec_plan_id, a.tec_er_id, a.tec_class, bc.bc_desc, bc.bc_key class_key, bc.rowid bc_rowid
  from tbl_benefits_class bc, tbl_employer_classes a
 where a.tec_client_id = bc.bc_client_id
   and a.tec_plan_id = bc.bc_plan_id
   and a.tec_class_key = bc.bc_key
   and a.tec_eff_date = (
         select max(b.tec_eff_date)
           from tbl_employer_classes b
          where b.tec_client_id = a.tec_client_id
            and b.tec_plan_id = a.tec_plan_id
            and b.tec_er_id = a.tec_er_id
            and b.tec_class_key = a.tec_class_key
            and b.tec_eff_date <= sysdate
       );


