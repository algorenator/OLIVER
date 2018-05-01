--
-- AUDIT_TBL_PENMAST_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_PENMAST_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_PENMAST FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_PENMAST(PENM_ID
                             ,PENM_PLAN
                             ,PENM_ENTRY_DATE
                             ,PENM_HIRE_DATE
                             ,PENM_STATUS
                             ,PENM_STATUS_DATE
                             ,PENM_RECIPROCAL
                             ,PENM_LOCAL
                             ,PENM_EMPLOYER
                             ,PENM_PAST_SERV
                             ,PENM_PAST_PENSION
                             ,PENM_CURR_SERV
                             ,PENM_CURR_PENSION
                             ,PENM_MARITAL_STATUS
                             ,PENM_LRD
                             ,PENM_VP_PENSION
                             ,PENM_PROCESS_DATE
                             ,PENM_CLIENT
                             ,PENM_VETSED_DATE
                             ,PENM_PAST_PENSION_LI
                             ,PENM_LAST_MODIFIED_DATE
                             ,PENM_LAST_MODIFIED_BY
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.PENM_ID
                             ,:new.PENM_PLAN
                             ,:new.PENM_ENTRY_DATE
                             ,:new.PENM_HIRE_DATE
                             ,:new.PENM_STATUS
                             ,:new.PENM_STATUS_DATE
                             ,:new.PENM_RECIPROCAL
                             ,:new.PENM_LOCAL
                             ,:new.PENM_EMPLOYER
                             ,:new.PENM_PAST_SERV
                             ,:new.PENM_PAST_PENSION
                             ,:new.PENM_CURR_SERV
                             ,:new.PENM_CURR_PENSION
                             ,:new.PENM_MARITAL_STATUS
                             ,:new.PENM_LRD
                             ,:new.PENM_VP_PENSION
                             ,:new.PENM_PROCESS_DATE
                             ,:new.PENM_CLIENT
                             ,:new.PENM_VETSED_DATE
                             ,:new.PENM_PAST_PENSION_LI
                             ,:new.PENM_LAST_MODIFIED_DATE
                             ,:new.PENM_LAST_MODIFIED_BY
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.PENM_ID <> :new.PENM_ID) or (:old.PENM_ID IS NULL and  :new.PENM_ID IS NOT NULL)  or (:old.PENM_ID IS NOT NULL and  :new.PENM_ID IS NULL))
                 or( (:old.PENM_PLAN <> :new.PENM_PLAN) or (:old.PENM_PLAN IS NULL and  :new.PENM_PLAN IS NOT NULL)  or (:old.PENM_PLAN IS NOT NULL and  :new.PENM_PLAN IS NULL))
                 or( (:old.PENM_ENTRY_DATE <> :new.PENM_ENTRY_DATE) or (:old.PENM_ENTRY_DATE IS NULL and  :new.PENM_ENTRY_DATE IS NOT NULL)  or (:old.PENM_ENTRY_DATE IS NOT NULL and  :new.PENM_ENTRY_DATE IS NULL))
                 or( (:old.PENM_HIRE_DATE <> :new.PENM_HIRE_DATE) or (:old.PENM_HIRE_DATE IS NULL and  :new.PENM_HIRE_DATE IS NOT NULL)  or (:old.PENM_HIRE_DATE IS NOT NULL and  :new.PENM_HIRE_DATE IS NULL))
                 or( (:old.PENM_STATUS <> :new.PENM_STATUS) or (:old.PENM_STATUS IS NULL and  :new.PENM_STATUS IS NOT NULL)  or (:old.PENM_STATUS IS NOT NULL and  :new.PENM_STATUS IS NULL))
                 or( (:old.PENM_STATUS_DATE <> :new.PENM_STATUS_DATE) or (:old.PENM_STATUS_DATE IS NULL and  :new.PENM_STATUS_DATE IS NOT NULL)  or (:old.PENM_STATUS_DATE IS NOT NULL and  :new.PENM_STATUS_DATE IS NULL))
                 or( (:old.PENM_RECIPROCAL <> :new.PENM_RECIPROCAL) or (:old.PENM_RECIPROCAL IS NULL and  :new.PENM_RECIPROCAL IS NOT NULL)  or (:old.PENM_RECIPROCAL IS NOT NULL and  :new.PENM_RECIPROCAL IS NULL))
                 or( (:old.PENM_LOCAL <> :new.PENM_LOCAL) or (:old.PENM_LOCAL IS NULL and  :new.PENM_LOCAL IS NOT NULL)  or (:old.PENM_LOCAL IS NOT NULL and  :new.PENM_LOCAL IS NULL))
                 or( (:old.PENM_EMPLOYER <> :new.PENM_EMPLOYER) or (:old.PENM_EMPLOYER IS NULL and  :new.PENM_EMPLOYER IS NOT NULL)  or (:old.PENM_EMPLOYER IS NOT NULL and  :new.PENM_EMPLOYER IS NULL))
                 or( (:old.PENM_PAST_SERV <> :new.PENM_PAST_SERV) or (:old.PENM_PAST_SERV IS NULL and  :new.PENM_PAST_SERV IS NOT NULL)  or (:old.PENM_PAST_SERV IS NOT NULL and  :new.PENM_PAST_SERV IS NULL))
                 or( (:old.PENM_PAST_PENSION <> :new.PENM_PAST_PENSION) or (:old.PENM_PAST_PENSION IS NULL and  :new.PENM_PAST_PENSION IS NOT NULL)  or (:old.PENM_PAST_PENSION IS NOT NULL and  :new.PENM_PAST_PENSION IS NULL))
                 or( (:old.PENM_CURR_SERV <> :new.PENM_CURR_SERV) or (:old.PENM_CURR_SERV IS NULL and  :new.PENM_CURR_SERV IS NOT NULL)  or (:old.PENM_CURR_SERV IS NOT NULL and  :new.PENM_CURR_SERV IS NULL))
                 or( (:old.PENM_CURR_PENSION <> :new.PENM_CURR_PENSION) or (:old.PENM_CURR_PENSION IS NULL and  :new.PENM_CURR_PENSION IS NOT NULL)  or (:old.PENM_CURR_PENSION IS NOT NULL and  :new.PENM_CURR_PENSION IS NULL))
                 or( (:old.PENM_MARITAL_STATUS <> :new.PENM_MARITAL_STATUS) or (:old.PENM_MARITAL_STATUS IS NULL and  :new.PENM_MARITAL_STATUS IS NOT NULL)  or (:old.PENM_MARITAL_STATUS IS NOT NULL and  :new.PENM_MARITAL_STATUS IS NULL))
                 or( (:old.PENM_LRD <> :new.PENM_LRD) or (:old.PENM_LRD IS NULL and  :new.PENM_LRD IS NOT NULL)  or (:old.PENM_LRD IS NOT NULL and  :new.PENM_LRD IS NULL))
                 or( (:old.PENM_VP_PENSION <> :new.PENM_VP_PENSION) or (:old.PENM_VP_PENSION IS NULL and  :new.PENM_VP_PENSION IS NOT NULL)  or (:old.PENM_VP_PENSION IS NOT NULL and  :new.PENM_VP_PENSION IS NULL))
                 or( (:old.PENM_PROCESS_DATE <> :new.PENM_PROCESS_DATE) or (:old.PENM_PROCESS_DATE IS NULL and  :new.PENM_PROCESS_DATE IS NOT NULL)  or (:old.PENM_PROCESS_DATE IS NOT NULL and  :new.PENM_PROCESS_DATE IS NULL))
                 or( (:old.PENM_CLIENT <> :new.PENM_CLIENT) or (:old.PENM_CLIENT IS NULL and  :new.PENM_CLIENT IS NOT NULL)  or (:old.PENM_CLIENT IS NOT NULL and  :new.PENM_CLIENT IS NULL))
                 or( (:old.PENM_VETSED_DATE <> :new.PENM_VETSED_DATE) or (:old.PENM_VETSED_DATE IS NULL and  :new.PENM_VETSED_DATE IS NOT NULL)  or (:old.PENM_VETSED_DATE IS NOT NULL and  :new.PENM_VETSED_DATE IS NULL))
                 or( (:old.PENM_PAST_PENSION_LI <> :new.PENM_PAST_PENSION_LI) or (:old.PENM_PAST_PENSION_LI IS NULL and  :new.PENM_PAST_PENSION_LI IS NOT NULL)  or (:old.PENM_PAST_PENSION_LI IS NOT NULL and  :new.PENM_PAST_PENSION_LI IS NULL))
                 or( (:old.PENM_LAST_MODIFIED_DATE <> :new.PENM_LAST_MODIFIED_DATE) or (:old.PENM_LAST_MODIFIED_DATE IS NULL and  :new.PENM_LAST_MODIFIED_DATE IS NOT NULL)  or (:old.PENM_LAST_MODIFIED_DATE IS NOT NULL and  :new.PENM_LAST_MODIFIED_DATE IS NULL))
                 or( (:old.PENM_LAST_MODIFIED_BY <> :new.PENM_LAST_MODIFIED_BY) or (:old.PENM_LAST_MODIFIED_BY IS NULL and  :new.PENM_LAST_MODIFIED_BY IS NOT NULL)  or (:old.PENM_LAST_MODIFIED_BY IS NOT NULL and  :new.PENM_LAST_MODIFIED_BY IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_PENMAST(PENM_ID
                             ,PENM_PLAN
                             ,PENM_ENTRY_DATE
                             ,PENM_HIRE_DATE
                             ,PENM_STATUS
                             ,PENM_STATUS_DATE
                             ,PENM_RECIPROCAL
                             ,PENM_LOCAL
                             ,PENM_EMPLOYER
                             ,PENM_PAST_SERV
                             ,PENM_PAST_PENSION
                             ,PENM_CURR_SERV
                             ,PENM_CURR_PENSION
                             ,PENM_MARITAL_STATUS
                             ,PENM_LRD
                             ,PENM_VP_PENSION
                             ,PENM_PROCESS_DATE
                             ,PENM_CLIENT
                             ,PENM_VETSED_DATE
                             ,PENM_PAST_PENSION_LI
                             ,PENM_LAST_MODIFIED_DATE
                             ,PENM_LAST_MODIFIED_BY
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.PENM_ID
                             ,:new.PENM_PLAN
                             ,:new.PENM_ENTRY_DATE
                             ,:new.PENM_HIRE_DATE
                             ,:new.PENM_STATUS
                             ,:new.PENM_STATUS_DATE
                             ,:new.PENM_RECIPROCAL
                             ,:new.PENM_LOCAL
                             ,:new.PENM_EMPLOYER
                             ,:new.PENM_PAST_SERV
                             ,:new.PENM_PAST_PENSION
                             ,:new.PENM_CURR_SERV
                             ,:new.PENM_CURR_PENSION
                             ,:new.PENM_MARITAL_STATUS
                             ,:new.PENM_LRD
                             ,:new.PENM_VP_PENSION
                             ,:new.PENM_PROCESS_DATE
                             ,:new.PENM_CLIENT
                             ,:new.PENM_VETSED_DATE
                             ,:new.PENM_PAST_PENSION_LI
                             ,:new.PENM_LAST_MODIFIED_DATE
                             ,:new.PENM_LAST_MODIFIED_BY
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_PENMAST(PENM_ID
                             ,PENM_PLAN
                             ,PENM_ENTRY_DATE
                             ,PENM_HIRE_DATE
                             ,PENM_STATUS
                             ,PENM_STATUS_DATE
                             ,PENM_RECIPROCAL
                             ,PENM_LOCAL
                             ,PENM_EMPLOYER
                             ,PENM_PAST_SERV
                             ,PENM_PAST_PENSION
                             ,PENM_CURR_SERV
                             ,PENM_CURR_PENSION
                             ,PENM_MARITAL_STATUS
                             ,PENM_LRD
                             ,PENM_VP_PENSION
                             ,PENM_PROCESS_DATE
                             ,PENM_CLIENT
                             ,PENM_VETSED_DATE
                             ,PENM_PAST_PENSION_LI
                             ,PENM_LAST_MODIFIED_DATE
                             ,PENM_LAST_MODIFIED_BY
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.PENM_ID
                             ,:old.PENM_PLAN
                             ,:old.PENM_ENTRY_DATE
                             ,:old.PENM_HIRE_DATE
                             ,:old.PENM_STATUS
                             ,:old.PENM_STATUS_DATE
                             ,:old.PENM_RECIPROCAL
                             ,:old.PENM_LOCAL
                             ,:old.PENM_EMPLOYER
                             ,:old.PENM_PAST_SERV
                             ,:old.PENM_PAST_PENSION
                             ,:old.PENM_CURR_SERV
                             ,:old.PENM_CURR_PENSION
                             ,:old.PENM_MARITAL_STATUS
                             ,:old.PENM_LRD
                             ,:old.PENM_VP_PENSION
                             ,:old.PENM_PROCESS_DATE
                             ,:old.PENM_CLIENT
                             ,:old.PENM_VETSED_DATE
                             ,:old.PENM_PAST_PENSION_LI
                             ,:old.PENM_LAST_MODIFIED_DATE
                             ,:old.PENM_LAST_MODIFIED_BY
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


