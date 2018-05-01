--
-- GET_EMPLOYER_LATEST  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.GET_EMPLOYER_LATEST (
    CLTID   VARCHAR2,
    PLID    VARCHAR2,
    EEID    VARCHAR2,
    MTH     DATE
) RETURN VARCHAR2 IS
    R    VARCHAR2(100);
    PT   TBL_PLAN.PL_TYPE%TYPE;
BEGIN
    SELECT
        MAX(PL_TYPE)
    INTO
        PT
    FROM
        TBL_PLAN
    WHERE
        PL_CLIENT_ID = CLTID
        AND   PL_ID = PLID;

    IF
        PLID IS NOT NULL AND PT IS NOT NULL
    THEN
        IF
            PT IN (
                'HB',
                'GB',
                'HW',
                'ADJ',
                'HSA'
            )
        THEN
            R := HR_BANK_PKG.GET_EMPLOYER(CLTID,PLID,EEID,MTH);
        ELSE
            R := PENSION_PKG.GET_PEN_EMPLOYER(CLTID,PLID,EEID,MTH);
        END IF;

    END IF;

    IF
        R IS NULL
    THEN
        SELECT
            MAX(A.TEH_ER_ID)
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

        IF
            R IS NULL
        THEN
            SELECT
                MAX(A.TD_EMPLOYER)
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

        IF
            R IS NULL
        THEN
            SELECT
                MAX(A.TD_EMPLOYER)
            INTO
                R
            FROM
                TRANSACTION_DETAIL A
            WHERE
                A.TD_MEM_ID = EEID
                AND   A.TD_CLIENT_ID = CLTID
                AND   A.TD_PLAN_ID = PLID
                AND   NVL(A.TDT_PEN_UNITS,0) > 0
                AND   TRUNC(A.TD_PERIOD,'MM') = (
                    SELECT
                        MAX(TRUNC(B.TD_PERIOD,'MM') )
                    FROM
                        TRANSACTION_DETAIL B
                    WHERE
                        B.TD_CLIENT_ID = CLTID
                        AND   B.TD_PLAN_ID = PLID
                        AND   B.TD_MEM_ID = EEID
                        AND   TRUNC(B.TD_PERIOD,'MM') <= MTH
                        AND   NVL(TDT_PEN_UNITS,0) > 0
                )
            ORDER BY
                TD_MEM_ID;

        END IF;

    END IF;

    RETURN R;
END GET_EMPLOYER_LATEST;
/

