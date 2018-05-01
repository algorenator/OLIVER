--
-- AUDIT_TBL_HW_COMMENTS_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_HW_COMMENTS_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_HW_COMMENTS FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_HW_COMMENTS(THC_ID
                             ,THC_DEC
                             ,THC_PLAN
                             ,THC_BENEFIT
                             ,THC_CLAIM
                             ,THC_ISACTIVE
                             ,THC_CLIENT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.THC_ID
                             ,:new.THC_DEC
                             ,:new.THC_PLAN
                             ,:new.THC_BENEFIT
                             ,:new.THC_CLAIM
                             ,:new.THC_ISACTIVE
                             ,:new.THC_CLIENT
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.THC_ID <> :new.THC_ID) or (:old.THC_ID IS NULL and  :new.THC_ID IS NOT NULL)  or (:old.THC_ID IS NOT NULL and  :new.THC_ID IS NULL))
                 or( (:old.THC_DEC <> :new.THC_DEC) or (:old.THC_DEC IS NULL and  :new.THC_DEC IS NOT NULL)  or (:old.THC_DEC IS NOT NULL and  :new.THC_DEC IS NULL))
                 or( (:old.THC_PLAN <> :new.THC_PLAN) or (:old.THC_PLAN IS NULL and  :new.THC_PLAN IS NOT NULL)  or (:old.THC_PLAN IS NOT NULL and  :new.THC_PLAN IS NULL))
                 or( (:old.THC_BENEFIT <> :new.THC_BENEFIT) or (:old.THC_BENEFIT IS NULL and  :new.THC_BENEFIT IS NOT NULL)  or (:old.THC_BENEFIT IS NOT NULL and  :new.THC_BENEFIT IS NULL))
                 or( (:old.THC_CLAIM <> :new.THC_CLAIM) or (:old.THC_CLAIM IS NULL and  :new.THC_CLAIM IS NOT NULL)  or (:old.THC_CLAIM IS NOT NULL and  :new.THC_CLAIM IS NULL))
                 or( (:old.THC_ISACTIVE <> :new.THC_ISACTIVE) or (:old.THC_ISACTIVE IS NULL and  :new.THC_ISACTIVE IS NOT NULL)  or (:old.THC_ISACTIVE IS NOT NULL and  :new.THC_ISACTIVE IS NULL))
                 or( (:old.THC_CLIENT <> :new.THC_CLIENT) or (:old.THC_CLIENT IS NULL and  :new.THC_CLIENT IS NOT NULL)  or (:old.THC_CLIENT IS NOT NULL and  :new.THC_CLIENT IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_HW_COMMENTS(THC_ID
                             ,THC_DEC
                             ,THC_PLAN
                             ,THC_BENEFIT
                             ,THC_CLAIM
                             ,THC_ISACTIVE
                             ,THC_CLIENT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.THC_ID
                             ,:new.THC_DEC
                             ,:new.THC_PLAN
                             ,:new.THC_BENEFIT
                             ,:new.THC_CLAIM
                             ,:new.THC_ISACTIVE
                             ,:new.THC_CLIENT
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_HW_COMMENTS(THC_ID
                             ,THC_DEC
                             ,THC_PLAN
                             ,THC_BENEFIT
                             ,THC_CLAIM
                             ,THC_ISACTIVE
                             ,THC_CLIENT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.THC_ID
                             ,:old.THC_DEC
                             ,:old.THC_PLAN
                             ,:old.THC_BENEFIT
                             ,:old.THC_CLAIM
                             ,:old.THC_ISACTIVE
                             ,:old.THC_CLIENT
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


