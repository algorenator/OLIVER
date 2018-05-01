--
-- POST_BATCHES_TEST  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.POST_BATCHES_TEST (
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
            THT_CHEQUE
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
    DBMS_OUTPUT.PUT_LINE('STEP1');
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
                TH_CLIENT_ID
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
                CLT_ID
            );
DBMS_OUTPUT.PUT_LINE('TRANSACTION_HEADER1');
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
DBMS_OUTPUT.PUT_LINE('MEMBER1');
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
DBMS_OUTPUT.PUT_LINE('TRANSACTION_DETAIL1');
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
        HR_BANK_PKG.ELIG_PROC(CLT_ID,PL_ID,'N');   --ADDED ON 09/FEB/2018 BY RAO

--IF  NVL(BEN_TYPE,'X')='P' THEN 
      --  POST_BATCHES_PEN(CLT_ID,PL_ID,USER_ID,TRAN_ID,BEN_TYPE);
--END IF;
--IF  NVL(BEN_TYPE,'X')='F' THEN
       -- POST_BATCHES_FUNDS(CLT_ID,PL_ID,USER_ID,TRAN_ID,BEN_TYPE);
--END IF;
        COMMIT;
    END POST_BATCHES_TEST;
/

