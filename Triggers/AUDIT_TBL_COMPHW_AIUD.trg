--
-- AUDIT_TBL_COMPHW_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_COMPHW_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_COMPHW FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_COMPHW(CH_NUMBER
                             ,CH_DIV
                             ,CH_CONTACT
                             ,CH_ADDRESS1
                             ,CH_ADDRESS2
                             ,CH_CITY
                             ,CH_PROV
                             ,CH_COUNTRY
                             ,CH_PHONE1
                             ,CH_PHONE2
                             ,CH_FAX
                             ,CH_EMAIL1
                             ,CH_EMAIL2
                             ,CH_LANG_PREF
                             ,CH_PLAN
                             ,CH_LAST_MODIFIED_BY
                             ,CH_LAST_MODIFIED_DATE
                             ,CH_OS_BAL
                             ,CH_EFF_DATE
                             ,CH_TERM_DATE
                             ,CH_CLIENT_ID
                             ,CH_POSTAL_CODE
                             ,CH_LRD
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.CH_NUMBER
                             ,:new.CH_DIV
                             ,:new.CH_CONTACT
                             ,:new.CH_ADDRESS1
                             ,:new.CH_ADDRESS2
                             ,:new.CH_CITY
                             ,:new.CH_PROV
                             ,:new.CH_COUNTRY
                             ,:new.CH_PHONE1
                             ,:new.CH_PHONE2
                             ,:new.CH_FAX
                             ,:new.CH_EMAIL1
                             ,:new.CH_EMAIL2
                             ,:new.CH_LANG_PREF
                             ,:new.CH_PLAN
                             ,:new.CH_LAST_MODIFIED_BY
                             ,:new.CH_LAST_MODIFIED_DATE
                             ,:new.CH_OS_BAL
                             ,:new.CH_EFF_DATE
                             ,:new.CH_TERM_DATE
                             ,:new.CH_CLIENT_ID
                             ,:new.CH_POSTAL_CODE
                             ,:new.CH_LRD
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.CH_NUMBER <> :new.CH_NUMBER) or (:old.CH_NUMBER IS NULL and  :new.CH_NUMBER IS NOT NULL)  or (:old.CH_NUMBER IS NOT NULL and  :new.CH_NUMBER IS NULL))
                 or( (:old.CH_DIV <> :new.CH_DIV) or (:old.CH_DIV IS NULL and  :new.CH_DIV IS NOT NULL)  or (:old.CH_DIV IS NOT NULL and  :new.CH_DIV IS NULL))
                 or( (:old.CH_CONTACT <> :new.CH_CONTACT) or (:old.CH_CONTACT IS NULL and  :new.CH_CONTACT IS NOT NULL)  or (:old.CH_CONTACT IS NOT NULL and  :new.CH_CONTACT IS NULL))
                 or( (:old.CH_ADDRESS1 <> :new.CH_ADDRESS1) or (:old.CH_ADDRESS1 IS NULL and  :new.CH_ADDRESS1 IS NOT NULL)  or (:old.CH_ADDRESS1 IS NOT NULL and  :new.CH_ADDRESS1 IS NULL))
                 or( (:old.CH_ADDRESS2 <> :new.CH_ADDRESS2) or (:old.CH_ADDRESS2 IS NULL and  :new.CH_ADDRESS2 IS NOT NULL)  or (:old.CH_ADDRESS2 IS NOT NULL and  :new.CH_ADDRESS2 IS NULL))
                 or( (:old.CH_CITY <> :new.CH_CITY) or (:old.CH_CITY IS NULL and  :new.CH_CITY IS NOT NULL)  or (:old.CH_CITY IS NOT NULL and  :new.CH_CITY IS NULL))
                 or( (:old.CH_PROV <> :new.CH_PROV) or (:old.CH_PROV IS NULL and  :new.CH_PROV IS NOT NULL)  or (:old.CH_PROV IS NOT NULL and  :new.CH_PROV IS NULL))
                 or( (:old.CH_COUNTRY <> :new.CH_COUNTRY) or (:old.CH_COUNTRY IS NULL and  :new.CH_COUNTRY IS NOT NULL)  or (:old.CH_COUNTRY IS NOT NULL and  :new.CH_COUNTRY IS NULL))
                 or( (:old.CH_PHONE1 <> :new.CH_PHONE1) or (:old.CH_PHONE1 IS NULL and  :new.CH_PHONE1 IS NOT NULL)  or (:old.CH_PHONE1 IS NOT NULL and  :new.CH_PHONE1 IS NULL))
                 or( (:old.CH_PHONE2 <> :new.CH_PHONE2) or (:old.CH_PHONE2 IS NULL and  :new.CH_PHONE2 IS NOT NULL)  or (:old.CH_PHONE2 IS NOT NULL and  :new.CH_PHONE2 IS NULL))
                 or( (:old.CH_FAX <> :new.CH_FAX) or (:old.CH_FAX IS NULL and  :new.CH_FAX IS NOT NULL)  or (:old.CH_FAX IS NOT NULL and  :new.CH_FAX IS NULL))
                 or( (:old.CH_EMAIL1 <> :new.CH_EMAIL1) or (:old.CH_EMAIL1 IS NULL and  :new.CH_EMAIL1 IS NOT NULL)  or (:old.CH_EMAIL1 IS NOT NULL and  :new.CH_EMAIL1 IS NULL))
                 or( (:old.CH_EMAIL2 <> :new.CH_EMAIL2) or (:old.CH_EMAIL2 IS NULL and  :new.CH_EMAIL2 IS NOT NULL)  or (:old.CH_EMAIL2 IS NOT NULL and  :new.CH_EMAIL2 IS NULL))
                 or( (:old.CH_LANG_PREF <> :new.CH_LANG_PREF) or (:old.CH_LANG_PREF IS NULL and  :new.CH_LANG_PREF IS NOT NULL)  or (:old.CH_LANG_PREF IS NOT NULL and  :new.CH_LANG_PREF IS NULL))
                 or( (:old.CH_PLAN <> :new.CH_PLAN) or (:old.CH_PLAN IS NULL and  :new.CH_PLAN IS NOT NULL)  or (:old.CH_PLAN IS NOT NULL and  :new.CH_PLAN IS NULL))
                 or( (:old.CH_LAST_MODIFIED_BY <> :new.CH_LAST_MODIFIED_BY) or (:old.CH_LAST_MODIFIED_BY IS NULL and  :new.CH_LAST_MODIFIED_BY IS NOT NULL)  or (:old.CH_LAST_MODIFIED_BY IS NOT NULL and  :new.CH_LAST_MODIFIED_BY IS NULL))
                 or( (:old.CH_LAST_MODIFIED_DATE <> :new.CH_LAST_MODIFIED_DATE) or (:old.CH_LAST_MODIFIED_DATE IS NULL and  :new.CH_LAST_MODIFIED_DATE IS NOT NULL)  or (:old.CH_LAST_MODIFIED_DATE IS NOT NULL and  :new.CH_LAST_MODIFIED_DATE IS NULL))
                 or( (:old.CH_OS_BAL <> :new.CH_OS_BAL) or (:old.CH_OS_BAL IS NULL and  :new.CH_OS_BAL IS NOT NULL)  or (:old.CH_OS_BAL IS NOT NULL and  :new.CH_OS_BAL IS NULL))
                 or( (:old.CH_EFF_DATE <> :new.CH_EFF_DATE) or (:old.CH_EFF_DATE IS NULL and  :new.CH_EFF_DATE IS NOT NULL)  or (:old.CH_EFF_DATE IS NOT NULL and  :new.CH_EFF_DATE IS NULL))
                 or( (:old.CH_TERM_DATE <> :new.CH_TERM_DATE) or (:old.CH_TERM_DATE IS NULL and  :new.CH_TERM_DATE IS NOT NULL)  or (:old.CH_TERM_DATE IS NOT NULL and  :new.CH_TERM_DATE IS NULL))
                 or( (:old.CH_CLIENT_ID <> :new.CH_CLIENT_ID) or (:old.CH_CLIENT_ID IS NULL and  :new.CH_CLIENT_ID IS NOT NULL)  or (:old.CH_CLIENT_ID IS NOT NULL and  :new.CH_CLIENT_ID IS NULL))
                 or( (:old.CH_POSTAL_CODE <> :new.CH_POSTAL_CODE) or (:old.CH_POSTAL_CODE IS NULL and  :new.CH_POSTAL_CODE IS NOT NULL)  or (:old.CH_POSTAL_CODE IS NOT NULL and  :new.CH_POSTAL_CODE IS NULL))
                 or( (:old.CH_LRD <> :new.CH_LRD) or (:old.CH_LRD IS NULL and  :new.CH_LRD IS NOT NULL)  or (:old.CH_LRD IS NOT NULL and  :new.CH_LRD IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_COMPHW(CH_NUMBER
                             ,CH_DIV
                             ,CH_CONTACT
                             ,CH_ADDRESS1
                             ,CH_ADDRESS2
                             ,CH_CITY
                             ,CH_PROV
                             ,CH_COUNTRY
                             ,CH_PHONE1
                             ,CH_PHONE2
                             ,CH_FAX
                             ,CH_EMAIL1
                             ,CH_EMAIL2
                             ,CH_LANG_PREF
                             ,CH_PLAN
                             ,CH_LAST_MODIFIED_BY
                             ,CH_LAST_MODIFIED_DATE
                             ,CH_OS_BAL
                             ,CH_EFF_DATE
                             ,CH_TERM_DATE
                             ,CH_CLIENT_ID
                             ,CH_POSTAL_CODE
                             ,CH_LRD
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.CH_NUMBER
                             ,:new.CH_DIV
                             ,:new.CH_CONTACT
                             ,:new.CH_ADDRESS1
                             ,:new.CH_ADDRESS2
                             ,:new.CH_CITY
                             ,:new.CH_PROV
                             ,:new.CH_COUNTRY
                             ,:new.CH_PHONE1
                             ,:new.CH_PHONE2
                             ,:new.CH_FAX
                             ,:new.CH_EMAIL1
                             ,:new.CH_EMAIL2
                             ,:new.CH_LANG_PREF
                             ,:new.CH_PLAN
                             ,:new.CH_LAST_MODIFIED_BY
                             ,:new.CH_LAST_MODIFIED_DATE
                             ,:new.CH_OS_BAL
                             ,:new.CH_EFF_DATE
                             ,:new.CH_TERM_DATE
                             ,:new.CH_CLIENT_ID
                             ,:new.CH_POSTAL_CODE
                             ,:new.CH_LRD
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_COMPHW(CH_NUMBER
                             ,CH_DIV
                             ,CH_CONTACT
                             ,CH_ADDRESS1
                             ,CH_ADDRESS2
                             ,CH_CITY
                             ,CH_PROV
                             ,CH_COUNTRY
                             ,CH_PHONE1
                             ,CH_PHONE2
                             ,CH_FAX
                             ,CH_EMAIL1
                             ,CH_EMAIL2
                             ,CH_LANG_PREF
                             ,CH_PLAN
                             ,CH_LAST_MODIFIED_BY
                             ,CH_LAST_MODIFIED_DATE
                             ,CH_OS_BAL
                             ,CH_EFF_DATE
                             ,CH_TERM_DATE
                             ,CH_CLIENT_ID
                             ,CH_POSTAL_CODE
                             ,CH_LRD
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.CH_NUMBER
                             ,:old.CH_DIV
                             ,:old.CH_CONTACT
                             ,:old.CH_ADDRESS1
                             ,:old.CH_ADDRESS2
                             ,:old.CH_CITY
                             ,:old.CH_PROV
                             ,:old.CH_COUNTRY
                             ,:old.CH_PHONE1
                             ,:old.CH_PHONE2
                             ,:old.CH_FAX
                             ,:old.CH_EMAIL1
                             ,:old.CH_EMAIL2
                             ,:old.CH_LANG_PREF
                             ,:old.CH_PLAN
                             ,:old.CH_LAST_MODIFIED_BY
                             ,:old.CH_LAST_MODIFIED_DATE
                             ,:old.CH_OS_BAL
                             ,:old.CH_EFF_DATE
                             ,:old.CH_TERM_DATE
                             ,:old.CH_CLIENT_ID
                             ,:old.CH_POSTAL_CODE
                             ,:old.CH_LRD
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


