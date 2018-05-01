--
-- GET_NAME  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.GET_NAME (
    P_PLAN     VARCHAR2,
    P_ID       VARCHAR2,
    P_DEP_NO   INTEGER
) RETURN VARCHAR2 AS
    V_NAME   VARCHAR2(100);
BEGIN
    IF
        NVL(P_DEP_NO,0) = 0
    THEN  --get name from member 
        SELECT
            MEM_FIRST_NAME
            || ' '
            || MEM_LAST_NAME
        INTO
            V_NAME
        FROM
            TBL_MEMBER
        WHERE
            MEM_PLAN = P_PLAN
            AND   MEM_ID = P_ID;

    ELSE
        SELECT
            HD_FIRST_NAME
            || ' '
            || HD_LAST_NAME
        INTO
            V_NAME
        FROM
            TBL_HW_DEPENDANTS
        WHERE
            HD_PLAN = P_PLAN
            AND   HD_ID = P_ID
            AND   HD_BEN_NO = P_DEP_NO;

    END IF;

    RETURN V_NAME;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END GET_NAME;
/

