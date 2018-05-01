--
-- OLIVER_AUTH  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.OLIVER_AUTH (
    PL_ID1      VARCHAR2,
    CL_ID       VARCHAR2,
    P_USER_ID   NUMBER,
    PNAME       VARCHAR2,
    CNAME       VARCHAR2,
    CTYPE       VARCHAR2,
    CID         VARCHAR2
) RETURN BOOLEAN AS

    C1           VARCHAR2(3000);
    C2           VARCHAR2(3000);
    C            VARCHAR2(3000);
    CNT          NUMBER;
    MODULE1      VARCHAR2(1000);
    PAGE1        VARCHAR2(1000);
    COMPONENT1   VARCHAR2(100);
BEGIN
    C := NULL;
    MODULE1 := NULL;
    IF
        CNAME IS NOT NULL AND MODULE1 IS NULL
    THEN
        IF
            UPPER(CNAME) LIKE '%MEMBER%'
        THEN
            MODULE1 := 'MEM';
        ELSIF UPPER(CNAME) LIKE '%EMPLOYER%' THEN
            MODULE1 := 'EMP';
        ELSIF UPPER(CNAME) LIKE '%DATA%INPUT%' THEN
            MODULE1 := 'DIM';
        ELSIF UPPER(CNAME) LIKE '%CLAIM%' THEN
            MODULE1 := 'CLM';
      --ELSIF UPPER(cname) LIKE '%CLIENT%' THEN
      --MODULE1:='CLT';
        ELSIF UPPER(CNAME) LIKE '%ADMIN%' THEN
            MODULE1 := 'ADMN';
        ELSIF UPPER(CNAME) LIKE '%REPORTS%' OR UPPER(CNAME) LIKE '%RPT%' THEN
            MODULE1 := 'RPT';
        ELSIF UPPER(CNAME) LIKE '%PEN%' THEN
            MODULE1 := 'PEN';
        ELSIF UPPER(CNAME) LIKE '%HSA%' THEN
            MODULE1 := 'HSA';
        ELSIF UPPER(CNAME) LIKE '%CARRIER%' AND UPPER(CTYPE) LIKE '%LIST%' THEN
            MODULE1 := 'CARRIER';
        ELSIF UPPER(CNAME) LIKE '%VISION%' AND UPPER(CTYPE) LIKE '%LIST%' THEN
            MODULE1 := 'CLM';
        ELSIF UPPER(CNAME) LIKE '%DOCU%' THEN
            MODULE1 := 'DOC';
        ELSIF UPPER(CNAME) LIKE '%REMIT%' THEN
            MODULE1 := 'DIM';
        ELSIF UPPER(CNAME) LIKE '%ACCOUNT%' THEN
            MODULE1 := 'ADMN';
        ELSIF UPPER(CNAME) LIKE '%AGREEMENTS%' THEN
            MODULE1 := 'AGMT';
            DBMS_OUTPUT.PUT_LINE('testing3'
            || MODULE1
            || ' '
            || CNAME);
        ELSIF UPPER(CNAME) LIKE '%HSA%' THEN
            MODULE1 := 'HSA';
      -- PAGE1:='VISION';
      --ELSIF UPPER(CNAME) LIKE '%DASHBOARD%' OR UPPER(CNAME) LIKE '%DBD%' THEN
        ELSIF CTYPE = 'APEX_APPLICATION_LIST_ENTRIES' THEN
            MODULE1 := CNAME;
        ELSE
            MODULE1 := NULL;
        END IF;
    END IF;
--IF PID IS NOT NULL AND CID IS NOT NULL AND UPPER(CTYPE) LIKE '%PAGE%REGION%' THEN
--SELECT MAX(COMPONENT_COMMENT) INTO C FROM APEX_APPLICATION_PAGE_ITEMS  WHERE  PAGE_ID=PID AND REGION_ID=CID;
--ELSIF PID IS NOT NULL THEN

    IF
        MODULE1 IS NULL AND CNAME IS NOT NULL
    THEN
        MODULE1 := SUBSTR(CNAME,1,INSTR(CNAME,'_') - 1);

        PAGE1 := SUBSTR(CNAME,INSTR(CNAME,'_',-1) + 1);

    END IF;
--MODULE1:='MEM';

    IF
        CTYPE = 'APEX_APPLICATION_PAGE_REGIONS' AND CID IS NOT NULL
    THEN
  -- select PARENT_REGION_NAME INTO COMPONENT1  from APEX_APPLICATION_PAGE_REGIONS WHERE PARENT_REGION_ID=CID;
        SELECT
            STATIC_ID
        INTO
            COMPONENT1
        FROM
            APEX_APPLICATION_PAGE_REGIONS
        WHERE
            REGION_ID = CID;

        MODULE1 := SUBSTR(COMPONENT1,1,INSTR(COMPONENT1,'_') - 1);

        PAGE1 := SUBSTR(COMPONENT1,INSTR(COMPONENT1,'_',2) + 1);

        COMPONENT1 := SUBSTR(COMPONENT1,INSTR(COMPONENT1,'_',-1) + 1);

    ELSE
        COMPONENT1 := NULL;
    END IF;

--IF module1     ='DBD' AND upper(cname) LIKE '%VISION%' THEN
 -- cnt         :=0;
--els

    IF
        MODULE1 IS NOT NULL
    THEN
        DBMS_OUTPUT.PUT_LINE('modanme '
        || MODULE1);
        SELECT
            COUNT(*)
        INTO
            CNT
        FROM
            PLAN_MODULES
        WHERE
            PM_ID IN (
                SELECT
                    PL_TYPE
                FROM
                    TBL_PLAN
                WHERE
                    UPPER(PL_ID1) LIKE '%'
                    || UPPER(PL_ID)
                    || '%'
                    AND   PL_CLIENT_ID = CL_ID
            )
            AND   PM_MODULE LIKE '%'
            || MODULE1
            || '%';

        DBMS_OUTPUT.PUT_LINE(CNT);
        IF
            NVL(CNT,0) > 0
        THEN
            SELECT
                COUNT(*)
            INTO
                CNT
            FROM
                APEX_ACCESS_CONTROL,
                USERS,
                PLAN_TYPES,
                TBL_PLAN,
                USER_GROUPS
            WHERE
                PT_ID = PL_TYPE
    --AND pt_group_type                = upper(NVL(component1,pt_group_type))
                AND   G_CLIENT_ID = CL_ID
                AND   GROUPID = GROUP_ID
                AND   G_PLAN_TYPE = PL_TYPE
                AND   PL_CLIENT_ID = CL_ID
                AND   PL_ID = PL_ID1
                AND   PLAN_ID = PL_ID1
                AND   APEX_ACCESS_CONTROL.CLIENT_ID = CL_ID
                AND   UPPER(PL_ID1) LIKE '%'
                || UPPER(APEX_ACCESS_CONTROL.PLAN_ID)
                || '%'
                AND   USERS.USER_ID = P_USER_ID
                AND   APEX_ACCESS_CONTROL.USER_ID = P_USER_ID
                AND   USERS.CLIENT_ID = APEX_ACCESS_CONTROL.CLIENT_ID
                AND   EXISTS (
                    SELECT
                        G_MODULE
                    FROM
                        USER_GROUPS
                    WHERE
                        USER_GROUPS.G_CLIENT_ID = CL_ID
                        AND   G_PLAN_TYPE = PL_TYPE
                        AND   USER_GROUPS.GROUPID = GROUP_ID
                        AND   UPPER(NVL(G_MODULE,MODULE1) ) LIKE '%'
                        || UPPER(MODULE1)
                        || '%'
                        AND   UPPER(NVL(MODULE_ID,MODULE1) ) LIKE '%'
                        || UPPER(MODULE1)
                        || '%'
                        AND   ( UPPER(NVL(PAGE1,PT_GROUP_TYPE) ) LIKE '%'
                        || UPPER(NVL(PT_GROUP_TYPE,'%') )
                        || '%' )
                        AND   (
                            UPPER(NVL(G_COMPONENT,'Y') ) NOT LIKE '%'
                            || UPPER(NVL(COMPONENT1,'X') )
                            || '%'
                            OR    COMPONENT1 = PAGE1
                        )
                )
                AND   SYSDATE BETWEEN USER_EFFECTIVE_DATE AND NVL(USER_TERMINATION_DATE,SYSDATE);
    --cnt:=1;

        ELSE
            CNT := 0;
        END IF;

    ELSE
        CNT := 1;
    END IF;

    IF
        NVL(CNT,0) = 0
    THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
/*
IF upper(nvl(C,'xxx')) LIKE '%ADMN%' or upper(nvl(C,'xxx')) LIKE '%CLM%' OR upper(nvl(C,'xxx')) LIKE '%EDIT%'THEN
RETURN FALSE;
ELSE
RETURN TRUE;
END IF
*/

EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END OLIVER_AUTH;
/

