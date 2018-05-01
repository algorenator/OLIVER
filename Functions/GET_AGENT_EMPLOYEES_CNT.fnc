--
-- GET_AGENT_EMPLOYEES_CNT  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.get_agent_employees_cnt(
    p_plan_id   VARCHAR2,
    p_client_id VARCHAR2,
    p_er_id     VARCHAR2,
    p_date      DATE )
  RETURN NUMBER
AS
  retval NUMBER(10);
BEGIN
  SELECT COUNT(*)
  INTO retval
  FROM
    (SELECT get_employer_latest(p_client_id, p_plan_id, mem_id, p_date) er_id
    FROM
      (SELECT mem_id
      FROM tbl_member
      WHERE mem_plan    = p_plan_id
      AND mem_client_id = p_client_id
      )
    )
  WHERE er_id = p_er_id;
  RETURN retval;
END;
/

