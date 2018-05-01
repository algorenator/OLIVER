--
-- ELIG_PROC_TEST  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.ELIG_PROC_TEST(
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
            TD_CLIENT_ID = 'DT'
            AND   TD_PLAN_ID = 'UNIFOR'
            AND   NVL(TD_UNITS,0) > 0
            AND   TD_PERIOD IS NOT NULL
            AND   TD_POSTED_DATE >= SYSDATE
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
                greatest(NVL(max1,greatest(MAX(TRUNC(PL_HW_MONTHEND,'MM') ),mth)),greatest(MAX(TRUNC(PL_HW_MONTHEND,'MM') ),mth) )
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
                    NVL(HR_BANK_PKG.GET_REQUIRED_HRS(CLT_ID,PL_ID1,DET_REC.TD_EMPLOYER,DET_REC.TD_MEM_ID,MTH),0) <= NVL(PREV_BAL,0) + NVL(CURR_HRS,0)
                THEN
                    DH := NVL(HR_BANK_PKG.GET_MONTHLY_HRS(CLT_ID,PL_ID1,DET_REC.TD_EMPLOYER,DET_REC.TD_MEM_ID,MTH),0);
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

               MH := HR_BANK_PKG.GET_MAX_HRS(CLT_ID,PL_ID1,NULL,NULL,MTH);
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
    END ELIG_PROC_TEST;
/

