--
-- GET_UNION_LATEST  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.GET_UNION_LATEST (
    CLTID   VARCHAR2,
    PLID    VARCHAR2,
    EEID    VARCHAR2,
    MTH     DATE
) RETURN VARCHAR2 IS
    R   VARCHAR2(100);
BEGIN
    SELECT
        MAX(A.TEH_UNION_LOCAL)
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
                AND   B.TEH_PLAN = PLID
                AND   B.TEH_ID = EEID
                AND   TEH_EFF_DATE <= MTH
        )
    ORDER BY
        TEH_ID;

    RETURN R;
END GET_UNION_LATEST;
/

