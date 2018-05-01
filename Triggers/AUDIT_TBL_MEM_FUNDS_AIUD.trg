--
-- AUDIT_TBL_MEM_FUNDS_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_MEM_FUNDS_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_MEM_FUNDS FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_MEM_FUNDS(TMF_ID
                             ,TMF_PLAN
                             ,TMF_UNITS
                             ,TMF_FUND
                             ,TMF_RATE
                             ,TMF_AMT
                             ,TMF_FROM
                             ,TMF_TO
                             ,TMF_PERIOD
                             ,TMF_ENTERED_DATE
                             ,TMF_EMPLOYER
                             ,TMF_USER
                             ,TMF_BATCH
                             ,TMF_DESC
                             ,TMF_CLIENT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.TMF_ID
                             ,:new.TMF_PLAN
                             ,:new.TMF_UNITS
                             ,:new.TMF_FUND
                             ,:new.TMF_RATE
                             ,:new.TMF_AMT
                             ,:new.TMF_FROM
                             ,:new.TMF_TO
                             ,:new.TMF_PERIOD
                             ,:new.TMF_ENTERED_DATE
                             ,:new.TMF_EMPLOYER
                             ,:new.TMF_USER
                             ,:new.TMF_BATCH
                             ,:new.TMF_DESC
                             ,:new.TMF_CLIENT
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.TMF_ID <> :new.TMF_ID) or (:old.TMF_ID IS NULL and  :new.TMF_ID IS NOT NULL)  or (:old.TMF_ID IS NOT NULL and  :new.TMF_ID IS NULL))
                 or( (:old.TMF_PLAN <> :new.TMF_PLAN) or (:old.TMF_PLAN IS NULL and  :new.TMF_PLAN IS NOT NULL)  or (:old.TMF_PLAN IS NOT NULL and  :new.TMF_PLAN IS NULL))
                 or( (:old.TMF_UNITS <> :new.TMF_UNITS) or (:old.TMF_UNITS IS NULL and  :new.TMF_UNITS IS NOT NULL)  or (:old.TMF_UNITS IS NOT NULL and  :new.TMF_UNITS IS NULL))
                 or( (:old.TMF_FUND <> :new.TMF_FUND) or (:old.TMF_FUND IS NULL and  :new.TMF_FUND IS NOT NULL)  or (:old.TMF_FUND IS NOT NULL and  :new.TMF_FUND IS NULL))
                 or( (:old.TMF_RATE <> :new.TMF_RATE) or (:old.TMF_RATE IS NULL and  :new.TMF_RATE IS NOT NULL)  or (:old.TMF_RATE IS NOT NULL and  :new.TMF_RATE IS NULL))
                 or( (:old.TMF_AMT <> :new.TMF_AMT) or (:old.TMF_AMT IS NULL and  :new.TMF_AMT IS NOT NULL)  or (:old.TMF_AMT IS NOT NULL and  :new.TMF_AMT IS NULL))
                 or( (:old.TMF_FROM <> :new.TMF_FROM) or (:old.TMF_FROM IS NULL and  :new.TMF_FROM IS NOT NULL)  or (:old.TMF_FROM IS NOT NULL and  :new.TMF_FROM IS NULL))
                 or( (:old.TMF_TO <> :new.TMF_TO) or (:old.TMF_TO IS NULL and  :new.TMF_TO IS NOT NULL)  or (:old.TMF_TO IS NOT NULL and  :new.TMF_TO IS NULL))
                 or( (:old.TMF_PERIOD <> :new.TMF_PERIOD) or (:old.TMF_PERIOD IS NULL and  :new.TMF_PERIOD IS NOT NULL)  or (:old.TMF_PERIOD IS NOT NULL and  :new.TMF_PERIOD IS NULL))
                 or( (:old.TMF_ENTERED_DATE <> :new.TMF_ENTERED_DATE) or (:old.TMF_ENTERED_DATE IS NULL and  :new.TMF_ENTERED_DATE IS NOT NULL)  or (:old.TMF_ENTERED_DATE IS NOT NULL and  :new.TMF_ENTERED_DATE IS NULL))
                 or( (:old.TMF_EMPLOYER <> :new.TMF_EMPLOYER) or (:old.TMF_EMPLOYER IS NULL and  :new.TMF_EMPLOYER IS NOT NULL)  or (:old.TMF_EMPLOYER IS NOT NULL and  :new.TMF_EMPLOYER IS NULL))
                 or( (:old.TMF_USER <> :new.TMF_USER) or (:old.TMF_USER IS NULL and  :new.TMF_USER IS NOT NULL)  or (:old.TMF_USER IS NOT NULL and  :new.TMF_USER IS NULL))
                 or( (:old.TMF_BATCH <> :new.TMF_BATCH) or (:old.TMF_BATCH IS NULL and  :new.TMF_BATCH IS NOT NULL)  or (:old.TMF_BATCH IS NOT NULL and  :new.TMF_BATCH IS NULL))
                 or( (:old.TMF_DESC <> :new.TMF_DESC) or (:old.TMF_DESC IS NULL and  :new.TMF_DESC IS NOT NULL)  or (:old.TMF_DESC IS NOT NULL and  :new.TMF_DESC IS NULL))
                 or( (:old.TMF_CLIENT <> :new.TMF_CLIENT) or (:old.TMF_CLIENT IS NULL and  :new.TMF_CLIENT IS NOT NULL)  or (:old.TMF_CLIENT IS NOT NULL and  :new.TMF_CLIENT IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_MEM_FUNDS(TMF_ID
                             ,TMF_PLAN
                             ,TMF_UNITS
                             ,TMF_FUND
                             ,TMF_RATE
                             ,TMF_AMT
                             ,TMF_FROM
                             ,TMF_TO
                             ,TMF_PERIOD
                             ,TMF_ENTERED_DATE
                             ,TMF_EMPLOYER
                             ,TMF_USER
                             ,TMF_BATCH
                             ,TMF_DESC
                             ,TMF_CLIENT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.TMF_ID
                             ,:new.TMF_PLAN
                             ,:new.TMF_UNITS
                             ,:new.TMF_FUND
                             ,:new.TMF_RATE
                             ,:new.TMF_AMT
                             ,:new.TMF_FROM
                             ,:new.TMF_TO
                             ,:new.TMF_PERIOD
                             ,:new.TMF_ENTERED_DATE
                             ,:new.TMF_EMPLOYER
                             ,:new.TMF_USER
                             ,:new.TMF_BATCH
                             ,:new.TMF_DESC
                             ,:new.TMF_CLIENT
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_MEM_FUNDS(TMF_ID
                             ,TMF_PLAN
                             ,TMF_UNITS
                             ,TMF_FUND
                             ,TMF_RATE
                             ,TMF_AMT
                             ,TMF_FROM
                             ,TMF_TO
                             ,TMF_PERIOD
                             ,TMF_ENTERED_DATE
                             ,TMF_EMPLOYER
                             ,TMF_USER
                             ,TMF_BATCH
                             ,TMF_DESC
                             ,TMF_CLIENT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.TMF_ID
                             ,:old.TMF_PLAN
                             ,:old.TMF_UNITS
                             ,:old.TMF_FUND
                             ,:old.TMF_RATE
                             ,:old.TMF_AMT
                             ,:old.TMF_FROM
                             ,:old.TMF_TO
                             ,:old.TMF_PERIOD
                             ,:old.TMF_ENTERED_DATE
                             ,:old.TMF_EMPLOYER
                             ,:old.TMF_USER
                             ,:old.TMF_BATCH
                             ,:old.TMF_DESC
                             ,:old.TMF_CLIENT
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


