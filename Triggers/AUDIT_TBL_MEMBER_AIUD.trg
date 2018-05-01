--
-- AUDIT_TBL_MEMBER_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_MEMBER_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_MEMBER FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_MEMBER(MEM_ID
                             ,MEM_SIN
                             ,MEM_FIRST_NAME
                             ,MEM_MIDDLE_NAME
                             ,MEM_LAST_NAME
                             ,MEM_GENDER
                             ,MEM_DOB
                             ,MEM_ADDRESS1
                             ,MEM_ADDRESS2
                             ,MEM_CITY
                             ,MEM_PROV
                             ,MEM_COUNTRY
                             ,MEM_POSTAL_CODE
                             ,MEM_EMAIL
                             ,MEM_HOME_PHONE
                             ,MEM_WORK_PHONE
                             ,MEM_CELL_PHONE
                             ,MEM_FAX
                             ,MEM_LANG_PREF
                             ,MEM_LAST_MODIFIED_BY
                             ,MEM_LAST_MODIFIED_DATE
                             ,MEM_PLAN
                             ,MEM_FILE_NAME
                             ,MEM_MIME_TYPE
                             ,MEM_DOD
                             ,MEM_TITLE
                             ,MEM_CREATED_BY
                             ,MEM_CREATED_DATE
                             ,MEM_CLIENT_ID
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.MEM_ID
                             ,:new.MEM_SIN
                             ,:new.MEM_FIRST_NAME
                             ,:new.MEM_MIDDLE_NAME
                             ,:new.MEM_LAST_NAME
                             ,:new.MEM_GENDER
                             ,:new.MEM_DOB
                             ,:new.MEM_ADDRESS1
                             ,:new.MEM_ADDRESS2
                             ,:new.MEM_CITY
                             ,:new.MEM_PROV
                             ,:new.MEM_COUNTRY
                             ,:new.MEM_POSTAL_CODE
                             ,:new.MEM_EMAIL
                             ,:new.MEM_HOME_PHONE
                             ,:new.MEM_WORK_PHONE
                             ,:new.MEM_CELL_PHONE
                             ,:new.MEM_FAX
                             ,:new.MEM_LANG_PREF
                             ,:new.MEM_LAST_MODIFIED_BY
                             ,:new.MEM_LAST_MODIFIED_DATE
                             ,:new.MEM_PLAN
                             ,:new.MEM_FILE_NAME
                             ,:new.MEM_MIME_TYPE
                             ,:new.MEM_DOD
                             ,:new.MEM_TITLE
                             ,:new.MEM_CREATED_BY
                             ,:new.MEM_CREATED_DATE
                             ,:new.MEM_CLIENT_ID
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.MEM_ID <> :new.MEM_ID) or (:old.MEM_ID IS NULL and  :new.MEM_ID IS NOT NULL)  or (:old.MEM_ID IS NOT NULL and  :new.MEM_ID IS NULL))
                 or( (:old.MEM_SIN <> :new.MEM_SIN) or (:old.MEM_SIN IS NULL and  :new.MEM_SIN IS NOT NULL)  or (:old.MEM_SIN IS NOT NULL and  :new.MEM_SIN IS NULL))
                 or( (:old.MEM_FIRST_NAME <> :new.MEM_FIRST_NAME) or (:old.MEM_FIRST_NAME IS NULL and  :new.MEM_FIRST_NAME IS NOT NULL)  or (:old.MEM_FIRST_NAME IS NOT NULL and  :new.MEM_FIRST_NAME IS NULL))
                 or( (:old.MEM_MIDDLE_NAME <> :new.MEM_MIDDLE_NAME) or (:old.MEM_MIDDLE_NAME IS NULL and  :new.MEM_MIDDLE_NAME IS NOT NULL)  or (:old.MEM_MIDDLE_NAME IS NOT NULL and  :new.MEM_MIDDLE_NAME IS NULL))
                 or( (:old.MEM_LAST_NAME <> :new.MEM_LAST_NAME) or (:old.MEM_LAST_NAME IS NULL and  :new.MEM_LAST_NAME IS NOT NULL)  or (:old.MEM_LAST_NAME IS NOT NULL and  :new.MEM_LAST_NAME IS NULL))
                 or( (:old.MEM_GENDER <> :new.MEM_GENDER) or (:old.MEM_GENDER IS NULL and  :new.MEM_GENDER IS NOT NULL)  or (:old.MEM_GENDER IS NOT NULL and  :new.MEM_GENDER IS NULL))
                 or( (:old.MEM_DOB <> :new.MEM_DOB) or (:old.MEM_DOB IS NULL and  :new.MEM_DOB IS NOT NULL)  or (:old.MEM_DOB IS NOT NULL and  :new.MEM_DOB IS NULL))
                 or( (:old.MEM_ADDRESS1 <> :new.MEM_ADDRESS1) or (:old.MEM_ADDRESS1 IS NULL and  :new.MEM_ADDRESS1 IS NOT NULL)  or (:old.MEM_ADDRESS1 IS NOT NULL and  :new.MEM_ADDRESS1 IS NULL))
                 or( (:old.MEM_ADDRESS2 <> :new.MEM_ADDRESS2) or (:old.MEM_ADDRESS2 IS NULL and  :new.MEM_ADDRESS2 IS NOT NULL)  or (:old.MEM_ADDRESS2 IS NOT NULL and  :new.MEM_ADDRESS2 IS NULL))
                 or( (:old.MEM_CITY <> :new.MEM_CITY) or (:old.MEM_CITY IS NULL and  :new.MEM_CITY IS NOT NULL)  or (:old.MEM_CITY IS NOT NULL and  :new.MEM_CITY IS NULL))
                 or( (:old.MEM_PROV <> :new.MEM_PROV) or (:old.MEM_PROV IS NULL and  :new.MEM_PROV IS NOT NULL)  or (:old.MEM_PROV IS NOT NULL and  :new.MEM_PROV IS NULL))
                 or( (:old.MEM_COUNTRY <> :new.MEM_COUNTRY) or (:old.MEM_COUNTRY IS NULL and  :new.MEM_COUNTRY IS NOT NULL)  or (:old.MEM_COUNTRY IS NOT NULL and  :new.MEM_COUNTRY IS NULL))
                 or( (:old.MEM_POSTAL_CODE <> :new.MEM_POSTAL_CODE) or (:old.MEM_POSTAL_CODE IS NULL and  :new.MEM_POSTAL_CODE IS NOT NULL)  or (:old.MEM_POSTAL_CODE IS NOT NULL and  :new.MEM_POSTAL_CODE IS NULL))
                 or( (:old.MEM_EMAIL <> :new.MEM_EMAIL) or (:old.MEM_EMAIL IS NULL and  :new.MEM_EMAIL IS NOT NULL)  or (:old.MEM_EMAIL IS NOT NULL and  :new.MEM_EMAIL IS NULL))
                 or( (:old.MEM_HOME_PHONE <> :new.MEM_HOME_PHONE) or (:old.MEM_HOME_PHONE IS NULL and  :new.MEM_HOME_PHONE IS NOT NULL)  or (:old.MEM_HOME_PHONE IS NOT NULL and  :new.MEM_HOME_PHONE IS NULL))
                 or( (:old.MEM_WORK_PHONE <> :new.MEM_WORK_PHONE) or (:old.MEM_WORK_PHONE IS NULL and  :new.MEM_WORK_PHONE IS NOT NULL)  or (:old.MEM_WORK_PHONE IS NOT NULL and  :new.MEM_WORK_PHONE IS NULL))
                 or( (:old.MEM_CELL_PHONE <> :new.MEM_CELL_PHONE) or (:old.MEM_CELL_PHONE IS NULL and  :new.MEM_CELL_PHONE IS NOT NULL)  or (:old.MEM_CELL_PHONE IS NOT NULL and  :new.MEM_CELL_PHONE IS NULL))
                 or( (:old.MEM_FAX <> :new.MEM_FAX) or (:old.MEM_FAX IS NULL and  :new.MEM_FAX IS NOT NULL)  or (:old.MEM_FAX IS NOT NULL and  :new.MEM_FAX IS NULL))
                 or( (:old.MEM_LANG_PREF <> :new.MEM_LANG_PREF) or (:old.MEM_LANG_PREF IS NULL and  :new.MEM_LANG_PREF IS NOT NULL)  or (:old.MEM_LANG_PREF IS NOT NULL and  :new.MEM_LANG_PREF IS NULL))
                 or( (:old.MEM_LAST_MODIFIED_BY <> :new.MEM_LAST_MODIFIED_BY) or (:old.MEM_LAST_MODIFIED_BY IS NULL and  :new.MEM_LAST_MODIFIED_BY IS NOT NULL)  or (:old.MEM_LAST_MODIFIED_BY IS NOT NULL and  :new.MEM_LAST_MODIFIED_BY IS NULL))
                 or( (:old.MEM_LAST_MODIFIED_DATE <> :new.MEM_LAST_MODIFIED_DATE) or (:old.MEM_LAST_MODIFIED_DATE IS NULL and  :new.MEM_LAST_MODIFIED_DATE IS NOT NULL)  or (:old.MEM_LAST_MODIFIED_DATE IS NOT NULL and  :new.MEM_LAST_MODIFIED_DATE IS NULL))
                 or( (:old.MEM_PLAN <> :new.MEM_PLAN) or (:old.MEM_PLAN IS NULL and  :new.MEM_PLAN IS NOT NULL)  or (:old.MEM_PLAN IS NOT NULL and  :new.MEM_PLAN IS NULL))
                 or( (:old.MEM_FILE_NAME <> :new.MEM_FILE_NAME) or (:old.MEM_FILE_NAME IS NULL and  :new.MEM_FILE_NAME IS NOT NULL)  or (:old.MEM_FILE_NAME IS NOT NULL and  :new.MEM_FILE_NAME IS NULL))
                 or( (:old.MEM_MIME_TYPE <> :new.MEM_MIME_TYPE) or (:old.MEM_MIME_TYPE IS NULL and  :new.MEM_MIME_TYPE IS NOT NULL)  or (:old.MEM_MIME_TYPE IS NOT NULL and  :new.MEM_MIME_TYPE IS NULL))
                 or( (:old.MEM_DOD <> :new.MEM_DOD) or (:old.MEM_DOD IS NULL and  :new.MEM_DOD IS NOT NULL)  or (:old.MEM_DOD IS NOT NULL and  :new.MEM_DOD IS NULL))
                 or( (:old.MEM_TITLE <> :new.MEM_TITLE) or (:old.MEM_TITLE IS NULL and  :new.MEM_TITLE IS NOT NULL)  or (:old.MEM_TITLE IS NOT NULL and  :new.MEM_TITLE IS NULL))
                 or( (:old.MEM_CREATED_BY <> :new.MEM_CREATED_BY) or (:old.MEM_CREATED_BY IS NULL and  :new.MEM_CREATED_BY IS NOT NULL)  or (:old.MEM_CREATED_BY IS NOT NULL and  :new.MEM_CREATED_BY IS NULL))
                 or( (:old.MEM_CREATED_DATE <> :new.MEM_CREATED_DATE) or (:old.MEM_CREATED_DATE IS NULL and  :new.MEM_CREATED_DATE IS NOT NULL)  or (:old.MEM_CREATED_DATE IS NOT NULL and  :new.MEM_CREATED_DATE IS NULL))
                 or( (:old.MEM_CLIENT_ID <> :new.MEM_CLIENT_ID) or (:old.MEM_CLIENT_ID IS NULL and  :new.MEM_CLIENT_ID IS NOT NULL)  or (:old.MEM_CLIENT_ID IS NOT NULL and  :new.MEM_CLIENT_ID IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_MEMBER(MEM_ID
                             ,MEM_SIN
                             ,MEM_FIRST_NAME
                             ,MEM_MIDDLE_NAME
                             ,MEM_LAST_NAME
                             ,MEM_GENDER
                             ,MEM_DOB
                             ,MEM_ADDRESS1
                             ,MEM_ADDRESS2
                             ,MEM_CITY
                             ,MEM_PROV
                             ,MEM_COUNTRY
                             ,MEM_POSTAL_CODE
                             ,MEM_EMAIL
                             ,MEM_HOME_PHONE
                             ,MEM_WORK_PHONE
                             ,MEM_CELL_PHONE
                             ,MEM_FAX
                             ,MEM_LANG_PREF
                             ,MEM_LAST_MODIFIED_BY
                             ,MEM_LAST_MODIFIED_DATE
                             ,MEM_PLAN
                             ,MEM_FILE_NAME
                             ,MEM_MIME_TYPE
                             ,MEM_DOD
                             ,MEM_TITLE
                             ,MEM_CREATED_BY
                             ,MEM_CREATED_DATE
                             ,MEM_CLIENT_ID
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.MEM_ID
                             ,:new.MEM_SIN
                             ,:new.MEM_FIRST_NAME
                             ,:new.MEM_MIDDLE_NAME
                             ,:new.MEM_LAST_NAME
                             ,:new.MEM_GENDER
                             ,:new.MEM_DOB
                             ,:new.MEM_ADDRESS1
                             ,:new.MEM_ADDRESS2
                             ,:new.MEM_CITY
                             ,:new.MEM_PROV
                             ,:new.MEM_COUNTRY
                             ,:new.MEM_POSTAL_CODE
                             ,:new.MEM_EMAIL
                             ,:new.MEM_HOME_PHONE
                             ,:new.MEM_WORK_PHONE
                             ,:new.MEM_CELL_PHONE
                             ,:new.MEM_FAX
                             ,:new.MEM_LANG_PREF
                             ,:new.MEM_LAST_MODIFIED_BY
                             ,:new.MEM_LAST_MODIFIED_DATE
                             ,:new.MEM_PLAN
                             ,:new.MEM_FILE_NAME
                             ,:new.MEM_MIME_TYPE
                             ,:new.MEM_DOD
                             ,:new.MEM_TITLE
                             ,:new.MEM_CREATED_BY
                             ,:new.MEM_CREATED_DATE
                             ,:new.MEM_CLIENT_ID
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_MEMBER(MEM_ID
                             ,MEM_SIN
                             ,MEM_FIRST_NAME
                             ,MEM_MIDDLE_NAME
                             ,MEM_LAST_NAME
                             ,MEM_GENDER
                             ,MEM_DOB
                             ,MEM_ADDRESS1
                             ,MEM_ADDRESS2
                             ,MEM_CITY
                             ,MEM_PROV
                             ,MEM_COUNTRY
                             ,MEM_POSTAL_CODE
                             ,MEM_EMAIL
                             ,MEM_HOME_PHONE
                             ,MEM_WORK_PHONE
                             ,MEM_CELL_PHONE
                             ,MEM_FAX
                             ,MEM_LANG_PREF
                             ,MEM_LAST_MODIFIED_BY
                             ,MEM_LAST_MODIFIED_DATE
                             ,MEM_PLAN
                             ,MEM_FILE_NAME
                             ,MEM_MIME_TYPE
                             ,MEM_DOD
                             ,MEM_TITLE
                             ,MEM_CREATED_BY
                             ,MEM_CREATED_DATE
                             ,MEM_CLIENT_ID
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.MEM_ID
                             ,:old.MEM_SIN
                             ,:old.MEM_FIRST_NAME
                             ,:old.MEM_MIDDLE_NAME
                             ,:old.MEM_LAST_NAME
                             ,:old.MEM_GENDER
                             ,:old.MEM_DOB
                             ,:old.MEM_ADDRESS1
                             ,:old.MEM_ADDRESS2
                             ,:old.MEM_CITY
                             ,:old.MEM_PROV
                             ,:old.MEM_COUNTRY
                             ,:old.MEM_POSTAL_CODE
                             ,:old.MEM_EMAIL
                             ,:old.MEM_HOME_PHONE
                             ,:old.MEM_WORK_PHONE
                             ,:old.MEM_CELL_PHONE
                             ,:old.MEM_FAX
                             ,:old.MEM_LANG_PREF
                             ,:old.MEM_LAST_MODIFIED_BY
                             ,:old.MEM_LAST_MODIFIED_DATE
                             ,:old.MEM_PLAN
                             ,:old.MEM_FILE_NAME
                             ,:old.MEM_MIME_TYPE
                             ,:old.MEM_DOD
                             ,:old.MEM_TITLE
                             ,:old.MEM_CREATED_BY
                             ,:old.MEM_CREATED_DATE
                             ,:old.MEM_CLIENT_ID
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


