--
-- AUDIT_TBL_HR_BANK_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_HR_BANK_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_HR_BANK FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_HR_BANK(THB_ID
                             ,THB_PLAN
                             ,THB_FROM_DATE
                             ,THB_TO_DATE
                             ,THB_MONTH
                             ,THB_HOURS
                             ,THB_DEDUCT_HRS
                             ,THB_CLOSING_HRS
                             ,THB_POSTED_DATE
                             ,THB_EMPLOYER
                             ,THB_MODIFIED_BY
                             ,THB_MODIFIED_DATE
                             ,THB_FUND_CODE
                             ,THB_CLIENT_ID
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.THB_ID
                             ,:new.THB_PLAN
                             ,:new.THB_FROM_DATE
                             ,:new.THB_TO_DATE
                             ,:new.THB_MONTH
                             ,:new.THB_HOURS
                             ,:new.THB_DEDUCT_HRS
                             ,:new.THB_CLOSING_HRS
                             ,:new.THB_POSTED_DATE
                             ,:new.THB_EMPLOYER
                             ,:new.THB_MODIFIED_BY
                             ,:new.THB_MODIFIED_DATE
                             ,:new.THB_FUND_CODE
                             ,:new.THB_CLIENT_ID
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.THB_ID <> :new.THB_ID) or (:old.THB_ID IS NULL and  :new.THB_ID IS NOT NULL)  or (:old.THB_ID IS NOT NULL and  :new.THB_ID IS NULL))
                 or( (:old.THB_PLAN <> :new.THB_PLAN) or (:old.THB_PLAN IS NULL and  :new.THB_PLAN IS NOT NULL)  or (:old.THB_PLAN IS NOT NULL and  :new.THB_PLAN IS NULL))
                 or( (:old.THB_FROM_DATE <> :new.THB_FROM_DATE) or (:old.THB_FROM_DATE IS NULL and  :new.THB_FROM_DATE IS NOT NULL)  or (:old.THB_FROM_DATE IS NOT NULL and  :new.THB_FROM_DATE IS NULL))
                 or( (:old.THB_TO_DATE <> :new.THB_TO_DATE) or (:old.THB_TO_DATE IS NULL and  :new.THB_TO_DATE IS NOT NULL)  or (:old.THB_TO_DATE IS NOT NULL and  :new.THB_TO_DATE IS NULL))
                 or( (:old.THB_MONTH <> :new.THB_MONTH) or (:old.THB_MONTH IS NULL and  :new.THB_MONTH IS NOT NULL)  or (:old.THB_MONTH IS NOT NULL and  :new.THB_MONTH IS NULL))
                 or( (:old.THB_HOURS <> :new.THB_HOURS) or (:old.THB_HOURS IS NULL and  :new.THB_HOURS IS NOT NULL)  or (:old.THB_HOURS IS NOT NULL and  :new.THB_HOURS IS NULL))
                 or( (:old.THB_DEDUCT_HRS <> :new.THB_DEDUCT_HRS) or (:old.THB_DEDUCT_HRS IS NULL and  :new.THB_DEDUCT_HRS IS NOT NULL)  or (:old.THB_DEDUCT_HRS IS NOT NULL and  :new.THB_DEDUCT_HRS IS NULL))
                 or( (:old.THB_CLOSING_HRS <> :new.THB_CLOSING_HRS) or (:old.THB_CLOSING_HRS IS NULL and  :new.THB_CLOSING_HRS IS NOT NULL)  or (:old.THB_CLOSING_HRS IS NOT NULL and  :new.THB_CLOSING_HRS IS NULL))
                 or( (:old.THB_POSTED_DATE <> :new.THB_POSTED_DATE) or (:old.THB_POSTED_DATE IS NULL and  :new.THB_POSTED_DATE IS NOT NULL)  or (:old.THB_POSTED_DATE IS NOT NULL and  :new.THB_POSTED_DATE IS NULL))
                 or( (:old.THB_EMPLOYER <> :new.THB_EMPLOYER) or (:old.THB_EMPLOYER IS NULL and  :new.THB_EMPLOYER IS NOT NULL)  or (:old.THB_EMPLOYER IS NOT NULL and  :new.THB_EMPLOYER IS NULL))
                 or( (:old.THB_MODIFIED_BY <> :new.THB_MODIFIED_BY) or (:old.THB_MODIFIED_BY IS NULL and  :new.THB_MODIFIED_BY IS NOT NULL)  or (:old.THB_MODIFIED_BY IS NOT NULL and  :new.THB_MODIFIED_BY IS NULL))
                 or( (:old.THB_MODIFIED_DATE <> :new.THB_MODIFIED_DATE) or (:old.THB_MODIFIED_DATE IS NULL and  :new.THB_MODIFIED_DATE IS NOT NULL)  or (:old.THB_MODIFIED_DATE IS NOT NULL and  :new.THB_MODIFIED_DATE IS NULL))
                 or( (:old.THB_FUND_CODE <> :new.THB_FUND_CODE) or (:old.THB_FUND_CODE IS NULL and  :new.THB_FUND_CODE IS NOT NULL)  or (:old.THB_FUND_CODE IS NOT NULL and  :new.THB_FUND_CODE IS NULL))
                 or( (:old.THB_CLIENT_ID <> :new.THB_CLIENT_ID) or (:old.THB_CLIENT_ID IS NULL and  :new.THB_CLIENT_ID IS NOT NULL)  or (:old.THB_CLIENT_ID IS NOT NULL and  :new.THB_CLIENT_ID IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_HR_BANK(THB_ID
                             ,THB_PLAN
                             ,THB_FROM_DATE
                             ,THB_TO_DATE
                             ,THB_MONTH
                             ,THB_HOURS
                             ,THB_DEDUCT_HRS
                             ,THB_CLOSING_HRS
                             ,THB_POSTED_DATE
                             ,THB_EMPLOYER
                             ,THB_MODIFIED_BY
                             ,THB_MODIFIED_DATE
                             ,THB_FUND_CODE
                             ,THB_CLIENT_ID
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.THB_ID
                             ,:new.THB_PLAN
                             ,:new.THB_FROM_DATE
                             ,:new.THB_TO_DATE
                             ,:new.THB_MONTH
                             ,:new.THB_HOURS
                             ,:new.THB_DEDUCT_HRS
                             ,:new.THB_CLOSING_HRS
                             ,:new.THB_POSTED_DATE
                             ,:new.THB_EMPLOYER
                             ,:new.THB_MODIFIED_BY
                             ,:new.THB_MODIFIED_DATE
                             ,:new.THB_FUND_CODE
                             ,:new.THB_CLIENT_ID
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_HR_BANK(THB_ID
                             ,THB_PLAN
                             ,THB_FROM_DATE
                             ,THB_TO_DATE
                             ,THB_MONTH
                             ,THB_HOURS
                             ,THB_DEDUCT_HRS
                             ,THB_CLOSING_HRS
                             ,THB_POSTED_DATE
                             ,THB_EMPLOYER
                             ,THB_MODIFIED_BY
                             ,THB_MODIFIED_DATE
                             ,THB_FUND_CODE
                             ,THB_CLIENT_ID
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.THB_ID
                             ,:old.THB_PLAN
                             ,:old.THB_FROM_DATE
                             ,:old.THB_TO_DATE
                             ,:old.THB_MONTH
                             ,:old.THB_HOURS
                             ,:old.THB_DEDUCT_HRS
                             ,:old.THB_CLOSING_HRS
                             ,:old.THB_POSTED_DATE
                             ,:old.THB_EMPLOYER
                             ,:old.THB_MODIFIED_BY
                             ,:old.THB_MODIFIED_DATE
                             ,:old.THB_FUND_CODE
                             ,:old.THB_CLIENT_ID
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


