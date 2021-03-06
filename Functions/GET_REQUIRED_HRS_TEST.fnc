--
-- GET_REQUIRED_HRS_TEST  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.GET_REQUIRED_HRS_test (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN NUMBER AS

        MIN_HRS       NUMBER(12,2) := 0;
        MONTHLY_HRS   NUMBER(12,2) := 0;
    BEGIN
        BEGIN
            IF
                ER_ID IS NOT NULL
            THEN
                SELECT
                    A.EHBR_MIN_HRS,
                    A.EHBR_MONTHLY_HRS
                INTO
                    MIN_HRS,MONTHLY_HRS
                FROM
                    TBL_EMPLOYER_HR_BANK_RATES A
                WHERE
                    A.EHB_CLIENT_ID = CLT_ID
                    AND   A.EHBR_PLAN = PL_ID
                    AND   A.ENBR_EMPLOYER = ER_ID
                    AND   NVL(A.EHBR_MONTHLY_HRS,0) > 0
                    AND   A.EHBR_EFF_DATE = (
                        SELECT
                            MAX(B.EHBR_EFF_DATE)
                        FROM
                            TBL_EMPLOYER_HR_BANK_RATES B
                        WHERE
                            B.EHB_CLIENT_ID = CLT_ID
                            AND   B.EHBR_PLAN = PL_ID
                            AND   B.ENBR_EMPLOYER = ER_ID
                            AND   NVL(B.EHBR_MONTHLY_HRS,0) > 0
                            AND   B.EHBR_EFF_DATE <= MTH
                    );

            ELSE
                SELECT
                    A.PHBR_MIN_HRS,
                    A.PHBR_MONTHLY_HRS
                INTO
                    MIN_HRS,MONTHLY_HRS
                FROM
                    TBL_PLAN_HR_BANK_RATES A
                WHERE
                    A.PHBR_CLIENT_ID = CLT_ID
                    AND   A.PHBR_PLAN = PL_ID
                    AND   NVL(A.PHBR_MONTHLY_HRS,0) > 0
                    AND   A.PHBR_EFF_DATE = (
                        SELECT
                            MAX(B.PHBR_EFF_DATE)
                        FROM
                            TBL_PLAN_HR_BANK_RATES B
                        WHERE
                            B.PHBR_PLAN = PL_ID
                            AND   B.PHBR_CLIENT_ID = CLT_ID
                            AND   B.PHBR_EFF_DATE <= MTH
                            AND   NVL(B.PHBR_MONTHLY_HRS,0) > 0
                    );

            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                BEGIN
                    SELECT
                        A.PHBR_MIN_HRS,
                        A.PHBR_MONTHLY_HRS
                    INTO
                        MIN_HRS,MONTHLY_HRS
                    FROM
                        TBL_PLAN_HR_BANK_RATES A
                    WHERE
                        A.PHBR_CLIENT_ID = CLT_ID
                        AND   A.PHBR_PLAN = PL_ID
                        AND   NVL(A.PHBR_MONTHLY_HRS,0) > 0
                        AND   A.PHBR_EFF_DATE = (
                            SELECT
                                MAX(B.PHBR_EFF_DATE)
                            FROM
                                TBL_PLAN_HR_BANK_RATES B
                            WHERE
                                B.PHBR_PLAN = PL_ID
                                AND   B.PHBR_EFF_DATE <= MTH
                                AND   NVL(B.PHBR_MONTHLY_HRS,0) > 0
                        );

                EXCEPTION
                    WHEN OTHERS THEN
  --SELECT A.PHBR_MIN_HRS,A.PHBR_MONTHLY_HRS INTO MIN_HRS,MONTHLY_HRS  FROM TBL_PLAN_HR_BANK_RATES A WHERE A.PHBR_PLAN=PL_ID AND  NVL(A.PHBR_MONTHLY_HRS,0)>0 AND  A.PHBR_EFF_DATE=(SELECT MAX(B.PHBR_EFF_DATE) FROM TBL_PLAN_HR_BANK_RATES B WHERE B.PHBR_PLAN=PL_ID AND B.PHBR_EFF_DATE<=MTH AND  NVL(B.PHBR_MONTHLY_HRS,0)>0);
                        MIN_HRS := 99999;
                        MONTHLY_HRS := 99999;
                END;
        END;

        IF
            FIRST_TIME_test(CLT_ID,PL_ID,ER_ID,EE_ID,MTH) = 'Y'
        THEN
            RETURN MIN_HRS;
        ELSE
            RETURN MONTHLY_HRS;
        END IF;

    END GET_REQUIRED_HRS_test;
/

