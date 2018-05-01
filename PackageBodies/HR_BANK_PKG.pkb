--
-- HR_BANK_PKG  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.HR_BANK_PKG AS

    FUNCTION GET_EMPLOYER (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN VARCHAR2 IS
        R   VARCHAR2(100);
    BEGIN
        SELECT
            MAX(HW_EMPLOYER)
        INTO
            R
        FROM
            TBL_HW
        WHERE
            HW_CLIENT = CLT_ID
            AND   HW_PLAN = PL_ID
            AND   HW_ID = EE_ID
        ORDER BY
            HW_PLAN,
            HW_ID;

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
                A.TEH_CLIENT = CLT_ID
                AND   A.TEH_PLAN = PL_ID
                AND   A.TEH_ID = EE_ID
                AND   A.TEH_EFF_DATE = (
                    SELECT
                        MAX(B.TEH_EFF_DATE)
                    FROM
                        TBL_EMPLOYMENT_HIST B
                    WHERE
                        B.TEH_ID = EE_ID
                        AND   B.TEH_PLAN = PL_ID
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
                    A.TD_CLIENT_ID = CLT_ID
                    AND   A.TD_PLAN_ID = PL_ID
                    AND   A.TD_MEM_ID = EE_ID
                    AND   TRUNC(A.TD_PERIOD,'MM') = (
                        SELECT
                            MAX(TRUNC(B.TD_PERIOD,'MM') )
                        FROM
                            TRANSACTION_DETAIL B
                        WHERE
                            B.TD_MEM_ID = EE_ID
                            AND   B.TD_PLAN_ID = PL_ID
                            AND   TRUNC(B.TD_PERIOD,'MM') <= MTH
                    )
                ORDER BY
                    TD_MEM_ID;

            END IF;

        END IF;

        RETURN R;
    END GET_EMPLOYER;

    FUNCTION FIRST_TIME (
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

    END FIRST_TIME;

    FUNCTION FIRST_TIME_ELIGIBLE (
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
            TBL_HR_BANK A
        WHERE
            A.THB_CLIENT_ID = CLT_ID
            AND   A.THB_PLAN = PL_ID
            AND   A.THB_ID = EE_ID
            AND   NVL(A.THB_DEDUCT_HRS,0) > 0
            AND   A.THB_MONTH < ADD_MONTHS(MTH,-2)
        ORDER BY
            THB_ID;

        IF
            NVL(CNT,0) > 0
        THEN
            RETURN 'N';
        ELSE
            SELECT
                COUNT(*)
            INTO
                CNT
            FROM
                TBL_HR_BANK A
            WHERE
                A.THB_CLIENT_ID = CLT_ID
                AND   A.THB_PLAN = PL_ID
                AND   A.THB_ID = EE_ID
                AND   NVL(A.THB_DEDUCT_HRS,0) > 0
                AND   A.THB_MONTH = ADD_MONTHS(MTH,-2)
            ORDER BY
                THB_ID;

            IF
                NVL(CNT,0) > 0
            THEN
                RETURN 'Y';
            ELSE
                RETURN 'N';
            END IF;

        END IF;

    END FIRST_TIME_ELIGIBLE;

    FUNCTION GET_REQUIRED_HRS (
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
            FIRST_TIME(CLT_ID,PL_ID,ER_ID,EE_ID,MTH) = 'Y'
        THEN
            RETURN MIN_HRS;
        ELSE
            RETURN MONTHLY_HRS;
        END IF;

    END GET_REQUIRED_HRS;

    FUNCTION GET_MONTHLY_HRS (
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
    END GET_MONTHLY_HRS;

    FUNCTION GET_MAX_HRS (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN NUMBER AS
        MAX_HRS   NUMBER(12,2) := 0;
    BEGIN
        BEGIN
            IF
                ER_ID IS NOT NULL
            THEN
                SELECT
                    A.EHBR_MAX_HRS
                INTO
                    MAX_HRS
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
                    A.PHBR_MAX_HRS
                INTO
                    MAX_HRS
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
                BEGIN
                    SELECT
                        NVL(MAX(A.PHBR_MAX_HRS),1200)
                    INTO
                        MAX_HRS
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
                        MAX_HRS := 1500;
                END;
        END;

        RETURN MAX_HRS;
    END GET_MAX_HRS;

    FUNCTION IS_ELIGIBLE (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN VARCHAR2 AS
        CNT   NUMBER;
    BEGIN
 --SELECT nvl(sum(thb_deduct_hrs),0) INTO CNT FROM TBL_HR_BANK WHERE THB_PLAN=PL_ID AND THB_ID=EE_ID  AND TRUNC(thb_month,'MM')=TRUNC(add_months(MTH,-2),'MM') group by thb_plan,thb_id,TRUNC(thb_month,'MM')  order by thb_plan,thb_id,TRUNC(thb_month,'MM') desc;
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
            AND   TRUNC(THB_MONTH,'MM') = TRUNC(ADD_MONTHS(MTH,-2),'MM')
            AND   NVL(THB_DEDUCT_HRS,0) > 0;

        IF
            NVL(CNT,0) > 0
        THEN
            RETURN 'Y';
        ELSE
            RETURN 'N';
        END IF;

    END IS_ELIGIBLE;

    PROCEDURE POST_BATCHES (
        CLT_ID     VARCHAR2,
        PL_ID      VARCHAR2,
        USER_ID    VARCHAR2,
        TRAN_ID    VARCHAR2,
        BEN_TYPE   VARCHAR2
    ) IS

        HB_CNT     NUMBER;
        CNT        NUMBER := 0;
        CURSOR TRAN_HEAD (
            PL_ID VARCHAR2,
            USER_ID VARCHAR2
        ) IS SELECT
            THT_EMPLOYER,
            THT_PLAN_ID,
            THT_START_DATE,
            THT_END_DATE,
            THT_PERIOD,
            THT_UNITS,
            THT_RATE,
            THT_AMOUNT,
            THT_PAYMENT_TYPE,
            THT_COMMENT,
            THT_USER,
            THT_DATE_TIME,
            THT_MEM_ID,
            THT_TRAN_ID,
            THT_VARIANCE_AMT,
            THT_CHEQUE,THT_TRAN_LABEL
             FROM
            TRANSACTION_HEADER_TEMP
             WHERE
            UPPER(THT_USER) = UPPER(USER_ID)
            AND   (
                NVL(THT_UNITS,0) <> 0
                OR    NVL(THT_AMOUNT,0) <> 0
            )
            AND   (
                (
                    NVL(THT_POST,'N') = 'P'
                    AND   TRAN_ID IS NULL
                )
                OR    (
                    TRAN_ID IS NOT NULL
                    AND   THT_TRAN_ID = TRAN_ID
                )
            )
        ORDER BY
            THT_PERIOD,
            THT_EMPLOYER;

        HEAD_REC   TRAN_HEAD%ROWTYPE;
        CURSOR TRAN_DET (
            PL_ID     VARCHAR2,
            USER_ID   VARCHAR2,
            TR_ID     VARCHAR2
        ) IS SELECT
            TDT_TRAN_ID,
            TDT_EMPLOYER,
            TDT_PLAN_ID,
            TDT_START_DATE,
            TDT_END_DATE,
            TDT_PERIOD,
            TDT_UNITS,
            TDT_AMOUNT,
            TDT_COMMENT,
            TDT_USER,
            TDT_DATE_TIME,
            TDT_MEM_ID,
            TDT_KEY,
            TDT_FIRST_NAME,
            TDT_LAST_NAME,
            TDT_EE_RATE,
            TDT_ER_RATE,
            TDT_MEM_SIN
             FROM
            TRANSACTION_DETAIL_TEMP
             WHERE
            UPPER(TDT_USER) = UPPER(USER_ID)
            AND   TDT_TRAN_ID = TR_ID
        ORDER BY
            TDT_MEM_ID,
            TDT_PERIOD;

        DET_REC    TRAN_DET%ROWTYPE;
    BEGIN
        OPEN TRAN_HEAD(PL_ID,USER_ID);
        LOOP
            FETCH TRAN_HEAD INTO HEAD_REC;
            EXIT WHEN TRAN_HEAD%NOTFOUND;
            INSERT INTO TRANSACTION_HEADER (
                TH_EMPLOYER,
                TH_PLAN_ID,
                TH_START_DATE,
                TH_END_DATE,
                TH_PERIOD,
                TH_UNITS,
                TH_RATE,
                TH_AMOUNT,
                TH_PAYMENT_TYPE,
                TH_COMMENT,
                TH_USER,
                TH_DATE_TIME,
                TH_MEM_ID,
                TH_TRAN_ID,
                TH_POSTED_DATE,
                TH_POSTED_USER,
                TH_CHEQUE,
                TH_CLIENT_ID,TH_TRAN_LABEL
            ) VALUES (
                HEAD_REC.THT_EMPLOYER,
                HEAD_REC.THT_PLAN_ID,
                HEAD_REC.THT_START_DATE,
                HEAD_REC.THT_END_DATE,
                HEAD_REC.THT_PERIOD,
                HEAD_REC.THT_UNITS,
                HEAD_REC.THT_RATE,
                HEAD_REC.THT_AMOUNT,
                HEAD_REC.THT_PAYMENT_TYPE,
                HEAD_REC.THT_COMMENT,
                HEAD_REC.THT_USER,
                HEAD_REC.THT_DATE_TIME,
                HEAD_REC.THT_MEM_ID,
                HEAD_REC.THT_TRAN_ID,
                --SYSDATE,Commented on 280318
                CURRENT_TIMESTAMP,--CHANGED ON 280318
                USER_ID,
                HEAD_REC.THT_CHEQUE,
                CLT_ID,HEAD_REC.THT_TRAN_LABEL
            );

            UPDATE TBL_COMPHW
                SET
                    CH_OS_BAL = NVL(CH_OS_BAL,0) + NVL(HEAD_REC.THT_VARIANCE_AMT,0)
            WHERE
                CH_PLAN = PL_ID
                AND   CH_NUMBER = HEAD_REC.THT_EMPLOYER;

            OPEN TRAN_DET(PL_ID,USER_ID,HEAD_REC.THT_TRAN_ID);
            LOOP
                FETCH TRAN_DET INTO DET_REC;
                EXIT WHEN TRAN_DET%NOTFOUND;
                SELECT
                    COUNT(*)
                INTO
                    CNT
                FROM
                    TBL_MEMBER
                WHERE
                    MEM_CLIENT_ID = CLT_ID
                    AND   MEM_ID = DET_REC.TDT_MEM_ID
                    AND   MEM_PLAN = PL_ID;

                IF
                    NVL(CNT,0) = 0
                THEN
                    INSERT INTO TBL_MEMBER (
                        MEM_ID,
                        MEM_SIN,
                        MEM_PLAN,
                        MEM_LAST_NAME,
                        MEM_FIRST_NAME,
                        MEM_CLIENT_ID,
                        MEM_CREATED_DATE,
                        MEM_CREATED_BY
                    ) VALUES (
                        DET_REC.TDT_MEM_ID,
                        DET_REC.TDT_MEM_SIN,
                        PL_ID,
                        DET_REC.TDT_LAST_NAME,
                        DET_REC.TDT_FIRST_NAME,
                        CLT_ID,
                        --SYSDATE,--COMMENTED ON 280318
                        CURRENT_TIMESTAMP,
                        USER_ID
                    );

                END IF;

                SELECT
                    COUNT(*)
                INTO
                    CNT
                FROM
                    TBL_HW
                WHERE
                    HW_CLIENT = CLT_ID
                    AND   HW_ID = DET_REC.TDT_MEM_ID
                    AND   HW_PLAN = PL_ID;

                IF
                    NVL(CNT,0) = 0
                THEN
                    INSERT INTO TBL_HW (
                        HW_ID,
                        HW_PLAN,
                        HW_EMPLOYER,
                        HW_EFF_DATE,
                        HW_CLIENT
                    ) VALUES (
                        DET_REC.TDT_MEM_ID,
                        PL_ID,
                        DET_REC.TDT_EMPLOYER,
                        HEAD_REC.THT_PERIOD,
                        CLT_ID
                    );

                ELSE
                    UPDATE TBL_HW
                        SET
                            HW_EMPLOYER = DET_REC.TDT_EMPLOYER
                    WHERE
                        HW_CLIENT = CLT_ID
                        AND   HW_PLAN = PL_ID
                        AND   HW_ID = DET_REC.TDT_MEM_ID;

                END IF;

                INSERT INTO TRANSACTION_DETAIL (
                    TD_TRAN_ID,
                    TD_EMPLOYER,
                    TD_PLAN_ID,
                    TD_START_DATE,
                    TD_END_DATE,
                    TD_PERIOD,
                    TD_UNITS,
                    TD_AMOUNT,
                    TD_COMMENT,
                    TD_USER,
                    TD_DATE_TIME,
                    TD_MEM_ID,
                    TD_KEY,
                    TD_POSTED_DATE,
                    TD_POSTED_USER,
                    TD_CLIENT_ID,
                    TD_ER_RATE,
                    TD_EE_RATE,
                    TD_MEM_SIN
                ) VALUES (
                    DET_REC.TDT_TRAN_ID,
                    DET_REC.TDT_EMPLOYER,
                    PL_ID,
                    HEAD_REC.THT_START_DATE,
                    HEAD_REC.THT_END_DATE,
                    HEAD_REC.THT_PERIOD,
                    DET_REC.TDT_UNITS,
                    DET_REC.TDT_AMOUNT,
                    DET_REC.TDT_COMMENT,
                    DET_REC.TDT_USER,
                    DET_REC.TDT_DATE_TIME,
                    DET_REC.TDT_MEM_ID,
                    DET_REC.TDT_KEY,
                     --SYSDATE,Commented on 280318
                CURRENT_TIMESTAMP,--CHANGED ON 280318
                    USER_ID,
                    CLT_ID,
                    DET_REC.TDT_ER_RATE,
                    DET_REC.TDT_EE_RATE,
                    DET_REC.TDT_MEM_SIN
                );
   
   --SELECT COUNT(*) INTO HB_CNT FROM TBL_HR_BANK WHERE THB_PLAN=PL_ID AND THB_ID=DET_REC.TDT_MEM_ID AND TRUNC(THB_MONTH,'MM')=TRUNC(DET_REC.TDT_PERIOD,'MM');

            END LOOP;

            CLOSE TRAN_DET;
  -- UPDATE TRANSACTION_DETAIL_TEMP SET TDT_POST='Y' WHERE TDT_PLAN_ID=PL_ID AND TDT_USER=USER_ID AND TDT_TRAN_ID=HEAD_REC.THT_TRAN_ID;
        END LOOP;

        CLOSE TRAN_HEAD;
        UPDATE TRANSACTION_HEADER_TEMP
            SET
                --THT_POSTED_DATE = SYSDATE, Commented on 280318
                THT_POSTED_DATE = CURRENT_TIMESTAMP,-- changed 280318
                THT_POST = 'Y'
        WHERE
            THT_CLIENT_ID = CLT_ID
            AND   THT_PLAN_ID = PL_ID
            AND   UPPER(THT_USER) = UPPER(USER_ID)
            AND   (
                (
                    NVL(THT_POST,'N') = 'P'
                    AND   TRAN_ID IS NULL
                )
                OR    (
                    TRAN_ID IS NOT NULL
                    AND   THT_TRAN_ID = TRAN_ID
                )
            );

        COMMIT;
        ELIG_PROC(CLT_ID,PL_ID,'N');   --ADDED ON 09/FEB/2018 BY RAO

--IF  NVL(BEN_TYPE,'X')='P' THEN 
        POST_BATCHES_PEN(CLT_ID,PL_ID,USER_ID,TRAN_ID,BEN_TYPE);
--END IF;
--IF  NVL(BEN_TYPE,'X')='F' THEN
        POST_BATCHES_FUNDS(CLT_ID,PL_ID,USER_ID,TRAN_ID,BEN_TYPE);
--END IF;
        COMMIT;
    END;

    PROCEDURE POST_BATCHES_PEN (
        CLT_ID     VARCHAR2,
        PL_ID      VARCHAR2,
        USER_ID    VARCHAR2,
        TRAN_ID    VARCHAR2,
        BEN_TYPE   VARCHAR2
    ) IS

        HB_CNT     NUMBER;
        CNT        NUMBER := 0;
        CNT1 NUMBER:=0;
        CURSOR TRAN_HEAD (
            CLT_ID    VARCHAR2,
            PL_ID     VARCHAR2,
            USER_ID   VARCHAR2
        ) IS SELECT
            THTP_EMPLOYER,
            THTP_PLAN_ID,
            THTP_START_DATE,
            THTP_END_DATE,
            NVL(THTP_PERIOD,THTP_END_DATE) THTP_PERIOD,
            THTP_UNITS,
            THTP_RATE,
            THTP_AMOUNT,
            THTP_PAYMENT_TYPE,
            THTP_COMMENT,
            THTP_USER,
            THTP_DATE_TIME,
            THTP_MEM_ID,
            THTP_TRAN_ID,
            THTP_VARIANCE_AMT,
            THTP_RECD_AMT,
            THTP_CHEQUE,
            THTP_EE_UNITS,
            THTP_ER_UNITS,
            THTP_VOL_UNITS,
            THTP_EE_ACCOUNT,
            THTP_ER_ACCOUNT,
            THTP_VOL_ACCOUNT,THTP_TRAN_LABEL
             FROM
            TRAN_HEADER_TEMP_PEN
             WHERE
            THT_CLIENT_ID = CLT_ID
            AND   THTP_PLAN_ID = PL_ID
            AND   UPPER(THTP_USER) = UPPER(USER_ID)
            AND   (
                (
                    NVL(THTP_UNITS,0) <> 0
                    OR    NVL(THTP_AMOUNT,0) <> 0
                )
                OR    THTP_UNITS IS NULL
            ) --added to reflect changes for vol, ee and er contributions. 
            AND   (
                (
                    NVL(THTP_POST,'N') = 'P'
                    AND   TRAN_ID IS NULL
                )
                OR    (
                    TRAN_ID IS NOT NULL
                    AND   THTP_TRAN_ID = TRAN_ID
                )
            )
        ORDER BY
            THTP_PERIOD,
            THTP_EMPLOYER;

        HEAD_REC   TRAN_HEAD%ROWTYPE;
        CURSOR TRAN_DET (
            CLT_ID    VARCHAR,
            PL_ID     VARCHAR2,
            USER_ID   VARCHAR2,
            TR_ID     VARCHAR2
        ) IS SELECT
            TDT_TRAN_ID,
            TDT_EMPLOYER,
            TDT_PLAN_ID,
            TDT_START_DATE,
            TDT_END_DATE,
            NVL(TDT_PERIOD,TDT_END_DATE) TDT_PERIOD,
            TDT_PEN_UNITS,
            TDT_AMOUNT,
            TDT_COMMENT,
            TDT_USER,
            TDT_DATE_TIME,
            DECODE(NVL(TDT_RATE,0),0,NVL(TDT_AMOUNT,0) / (DECODE(NVL(TDT_PEN_UNITS,0),0,1,TDT_PEN_UNITS) ),TDT_RATE) TDT_RATE,
            TDT_MEM_ID,
            TDT_KEY,
            TDT_FIRST_NAME,
            TDT_LAST_NAME,
            TDT_OCCU,
            TDT_EE_UNITS,
            TDT_ER_UNITS,
            TDT_VOL_UNITS,
            TDT_ER_RATE,
            TDT_EE_RATE,
            TDT_MEM_SIN
             FROM
            TRANSACTION_DETAIL_TEMP
             WHERE
            TDT_CLIENT_ID = CLT_ID
            AND   TDT_PLAN_ID = PL_ID
            AND   UPPER(TDT_USER) = UPPER(USER_ID)
            AND   TDT_TRAN_ID = TR_ID
        ORDER BY
            TDT_MEM_ID,
            TDT_PERIOD;

        DET_REC    TRAN_DET%ROWTYPE;
        PEN_VAL    NUMBER(12,6) := 0;
        ST  VARCHAR2(10);
        ST_DATE DATE;
    BEGIN
        OPEN TRAN_HEAD(CLT_ID,PL_ID,USER_ID);
        LOOP
            FETCH TRAN_HEAD INTO HEAD_REC;
            EXIT WHEN TRAN_HEAD%NOTFOUND;
            INSERT INTO TRANSACTION_HEADER_PEN (
                THP_EMPLOYER,
                THP_PLAN_ID,
                THP_START_DATE,
                THP_END_DATE,
                THP_PERIOD,
                THP_UNITS,
                THP_RATE,
                THP_AMOUNT,
                THP_PAYMENT_TYPE,
                THP_COMMENT,
                THP_USER,
                THP_DATE_TIME,
                THP_MEM_ID,
                THP_TRAN_ID,
                THP_POSTED_DATE,
                THP_POSTED_USER,
                THP_CHEQUE,
                THP_CLIENT_ID,
                THP_VARIANCE_AMT,
                THP_RECD_AMT,
                THP_EE_UNITS,
                THP_ER_UNITS,
                THP_VOL_UNITS,
                THP_EE_ACCOUNT,
                THP_ER_ACCOUNT,
                THP_VOL_ACCOUNT,THP_TRAN_LABEL
            ) VALUES (
                HEAD_REC.THTP_EMPLOYER,
                HEAD_REC.THTP_PLAN_ID,
                HEAD_REC.THTP_START_DATE,
                HEAD_REC.THTP_END_DATE,
                HEAD_REC.THTP_PERIOD,
                HEAD_REC.THTP_UNITS,
                HEAD_REC.THTP_RATE,
                HEAD_REC.THTP_RECD_AMT,
                HEAD_REC.THTP_PAYMENT_TYPE,
                HEAD_REC.THTP_COMMENT,
                HEAD_REC.THTP_USER,
                HEAD_REC.THTP_DATE_TIME,
                HEAD_REC.THTP_MEM_ID,
                HEAD_REC.THTP_TRAN_ID,
               -- SYSDATE,Commented on 280318
               CURRENT_TIMESTAMP,--changed on 280318
                USER_ID,
                HEAD_REC.THTP_CHEQUE,
                CLT_ID,
                NVL(HEAD_REC.THTP_VARIANCE_AMT,0),
                HEAD_REC.THTP_RECD_AMT,
                HEAD_REC.THTP_EE_UNITS,
                HEAD_REC.THTP_ER_UNITS,
                HEAD_REC.THTP_VOL_UNITS,
                HEAD_REC.THTP_EE_ACCOUNT,
                HEAD_REC.THTP_ER_ACCOUNT,
                HEAD_REC.THTP_VOL_ACCOUNT,HEAD_REC.THTP_TRAN_LABEL
            );

            UPDATE TBL_COMPPEN
                SET
                    CP_OS_BAL = NVL(CP_OS_BAL,0) + NVL(HEAD_REC.THTP_VARIANCE_AMT,0)
            WHERE
                CP_CLIENT = CLT_ID
                AND   CP_PLAN = PL_ID
                AND   CP_NUMBER = HEAD_REC.THTP_EMPLOYER;

            OPEN TRAN_DET(CLT_ID,PL_ID,USER_ID,HEAD_REC.THTP_TRAN_ID);
            LOOP
                FETCH TRAN_DET INTO DET_REC;
                EXIT WHEN TRAN_DET%NOTFOUND;
                SELECT
                    COUNT(*)
                INTO
                    CNT
                FROM
                    TBL_MEMBER
                WHERE
                    MEM_CLIENT_ID = CLT_ID
                    AND   MEM_ID = DET_REC.TDT_MEM_ID
                    AND   MEM_PLAN = PL_ID;

                IF
                    NVL(CNT,0) = 0
                THEN
                    INSERT INTO TBL_MEMBER (
                        MEM_ID,
                        MEM_SIN,
                        MEM_PLAN,
                        MEM_LAST_NAME,
                        MEM_FIRST_NAME,
                        MEM_CLIENT_ID,
                        MEM_CREATED_DATE,
                        MEM_CREATED_BY
                    ) VALUES (
                        DET_REC.TDT_MEM_ID,
                        DET_REC.TDT_MEM_SIN,
                        PL_ID,
                        DET_REC.TDT_LAST_NAME,
                        DET_REC.TDT_FIRST_NAME,
                        CLT_ID,
                        --SYSDATE,COMMENTED ON 280318
                        CURRENT_TIMESTAMP,
                        USER_ID
                    );

                END IF;

                SELECT
                    COUNT(*),MAX(PENM_STATUS),MAX(PENM_STATUS_DATE)
                INTO
                    CNT,ST,ST_DATE
                FROM
                    TBL_PENMAST
                WHERE
                    PENM_CLIENT = CLT_ID
                    AND   PENM_ID = DET_REC.TDT_MEM_ID
                    AND   PENM_PLAN = PL_ID   ;
                    
                SELECT COUNT(*) INTO CNT1 FROM TBL_EMPLOYMENT_HIST
                WHERE TEH_ID=DET_REC.TDT_MEM_ID
                        AND TEH_ER_ID=DET_REC.TDT_EMPLOYER
                        AND TEH_PLAN=PL_ID
                        AND TEH_CLIENT=CLT_ID;

                IF
                    NVL(CNT,0) = 0
                THEN
                ST:='C';
              
                    INSERT INTO TBL_PENMAST (
                        PENM_ID,
                        PENM_PLAN,
                        PENM_EMPLOYER,
                        PENM_ENTRY_DATE,
                        PENM_LRD,
                        PENM_STATUS,
                        PENM_STATUS_DATE,
                        PENM_CLIENT
                    ) VALUES (
                        DET_REC.TDT_MEM_ID,
                        PL_ID,
                        DET_REC.TDT_EMPLOYER,
                        DET_REC.TDT_PERIOD,
                        HEAD_REC.THTP_END_DATE,
                        'C',
                        NVL(HEAD_REC.THTP_START_DATE,HEAD_REC.THTP_PERIOD),
                        CLT_ID
                    );
                    
                INSERT INTO TBL_MEM_PEN_STATUS_HIST(TMPSH_CLIENT,TMPSH_PLAN,TMPSH_MEM_ID,TMPSH_STATUS,TMPSH_STATUS_DATE) VALUES  (CLT_ID,PL_ID,DET_REC.TDT_MEM_ID,'C',NVL(HEAD_REC.THTP_START_DATE,HEAD_REC.THTP_PERIOD));

                    INSERT INTO TBL_EMPLOYMENT_HIST (
                        TEH_ID,
                        TEH_ER_ID,
                        TEH_OCCU,
                        TEH_EFF_DATE,
                        TEH_PROCESS_DATE,
                        TEH_PLAN,
                        TEH_UNION_LOCAL,
                        TEH_CLIENT
                    ) VALUES (
                        DET_REC.TDT_MEM_ID,
                        DET_REC.TDT_EMPLOYER,
                        DET_REC.TDT_OCCU,
                        HEAD_REC.THTP_END_DATE,
                        --SYSDATE,COMMENTED ON 280318
                        CURRENT_TIMESTAMP,
                        PL_ID,
                        NULL,
                        CLT_ID
                    );

                ELSE
                
                IF NVL(CNT1,0)=0 THEN
                INSERT INTO TBL_EMPLOYMENT_HIST (
                        TEH_ID,
                        TEH_ER_ID,
                        TEH_OCCU,
                        TEH_EFF_DATE,
                        TEH_PROCESS_DATE,
                        TEH_PLAN,
                        TEH_UNION_LOCAL,
                        TEH_CLIENT
                    ) VALUES (
                        DET_REC.TDT_MEM_ID,
                        DET_REC.TDT_EMPLOYER,
                        DET_REC.TDT_OCCU,
                        HEAD_REC.THTP_END_DATE,
                        --SYSDATE,COMMENTED ON 280318
                        CURRENT_TIMESTAMP,
                        PL_ID,
                        NULL,
                        CLT_ID
                    );
                    END IF;
                
                
                IF  NVL(ST,'X') NOT IN ('C','A') AND HEAD_REC.THTP_PERIOD>=NVL(ST_DATE,NVL(HEAD_REC.THTP_START_DATE,HEAD_REC.THTP_PERIOD)) THEN
                --INSERT INTO TBL_MEM_PEN_STATUS_HIST(TMPSH_CLIENT,TMPSH_PLAN,TMPSH_MEM_ID,TMPSH_STATUS,TMPSH_STATUS_DATE) VALUES  (CLT_ID,PL_ID,DET_REC.TDT_MEM_ID,ST,ST_DATE); Commented on 160418 by Ramana
                 ST:='C';
                 ST_DATE:=NVL(HEAD_REC.THTP_START_DATE,HEAD_REC.THTP_PERIOD); 
                INSERT INTO TBL_MEM_PEN_STATUS_HIST(TMPSH_CLIENT,TMPSH_PLAN,TMPSH_MEM_ID,TMPSH_STATUS,TMPSH_STATUS_DATE) VALUES  (CLT_ID,PL_ID,DET_REC.TDT_MEM_ID,ST,ST_DATE);--added on 160418
                -- UPDATE TB_PENMAST SET PENM_STATUS='C' ,PENM_STATUS_DATE=HEAD_REC.THTP_START_DATE,PENM_LRD=HEAD_REC.THTP_END_DATE WHERE 
                END IF;
                
                    UPDATE TBL_PENMAST
                        SET
                            PENM_LRD = GREATEST(NVL(PENM_LRD,NVL(HEAD_REC.THTP_END_DATE,HEAD_REC.THTP_PERIOD)),NVL(HEAD_REC.THTP_END_DATE,HEAD_REC.THTP_PERIOD)),
                            PENM_EMPLOYER = DET_REC.TDT_EMPLOYER,PENM_STATUS=ST,PENM_STATUS_DATE=ST_DATE
                    WHERE
                        PENM_CLIENT = CLT_ID
                        AND   PENM_PLAN = PL_ID
                        AND   PENM_ID = DET_REC.TDT_MEM_ID
                        AND   NVL(PENM_LRD,HEAD_REC.THTP_END_DATE - 1) < HEAD_REC.THTP_END_DATE;
        -- UPDATE TBL_PENMAST SET PENM_LRD=GREATEST(NVL(PENM_LRD,HEAD_REC.THTP_END_DATE),HEAD_REC.THTP_END_DATE),penm_employer=TEH_ER_ID  WHERE   PENM_CLIENT=CLT_ID AND PENM_PLAN=PL_ID AND PENM_ID=DET_REC.TDT_MEM_ID;

                END IF;
                
              

                INSERT INTO TRANSACTION_DETAIL (
                    TD_TRAN_ID,
                    TD_EMPLOYER,
                    TD_PLAN_ID,
                    TD_START_DATE,
                    TD_END_DATE,
                    TD_PERIOD,
                    TDT_PEN_UNITS,
                    TD_AMOUNT,
                    TD_COMMENT,
                    TD_USER,
                    TD_DATE_TIME,
                    TD_MEM_ID,
                    TD_KEY,
                    TD_POSTED_DATE,
                    TD_POSTED_USER,
                    TD_CLIENT_ID,
                    TD_RATE,
                    TDT_EE_UNITS,
                    TDT_ER_UNITS,
                    TD_VOL_UNITS,
                    TD_ER_RATE,
                    TD_EE_RATE,
                    TD_MEM_SIN
                ) VALUES (
                    DET_REC.TDT_TRAN_ID,
                    HEAD_REC.THTP_EMPLOYER,
                    PL_ID,
                    HEAD_REC.THTP_START_DATE,
                    HEAD_REC.THTP_END_DATE,
                    HEAD_REC.THTP_PERIOD,
                    DET_REC.TDT_PEN_UNITS,
                    DET_REC.TDT_AMOUNT,
                    DET_REC.TDT_COMMENT,
                    DET_REC.TDT_USER,
                    DET_REC.TDT_DATE_TIME,
                    DET_REC.TDT_MEM_ID,
                    DET_REC.TDT_KEY,
                    -- SYSDATE,Commented on 280318
               CURRENT_TIMESTAMP,--changed on 280318
                    USER_ID,
                    CLT_ID,
                    DET_REC.TDT_RATE,
                    DET_REC.TDT_EE_UNITS,
                    DET_REC.TDT_ER_UNITS,
                    DET_REC.TDT_VOL_UNITS,
                    DET_REC.TDT_ER_RATE,
                    DET_REC.TDT_EE_RATE,
                    DET_REC.TDT_MEM_SIN
                );

   --SELECT COUNT(*) INTO HB_CNT FROM TBL_HR_BANK WHERE THB_PLAN=PL_ID AND THB_ID=DET_REC.TDT_MEM_ID AND TRUNC(THB_MONTH,'MM')=TRUNC(DET_REC.TDT_PERIOD,'MM');

                INSERT INTO TBL_MEM_UNITS (
                    MPU_ID,
                    MPU_PLAN,
                    MPU_UNITS,
                    MPU_FUND,
                    MPU_RATE,
                    MPU_AMT,
                    MPU_FROM,
                    MPU_TO,
                    MPU_PERIOD,
                    MPU_ENTERED_DATE,
                    MPU_EMPLOYER,
                    MPU_USER,
                    MU_BATCH,
                    MU_DESC,
                    MU_CLIENT,
                    MU_EE_UNITS,
                    MU_ER_UNITS,
                    MU_VOL_UNITS,
                    MU_EE_ACCOUNT,
                    MU_ER_ACCOUNT,
                    MU_VOL_ACCOUNT
                ) VALUES (
                    DET_REC.TDT_MEM_ID,
                    PL_ID,
                    DET_REC.TDT_PEN_UNITS,
                    'PEN',
                    DET_REC.TDT_RATE,
                    DET_REC.TDT_AMOUNT,
                    HEAD_REC.THTP_START_DATE,
                    HEAD_REC.THTP_END_DATE,
                    HEAD_REC.THTP_END_DATE,
                    --SYSDATE,COMMENTED ON 280318
                    CURRENT_TIMESTAMP,
                    HEAD_REC.THTP_EMPLOYER,
                    USER_ID,
                    DET_REC.TDT_TRAN_ID,
                    NULL,
                    CLT_ID,
                    DET_REC.TDT_EE_UNITS,
                    DET_REC.TDT_ER_UNITS,
                    DET_REC.TDT_VOL_UNITS,
                    HEAD_REC.THTP_EE_ACCOUNT,
                    HEAD_REC.THTP_ER_ACCOUNT,
                    HEAD_REC.THTP_VOL_ACCOUNT
                );

                SELECT
                    NVL(MAX( (NVL(DET_REC.TDT_PEN_UNITS,0) / TPCF_UNIT_QTY) * NVL(TPCF_RATE,0) ),0)
                INTO
                    PEN_VAL
                FROM
                    TBL_PEN_CALC_FORMULA
                WHERE
                    TPCF_CLIENT = CLT_ID
                    AND   TPCF_PLAN = PL_ID
                    AND   ( HEAD_REC.THTP_END_DATE BETWEEN NVL(TPCF_EFF_DATE,HEAD_REC.THTP_END_DATE) AND NVL(TPCF_TERM_DATE,HEAD_REC.THTP_END_DATE + 1) );

                BEGIN
                    IF
                        NVL(HEAD_REC.THTP_EE_ACCOUNT,'XX') <> 'XX' AND NVL(DET_REC.TDT_EE_UNITS,0) <> 0
                    THEN
                        SELECT
                            COUNT(*)
                        INTO
                            CNT
                        FROM
                            TBL_ANNUAL
                        WHERE
                            ANN_CLIENT = CLT_ID
                            AND   ANN_PLAN = PL_ID
                            AND   ANN_ID = DET_REC.TDT_MEM_ID
                            AND   ANN_YEAR = TO_NUMBER(TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') )
                            AND   NVL(ANN_ACCOUNT,'XX') = NVL(HEAD_REC.THTP_EE_ACCOUNT,'XX')
                            AND ANN_STATUS=ST;

                        IF
                            NVL(CNT,0) > 0
                        THEN
                            UPDATE TBL_ANNUAL
                                SET
                                    ANN_HRS = NVL(ANN_HRS,0) + NVL(DET_REC.TDT_PEN_UNITS,0),
                                    ANN_PEN_VALUE = NVL(ANN_PEN_VALUE,0) + NVL(PEN_VAL,0),
                                    ANN_LRD = GREATEST(ANN_LRD,HEAD_REC.THTP_END_DATE),
                                    ANN_EE_CONTS = NVL(ANN_EE_CONTS,0) + NVL(DET_REC.TDT_EE_UNITS,0)
                            WHERE
                                ANN_PLAN = PL_ID
                                AND   ANN_ID = DET_REC.TDT_MEM_ID
                                AND   ANN_YEAR = TO_NUMBER(TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') )
                                AND   NVL(ANN_ACCOUNT,'XX') = NVL(HEAD_REC.THTP_EE_ACCOUNT,'XX') AND ANN_STATUS=ST;

                        ELSE
                            INSERT INTO TBL_ANNUAL (
                                ANN_ID,
                                ANN_YEAR,
                                ANN_CLIENT,
                                ANN_PLAN,
                                ANN_HRS,
                                ANN_LRD,
                                ANN_PEN_VALUE,
                                ANN_EE_CONTS,
                                ANN_ACCOUNT,ANN_STATUS
                            ) VALUES (
                                DET_REC.TDT_MEM_ID,
                                TO_NUMBER(TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') ),
                                CLT_ID,
                                PL_ID,
                                NVL(DET_REC.TDT_PEN_UNITS,0),
                                PENSION_PKG.GET_PEN_LRD(CLT_ID,PL_ID,DET_REC.TDT_MEM_ID,TO_DATE('31-DEC-'
                                || TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') ) ),
                                NVL(PEN_VAL,0),
                                NVL(DET_REC.TDT_EE_UNITS,0),
                                HEAD_REC.THTP_EE_ACCOUNT,ST
                            );

                        END IF;

                    END IF;

                    IF
                        NVL(HEAD_REC.THTP_ER_ACCOUNT,'XX') <> 'XX' AND NVL(DET_REC.TDT_ER_UNITS,0) <> 0
                    THEN
                        SELECT
                            COUNT(*)
                        INTO
                            CNT
                        FROM
                            TBL_ANNUAL
                        WHERE
                            ANN_CLIENT = CLT_ID
                            AND   ANN_PLAN = PL_ID
                            AND   ANN_ID = DET_REC.TDT_MEM_ID
                            AND   ANN_YEAR = TO_NUMBER(TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') )
                            AND   NVL(ANN_ACCOUNT,'XX') = NVL(HEAD_REC.THTP_ER_ACCOUNT,'XX')
                            AND ANN_STATUS=ST;
                            
                        IF
                            NVL(CNT,0) > 0
                        THEN
                            UPDATE TBL_ANNUAL
                                SET
                                    ANN_HRS = NVL(ANN_HRS,0) + NVL(DET_REC.TDT_PEN_UNITS,0),
                                    ANN_PEN_VALUE = NVL(ANN_PEN_VALUE,0) + NVL(PEN_VAL,0),
                                    ANN_LRD = GREATEST(ANN_LRD,HEAD_REC.THTP_END_DATE),
                                    ANN_ER_CONTS = NVL(ANN_ER_CONTS,0) + NVL(DET_REC.TDT_ER_UNITS,0)
                            WHERE
                                ANN_PLAN = PL_ID
                                AND   ANN_ID = DET_REC.TDT_MEM_ID
                                AND   ANN_YEAR = TO_NUMBER(TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') )
                                AND   NVL(ANN_ACCOUNT,'XX') = NVL(HEAD_REC.THTP_ER_ACCOUNT,'XX')   AND ANN_STATUS=ST;

                        ELSE
                            INSERT INTO TBL_ANNUAL (
                                ANN_ID,
                                ANN_YEAR,
                                ANN_CLIENT,
                                ANN_PLAN,
                                ANN_HRS,
                                ANN_LRD,
                                ANN_PEN_VALUE,
                                ANN_ER_CONTS,
                                ANN_ACCOUNT,ANN_STATUS
                            ) VALUES (
                                DET_REC.TDT_MEM_ID,
                                TO_NUMBER(TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') ),
                                CLT_ID,
                                PL_ID,
                                NVL(DET_REC.TDT_PEN_UNITS,0),
                                PENSION_PKG.GET_PEN_LRD(CLT_ID,PL_ID,DET_REC.TDT_MEM_ID,TO_DATE('31-DEC-'
                                || TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') ) ),
                                NVL(PEN_VAL,0),
                                NVL(DET_REC.TDT_EE_UNITS,0),
                                HEAD_REC.THTP_ER_ACCOUNT,ST
                            );

                        END IF;

                    END IF;

                    IF
                        NVL(HEAD_REC.THTP_VOL_ACCOUNT,'XX') <> 'XX' AND NVL(DET_REC.TDT_VOL_UNITS,0) <> 0
                    THEN
                        SELECT
                            COUNT(*)
                        INTO
                            CNT
                        FROM
                            TBL_ANNUAL
                        WHERE
                            ANN_CLIENT = CLT_ID
                            AND   ANN_PLAN = PL_ID
                            AND   ANN_ID = DET_REC.TDT_MEM_ID
                            AND   ANN_YEAR = TO_NUMBER(TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') )
                            AND   NVL(ANN_ACCOUNT,'XX') = NVL(HEAD_REC.THTP_VOL_ACCOUNT,'XX')   AND ANN_STATUS=ST;

                        IF
                            NVL(CNT,0) > 0
                        THEN
                            UPDATE TBL_ANNUAL
                                SET
                                    ANN_HRS = NVL(ANN_HRS,0) + NVL(DET_REC.TDT_PEN_UNITS,0),
                                    ANN_PEN_VALUE = NVL(ANN_PEN_VALUE,0) + NVL(PEN_VAL,0),
                                    ANN_LRD = GREATEST(ANN_LRD,HEAD_REC.THTP_END_DATE),
                                    ANN_VOL_UNITS = NVL(ANN_VOL_UNITS,0) + NVL(DET_REC.TDT_VOL_UNITS,0)
                            WHERE
                                ANN_PLAN = PL_ID
                                AND   ANN_ID = DET_REC.TDT_MEM_ID
                                AND   ANN_YEAR = TO_NUMBER(TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') )
                                AND   NVL(ANN_ACCOUNT,'XX') = NVL(HEAD_REC.THTP_VOL_ACCOUNT,'XX')   AND ANN_STATUS=ST;

                        ELSE
                            INSERT INTO TBL_ANNUAL (
                                ANN_ID,
                                ANN_YEAR,
                                ANN_CLIENT,
                                ANN_PLAN,
                                ANN_HRS,
                                ANN_LRD,
                                ANN_PEN_VALUE,
                                ANN_VOL_UNITS,
                                ANN_ACCOUNT,ANN_STATUS
                            ) VALUES (
                                DET_REC.TDT_MEM_ID,
                                TO_NUMBER(TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') ),
                                CLT_ID,
                                PL_ID,
                                NVL(DET_REC.TDT_PEN_UNITS,0),
                                PENSION_PKG.GET_PEN_LRD(CLT_ID,PL_ID,DET_REC.TDT_MEM_ID,TO_DATE('31-DEC-'
                                || TO_CHAR(HEAD_REC.THTP_END_DATE,'rrrr') ) ),
                                NVL(PEN_VAL,0),
                                NVL(DET_REC.TDT_VOL_UNITS,0),
                                HEAD_REC.THTP_VOL_ACCOUNT,ST
                            );

                        END IF;

                    END IF;

                END;

            END LOOP;

            CLOSE TRAN_DET;
  -- UPDATE TRANSACTION_DETAIL_TEMP SET TDT_POST='Y' WHERE TDT_PLAN_ID=PL_ID AND TDT_USER=USER_ID AND TDT_TRAN_ID=HEAD_REC.THTP_TRAN_ID;
        END LOOP;

        CLOSE TRAN_HEAD;
        UPDATE TRAN_HEADER_TEMP_PEN
            SET
                --THTP_POSTED_DATE = SYSDATE,commented on 280318
                THTP_POSTED_DATE = CURRENT_TIMESTAMP,
                THTP_POST = 'Y'
        WHERE
            THT_CLIENT_ID = CLT_ID
            AND   THTP_PLAN_ID = PL_ID
            AND   UPPER(THTP_USER) = UPPER(USER_ID)
            AND   (
                (
                    NVL(THTP_POST,'N') = 'P'
                    AND   TRAN_ID IS NULL
                )
                OR    (
                    TRAN_ID IS NOT NULL
                    AND   THTP_TRAN_ID = TRAN_ID
                )
            );

        COMMIT;
    END;

    PROCEDURE POST_BATCHES_FUNDS (
        CLT_ID     VARCHAR2,
        PL_ID      VARCHAR2,
        USER_ID    VARCHAR2,
        TRAN_ID    VARCHAR2,
        BEN_TYPE   VARCHAR2
    ) IS

        HB_CNT     NUMBER;
        CNT        NUMBER := 0;
        CURSOR TRAN_HEAD (
            CLT_ID    VARCHAR2,
            PL_ID     VARCHAR2,
            USER_ID   VARCHAR2
        ) IS SELECT
            THTF_CLIENT_ID,
            THTF_EMPLOYER,
            THTF_PLAN_ID,
            THTF_START_DATE,
            THTF_END_DATE,
            THTF_PERIOD,
            HTFD_UNITS,
            HTFD_RATE,
            HTFD_AMT,
            THTF_PAYMENT_TYPE,
            HTFD_FUND,
            THTF_COMMENT,
            THTF_USER,
            THTF_DATE_TIME,
            THTF_MEM_ID,
            THTF_TRAN_ID,
            THTF_CHEQUE,THTF_TRAN_LABEL
             FROM
            TRAN_HEADER_TEMP_FUNDS,
            TRAN_HEADDER_TEMP_FUNDS_DET
             WHERE
            THTF_CLIENT_ID = CLT_ID
            AND   THTFD_CLIENT_ID = CLT_ID
            AND   THTF_TRAN_ID = HTFD_TRAN_ID
            AND   (
                NVL(HTFD_UNITS,0) <> 0
                OR    NVL(HTFD_AMT,0) <> 0
            )
            AND   UPPER(THTF_USER) = UPPER(USER_ID)
            AND   (
                (
                    NVL(THTF_POST,'N') = 'P'
                    AND   TRAN_ID IS NULL
                )
                OR    (
                    TRAN_ID IS NOT NULL
                    AND   THTF_TRAN_ID = TRAN_ID
                )
            )
        ORDER BY
            THTF_PERIOD,
            THTF_EMPLOYER;

        HEAD_REC   TRAN_HEAD%ROWTYPE;
        CURSOR TRAN_DET (
            CLT_ID    VARCHAR2,
            PL_ID     VARCHAR2,
            USER_ID   VARCHAR2,
            TR_ID     VARCHAR2,
            FD        VARCHAR2
        ) IS SELECT
            DTF_TRAN_ID,
            DTF_MEM_ID,
            DTF_FUND,
            DTF_UNITS,
            DTF_RATE,
            DTF_AMT,
            DTF_EMPLOYER
             FROM
            TRAN_DETAILS_TEMP_FUNDS_DET
             WHERE
            DTF_TRAN_ID = TR_ID
            AND   DTF_MEM_ID IS NOT NULL
            AND   DTF_FUND = FD
        ORDER BY
            DTF_MEM_ID;

        DET_REC    TRAN_DET%ROWTYPE;
    BEGIN
        OPEN TRAN_HEAD(CLT_ID,PL_ID,USER_ID);
        LOOP
            FETCH TRAN_HEAD INTO HEAD_REC;
            EXIT WHEN TRAN_HEAD%NOTFOUND;
            INSERT INTO TRANSACTION_HEADER_FUNDS (
                THF_EMPLOYER,
                THF_PLAN_ID,
                THF_START_DATE,
                THF_END_DATE,
                THF_PERIOD,
                THF_UNITS,
                THF_RATE,
                THF_AMOUNT,
                THF_PAYMENT_TYPE,
                THF_COMMENT,
                THF_USER,
                THF_DATE_TIME,
                THF_MEM_ID,
                THF_TRAN_ID,
                THF_POSTED_DATE,
                THF_POSTED_USER,
                THF_CHEQUE,
                THF_CLIENT_ID,THF_TRAN_LABEL
            ) VALUES (
                HEAD_REC.THTF_EMPLOYER,
                HEAD_REC.THTF_PLAN_ID,
                HEAD_REC.THTF_START_DATE,
                HEAD_REC.THTF_END_DATE,
                HEAD_REC.THTF_PERIOD,
                HEAD_REC.HTFD_UNITS,
                HEAD_REC.HTFD_RATE,
                HEAD_REC.HTFD_AMT,
                HEAD_REC.THTF_PAYMENT_TYPE,
                HEAD_REC.THTF_COMMENT,
                HEAD_REC.THTF_USER,
                HEAD_REC.THTF_DATE_TIME,
                HEAD_REC.THTF_MEM_ID,
                HEAD_REC.THTF_TRAN_ID,
               -- SYSDATE, COMMENTED ON 280318
               CURRENT_TIMESTAMP,
                USER_ID,
                HEAD_REC.THTF_CHEQUE,
                CLT_ID,HEAD_REC.THTF_TRAN_LABEL
            );

            OPEN TRAN_DET(CLT_ID,PL_ID,USER_ID,HEAD_REC.THTF_TRAN_ID,HEAD_REC.HTFD_FUND);
            LOOP
                FETCH TRAN_DET INTO DET_REC;
                EXIT WHEN TRAN_DET%NOTFOUND;
      --SELECT COUNT(*) INTO CNT FROM TBL_MEMBER WHERE MEM_ID=DET_REC.DTF_MEM_ID AND MEM_PLAN=PL_ID;
                INSERT INTO TRANSACTION_DETAIL (
                    TD_TRAN_ID,
                    TD_EMPLOYER,
                    TD_PLAN_ID,
                    TD_START_DATE,
                    TD_END_DATE,
                    TD_PERIOD,
                    TD_UNITS,
                    TD_AMOUNT,
                    TD_COMMENT,
                    TD_USER,
                    TD_DATE_TIME,
                    TD_MEM_ID,
                    TD_KEY,
                    TD_POSTED_DATE,
                    TD_POSTED_USER
                ) VALUES (
                    DET_REC.DTF_TRAN_ID,
                    DET_REC.DTF_EMPLOYER,
                    PL_ID,
                    HEAD_REC.THTF_START_DATE,
                    HEAD_REC.THTF_END_DATE,
                    HEAD_REC.THTF_PERIOD,
                    DET_REC.DTF_UNITS,
                    DET_REC.DTF_AMT,
                    DET_REC.DTF_FUND,
                    USER_ID,
                   -- SYSDATE,COMMENTED ON 280318
                   CURRENT_TIMESTAMP,
                    DET_REC.DTF_MEM_ID,
                    DET_REC.DTF_MEM_ID,
                    --SYSDATE,COMMENTED ON 280318
                    CURRENT_TIMESTAMP,
                    USER_ID
                );

                INSERT INTO TBL_MEM_FUNDS (
                    TMF_ID,
                    TMF_PLAN,
                    TMF_UNITS,
                    TMF_FUND,
                    TMF_RATE,
                    TMF_AMT,
                    TMF_FROM,
                    TMF_TO,
                    TMF_PERIOD,
                    TMF_ENTERED_DATE,
                    TMF_EMPLOYER,
                    TMF_USER,
                    TMF_BATCH,
                    TMF_DESC
                ) VALUES (
                    DET_REC.DTF_MEM_ID,
                    HEAD_REC.THTF_PLAN_ID,
                    DET_REC.DTF_UNITS,
                    DET_REC.DTF_FUND,
                    DET_REC.DTF_RATE,
                    DET_REC.DTF_AMT,
                    HEAD_REC.THTF_START_DATE,
                    HEAD_REC.THTF_END_DATE,
                    HEAD_REC.THTF_PERIOD,
                    --SYSDATE,--COMMENTED ON 280318
                    CURRENT_TIMESTAMP,
                    DET_REC.DTF_EMPLOYER,
                    USER_ID,
                    DET_REC.DTF_TRAN_ID,
                    NULL
                );

            END LOOP;

            CLOSE TRAN_DET;
   
  -- UPDATE TRANSACTION_DETAIL_TEMP SET DTF_POST='Y' WHERE DTF_PLAN_ID=PL_ID AND DTF_USER=USER_ID AND DTF_TRAN_ID=HEAD_REC.THTF_TRAN_ID;
        END LOOP;

        CLOSE TRAN_HEAD;
        UPDATE TRAN_HEADER_TEMP_FUNDS
            SET
                --THTF_POSTED_DATE = SYSDATE,COMMENTED ON 280318
                THTF_POSTED_DATE = CURRENT_TIMESTAMP,
                THTF_POST = 'Y'
        WHERE
            THTF_CLIENT_ID = CLT_ID
            AND   UPPER(THTF_USER) = UPPER(USER_ID)
            AND   (
                (
                    NVL(THTF_POST,'N') = 'P'
                    AND   TRAN_ID IS NULL
                )
                OR    (
                    TRAN_ID IS NOT NULL
                    AND   THTF_TRAN_ID = TRAN_ID
                )
            );

        COMMIT;
    END;

    FUNCTION GET_HR_BANK (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN NUMBER IS
        R   NUMBER(12,2) := 0;
    BEGIN
        SELECT
            MAX(A.THB_CLOSING_HRS)
        INTO
            R
        FROM
            TBL_HR_BANK A
        WHERE
            A.THB_CLIENT_ID = CLT_ID
            AND   A.THB_PLAN = PL_ID
            AND   A.THB_ID = EE_ID
            AND   A.THB_MONTH = (
                SELECT
                    MAX(B.THB_MONTH)
                FROM
                    TBL_HR_BANK B
                WHERE
                    B.THB_CLIENT_ID = CLT_ID
                    AND   B.THB_PLAN = PL_ID
                    AND   B.THB_ID = EE_ID
                    AND   B.THB_MONTH <= MTH
            )
            AND   A.THB_POSTED_DATE = (
                SELECT
                    MAX(C.THB_POSTED_DATE)
                FROM
                    TBL_HR_BANK C
                WHERE
                    C.THB_PLAN = PL_ID
                    AND   C.THB_ID = EE_ID
                    AND   C.THB_MONTH = A.THB_MONTH
            );

        RETURN R;
    END;

    FUNCTION GET_FORFEIT_HRS (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        MTH      DATE
    ) RETURN NUMBER IS
        R   NUMBER(12,2) := 0;
    BEGIN
        SELECT
            SUM(A.THB_CLOSING_HRS)
        INTO
            R
        FROM
            TBL_HR_BANK A,
            TBL_HW
        WHERE
            A.THB_CLIENT_ID = CLT_ID
            AND   HW_CLIENT = CLT_ID
            AND   A.THB_ID = HW_ID
            AND   HW_EMPLOYER = ER_ID
            AND   TO_CHAR(A.THB_MONTH,'MON-RRRR') = TO_CHAR(ADD_MONTHS(TRUNC(MTH,'MM'),-10),'MON-RRRR')
            AND   TRUNC(A.THB_MONTH,'MM') = (
                SELECT
                    MAX(TRUNC(B.THB_MONTH,'MM') )
                FROM
                    TBL_HR_BANK B
                WHERE
                    B.THB_ID = A.THB_ID
                    AND   B.THB_MONTH <= MTH
                    AND   NVL(B.THB_HOURS,0) > 0
            );

        RETURN R;
    END;

    FUNCTION FIRST_ELIGIBLE_DATE (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2
    ) RETURN DATE IS
        R   DATE;
    BEGIN
        SELECT
            MIN(THB_MONTH)
        INTO
            R
        FROM
            TBL_HR_BANK
        WHERE
            THB_CLIENT_ID = CLT_ID
            AND   THB_PLAN = PL_ID
            AND   THB_ID = EE_ID
            AND   NVL(THB_DEDUCT_HRS,0) <> 0;

        IF
            R IS NULL
        THEN
            RETURN NULL;
        ELSE
            RETURN ADD_MONTHS(R,2);
        END IF;

    END;

    PROCEDURE ELIG_PROC (
        CLT_ID   VARCHAR2,
        PL_ID1   VARCHAR2,
        MEND     VARCHAR2
    ) IS

        CNT        NUMBER;
        MTH        DATE;
        DH         NUMBER(12,2) := 0;
        PREV_BAL   NUMBER(12,2) := 0;
        CURR_HRS   NUMBER(12,2) := 0;
        MAX1       DATE;
        HB_CNT     NUMBER;
        DT         DATE;
        CURSOR TRAN_DET (
            CLT_ID   VARCHAR2,
            PL_ID1   VARCHAR2,
            DT       DATE
        ) IS ( SELECT
            TD_PLAN_ID,
            TD_MEM_ID,
            TD_EMPLOYER,
            MIN(TRUNC(TD_PERIOD,'MM') ) MTH
               FROM
            TRANSACTION_DETAIL
               WHERE
            TD_CLIENT_ID = CLT_ID
            AND   TD_PLAN_ID = PL_ID1
            AND   NVL(TD_UNITS,0) > 0
            AND   TD_PERIOD IS NOT NULL
            AND   TD_POSTED_DATE >= DT
            AND   NVL(MEND,'N') = 'N'
               GROUP BY
            TD_PLAN_ID,
            TD_MEM_ID,
            TD_EMPLOYER
        )
        UNION
        ( SELECT
            THB_PLAN,
            THB_ID,
            MAX(THB_EMPLOYER),
            MAX(TRUNC(THB_MONTH,'MM') ) MTH
          FROM
            TBL_HR_BANK
          WHERE
            THB_CLIENT_ID = CLT_ID
            AND   THB_PLAN = PL_ID1
            AND   NVL(THB_CLOSING_HRS,0) > 0
           -- AND   THB_MONTH > ADD_MONTHS(SYSDATE,-12) Commented on 280318
            AND   THB_MONTH > ADD_MONTHS(CURRENT_TIMESTAMP,-12)
            AND   NVL(MEND,'N') = 'Y'
          GROUP BY
            THB_CLIENT_ID,
            THB_PLAN,
            THB_ID
        );

        DET_REC    TRAN_DET%ROWTYPE;
        MH         NUMBER(12,2) := 0;
    BEGIN
        SELECT
            ( MAX(PH_LAST_ELIG_PROC_DATE) )
        INTO
            DT
        FROM
            POSTING_HISTORY
        WHERE
            PH_CLIENT_ID = CLT_ID
            AND   PH_PLAN = PL_ID1;

        DBMS_OUTPUT.PUT_LINE(DT);
        OPEN TRAN_DET(CLT_ID,PL_ID1,DT);
        LOOP
            FETCH TRAN_DET INTO DET_REC;
            EXIT WHEN TRAN_DET%NOTFOUND;
            MTH := TRUNC(DET_REC.MTH,'MM');
            
            select max(thb_month) into max1 from tbl_hr_bank 
            where              THB_CLIENT_ID = CLT_ID
                        AND   THB_PLAN = PL_ID1
                        AND   THB_ID = DET_REC.TD_MEM_ID;
            SELECT
               -- greatest(max1,greatest(MAX(TRUNC(PL_HW_MONTHEND,'MM') ),mth) )  commented on 180418 by Ramana
               greatest(NVL(max1,greatest(MAX(TRUNC(PL_HW_MONTHEND,'MM') ),mth)),greatest(MAX(TRUNC(PL_HW_MONTHEND,'MM') ),mth) ) --added by ramana on 180418
            INTO
                MAX1
            FROM
                TBL_PLAN
            WHERE
                PL_CLIENT_ID = CLT_ID
                AND   PL_ID = PL_ID1;

            LOOP
                DBMS_OUTPUT.PUT_LINE(MTH);
                IF
                    MTH > MAX1
                THEN
                    EXIT;
                END IF;
                SELECT
                    NVL(SUM(NVL(A.THB_CLOSING_HRS,0) ),0)
                INTO
                    PREV_BAL
                FROM
                    TBL_HR_BANK A
                WHERE
                    A.THB_CLIENT_ID = CLT_ID
                    AND   A.THB_PLAN = PL_ID1
                    AND   A.THB_ID = DET_REC.TD_MEM_ID
                    AND   TRUNC(A.THB_MONTH,'MM') = (
                        SELECT
                            TRUNC(MAX(B.THB_MONTH),'MM')
                        FROM
                            TBL_HR_BANK B
                        WHERE
                            B.THB_CLIENT_ID = CLT_ID
                            AND   B.THB_PLAN = PL_ID1
                            AND   B.THB_ID = DET_REC.TD_MEM_ID
                            AND   TRUNC(B.THB_MONTH,'MM') <= TRUNC(ADD_MONTHS(MTH,-1),'MM')
                    );

                SELECT
                    SUM(NVL(TD_UNITS,0) )
                INTO
                    CURR_HRS
                FROM
                    TRANSACTION_DETAIL
                WHERE
                    TD_CLIENT_ID = CLT_ID
                    AND   TD_PLAN_ID = PL_ID1
                    AND   TD_MEM_ID = DET_REC.TD_MEM_ID
                    AND   TRUNC(TD_PERIOD,'MM') = TRUNC(MTH,'MM');

                IF
                    NVL(GET_REQUIRED_HRS(CLT_ID,PL_ID1,DET_REC.TD_EMPLOYER,DET_REC.TD_MEM_ID,MTH),0) <= NVL(PREV_BAL,0) + NVL(CURR_HRS,0)
                THEN
                    DH := NVL(GET_MONTHLY_HRS(CLT_ID,PL_ID1,DET_REC.TD_EMPLOYER,DET_REC.TD_MEM_ID,MTH),0);
                ELSE
                    DH := 0;
                END IF;

                SELECT
                    COUNT(*)
                INTO
                    CNT
                FROM
                    TBL_HR_BANK
                WHERE
                    THB_CLIENT_ID = CLT_ID
                    AND   THB_PLAN = PL_ID1
                    AND   THB_ID = DET_REC.TD_MEM_ID
                    AND   TRUNC(THB_MONTH,'MM') = TRUNC(MTH,'MM');
 --MH:=GET_MAX_HRS(PL_ID1 ,NULL,NULL ,MTH);

                MH := GET_MAX_HRS(CLT_ID,PL_ID1,NULL,NULL,MTH);
   --MH:=1200;
   --
                IF
                    NVL(CNT,0) > 0
                THEN
                    UPDATE TBL_HR_BANK
                        SET
                            THB_EMPLOYER = DET_REC.TD_EMPLOYER,
                            THB_HOURS = NVL(CURR_HRS,0),--Changed on 270318 previous statement is :THB_HOURS = NVL(CURR_HRS,0)
                            THB_DEDUCT_HRS = DH,
                            --THB_CLOSING_HRS = LEAST(NVL(MH,0),NVL(PREV_BAL,0) + NVL(CURR_HRS,0) - NVL(DH,0) ),commented on 270318 before change
                            THB_CLOSING_HRS = LEAST(NVL(MH,0),NVL(PREV_BAL,0) + NVL(CURR_HRS,0) - NVL(DH,0) ),--on 270318 after change
                            --THB_POSTED_DATE = SYSDATE
                            THB_POSTED_DATE = CURRENT_TIMESTAMP
                    WHERE
                        THB_CLIENT_ID = CLT_ID
                        AND   THB_PLAN = PL_ID1
                        AND   THB_ID = DET_REC.TD_MEM_ID
                        AND   TRUNC(THB_MONTH,'MM') = TRUNC(MTH,'MM');

                ELSE
                    INSERT INTO TBL_HR_BANK (
                        THB_ID,
                        THB_PLAN,
                        THB_MONTH,
                        THB_HOURS,
                        THB_DEDUCT_HRS,
                        THB_CLOSING_HRS,
                        THB_POSTED_DATE,
                        THB_EMPLOYER,
                        THB_CLIENT_ID
                    ) VALUES (
                        DET_REC.TD_MEM_ID,
                        PL_ID1,
                        MTH,
                        CURR_HRS,
                        DH,
                        LEAST(NVL(MH,0),NVL(PREV_BAL,0) + NVL(CURR_HRS,0) - NVL(DH,0) ),
                        --SYSDATE,COMMENTED ON 280318
                        CURRENT_TIMESTAMP,
                        DET_REC.TD_EMPLOYER,
                        CLT_ID
                    );

                END IF;

                MTH := ADD_MONTHS(MTH,1);

            END LOOP;

        END LOOP;

        CLOSE TRAN_DET;
        INSERT INTO POSTING_HISTORY (
            PH_PLAN,
            PH_LAST_ELIG_PROC_DATE,
            PH_CLIENT_ID
        ) VALUES (
            PL_ID1,
            --SYSDATE,--COMMENTED ON 280318
            CURRENT_TIMESTAMP,
            CLT_ID
        );

        COMMIT;
    END;

    FUNCTION GET_HB_LRD (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN DATE IS
        L   DATE;
    BEGIN
        SELECT
            MAX(THB_MONTH)
        INTO
            L
        FROM
            TBL_HR_BANK
        WHERE
            THB_PLAN = PL_ID
            AND   THB_ID = EE_ID
            AND   NVL(THB_HOURS,0) > 0;

        RETURN L;
    END;

    FUNCTION GET_BEN_RATE (
        CLT_ID     VARCHAR2,
        PL_ID      VARCHAR2,
        AGREE_ID   VARCHAR2,
        OCCU_ID    VARCHAR2,
        EARNED     VARCHAR2
    ) RETURN NUMBER AS
        V_HB_RATE   NUMBER;
    BEGIN
        SELECT
            TAD_RATE
        INTO
            V_HB_RATE
        FROM
            TBL_AGREEMENT_DETAILS
        WHERE
            TAD_CLIENT_ID = CLT_ID
            AND   TAD_PLAN_ID = PL_ID
            AND   TAD_AGREE_ID = AGREE_ID
            AND   TAD_UNIT_TYPE = NVL2(EARNED,'EARN','WORK')
            AND   TAD_OCCUP_ID = OCCU_ID;

        RETURN V_HB_RATE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END;

    FUNCTION GET_DEP_NO (
        P_PLAN_ID     VARCHAR2,
        P_CLIENT_ID   VARCHAR2,
        P_HD_ID       VARCHAR2
    ) RETURN NUMBER AS
        DEP_BEN_NO   TBL_HW_DEPENDANTS.HD_BEN_NO%TYPE;
    BEGIN
        SELECT
            NVL(MAX(HD_BEN_NO),0) + 1
        INTO
            DEP_BEN_NO
        FROM
            TBL_HW_DEPENDANTS
        WHERE
            HD_PLAN = P_PLAN_ID
            AND   HD_CLIENT = P_CLIENT_ID
            AND   HD_ID = P_HD_ID;

        RETURN DEP_BEN_NO;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 1;
    END GET_DEP_NO;

    FUNCTION GET_BEN_NO (
        P_PLAN_ID     VARCHAR2,
        P_CLIENT_ID   VARCHAR2,
        P_HB_ID       VARCHAR2
    ) RETURN NUMBER AS
        BEN_NO   TBL_HW_BENEFICIARY.HB_BEN_NO%TYPE;
    BEGIN
        SELECT
            NVL(MAX(HB_BEN_NO),0) + 1
        INTO
            BEN_NO
        FROM
            TBL_HW_BENEFICIARY
        WHERE
            HB_PLAN = P_PLAN_ID
            AND   HB_CLIENT = P_CLIENT_ID
            AND   HB_ID = P_HB_ID;

        RETURN BEN_NO;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 1;
    END GET_BEN_NO;

    FUNCTION ELIG_MONTH_UPTO (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        EE_ID    VARCHAR2
    ) RETURN DATE AS
        MTH   DATE;
    BEGIN
        SELECT
            --NVL(ADD_MONTHS(TRUNC(MAX(THB_MONTH),'mm'),2),SYSDATE)  Commented on 280318
            NVL(ADD_MONTHS(TRUNC(MAX(THB_MONTH),'mm'),2),CURRENT_TIMESTAMP)
        INTO
            MTH
        FROM
            TBL_HR_BANK
        WHERE
            THB_CLIENT_ID = CLT_ID
            AND   THB_PLAN = PL_ID
            AND   THB_ID = EE_ID;

        RETURN MTH;
    END;

END HR_BANK_PKG;
/

