--
-- PKG_PORTAL_AUTH  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.PKG_PORTAL_AUTH AS

    FUNCTION CREATE_HASH_PASSWORD (
        P_USERNAME   IN USERS.USER_NAME%TYPE,
        P_PASSWORD   IN USERS.PASSWORD%TYPE
    ) RETURN VARCHAR2
        IS
    BEGIN
        RETURN MD5HASH(UPPER(P_USERNAME)
        || P_PASSWORD);
    END CREATE_HASH_PASSWORD;

    FUNCTION MD5HASH (
        P_INPUT IN VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        RETURN UPPER(DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT => UTL_I18N.STRING_TO_RAW(P_INPUT) ) );
    END MD5HASH;

    FUNCTION AUTHENTICATE (
        P_USERNAME   IN VARCHAR2,
        P_PASSWORD   IN VARCHAR2
    ) RETURN BOOLEAN IS

        V_PASSWORD     VARCHAR2(100);
        V_HASH         VARCHAR2(100);
        V_CLIENT_ID    VARCHAR2(20);
        V_PLAN_ID      VARCHAR2(20);
        V_FIRST_NAME   VARCHAR2(60);
        V_LAST_NAME    VARCHAR2(60);
    BEGIN
        V_HASH := MD5HASH(UPPER(P_USERNAME)
        || P_PASSWORD);
        SELECT
            PASSWORD,
            CLIENT_ID,
            PLAN_ID,
            USER_FIRST_NAME,
            USER_LAST_NAME
        INTO
            V_PASSWORD,V_CLIENT_ID,V_PLAN_ID,V_FIRST_NAME,V_LAST_NAME
        FROM
            PORTAL_USERS
        WHERE
            UPPER(EMAIL) = UPPER(P_USERNAME);

        IF
            V_PASSWORD = V_HASH
        THEN
            AUDIT_PORTAL_ACCESS(P_USERNAME,'true',V_CLIENT_ID,V_PLAN_ID,V_FIRST_NAME,V_LAST_NAME);
            RETURN TRUE;
        ELSE
            AUDIT_PORTAL_ACCESS(P_USERNAME,'false',V_CLIENT_ID,V_PLAN_ID,V_FIRST_NAME,V_LAST_NAME);
            RETURN FALSE;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            AUDIT_PORTAL_ACCESS(P_USERNAME,'false',NULL,NULL,NULL,NULL);
            RETURN FALSE;
    END AUTHENTICATE;

    PROCEDURE AUDIT_PORTAL_ACCESS (
        P_USER_NAME     VARCHAR2,
        P_AUTH_RESULT   VARCHAR2,
        P_CLIENT_ID     VARCHAR2,
        P_PLAN_ID       VARCHAR2,
        P_FIRST_NAME    VARCHAR2,
        P_LAST_NAME     VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
      -- purge data older than 90 days
        DELETE PORTAL_USERS_ACTIVITY WHERE
            AUDIT_DATE < SYSDATE - 90;
      -- create audit row

        INSERT INTO PORTAL_USERS_ACTIVITY (
            EMAIL,
            AUDIT_DATE,
            IPADDRESS,
            AUTH_RESULT,
            CLIENT_ID,
            PLAN_ID,
            FIRST_NAME,
            LAST_NAME
        ) VALUES (
            P_USER_NAME,
            SYSDATE,
            OWA_UTIL.GET_CGI_ENV('REMOTE_ADDR'),
            P_AUTH_RESULT,
            P_CLIENT_ID,
            P_PLAN_ID,
            P_FIRST_NAME,
            P_LAST_NAME
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END AUDIT_PORTAL_ACCESS;

    PROCEDURE SEND_CREATION_EMAIL (
        P_EMAIL   IN VARCHAR2,
        P_URL     IN VARCHAR2
    ) IS
        L_BODY           CLOB;
        L_BODY_HTML      CLOB;
        V_EMAIL_EXISTS   VARCHAR2(1) := 'N';
    BEGIN
        SELECT
            'Y'
        INTO
            V_EMAIL_EXISTS
        FROM
            PORTAL_USERS
        WHERE
            UPPER(EMAIL) = UPPER(P_EMAIL);

        APEX_DEBUG.MESSAGE(P_MESSAGE => 'Creation of Oliver Member Portal account',P_LEVEL => 3);
        L_BODY := '<p>Hi,</p>
            <p>You have created an account on the Oliver Member Portal.</p>
             <p><a href="'
        || P_URL
        || '"><button type="button">Enter Portal</button></a></p>
             <p>If you did not request this, you can simply ignore this email.</p>
             <p>Kind regards,<br/>
             The Oliver Team</p>'
;
        L_BODY_HTML := '<html>
        <head>
            <style type="text/css">

                body{
                    font-size:10pt;
                    margin:30px;
                    background-color:#ffffff;}

                span.sig{font-style:italic;
                    font-weight:bold;
                    color:#811919;}

button {
font-size:20px;
background-color: #29B6F6;
color: #fff;
border-radius: 0px;
font-weight: lighter;
border: none;
}

             </style>
         </head>
         <body>'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '<p>Hi,</p>'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '<p>You have created an account on the Oliver Member Portal.</p>'
        || UTL_TCP.CRLF;
   -- l_body_html := l_body_html ||'<p><a href="'||p_url||'"><button type="button">Enter Portal</button></a></p>'||utl_tcp.crlf;
        L_BODY_HTML := L_BODY_HTML
        || '<p>If you did not create this account or recieving this in error, you can simply ignore this email.</p>'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '  Kind Regards,<br />'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '  <span class="sig">The Oliver Portal Team</span><br />'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '</body></html>';
        IF
            V_EMAIL_EXISTS = 'Y'
        THEN
            APEX_MAIL.SEND(P_TO => P_EMAIL,P_FROM => 'admin@cdatsystems.com',P_BODY => L_BODY,P_BODY_HTML => L_BODY_HTML,P_SUBJ => 'Creation of Oliver Member Portal account'
);

            APEX_MAIL.PUSH_QUEUE;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002,'Issue sending reset password email.');
    END SEND_CREATION_EMAIL;

    PROCEDURE CHANGE_PASSWORD (
        P_MEMBERID   VARCHAR2,
        P_EMAIL      IN VARCHAR2,
        P_PASSWORD   IN VARCHAR2
    ) IS
        V_CODE   RAW(32);
        V_HASH   VARCHAR2(32);
    BEGIN
   /* UPDATE portal_users ur
    SET ur.isactive        = 'N'
    WHERE UPPER (ur.email) = UPPER (p_email)
    AND upper(mem_id)      =upper(p_memberid); */
    
    -- generate the password hash for the user
        V_HASH := MD5HASH(UPPER(P_EMAIL)
        || P_PASSWORD);
    -- generate the verification link that will be used
        V_CODE := MD5HASH(P_EMAIL
        || DBMS_RANDOM.STRING('A',8) );
    /*
    INTO tbl_verification_link
      (
        email,
        registered,
        verification_code
      )
      VALUES
      (
        p_email,
        SYSDATE,
        v_code
      );*/
    -- generate the password hash for the user
        V_HASH := MD5HASH(UPPER(P_EMAIL)
        || P_PASSWORD);
        UPDATE PORTAL_USERS
            SET
                PASSWORD = V_HASH
        WHERE
            MEM_ID = P_MEMBERID
            AND   EMAIL = P_EMAIL;
    --send_verification_email(p_email, v_code );

    END CHANGE_PASSWORD;

    PROCEDURE REGISTER_PORTAL_USER (
        P_EMAIL      IN VARCHAR2,
        P_PASSWORD   IN VARCHAR2,
        P_MEMBERID   IN NUMBER,
        P_DOB        IN VARCHAR2,
        P_CLIENTID   IN VARCHAR2,
        P_PLANID     IN VARCHAR2
    ) IS

        V_HASH         VARCHAR2(32);
        V_CODE         RAW(32);
        V_FIRST_NAME   TBL_MEMBER.MEM_FIRST_NAME%TYPE;
        V_LAST_NAME    TBL_MEMBER.MEM_LAST_NAME%TYPE;
        V_SIN          TBL_MEMBER.MEM_SIN%TYPE;
        V_MEM_ID       TBL_MEMBER.MEM_ID%TYPE;
        V_APP_ID       NUMBER;
        V_URL          VARCHAR2(1000);
    BEGIN
    -- generate the password hash for the user
        V_HASH := MD5HASH(UPPER(P_EMAIL)
        || P_PASSWORD);
    -- generate the verification link that will be used
        V_CODE := MD5HASH(P_EMAIL
        || DBMS_RANDOM.STRING('A',8) );
        SELECT
            MEM_FIRST_NAME,
            MEM_LAST_NAME,
            MEM_SIN,
            MEM_ID
        INTO
            V_FIRST_NAME,V_LAST_NAME,V_SIN,V_MEM_ID
        FROM
            TBL_MEMBER
        WHERE
            (
                MEM_ID = P_MEMBERID
                OR    SUBSTR(MEM_SIN,GREATEST(LENGTH(MEM_SIN) - 3,1) ) = P_MEMBERID
            )
            AND   MEM_DOB = TO_DATE(UPPER(P_DOB),'DD-MON-RRRR')
            AND   MEM_PLAN = P_PLANID
            AND   MEM_CLIENT_ID = P_CLIENTID;

        INSERT INTO PORTAL_USERS (
            USER_ID,
            EMAIL,
            PASSWORD,
            USER_FIRST_NAME,
            USER_LAST_NAME,
            DATE_CREATED,
            CLIENT_ID,
            MEM_ID,
            ISACTIVE,
            PLAN_ID
        ) VALUES (
      --important to use this sequence as the apex_access_control list pulls from 2 seperate tables (users and portal_users)
            PORTAL_USERS_SEQ.NEXTVAL,
            P_EMAIL,
            V_HASH,
            V_FIRST_NAME,
            V_LAST_NAME,
            SYSDATE,
            P_CLIENTID,
            V_MEM_ID,
            'Y',
            P_PLANID
        );

        SELECT
            LINK
        INTO
            V_APP_ID
        FROM
            CLIENT_SUBDOMAIN
        WHERE
            CLIENT_ID = P_CLIENTID
            AND   PLAN_ID = P_PLANID;

        V_URL := OWA_UTIL.GET_CGI_ENV('REQUEST_PROTOCOL')
        || '://'
        /*|| owa_util.get_cgi_env('HTTP_HOST') -- temporarily taken out by ticket #1479
        || owa_util.get_cgi_env('SCRIPT_NAME')*/
        || 'datownley.ollieportal.co/ords'
        || '/f?p='
        || V_APP_ID;

        SEND_CREATION_EMAIL(P_EMAIL => P_EMAIL,P_URL => V_URL);
    END REGISTER_PORTAL_USER;

    PROCEDURE REGISTER_PORTAL_ADMIN (
        P_USER_ID     IN INTEGER,
        P_CLIENT_ID   IN VARCHAR2,
        P_PLAN_ID     IN VARCHAR2
    ) IS
        R_USERS   USERS%ROWTYPE;
    BEGIN
        SELECT
            *
        INTO
            R_USERS
        FROM
            USERS
        WHERE
            USER_ID = P_USER_ID
            AND   CLIENT_ID = P_CLIENT_ID;

        FOR X IN (
            SELECT
                COUNT(*) CNT
            FROM
                DUAL
            WHERE
                EXISTS (
                    SELECT
                        NULL
                    FROM
                        PORTAL_USERS
                    WHERE
                        CLIENT_ID = P_CLIENT_ID
                  --AND   plan_id = p_plan_id
                        AND   UPPER(EMAIL) = UPPER(R_USERS.EMAIL)
                )
        ) LOOP
            IF
                ( X.CNT = 1 )
            THEN
                DBMS_OUTPUT.PUT_LINE(X.CNT);
                RAISE_APPLICATION_ERROR(-20100,'Portal admin account exists already for '
                || R_USERS.EMAIL);
            ELSE
                DBMS_OUTPUT.PUT_LINE(X.CNT);
                INSERT INTO PORTAL_USERS (
                    USER_ID,
                    EMAIL,
                    PASSWORD,
                    DATE_CREATED,
                    CLIENT_ID,
                    ISACTIVE,
                    ISADMIN,
                    PEN_VERIFY,
                    HW_VERIFY
            --,plan_id
                ) VALUES (
                    PORTAL_USERS_SEQ.NEXTVAL,
                    R_USERS.EMAIL,
                    R_USERS.PASSWORD,
                    SYSDATE,
                    P_CLIENT_ID,
                    'Y',
                    'Y',
                    'Y',
                    'Y'
            --p_plan_id
                );

                UPDATE PORTAL_USERS
                    SET
                        ISADMIN = 'N'
                WHERE
                    CLIENT_ID = P_CLIENT_ID
                  --AND   plan_id = p_plan_id
                    AND   ISADMIN IS NULL;

            END IF;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(SQLCODE,SQLERRM);
    END;

    FUNCTION AUTHORIZE (
        P_PLAN_ID      VARCHAR2,
        P_PLAN_TYPE    VARCHAR2,
        P_PLAN_GROUP   VARCHAR2,
        P_CLIENT_ID    VARCHAR2,
        P_USER_ID      NUMBER,
        P_PAGE_ID      NUMBER
    ) RETURN BOOLEAN
        IS
    BEGIN
        FOR X IN (
            SELECT
                COUNT(*) CNT
            FROM
                DUAL
            WHERE
                EXISTS (
                    SELECT
                        NULL
                    FROM
                        PORTAL_USERS_ACCESS
                    WHERE
                        CLIENT_ID = P_CLIENT_ID
                        AND   PLAN_ID = P_PLAN_ID
                        AND   PLAN_GROUP = PLAN_GROUP
                        AND   PLAN_TYPE = PLAN_TYPE
                        AND   USER_ID = P_USER_ID
                        AND   PAGE_ID = P_PAGE_ID
                )
        ) LOOP
            IF
                ( X.CNT = 1 )
            THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;
        END LOOP;
    END;

    PROCEDURE MAIL_RESET_PASSWORD (
        P_EMAIL   IN VARCHAR2,
        P_URL     IN VARCHAR2
    ) IS
        L_BODY           CLOB;
        L_BODY_HTML      CLOB;
        V_EMAIL_EXISTS   VARCHAR2(1) := 'N';
    BEGIN
        SELECT
            'Y'
        INTO
            V_EMAIL_EXISTS
        FROM
            PORTAL_USERS
        WHERE
            UPPER(EMAIL) = UPPER(P_EMAIL);

        APEX_DEBUG.MESSAGE(P_MESSAGE => 'Reset password Oliver Member Portal account',P_LEVEL => 3);
        L_BODY := '<p>Hi,</p>
            <p>We received a request to reset your password in the Oliver Member Portal application.</p>
             <p><a href="'
        || P_URL
        || '"><button type="button">Reset Password</button></a></p>
             <p>If you did not request this, you can simply ignore this email.</p>
             <p>Kind regards,<br/>
             The Oliver Team</p>'
;
        L_BODY_HTML := '<html>
        <head>
            <style type="text/css">

                body{
                    font-size:10pt;
                    margin:30px;
                    background-color:#ffffff;}

                span.sig{font-style:italic;
                    font-weight:bold;
                    color:#811919;}

button {
font-size:20px;
background-color: #29B6F6;
color: #fff;
border-radius: 0px;
font-weight: lighter;
border: none;
}

             </style>
         </head>
         <body>'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '<p>Hi,</p>'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '<p>We received a request to reset your password in the Oliver Member Portal application.</p>'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '<p><a href="'
        || P_URL
        || '"><button type="button">Reset Password</button></a></p>'
        || UTL_TCP.CRLF;

        L_BODY_HTML := L_BODY_HTML
        || '<p>If you did not request this, you can simply ignore this email.</p>'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '  Sincerely,<br />'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '  <span class="sig">The Oliver Portal Team</span><br />'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '</body></html>';
        IF
            V_EMAIL_EXISTS = 'Y'
        THEN
            APEX_MAIL.SEND(P_TO => P_EMAIL,P_FROM => 'admin@cdatsystems.com',P_BODY => L_BODY,P_BODY_HTML => L_BODY_HTML,P_SUBJ => 'Reset password Oliver Member Portal account'
);

            APEX_MAIL.PUSH_QUEUE;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002,'Issue sending reset password email.');
    END MAIL_RESET_PASSWORD;

    PROCEDURE REQUEST_RESET_PASSWORD (
        P_EMAIL IN VARCHAR2
    ) IS
        L_ID                  NUMBER;
        L_VERIFICATION_CODE   VARCHAR2(100);
        L_URL                 VARCHAR2(200);
    BEGIN
  -- First, check to see if the user is in the user table
        SELECT
            USER_ID
        INTO
            L_ID
        FROM
            PORTAL_USERS
        WHERE
            UPPER(EMAIL) = UPPER(P_EMAIL);

        DBMS_RANDOM.INITIALIZE(TO_CHAR(SYSDATE,'YYMMDDDSS') );
        L_VERIFICATION_CODE := DBMS_RANDOM.STRING('A',20);
        /*l_url := apex_util.prepare_url(p_url => c_hostname
        || 'f?p='
        || v('APP_ID')
        || ':20:0::::P20_ID,P20_VC:'
        || l_id
        || ','
        || l_verification_code,p_checksum_type => 1);
        l_url := c_hostname
        || apex_page.get_url(p_page => 20, p_session => 0, p_items => 'P20_ID,P20_VC',p_values => ''
        || l_id
        || ','
        || l_verification_code
        || '');*/
        L_URL := OWA_UTIL.GET_CGI_ENV('REQUEST_PROTOCOL')
        || '://'
        || OWA_UTIL.GET_CGI_ENV('HTTP_HOST')
        || OWA_UTIL.GET_CGI_ENV('SCRIPT_NAME')
        || '/f?p='
        || APEX_APPLICATION.G_FLOW_ID
        || ':20:0::NO::P20_ID,P20_VC:'
        || L_ID
        || ','
        || L_VERIFICATION_CODE;

        UPDATE PORTAL_USERS
            SET
                VERIFICATION_CODE = L_VERIFICATION_CODE
        WHERE
            USER_ID = L_ID;

        MAIL_RESET_PASSWORD(P_EMAIL => P_EMAIL,P_URL => L_URL);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END REQUEST_RESET_PASSWORD;

    FUNCTION IS_USER_ADMIN (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_EMAIL       VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        FOR U IN (
            SELECT
                NVL(ISADMIN,'N') IS_ADMIN
            FROM
                PORTAL_USERS
            WHERE
                CLIENT_ID = P_CLIENT_ID
                AND   PLAN_ID = P_PLAN_ID
                AND   LOWER(EMAIL) = LOWER(P_EMAIL)
        ) LOOP
            RETURN U.IS_ADMIN;
        END LOOP;

        RETURN NULL;
    END IS_USER_ADMIN;

    FUNCTION IS_PEN_MEMBER_ACTIVE (
        P_PLAN        VARCHAR2,
        P_CLIENT      VARCHAR2,
        P_MEMBER_ID   VARCHAR2
    ) RETURN VARCHAR2 AS
        RETVAL   VARCHAR2(1);
    BEGIN
        SELECT
            PENM_STATUS
        INTO
            RETVAL
        FROM
            TBL_PENMAST
        WHERE
            PENM_CLIENT = P_CLIENT
            AND   PENM_PLAN = P_PLAN
            AND   PENM_ID = P_MEMBER_ID;

        RETURN RETVAL;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END IS_PEN_MEMBER_ACTIVE;

    FUNCTION GET_ACTIVE_STATUS_CODE (
        P_PLAN VARCHAR2,
        P_CLIENT VARCHAR2
    ) RETURN VARCHAR2 AS
        RETVAL   VARCHAR2(1);
    BEGIN
        SELECT
            TPS_STATUS
        INTO
            RETVAL
        FROM
            TBL_PENSION_STATUS
        WHERE
            TPS_CLIENT = P_CLIENT
            AND   TPS_PLAN = P_PLAN
            AND   UPPER(TRIM(TPS_STATUS_DESC) ) = 'ACTIVE';

        RETURN RETVAL;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END GET_ACTIVE_STATUS_CODE;

    PROCEDURE UNAVAILABLE_MESSAGE
        IS
    BEGIN
        HTP.P('
        <center><img src="http://www.expressimpress.org/wp-content/uploads/2015/05/bebacksoon-300x281.jpg"></center>
        <center><strong><big>SYSTEM MAINTENANCE IN PROGRESS</big></strong></center>
        <p>
          <center>
            Your pension account access is temporarily unavailable</br>
            due to system maintenance. The service will be unavailable for approximately four hours. We apologize</br>
            for any inconvenience, and thank you for your patience.
          </center>
        </p>
      '
);
    END UNAVAILABLE_MESSAGE;

END PKG_PORTAL_AUTH;

/

