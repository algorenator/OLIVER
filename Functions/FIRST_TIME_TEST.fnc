--
-- FIRST_TIME_TEST  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.FIRST_TIME_test (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN VARCHAR2 IS
        CNT   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO
            CNT
        FROM
            TBL_HR_BANK
        WHERE
            THB_CLIENT_ID = CLT_ID
            AND   THB_PLAN = PL_ID
            AND   THB_ID = EE_ID
            AND   NVL(THB_DEDUCT_HRS,0) > 0
            AND   THB_MONTH < ADD_MONTHS(MTH,-2)
        ORDER BY
            THB_ID;

        IF
            NVL(CNT,0) > 0
        THEN
            RETURN 'N';
        ELSE
            RETURN 'Y';
        END IF;

    END FIRST_TIME_test;
/

