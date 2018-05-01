--
-- AUDIT_TBL_HW_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_HW_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_HW FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_HW(HW_PLAN
                             ,HW_ID
                             ,HW_EFF_DATE
                             ,HW_TERM_DATE
                             ,HW_COVERAGE
                             ,HW_EMPLOYER
                             ,HW_DIV
                             ,HW_BILLING_CODE
                             ,HW_TERM_CODE
                             ,HW_APP_RECD
                             ,HW_LAST_MODIFIED_DATE
                             ,HW_LAST_MODIFIED_BY
                             ,HW_LOCAL
                             ,HW_LOCAL_EFF_DATE
                             ,HW_RECIPROCAL
                             ,HW_RECIPROCAL_DATE
                             ,HW_SUSPENED
                             ,HW_SUSP_DATE
                             ,HW_SUSP_REASON
                             ,HW_CLASS
                             ,HW_STATUS
                             ,HW_MEM_CATEGORY
                             ,HW_SUB_PLAN
                             ,HW_SUBSIDIZED
                             ,HW_LATE_APP
                             ,HW_LATE_EFF_DATE
                             ,HW_LATE_TERM_DATE
                             ,HW_CLIENT
                             ,HW_SMOKER
                             ,HW_EE_TYPE
                             ,HW_COUPLE_DEP_NO
                             ,HW_VISION_ELIGIBLE
                             ,HW_SPOUSAL_SMOKER
                             ,HW_DEP_STATUS
                             ,HW_SMOKER_EFF_DATE
                             ,HW_SP_SMOKER_EFF_DATE
                             ,HW_DEP_STATUS_EFF_DATE
                             ,HW_CLASS_EFF_DATE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.HW_PLAN
                             ,:new.HW_ID
                             ,:new.HW_EFF_DATE
                             ,:new.HW_TERM_DATE
                             ,:new.HW_COVERAGE
                             ,:new.HW_EMPLOYER
                             ,:new.HW_DIV
                             ,:new.HW_BILLING_CODE
                             ,:new.HW_TERM_CODE
                             ,:new.HW_APP_RECD
                             ,:new.HW_LAST_MODIFIED_DATE
                             ,:new.HW_LAST_MODIFIED_BY
                             ,:new.HW_LOCAL
                             ,:new.HW_LOCAL_EFF_DATE
                             ,:new.HW_RECIPROCAL
                             ,:new.HW_RECIPROCAL_DATE
                             ,:new.HW_SUSPENED
                             ,:new.HW_SUSP_DATE
                             ,:new.HW_SUSP_REASON
                             ,:new.HW_CLASS
                             ,:new.HW_STATUS
                             ,:new.HW_MEM_CATEGORY
                             ,:new.HW_SUB_PLAN
                             ,:new.HW_SUBSIDIZED
                             ,:new.HW_LATE_APP
                             ,:new.HW_LATE_EFF_DATE
                             ,:new.HW_LATE_TERM_DATE
                             ,:new.HW_CLIENT
                             ,:new.HW_SMOKER
                             ,:new.HW_EE_TYPE
                             ,:new.HW_COUPLE_DEP_NO
                             ,:new.HW_VISION_ELIGIBLE
                             ,:new.HW_SPOUSAL_SMOKER
                             ,:new.HW_DEP_STATUS
                             ,:new.HW_SMOKER_EFF_DATE
                             ,:new.HW_SP_SMOKER_EFF_DATE
                             ,:new.HW_DEP_STATUS_EFF_DATE
                             ,:new.HW_CLASS_EFF_DATE
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.HW_PLAN <> :new.HW_PLAN) or (:old.HW_PLAN IS NULL and  :new.HW_PLAN IS NOT NULL)  or (:old.HW_PLAN IS NOT NULL and  :new.HW_PLAN IS NULL))
                 or( (:old.HW_ID <> :new.HW_ID) or (:old.HW_ID IS NULL and  :new.HW_ID IS NOT NULL)  or (:old.HW_ID IS NOT NULL and  :new.HW_ID IS NULL))
                 or( (:old.HW_EFF_DATE <> :new.HW_EFF_DATE) or (:old.HW_EFF_DATE IS NULL and  :new.HW_EFF_DATE IS NOT NULL)  or (:old.HW_EFF_DATE IS NOT NULL and  :new.HW_EFF_DATE IS NULL))
                 or( (:old.HW_TERM_DATE <> :new.HW_TERM_DATE) or (:old.HW_TERM_DATE IS NULL and  :new.HW_TERM_DATE IS NOT NULL)  or (:old.HW_TERM_DATE IS NOT NULL and  :new.HW_TERM_DATE IS NULL))
                 or( (:old.HW_COVERAGE <> :new.HW_COVERAGE) or (:old.HW_COVERAGE IS NULL and  :new.HW_COVERAGE IS NOT NULL)  or (:old.HW_COVERAGE IS NOT NULL and  :new.HW_COVERAGE IS NULL))
                 or( (:old.HW_EMPLOYER <> :new.HW_EMPLOYER) or (:old.HW_EMPLOYER IS NULL and  :new.HW_EMPLOYER IS NOT NULL)  or (:old.HW_EMPLOYER IS NOT NULL and  :new.HW_EMPLOYER IS NULL))
                 or( (:old.HW_DIV <> :new.HW_DIV) or (:old.HW_DIV IS NULL and  :new.HW_DIV IS NOT NULL)  or (:old.HW_DIV IS NOT NULL and  :new.HW_DIV IS NULL))
                 or( (:old.HW_BILLING_CODE <> :new.HW_BILLING_CODE) or (:old.HW_BILLING_CODE IS NULL and  :new.HW_BILLING_CODE IS NOT NULL)  or (:old.HW_BILLING_CODE IS NOT NULL and  :new.HW_BILLING_CODE IS NULL))
                 or( (:old.HW_TERM_CODE <> :new.HW_TERM_CODE) or (:old.HW_TERM_CODE IS NULL and  :new.HW_TERM_CODE IS NOT NULL)  or (:old.HW_TERM_CODE IS NOT NULL and  :new.HW_TERM_CODE IS NULL))
                 or( (:old.HW_APP_RECD <> :new.HW_APP_RECD) or (:old.HW_APP_RECD IS NULL and  :new.HW_APP_RECD IS NOT NULL)  or (:old.HW_APP_RECD IS NOT NULL and  :new.HW_APP_RECD IS NULL))
                 or( (:old.HW_LAST_MODIFIED_DATE <> :new.HW_LAST_MODIFIED_DATE) or (:old.HW_LAST_MODIFIED_DATE IS NULL and  :new.HW_LAST_MODIFIED_DATE IS NOT NULL)  or (:old.HW_LAST_MODIFIED_DATE IS NOT NULL and  :new.HW_LAST_MODIFIED_DATE IS NULL))
                 or( (:old.HW_LAST_MODIFIED_BY <> :new.HW_LAST_MODIFIED_BY) or (:old.HW_LAST_MODIFIED_BY IS NULL and  :new.HW_LAST_MODIFIED_BY IS NOT NULL)  or (:old.HW_LAST_MODIFIED_BY IS NOT NULL and  :new.HW_LAST_MODIFIED_BY IS NULL))
                 or( (:old.HW_LOCAL <> :new.HW_LOCAL) or (:old.HW_LOCAL IS NULL and  :new.HW_LOCAL IS NOT NULL)  or (:old.HW_LOCAL IS NOT NULL and  :new.HW_LOCAL IS NULL))
                 or( (:old.HW_LOCAL_EFF_DATE <> :new.HW_LOCAL_EFF_DATE) or (:old.HW_LOCAL_EFF_DATE IS NULL and  :new.HW_LOCAL_EFF_DATE IS NOT NULL)  or (:old.HW_LOCAL_EFF_DATE IS NOT NULL and  :new.HW_LOCAL_EFF_DATE IS NULL))
                 or( (:old.HW_RECIPROCAL <> :new.HW_RECIPROCAL) or (:old.HW_RECIPROCAL IS NULL and  :new.HW_RECIPROCAL IS NOT NULL)  or (:old.HW_RECIPROCAL IS NOT NULL and  :new.HW_RECIPROCAL IS NULL))
                 or( (:old.HW_RECIPROCAL_DATE <> :new.HW_RECIPROCAL_DATE) or (:old.HW_RECIPROCAL_DATE IS NULL and  :new.HW_RECIPROCAL_DATE IS NOT NULL)  or (:old.HW_RECIPROCAL_DATE IS NOT NULL and  :new.HW_RECIPROCAL_DATE IS NULL))
                 or( (:old.HW_SUSPENED <> :new.HW_SUSPENED) or (:old.HW_SUSPENED IS NULL and  :new.HW_SUSPENED IS NOT NULL)  or (:old.HW_SUSPENED IS NOT NULL and  :new.HW_SUSPENED IS NULL))
                 or( (:old.HW_SUSP_DATE <> :new.HW_SUSP_DATE) or (:old.HW_SUSP_DATE IS NULL and  :new.HW_SUSP_DATE IS NOT NULL)  or (:old.HW_SUSP_DATE IS NOT NULL and  :new.HW_SUSP_DATE IS NULL))
                 or( (:old.HW_SUSP_REASON <> :new.HW_SUSP_REASON) or (:old.HW_SUSP_REASON IS NULL and  :new.HW_SUSP_REASON IS NOT NULL)  or (:old.HW_SUSP_REASON IS NOT NULL and  :new.HW_SUSP_REASON IS NULL))
                 or( (:old.HW_CLASS <> :new.HW_CLASS) or (:old.HW_CLASS IS NULL and  :new.HW_CLASS IS NOT NULL)  or (:old.HW_CLASS IS NOT NULL and  :new.HW_CLASS IS NULL))
                 or( (:old.HW_STATUS <> :new.HW_STATUS) or (:old.HW_STATUS IS NULL and  :new.HW_STATUS IS NOT NULL)  or (:old.HW_STATUS IS NOT NULL and  :new.HW_STATUS IS NULL))
                 or( (:old.HW_MEM_CATEGORY <> :new.HW_MEM_CATEGORY) or (:old.HW_MEM_CATEGORY IS NULL and  :new.HW_MEM_CATEGORY IS NOT NULL)  or (:old.HW_MEM_CATEGORY IS NOT NULL and  :new.HW_MEM_CATEGORY IS NULL))
                 or( (:old.HW_SUB_PLAN <> :new.HW_SUB_PLAN) or (:old.HW_SUB_PLAN IS NULL and  :new.HW_SUB_PLAN IS NOT NULL)  or (:old.HW_SUB_PLAN IS NOT NULL and  :new.HW_SUB_PLAN IS NULL))
                 or( (:old.HW_SUBSIDIZED <> :new.HW_SUBSIDIZED) or (:old.HW_SUBSIDIZED IS NULL and  :new.HW_SUBSIDIZED IS NOT NULL)  or (:old.HW_SUBSIDIZED IS NOT NULL and  :new.HW_SUBSIDIZED IS NULL))
                 or( (:old.HW_LATE_APP <> :new.HW_LATE_APP) or (:old.HW_LATE_APP IS NULL and  :new.HW_LATE_APP IS NOT NULL)  or (:old.HW_LATE_APP IS NOT NULL and  :new.HW_LATE_APP IS NULL))
                 or( (:old.HW_LATE_EFF_DATE <> :new.HW_LATE_EFF_DATE) or (:old.HW_LATE_EFF_DATE IS NULL and  :new.HW_LATE_EFF_DATE IS NOT NULL)  or (:old.HW_LATE_EFF_DATE IS NOT NULL and  :new.HW_LATE_EFF_DATE IS NULL))
                 or( (:old.HW_LATE_TERM_DATE <> :new.HW_LATE_TERM_DATE) or (:old.HW_LATE_TERM_DATE IS NULL and  :new.HW_LATE_TERM_DATE IS NOT NULL)  or (:old.HW_LATE_TERM_DATE IS NOT NULL and  :new.HW_LATE_TERM_DATE IS NULL))
                 or( (:old.HW_CLIENT <> :new.HW_CLIENT) or (:old.HW_CLIENT IS NULL and  :new.HW_CLIENT IS NOT NULL)  or (:old.HW_CLIENT IS NOT NULL and  :new.HW_CLIENT IS NULL))
                 or( (:old.HW_SMOKER <> :new.HW_SMOKER) or (:old.HW_SMOKER IS NULL and  :new.HW_SMOKER IS NOT NULL)  or (:old.HW_SMOKER IS NOT NULL and  :new.HW_SMOKER IS NULL))
                 or( (:old.HW_EE_TYPE <> :new.HW_EE_TYPE) or (:old.HW_EE_TYPE IS NULL and  :new.HW_EE_TYPE IS NOT NULL)  or (:old.HW_EE_TYPE IS NOT NULL and  :new.HW_EE_TYPE IS NULL))
                 or( (:old.HW_COUPLE_DEP_NO <> :new.HW_COUPLE_DEP_NO) or (:old.HW_COUPLE_DEP_NO IS NULL and  :new.HW_COUPLE_DEP_NO IS NOT NULL)  or (:old.HW_COUPLE_DEP_NO IS NOT NULL and  :new.HW_COUPLE_DEP_NO IS NULL))
                 or( (:old.HW_VISION_ELIGIBLE <> :new.HW_VISION_ELIGIBLE) or (:old.HW_VISION_ELIGIBLE IS NULL and  :new.HW_VISION_ELIGIBLE IS NOT NULL)  or (:old.HW_VISION_ELIGIBLE IS NOT NULL and  :new.HW_VISION_ELIGIBLE IS NULL))
                 or( (:old.HW_SPOUSAL_SMOKER <> :new.HW_SPOUSAL_SMOKER) or (:old.HW_SPOUSAL_SMOKER IS NULL and  :new.HW_SPOUSAL_SMOKER IS NOT NULL)  or (:old.HW_SPOUSAL_SMOKER IS NOT NULL and  :new.HW_SPOUSAL_SMOKER IS NULL))
                 or( (:old.HW_DEP_STATUS <> :new.HW_DEP_STATUS) or (:old.HW_DEP_STATUS IS NULL and  :new.HW_DEP_STATUS IS NOT NULL)  or (:old.HW_DEP_STATUS IS NOT NULL and  :new.HW_DEP_STATUS IS NULL))
                 or( (:old.HW_SMOKER_EFF_DATE <> :new.HW_SMOKER_EFF_DATE) or (:old.HW_SMOKER_EFF_DATE IS NULL and  :new.HW_SMOKER_EFF_DATE IS NOT NULL)  or (:old.HW_SMOKER_EFF_DATE IS NOT NULL and  :new.HW_SMOKER_EFF_DATE IS NULL))
                 or( (:old.HW_SP_SMOKER_EFF_DATE <> :new.HW_SP_SMOKER_EFF_DATE) or (:old.HW_SP_SMOKER_EFF_DATE IS NULL and  :new.HW_SP_SMOKER_EFF_DATE IS NOT NULL)  or (:old.HW_SP_SMOKER_EFF_DATE IS NOT NULL and  :new.HW_SP_SMOKER_EFF_DATE IS NULL))
                 or( (:old.HW_DEP_STATUS_EFF_DATE <> :new.HW_DEP_STATUS_EFF_DATE) or (:old.HW_DEP_STATUS_EFF_DATE IS NULL and  :new.HW_DEP_STATUS_EFF_DATE IS NOT NULL)  or (:old.HW_DEP_STATUS_EFF_DATE IS NOT NULL and  :new.HW_DEP_STATUS_EFF_DATE IS NULL))
                 or( (:old.HW_CLASS_EFF_DATE <> :new.HW_CLASS_EFF_DATE) or (:old.HW_CLASS_EFF_DATE IS NULL and  :new.HW_CLASS_EFF_DATE IS NOT NULL)  or (:old.HW_CLASS_EFF_DATE IS NOT NULL and  :new.HW_CLASS_EFF_DATE IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_HW(HW_PLAN
                             ,HW_ID
                             ,HW_EFF_DATE
                             ,HW_TERM_DATE
                             ,HW_COVERAGE
                             ,HW_EMPLOYER
                             ,HW_DIV
                             ,HW_BILLING_CODE
                             ,HW_TERM_CODE
                             ,HW_APP_RECD
                             ,HW_LAST_MODIFIED_DATE
                             ,HW_LAST_MODIFIED_BY
                             ,HW_LOCAL
                             ,HW_LOCAL_EFF_DATE
                             ,HW_RECIPROCAL
                             ,HW_RECIPROCAL_DATE
                             ,HW_SUSPENED
                             ,HW_SUSP_DATE
                             ,HW_SUSP_REASON
                             ,HW_CLASS
                             ,HW_STATUS
                             ,HW_MEM_CATEGORY
                             ,HW_SUB_PLAN
                             ,HW_SUBSIDIZED
                             ,HW_LATE_APP
                             ,HW_LATE_EFF_DATE
                             ,HW_LATE_TERM_DATE
                             ,HW_CLIENT
                             ,HW_SMOKER
                             ,HW_EE_TYPE
                             ,HW_COUPLE_DEP_NO
                             ,HW_VISION_ELIGIBLE
                             ,HW_SPOUSAL_SMOKER
                             ,HW_DEP_STATUS
                             ,HW_SMOKER_EFF_DATE
                             ,HW_SP_SMOKER_EFF_DATE
                             ,HW_DEP_STATUS_EFF_DATE
                             ,HW_CLASS_EFF_DATE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.HW_PLAN
                             ,:new.HW_ID
                             ,:new.HW_EFF_DATE
                             ,:new.HW_TERM_DATE
                             ,:new.HW_COVERAGE
                             ,:new.HW_EMPLOYER
                             ,:new.HW_DIV
                             ,:new.HW_BILLING_CODE
                             ,:new.HW_TERM_CODE
                             ,:new.HW_APP_RECD
                             ,:new.HW_LAST_MODIFIED_DATE
                             ,:new.HW_LAST_MODIFIED_BY
                             ,:new.HW_LOCAL
                             ,:new.HW_LOCAL_EFF_DATE
                             ,:new.HW_RECIPROCAL
                             ,:new.HW_RECIPROCAL_DATE
                             ,:new.HW_SUSPENED
                             ,:new.HW_SUSP_DATE
                             ,:new.HW_SUSP_REASON
                             ,:new.HW_CLASS
                             ,:new.HW_STATUS
                             ,:new.HW_MEM_CATEGORY
                             ,:new.HW_SUB_PLAN
                             ,:new.HW_SUBSIDIZED
                             ,:new.HW_LATE_APP
                             ,:new.HW_LATE_EFF_DATE
                             ,:new.HW_LATE_TERM_DATE
                             ,:new.HW_CLIENT
                             ,:new.HW_SMOKER
                             ,:new.HW_EE_TYPE
                             ,:new.HW_COUPLE_DEP_NO
                             ,:new.HW_VISION_ELIGIBLE
                             ,:new.HW_SPOUSAL_SMOKER
                             ,:new.HW_DEP_STATUS
                             ,:new.HW_SMOKER_EFF_DATE
                             ,:new.HW_SP_SMOKER_EFF_DATE
                             ,:new.HW_DEP_STATUS_EFF_DATE
                             ,:new.HW_CLASS_EFF_DATE
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_HW(HW_PLAN
                             ,HW_ID
                             ,HW_EFF_DATE
                             ,HW_TERM_DATE
                             ,HW_COVERAGE
                             ,HW_EMPLOYER
                             ,HW_DIV
                             ,HW_BILLING_CODE
                             ,HW_TERM_CODE
                             ,HW_APP_RECD
                             ,HW_LAST_MODIFIED_DATE
                             ,HW_LAST_MODIFIED_BY
                             ,HW_LOCAL
                             ,HW_LOCAL_EFF_DATE
                             ,HW_RECIPROCAL
                             ,HW_RECIPROCAL_DATE
                             ,HW_SUSPENED
                             ,HW_SUSP_DATE
                             ,HW_SUSP_REASON
                             ,HW_CLASS
                             ,HW_STATUS
                             ,HW_MEM_CATEGORY
                             ,HW_SUB_PLAN
                             ,HW_SUBSIDIZED
                             ,HW_LATE_APP
                             ,HW_LATE_EFF_DATE
                             ,HW_LATE_TERM_DATE
                             ,HW_CLIENT
                             ,HW_SMOKER
                             ,HW_EE_TYPE
                             ,HW_COUPLE_DEP_NO
                             ,HW_VISION_ELIGIBLE
                             ,HW_SPOUSAL_SMOKER
                             ,HW_DEP_STATUS
                             ,HW_SMOKER_EFF_DATE
                             ,HW_SP_SMOKER_EFF_DATE
                             ,HW_DEP_STATUS_EFF_DATE
                             ,HW_CLASS_EFF_DATE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.HW_PLAN
                             ,:old.HW_ID
                             ,:old.HW_EFF_DATE
                             ,:old.HW_TERM_DATE
                             ,:old.HW_COVERAGE
                             ,:old.HW_EMPLOYER
                             ,:old.HW_DIV
                             ,:old.HW_BILLING_CODE
                             ,:old.HW_TERM_CODE
                             ,:old.HW_APP_RECD
                             ,:old.HW_LAST_MODIFIED_DATE
                             ,:old.HW_LAST_MODIFIED_BY
                             ,:old.HW_LOCAL
                             ,:old.HW_LOCAL_EFF_DATE
                             ,:old.HW_RECIPROCAL
                             ,:old.HW_RECIPROCAL_DATE
                             ,:old.HW_SUSPENED
                             ,:old.HW_SUSP_DATE
                             ,:old.HW_SUSP_REASON
                             ,:old.HW_CLASS
                             ,:old.HW_STATUS
                             ,:old.HW_MEM_CATEGORY
                             ,:old.HW_SUB_PLAN
                             ,:old.HW_SUBSIDIZED
                             ,:old.HW_LATE_APP
                             ,:old.HW_LATE_EFF_DATE
                             ,:old.HW_LATE_TERM_DATE
                             ,:old.HW_CLIENT
                             ,:old.HW_SMOKER
                             ,:old.HW_EE_TYPE
                             ,:old.HW_COUPLE_DEP_NO
                             ,:old.HW_VISION_ELIGIBLE
                             ,:old.HW_SPOUSAL_SMOKER
                             ,:old.HW_DEP_STATUS
                             ,:old.HW_SMOKER_EFF_DATE
                             ,:old.HW_SP_SMOKER_EFF_DATE
                             ,:old.HW_DEP_STATUS_EFF_DATE
                             ,:old.HW_CLASS_EFF_DATE
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


