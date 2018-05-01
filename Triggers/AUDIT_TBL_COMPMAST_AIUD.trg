--
-- AUDIT_TBL_COMPMAST_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_COMPMAST_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_COMPMAST FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_COMPMAST(CO_NUMBER
                             ,CO_DIV
                             ,CO_NAME
                             ,CO_PLAN
                             ,CO_LAST_MODIFIED_BY
                             ,CO_LAST_MODIFIED_DATE
                             ,CO_FILE_NAME
                             ,CO_MIME_TYPE
                             ,CO_CLIENT
                             ,CO_TYPE
                             ,CO_CREATED_DATE
                             ,CO_CREATED_BY
                             ,CO_EDITED_DATE
                             ,CO_EDITED_BY
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.CO_NUMBER
                             ,:new.CO_DIV
                             ,:new.CO_NAME
                             ,:new.CO_PLAN
                             ,:new.CO_LAST_MODIFIED_BY
                             ,:new.CO_LAST_MODIFIED_DATE
                             ,:new.CO_FILE_NAME
                             ,:new.CO_MIME_TYPE
                             ,:new.CO_CLIENT
                             ,:new.CO_TYPE
                             ,:new.CO_CREATED_DATE
                             ,:new.CO_CREATED_BY
                             ,:new.CO_EDITED_DATE
                             ,:new.CO_EDITED_BY
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.CO_NUMBER <> :new.CO_NUMBER) or (:old.CO_NUMBER IS NULL and  :new.CO_NUMBER IS NOT NULL)  or (:old.CO_NUMBER IS NOT NULL and  :new.CO_NUMBER IS NULL))
                 or( (:old.CO_DIV <> :new.CO_DIV) or (:old.CO_DIV IS NULL and  :new.CO_DIV IS NOT NULL)  or (:old.CO_DIV IS NOT NULL and  :new.CO_DIV IS NULL))
                 or( (:old.CO_NAME <> :new.CO_NAME) or (:old.CO_NAME IS NULL and  :new.CO_NAME IS NOT NULL)  or (:old.CO_NAME IS NOT NULL and  :new.CO_NAME IS NULL))
                 or( (:old.CO_PLAN <> :new.CO_PLAN) or (:old.CO_PLAN IS NULL and  :new.CO_PLAN IS NOT NULL)  or (:old.CO_PLAN IS NOT NULL and  :new.CO_PLAN IS NULL))
                 or( (:old.CO_LAST_MODIFIED_BY <> :new.CO_LAST_MODIFIED_BY) or (:old.CO_LAST_MODIFIED_BY IS NULL and  :new.CO_LAST_MODIFIED_BY IS NOT NULL)  or (:old.CO_LAST_MODIFIED_BY IS NOT NULL and  :new.CO_LAST_MODIFIED_BY IS NULL))
                 or( (:old.CO_LAST_MODIFIED_DATE <> :new.CO_LAST_MODIFIED_DATE) or (:old.CO_LAST_MODIFIED_DATE IS NULL and  :new.CO_LAST_MODIFIED_DATE IS NOT NULL)  or (:old.CO_LAST_MODIFIED_DATE IS NOT NULL and  :new.CO_LAST_MODIFIED_DATE IS NULL))
                 or( (:old.CO_FILE_NAME <> :new.CO_FILE_NAME) or (:old.CO_FILE_NAME IS NULL and  :new.CO_FILE_NAME IS NOT NULL)  or (:old.CO_FILE_NAME IS NOT NULL and  :new.CO_FILE_NAME IS NULL))
                 or( (:old.CO_MIME_TYPE <> :new.CO_MIME_TYPE) or (:old.CO_MIME_TYPE IS NULL and  :new.CO_MIME_TYPE IS NOT NULL)  or (:old.CO_MIME_TYPE IS NOT NULL and  :new.CO_MIME_TYPE IS NULL))
                 or( (:old.CO_CLIENT <> :new.CO_CLIENT) or (:old.CO_CLIENT IS NULL and  :new.CO_CLIENT IS NOT NULL)  or (:old.CO_CLIENT IS NOT NULL and  :new.CO_CLIENT IS NULL))
                 or( (:old.CO_TYPE <> :new.CO_TYPE) or (:old.CO_TYPE IS NULL and  :new.CO_TYPE IS NOT NULL)  or (:old.CO_TYPE IS NOT NULL and  :new.CO_TYPE IS NULL))
                 or( (:old.CO_CREATED_DATE <> :new.CO_CREATED_DATE) or (:old.CO_CREATED_DATE IS NULL and  :new.CO_CREATED_DATE IS NOT NULL)  or (:old.CO_CREATED_DATE IS NOT NULL and  :new.CO_CREATED_DATE IS NULL))
                 or( (:old.CO_CREATED_BY <> :new.CO_CREATED_BY) or (:old.CO_CREATED_BY IS NULL and  :new.CO_CREATED_BY IS NOT NULL)  or (:old.CO_CREATED_BY IS NOT NULL and  :new.CO_CREATED_BY IS NULL))
                 or( (:old.CO_EDITED_DATE <> :new.CO_EDITED_DATE) or (:old.CO_EDITED_DATE IS NULL and  :new.CO_EDITED_DATE IS NOT NULL)  or (:old.CO_EDITED_DATE IS NOT NULL and  :new.CO_EDITED_DATE IS NULL))
                 or( (:old.CO_EDITED_BY <> :new.CO_EDITED_BY) or (:old.CO_EDITED_BY IS NULL and  :new.CO_EDITED_BY IS NOT NULL)  or (:old.CO_EDITED_BY IS NOT NULL and  :new.CO_EDITED_BY IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_COMPMAST(CO_NUMBER
                             ,CO_DIV
                             ,CO_NAME
                             ,CO_PLAN
                             ,CO_LAST_MODIFIED_BY
                             ,CO_LAST_MODIFIED_DATE
                             ,CO_FILE_NAME
                             ,CO_MIME_TYPE
                             ,CO_CLIENT
                             ,CO_TYPE
                             ,CO_CREATED_DATE
                             ,CO_CREATED_BY
                             ,CO_EDITED_DATE
                             ,CO_EDITED_BY
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.CO_NUMBER
                             ,:new.CO_DIV
                             ,:new.CO_NAME
                             ,:new.CO_PLAN
                             ,:new.CO_LAST_MODIFIED_BY
                             ,:new.CO_LAST_MODIFIED_DATE
                             ,:new.CO_FILE_NAME
                             ,:new.CO_MIME_TYPE
                             ,:new.CO_CLIENT
                             ,:new.CO_TYPE
                             ,:new.CO_CREATED_DATE
                             ,:new.CO_CREATED_BY
                             ,:new.CO_EDITED_DATE
                             ,:new.CO_EDITED_BY
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_COMPMAST(CO_NUMBER
                             ,CO_DIV
                             ,CO_NAME
                             ,CO_PLAN
                             ,CO_LAST_MODIFIED_BY
                             ,CO_LAST_MODIFIED_DATE
                             ,CO_FILE_NAME
                             ,CO_MIME_TYPE
                             ,CO_CLIENT
                             ,CO_TYPE
                             ,CO_CREATED_DATE
                             ,CO_CREATED_BY
                             ,CO_EDITED_DATE
                             ,CO_EDITED_BY
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.CO_NUMBER
                             ,:old.CO_DIV
                             ,:old.CO_NAME
                             ,:old.CO_PLAN
                             ,:old.CO_LAST_MODIFIED_BY
                             ,:old.CO_LAST_MODIFIED_DATE
                             ,:old.CO_FILE_NAME
                             ,:old.CO_MIME_TYPE
                             ,:old.CO_CLIENT
                             ,:old.CO_TYPE
                             ,:old.CO_CREATED_DATE
                             ,:old.CO_CREATED_BY
                             ,:old.CO_EDITED_DATE
                             ,:old.CO_EDITED_BY
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


