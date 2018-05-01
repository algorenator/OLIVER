--
-- AUDIT_TBL_MEM_BANK_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_MEM_BANK_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_MEM_BANK FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_MEM_BANK(TMB_ID
                             ,TMB_PL_ID
                             ,TMB_BANK
                             ,TMB_BRANCH
                             ,TMB_ACCOUNT
                             ,TMB_ACTIVE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.TMB_ID
                             ,:new.TMB_PL_ID
                             ,:new.TMB_BANK
                             ,:new.TMB_BRANCH
                             ,:new.TMB_ACCOUNT
                             ,:new.TMB_ACTIVE
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.TMB_ID <> :new.TMB_ID) or (:old.TMB_ID IS NULL and  :new.TMB_ID IS NOT NULL)  or (:old.TMB_ID IS NOT NULL and  :new.TMB_ID IS NULL))
                 or( (:old.TMB_PL_ID <> :new.TMB_PL_ID) or (:old.TMB_PL_ID IS NULL and  :new.TMB_PL_ID IS NOT NULL)  or (:old.TMB_PL_ID IS NOT NULL and  :new.TMB_PL_ID IS NULL))
                 or( (:old.TMB_BANK <> :new.TMB_BANK) or (:old.TMB_BANK IS NULL and  :new.TMB_BANK IS NOT NULL)  or (:old.TMB_BANK IS NOT NULL and  :new.TMB_BANK IS NULL))
                 or( (:old.TMB_BRANCH <> :new.TMB_BRANCH) or (:old.TMB_BRANCH IS NULL and  :new.TMB_BRANCH IS NOT NULL)  or (:old.TMB_BRANCH IS NOT NULL and  :new.TMB_BRANCH IS NULL))
                 or( (:old.TMB_ACCOUNT <> :new.TMB_ACCOUNT) or (:old.TMB_ACCOUNT IS NULL and  :new.TMB_ACCOUNT IS NOT NULL)  or (:old.TMB_ACCOUNT IS NOT NULL and  :new.TMB_ACCOUNT IS NULL))
                 or( (:old.TMB_ACTIVE <> :new.TMB_ACTIVE) or (:old.TMB_ACTIVE IS NULL and  :new.TMB_ACTIVE IS NOT NULL)  or (:old.TMB_ACTIVE IS NOT NULL and  :new.TMB_ACTIVE IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_MEM_BANK(TMB_ID
                             ,TMB_PL_ID
                             ,TMB_BANK
                             ,TMB_BRANCH
                             ,TMB_ACCOUNT
                             ,TMB_ACTIVE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.TMB_ID
                             ,:new.TMB_PL_ID
                             ,:new.TMB_BANK
                             ,:new.TMB_BRANCH
                             ,:new.TMB_ACCOUNT
                             ,:new.TMB_ACTIVE
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_MEM_BANK(TMB_ID
                             ,TMB_PL_ID
                             ,TMB_BANK
                             ,TMB_BRANCH
                             ,TMB_ACCOUNT
                             ,TMB_ACTIVE
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.TMB_ID
                             ,:old.TMB_PL_ID
                             ,:old.TMB_BANK
                             ,:old.TMB_BRANCH
                             ,:old.TMB_ACCOUNT
                             ,:old.TMB_ACTIVE
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


