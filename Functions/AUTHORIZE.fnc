--
-- AUTHORIZE  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.AUTHORIZE (
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
/

