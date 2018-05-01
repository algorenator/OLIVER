--
-- GET_SALARY  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.GET_SALARY (
    CLIENT1   VARCHAR2,
    PL        VARCHAR2,
    ID1       VARCHAR2,
    BENEFIT   VARCHAR2,
    DT        DATE
) RETURN VARCHAR2 IS
    SAL   NUMBER(12,2) := 0;
BEGIN
    BEGIN
        SELECT
            NVL(TEH_SALARY,0)
        INTO
            SAL
        FROM
            TBL_EMPLOYMENT_HIST
        WHERE
            TEH_CLIENT = CLIENT1
            AND   TEH_PLAN = PL
            AND   TEH_ID = ID1
            AND   TEH_EFF_DATE = (
                SELECT
                    MAX(TEH_EFF_DATE)
                FROM
                    TBL_EMPLOYMENT_HIST
                WHERE
                    TEH_CLIENT = CLIENT1
                    AND   TEH_PLAN = PL
                    AND   TEH_ID = ID1
                    AND   TEH_EFF_DATE <= DT
            );

    EXCEPTION
        WHEN OTHERS THEN
            SELECT
                MAX(NVL(TEH_SALARY,0) )
            INTO
                SAL
            FROM
                TBL_EMPLOYMENT_HIST
            WHERE
                TEH_CLIENT = CLIENT1
                AND   TEH_PLAN = PL
                AND   TEH_ID = ID1
                AND   TEH_EFF_DATE = (
                    SELECT
                        MAX(TEH_EFF_DATE)
                    FROM
                        TBL_EMPLOYMENT_HIST
                    WHERE
                        TEH_CLIENT = CLIENT1
                        AND   TEH_PLAN = PL
                        AND   TEH_ID = ID1
                        AND   TEH_EFF_DATE <= DT
                )
                AND   TEH_TREM_DATE IS NULL;

    END;

    RETURN SAL;
END;
/

