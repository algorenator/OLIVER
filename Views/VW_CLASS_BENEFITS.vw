--
-- VW_CLASS_BENEFITS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.VW_CLASS_BENEFITS
(CLIENTID, PLANID, CLASSID, BENEFITID, BENDESC, 
 BM_BEN_TYPE, BM_BEN_GROUP)
AS 
(SELECT DISTINCT BC_CLIENT_ID CLIENTID,BC_PLAN_ID PLANID,BC_ID CLASSID,BAB_BENEFIT BENEFITID,X.BM_DESC BENDESC,X.BM_BEN_TYPE,X.BM_BEN_GROUP FROM TBL_BENEFITS_CLASS,BENEFITS_AGE_BASED A,TBL_BENEFITS_MASTER X WHERE BC_CLIENT_ID=A.BAB_CLIENT_ID AND BC_PLAN_ID=A.BAB_PLAN_ID AND BC_CLIENT_ID=BM_CLIENT_ID AND BC_PLAN_ID=BM_PLAN  AND A.BAB_BENEFIT=BM_CODE  AND BC_ID=A.BAB_CLASS and a.bab_term_date is null  and A.bab_eff_date=(select max(B.bab_eff_date) from benefits_age_based B where B.bab_client_id=A.BAB_CLIENT_ID and B.bab_plan_id=A.BAB_PLAN_ID and B.bab_benefit IN (SELECT Y.BM_CODE FROM TBL_BENEFITS_MASTER Y WHERE Y.BM_CLIENT_ID=X.BM_CLIENT_ID AND Y.BM_PLAN =X.BM_PLAN AND Y.BM_BEN_GROUP=X.BM_BEN_GROUP) AND BC_ID=B.BAB_CLASS and B.bab_eff_date<=sysdate) )
UNION
(SELECT DISTINCT BC_CLIENT_ID CLIENTID,BC_PLAN_ID PLANID,BC_ID CLASSID,BDB_BENEFIT BENEFITID,X.BM_DESC BENDESC,X.BM_BEN_TYPE,X.BM_BEN_GROUP FROM TBL_BENEFITS_CLASS,BENEFITS_DEP_BASED A,TBL_BENEFITS_MASTER X WHERE BC_CLIENT_ID=A.BDB_CLIENT_ID AND BC_PLAN_ID=A.BDB_PLAN_ID AND BC_CLIENT_ID=BM_CLIENT_ID AND BC_PLAN_ID=BM_PLAN  AND A.BDB_BENEFIT=BM_CODE  AND BC_ID=A.BDB_CLASS and  a.bdb_term_date is null and  A.bDb_eff_date=(select max(B.bDb_eff_date) from benefits_DEP_based B where B.bDb_client_id=A.BDB_CLIENT_ID and B.bDb_plan_id=A.BDB_PLAN_ID and B.bDb_benefit IN (SELECT Y.BM_CODE FROM TBL_BENEFITS_MASTER Y WHERE Y.BM_CLIENT_ID=X.BM_CLIENT_ID AND Y.BM_PLAN =X.BM_PLAN AND Y.BM_BEN_GROUP=X.BM_BEN_GROUP) and BC_ID=B.BDB_CLASS AND B.bDb_eff_date<=sysdate) )
UNION
(SELECT DISTINCT BC_CLIENT_ID CLIENTID,BC_PLAN_ID PLANID,BC_ID CLASSID,BVB_BENEFIT BENEFITID,X.BM_DESC BENDESC,X.BM_BEN_TYPE,X.BM_BEN_GROUP FROM TBL_BENEFITS_CLASS,BENEFITS_VOLUME_BASED A,TBL_BENEFITS_MASTER X WHERE BC_CLIENT_ID=A.BVB_CLIENT_ID AND BC_PLAN_ID=A.BVB_PLAN_ID AND BC_CLIENT_ID=BM_CLIENT_ID AND BC_PLAN_ID=BM_PLAN  AND A.BVB_BENEFIT=BM_CODE  AND BC_ID=A.BVB_CLASS and a.bvb_term_date is null and A.bVb_effECTIVE_date=(select max(B.bVb_effECTIVE_date) from benefits_VOLUME_based B where B.bVb_client_id=A.BVB_CLIENT_ID and B.bVb_plan_id=A.BVB_PLAN_ID and B.bVb_benefit IN (SELECT Y.BM_CODE FROM TBL_BENEFITS_MASTER Y WHERE Y.BM_CLIENT_ID=X.BM_CLIENT_ID AND Y.BM_PLAN =X.BM_PLAN AND Y.BM_BEN_GROUP=X.BM_BEN_GROUP) AND BC_ID=B.BVB_CLASS AND B.bVb_effECTIVE_date<=sysdate) );

