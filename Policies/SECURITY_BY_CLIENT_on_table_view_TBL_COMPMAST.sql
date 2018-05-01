--
-- SECURITY_BY_CLIENT on table/view TBL_COMPMAST  (Policy) 
--
BEGIN
  SYS.DBMS_RLS.ADD_POLICY     (
    object_schema          => 'OLIVER'
    ,object_name           => 'TBL_COMPMAST'
    ,policy_name           => 'SECURITY_BY_CLIENT'
    ,function_schema       => 'OLIVER'
    ,policy_function       => 'INIT.BY_EMP_CLIENT'
    ,statement_types       => 'SELECT,UPDATE,DELETE'
    ,policy_type           => dbms_rls.dynamic
    ,long_predicate        => FALSE
    ,update_check          => FALSE
    ,static_policy         => FALSE
    ,enable                => TRUE );
END;
/



