--
-- PKG_MEMBER_PORTAL  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.PKG_MEMBER_PORTAL AS

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
        V_AUTHENTICATE   CHAR(1);
        V_HASH           VARCHAR2(32);
    BEGIN
        V_HASH := MD5HASH(P_USERNAME
        || P_PASSWORD);
        SELECT
            ISACTIVE
        INTO
            V_AUTHENTICATE
        FROM
            USERS
        WHERE
            UPPER(USER_NAME) = UPPER(P_USERNAME)
            AND   UPPER(PASSWORD) = V_HASH;

        IF
            V_AUTHENTICATE = 'N'
        THEN
            APEX_UTIL.SET_SESSION_STATE('MESSAGE','your account has not been verified yet');
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END AUTHENTICATE;

    PROCEDURE REGISTER_PORTAL_USER (
        P_EMAIL       IN VARCHAR2,
        P_PASSWORD    IN VARCHAR2,
        P_MEMBERID    IN NUMBER,
        P_CLIENTID    IN VARCHAR2,
        P_PLANTYPES   IN VARCHAR2
    ) IS
        V_HASH   VARCHAR2(32);
        V_CODE   RAW(32);
    BEGIN
    -- generate the password hash for the user
        V_HASH := MD5HASH(UPPER(P_EMAIL)
        || P_PASSWORD);
    -- generate the verification link that will be used
        V_CODE := MD5HASH(P_EMAIL
        || DBMS_RANDOM.STRING('A',8) );
        INSERT INTO TBL_VERIFICATION_LINK (
            EMAIL,
            REGISTERED,
            VERIFICATION_CODE
        ) VALUES (
            P_EMAIL,
            SYSDATE,
            V_CODE
        );

        INSERT INTO USERS (
            USER_ID,
            USER_NAME,
            PASSWORD,
            FILE_NAME,
            MIME_TYPE,
            ATTACHMENT,
            USER_FISRT_NAME,
            USER_LAST_NAME,
            USER_EFFECTIVE_DATE,
            USER_TERMINATION_DATE,
            CLIENT_ID,
      --plan_id,
            MEM_ID,
            ISACTIVE
        ) VALUES (
            USERS_SEQ.NEXTVAL,
            P_EMAIL,
            V_HASH,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            SYSDATE,
            NULL,
            P_CLIENTID,
       --p_plantypes,
            P_MEMBERID,
            'Y'
        );
    -- send the verification email
    --send_verification_email (p_username, p_email, v_code);
    --send_developer_email(p_username);

    END REGISTER_PORTAL_USER;

    PROCEDURE CHANGE_PASSWORD (
        P_MEMBERID   VARCHAR2,
        P_EMAIL      IN VARCHAR2,
        P_PASSWORD   IN VARCHAR2
    ) IS
        V_CODE   RAW(32);
        V_HASH   VARCHAR2(32);
    BEGIN
        UPDATE USERS UR
            SET
                UR.ISACTIVE = 'N'
        WHERE
            UPPER(UR.USER_NAME) = UPPER(P_EMAIL)
            AND   UPPER(MEM_ID) = UPPER(P_MEMBERID);
    -- generate the password hash for the user

        V_HASH := MD5HASH(UPPER(P_EMAIL)
        || P_PASSWORD);
    -- generate the verification link that will be used
        V_CODE := MD5HASH(P_EMAIL
        || DBMS_RANDOM.STRING('A',8) );
        INSERT INTO TBL_VERIFICATION_LINK (
            EMAIL,
            REGISTERED,
            VERIFICATION_CODE
        ) VALUES (
            P_EMAIL,
            SYSDATE,
            V_CODE
        );
    -- generate the password hash for the user

        V_HASH := MD5HASH(UPPER(P_EMAIL)
        || P_PASSWORD);
        UPDATE USERS
            SET
                PASSWORD = V_HASH
        WHERE
            MEM_ID = P_MEMBERID
            AND   USER_NAME = P_EMAIL;

        SEND_VERIFICATION_EMAIL(P_EMAIL,V_CODE);
    END CHANGE_PASSWORD;

    PROCEDURE SEND_VERIFICATION_EMAIL (
        P_EMAIL   IN VARCHAR2,
        P_CODE    IN RAW
    ) IS

        L_BODY          CLOB;
        L_LINK          CLOB;
        C_SMTP_SERVER   VARCHAR2(10) := 'localhost';
        C_SMTP_PORT     INTEGER := 25;
        C_BASE_URL      VARCHAR2(200) := 'https://cdatdev.com/ords/CDATV5.pkg_member_portal.verify_user?p_email=';
        C_FROM          VARCHAR2(30) := 'admin@cdatsystems.com';
    BEGIN
        L_BODY := '=============================================='
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || '= This Is an Automated Message, Do Not Reply ='
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || '=============================================='
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || 'Hello '
        || P_EMAIL
        || ','
        || UTL_TCP.CRLF;

        L_BODY := L_BODY
        || UTL_TCP.CRLF;
    /*l_body := l_body || 'Thanks for taking the time to register.' || utl_tcp.crlf;
    l_body := l_body || utl_tcp.crlf;
    l_body := l_body || 'in order to complete your registration you will need to verify
    your email address.' || utl_tcp.crlf;
    l_body := l_body || utl_tcp.crlf;*/
        L_BODY := L_BODY
        || 'To verify your password change, simply click the link below, or copy it and paste it into the address field of your web browser.'
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || UTL_TCP.CRLF;
        L_LINK := C_BASE_URL
        || P_EMAIL
        || '&p_code='
        || P_CODE;
        L_BODY := L_BODY
        || L_LINK
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || 'You only need to click this link once, and your account will be updated.'
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || 'You need to verify your email address
within 5 days of receiving this mail.'
        || UTL_TCP.CRLF;
        APEX_MAIL.SEND(P_TO => P_EMAIL,P_FROM => C_FROM,P_BODY => L_BODY,P_SUBJ => 'Your verification email');

        APEX_MAIL.PUSH_QUEUE(C_SMTP_SERVER,C_SMTP_PORT);
    END SEND_VERIFICATION_EMAIL;

    PROCEDURE VERIFY_USER (
        P_EMAIL   IN VARCHAR2,
        P_CODE    IN VARCHAR2
    )
        IS
    BEGIN
        UPDATE USERS UR
            SET
                UR.ISACTIVE = 'Y'
        WHERE
            UPPER(UR.USER_NAME) = UPPER(P_EMAIL)
            AND   EXISTS (
                SELECT
                    1
                FROM
                    TBL_VERIFICATION_LINK VL
                WHERE
                    VL.EMAIL = UR.USER_NAME
                    AND   VL.VERIFICATION_CODE = P_CODE
            );

        IF
            SQL%ROWCOUNT > 0
        THEN
            HTP.P('Thank you, your account has now been verified.  You can log in to the <a href="https://cdatdev.com/ords/f?p=100" class="button">Member Portal</a> here.'
);
        ELSE
            HTP.P('Sorry the link you have used is invalid, please contact your Administrator.');
        END IF;

    END VERIFY_USER;

    FUNCTION IS_ACTIVE (
        P_EMAIL IN VARCHAR2
    ) RETURN VARCHAR2 IS
        V_RETVAL   VARCHAR2(1) := 'N';
    BEGIN
        SELECT
            ISACTIVE
        INTO
            V_RETVAL
        FROM
            USERS
        WHERE
            UPPER(P_EMAIL) = UPPER(USER_NAME);

        RETURN V_RETVAL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'N';
    END IS_ACTIVE;

END PKG_MEMBER_PORTAL;

/

