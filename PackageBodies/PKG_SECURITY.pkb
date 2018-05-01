--
-- PKG_SECURITY  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.PKG_SECURITY AS

    C_KEY      VARCHAR2(255) := 'oliver_cdat_systems_com_2017_van';

    PROCEDURE LOG_PAGE_ACCESS IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO APEX_PAGE_ACCESS (
            APP_ID,
            PAGE_ID,
            USER_ID,
            CLIENT_ID,
            ACCESS_DATE
        ) VALUES (
            APEX_APPLICATION.G_FLOW_ID,
            APEX_APPLICATION.G_FLOW_STEP_ID,
            APEX_APPLICATION.G_USER,
            V('P1_CLIENT_ID'),
            SYSDATE
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END LOG_PAGE_ACCESS;

    FUNCTION ENCRYPT (
        P_TEXT VARCHAR2
    ) RETURN VARCHAR2 IS
        L_CRYPTO   RAW(2000);
        L_KEY      RAW(32) := UTL_RAW.CAST_TO_RAW(C_KEY);
    BEGIN
        L_CRYPTO := DBMS_CRYPTO.ENCRYPT(SRC => UTL_I18N.STRING_TO_RAW(P_TEXT,'AL32UTF8'),TYP => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC
+ DBMS_CRYPTO.PAD_PKCS5,KEY => L_KEY);

        RETURN L_CRYPTO;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN SQLERRM;
    END ENCRYPT;

    FUNCTION DECRYPT (
        P_TEXT VARCHAR2
    ) RETURN VARCHAR2 IS
        L_CRYPTO   RAW(2000);
        L_KEY      RAW(32) := UTL_RAW.CAST_TO_RAW(C_KEY);
    BEGIN
        L_CRYPTO := DBMS_CRYPTO.DECRYPT(SRC => P_TEXT,TYP => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,KEY => L_KEY)
;

        RETURN UTL_I18N.RAW_TO_CHAR(L_CRYPTO,'AL32UTF8');
    EXCEPTION
        WHEN OTHERS THEN
            RETURN SQLERRM;
    END DECRYPT;

    FUNCTION AUTHENTICATE_PWD_MGMT (
        P_USERNAME VARCHAR2,
        P_PASSWORD VARCHAR2
    ) RETURN BOOLEAN
        IS
    BEGIN
        FOR U IN (
            SELECT
                NULL
            FROM
                SEC_USER
            WHERE
                LOWER(USER_NAME) = LOWER(P_USERNAME)
                AND   LOWER(PKG_SECURITY.DECRYPT(PASSWORD) ) = LOWER(P_PASSWORD)
                AND   ENABLED = 'Y'
                AND   UPPER(V('APP_DOMAIN') ) = 'CDAT'
        ) LOOP
            RETURN TRUE;
        END LOOP;

        RETURN FALSE;
    END AUTHENTICATE_PWD_MGMT;

    FUNCTION AUTHORIZE_PWD_MGMT (
        P_USERNAME VARCHAR2
    ) RETURN BOOLEAN
        IS
    BEGIN
        FOR U IN (
            SELECT
                IS_INTERNAL_ADMIN
            FROM
                SEC_USER
            WHERE
                LOWER(USER_NAME) = LOWER(P_USERNAME)
                AND   ENABLED = 'Y'
        ) LOOP
            IF
                U.IS_INTERNAL_ADMIN = 'Y'
            THEN
                RETURN TRUE;
            END IF;
        END LOOP;

        RETURN FALSE;
    END AUTHORIZE_PWD_MGMT;

    FUNCTION USER_PROJECT_AUTHORIZED (
        P_USERNAME VARCHAR2,
        P_PROJECT_ID VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        FOR U IN (
            SELECT
                ID,
                IS_INTERNAL_ADMIN
            FROM
                SEC_USER
            WHERE
                LOWER(USER_NAME) = LOWER(P_USERNAME)
        ) LOOP
      -- user is admin
            IF
                U.IS_INTERNAL_ADMIN = 'Y'
            THEN
                RETURN 'Y';
            END IF;
      -- check if user's group has access to project
            FOR P IN (
                SELECT
                    NULL
                FROM
                    SEC_USER_GROUP_PROJECTS UGP
                WHERE
                    UGP.PROJECT_ID = P_PROJECT_ID
                    AND   UGP.USER_GROUP_ID IN (
                        SELECT
                            USER_GROUP_ID
                        FROM
                            SEC_USER_GROUP_USERS
                        WHERE
                            USER_ID = U.ID
                    )
            ) LOOP
                RETURN 'Y';
            END LOOP;

        END LOOP;
    -- no access found

        RETURN 'N';
    END USER_PROJECT_AUTHORIZED;

END PKG_SECURITY;
/

