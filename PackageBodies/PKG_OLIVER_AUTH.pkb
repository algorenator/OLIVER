--
-- PKG_OLIVER_AUTH  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.PKG_OLIVER_AUTH AS

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
        V_COUNT       PLS_INTEGER;
        V_CLIENT_ID   VARCHAR2(255);
        L_RESULT      BOOLEAN;
    BEGIN
        V_CLIENT_ID := V('P101_SUBDOMAIN');
        SELECT
            COUNT(*)
        INTO
            V_COUNT
        FROM
            USERS
        WHERE
            LOWER(EMAIL) = LOWER(P_USERNAME)
            AND   PASSWORD = CREATE_HASH_PASSWORD(P_USERNAME,P_PASSWORD)
            AND   UPPER(CLIENT_ID) = UPPER(V_CLIENT_ID)
            AND   (
                USER_TERMINATION_DATE IS NULL
                OR    USER_TERMINATION_DATE > SYSDATE
            );

        L_RESULT := V_COUNT > 0;
        AUDIT_ACCESS(V_CLIENT_ID,P_USERNAME,
            CASE
                WHEN L_RESULT THEN 'true'
                ELSE 'false'
            END
        );
        RETURN L_RESULT;
    EXCEPTION
        WHEN OTHERS THEN
            AUDIT_ACCESS(V_CLIENT_ID,P_USERNAME,'false');
            RETURN FALSE;
    END AUTHENTICATE;

    PROCEDURE SEND_VERIFICATION_EMAIL (
        P_EMAIL   IN VARCHAR2,
        P_CODE    IN RAW
    ) IS

        L_BODY          CLOB;
        L_LINK          CLOB;
        C_SMTP_SERVER   VARCHAR2(10) := 'localhost';
        C_SMTP_PORT     INTEGER := 25;
        C_BASE_URL      VARCHAR2(2000);
        C_FROM          VARCHAR2(30) := 'admin@cdatsystems.com';
    BEGIN
        C_BASE_URL := OWA_UTIL.GET_CGI_ENV('REQUEST_PROTOCOL')
        || '://'
        || OWA_UTIL.GET_CGI_ENV('HTTP_HOST')
        || OWA_UTIL.GET_CGI_ENV('SCRIPT_NAME')
        || '/cdatv5.pkg_member_portal.verify_user?p_email=';

        L_BODY := '=============================================='
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || '= This Is an Automated Message,Do Not Reply ='
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
        L_BODY := L_BODY
        || 'To verify your password change,simply click the link below,or copy it and paste it into the address field of your web browser.'
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
        || 'You only need to click this link once,and your account will be updated.'
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || UTL_TCP.CRLF;
        L_BODY := L_BODY
        || 'You need to verify your email address within 5 days of receiving this mail.'
        || UTL_TCP.CRLF;
        APEX_MAIL.SEND(P_TO => P_EMAIL,P_FROM => C_FROM,P_BODY => L_BODY,P_SUBJ => 'Your verification email');

        APEX_MAIL.PUSH_QUEUE(C_SMTP_SERVER,C_SMTP_PORT);
    END SEND_VERIFICATION_EMAIL;

    FUNCTION USER_NOT_GRANTED_ACCESSES (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_USER_ID     VARCHAR2
    ) RETURN T_ACCESSES_TREE
        PIPELINED
    IS
        L_PLAN_TYPE   T_TREE_NODE;
        L_GROUP       T_TREE_NODE;
        L_MOD         T_TREE_NODE;
    BEGIN

      -- get plan types
        FOR PLAN_TYPE IN (
            SELECT
                PT.PT_DESC,
                P.PL_TYPE
            FROM
                PLAN_TYPES PT,
                TBL_PLAN P
            WHERE
                P.PL_ID = P_PLAN_ID
                AND   PL_CLIENT_ID = P_CLIENT_ID
                AND   PT.PT_ID = P.PL_TYPE
            GROUP BY
                P.PL_TYPE,
                PT.PT_DESC
            ORDER BY
                PT.PT_DESC
        ) LOOP
            L_PLAN_TYPE := NULL;
            L_PLAN_TYPE.NAME := PLAN_TYPE.PT_DESC;
            L_PLAN_TYPE.CODE := PLAN_TYPE.PL_TYPE;

        -- get user groups
            FOR USER_GROUP IN (
                SELECT
                    GROUP_DESC,
                    GROUPID
                FROM
                    USER_GROUPS UG
                WHERE
                    G_CLIENT_ID = P_CLIENT_ID
                    AND   G_PLAN_TYPE = PLAN_TYPE.PL_TYPE
                    AND   (
                        SELECT
                            COUNT(*)
                        FROM
                            APEX_ACCESS_CONTROL
                        WHERE
                            CLIENT_ID = P_CLIENT_ID
                            AND   USER_ID = P_USER_ID
                            AND   EMP_MEMBER_ID IS NULL
                            AND   GROUP_ID = UG.GROUPID
                            AND   PLAN_ID = P_PLAN_ID
                    ) = 0
                GROUP BY
                    GROUP_DESC,
                    GROUPID
                ORDER BY
                    GROUP_DESC
            ) LOOP
                L_GROUP := NULL;
                L_GROUP.NAME := USER_GROUP.GROUP_DESC;
                L_GROUP.CODE := PLAN_TYPE.PL_TYPE
                || '|'
                || USER_GROUP.GROUPID;
                L_GROUP.PARENT_CODE := PLAN_TYPE.PL_TYPE;
                L_GROUP.PLAN_ID := P_PLAN_ID;
                L_GROUP.GROUP_ID := USER_GROUP.GROUPID;

          -- get group modules
                FOR MODULES IN (
                    SELECT
                        GET_MODULE_DESC(UG.G_MODULE) DESCRIPTION,
                        UG.G_MODULE
                    FROM
                        USER_GROUPS UG
                    WHERE
                        UG.GROUPID = USER_GROUP.GROUPID
                        AND   UG.G_CLIENT_ID = P_CLIENT_ID
                        AND   UG.G_PLAN_TYPE = PLAN_TYPE.PL_TYPE
                    ORDER BY
                        DESCRIPTION
                ) LOOP
                    L_MOD := NULL;
                    L_MOD.NAME := MODULES.DESCRIPTION;
                    L_MOD.CODE := PLAN_TYPE.PL_TYPE
                    || '|'
                    || USER_GROUP.GROUPID
                    || '|'
                    || MODULES.G_MODULE;

                    L_MOD.PARENT_CODE := PLAN_TYPE.PL_TYPE
                    || '|'
                    || USER_GROUP.GROUPID;
                    IF
                        L_PLAN_TYPE.NAME IS NOT NULL
                    THEN
                        PIPE ROW ( L_PLAN_TYPE );
                        L_PLAN_TYPE := NULL;
                    END IF;

                    IF
                        L_GROUP.NAME IS NOT NULL
                    THEN
                        PIPE ROW ( L_GROUP );
                        L_GROUP := NULL;
                    END IF;

                    PIPE ROW ( L_MOD );
                END LOOP;

            END LOOP;

        END LOOP;
    END USER_NOT_GRANTED_ACCESSES;

    FUNCTION USER_GRANTED_ACCESSES (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_USER_ID     VARCHAR2
    ) RETURN T_ACCESSES_TREE
        PIPELINED
    IS
        L_PLAN_TYPE   T_TREE_NODE;
        L_GROUP       T_TREE_NODE;
        L_MOD         T_TREE_NODE;
    BEGIN

      -- get plan types
        FOR PLAN_TYPE IN (
            SELECT
                PT.PT_DESC,
                P.PL_TYPE
            FROM
                PLAN_TYPES PT,
                TBL_PLAN P
            WHERE
                P.PL_ID = P_PLAN_ID
                AND   P.PL_CLIENT_ID = P_CLIENT_ID
                AND   PT.PT_ID = P.PL_TYPE
            GROUP BY
                P.PL_TYPE,
                PT.PT_DESC
            ORDER BY
                PT_DESC
        ) LOOP
            L_PLAN_TYPE := NULL;
            L_PLAN_TYPE.NAME := PLAN_TYPE.PT_DESC;
            L_PLAN_TYPE.CODE := PLAN_TYPE.PL_TYPE;

        -- get user groups
            FOR USER_GROUP IN (
                SELECT
                    GROUP_DESC,
                    GROUPID
                FROM
                    USER_GROUPS UG
                WHERE
                    G_CLIENT_ID = P_CLIENT_ID
                    AND   G_PLAN_TYPE = PLAN_TYPE.PL_TYPE
                    AND   (
                        SELECT
                            COUNT(*)
                        FROM
                            APEX_ACCESS_CONTROL
                        WHERE
                            CLIENT_ID = P_CLIENT_ID
                            AND   USER_ID = P_USER_ID
                            AND   EMP_MEMBER_ID IS NULL
                            AND   GROUP_ID = UG.GROUPID
                            AND   PLAN_ID = P_PLAN_ID
                    ) > 0
                GROUP BY
                    GROUP_DESC,
                    GROUPID
                ORDER BY
                    GROUP_DESC
            ) LOOP
                L_GROUP := NULL;
                L_GROUP.NAME := USER_GROUP.GROUP_DESC;
                L_GROUP.CODE := PLAN_TYPE.PL_TYPE
                || '|'
                || USER_GROUP.GROUPID;
                L_GROUP.PARENT_CODE := PLAN_TYPE.PL_TYPE;
                L_GROUP.PLAN_ID := P_PLAN_ID;
                L_GROUP.GROUP_ID := USER_GROUP.GROUPID;

          -- get group modules
                FOR MODULES IN (
                    SELECT
                        GET_MODULE_DESC(UG.G_MODULE) DESCRIPTION,
                        UG.G_MODULE
                    FROM
                        USER_GROUPS UG
                    WHERE
                        UG.GROUPID = USER_GROUP.GROUPID
                        AND   UG.G_CLIENT_ID = P_CLIENT_ID
                        AND   UG.G_PLAN_TYPE = PLAN_TYPE.PL_TYPE
                    ORDER BY
                        DESCRIPTION
                ) LOOP
                    L_MOD := NULL;
                    L_MOD.NAME := MODULES.DESCRIPTION;
                    L_MOD.CODE := PLAN_TYPE.PL_TYPE
                    || '|'
                    || USER_GROUP.GROUPID
                    || '|'
                    || MODULES.G_MODULE;

                    L_MOD.PARENT_CODE := PLAN_TYPE.PL_TYPE
                    || '|'
                    || USER_GROUP.GROUPID;
                    IF
                        L_PLAN_TYPE.NAME IS NOT NULL
                    THEN
                        PIPE ROW ( L_PLAN_TYPE );
                        L_PLAN_TYPE := NULL;
                    END IF;

                    IF
                        L_GROUP.NAME IS NOT NULL
                    THEN
                        PIPE ROW ( L_GROUP );
                        L_GROUP := NULL;
                    END IF;

                    PIPE ROW ( L_MOD );
                END LOOP;

            END LOOP;

        END LOOP;
    END USER_GRANTED_ACCESSES;

    PROCEDURE GRANT_USER_ACCESS (
        P_CLIENT_ID   VARCHAR2,
        P_USER_ID     VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_GROUP_ID    VARCHAR2
    )
        IS
    BEGIN
      -- check whether this access already exists
        FOR A IN (
            SELECT
                NULL
            FROM
                APEX_ACCESS_CONTROL
            WHERE
                CLIENT_ID = P_CLIENT_ID
                AND   USER_ID = P_USER_ID
                AND   EMP_MEMBER_ID IS NULL
                AND   PLAN_ID = P_PLAN_ID
                AND   GROUP_ID = P_GROUP_ID
        ) LOOP
            RETURN;
        END LOOP;
      -- insert new access

        INSERT INTO APEX_ACCESS_CONTROL (
            CLIENT_ID,
            USER_ID,
            PLAN_ID,
            GROUP_ID
        ) VALUES (
            P_CLIENT_ID,
            P_USER_ID,
            P_PLAN_ID,
            P_GROUP_ID
        );

    END GRANT_USER_ACCESS;

    PROCEDURE REVOKE_USER_ACCESS (
        P_CLIENT_ID   VARCHAR2,
        P_USER_ID     VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_GROUP_ID    VARCHAR2
    )
        IS
    BEGIN
        DELETE APEX_ACCESS_CONTROL
        WHERE
            CLIENT_ID = P_CLIENT_ID
            AND   USER_ID = P_USER_ID
            AND   EMP_MEMBER_ID IS NULL
            AND   PLAN_ID = P_PLAN_ID
            AND   GROUP_ID = P_GROUP_ID;

    END REVOKE_USER_ACCESS;

    FUNCTION GET_MODULE_DESC (
        P_MODULE_ID VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        FOR M IN (
            SELECT
                DESCRIPTION
            FROM
                PLAN_MODULE_DESC
            WHERE
                MODULE_ID = P_MODULE_ID
        ) LOOP
            RETURN M.DESCRIPTION;
        END LOOP;

        RETURN P_MODULE_ID;
    END GET_MODULE_DESC;

    FUNCTION GET_GROUP_DETAILS (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_GROUP_ID    VARCHAR2
    ) RETURN T_GROUPS_AUTH
        PIPELINED
    IS
        L_GROUP   T_GROUP_AUTH;
        L_ID      VARCHAR2(255);
    BEGIN
        IF
            P_GROUP_ID IS NULL
        THEN
            RETURN;
        END IF;
        FOR G IN (
            SELECT
                GROUPID,
                GROUP_DESC,
                PT_DESC,
                PKG_OLIVER_AUTH.GET_MODULE_DESC(G_MODULE) MODULE_DESC,
                DECODE(G_LEVEL,'R','Read-Only','E','Edit','C','Create') PERMISSION_LEVEL,
                G_PLAN_TYPE,
                UG.ROWID
            FROM
                USER_GROUPS UG
                LEFT JOIN PLAN_TYPES ON PT_ID = G_PLAN_TYPE
            WHERE
                TO_CHAR(GROUPID) LIKE NVL(P_GROUP_ID,'%')
                AND   TO_CHAR(G_CLIENT_ID) = P_CLIENT_ID
                AND   G_PLAN_TYPE IN (
                    SELECT
                        PL_TYPE
                    FROM
                        TBL_PLAN
                    WHERE
                        PL_CLIENT_ID = P_CLIENT_ID
                        AND   PL_ID = P_PLAN_ID
                )
            ORDER BY
                GROUP_DESC,
                G_PLAN_TYPE,
                MODULE_DESC
        ) LOOP
            IF
                L_ID IS NULL OR ( L_ID <> ( G.GROUP_DESC
                || G.G_PLAN_TYPE ) )
            THEN
                L_ID := G.GROUP_DESC
                || G.G_PLAN_TYPE;
                L_GROUP.GROUP_ID := G.GROUPID;
                L_GROUP.GROUP_DESC := G.GROUP_DESC;
                L_GROUP.PLAN_TYPE := G.PT_DESC;
            ELSE
                L_GROUP.GROUP_ID := NULL;
                L_GROUP.GROUP_DESC := NULL;
                L_GROUP.PLAN_TYPE := NULL;
            END IF;

            L_GROUP.MODULE_DESC := G.MODULE_DESC;
            L_GROUP.PERMISSION_LEVEL := G.PERMISSION_LEVEL;
            L_GROUP.GROUP_ROWID := ROWIDTOCHAR(G.ROWID);
            PIPE ROW ( L_GROUP );
        END LOOP;

    END GET_GROUP_DETAILS;

    FUNCTION AUTHORIZE (
        P_PLAN_ID     VARCHAR2,
        P_CLIENT_ID   VARCHAR2,
        P_USER_ID     NUMBER,
        P_APP_ID      NUMBER,
        P_PAGE_ID     NUMBER,
        P_COMP_TYPE   VARCHAR2,
        P_COMP_ID     NUMBER
    ) RETURN BOOLEAN IS

        L_PAGE_NAME    VARCHAR2(255);
        L_STATIC_ID    VARCHAR2(255);
        L_MODULE       VARCHAR2(30);
        L_GROUP_TYPE   VARCHAR2(30);
        L_PLAN_TYPE    VARCHAR2(30);
    BEGIN

      -- dealing with navigation list entries
        IF
            P_COMP_TYPE = 'APEX_APPLICATION_LIST_ENTRIES'
        THEN

        -- module value (MEM, PEN, etc) is stored in the 'entry_attribute_01' for navigation list entries.
            FOR R IN (
                SELECT
                    ENTRY_ATTRIBUTE_01 ATTRIBUTE
                FROM
                    APEX_APPLICATION_LIST_ENTRIES
                WHERE
                    APPLICATION_ID = P_APP_ID
                    AND   LIST_ENTRY_ID = P_COMP_ID
            ) LOOP
                FOR A IN (
                    SELECT
                        LEVEL,
                        REGEXP_SUBSTR(R.ATTRIBUTE,'[^_]+',1,LEVEL) VALUE
                    FROM
                        DUAL
                    CONNECT BY
                        REGEXP_SUBSTR(R.ATTRIBUTE,'[^_]+',1,LEVEL) IS NOT NULL
                    ORDER BY
                        LEVEL
                ) LOOP
                    -- get the associated module, e.g., static id "MEM_PEN" => MEM
                    IF
                        A.LEVEL = 1
                    THEN
                        L_MODULE := A.VALUE;
                    ELSIF A.LEVEL = 2 THEN
                    -- get the associated plan_group_type, e.g., static id "MEM_PEN" => PEN
                        L_GROUP_TYPE := A.VALUE;
                    END IF;
                END LOOP;
            END LOOP;

        -- if the list doesn't belong to any existent module,grant access and leave

            IF
                L_MODULE IS NULL
            THEN
                RETURN TRUE;
            END IF;

        -- look for access to the module
            FOR U IN (
                SELECT
                    NULL
                FROM
                    USERS
                WHERE
                    USER_ID = P_USER_ID
                    AND   CLIENT_ID = P_CLIENT_ID
                    AND   SYSDATE BETWEEN USER_EFFECTIVE_DATE AND NVL(USER_TERMINATION_DATE,SYSDATE)
            ) LOOP
                FOR PT IN (
                    SELECT
                        P.PL_TYPE
                    FROM
                        PLAN_TYPES PLT,
                        TBL_PLAN P
                    WHERE
                        P.PL_ID = P_PLAN_ID
                        AND   P.PL_CLIENT_ID = P_CLIENT_ID
                        AND   PLT.PT_ID = P.PL_TYPE
                        AND   (
                            L_GROUP_TYPE IS NULL
                            OR    PLT.PT_GROUP_TYPE = L_GROUP_TYPE
                        )
                ) LOOP
                    FOR AC IN (
                        SELECT
                            GROUP_ID
                        FROM
                            APEX_ACCESS_CONTROL AAC
                        WHERE
                            AAC.USER_ID = P_USER_ID
                            AND   AAC.PLAN_ID = P_PLAN_ID
                            AND   AAC.CLIENT_ID = P_CLIENT_ID
                    ) LOOP
                        FOR UG IN (
                            SELECT
                                NULL
                            FROM
                                USER_GROUPS UG
                            WHERE
                                UG.GROUPID = AC.GROUP_ID
                                AND   UG.G_PLAN_TYPE = PT.PL_TYPE
                                AND   UG.G_CLIENT_ID = P_CLIENT_ID
                                AND   UG.G_MODULE = L_MODULE
                        ) LOOP          
                    -- found access
                            RETURN TRUE;
                        END LOOP;
                    END LOOP;
                END LOOP;
            END LOOP;

        -- no access was found

            RETURN FALSE;

      -- dealing with pages
        ELSIF P_COMP_TYPE = 'APEX_APPLICATION_PAGES' THEN

        -- get page_name
            FOR P IN (
                SELECT
                    PAGE_NAME
                FROM
                    APEX_APPLICATION_PAGES
                WHERE
                    APPLICATION_ID = P_APP_ID
                    AND   PAGE_ID = P_PAGE_ID
            ) LOOP
                L_PAGE_NAME := P.PAGE_NAME;
            END LOOP;

        -- if the page name doesn't exist,grant access and leave

            IF
                L_PAGE_NAME IS NULL
            THEN
                RETURN TRUE;
            END IF;

        -- get all the page's associated modules,e.g.,page name "MEM_EMP" => MEM->Member,EMP->Employer
            FOR M IN (
                WITH MS AS (
                    SELECT
                        REGEXP_SUBSTR(L_PAGE_NAME,'[^_]+',1,LEVEL) MODULE_ID
                    FROM
                        DUAL
                    CONNECT BY
                        REGEXP_SUBSTR(L_PAGE_NAME,'[^_]+',1,LEVEL) IS NOT NULL
                ) SELECT
                    PM.PM_MODULE
                  FROM
                    MS,
                    PLAN_MODULES PM
                  WHERE
                    PM.PM_MODULE = MS.MODULE_ID
            ) LOOP

          -- records the last found module
                L_MODULE := M.PM_MODULE;

          -- look for access to the module
                FOR U IN (
                    SELECT
                        NULL
                    FROM
                        USERS
                    WHERE
                        USER_ID = P_USER_ID
                        AND   CLIENT_ID = P_CLIENT_ID
                        AND   SYSDATE BETWEEN USER_EFFECTIVE_DATE AND NVL(USER_TERMINATION_DATE,SYSDATE)
                ) LOOP
                    FOR PT IN (
                        SELECT
                            P.PL_TYPE
                        FROM
                            PLAN_TYPES PLT,
                            TBL_PLAN P
                        WHERE
                            P.PL_ID = P_PLAN_ID
                            AND   P.PL_CLIENT_ID = P_CLIENT_ID
                            AND   PLT.PT_ID = P.PL_TYPE
                    ) LOOP
                        FOR AC IN (
                            SELECT
                                GROUP_ID
                            FROM
                                APEX_ACCESS_CONTROL AAC
                            WHERE
                                AAC.USER_ID = P_USER_ID
                                AND   AAC.PLAN_ID = P_PLAN_ID
                                AND   AAC.CLIENT_ID = P_CLIENT_ID
                        ) LOOP
                            FOR UG IN (
                                SELECT
                                    NULL
                                FROM
                                    USER_GROUPS UG
                                WHERE
                                    UG.GROUPID = AC.GROUP_ID
                                    AND   UG.G_PLAN_TYPE = PT.PL_TYPE
                                    AND   UG.G_CLIENT_ID = P_CLIENT_ID
                                    AND   UG.G_MODULE = L_MODULE
                            ) LOOP          
                        -- found access
                                RETURN TRUE;
                            END LOOP;
                        END LOOP;
                    END LOOP;
                END LOOP;

            END LOOP;

        -- if the page doesn't belong to any existent module then grant access and leave
        -- else deny access to the page because all associated modules have no granted access

            IF
                L_MODULE IS NULL
            THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;

      -- dealing with page regions
        ELSIF P_COMP_TYPE = 'APEX_APPLICATION_PAGE_REGIONS' THEN

        -- get the region's static id
            FOR R IN (
                SELECT
                    STATIC_ID
                FROM
                    APEX_APPLICATION_PAGE_REGIONS
                WHERE
                    APPLICATION_ID = P_APP_ID
                    AND   PAGE_ID = P_PAGE_ID
                    AND   REGION_ID = P_COMP_ID
            ) LOOP
                L_STATIC_ID := TRIM(R.STATIC_ID);
            END LOOP;
        -- if the static_id is null, grant access and leave

            IF
                L_STATIC_ID IS NULL OR L_STATIC_ID LIKE '%_AUTHORIZED'
            THEN
                RETURN TRUE;
            END IF;

        -- parse the static id
            FOR S IN (
                SELECT
                    LEVEL,
                    REGEXP_SUBSTR(L_STATIC_ID,'[^_]+',1,LEVEL) VALUE
                FROM
                    DUAL
                CONNECT BY
                    REGEXP_SUBSTR(L_STATIC_ID,'[^_]+',1,LEVEL) IS NOT NULL
                ORDER BY
                    LEVEL
            ) LOOP
                IF
                    S.LEVEL = 1
                THEN
                -- get the region's associated module, e.g., static id "MEM_PEN_GB" => MEM
                    L_MODULE := S.VALUE;
                ELSIF S.LEVEL = 2 THEN
                -- get the region's associated plan_group_type, e.g., static id "MEM_PEN_GB" => PEN
                    L_GROUP_TYPE := S.VALUE;
                ELSIF S.LEVEL = 3 THEN
                -- get the region's associated plan_type, e.g., static id "MEM_PEN_GB" => GB
                    L_PLAN_TYPE := S.VALUE;
                END IF;
            END LOOP;

        -- if the region has no associated module then grant access and leave

            IF
                L_MODULE IS NULL
            THEN
                RETURN TRUE;
            END IF;

        -- check if the user has access granted
            FOR U IN (
                SELECT
                    NULL
                FROM
                    USERS
                WHERE
                    USER_ID = P_USER_ID
                    AND   CLIENT_ID = P_CLIENT_ID
                    AND   SYSDATE BETWEEN USER_EFFECTIVE_DATE AND NVL(USER_TERMINATION_DATE,SYSDATE)
            ) LOOP
                FOR PT IN (
                    SELECT
                        P.PL_TYPE
                    FROM
                        PLAN_TYPES PLT,
                        TBL_PLAN P
                    WHERE
                        P.PL_ID = P_PLAN_ID
                        AND   P.PL_CLIENT_ID = P_CLIENT_ID
                        AND   PLT.PT_ID = P.PL_TYPE
                        AND   (
                            L_GROUP_TYPE IS NULL
                            OR    PLT.PT_GROUP_TYPE = L_GROUP_TYPE
                        )
                        AND   (
                            L_PLAN_TYPE IS NULL
                            OR    P.PL_TYPE = L_PLAN_TYPE
                        )
                ) LOOP
                    FOR AC IN (
                        SELECT
                            GROUP_ID
                        FROM
                            APEX_ACCESS_CONTROL AAC
                        WHERE
                            AAC.USER_ID = P_USER_ID
                            AND   AAC.PLAN_ID = P_PLAN_ID
                            AND   AAC.CLIENT_ID = P_CLIENT_ID
                    ) LOOP
                        FOR UG IN (
                            SELECT
                                NULL
                            FROM
                                USER_GROUPS UG
                            WHERE
                                UG.GROUPID = AC.GROUP_ID
                                AND   UG.G_PLAN_TYPE = PT.PL_TYPE
                                AND   UG.G_CLIENT_ID = P_CLIENT_ID
                                AND   UG.G_MODULE = L_MODULE
                        ) LOOP          
                    -- found access
                            RETURN TRUE;
                        END LOOP;
                    END LOOP;
                END LOOP;
            END LOOP;

        -- no access was found

            RETURN FALSE;

      -- dealing with page buttons
        ELSIF P_COMP_TYPE = 'APEX_APPLICATION_BUTTONS' THEN

        -- get the button's static id
            FOR B IN (
                SELECT
                    BUTTON_STATIC_ID
                FROM
                    APEX_APPLICATION_PAGE_BUTTONS
                WHERE
                    APPLICATION_ID = P_APP_ID
                    AND   PAGE_ID = P_PAGE_ID
                    AND   BUTTON_ID = P_COMP_ID
            ) LOOP
                L_STATIC_ID := TRIM(B.BUTTON_STATIC_ID);
            END LOOP;

        -- if the static_id is null, grant access and leave
            IF
                L_STATIC_ID IS NULL OR L_STATIC_ID LIKE '%_AUTHORIZED'
            THEN
                RETURN TRUE;
            END IF;

        -- parse the static id
            FOR S IN (
                SELECT
                    LEVEL,
                    REGEXP_SUBSTR(L_STATIC_ID,'[^_]+',1,LEVEL) VALUE
                FROM
                    DUAL
                CONNECT BY
                    REGEXP_SUBSTR(L_STATIC_ID,'[^_]+',1,LEVEL) IS NOT NULL
                ORDER BY
                    LEVEL
            ) LOOP
                IF
                    S.LEVEL = 1
                THEN
                -- get the button's associated module, e.g., static id "MEM_PEN_GB" => MEM
                    L_MODULE := S.VALUE;
                ELSIF S.LEVEL = 2 THEN
                -- get the button's associated plan_group_type, e.g., static id "MEM_PEN_GB" => PEN
                    L_GROUP_TYPE := S.VALUE;
                ELSIF S.LEVEL = 3 THEN
                -- get the button's associated plan_type, e.g., static id "MEM_PEN_GB" => GB
                    L_PLAN_TYPE := S.VALUE;
                END IF;
            END LOOP;

        -- if the button has no associated module then grant access and leave
            IF
                L_MODULE IS NULL
            THEN
                RETURN TRUE;
            END IF;

        -- check if the user has access granted
            FOR U IN (
                SELECT
                    NULL
                FROM
                    USERS
                WHERE
                    USER_ID = P_USER_ID
                    AND   CLIENT_ID = P_CLIENT_ID
                    AND   SYSDATE BETWEEN USER_EFFECTIVE_DATE AND NVL(USER_TERMINATION_DATE,SYSDATE)
            ) LOOP
                FOR PT IN (
                    SELECT
                        P.PL_TYPE
                    FROM
                        PLAN_TYPES PLT,
                        TBL_PLAN P
                    WHERE
                        P.PL_ID = P_PLAN_ID
                        AND   P.PL_CLIENT_ID = P_CLIENT_ID
                        AND   PLT.PT_ID = P.PL_TYPE
                        AND   (
                            L_GROUP_TYPE IS NULL
                            OR    PLT.PT_GROUP_TYPE = L_GROUP_TYPE
                        )
                        AND   (
                            L_PLAN_TYPE IS NULL
                            OR    P.PL_TYPE = L_PLAN_TYPE
                        )
                ) LOOP
                    FOR AC IN (
                        SELECT
                            GROUP_ID
                        FROM
                            APEX_ACCESS_CONTROL AAC
                        WHERE
                            AAC.USER_ID = P_USER_ID
                            AND   AAC.PLAN_ID = P_PLAN_ID
                            AND   AAC.CLIENT_ID = P_CLIENT_ID
                    ) LOOP
                        FOR UG IN (
                            SELECT
                                NULL
                            FROM
                                USER_GROUPS UG
                            WHERE
                                UG.GROUPID = AC.GROUP_ID
                                AND   UG.G_PLAN_TYPE = PT.PL_TYPE
                                AND   UG.G_CLIENT_ID = P_CLIENT_ID
                                AND   UG.G_MODULE = L_MODULE
                        ) LOOP          
                    -- found access
                            RETURN TRUE;
                        END LOOP;
                    END LOOP;
                END LOOP;
            END LOOP;

        -- no access was found
            RETURN FALSE;

        END IF;

      -- in case it isn't a page,region or navigation list entry
        RETURN TRUE;

    END AUTHORIZE;

    PROCEDURE AUDIT_ACCESS (
        P_CLIENT_ID     VARCHAR2,
        P_USER_NAME     VARCHAR2,
        P_AUTH_RESULT   VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
    /* by Alexey --this table will be realated with audit_apex_activity_log which contans history of all apex logs
      -- purge data older than 30 days
        DELETE app_access_audit WHERE
            audit_date < SYSDATE - 30;
      -- create audit row
*/
        INSERT INTO APP_ACCESS_AUDIT (
            CLIENT_ID,
            USER_NAME,
            AUTH_RESULT,
            AUDIT_DATE,
            HTTP_HOST,
            HTTP_PORT,
            HTTP_REFERER,
            HTTP_USER_AGENT,
            PATH_INFO,
            REMOTE_ADDR,
            REMOTE_USER,
            REQUEST_METHOD,
            REQUEST_PROTOCOL,
            LOGIN_USERNAME_COOKIE,
            SESSION_ID
        ) VALUES (
            UPPER(P_CLIENT_ID),
            P_USER_NAME,
            P_AUTH_RESULT,
            SYSDATE,
            OWA_UTIL.GET_CGI_ENV('HTTP_HOST'),
            OWA_UTIL.GET_CGI_ENV('HTTP_PORT'),
            OWA_UTIL.GET_CGI_ENV('HTTP_REFERER'),
            OWA_UTIL.GET_CGI_ENV('HTTP_USER_AGENT'),
            OWA_UTIL.GET_CGI_ENV('PATH_INFO'),
            OWA_UTIL.GET_CGI_ENV('REMOTE_ADDR'),
            OWA_UTIL.GET_CGI_ENV('REMOTE_USER'),
            OWA_UTIL.GET_CGI_ENV('REQUEST_METHOD'),
            OWA_UTIL.GET_CGI_ENV('REQUEST_PROTOCOL'),
            APEX_AUTHENTICATION.GET_LOGIN_USERNAME_COOKIE,
            V('APP_SESSION')
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END AUDIT_ACCESS;

    PROCEDURE SEND_PASSWORD_UPDATED_EMAIL (
        P_EMAIL       IN VARCHAR2,
        P_CLIENT_ID   IN VARCHAR2
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
            USERS
        WHERE
            UPPER(EMAIL) = UPPER(P_EMAIL)
            AND   CLIENT_ID = P_CLIENT_ID;

        APEX_DEBUG.MESSAGE(P_MESSAGE => 'Oliver - Password Change',P_LEVEL => 3);
        L_BODY := '<p>Hi,</p>
            <p>Your Oliver password was updated.</p>
             <p>If you did not make this change, please alert the system Administrator.</p>
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
        || '<p>Your Oliver password was updated.</p>'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '<p>If you did not make this change, please alert your System Administrator.</p>'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '  Kind Regards,<br />'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '  <span class="sig">The Oliver Team</span><br />'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '</body></html>';
        IF
            V_EMAIL_EXISTS = 'Y'
        THEN
            APEX_MAIL.SEND(P_TO => P_EMAIL,P_FROM => 'admin@cdatsystems.com',P_BODY => L_BODY,P_BODY_HTML => L_BODY_HTML,P_SUBJ => 'Oliver - Password Change'
);

            APEX_MAIL.PUSH_QUEUE;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002,'Issue sending password changed email.');
    END SEND_PASSWORD_UPDATED_EMAIL;

    PROCEDURE SEND_CREATION_EMAIL (
        P_EMAIL       IN VARCHAR2,
        P_URL         IN VARCHAR2,
        P_CLIENT_ID   IN VARCHAR2
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
            USERS
        WHERE
            UPPER(EMAIL) = UPPER(P_EMAIL)
            AND   CLIENT_ID = P_CLIENT_ID;

      /*apex_debug.message(p_message => 'Creation of Oliver account',p_level => 3);*/

        L_BODY := '<p>Hi,</p>
          <p>An Oliver account has been created for you.</p>
           <p><a href="'
        || P_URL
        || '"><button type="button">Create Password</button></a></p>
           <p>Please create a password to access the system.</p>
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
        || '<p>An Oliver account has been created for you.</p>'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '<p><a href="'
        || P_URL
        || '"><button type="button">Create Password</button></a></p>'
        || UTL_TCP.CRLF;

        L_BODY_HTML := L_BODY_HTML
        || '<p>If you did not request this, you can simply ignore this email.</p>'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '  Kind regards,<br />'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '  <span class="sig">The Oliver Team</span><br />'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '</body></html>';
        IF
            V_EMAIL_EXISTS = 'Y'
        THEN
            APEX_MAIL.SEND(P_TO => P_EMAIL,P_FROM => 'admin@cdatsystems.com',P_BODY => L_BODY,P_BODY_HTML => L_BODY_HTML,P_SUBJ => 'Creation of Oliver account.'
);

            APEX_MAIL.PUSH_QUEUE;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002,'Issue sending account creation email.');
    END SEND_CREATION_EMAIL;

    PROCEDURE CREATE_INITIAL_PASSWORD (
        P_EMAIL            IN VARCHAR2,
        P_CLIENT_ID        IN VARCHAR2,
        P_RESET_PASSWORD   IN VARCHAR2
    ) IS
        L_ID                  NUMBER;
        L_VERIFICATION_CODE   VARCHAR2(100);
        L_URL                 VARCHAR2(2000);
    BEGIN
  -- First, check to see if the user is in the user table
        SELECT
            USER_ID
        INTO
            L_ID
        FROM
            USERS
        WHERE
            UPPER(EMAIL) = UPPER(P_EMAIL)
            AND   CLIENT_ID = P_CLIENT_ID;

        DBMS_RANDOM.INITIALIZE(TO_CHAR(SYSDATE,'YYMMDDDSS') );
        L_VERIFICATION_CODE := DBMS_RANDOM.STRING('A',20);

        /*l_url := apex_util.prepare_url(p_url => c_hostname
        || 'f?p='
        || v('APP_ID')
        || ':89:0::::P89_ID,P89_VC:'
        || l_id
        || ','
        || l_verification_code,p_checksum_type => 3); */

     /* l_url := c_hostname
        || apex_page.get_url(p_page => 89,p_session => 0, p_items => 'P89_ID,P89_VC',p_values => ''
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
        || ':89:0::NO::P89_ID,P89_VC:'
        || L_ID
        || ','
        || L_VERIFICATION_CODE;

        UPDATE USERS
            SET
                VERIFICATION_CODE = L_VERIFICATION_CODE
        WHERE
            USER_ID = L_ID;

        IF
            P_RESET_PASSWORD = 'Y'
        THEN
            SEND_RESET_PASSWORD_EMAIL(P_EMAIL => P_EMAIL,P_URL => L_URL,P_CLIENT_ID => P_CLIENT_ID);
        ELSIF P_RESET_PASSWORD = 'N' THEN
            SEND_CREATION_EMAIL(P_EMAIL => P_EMAIL,P_URL => L_URL,P_CLIENT_ID => P_CLIENT_ID);
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END CREATE_INITIAL_PASSWORD;

    PROCEDURE CHANGE_PASSWORD (
        P_CLIENT_ID    VARCHAR2,
        P_EMAIL        VARCHAR2,
        P_PASSWORD     VARCHAR2,
        P_SEND_EMAIL   BOOLEAN
    )
        IS
    BEGIN
        FOR U IN (
            SELECT
                ROWID,
                USER_NAME,
                USER_ID
            FROM
                USERS
            WHERE
                CLIENT_ID = P_CLIENT_ID
                AND   UPPER(EMAIL) = UPPER(P_EMAIL)
        ) LOOP

        -- update users table
            UPDATE USERS
                SET
                    PASSWORD = P_PASSWORD
            WHERE
                ROWID = U.ROWID;

        -- purge data older than 30 days

            DELETE FROM APP_PASSWORD_AUDIT
            WHERE
                AUDIT_DATE < SYSDATE - 30;

        -- log the password change

            INSERT INTO APP_PASSWORD_AUDIT (
                CLIENT_ID,
                CHANGED_USER,
                CHANGED_BY,
                AUDIT_DATE
            ) VALUES (
                P_CLIENT_ID,
                P_EMAIL,
                V('APP_USER'),
                SYSDATE
            );

        -- send notification email

            IF
                P_SEND_EMAIL
            THEN
                SEND_PASSWORD_UPDATED_EMAIL(P_EMAIL,P_CLIENT_ID);
            END IF;
        END LOOP;
    END CHANGE_PASSWORD;

    PROCEDURE SEND_RESET_PASSWORD_EMAIL (
        P_EMAIL       IN VARCHAR2,
        P_URL         IN VARCHAR2,
        P_CLIENT_ID   IN VARCHAR2
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
            USERS
        WHERE
            UPPER(EMAIL) = UPPER(P_EMAIL)
            AND   CLIENT_ID = P_CLIENT_ID;

     /*apex_debug.message(p_message => 'Reset of Oliver account password',p_level => 3);*/

        L_BODY := '<p>Hi,</p>
         <p>A request has been made to reset your password.</p>
          <p><a href="'
        || P_URL
        || '"><button type="button">Reset Password</button></a></p>
          <p>Please reset your password to access the system.</p>
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
        || '<p>A request has been made to reset your password.</p>'
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
        || '  Kind regards,<br />'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '  <span class="sig">The Oliver Team</span><br />'
        || UTL_TCP.CRLF;
        L_BODY_HTML := L_BODY_HTML
        || '</body></html>';
        IF
            V_EMAIL_EXISTS = 'Y'
        THEN
            APEX_MAIL.SEND(P_TO => P_EMAIL,P_FROM => 'admin@cdatsystems.com',P_BODY => L_BODY,P_BODY_HTML => L_BODY_HTML,P_SUBJ => 'Reset of Oliver account password.'
);

            APEX_MAIL.PUSH_QUEUE;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002,'Issue sending reset password email.');
    END SEND_RESET_PASSWORD_EMAIL;

    FUNCTION IS_USER_ADMIN (
        P_CLIENT_ID VARCHAR2,
        P_EMAIL VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        FOR U IN (
            SELECT
                NVL(ISADMIN,'N') IS_ADMIN
            FROM
                USERS
            WHERE
                CLIENT_ID = P_CLIENT_ID
                AND   LOWER(EMAIL) = LOWER(P_EMAIL)
        ) LOOP
            RETURN U.IS_ADMIN;
        END LOOP;
      -- user not found

        RETURN NULL;
    END IS_USER_ADMIN;

    PROCEDURE UNAVAILABLE_MESSAGE
        IS
    BEGIN
        HTP.P('
        <center>Sorry, we are currently unavailable due to a programmed maintenance.</center>
        <p><strong><center>Do not worry though, Rao is doing something to get us back soon. We''ll let you know when it''s back online.</center></strong></p>
        <br><br>
        <center><img src="https://cdn.mos.cms.futurecdn.net/9vkE5D4ytKM8So2A75Ekbk-970-80.jpg" height="400" width="700"></center>

        <br><br>
        <center><button onclick="joke();" id="joke-button-id">tell me a joke</button></center>
        <br>
        <center><div id="joke-div-id" style="color: fuchsia;"></div></center>

        <script>
          function getJoke(){
            var Httpreq = new XMLHttpRequest(); // a new request
            Httpreq.open("GET","https://api.icndb.com/jokes/random",false);
            Httpreq.send(null);
            return Httpreq.responseText;          
          }

          function joke() {
            var json_obj = JSON.parse(getJoke());
            document.getElementById("joke-div-id").innerHTML = json_obj.value.joke;
            document.getElementById("joke-button-id").innerHTML = "tell me another joke";
          }
        </script>
      '
);
    END UNAVAILABLE_MESSAGE;

    procedure audit_logout is
    begin
      for a in (
        select rowid
          from app_access_audit
         where session_id = v('APP_SESSION')
           and user_name = v('APP_USER')
      ) loop
        update app_access_audit
           set logout_time = sysdate
         where rowid = a.rowid;
      end loop;
    end audit_logout;

    function user_has_access(p_client_id varchar2, p_plan_id varchar2, p_email varchar2, p_module varchar2) return varchar2 is
    begin
      for g in (
        select c.group_id
          from apex_access_control c, users u
         where u.client_id = p_client_id
           and u.email = p_email
           and c.client_id = u.client_id
           and c.plan_id = p_plan_id
           and c.user_id = u.user_id
      ) loop
        for p in (
          select pl_type
            from tbl_plan
           where pl_client_id = p_client_id
             and pl_id = p_plan_id
        ) loop
          for a in (
            select null
              from user_groups
             where g_client_id = p_client_id
               and g_plan_type = p.pl_type
               and groupid = g.group_id
               and g_module = p_module
          ) loop
            return 'Write';
          end loop;
        end loop;
      end loop;
      return 'No Access';
    end user_has_access;

END PKG_OLIVER_AUTH;

/

