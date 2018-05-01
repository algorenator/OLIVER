--
-- AUDIT_TBL_MEM_UNITS_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_MEM_UNITS_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_MEM_UNITS FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_MEM_UNITS(MPU_ID
                             ,MPU_PLAN
                             ,MPU_UNITS
                             ,MPU_FUND
                             ,MPU_RATE
                             ,MPU_AMT
                             ,MPU_FROM
                             ,MPU_TO
                             ,MPU_PERIOD
                             ,MPU_ENTERED_DATE
                             ,MPU_EMPLOYER
                             ,MPU_USER
                             ,MU_BATCH
                             ,MU_DESC
                             ,MU_CLIENT
                             ,TRANS_TYPE
                             ,UNITS_TYPE
                             ,MU_EE_UNITS
                             ,MU_ER_UNITS
                             ,MU_VOL_UNITS
                             ,MU_RECD_DATE
                             ,MU_EE_ACCOUNT
                             ,MU_ER_ACCOUNT
                             ,MU_VOL_ACCOUNT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.MPU_ID
                             ,:new.MPU_PLAN
                             ,:new.MPU_UNITS
                             ,:new.MPU_FUND
                             ,:new.MPU_RATE
                             ,:new.MPU_AMT
                             ,:new.MPU_FROM
                             ,:new.MPU_TO
                             ,:new.MPU_PERIOD
                             ,:new.MPU_ENTERED_DATE
                             ,:new.MPU_EMPLOYER
                             ,:new.MPU_USER
                             ,:new.MU_BATCH
                             ,:new.MU_DESC
                             ,:new.MU_CLIENT
                             ,:new.TRANS_TYPE
                             ,:new.UNITS_TYPE
                             ,:new.MU_EE_UNITS
                             ,:new.MU_ER_UNITS
                             ,:new.MU_VOL_UNITS
                             ,:new.MU_RECD_DATE
                             ,:new.MU_EE_ACCOUNT
                             ,:new.MU_ER_ACCOUNT
                             ,:new.MU_VOL_ACCOUNT
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.MPU_ID <> :new.MPU_ID) or (:old.MPU_ID IS NULL and  :new.MPU_ID IS NOT NULL)  or (:old.MPU_ID IS NOT NULL and  :new.MPU_ID IS NULL))
                 or( (:old.MPU_PLAN <> :new.MPU_PLAN) or (:old.MPU_PLAN IS NULL and  :new.MPU_PLAN IS NOT NULL)  or (:old.MPU_PLAN IS NOT NULL and  :new.MPU_PLAN IS NULL))
                 or( (:old.MPU_UNITS <> :new.MPU_UNITS) or (:old.MPU_UNITS IS NULL and  :new.MPU_UNITS IS NOT NULL)  or (:old.MPU_UNITS IS NOT NULL and  :new.MPU_UNITS IS NULL))
                 or( (:old.MPU_FUND <> :new.MPU_FUND) or (:old.MPU_FUND IS NULL and  :new.MPU_FUND IS NOT NULL)  or (:old.MPU_FUND IS NOT NULL and  :new.MPU_FUND IS NULL))
                 or( (:old.MPU_RATE <> :new.MPU_RATE) or (:old.MPU_RATE IS NULL and  :new.MPU_RATE IS NOT NULL)  or (:old.MPU_RATE IS NOT NULL and  :new.MPU_RATE IS NULL))
                 or( (:old.MPU_AMT <> :new.MPU_AMT) or (:old.MPU_AMT IS NULL and  :new.MPU_AMT IS NOT NULL)  or (:old.MPU_AMT IS NOT NULL and  :new.MPU_AMT IS NULL))
                 or( (:old.MPU_FROM <> :new.MPU_FROM) or (:old.MPU_FROM IS NULL and  :new.MPU_FROM IS NOT NULL)  or (:old.MPU_FROM IS NOT NULL and  :new.MPU_FROM IS NULL))
                 or( (:old.MPU_TO <> :new.MPU_TO) or (:old.MPU_TO IS NULL and  :new.MPU_TO IS NOT NULL)  or (:old.MPU_TO IS NOT NULL and  :new.MPU_TO IS NULL))
                 or( (:old.MPU_PERIOD <> :new.MPU_PERIOD) or (:old.MPU_PERIOD IS NULL and  :new.MPU_PERIOD IS NOT NULL)  or (:old.MPU_PERIOD IS NOT NULL and  :new.MPU_PERIOD IS NULL))
                 or( (:old.MPU_ENTERED_DATE <> :new.MPU_ENTERED_DATE) or (:old.MPU_ENTERED_DATE IS NULL and  :new.MPU_ENTERED_DATE IS NOT NULL)  or (:old.MPU_ENTERED_DATE IS NOT NULL and  :new.MPU_ENTERED_DATE IS NULL))
                 or( (:old.MPU_EMPLOYER <> :new.MPU_EMPLOYER) or (:old.MPU_EMPLOYER IS NULL and  :new.MPU_EMPLOYER IS NOT NULL)  or (:old.MPU_EMPLOYER IS NOT NULL and  :new.MPU_EMPLOYER IS NULL))
                 or( (:old.MPU_USER <> :new.MPU_USER) or (:old.MPU_USER IS NULL and  :new.MPU_USER IS NOT NULL)  or (:old.MPU_USER IS NOT NULL and  :new.MPU_USER IS NULL))
                 or( (:old.MU_BATCH <> :new.MU_BATCH) or (:old.MU_BATCH IS NULL and  :new.MU_BATCH IS NOT NULL)  or (:old.MU_BATCH IS NOT NULL and  :new.MU_BATCH IS NULL))
                 or( (:old.MU_DESC <> :new.MU_DESC) or (:old.MU_DESC IS NULL and  :new.MU_DESC IS NOT NULL)  or (:old.MU_DESC IS NOT NULL and  :new.MU_DESC IS NULL))
                 or( (:old.MU_CLIENT <> :new.MU_CLIENT) or (:old.MU_CLIENT IS NULL and  :new.MU_CLIENT IS NOT NULL)  or (:old.MU_CLIENT IS NOT NULL and  :new.MU_CLIENT IS NULL))
                 or( (:old.TRANS_TYPE <> :new.TRANS_TYPE) or (:old.TRANS_TYPE IS NULL and  :new.TRANS_TYPE IS NOT NULL)  or (:old.TRANS_TYPE IS NOT NULL and  :new.TRANS_TYPE IS NULL))
                 or( (:old.UNITS_TYPE <> :new.UNITS_TYPE) or (:old.UNITS_TYPE IS NULL and  :new.UNITS_TYPE IS NOT NULL)  or (:old.UNITS_TYPE IS NOT NULL and  :new.UNITS_TYPE IS NULL))
                 or( (:old.MU_EE_UNITS <> :new.MU_EE_UNITS) or (:old.MU_EE_UNITS IS NULL and  :new.MU_EE_UNITS IS NOT NULL)  or (:old.MU_EE_UNITS IS NOT NULL and  :new.MU_EE_UNITS IS NULL))
                 or( (:old.MU_ER_UNITS <> :new.MU_ER_UNITS) or (:old.MU_ER_UNITS IS NULL and  :new.MU_ER_UNITS IS NOT NULL)  or (:old.MU_ER_UNITS IS NOT NULL and  :new.MU_ER_UNITS IS NULL))
                 or( (:old.MU_VOL_UNITS <> :new.MU_VOL_UNITS) or (:old.MU_VOL_UNITS IS NULL and  :new.MU_VOL_UNITS IS NOT NULL)  or (:old.MU_VOL_UNITS IS NOT NULL and  :new.MU_VOL_UNITS IS NULL))
                 or( (:old.MU_RECD_DATE <> :new.MU_RECD_DATE) or (:old.MU_RECD_DATE IS NULL and  :new.MU_RECD_DATE IS NOT NULL)  or (:old.MU_RECD_DATE IS NOT NULL and  :new.MU_RECD_DATE IS NULL))
                 or( (:old.MU_EE_ACCOUNT <> :new.MU_EE_ACCOUNT) or (:old.MU_EE_ACCOUNT IS NULL and  :new.MU_EE_ACCOUNT IS NOT NULL)  or (:old.MU_EE_ACCOUNT IS NOT NULL and  :new.MU_EE_ACCOUNT IS NULL))
                 or( (:old.MU_ER_ACCOUNT <> :new.MU_ER_ACCOUNT) or (:old.MU_ER_ACCOUNT IS NULL and  :new.MU_ER_ACCOUNT IS NOT NULL)  or (:old.MU_ER_ACCOUNT IS NOT NULL and  :new.MU_ER_ACCOUNT IS NULL))
                 or( (:old.MU_VOL_ACCOUNT <> :new.MU_VOL_ACCOUNT) or (:old.MU_VOL_ACCOUNT IS NULL and  :new.MU_VOL_ACCOUNT IS NOT NULL)  or (:old.MU_VOL_ACCOUNT IS NOT NULL and  :new.MU_VOL_ACCOUNT IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_MEM_UNITS(MPU_ID
                             ,MPU_PLAN
                             ,MPU_UNITS
                             ,MPU_FUND
                             ,MPU_RATE
                             ,MPU_AMT
                             ,MPU_FROM
                             ,MPU_TO
                             ,MPU_PERIOD
                             ,MPU_ENTERED_DATE
                             ,MPU_EMPLOYER
                             ,MPU_USER
                             ,MU_BATCH
                             ,MU_DESC
                             ,MU_CLIENT
                             ,TRANS_TYPE
                             ,UNITS_TYPE
                             ,MU_EE_UNITS
                             ,MU_ER_UNITS
                             ,MU_VOL_UNITS
                             ,MU_RECD_DATE
                             ,MU_EE_ACCOUNT
                             ,MU_ER_ACCOUNT
                             ,MU_VOL_ACCOUNT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.MPU_ID
                             ,:new.MPU_PLAN
                             ,:new.MPU_UNITS
                             ,:new.MPU_FUND
                             ,:new.MPU_RATE
                             ,:new.MPU_AMT
                             ,:new.MPU_FROM
                             ,:new.MPU_TO
                             ,:new.MPU_PERIOD
                             ,:new.MPU_ENTERED_DATE
                             ,:new.MPU_EMPLOYER
                             ,:new.MPU_USER
                             ,:new.MU_BATCH
                             ,:new.MU_DESC
                             ,:new.MU_CLIENT
                             ,:new.TRANS_TYPE
                             ,:new.UNITS_TYPE
                             ,:new.MU_EE_UNITS
                             ,:new.MU_ER_UNITS
                             ,:new.MU_VOL_UNITS
                             ,:new.MU_RECD_DATE
                             ,:new.MU_EE_ACCOUNT
                             ,:new.MU_ER_ACCOUNT
                             ,:new.MU_VOL_ACCOUNT
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_MEM_UNITS(MPU_ID
                             ,MPU_PLAN
                             ,MPU_UNITS
                             ,MPU_FUND
                             ,MPU_RATE
                             ,MPU_AMT
                             ,MPU_FROM
                             ,MPU_TO
                             ,MPU_PERIOD
                             ,MPU_ENTERED_DATE
                             ,MPU_EMPLOYER
                             ,MPU_USER
                             ,MU_BATCH
                             ,MU_DESC
                             ,MU_CLIENT
                             ,TRANS_TYPE
                             ,UNITS_TYPE
                             ,MU_EE_UNITS
                             ,MU_ER_UNITS
                             ,MU_VOL_UNITS
                             ,MU_RECD_DATE
                             ,MU_EE_ACCOUNT
                             ,MU_ER_ACCOUNT
                             ,MU_VOL_ACCOUNT
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.MPU_ID
                             ,:old.MPU_PLAN
                             ,:old.MPU_UNITS
                             ,:old.MPU_FUND
                             ,:old.MPU_RATE
                             ,:old.MPU_AMT
                             ,:old.MPU_FROM
                             ,:old.MPU_TO
                             ,:old.MPU_PERIOD
                             ,:old.MPU_ENTERED_DATE
                             ,:old.MPU_EMPLOYER
                             ,:old.MPU_USER
                             ,:old.MU_BATCH
                             ,:old.MU_DESC
                             ,:old.MU_CLIENT
                             ,:old.TRANS_TYPE
                             ,:old.UNITS_TYPE
                             ,:old.MU_EE_UNITS
                             ,:old.MU_ER_UNITS
                             ,:old.MU_VOL_UNITS
                             ,:old.MU_RECD_DATE
                             ,:old.MU_EE_ACCOUNT
                             ,:old.MU_ER_ACCOUNT
                             ,:old.MU_VOL_ACCOUNT
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


