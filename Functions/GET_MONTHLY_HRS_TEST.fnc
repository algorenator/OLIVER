--
-- GET_MONTHLY_HRS_TEST  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.GET_MONTHLY_HRS_test (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN NUMBER AS
        MONTHLY_HRS   NUMBER(12,2) := 0;
        MC            TBL_HW.HW_MEM_CATEGORY%TYPE;
    BEGIN
        MONTHLY_HRS := 0;
        IF
            EE_ID IS NOT NULL
        THEN
            SELECT
                NVL(MAX(HW_MEM_CATEGORY),'M')
            INTO
                MC
            FROM
                TBL_HW
            WHERE
                HW_ID = EE_ID
                AND   HW_PLAN = PL_ID;

            IF
                NVL(MC,'M') <> 'M'
            THEN
                SELECT
                    NVL(MAX(A.PHBCR_MONTHLY_HRS),0)
                INTO
                    MONTHLY_HRS
                FROM
                    TBL_PLAN_HR_BANK_CLASS_RATES A
                WHERE
                    A.PHBCR_PLAN = PL_ID
                    AND   PHBCR_CLASS = MC
                    AND   NVL(A.PHBCR_MONTHLY_HRS,0) > 0
                    AND   A.PHBCR_EFF_DATE = (
                        SELECT
                            MAX(B.PHBCR_EFF_DATE)
                        FROM
                            TBL_PLAN_HR_BANK_CLASS_RATES B
                        WHERE
                            B.PHCR_CLIENT_ID = CLT_ID
                            AND   B.PHBCR_PLAN = PL_ID
                            AND   PHBCR_CLASS = MC
                            AND   B.PHBCR_EFF_DATE <= MTH
                            AND   NVL(B.PHBCR_MONTHLY_HRS,0) > 0
                    );

            END IF;

        END IF;

        IF
            NVL(MONTHLY_HRS,0) = 0
        THEN
            BEGIN
                IF
                    ER_ID IS NOT NULL
                THEN
                    SELECT
                        A.EHBR_MONTHLY_HRS
                    INTO
                        MONTHLY_HRS
                    FROM
                        TBL_EMPLOYER_HR_BANK_RATES A
                    WHERE
                        A.EHBR_PLAN = PL_ID
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
                        A.PHBR_MONTHLY_HRS
                    INTO
                        MONTHLY_HRS
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
                                B.PHBR_CLIENT_ID = CLT_ID
                                AND   B.PHBR_PLAN = PL_ID
                                AND   B.PHBR_EFF_DATE <= MTH
                                AND   NVL(B.PHBR_MONTHLY_HRS,0) > 0
                        );

                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    SELECT
                        A.PHBR_MONTHLY_HRS
                    INTO
                        MONTHLY_HRS
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
                                B.PHBR_CLIENT_ID = CLT_ID
                                AND   B.PHBR_PLAN = PL_ID
                                AND   B.PHBR_EFF_DATE <= MTH
                                AND   NVL(B.PHBR_MONTHLY_HRS,0) > 0
                        );

            END;
        END IF;

        RETURN MONTHLY_HRS;
    END GET_MONTHLY_HRS_test;
/

