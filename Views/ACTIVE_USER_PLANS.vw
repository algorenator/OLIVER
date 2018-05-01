--
-- ACTIVE_USER_PLANS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.ACTIVE_USER_PLANS
(PL_CLIENT_ID, USER_NAME, PL_ID, PL_NAME, USER_EFFECTIVE_DATE, 
 USER_TERMINATION_DATE)
AS 
( SELECT
        a.pl_client_id,
        b.user_name,
        a.pl_id,
        a.pl_name,
       -- c.admin_privileges,
        b.user_effective_date,
        b.user_termination_date
      FROM
        tbl_plan a,
        users b--,
      --  apex_access_control c
      WHERE
        a.pl_client_id = b.client_id
    --    AND   a.pl_client_id = c.client_id
    --    AND   a.pl_id = c.plan_id
    --    AND   b.user_name = c.admin_username
        AND   nvl(b.user_termination_date,SYSDATE) >= SYSDATE
    );


