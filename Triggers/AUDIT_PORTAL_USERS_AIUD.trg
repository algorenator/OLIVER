--
-- AUDIT_PORTAL_USERS_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_PORTAL_USERS_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.PORTAL_USERS FOR EACH ROW
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
      insert into OLIVER.AUDIT_PORTAL_USERS(USER_ID
                             ,EMAIL
                             ,PASSWORD
                             ,USER_FIRST_NAME
                             ,USER_LAST_NAME
                             ,DATE_CREATED
                             ,CLIENT_ID
                             ,MEM_ID
                             ,ISACTIVE
                             ,PLAN_ID
                             ,HW_VERIFY
                             ,PEN_VERIFY
                             ,VERIFICATION_CODE
                             ,ISADMIN
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.USER_ID
                             ,:new.EMAIL
                             ,:new.PASSWORD
                             ,:new.USER_FIRST_NAME
                             ,:new.USER_LAST_NAME
                             ,:new.DATE_CREATED
                             ,:new.CLIENT_ID
                             ,:new.MEM_ID
                             ,:new.ISACTIVE
                             ,:new.PLAN_ID
                             ,:new.HW_VERIFY
                             ,:new.PEN_VERIFY
                             ,:new.VERIFICATION_CODE
                             ,:new.ISADMIN
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.USER_ID <> :new.USER_ID) or (:old.USER_ID IS NULL and  :new.USER_ID IS NOT NULL)  or (:old.USER_ID IS NOT NULL and  :new.USER_ID IS NULL))
                 or( (:old.EMAIL <> :new.EMAIL) or (:old.EMAIL IS NULL and  :new.EMAIL IS NOT NULL)  or (:old.EMAIL IS NOT NULL and  :new.EMAIL IS NULL))
                 or( (:old.PASSWORD <> :new.PASSWORD) or (:old.PASSWORD IS NULL and  :new.PASSWORD IS NOT NULL)  or (:old.PASSWORD IS NOT NULL and  :new.PASSWORD IS NULL))
                 or( (:old.USER_FIRST_NAME <> :new.USER_FIRST_NAME) or (:old.USER_FIRST_NAME IS NULL and  :new.USER_FIRST_NAME IS NOT NULL)  or (:old.USER_FIRST_NAME IS NOT NULL and  :new.USER_FIRST_NAME IS NULL))
                 or( (:old.USER_LAST_NAME <> :new.USER_LAST_NAME) or (:old.USER_LAST_NAME IS NULL and  :new.USER_LAST_NAME IS NOT NULL)  or (:old.USER_LAST_NAME IS NOT NULL and  :new.USER_LAST_NAME IS NULL))
                 or( (:old.DATE_CREATED <> :new.DATE_CREATED) or (:old.DATE_CREATED IS NULL and  :new.DATE_CREATED IS NOT NULL)  or (:old.DATE_CREATED IS NOT NULL and  :new.DATE_CREATED IS NULL))
                 or( (:old.CLIENT_ID <> :new.CLIENT_ID) or (:old.CLIENT_ID IS NULL and  :new.CLIENT_ID IS NOT NULL)  or (:old.CLIENT_ID IS NOT NULL and  :new.CLIENT_ID IS NULL))
                 or( (:old.MEM_ID <> :new.MEM_ID) or (:old.MEM_ID IS NULL and  :new.MEM_ID IS NOT NULL)  or (:old.MEM_ID IS NOT NULL and  :new.MEM_ID IS NULL))
                 or( (:old.ISACTIVE <> :new.ISACTIVE) or (:old.ISACTIVE IS NULL and  :new.ISACTIVE IS NOT NULL)  or (:old.ISACTIVE IS NOT NULL and  :new.ISACTIVE IS NULL))
                 or( (:old.PLAN_ID <> :new.PLAN_ID) or (:old.PLAN_ID IS NULL and  :new.PLAN_ID IS NOT NULL)  or (:old.PLAN_ID IS NOT NULL and  :new.PLAN_ID IS NULL))
                 or( (:old.HW_VERIFY <> :new.HW_VERIFY) or (:old.HW_VERIFY IS NULL and  :new.HW_VERIFY IS NOT NULL)  or (:old.HW_VERIFY IS NOT NULL and  :new.HW_VERIFY IS NULL))
                 or( (:old.PEN_VERIFY <> :new.PEN_VERIFY) or (:old.PEN_VERIFY IS NULL and  :new.PEN_VERIFY IS NOT NULL)  or (:old.PEN_VERIFY IS NOT NULL and  :new.PEN_VERIFY IS NULL))
                 or( (:old.VERIFICATION_CODE <> :new.VERIFICATION_CODE) or (:old.VERIFICATION_CODE IS NULL and  :new.VERIFICATION_CODE IS NOT NULL)  or (:old.VERIFICATION_CODE IS NOT NULL and  :new.VERIFICATION_CODE IS NULL))
                 or( (:old.ISADMIN <> :new.ISADMIN) or (:old.ISADMIN IS NULL and  :new.ISADMIN IS NOT NULL)  or (:old.ISADMIN IS NOT NULL and  :new.ISADMIN IS NULL))
                 then 
      insert into OLIVER.AUDIT_PORTAL_USERS(USER_ID
                             ,EMAIL
                             ,PASSWORD
                             ,USER_FIRST_NAME
                             ,USER_LAST_NAME
                             ,DATE_CREATED
                             ,CLIENT_ID
                             ,MEM_ID
                             ,ISACTIVE
                             ,PLAN_ID
                             ,HW_VERIFY
                             ,PEN_VERIFY
                             ,VERIFICATION_CODE
                             ,ISADMIN
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.USER_ID
                             ,:new.EMAIL
                             ,:new.PASSWORD
                             ,:new.USER_FIRST_NAME
                             ,:new.USER_LAST_NAME
                             ,:new.DATE_CREATED
                             ,:new.CLIENT_ID
                             ,:new.MEM_ID
                             ,:new.ISACTIVE
                             ,:new.PLAN_ID
                             ,:new.HW_VERIFY
                             ,:new.PEN_VERIFY
                             ,:new.VERIFICATION_CODE
                             ,:new.ISADMIN
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_PORTAL_USERS(USER_ID
                             ,EMAIL
                             ,PASSWORD
                             ,USER_FIRST_NAME
                             ,USER_LAST_NAME
                             ,DATE_CREATED
                             ,CLIENT_ID
                             ,MEM_ID
                             ,ISACTIVE
                             ,PLAN_ID
                             ,HW_VERIFY
                             ,PEN_VERIFY
                             ,VERIFICATION_CODE
                             ,ISADMIN
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.USER_ID
                             ,:old.EMAIL
                             ,:old.PASSWORD
                             ,:old.USER_FIRST_NAME
                             ,:old.USER_LAST_NAME
                             ,:old.DATE_CREATED
                             ,:old.CLIENT_ID
                             ,:old.MEM_ID
                             ,:old.ISACTIVE
                             ,:old.PLAN_ID
                             ,:old.HW_VERIFY
                             ,:old.PEN_VERIFY
                             ,:old.VERIFICATION_CODE
                             ,:old.ISADMIN
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


