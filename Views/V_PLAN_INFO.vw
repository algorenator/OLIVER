--
-- V_PLAN_INFO  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.V_PLAN_INFO
(PLAN_GROUP, PLAN_TYPE, CLIENT_ID, PLAN_ID, PLAN_NAME)
AS 
SELECT
        pt_group_type plan_group,
        pl_type plan_type,
        pl_client_id client_id,
        pl_id plan_id,
        pl_name plan_name
    FROM
        tbl_plan p
        INNER JOIN plan_types pt ON p.pl_type = pt.pt_id
    ORDER BY
        pt_group_type, pl_type,
        pl_client_id,
        pl_id,
        pl_name;


