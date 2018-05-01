--
-- AUDIT_TBL_PLAN_AIUD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUDIT_TBL_PLAN_AIUD AFTER INSERT OR UPDATE OR DELETE ON OLIVER.TBL_PLAN FOR EACH ROW
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
      insert into OLIVER.AUDIT_TBL_PLAN(PL_ID
                             ,PL_ADMINISTRATOR
                             ,PL_CONTACT
                             ,PL_NAME
                             ,PL_ADDRESS1
                             ,PL_ADDRESS2
                             ,PL_CITY
                             ,PL_PROV
                             ,PL_COUNTRY
                             ,PL_PHONE1
                             ,PL_PHONE2
                             ,PL_FAX
                             ,PL_EMAIL
                             ,PL_POST_CODE
                             ,PL_HW_MONTHEND
                             ,PL_EFF_DATE
                             ,PL_JURISDICTION
                             ,PL_TERM_DATE
                             ,PL_CLIENT_ID
                             ,PL_TYPE
                             ,PL_STATUS
                             ,PL_MEMBER_IDENTIFIER
                             ,PL_GST_NUMBER
                             ,PL_PAY_GRACE_PERIOD
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.PL_ID
                             ,:new.PL_ADMINISTRATOR
                             ,:new.PL_CONTACT
                             ,:new.PL_NAME
                             ,:new.PL_ADDRESS1
                             ,:new.PL_ADDRESS2
                             ,:new.PL_CITY
                             ,:new.PL_PROV
                             ,:new.PL_COUNTRY
                             ,:new.PL_PHONE1
                             ,:new.PL_PHONE2
                             ,:new.PL_FAX
                             ,:new.PL_EMAIL
                             ,:new.PL_POST_CODE
                             ,:new.PL_HW_MONTHEND
                             ,:new.PL_EFF_DATE
                             ,:new.PL_JURISDICTION
                             ,:new.PL_TERM_DATE
                             ,:new.PL_CLIENT_ID
                             ,:new.PL_TYPE
                             ,:new.PL_STATUS
                             ,:new.PL_MEMBER_IDENTIFIER
                             ,:new.PL_GST_NUMBER
                             ,:new.PL_PAY_GRACE_PERIOD
                                  ,'I',v_user,SYSDATE);
 elsif updating then 
 v_action:='UPDATE';
   if ( (:old.PL_ID <> :new.PL_ID) or (:old.PL_ID IS NULL and  :new.PL_ID IS NOT NULL)  or (:old.PL_ID IS NOT NULL and  :new.PL_ID IS NULL))
                 or( (:old.PL_ADMINISTRATOR <> :new.PL_ADMINISTRATOR) or (:old.PL_ADMINISTRATOR IS NULL and  :new.PL_ADMINISTRATOR IS NOT NULL)  or (:old.PL_ADMINISTRATOR IS NOT NULL and  :new.PL_ADMINISTRATOR IS NULL))
                 or( (:old.PL_CONTACT <> :new.PL_CONTACT) or (:old.PL_CONTACT IS NULL and  :new.PL_CONTACT IS NOT NULL)  or (:old.PL_CONTACT IS NOT NULL and  :new.PL_CONTACT IS NULL))
                 or( (:old.PL_NAME <> :new.PL_NAME) or (:old.PL_NAME IS NULL and  :new.PL_NAME IS NOT NULL)  or (:old.PL_NAME IS NOT NULL and  :new.PL_NAME IS NULL))
                 or( (:old.PL_ADDRESS1 <> :new.PL_ADDRESS1) or (:old.PL_ADDRESS1 IS NULL and  :new.PL_ADDRESS1 IS NOT NULL)  or (:old.PL_ADDRESS1 IS NOT NULL and  :new.PL_ADDRESS1 IS NULL))
                 or( (:old.PL_ADDRESS2 <> :new.PL_ADDRESS2) or (:old.PL_ADDRESS2 IS NULL and  :new.PL_ADDRESS2 IS NOT NULL)  or (:old.PL_ADDRESS2 IS NOT NULL and  :new.PL_ADDRESS2 IS NULL))
                 or( (:old.PL_CITY <> :new.PL_CITY) or (:old.PL_CITY IS NULL and  :new.PL_CITY IS NOT NULL)  or (:old.PL_CITY IS NOT NULL and  :new.PL_CITY IS NULL))
                 or( (:old.PL_PROV <> :new.PL_PROV) or (:old.PL_PROV IS NULL and  :new.PL_PROV IS NOT NULL)  or (:old.PL_PROV IS NOT NULL and  :new.PL_PROV IS NULL))
                 or( (:old.PL_COUNTRY <> :new.PL_COUNTRY) or (:old.PL_COUNTRY IS NULL and  :new.PL_COUNTRY IS NOT NULL)  or (:old.PL_COUNTRY IS NOT NULL and  :new.PL_COUNTRY IS NULL))
                 or( (:old.PL_PHONE1 <> :new.PL_PHONE1) or (:old.PL_PHONE1 IS NULL and  :new.PL_PHONE1 IS NOT NULL)  or (:old.PL_PHONE1 IS NOT NULL and  :new.PL_PHONE1 IS NULL))
                 or( (:old.PL_PHONE2 <> :new.PL_PHONE2) or (:old.PL_PHONE2 IS NULL and  :new.PL_PHONE2 IS NOT NULL)  or (:old.PL_PHONE2 IS NOT NULL and  :new.PL_PHONE2 IS NULL))
                 or( (:old.PL_FAX <> :new.PL_FAX) or (:old.PL_FAX IS NULL and  :new.PL_FAX IS NOT NULL)  or (:old.PL_FAX IS NOT NULL and  :new.PL_FAX IS NULL))
                 or( (:old.PL_EMAIL <> :new.PL_EMAIL) or (:old.PL_EMAIL IS NULL and  :new.PL_EMAIL IS NOT NULL)  or (:old.PL_EMAIL IS NOT NULL and  :new.PL_EMAIL IS NULL))
                 or( (:old.PL_POST_CODE <> :new.PL_POST_CODE) or (:old.PL_POST_CODE IS NULL and  :new.PL_POST_CODE IS NOT NULL)  or (:old.PL_POST_CODE IS NOT NULL and  :new.PL_POST_CODE IS NULL))
                 or( (:old.PL_HW_MONTHEND <> :new.PL_HW_MONTHEND) or (:old.PL_HW_MONTHEND IS NULL and  :new.PL_HW_MONTHEND IS NOT NULL)  or (:old.PL_HW_MONTHEND IS NOT NULL and  :new.PL_HW_MONTHEND IS NULL))
                 or( (:old.PL_EFF_DATE <> :new.PL_EFF_DATE) or (:old.PL_EFF_DATE IS NULL and  :new.PL_EFF_DATE IS NOT NULL)  or (:old.PL_EFF_DATE IS NOT NULL and  :new.PL_EFF_DATE IS NULL))
                 or( (:old.PL_JURISDICTION <> :new.PL_JURISDICTION) or (:old.PL_JURISDICTION IS NULL and  :new.PL_JURISDICTION IS NOT NULL)  or (:old.PL_JURISDICTION IS NOT NULL and  :new.PL_JURISDICTION IS NULL))
                 or( (:old.PL_TERM_DATE <> :new.PL_TERM_DATE) or (:old.PL_TERM_DATE IS NULL and  :new.PL_TERM_DATE IS NOT NULL)  or (:old.PL_TERM_DATE IS NOT NULL and  :new.PL_TERM_DATE IS NULL))
                 or( (:old.PL_CLIENT_ID <> :new.PL_CLIENT_ID) or (:old.PL_CLIENT_ID IS NULL and  :new.PL_CLIENT_ID IS NOT NULL)  or (:old.PL_CLIENT_ID IS NOT NULL and  :new.PL_CLIENT_ID IS NULL))
                 or( (:old.PL_TYPE <> :new.PL_TYPE) or (:old.PL_TYPE IS NULL and  :new.PL_TYPE IS NOT NULL)  or (:old.PL_TYPE IS NOT NULL and  :new.PL_TYPE IS NULL))
                 or( (:old.PL_STATUS <> :new.PL_STATUS) or (:old.PL_STATUS IS NULL and  :new.PL_STATUS IS NOT NULL)  or (:old.PL_STATUS IS NOT NULL and  :new.PL_STATUS IS NULL))
                 or( (:old.PL_MEMBER_IDENTIFIER <> :new.PL_MEMBER_IDENTIFIER) or (:old.PL_MEMBER_IDENTIFIER IS NULL and  :new.PL_MEMBER_IDENTIFIER IS NOT NULL)  or (:old.PL_MEMBER_IDENTIFIER IS NOT NULL and  :new.PL_MEMBER_IDENTIFIER IS NULL))
                 or( (:old.PL_GST_NUMBER <> :new.PL_GST_NUMBER) or (:old.PL_GST_NUMBER IS NULL and  :new.PL_GST_NUMBER IS NOT NULL)  or (:old.PL_GST_NUMBER IS NOT NULL and  :new.PL_GST_NUMBER IS NULL))
                 or( (:old.PL_PAY_GRACE_PERIOD <> :new.PL_PAY_GRACE_PERIOD) or (:old.PL_PAY_GRACE_PERIOD IS NULL and  :new.PL_PAY_GRACE_PERIOD IS NOT NULL)  or (:old.PL_PAY_GRACE_PERIOD IS NOT NULL and  :new.PL_PAY_GRACE_PERIOD IS NULL))
                 then 
      insert into OLIVER.AUDIT_TBL_PLAN(PL_ID
                             ,PL_ADMINISTRATOR
                             ,PL_CONTACT
                             ,PL_NAME
                             ,PL_ADDRESS1
                             ,PL_ADDRESS2
                             ,PL_CITY
                             ,PL_PROV
                             ,PL_COUNTRY
                             ,PL_PHONE1
                             ,PL_PHONE2
                             ,PL_FAX
                             ,PL_EMAIL
                             ,PL_POST_CODE
                             ,PL_HW_MONTHEND
                             ,PL_EFF_DATE
                             ,PL_JURISDICTION
                             ,PL_TERM_DATE
                             ,PL_CLIENT_ID
                             ,PL_TYPE
                             ,PL_STATUS
                             ,PL_MEMBER_IDENTIFIER
                             ,PL_GST_NUMBER
                             ,PL_PAY_GRACE_PERIOD
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:new.PL_ID
                             ,:new.PL_ADMINISTRATOR
                             ,:new.PL_CONTACT
                             ,:new.PL_NAME
                             ,:new.PL_ADDRESS1
                             ,:new.PL_ADDRESS2
                             ,:new.PL_CITY
                             ,:new.PL_PROV
                             ,:new.PL_COUNTRY
                             ,:new.PL_PHONE1
                             ,:new.PL_PHONE2
                             ,:new.PL_FAX
                             ,:new.PL_EMAIL
                             ,:new.PL_POST_CODE
                             ,:new.PL_HW_MONTHEND
                             ,:new.PL_EFF_DATE
                             ,:new.PL_JURISDICTION
                             ,:new.PL_TERM_DATE
                             ,:new.PL_CLIENT_ID
                             ,:new.PL_TYPE
                             ,:new.PL_STATUS
                             ,:new.PL_MEMBER_IDENTIFIER
                             ,:new.PL_GST_NUMBER
                             ,:new.PL_PAY_GRACE_PERIOD
                                  ,'U',v_user,SYSDATE);
   end if; elsif deleting then
 v_action:='DELETING';
      insert into OLIVER.AUDIT_TBL_PLAN(PL_ID
                             ,PL_ADMINISTRATOR
                             ,PL_CONTACT
                             ,PL_NAME
                             ,PL_ADDRESS1
                             ,PL_ADDRESS2
                             ,PL_CITY
                             ,PL_PROV
                             ,PL_COUNTRY
                             ,PL_PHONE1
                             ,PL_PHONE2
                             ,PL_FAX
                             ,PL_EMAIL
                             ,PL_POST_CODE
                             ,PL_HW_MONTHEND
                             ,PL_EFF_DATE
                             ,PL_JURISDICTION
                             ,PL_TERM_DATE
                             ,PL_CLIENT_ID
                             ,PL_TYPE
                             ,PL_STATUS
                             ,PL_MEMBER_IDENTIFIER
                             ,PL_GST_NUMBER
                             ,PL_PAY_GRACE_PERIOD
                                  ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)
      values (:old.PL_ID
                             ,:old.PL_ADMINISTRATOR
                             ,:old.PL_CONTACT
                             ,:old.PL_NAME
                             ,:old.PL_ADDRESS1
                             ,:old.PL_ADDRESS2
                             ,:old.PL_CITY
                             ,:old.PL_PROV
                             ,:old.PL_COUNTRY
                             ,:old.PL_PHONE1
                             ,:old.PL_PHONE2
                             ,:old.PL_FAX
                             ,:old.PL_EMAIL
                             ,:old.PL_POST_CODE
                             ,:old.PL_HW_MONTHEND
                             ,:old.PL_EFF_DATE
                             ,:old.PL_JURISDICTION
                             ,:old.PL_TERM_DATE
                             ,:old.PL_CLIENT_ID
                             ,:old.PL_TYPE
                             ,:old.PL_STATUS
                             ,:old.PL_MEMBER_IDENTIFIER
                             ,:old.PL_GST_NUMBER
                             ,:old.PL_PAY_GRACE_PERIOD
                                  ,'D',v_user,SYSDATE);
   end if;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
/


