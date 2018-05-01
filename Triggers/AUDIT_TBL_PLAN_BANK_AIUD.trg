--
-- AUDIT_TBL_PLAN_BANK_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_PLAN_BANK_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_PLAN_BANK FOR EACH ROW
/* Generated automatically by AUDIT_UTILS.CREATE_AUDIT_TRIGGERS() */
DECLARE 
 v_user varchar2(2000):=null;
 v_action varchar2(15);
BEGIN
   SELECT SYS_CONTEXT ('USERENV', 'session_user')||' | '
            ||  SYS_CONTEXT ('USERENV', 'IP_ADDRESS')||' | '
            ||  SYS_CONTEXT ('USERENV', 'OS_USER')||' | '
            ||  SYS_CONTEXT ('USERENV', 'MODULE')||' | '
              session_user
   INTO v_user
   FROM DUAL;

BEGIN
v_user:=v_user||CHR(10)||owa_util.get_cgi_env('HTTP_HOST');           
v_user:=v_user||CHR(10)||owa_util.get_cgi_env('HTTP_PORT');           
v_user:=v_user||CHR(10)||owa_util.get_cgi_env('HTTP_REFERER');        
v_user:=v_user||CHR(10)||owa_util.get_cgi_env('HTTP_USER_AGENT');     
v_user:=v_user||CHR(10)||owa_util.get_cgi_env('PATH_INFO');           
v_user:=v_user||CHR(10)||owa_util.get_cgi_env('REMOTE_ADDR');         
v_user:=v_user||CHR(10)||owa_util.get_cgi_env('REMOTE_USER');         
v_user:=v_user||CHR(10)||owa_util.get_cgi_env('REQUEST_METHOD');      
v_user:=v_user||CHR(10)||owa_util.get_cgi_env('REQUEST_PROTOCOL');    
v_user:=v_user||CHR(10)||apex_authentication.get_login_username_cookie; 
EXCEPTION WHEN OTHERS THEN NULL;
END;
 if inserting then 
 v_action:='INSERT';
      insert into OLIVER.AUDIT_TBL_PLAN_BANK(TPB_CLIENT
                             ,TPB_PLAN
                             ,TPB_SUB_PLAN
                             ,TPB_EFF_DATE
                             ,TPB_TRANSIT
                             ,TPB_BRANCH
                             ,TPB_ACCOUNT
                             ,TPB_PLAN_TYPE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.TPB_CLIENT
                             ,:new.TPB_PLAN
                             ,:new.TPB_SUB_PLAN
                             ,:new.TPB_EFF_DATE
                             ,:new.TPB_TRANSIT
                             ,:new.TPB_BRANCH
                             ,:new.TPB_ACCOUNT
                             ,:new.TPB_PLAN_TYPE
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.TPB_CLIENT <> :new.TPB_CLIENT) or (:old.TPB_CLIENT IS NULL and  :new.TPB_CLIENT IS NOT NULL)  or (:old.TPB_CLIENT IS NOT NULL and  :new.TPB_CLIENT IS NULL))
                 or( (:old.TPB_PLAN <> :new.TPB_PLAN) or (:old.TPB_PLAN IS NULL and  :new.TPB_PLAN IS NOT NULL)  or (:old.TPB_PLAN IS NOT NULL and  :new.TPB_PLAN IS NULL))
                 or( (:old.TPB_SUB_PLAN <> :new.TPB_SUB_PLAN) or (:old.TPB_SUB_PLAN IS NULL and  :new.TPB_SUB_PLAN IS NOT NULL)  or (:old.TPB_SUB_PLAN IS NOT NULL and  :new.TPB_SUB_PLAN IS NULL))
                 or( (:old.TPB_EFF_DATE <> :new.TPB_EFF_DATE) or (:old.TPB_EFF_DATE IS NULL and  :new.TPB_EFF_DATE IS NOT NULL)  or (:old.TPB_EFF_DATE IS NOT NULL and  :new.TPB_EFF_DATE IS NULL))
                 or( (:old.TPB_TRANSIT <> :new.TPB_TRANSIT) or (:old.TPB_TRANSIT IS NULL and  :new.TPB_TRANSIT IS NOT NULL)  or (:old.TPB_TRANSIT IS NOT NULL and  :new.TPB_TRANSIT IS NULL))
                 or( (:old.TPB_BRANCH <> :new.TPB_BRANCH) or (:old.TPB_BRANCH IS NULL and  :new.TPB_BRANCH IS NOT NULL)  or (:old.TPB_BRANCH IS NOT NULL and  :new.TPB_BRANCH IS NULL))
                 or( (:old.TPB_ACCOUNT <> :new.TPB_ACCOUNT) or (:old.TPB_ACCOUNT IS NULL and  :new.TPB_ACCOUNT IS NOT NULL)  or (:old.TPB_ACCOUNT IS NOT NULL and  :new.TPB_ACCOUNT IS NULL))
                 or( (:old.TPB_PLAN_TYPE <> :new.TPB_PLAN_TYPE) or (:old.TPB_PLAN_TYPE IS NULL and  :new.TPB_PLAN_TYPE IS NOT NULL)  or (:old.TPB_PLAN_TYPE IS NOT NULL and  :new.TPB_PLAN_TYPE IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_PLAN_BANK(TPB_CLIENT
                             ,TPB_PLAN
                             ,TPB_SUB_PLAN
                             ,TPB_EFF_DATE
                             ,TPB_TRANSIT
                             ,TPB_BRANCH
                             ,TPB_ACCOUNT
                             ,TPB_PLAN_TYPE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.TPB_CLIENT
                             ,:new.TPB_PLAN
                             ,:new.TPB_SUB_PLAN
                             ,:new.TPB_EFF_DATE
                             ,:new.TPB_TRANSIT
                             ,:new.TPB_BRANCH
                             ,:new.TPB_ACCOUNT
                             ,:new.TPB_PLAN_TYPE
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_PLAN_BANK(TPB_CLIENT
                             ,TPB_PLAN
                             ,TPB_SUB_PLAN
                             ,TPB_EFF_DATE
                             ,TPB_TRANSIT
                             ,TPB_BRANCH
                             ,TPB_ACCOUNT
                             ,TPB_PLAN_TYPE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.TPB_CLIENT
                             ,:old.TPB_PLAN
                             ,:old.TPB_SUB_PLAN
                             ,:old.TPB_EFF_DATE
                             ,:old.TPB_TRANSIT
                             ,:old.TPB_BRANCH
                             ,:old.TPB_ACCOUNT
                             ,:old.TPB_PLAN_TYPE
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


