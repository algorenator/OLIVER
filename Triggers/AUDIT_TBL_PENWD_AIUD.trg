--
-- AUDIT_TBL_PENWD_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_PENWD_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_PENWD FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_PENWD(PW_CLIENT
                             ,PW_PLAN
                             ,PW_MEM_ID
                             ,PW_NLI_WDRAW_EE
                             ,PW_LI_WDRAW_EE
                             ,PW_LI_WDRAW_ER
                             ,PW_NLI_WDRAW_ER
                             ,PW_TERM_DATE
                             ,PW_PROCESS_DATE
                             ,PW_COMMENT
                             ,PW_CREATED_BY
                             ,PW_CREATION_DATE
                             ,PW_LAST_UPDATED_BY
                             ,PW_LAST_UPDATED_DATE
                             ,PW_SOL_RATIO
                             ,PW_EE_DUE
                             ,PW_ER_DUE
                             ,PW_DUE_DATE
                             ,PW_SHORT_INT_RATE
                             ,PW_LONG_INT_RATE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.PW_CLIENT
                             ,:new.PW_PLAN
                             ,:new.PW_MEM_ID
                             ,:new.PW_NLI_WDRAW_EE
                             ,:new.PW_LI_WDRAW_EE
                             ,:new.PW_LI_WDRAW_ER
                             ,:new.PW_NLI_WDRAW_ER
                             ,:new.PW_TERM_DATE
                             ,:new.PW_PROCESS_DATE
                             ,:new.PW_COMMENT
                             ,:new.PW_CREATED_BY
                             ,:new.PW_CREATION_DATE
                             ,:new.PW_LAST_UPDATED_BY
                             ,:new.PW_LAST_UPDATED_DATE
                             ,:new.PW_SOL_RATIO
                             ,:new.PW_EE_DUE
                             ,:new.PW_ER_DUE
                             ,:new.PW_DUE_DATE
                             ,:new.PW_SHORT_INT_RATE
                             ,:new.PW_LONG_INT_RATE
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.PW_CLIENT <> :new.PW_CLIENT) or (:old.PW_CLIENT IS NULL and  :new.PW_CLIENT IS NOT NULL)  or (:old.PW_CLIENT IS NOT NULL and  :new.PW_CLIENT IS NULL))
                 or( (:old.PW_PLAN <> :new.PW_PLAN) or (:old.PW_PLAN IS NULL and  :new.PW_PLAN IS NOT NULL)  or (:old.PW_PLAN IS NOT NULL and  :new.PW_PLAN IS NULL))
                 or( (:old.PW_MEM_ID <> :new.PW_MEM_ID) or (:old.PW_MEM_ID IS NULL and  :new.PW_MEM_ID IS NOT NULL)  or (:old.PW_MEM_ID IS NOT NULL and  :new.PW_MEM_ID IS NULL))
                 or( (:old.PW_NLI_WDRAW_EE <> :new.PW_NLI_WDRAW_EE) or (:old.PW_NLI_WDRAW_EE IS NULL and  :new.PW_NLI_WDRAW_EE IS NOT NULL)  or (:old.PW_NLI_WDRAW_EE IS NOT NULL and  :new.PW_NLI_WDRAW_EE IS NULL))
                 or( (:old.PW_LI_WDRAW_EE <> :new.PW_LI_WDRAW_EE) or (:old.PW_LI_WDRAW_EE IS NULL and  :new.PW_LI_WDRAW_EE IS NOT NULL)  or (:old.PW_LI_WDRAW_EE IS NOT NULL and  :new.PW_LI_WDRAW_EE IS NULL))
                 or( (:old.PW_LI_WDRAW_ER <> :new.PW_LI_WDRAW_ER) or (:old.PW_LI_WDRAW_ER IS NULL and  :new.PW_LI_WDRAW_ER IS NOT NULL)  or (:old.PW_LI_WDRAW_ER IS NOT NULL and  :new.PW_LI_WDRAW_ER IS NULL))
                 or( (:old.PW_NLI_WDRAW_ER <> :new.PW_NLI_WDRAW_ER) or (:old.PW_NLI_WDRAW_ER IS NULL and  :new.PW_NLI_WDRAW_ER IS NOT NULL)  or (:old.PW_NLI_WDRAW_ER IS NOT NULL and  :new.PW_NLI_WDRAW_ER IS NULL))
                 or( (:old.PW_TERM_DATE <> :new.PW_TERM_DATE) or (:old.PW_TERM_DATE IS NULL and  :new.PW_TERM_DATE IS NOT NULL)  or (:old.PW_TERM_DATE IS NOT NULL and  :new.PW_TERM_DATE IS NULL))
                 or( (:old.PW_PROCESS_DATE <> :new.PW_PROCESS_DATE) or (:old.PW_PROCESS_DATE IS NULL and  :new.PW_PROCESS_DATE IS NOT NULL)  or (:old.PW_PROCESS_DATE IS NOT NULL and  :new.PW_PROCESS_DATE IS NULL))
                 or( (:old.PW_COMMENT <> :new.PW_COMMENT) or (:old.PW_COMMENT IS NULL and  :new.PW_COMMENT IS NOT NULL)  or (:old.PW_COMMENT IS NOT NULL and  :new.PW_COMMENT IS NULL))
                 or( (:old.PW_CREATED_BY <> :new.PW_CREATED_BY) or (:old.PW_CREATED_BY IS NULL and  :new.PW_CREATED_BY IS NOT NULL)  or (:old.PW_CREATED_BY IS NOT NULL and  :new.PW_CREATED_BY IS NULL))
                 or( (:old.PW_CREATION_DATE <> :new.PW_CREATION_DATE) or (:old.PW_CREATION_DATE IS NULL and  :new.PW_CREATION_DATE IS NOT NULL)  or (:old.PW_CREATION_DATE IS NOT NULL and  :new.PW_CREATION_DATE IS NULL))
                 or( (:old.PW_LAST_UPDATED_BY <> :new.PW_LAST_UPDATED_BY) or (:old.PW_LAST_UPDATED_BY IS NULL and  :new.PW_LAST_UPDATED_BY IS NOT NULL)  or (:old.PW_LAST_UPDATED_BY IS NOT NULL and  :new.PW_LAST_UPDATED_BY IS NULL))
                 or( (:old.PW_LAST_UPDATED_DATE <> :new.PW_LAST_UPDATED_DATE) or (:old.PW_LAST_UPDATED_DATE IS NULL and  :new.PW_LAST_UPDATED_DATE IS NOT NULL)  or (:old.PW_LAST_UPDATED_DATE IS NOT NULL and  :new.PW_LAST_UPDATED_DATE IS NULL))
                 or( (:old.PW_SOL_RATIO <> :new.PW_SOL_RATIO) or (:old.PW_SOL_RATIO IS NULL and  :new.PW_SOL_RATIO IS NOT NULL)  or (:old.PW_SOL_RATIO IS NOT NULL and  :new.PW_SOL_RATIO IS NULL))
                 or( (:old.PW_EE_DUE <> :new.PW_EE_DUE) or (:old.PW_EE_DUE IS NULL and  :new.PW_EE_DUE IS NOT NULL)  or (:old.PW_EE_DUE IS NOT NULL and  :new.PW_EE_DUE IS NULL))
                 or( (:old.PW_ER_DUE <> :new.PW_ER_DUE) or (:old.PW_ER_DUE IS NULL and  :new.PW_ER_DUE IS NOT NULL)  or (:old.PW_ER_DUE IS NOT NULL and  :new.PW_ER_DUE IS NULL))
                 or( (:old.PW_DUE_DATE <> :new.PW_DUE_DATE) or (:old.PW_DUE_DATE IS NULL and  :new.PW_DUE_DATE IS NOT NULL)  or (:old.PW_DUE_DATE IS NOT NULL and  :new.PW_DUE_DATE IS NULL))
                 or( (:old.PW_SHORT_INT_RATE <> :new.PW_SHORT_INT_RATE) or (:old.PW_SHORT_INT_RATE IS NULL and  :new.PW_SHORT_INT_RATE IS NOT NULL)  or (:old.PW_SHORT_INT_RATE IS NOT NULL and  :new.PW_SHORT_INT_RATE IS NULL))
                 or( (:old.PW_LONG_INT_RATE <> :new.PW_LONG_INT_RATE) or (:old.PW_LONG_INT_RATE IS NULL and  :new.PW_LONG_INT_RATE IS NOT NULL)  or (:old.PW_LONG_INT_RATE IS NOT NULL and  :new.PW_LONG_INT_RATE IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_PENWD(PW_CLIENT
                             ,PW_PLAN
                             ,PW_MEM_ID
                             ,PW_NLI_WDRAW_EE
                             ,PW_LI_WDRAW_EE
                             ,PW_LI_WDRAW_ER
                             ,PW_NLI_WDRAW_ER
                             ,PW_TERM_DATE
                             ,PW_PROCESS_DATE
                             ,PW_COMMENT
                             ,PW_CREATED_BY
                             ,PW_CREATION_DATE
                             ,PW_LAST_UPDATED_BY
                             ,PW_LAST_UPDATED_DATE
                             ,PW_SOL_RATIO
                             ,PW_EE_DUE
                             ,PW_ER_DUE
                             ,PW_DUE_DATE
                             ,PW_SHORT_INT_RATE
                             ,PW_LONG_INT_RATE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.PW_CLIENT
                             ,:new.PW_PLAN
                             ,:new.PW_MEM_ID
                             ,:new.PW_NLI_WDRAW_EE
                             ,:new.PW_LI_WDRAW_EE
                             ,:new.PW_LI_WDRAW_ER
                             ,:new.PW_NLI_WDRAW_ER
                             ,:new.PW_TERM_DATE
                             ,:new.PW_PROCESS_DATE
                             ,:new.PW_COMMENT
                             ,:new.PW_CREATED_BY
                             ,:new.PW_CREATION_DATE
                             ,:new.PW_LAST_UPDATED_BY
                             ,:new.PW_LAST_UPDATED_DATE
                             ,:new.PW_SOL_RATIO
                             ,:new.PW_EE_DUE
                             ,:new.PW_ER_DUE
                             ,:new.PW_DUE_DATE
                             ,:new.PW_SHORT_INT_RATE
                             ,:new.PW_LONG_INT_RATE
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_PENWD(PW_CLIENT
                             ,PW_PLAN
                             ,PW_MEM_ID
                             ,PW_NLI_WDRAW_EE
                             ,PW_LI_WDRAW_EE
                             ,PW_LI_WDRAW_ER
                             ,PW_NLI_WDRAW_ER
                             ,PW_TERM_DATE
                             ,PW_PROCESS_DATE
                             ,PW_COMMENT
                             ,PW_CREATED_BY
                             ,PW_CREATION_DATE
                             ,PW_LAST_UPDATED_BY
                             ,PW_LAST_UPDATED_DATE
                             ,PW_SOL_RATIO
                             ,PW_EE_DUE
                             ,PW_ER_DUE
                             ,PW_DUE_DATE
                             ,PW_SHORT_INT_RATE
                             ,PW_LONG_INT_RATE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.PW_CLIENT
                             ,:old.PW_PLAN
                             ,:old.PW_MEM_ID
                             ,:old.PW_NLI_WDRAW_EE
                             ,:old.PW_LI_WDRAW_EE
                             ,:old.PW_LI_WDRAW_ER
                             ,:old.PW_NLI_WDRAW_ER
                             ,:old.PW_TERM_DATE
                             ,:old.PW_PROCESS_DATE
                             ,:old.PW_COMMENT
                             ,:old.PW_CREATED_BY
                             ,:old.PW_CREATION_DATE
                             ,:old.PW_LAST_UPDATED_BY
                             ,:old.PW_LAST_UPDATED_DATE
                             ,:old.PW_SOL_RATIO
                             ,:old.PW_EE_DUE
                             ,:old.PW_ER_DUE
                             ,:old.PW_DUE_DATE
                             ,:old.PW_SHORT_INT_RATE
                             ,:old.PW_LONG_INT_RATE
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


