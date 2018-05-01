--
-- CREATE_ANNUAL_BLANK_RECORDS_PATCH  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.CREATE_ANNUAL_BLANK_RECORDS_PATCH (
    CLT_ID   VARCHAR2,
    PL_ID    VARCHAR2,
    ACCT     VARCHAR2,
    YR       NUMBER
) IS

    CURSOR C IS SELECT
        ANN_CLIENT,
        ANN_PLAN,
        ANN_ID,
        ANN_ACCOUNT,
        MIN(ANN_YEAR) YR1
                FROM
        TBL_ANNUAL,
        TBL_PENMAST
                WHERE
        ANN_PLAN LIKE 'MACH1'
        AND   PENM_CLIENT = CLT_ID
        AND   PENM_PLAN = PL_ID
        AND   PENM_ID = ANN_ID
        AND   NVL(PENM_STATUS,'A') IN (
            'C',
            'A',
            'VP'
        )
        AND   ANN_CLIENT = CLT_ID
        AND   ANN_PLAN = PL_ID
        AND   ANN_ACCOUNT = ACCT
        AND   ANN_YEAR <= YR
                GROUP BY
        ANN_CLIENT,
        ANN_PLAN,
        ANN_ID,
        ANN_ACCOUNT;

    REC       C%ROWTYPE;
    ST_YR     NUMBER;
    ANN_CNT   NUMBER;
BEGIN
    OPEN C;
    LOOP
        FETCH C INTO REC;
        EXIT WHEN C%NOTFOUND;
        ST_YR := REC.YR1 + 1;
        LOOP
            IF
                ST_YR > YR
            THEN
                EXIT;
            END IF;
            SELECT
                COUNT(*)
            INTO
                ANN_CNT
            FROM
                TBL_ANNUAL
            WHERE
                ANN_CLIENT = REC.ANN_CLIENT
                AND   ANN_PLAN = REC.ANN_PLAN
                AND   ANN_ID = REC.ANN_ID
                AND   ANN_ACCOUNT = REC.ANN_ACCOUNT
                AND   ANN_YEAR = ST_YR;

            IF
                NVL(ANN_CNT,0) = 0
            THEN
                INSERT INTO TBL_ANNUAL (
                    ANN_CLIENT,
                    ANN_PLAN,
                    ANN_ID,
                    ANN_ACCOUNT,
                    ANN_YEAR
                ) VALUES (
                    REC.ANN_CLIENT,
                    REC.ANN_PLAN,
                    REC.ANN_ID,
                    REC.ANN_ACCOUNT,
                    ST_YR
                );

            END IF;

            ST_YR := ST_YR + 1;
        END LOOP;

    END LOOP;

    CLOSE C;
END;
/

