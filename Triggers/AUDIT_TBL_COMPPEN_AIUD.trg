--
-- AUDIT_TBL_COMPPEN_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_COMPPEN_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_COMPPEN FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_COMPPEN(CP_NUMBER
                             ,CP_DIV
                             ,CP_CONTACT
                             ,CP_ADDRESS1
                             ,CP_ADDRESS2
                             ,CP_CITY
                             ,CP_PROV
                             ,CP_COUNTRY
                             ,CP_PHONE1
                             ,CP_PHONE2
                             ,CP_FAX
                             ,CP_EMAIL1
                             ,CP_EMAIL2
                             ,CP_LANG_PREF
                             ,CP_PLAN
                             ,CP_LAST_MODIFIED_BY
                             ,CP_LAST_MODIFIED_DATE
                             ,CP_OS_BAL
                             ,CP_EFF_DATE
                             ,CP_TERM_DATE
                             ,CP_LRD
                             ,CP_WORK_PROV
                             ,CP_CLIENT
                             ,CP_CREATED_DATE
                             ,CP_CREATED_BY
                             ,CP_POST_CODE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.CP_NUMBER
                             ,:new.CP_DIV
                             ,:new.CP_CONTACT
                             ,:new.CP_ADDRESS1
                             ,:new.CP_ADDRESS2
                             ,:new.CP_CITY
                             ,:new.CP_PROV
                             ,:new.CP_COUNTRY
                             ,:new.CP_PHONE1
                             ,:new.CP_PHONE2
                             ,:new.CP_FAX
                             ,:new.CP_EMAIL1
                             ,:new.CP_EMAIL2
                             ,:new.CP_LANG_PREF
                             ,:new.CP_PLAN
                             ,:new.CP_LAST_MODIFIED_BY
                             ,:new.CP_LAST_MODIFIED_DATE
                             ,:new.CP_OS_BAL
                             ,:new.CP_EFF_DATE
                             ,:new.CP_TERM_DATE
                             ,:new.CP_LRD
                             ,:new.CP_WORK_PROV
                             ,:new.CP_CLIENT
                             ,:new.CP_CREATED_DATE
                             ,:new.CP_CREATED_BY
                             ,:new.CP_POST_CODE
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.CP_NUMBER <> :new.CP_NUMBER) or (:old.CP_NUMBER IS NULL and  :new.CP_NUMBER IS NOT NULL)  or (:old.CP_NUMBER IS NOT NULL and  :new.CP_NUMBER IS NULL))
                 or( (:old.CP_DIV <> :new.CP_DIV) or (:old.CP_DIV IS NULL and  :new.CP_DIV IS NOT NULL)  or (:old.CP_DIV IS NOT NULL and  :new.CP_DIV IS NULL))
                 or( (:old.CP_CONTACT <> :new.CP_CONTACT) or (:old.CP_CONTACT IS NULL and  :new.CP_CONTACT IS NOT NULL)  or (:old.CP_CONTACT IS NOT NULL and  :new.CP_CONTACT IS NULL))
                 or( (:old.CP_ADDRESS1 <> :new.CP_ADDRESS1) or (:old.CP_ADDRESS1 IS NULL and  :new.CP_ADDRESS1 IS NOT NULL)  or (:old.CP_ADDRESS1 IS NOT NULL and  :new.CP_ADDRESS1 IS NULL))
                 or( (:old.CP_ADDRESS2 <> :new.CP_ADDRESS2) or (:old.CP_ADDRESS2 IS NULL and  :new.CP_ADDRESS2 IS NOT NULL)  or (:old.CP_ADDRESS2 IS NOT NULL and  :new.CP_ADDRESS2 IS NULL))
                 or( (:old.CP_CITY <> :new.CP_CITY) or (:old.CP_CITY IS NULL and  :new.CP_CITY IS NOT NULL)  or (:old.CP_CITY IS NOT NULL and  :new.CP_CITY IS NULL))
                 or( (:old.CP_PROV <> :new.CP_PROV) or (:old.CP_PROV IS NULL and  :new.CP_PROV IS NOT NULL)  or (:old.CP_PROV IS NOT NULL and  :new.CP_PROV IS NULL))
                 or( (:old.CP_COUNTRY <> :new.CP_COUNTRY) or (:old.CP_COUNTRY IS NULL and  :new.CP_COUNTRY IS NOT NULL)  or (:old.CP_COUNTRY IS NOT NULL and  :new.CP_COUNTRY IS NULL))
                 or( (:old.CP_PHONE1 <> :new.CP_PHONE1) or (:old.CP_PHONE1 IS NULL and  :new.CP_PHONE1 IS NOT NULL)  or (:old.CP_PHONE1 IS NOT NULL and  :new.CP_PHONE1 IS NULL))
                 or( (:old.CP_PHONE2 <> :new.CP_PHONE2) or (:old.CP_PHONE2 IS NULL and  :new.CP_PHONE2 IS NOT NULL)  or (:old.CP_PHONE2 IS NOT NULL and  :new.CP_PHONE2 IS NULL))
                 or( (:old.CP_FAX <> :new.CP_FAX) or (:old.CP_FAX IS NULL and  :new.CP_FAX IS NOT NULL)  or (:old.CP_FAX IS NOT NULL and  :new.CP_FAX IS NULL))
                 or( (:old.CP_EMAIL1 <> :new.CP_EMAIL1) or (:old.CP_EMAIL1 IS NULL and  :new.CP_EMAIL1 IS NOT NULL)  or (:old.CP_EMAIL1 IS NOT NULL and  :new.CP_EMAIL1 IS NULL))
                 or( (:old.CP_EMAIL2 <> :new.CP_EMAIL2) or (:old.CP_EMAIL2 IS NULL and  :new.CP_EMAIL2 IS NOT NULL)  or (:old.CP_EMAIL2 IS NOT NULL and  :new.CP_EMAIL2 IS NULL))
                 or( (:old.CP_LANG_PREF <> :new.CP_LANG_PREF) or (:old.CP_LANG_PREF IS NULL and  :new.CP_LANG_PREF IS NOT NULL)  or (:old.CP_LANG_PREF IS NOT NULL and  :new.CP_LANG_PREF IS NULL))
                 or( (:old.CP_PLAN <> :new.CP_PLAN) or (:old.CP_PLAN IS NULL and  :new.CP_PLAN IS NOT NULL)  or (:old.CP_PLAN IS NOT NULL and  :new.CP_PLAN IS NULL))
                 or( (:old.CP_LAST_MODIFIED_BY <> :new.CP_LAST_MODIFIED_BY) or (:old.CP_LAST_MODIFIED_BY IS NULL and  :new.CP_LAST_MODIFIED_BY IS NOT NULL)  or (:old.CP_LAST_MODIFIED_BY IS NOT NULL and  :new.CP_LAST_MODIFIED_BY IS NULL))
                 or( (:old.CP_LAST_MODIFIED_DATE <> :new.CP_LAST_MODIFIED_DATE) or (:old.CP_LAST_MODIFIED_DATE IS NULL and  :new.CP_LAST_MODIFIED_DATE IS NOT NULL)  or (:old.CP_LAST_MODIFIED_DATE IS NOT NULL and  :new.CP_LAST_MODIFIED_DATE IS NULL))
                 or( (:old.CP_OS_BAL <> :new.CP_OS_BAL) or (:old.CP_OS_BAL IS NULL and  :new.CP_OS_BAL IS NOT NULL)  or (:old.CP_OS_BAL IS NOT NULL and  :new.CP_OS_BAL IS NULL))
                 or( (:old.CP_EFF_DATE <> :new.CP_EFF_DATE) or (:old.CP_EFF_DATE IS NULL and  :new.CP_EFF_DATE IS NOT NULL)  or (:old.CP_EFF_DATE IS NOT NULL and  :new.CP_EFF_DATE IS NULL))
                 or( (:old.CP_TERM_DATE <> :new.CP_TERM_DATE) or (:old.CP_TERM_DATE IS NULL and  :new.CP_TERM_DATE IS NOT NULL)  or (:old.CP_TERM_DATE IS NOT NULL and  :new.CP_TERM_DATE IS NULL))
                 or( (:old.CP_LRD <> :new.CP_LRD) or (:old.CP_LRD IS NULL and  :new.CP_LRD IS NOT NULL)  or (:old.CP_LRD IS NOT NULL and  :new.CP_LRD IS NULL))
                 or( (:old.CP_WORK_PROV <> :new.CP_WORK_PROV) or (:old.CP_WORK_PROV IS NULL and  :new.CP_WORK_PROV IS NOT NULL)  or (:old.CP_WORK_PROV IS NOT NULL and  :new.CP_WORK_PROV IS NULL))
                 or( (:old.CP_CLIENT <> :new.CP_CLIENT) or (:old.CP_CLIENT IS NULL and  :new.CP_CLIENT IS NOT NULL)  or (:old.CP_CLIENT IS NOT NULL and  :new.CP_CLIENT IS NULL))
                 or( (:old.CP_CREATED_DATE <> :new.CP_CREATED_DATE) or (:old.CP_CREATED_DATE IS NULL and  :new.CP_CREATED_DATE IS NOT NULL)  or (:old.CP_CREATED_DATE IS NOT NULL and  :new.CP_CREATED_DATE IS NULL))
                 or( (:old.CP_CREATED_BY <> :new.CP_CREATED_BY) or (:old.CP_CREATED_BY IS NULL and  :new.CP_CREATED_BY IS NOT NULL)  or (:old.CP_CREATED_BY IS NOT NULL and  :new.CP_CREATED_BY IS NULL))
                 or( (:old.CP_POST_CODE <> :new.CP_POST_CODE) or (:old.CP_POST_CODE IS NULL and  :new.CP_POST_CODE IS NOT NULL)  or (:old.CP_POST_CODE IS NOT NULL and  :new.CP_POST_CODE IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_COMPPEN(CP_NUMBER
                             ,CP_DIV
                             ,CP_CONTACT
                             ,CP_ADDRESS1
                             ,CP_ADDRESS2
                             ,CP_CITY
                             ,CP_PROV
                             ,CP_COUNTRY
                             ,CP_PHONE1
                             ,CP_PHONE2
                             ,CP_FAX
                             ,CP_EMAIL1
                             ,CP_EMAIL2
                             ,CP_LANG_PREF
                             ,CP_PLAN
                             ,CP_LAST_MODIFIED_BY
                             ,CP_LAST_MODIFIED_DATE
                             ,CP_OS_BAL
                             ,CP_EFF_DATE
                             ,CP_TERM_DATE
                             ,CP_LRD
                             ,CP_WORK_PROV
                             ,CP_CLIENT
                             ,CP_CREATED_DATE
                             ,CP_CREATED_BY
                             ,CP_POST_CODE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.CP_NUMBER
                             ,:new.CP_DIV
                             ,:new.CP_CONTACT
                             ,:new.CP_ADDRESS1
                             ,:new.CP_ADDRESS2
                             ,:new.CP_CITY
                             ,:new.CP_PROV
                             ,:new.CP_COUNTRY
                             ,:new.CP_PHONE1
                             ,:new.CP_PHONE2
                             ,:new.CP_FAX
                             ,:new.CP_EMAIL1
                             ,:new.CP_EMAIL2
                             ,:new.CP_LANG_PREF
                             ,:new.CP_PLAN
                             ,:new.CP_LAST_MODIFIED_BY
                             ,:new.CP_LAST_MODIFIED_DATE
                             ,:new.CP_OS_BAL
                             ,:new.CP_EFF_DATE
                             ,:new.CP_TERM_DATE
                             ,:new.CP_LRD
                             ,:new.CP_WORK_PROV
                             ,:new.CP_CLIENT
                             ,:new.CP_CREATED_DATE
                             ,:new.CP_CREATED_BY
                             ,:new.CP_POST_CODE
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_COMPPEN(CP_NUMBER
                             ,CP_DIV
                             ,CP_CONTACT
                             ,CP_ADDRESS1
                             ,CP_ADDRESS2
                             ,CP_CITY
                             ,CP_PROV
                             ,CP_COUNTRY
                             ,CP_PHONE1
                             ,CP_PHONE2
                             ,CP_FAX
                             ,CP_EMAIL1
                             ,CP_EMAIL2
                             ,CP_LANG_PREF
                             ,CP_PLAN
                             ,CP_LAST_MODIFIED_BY
                             ,CP_LAST_MODIFIED_DATE
                             ,CP_OS_BAL
                             ,CP_EFF_DATE
                             ,CP_TERM_DATE
                             ,CP_LRD
                             ,CP_WORK_PROV
                             ,CP_CLIENT
                             ,CP_CREATED_DATE
                             ,CP_CREATED_BY
                             ,CP_POST_CODE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.CP_NUMBER
                             ,:old.CP_DIV
                             ,:old.CP_CONTACT
                             ,:old.CP_ADDRESS1
                             ,:old.CP_ADDRESS2
                             ,:old.CP_CITY
                             ,:old.CP_PROV
                             ,:old.CP_COUNTRY
                             ,:old.CP_PHONE1
                             ,:old.CP_PHONE2
                             ,:old.CP_FAX
                             ,:old.CP_EMAIL1
                             ,:old.CP_EMAIL2
                             ,:old.CP_LANG_PREF
                             ,:old.CP_PLAN
                             ,:old.CP_LAST_MODIFIED_BY
                             ,:old.CP_LAST_MODIFIED_DATE
                             ,:old.CP_OS_BAL
                             ,:old.CP_EFF_DATE
                             ,:old.CP_TERM_DATE
                             ,:old.CP_LRD
                             ,:old.CP_WORK_PROV
                             ,:old.CP_CLIENT
                             ,:old.CP_CREATED_DATE
                             ,:old.CP_CREATED_BY
                             ,:old.CP_POST_CODE
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


