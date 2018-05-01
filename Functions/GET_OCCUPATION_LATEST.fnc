--
-- GET_OCCUPATION_LATEST  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.GET_OCCUPATION_LATEST (
    CLTID   VARCHAR2,
    PLID    VARCHAR2,
    EEID    VARCHAR2,
    MTH     DATE
) RETURN VARCHAR2 IS
    R    VARCHAR2(100);
    PT   TBL_PLAN.PL_TYPE%TYPE;
BEGIN
    SELECT
        MAX(A.TEH_OCCU)
    INTO
        R
    FROM
        TBL_EMPLOYMENT_HIST A
    WHERE
        A.TEH_CLIENT = CLTID
        AND   A.TEH_PLAN = PLID
        AND   A.TEH_ID = EEID
        AND   A.TEH_EFF_DATE = (
            SELECT
                MAX(B.TEH_EFF_DATE)
            FROM
                TBL_EMPLOYMENT_HIST B
            WHERE
                B.TEH_CLIENT = CLTID
                AND   B.TEH_ID = EEID
                AND   B.TEH_PLAN = PLID
                AND   TEH_EFF_DATE <= MTH
        )
    ORDER BY
        TEH_ID;

    IF
        R IS NULL
    THEN
        SELECT
            MAX(A.TD_OCCU)
        INTO
            R
        FROM
            TRANSACTION_DETAIL A
        WHERE
            A.TD_CLIENT_ID = CLTID
            AND   A.TD_PLAN_ID = PLID
            AND   A.TD_MEM_ID = EEID
            AND   TRUNC(A.TD_PERIOD,'MM') = (
                SELECT
                    MAX(TRUNC(B.TD_PERIOD,'MM') )
                FROM
                    TRANSACTION_DETAIL B
                WHERE
                    B.TD_CLIENT_ID = CLTID
                    AND   B.TD_MEM_ID = EEID
                    AND   B.TD_PLAN_ID = PLID
                    AND   TRUNC(B.TD_PERIOD,'MM') <= MTH
            )
        ORDER BY
            TD_MEM_ID;

    END IF;
    /*
    if  R IS NULL THEN
        SELECT MAX(A.TD_OCCU) INTO R FROM TRANSACTION_DETAIL A WHERE A.TD_CLIENT_ID=CLT_ID  AND A.TD_PLAN_ID=PLID AND A.TD_MEM_ID=EEID  AND NVL(A.TDT_PEN_UNITS,0)>0 AND TRUNC(A.TD_PERIOD,'MM')=(SELECT MAX(TRUNC(B.TD_PERIOD,'MM')) FROM TRANSACTION_DETAIL B WHERE B.TD_MEM_ID=EEID AND B.TD_PLAN_ID=PLID AND TRUNC(B.TD_PERIOD,'MM')<=MTH AND NVL(TDT_PEN_UNITS,0)>0) ORDER BY TD_MEM_ID;
    END IF;
     */

    RETURN R;
END GET_OCCUPATION_LATEST;
/

