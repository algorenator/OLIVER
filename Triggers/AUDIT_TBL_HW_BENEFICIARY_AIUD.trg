--
-- AUDIT_TBL_HW_BENEFICIARY_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_HW_BENEFICIARY_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_HW_BENEFICIARY FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_HW_BENEFICIARY(HB_PLAN
                             ,HB_ID
                             ,HB_BEN_NO
                             ,HB_LAST_NAME
                             ,HB_FIRST_NAME
                             ,HB_DOB
                             ,HB_RELATION
                             ,HB_BE_PER
                             ,HB_EFF_DATE
                             ,HB_TERM_DATE
                             ,HB_SEX
                             ,HB_LAST_MODIFIED_BY
                             ,HB_LAST_MODIFIED_DATE
                             ,HB_KEY
                             ,HB_BENEFIT
                             ,HB_CLIENT
                             ,HB_LATE_APPLICANT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.HB_PLAN
                             ,:new.HB_ID
                             ,:new.HB_BEN_NO
                             ,:new.HB_LAST_NAME
                             ,:new.HB_FIRST_NAME
                             ,:new.HB_DOB
                             ,:new.HB_RELATION
                             ,:new.HB_BE_PER
                             ,:new.HB_EFF_DATE
                             ,:new.HB_TERM_DATE
                             ,:new.HB_SEX
                             ,:new.HB_LAST_MODIFIED_BY
                             ,:new.HB_LAST_MODIFIED_DATE
                             ,:new.HB_KEY
                             ,:new.HB_BENEFIT
                             ,:new.HB_CLIENT
                             ,:new.HB_LATE_APPLICANT
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.HB_PLAN <> :new.HB_PLAN) or (:old.HB_PLAN IS NULL and  :new.HB_PLAN IS NOT NULL)  or (:old.HB_PLAN IS NOT NULL and  :new.HB_PLAN IS NULL))
                 or( (:old.HB_ID <> :new.HB_ID) or (:old.HB_ID IS NULL and  :new.HB_ID IS NOT NULL)  or (:old.HB_ID IS NOT NULL and  :new.HB_ID IS NULL))
                 or( (:old.HB_BEN_NO <> :new.HB_BEN_NO) or (:old.HB_BEN_NO IS NULL and  :new.HB_BEN_NO IS NOT NULL)  or (:old.HB_BEN_NO IS NOT NULL and  :new.HB_BEN_NO IS NULL))
                 or( (:old.HB_LAST_NAME <> :new.HB_LAST_NAME) or (:old.HB_LAST_NAME IS NULL and  :new.HB_LAST_NAME IS NOT NULL)  or (:old.HB_LAST_NAME IS NOT NULL and  :new.HB_LAST_NAME IS NULL))
                 or( (:old.HB_FIRST_NAME <> :new.HB_FIRST_NAME) or (:old.HB_FIRST_NAME IS NULL and  :new.HB_FIRST_NAME IS NOT NULL)  or (:old.HB_FIRST_NAME IS NOT NULL and  :new.HB_FIRST_NAME IS NULL))
                 or( (:old.HB_DOB <> :new.HB_DOB) or (:old.HB_DOB IS NULL and  :new.HB_DOB IS NOT NULL)  or (:old.HB_DOB IS NOT NULL and  :new.HB_DOB IS NULL))
                 or( (:old.HB_RELATION <> :new.HB_RELATION) or (:old.HB_RELATION IS NULL and  :new.HB_RELATION IS NOT NULL)  or (:old.HB_RELATION IS NOT NULL and  :new.HB_RELATION IS NULL))
                 or( (:old.HB_BE_PER <> :new.HB_BE_PER) or (:old.HB_BE_PER IS NULL and  :new.HB_BE_PER IS NOT NULL)  or (:old.HB_BE_PER IS NOT NULL and  :new.HB_BE_PER IS NULL))
                 or( (:old.HB_EFF_DATE <> :new.HB_EFF_DATE) or (:old.HB_EFF_DATE IS NULL and  :new.HB_EFF_DATE IS NOT NULL)  or (:old.HB_EFF_DATE IS NOT NULL and  :new.HB_EFF_DATE IS NULL))
                 or( (:old.HB_TERM_DATE <> :new.HB_TERM_DATE) or (:old.HB_TERM_DATE IS NULL and  :new.HB_TERM_DATE IS NOT NULL)  or (:old.HB_TERM_DATE IS NOT NULL and  :new.HB_TERM_DATE IS NULL))
                 or( (:old.HB_SEX <> :new.HB_SEX) or (:old.HB_SEX IS NULL and  :new.HB_SEX IS NOT NULL)  or (:old.HB_SEX IS NOT NULL and  :new.HB_SEX IS NULL))
                 or( (:old.HB_LAST_MODIFIED_BY <> :new.HB_LAST_MODIFIED_BY) or (:old.HB_LAST_MODIFIED_BY IS NULL and  :new.HB_LAST_MODIFIED_BY IS NOT NULL)  or (:old.HB_LAST_MODIFIED_BY IS NOT NULL and  :new.HB_LAST_MODIFIED_BY IS NULL))
                 or( (:old.HB_LAST_MODIFIED_DATE <> :new.HB_LAST_MODIFIED_DATE) or (:old.HB_LAST_MODIFIED_DATE IS NULL and  :new.HB_LAST_MODIFIED_DATE IS NOT NULL)  or (:old.HB_LAST_MODIFIED_DATE IS NOT NULL and  :new.HB_LAST_MODIFIED_DATE IS NULL))
                 or( (:old.HB_KEY <> :new.HB_KEY) or (:old.HB_KEY IS NULL and  :new.HB_KEY IS NOT NULL)  or (:old.HB_KEY IS NOT NULL and  :new.HB_KEY IS NULL))
                 or( (:old.HB_BENEFIT <> :new.HB_BENEFIT) or (:old.HB_BENEFIT IS NULL and  :new.HB_BENEFIT IS NOT NULL)  or (:old.HB_BENEFIT IS NOT NULL and  :new.HB_BENEFIT IS NULL))
                 or( (:old.HB_CLIENT <> :new.HB_CLIENT) or (:old.HB_CLIENT IS NULL and  :new.HB_CLIENT IS NOT NULL)  or (:old.HB_CLIENT IS NOT NULL and  :new.HB_CLIENT IS NULL))
                 or( (:old.HB_LATE_APPLICANT <> :new.HB_LATE_APPLICANT) or (:old.HB_LATE_APPLICANT IS NULL and  :new.HB_LATE_APPLICANT IS NOT NULL)  or (:old.HB_LATE_APPLICANT IS NOT NULL and  :new.HB_LATE_APPLICANT IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_HW_BENEFICIARY(HB_PLAN
                             ,HB_ID
                             ,HB_BEN_NO
                             ,HB_LAST_NAME
                             ,HB_FIRST_NAME
                             ,HB_DOB
                             ,HB_RELATION
                             ,HB_BE_PER
                             ,HB_EFF_DATE
                             ,HB_TERM_DATE
                             ,HB_SEX
                             ,HB_LAST_MODIFIED_BY
                             ,HB_LAST_MODIFIED_DATE
                             ,HB_KEY
                             ,HB_BENEFIT
                             ,HB_CLIENT
                             ,HB_LATE_APPLICANT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.HB_PLAN
                             ,:new.HB_ID
                             ,:new.HB_BEN_NO
                             ,:new.HB_LAST_NAME
                             ,:new.HB_FIRST_NAME
                             ,:new.HB_DOB
                             ,:new.HB_RELATION
                             ,:new.HB_BE_PER
                             ,:new.HB_EFF_DATE
                             ,:new.HB_TERM_DATE
                             ,:new.HB_SEX
                             ,:new.HB_LAST_MODIFIED_BY
                             ,:new.HB_LAST_MODIFIED_DATE
                             ,:new.HB_KEY
                             ,:new.HB_BENEFIT
                             ,:new.HB_CLIENT
                             ,:new.HB_LATE_APPLICANT
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_HW_BENEFICIARY(HB_PLAN
                             ,HB_ID
                             ,HB_BEN_NO
                             ,HB_LAST_NAME
                             ,HB_FIRST_NAME
                             ,HB_DOB
                             ,HB_RELATION
                             ,HB_BE_PER
                             ,HB_EFF_DATE
                             ,HB_TERM_DATE
                             ,HB_SEX
                             ,HB_LAST_MODIFIED_BY
                             ,HB_LAST_MODIFIED_DATE
                             ,HB_KEY
                             ,HB_BENEFIT
                             ,HB_CLIENT
                             ,HB_LATE_APPLICANT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.HB_PLAN
                             ,:old.HB_ID
                             ,:old.HB_BEN_NO
                             ,:old.HB_LAST_NAME
                             ,:old.HB_FIRST_NAME
                             ,:old.HB_DOB
                             ,:old.HB_RELATION
                             ,:old.HB_BE_PER
                             ,:old.HB_EFF_DATE
                             ,:old.HB_TERM_DATE
                             ,:old.HB_SEX
                             ,:old.HB_LAST_MODIFIED_BY
                             ,:old.HB_LAST_MODIFIED_DATE
                             ,:old.HB_KEY
                             ,:old.HB_BENEFIT
                             ,:old.HB_CLIENT
                             ,:old.HB_LATE_APPLICANT
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


