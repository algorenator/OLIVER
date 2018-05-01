--
-- NEW_OLIVER_AUTH  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.NEW_OLIVER_AUTH (
    P_PLAN_ID     VARCHAR2,
    P_CLIENT_ID   VARCHAR2,
    P_USER_ID     VARCHAR2,
    P_PAGE_ID     VARCHAR2,
    P_COMP_NAME   VARCHAR2,
    P_COMP_TYPE   VARCHAR2,
    P_COMP_ID     VARCHAR2
) RETURN BOOLEAN AS

    V_C            VARCHAR2(3000) := NULL;
    V_CNT          NUMBER := 0;
    V_MODULE1      VARCHAR2(1000) := NULL;
    V_PAGE1        VARCHAR2(1000);
    V_COMPONENT1   VARCHAR2(100);
    V_COMP_NAME    VARCHAR2(100);
BEGIN
    IF
        P_COMP_TYPE = 'APEX_APPLICATION_PAGES'
    THEN
        SELECT
            PAGE_NAME
        INTO
            V_COMP_NAME
        FROM
            APEX_APPLICATION_PAGES
        WHERE
            PAGE_ID = P_PAGE_ID
            AND   APPLICATION_ID = 112;

        DBMS_OUTPUT.PUT_LINE('Page '
        || V_COMP_NAME);
    ELSE
        V_COMP_NAME := P_COMP_NAME;
    END IF;

    IF
        V_COMP_NAME IS NOT NULL
        --v_comp_name is the given name of the page,component,etc.  it is passed from the global  application item :APP_COMPONENT_NAME
        --v_comp_name (:APP_COMPONENT_NAME) is the 'title' of the page for apex pages,not the 'name' of the page.
    THEN
    --grab the module_id (abbreviation) from the plan_module_desc table based on component name.  if a record doesn't exist,there are no restrictions on that component,page,etc.
        FOR M IN (
            SELECT
                TRIM(MODULE_ID) MODULE_ID
            FROM
                PLAN_MODULE_DESC
            WHERE
                UPPER(V_COMP_NAME) LIKE '%'
                || UPPER(MODULE_ID)
                || '%'
        ) LOOP
            V_MODULE1 := M.MODULE_ID;
            DBMS_OUTPUT.PUT_LINE('modanme1 '
            || V_MODULE1);
        END LOOP;

        IF
                --v_module1 IS NULL and
            P_COMP_TYPE = 'APEX_APPLICATION_LIST_ENTRIES'
        THEN
            FOR X IN (
                SELECT
                    TRIM(MODULE_ID) MODULE_ID
                FROM
                    PLAN_MODULE_DESC
                WHERE
                    UPPER(V_MODULE1) LIKE '%'
                    || UPPER(DESCRIPTION)
                    || '%'
            ) LOOP
                V_MODULE1 := X.MODULE_ID;
            END LOOP;

            DBMS_OUTPUT.PUT_LINE('modanme2 '
            || V_MODULE1);
            DBMS_OUTPUT.PUT_LINE('List Item '
            || V_MODULE1);
        END IF;

    END IF;
        --these list entries make up the navigation bar.

    IF
        V_MODULE1 IS NULL AND V_COMP_NAME IS NOT NULL
    THEN
        V_MODULE1 := SUBSTR(V_COMP_NAME,1,INSTR(V_COMP_NAME,'_') - 1);

        V_PAGE1 := SUBSTR(V_COMP_NAME,INSTR(V_COMP_NAME,'_',-1) + 1);

    END IF;

    IF
        P_COMP_TYPE = 'APEX_APPLICATION_PAGE_REGIONS' AND P_COMP_ID IS NOT NULL
            --these are the individual regions on the page
    THEN
        SELECT
            STATIC_ID
        INTO
            V_COMPONENT1
        FROM
            APEX_APPLICATION_PAGE_REGIONS AAPR
        WHERE
            REGION_ID = P_COMP_ID;

        V_MODULE1 := SUBSTR(V_COMPONENT1,1,INSTR(V_COMPONENT1,'_') - 1);

        V_PAGE1 := SUBSTR(V_COMPONENT1,INSTR(V_COMPONENT1,'_',2) + 1);

        V_COMPONENT1 := SUBSTR(V_COMPONENT1,INSTR(V_COMPONENT1,'_',-1) + 1);

    ELSE
        V_COMPONENT1 := NULL;
    END IF;

    IF
        V_MODULE1 IS NOT NULL
    THEN
        DBMS_OUTPUT.PUT_LINE('modanme '
        || V_MODULE1);
    --check to see if this module is allowed within the plan type of this plan and client.  this is the purpose of the plan_module table.
        SELECT
            COUNT(*)
        INTO
            V_CNT
        FROM
            PLAN_MODULES PM
        WHERE
            PM.PM_ID IN (
                SELECT
                    TP.PL_TYPE
                FROM
                    TBL_PLAN TP
                WHERE
                    UPPER(P_PLAN_ID) LIKE '%'
                    || UPPER(TP.PL_ID)
                    || '%'
                    AND   TP.PL_CLIENT_ID = P_CLIENT_ID
            )
            AND   PM.PM_MODULE LIKE '%'
            || V_MODULE1
            || '%';

        DBMS_OUTPUT.PUT_LINE(V_CNT);
        IF
            V_CNT > 0
        THEN
        --if there is a plan module record,now check to see if the user has access to it.
            SELECT
                COUNT(*)
            INTO
                V_CNT
            FROM
                APEX_ACCESS_CONTROL AAC,
                USERS U,
                PLAN_TYPES PT,
                TBL_PLAN TP,
                USER_GROUPS UG
            WHERE
                PT_ID = TP.PL_TYPE
                AND   UG.G_CLIENT_ID = P_CLIENT_ID
                AND   UG.GROUPID = AAC.GROUP_ID
                AND   G_PLAN_TYPE = TP.PL_TYPE
                AND   TP.PL_CLIENT_ID = P_CLIENT_ID
                AND   TP.PL_ID = P_PLAN_ID
                AND   AAC.PLAN_ID = P_PLAN_ID
                AND   AAC.CLIENT_ID = P_CLIENT_ID
                AND   UPPER(P_PLAN_ID) LIKE '%'
                || UPPER(AAC.PLAN_ID)
                || '%'
                AND   U.USER_ID = P_USER_ID
                AND   AAC.USER_ID = P_USER_ID
                AND   U.CLIENT_ID = AAC.CLIENT_ID
                AND   EXISTS (
                    SELECT
                        G_MODULE
                    FROM
                        USER_GROUPS UG
                    WHERE
                        UG.G_CLIENT_ID = P_CLIENT_ID
                        AND   UG.G_PLAN_TYPE = TP.PL_TYPE
                        AND   UG.GROUPID = AAC.GROUP_ID
                        AND   UPPER(NVL(UG.G_MODULE,V_MODULE1) ) LIKE '%'
                        || UPPER(V_MODULE1)
                        || '%'
                        AND   UPPER(NVL(AAC.MODULE_ID,V_MODULE1) ) LIKE '%'
                        || UPPER(V_MODULE1)
                        || '%'
                        AND   ( UPPER(NVL(V_PAGE1,PT_GROUP_TYPE) ) LIKE '%'
                        || UPPER(NVL(PT_GROUP_TYPE,'%') )
                        || '%' )
                        AND   (
                            UPPER(NVL(UG.G_COMPONENT,'Y') ) NOT LIKE '%'
                            || UPPER(NVL(V_COMPONENT1,'X') )
                            || '%'
                            OR    V_COMPONENT1 = V_PAGE1
                        )
                )
                AND   SYSDATE BETWEEN U.USER_EFFECTIVE_DATE AND NVL(U.USER_TERMINATION_DATE,SYSDATE);

        END IF;

    ELSE
    
    --module doesn't exist in the table,which means there is no restriction on it
        V_CNT := 1;
    END IF;

    IF
        V_CNT = 0
    THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END NEW_OLIVER_AUTH;
/

