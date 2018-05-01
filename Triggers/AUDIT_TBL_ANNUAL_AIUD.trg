--
-- AUDIT_TBL_ANNUAL_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_ANNUAL_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_ANNUAL FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_ANNUAL(ANN_ID
                             ,ANN_PLAN
                             ,ANN_YEAR
                             ,ANN_STATUS
                             ,ANN_COMP
                             ,ANN_EE_CONTS
                             ,ANN_ER_CONTS
                             ,ANN_EARNINGS
                             ,ANN_HRS
                             ,ANN_CRED_SERV
                             ,ANN_PA
                             ,ANN_PEN_VALUE
                             ,ANN_LRD
                             ,ANN_CLIENT
                             ,ANN_VOL_UNITS
                             ,EE_INT
                             ,ER_INT
                             ,VOL_INT
                             ,ANN_ACCOUNT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.ANN_ID
                             ,:new.ANN_PLAN
                             ,:new.ANN_YEAR
                             ,:new.ANN_STATUS
                             ,:new.ANN_COMP
                             ,:new.ANN_EE_CONTS
                             ,:new.ANN_ER_CONTS
                             ,:new.ANN_EARNINGS
                             ,:new.ANN_HRS
                             ,:new.ANN_CRED_SERV
                             ,:new.ANN_PA
                             ,:new.ANN_PEN_VALUE
                             ,:new.ANN_LRD
                             ,:new.ANN_CLIENT
                             ,:new.ANN_VOL_UNITS
                             ,:new.EE_INT
                             ,:new.ER_INT
                             ,:new.VOL_INT
                             ,:new.ANN_ACCOUNT
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.ANN_ID <> :new.ANN_ID) or (:old.ANN_ID IS NULL and  :new.ANN_ID IS NOT NULL)  or (:old.ANN_ID IS NOT NULL and  :new.ANN_ID IS NULL))
                 or( (:old.ANN_PLAN <> :new.ANN_PLAN) or (:old.ANN_PLAN IS NULL and  :new.ANN_PLAN IS NOT NULL)  or (:old.ANN_PLAN IS NOT NULL and  :new.ANN_PLAN IS NULL))
                 or( (:old.ANN_YEAR <> :new.ANN_YEAR) or (:old.ANN_YEAR IS NULL and  :new.ANN_YEAR IS NOT NULL)  or (:old.ANN_YEAR IS NOT NULL and  :new.ANN_YEAR IS NULL))
                 or( (:old.ANN_STATUS <> :new.ANN_STATUS) or (:old.ANN_STATUS IS NULL and  :new.ANN_STATUS IS NOT NULL)  or (:old.ANN_STATUS IS NOT NULL and  :new.ANN_STATUS IS NULL))
                 or( (:old.ANN_COMP <> :new.ANN_COMP) or (:old.ANN_COMP IS NULL and  :new.ANN_COMP IS NOT NULL)  or (:old.ANN_COMP IS NOT NULL and  :new.ANN_COMP IS NULL))
                 or( (:old.ANN_EE_CONTS <> :new.ANN_EE_CONTS) or (:old.ANN_EE_CONTS IS NULL and  :new.ANN_EE_CONTS IS NOT NULL)  or (:old.ANN_EE_CONTS IS NOT NULL and  :new.ANN_EE_CONTS IS NULL))
                 or( (:old.ANN_ER_CONTS <> :new.ANN_ER_CONTS) or (:old.ANN_ER_CONTS IS NULL and  :new.ANN_ER_CONTS IS NOT NULL)  or (:old.ANN_ER_CONTS IS NOT NULL and  :new.ANN_ER_CONTS IS NULL))
                 or( (:old.ANN_EARNINGS <> :new.ANN_EARNINGS) or (:old.ANN_EARNINGS IS NULL and  :new.ANN_EARNINGS IS NOT NULL)  or (:old.ANN_EARNINGS IS NOT NULL and  :new.ANN_EARNINGS IS NULL))
                 or( (:old.ANN_HRS <> :new.ANN_HRS) or (:old.ANN_HRS IS NULL and  :new.ANN_HRS IS NOT NULL)  or (:old.ANN_HRS IS NOT NULL and  :new.ANN_HRS IS NULL))
                 or( (:old.ANN_CRED_SERV <> :new.ANN_CRED_SERV) or (:old.ANN_CRED_SERV IS NULL and  :new.ANN_CRED_SERV IS NOT NULL)  or (:old.ANN_CRED_SERV IS NOT NULL and  :new.ANN_CRED_SERV IS NULL))
                 or( (:old.ANN_PA <> :new.ANN_PA) or (:old.ANN_PA IS NULL and  :new.ANN_PA IS NOT NULL)  or (:old.ANN_PA IS NOT NULL and  :new.ANN_PA IS NULL))
                 or( (:old.ANN_PEN_VALUE <> :new.ANN_PEN_VALUE) or (:old.ANN_PEN_VALUE IS NULL and  :new.ANN_PEN_VALUE IS NOT NULL)  or (:old.ANN_PEN_VALUE IS NOT NULL and  :new.ANN_PEN_VALUE IS NULL))
                 or( (:old.ANN_LRD <> :new.ANN_LRD) or (:old.ANN_LRD IS NULL and  :new.ANN_LRD IS NOT NULL)  or (:old.ANN_LRD IS NOT NULL and  :new.ANN_LRD IS NULL))
                 or( (:old.ANN_CLIENT <> :new.ANN_CLIENT) or (:old.ANN_CLIENT IS NULL and  :new.ANN_CLIENT IS NOT NULL)  or (:old.ANN_CLIENT IS NOT NULL and  :new.ANN_CLIENT IS NULL))
                 or( (:old.ANN_VOL_UNITS <> :new.ANN_VOL_UNITS) or (:old.ANN_VOL_UNITS IS NULL and  :new.ANN_VOL_UNITS IS NOT NULL)  or (:old.ANN_VOL_UNITS IS NOT NULL and  :new.ANN_VOL_UNITS IS NULL))
                 or( (:old.EE_INT <> :new.EE_INT) or (:old.EE_INT IS NULL and  :new.EE_INT IS NOT NULL)  or (:old.EE_INT IS NOT NULL and  :new.EE_INT IS NULL))
                 or( (:old.ER_INT <> :new.ER_INT) or (:old.ER_INT IS NULL and  :new.ER_INT IS NOT NULL)  or (:old.ER_INT IS NOT NULL and  :new.ER_INT IS NULL))
                 or( (:old.VOL_INT <> :new.VOL_INT) or (:old.VOL_INT IS NULL and  :new.VOL_INT IS NOT NULL)  or (:old.VOL_INT IS NOT NULL and  :new.VOL_INT IS NULL))
                 or( (:old.ANN_ACCOUNT <> :new.ANN_ACCOUNT) or (:old.ANN_ACCOUNT IS NULL and  :new.ANN_ACCOUNT IS NOT NULL)  or (:old.ANN_ACCOUNT IS NOT NULL and  :new.ANN_ACCOUNT IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_ANNUAL(ANN_ID
                             ,ANN_PLAN
                             ,ANN_YEAR
                             ,ANN_STATUS
                             ,ANN_COMP
                             ,ANN_EE_CONTS
                             ,ANN_ER_CONTS
                             ,ANN_EARNINGS
                             ,ANN_HRS
                             ,ANN_CRED_SERV
                             ,ANN_PA
                             ,ANN_PEN_VALUE
                             ,ANN_LRD
                             ,ANN_CLIENT
                             ,ANN_VOL_UNITS
                             ,EE_INT
                             ,ER_INT
                             ,VOL_INT
                             ,ANN_ACCOUNT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.ANN_ID
                             ,:new.ANN_PLAN
                             ,:new.ANN_YEAR
                             ,:new.ANN_STATUS
                             ,:new.ANN_COMP
                             ,:new.ANN_EE_CONTS
                             ,:new.ANN_ER_CONTS
                             ,:new.ANN_EARNINGS
                             ,:new.ANN_HRS
                             ,:new.ANN_CRED_SERV
                             ,:new.ANN_PA
                             ,:new.ANN_PEN_VALUE
                             ,:new.ANN_LRD
                             ,:new.ANN_CLIENT
                             ,:new.ANN_VOL_UNITS
                             ,:new.EE_INT
                             ,:new.ER_INT
                             ,:new.VOL_INT
                             ,:new.ANN_ACCOUNT
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_ANNUAL(ANN_ID
                             ,ANN_PLAN
                             ,ANN_YEAR
                             ,ANN_STATUS
                             ,ANN_COMP
                             ,ANN_EE_CONTS
                             ,ANN_ER_CONTS
                             ,ANN_EARNINGS
                             ,ANN_HRS
                             ,ANN_CRED_SERV
                             ,ANN_PA
                             ,ANN_PEN_VALUE
                             ,ANN_LRD
                             ,ANN_CLIENT
                             ,ANN_VOL_UNITS
                             ,EE_INT
                             ,ER_INT
                             ,VOL_INT
                             ,ANN_ACCOUNT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.ANN_ID
                             ,:old.ANN_PLAN
                             ,:old.ANN_YEAR
                             ,:old.ANN_STATUS
                             ,:old.ANN_COMP
                             ,:old.ANN_EE_CONTS
                             ,:old.ANN_ER_CONTS
                             ,:old.ANN_EARNINGS
                             ,:old.ANN_HRS
                             ,:old.ANN_CRED_SERV
                             ,:old.ANN_PA
                             ,:old.ANN_PEN_VALUE
                             ,:old.ANN_LRD
                             ,:old.ANN_CLIENT
                             ,:old.ANN_VOL_UNITS
                             ,:old.EE_INT
                             ,:old.ER_INT
                             ,:old.VOL_INT
                             ,:old.ANN_ACCOUNT
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


