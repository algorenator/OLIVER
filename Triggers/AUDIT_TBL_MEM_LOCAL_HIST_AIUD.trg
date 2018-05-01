--
-- AUDIT_TBL_MEM_LOCAL_HIST_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_MEM_LOCAL_HIST_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_MEM_LOCAL_HIST FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_MEM_LOCAL_HIST(ML_CLIENT
                             ,ML_PLAN
                             ,ML_ID
                             ,ML_LOCAL
                             ,ML_EFF_DATE
                             ,ML_TERM_DATE
                             ,ML_ENTERED_DATE
                             ,ML_RECIPROCAL
                             ,ML_USR
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.ML_CLIENT
                             ,:new.ML_PLAN
                             ,:new.ML_ID
                             ,:new.ML_LOCAL
                             ,:new.ML_EFF_DATE
                             ,:new.ML_TERM_DATE
                             ,:new.ML_ENTERED_DATE
                             ,:new.ML_RECIPROCAL
                             ,:new.ML_USR
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.ML_CLIENT <> :new.ML_CLIENT) or (:old.ML_CLIENT IS NULL and  :new.ML_CLIENT IS NOT NULL)  or (:old.ML_CLIENT IS NOT NULL and  :new.ML_CLIENT IS NULL))
                 or( (:old.ML_PLAN <> :new.ML_PLAN) or (:old.ML_PLAN IS NULL and  :new.ML_PLAN IS NOT NULL)  or (:old.ML_PLAN IS NOT NULL and  :new.ML_PLAN IS NULL))
                 or( (:old.ML_ID <> :new.ML_ID) or (:old.ML_ID IS NULL and  :new.ML_ID IS NOT NULL)  or (:old.ML_ID IS NOT NULL and  :new.ML_ID IS NULL))
                 or( (:old.ML_LOCAL <> :new.ML_LOCAL) or (:old.ML_LOCAL IS NULL and  :new.ML_LOCAL IS NOT NULL)  or (:old.ML_LOCAL IS NOT NULL and  :new.ML_LOCAL IS NULL))
                 or( (:old.ML_EFF_DATE <> :new.ML_EFF_DATE) or (:old.ML_EFF_DATE IS NULL and  :new.ML_EFF_DATE IS NOT NULL)  or (:old.ML_EFF_DATE IS NOT NULL and  :new.ML_EFF_DATE IS NULL))
                 or( (:old.ML_TERM_DATE <> :new.ML_TERM_DATE) or (:old.ML_TERM_DATE IS NULL and  :new.ML_TERM_DATE IS NOT NULL)  or (:old.ML_TERM_DATE IS NOT NULL and  :new.ML_TERM_DATE IS NULL))
                 or( (:old.ML_ENTERED_DATE <> :new.ML_ENTERED_DATE) or (:old.ML_ENTERED_DATE IS NULL and  :new.ML_ENTERED_DATE IS NOT NULL)  or (:old.ML_ENTERED_DATE IS NOT NULL and  :new.ML_ENTERED_DATE IS NULL))
                 or( (:old.ML_RECIPROCAL <> :new.ML_RECIPROCAL) or (:old.ML_RECIPROCAL IS NULL and  :new.ML_RECIPROCAL IS NOT NULL)  or (:old.ML_RECIPROCAL IS NOT NULL and  :new.ML_RECIPROCAL IS NULL))
                 or( (:old.ML_USR <> :new.ML_USR) or (:old.ML_USR IS NULL and  :new.ML_USR IS NOT NULL)  or (:old.ML_USR IS NOT NULL and  :new.ML_USR IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_MEM_LOCAL_HIST(ML_CLIENT
                             ,ML_PLAN
                             ,ML_ID
                             ,ML_LOCAL
                             ,ML_EFF_DATE
                             ,ML_TERM_DATE
                             ,ML_ENTERED_DATE
                             ,ML_RECIPROCAL
                             ,ML_USR
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.ML_CLIENT
                             ,:new.ML_PLAN
                             ,:new.ML_ID
                             ,:new.ML_LOCAL
                             ,:new.ML_EFF_DATE
                             ,:new.ML_TERM_DATE
                             ,:new.ML_ENTERED_DATE
                             ,:new.ML_RECIPROCAL
                             ,:new.ML_USR
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_MEM_LOCAL_HIST(ML_CLIENT
                             ,ML_PLAN
                             ,ML_ID
                             ,ML_LOCAL
                             ,ML_EFF_DATE
                             ,ML_TERM_DATE
                             ,ML_ENTERED_DATE
                             ,ML_RECIPROCAL
                             ,ML_USR
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.ML_CLIENT
                             ,:old.ML_PLAN
                             ,:old.ML_ID
                             ,:old.ML_LOCAL
                             ,:old.ML_EFF_DATE
                             ,:old.ML_TERM_DATE
                             ,:old.ML_ENTERED_DATE
                             ,:old.ML_RECIPROCAL
                             ,:old.ML_USR
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


