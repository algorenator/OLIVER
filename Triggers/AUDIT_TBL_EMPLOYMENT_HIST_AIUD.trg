--
-- AUDIT_TBL_EMPLOYMENT_HIST_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_EMPLOYMENT_HIST_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_EMPLOYMENT_HIST FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_EMPLOYMENT_HIST(TEH_ID
                             ,TEH_ER_ID
                             ,TEH_EFF_DATE
                             ,TEH_TREM_DATE
                             ,TEH_SALARY
                             ,TEH_PROCESS_DATE
                             ,TEH_LAST_MODIFIED_BY
                             ,TEH_LAST_MODIFIED_DATE
                             ,TEH_OCCU
                             ,TEH_EMPLOYMENT_TYPE
                             ,TEH_PLAN
                             ,TEH_CLIENT
                             ,TEH_UNION_LOCAL
                             ,TEH_AGREE_ID
                             ,TEH_HIRE_DATE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.TEH_ID
                             ,:new.TEH_ER_ID
                             ,:new.TEH_EFF_DATE
                             ,:new.TEH_TREM_DATE
                             ,:new.TEH_SALARY
                             ,:new.TEH_PROCESS_DATE
                             ,:new.TEH_LAST_MODIFIED_BY
                             ,:new.TEH_LAST_MODIFIED_DATE
                             ,:new.TEH_OCCU
                             ,:new.TEH_EMPLOYMENT_TYPE
                             ,:new.TEH_PLAN
                             ,:new.TEH_CLIENT
                             ,:new.TEH_UNION_LOCAL
                             ,:new.TEH_AGREE_ID
                             ,:new.TEH_HIRE_DATE
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.TEH_ID <> :new.TEH_ID) or (:old.TEH_ID IS NULL and  :new.TEH_ID IS NOT NULL)  or (:old.TEH_ID IS NOT NULL and  :new.TEH_ID IS NULL))
                 or( (:old.TEH_ER_ID <> :new.TEH_ER_ID) or (:old.TEH_ER_ID IS NULL and  :new.TEH_ER_ID IS NOT NULL)  or (:old.TEH_ER_ID IS NOT NULL and  :new.TEH_ER_ID IS NULL))
                 or( (:old.TEH_EFF_DATE <> :new.TEH_EFF_DATE) or (:old.TEH_EFF_DATE IS NULL and  :new.TEH_EFF_DATE IS NOT NULL)  or (:old.TEH_EFF_DATE IS NOT NULL and  :new.TEH_EFF_DATE IS NULL))
                 or( (:old.TEH_TREM_DATE <> :new.TEH_TREM_DATE) or (:old.TEH_TREM_DATE IS NULL and  :new.TEH_TREM_DATE IS NOT NULL)  or (:old.TEH_TREM_DATE IS NOT NULL and  :new.TEH_TREM_DATE IS NULL))
                 or( (:old.TEH_SALARY <> :new.TEH_SALARY) or (:old.TEH_SALARY IS NULL and  :new.TEH_SALARY IS NOT NULL)  or (:old.TEH_SALARY IS NOT NULL and  :new.TEH_SALARY IS NULL))
                 or( (:old.TEH_PROCESS_DATE <> :new.TEH_PROCESS_DATE) or (:old.TEH_PROCESS_DATE IS NULL and  :new.TEH_PROCESS_DATE IS NOT NULL)  or (:old.TEH_PROCESS_DATE IS NOT NULL and  :new.TEH_PROCESS_DATE IS NULL))
                 or( (:old.TEH_LAST_MODIFIED_BY <> :new.TEH_LAST_MODIFIED_BY) or (:old.TEH_LAST_MODIFIED_BY IS NULL and  :new.TEH_LAST_MODIFIED_BY IS NOT NULL)  or (:old.TEH_LAST_MODIFIED_BY IS NOT NULL and  :new.TEH_LAST_MODIFIED_BY IS NULL))
                 or( (:old.TEH_LAST_MODIFIED_DATE <> :new.TEH_LAST_MODIFIED_DATE) or (:old.TEH_LAST_MODIFIED_DATE IS NULL and  :new.TEH_LAST_MODIFIED_DATE IS NOT NULL)  or (:old.TEH_LAST_MODIFIED_DATE IS NOT NULL and  :new.TEH_LAST_MODIFIED_DATE IS NULL))
                 or( (:old.TEH_OCCU <> :new.TEH_OCCU) or (:old.TEH_OCCU IS NULL and  :new.TEH_OCCU IS NOT NULL)  or (:old.TEH_OCCU IS NOT NULL and  :new.TEH_OCCU IS NULL))
                 or( (:old.TEH_EMPLOYMENT_TYPE <> :new.TEH_EMPLOYMENT_TYPE) or (:old.TEH_EMPLOYMENT_TYPE IS NULL and  :new.TEH_EMPLOYMENT_TYPE IS NOT NULL)  or (:old.TEH_EMPLOYMENT_TYPE IS NOT NULL and  :new.TEH_EMPLOYMENT_TYPE IS NULL))
                 or( (:old.TEH_PLAN <> :new.TEH_PLAN) or (:old.TEH_PLAN IS NULL and  :new.TEH_PLAN IS NOT NULL)  or (:old.TEH_PLAN IS NOT NULL and  :new.TEH_PLAN IS NULL))
                 or( (:old.TEH_CLIENT <> :new.TEH_CLIENT) or (:old.TEH_CLIENT IS NULL and  :new.TEH_CLIENT IS NOT NULL)  or (:old.TEH_CLIENT IS NOT NULL and  :new.TEH_CLIENT IS NULL))
                 or( (:old.TEH_UNION_LOCAL <> :new.TEH_UNION_LOCAL) or (:old.TEH_UNION_LOCAL IS NULL and  :new.TEH_UNION_LOCAL IS NOT NULL)  or (:old.TEH_UNION_LOCAL IS NOT NULL and  :new.TEH_UNION_LOCAL IS NULL))
                 or( (:old.TEH_AGREE_ID <> :new.TEH_AGREE_ID) or (:old.TEH_AGREE_ID IS NULL and  :new.TEH_AGREE_ID IS NOT NULL)  or (:old.TEH_AGREE_ID IS NOT NULL and  :new.TEH_AGREE_ID IS NULL))
                 or( (:old.TEH_HIRE_DATE <> :new.TEH_HIRE_DATE) or (:old.TEH_HIRE_DATE IS NULL and  :new.TEH_HIRE_DATE IS NOT NULL)  or (:old.TEH_HIRE_DATE IS NOT NULL and  :new.TEH_HIRE_DATE IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_EMPLOYMENT_HIST(TEH_ID
                             ,TEH_ER_ID
                             ,TEH_EFF_DATE
                             ,TEH_TREM_DATE
                             ,TEH_SALARY
                             ,TEH_PROCESS_DATE
                             ,TEH_LAST_MODIFIED_BY
                             ,TEH_LAST_MODIFIED_DATE
                             ,TEH_OCCU
                             ,TEH_EMPLOYMENT_TYPE
                             ,TEH_PLAN
                             ,TEH_CLIENT
                             ,TEH_UNION_LOCAL
                             ,TEH_AGREE_ID
                             ,TEH_HIRE_DATE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.TEH_ID
                             ,:new.TEH_ER_ID
                             ,:new.TEH_EFF_DATE
                             ,:new.TEH_TREM_DATE
                             ,:new.TEH_SALARY
                             ,:new.TEH_PROCESS_DATE
                             ,:new.TEH_LAST_MODIFIED_BY
                             ,:new.TEH_LAST_MODIFIED_DATE
                             ,:new.TEH_OCCU
                             ,:new.TEH_EMPLOYMENT_TYPE
                             ,:new.TEH_PLAN
                             ,:new.TEH_CLIENT
                             ,:new.TEH_UNION_LOCAL
                             ,:new.TEH_AGREE_ID
                             ,:new.TEH_HIRE_DATE
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_EMPLOYMENT_HIST(TEH_ID
                             ,TEH_ER_ID
                             ,TEH_EFF_DATE
                             ,TEH_TREM_DATE
                             ,TEH_SALARY
                             ,TEH_PROCESS_DATE
                             ,TEH_LAST_MODIFIED_BY
                             ,TEH_LAST_MODIFIED_DATE
                             ,TEH_OCCU
                             ,TEH_EMPLOYMENT_TYPE
                             ,TEH_PLAN
                             ,TEH_CLIENT
                             ,TEH_UNION_LOCAL
                             ,TEH_AGREE_ID
                             ,TEH_HIRE_DATE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.TEH_ID
                             ,:old.TEH_ER_ID
                             ,:old.TEH_EFF_DATE
                             ,:old.TEH_TREM_DATE
                             ,:old.TEH_SALARY
                             ,:old.TEH_PROCESS_DATE
                             ,:old.TEH_LAST_MODIFIED_BY
                             ,:old.TEH_LAST_MODIFIED_DATE
                             ,:old.TEH_OCCU
                             ,:old.TEH_EMPLOYMENT_TYPE
                             ,:old.TEH_PLAN
                             ,:old.TEH_CLIENT
                             ,:old.TEH_UNION_LOCAL
                             ,:old.TEH_AGREE_ID
                             ,:old.TEH_HIRE_DATE
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


