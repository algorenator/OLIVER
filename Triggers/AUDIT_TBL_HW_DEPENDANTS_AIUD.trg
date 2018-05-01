--
-- AUDIT_TBL_HW_DEPENDANTS_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_HW_DEPENDANTS_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_HW_DEPENDANTS FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_HW_DEPENDANTS(HD_PLAN
                             ,HD_ID
                             ,HD_BEN_NO
                             ,HD_LAST_NAME
                             ,HD_FIRST_NAME
                             ,HD_DOB
                             ,HD_RELATION
                             ,HD_BE_PER
                             ,HD_EFF_DATE
                             ,HD_TERM_DATE
                             ,HD_SEX
                             ,HD_LAST_MODIFIED_BY
                             ,HD_LAST_MODIFIED_DATE
                             ,HD_KEY
                             ,HD_LATE_APP
                             ,HD_LATE_EFF_DATE
                             ,HD_LATE_TERM_DATE
                             ,HD_CLIENT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.HD_PLAN
                             ,:new.HD_ID
                             ,:new.HD_BEN_NO
                             ,:new.HD_LAST_NAME
                             ,:new.HD_FIRST_NAME
                             ,:new.HD_DOB
                             ,:new.HD_RELATION
                             ,:new.HD_BE_PER
                             ,:new.HD_EFF_DATE
                             ,:new.HD_TERM_DATE
                             ,:new.HD_SEX
                             ,:new.HD_LAST_MODIFIED_BY
                             ,:new.HD_LAST_MODIFIED_DATE
                             ,:new.HD_KEY
                             ,:new.HD_LATE_APP
                             ,:new.HD_LATE_EFF_DATE
                             ,:new.HD_LATE_TERM_DATE
                             ,:new.HD_CLIENT
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.HD_PLAN <> :new.HD_PLAN) or (:old.HD_PLAN IS NULL and  :new.HD_PLAN IS NOT NULL)  or (:old.HD_PLAN IS NOT NULL and  :new.HD_PLAN IS NULL))
                 or( (:old.HD_ID <> :new.HD_ID) or (:old.HD_ID IS NULL and  :new.HD_ID IS NOT NULL)  or (:old.HD_ID IS NOT NULL and  :new.HD_ID IS NULL))
                 or( (:old.HD_BEN_NO <> :new.HD_BEN_NO) or (:old.HD_BEN_NO IS NULL and  :new.HD_BEN_NO IS NOT NULL)  or (:old.HD_BEN_NO IS NOT NULL and  :new.HD_BEN_NO IS NULL))
                 or( (:old.HD_LAST_NAME <> :new.HD_LAST_NAME) or (:old.HD_LAST_NAME IS NULL and  :new.HD_LAST_NAME IS NOT NULL)  or (:old.HD_LAST_NAME IS NOT NULL and  :new.HD_LAST_NAME IS NULL))
                 or( (:old.HD_FIRST_NAME <> :new.HD_FIRST_NAME) or (:old.HD_FIRST_NAME IS NULL and  :new.HD_FIRST_NAME IS NOT NULL)  or (:old.HD_FIRST_NAME IS NOT NULL and  :new.HD_FIRST_NAME IS NULL))
                 or( (:old.HD_DOB <> :new.HD_DOB) or (:old.HD_DOB IS NULL and  :new.HD_DOB IS NOT NULL)  or (:old.HD_DOB IS NOT NULL and  :new.HD_DOB IS NULL))
                 or( (:old.HD_RELATION <> :new.HD_RELATION) or (:old.HD_RELATION IS NULL and  :new.HD_RELATION IS NOT NULL)  or (:old.HD_RELATION IS NOT NULL and  :new.HD_RELATION IS NULL))
                 or( (:old.HD_BE_PER <> :new.HD_BE_PER) or (:old.HD_BE_PER IS NULL and  :new.HD_BE_PER IS NOT NULL)  or (:old.HD_BE_PER IS NOT NULL and  :new.HD_BE_PER IS NULL))
                 or( (:old.HD_EFF_DATE <> :new.HD_EFF_DATE) or (:old.HD_EFF_DATE IS NULL and  :new.HD_EFF_DATE IS NOT NULL)  or (:old.HD_EFF_DATE IS NOT NULL and  :new.HD_EFF_DATE IS NULL))
                 or( (:old.HD_TERM_DATE <> :new.HD_TERM_DATE) or (:old.HD_TERM_DATE IS NULL and  :new.HD_TERM_DATE IS NOT NULL)  or (:old.HD_TERM_DATE IS NOT NULL and  :new.HD_TERM_DATE IS NULL))
                 or( (:old.HD_SEX <> :new.HD_SEX) or (:old.HD_SEX IS NULL and  :new.HD_SEX IS NOT NULL)  or (:old.HD_SEX IS NOT NULL and  :new.HD_SEX IS NULL))
                 or( (:old.HD_LAST_MODIFIED_BY <> :new.HD_LAST_MODIFIED_BY) or (:old.HD_LAST_MODIFIED_BY IS NULL and  :new.HD_LAST_MODIFIED_BY IS NOT NULL)  or (:old.HD_LAST_MODIFIED_BY IS NOT NULL and  :new.HD_LAST_MODIFIED_BY IS NULL))
                 or( (:old.HD_LAST_MODIFIED_DATE <> :new.HD_LAST_MODIFIED_DATE) or (:old.HD_LAST_MODIFIED_DATE IS NULL and  :new.HD_LAST_MODIFIED_DATE IS NOT NULL)  or (:old.HD_LAST_MODIFIED_DATE IS NOT NULL and  :new.HD_LAST_MODIFIED_DATE IS NULL))
                 or( (:old.HD_KEY <> :new.HD_KEY) or (:old.HD_KEY IS NULL and  :new.HD_KEY IS NOT NULL)  or (:old.HD_KEY IS NOT NULL and  :new.HD_KEY IS NULL))
                 or( (:old.HD_LATE_APP <> :new.HD_LATE_APP) or (:old.HD_LATE_APP IS NULL and  :new.HD_LATE_APP IS NOT NULL)  or (:old.HD_LATE_APP IS NOT NULL and  :new.HD_LATE_APP IS NULL))
                 or( (:old.HD_LATE_EFF_DATE <> :new.HD_LATE_EFF_DATE) or (:old.HD_LATE_EFF_DATE IS NULL and  :new.HD_LATE_EFF_DATE IS NOT NULL)  or (:old.HD_LATE_EFF_DATE IS NOT NULL and  :new.HD_LATE_EFF_DATE IS NULL))
                 or( (:old.HD_LATE_TERM_DATE <> :new.HD_LATE_TERM_DATE) or (:old.HD_LATE_TERM_DATE IS NULL and  :new.HD_LATE_TERM_DATE IS NOT NULL)  or (:old.HD_LATE_TERM_DATE IS NOT NULL and  :new.HD_LATE_TERM_DATE IS NULL))
                 or( (:old.HD_CLIENT <> :new.HD_CLIENT) or (:old.HD_CLIENT IS NULL and  :new.HD_CLIENT IS NOT NULL)  or (:old.HD_CLIENT IS NOT NULL and  :new.HD_CLIENT IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_HW_DEPENDANTS(HD_PLAN
                             ,HD_ID
                             ,HD_BEN_NO
                             ,HD_LAST_NAME
                             ,HD_FIRST_NAME
                             ,HD_DOB
                             ,HD_RELATION
                             ,HD_BE_PER
                             ,HD_EFF_DATE
                             ,HD_TERM_DATE
                             ,HD_SEX
                             ,HD_LAST_MODIFIED_BY
                             ,HD_LAST_MODIFIED_DATE
                             ,HD_KEY
                             ,HD_LATE_APP
                             ,HD_LATE_EFF_DATE
                             ,HD_LATE_TERM_DATE
                             ,HD_CLIENT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.HD_PLAN
                             ,:new.HD_ID
                             ,:new.HD_BEN_NO
                             ,:new.HD_LAST_NAME
                             ,:new.HD_FIRST_NAME
                             ,:new.HD_DOB
                             ,:new.HD_RELATION
                             ,:new.HD_BE_PER
                             ,:new.HD_EFF_DATE
                             ,:new.HD_TERM_DATE
                             ,:new.HD_SEX
                             ,:new.HD_LAST_MODIFIED_BY
                             ,:new.HD_LAST_MODIFIED_DATE
                             ,:new.HD_KEY
                             ,:new.HD_LATE_APP
                             ,:new.HD_LATE_EFF_DATE
                             ,:new.HD_LATE_TERM_DATE
                             ,:new.HD_CLIENT
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_HW_DEPENDANTS(HD_PLAN
                             ,HD_ID
                             ,HD_BEN_NO
                             ,HD_LAST_NAME
                             ,HD_FIRST_NAME
                             ,HD_DOB
                             ,HD_RELATION
                             ,HD_BE_PER
                             ,HD_EFF_DATE
                             ,HD_TERM_DATE
                             ,HD_SEX
                             ,HD_LAST_MODIFIED_BY
                             ,HD_LAST_MODIFIED_DATE
                             ,HD_KEY
                             ,HD_LATE_APP
                             ,HD_LATE_EFF_DATE
                             ,HD_LATE_TERM_DATE
                             ,HD_CLIENT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.HD_PLAN
                             ,:old.HD_ID
                             ,:old.HD_BEN_NO
                             ,:old.HD_LAST_NAME
                             ,:old.HD_FIRST_NAME
                             ,:old.HD_DOB
                             ,:old.HD_RELATION
                             ,:old.HD_BE_PER
                             ,:old.HD_EFF_DATE
                             ,:old.HD_TERM_DATE
                             ,:old.HD_SEX
                             ,:old.HD_LAST_MODIFIED_BY
                             ,:old.HD_LAST_MODIFIED_DATE
                             ,:old.HD_KEY
                             ,:old.HD_LATE_APP
                             ,:old.HD_LATE_EFF_DATE
                             ,:old.HD_LATE_TERM_DATE
                             ,:old.HD_CLIENT
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


