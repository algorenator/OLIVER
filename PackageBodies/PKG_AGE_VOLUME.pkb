--
-- PKG_AGE_VOLUME  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.PKG_AGE_VOLUME IS

    FUNCTION REPORT_AGE_VOLUME (
        P_CLIENT_ID VARCHAR2,
        P_PLAN_ID VARCHAR2
    ) RETURN T_REPORT_AGE_VOLUME
        PIPELINED
    IS

        TYPE T_AGE_INITIAL IS
            TABLE OF PLS_INTEGER;
        TYPE T_AGE_FINAL IS
            TABLE OF PLS_INTEGER;
        TYPE T_GENDER IS
            TABLE OF VARCHAR2(1);
        TYPE T_SMOKER IS
            TABLE OF VARCHAR2(1);
        L_ROW           T_BENEFIT_AGE_VOLUME;
        L_MONTH_END     DATE;
        L_AGE_INITIAL   T_AGE_INITIAL := T_AGE_INITIAL(0,36,41,46,51,56,61,66,71);
        L_AGE_FINAL     T_AGE_FINAL := T_AGE_FINAL(35,40,45,50,55,60,65,70,99);
        L_GENDER        T_GENDER := T_GENDER('F','M');
        L_SMOKER        T_SMOKER := T_SMOKER('S','N');
    BEGIN
       
    
    
        FOR M IN (
            SELECT
                TRUNC(PL_HW_MONTHEND) MONTH_END
            FROM
                TBL_PLAN
            WHERE
                PL_CLIENT_ID = P_CLIENT_ID
                AND   PL_ID = P_PLAN_ID
            GROUP BY
                TRUNC(PL_HW_MONTHEND),
                PL_CLIENT_ID,
                PL_ID
        ) LOOP
            L_MONTH_END := M.MONTH_END;
        END LOOP;

        IF
            L_MONTH_END IS NULL
        THEN
            RETURN;
        END IF;
        FOR BG IN (
            SELECT
                BM_BEN_GROUP,
                BENDESC
            FROM
                MEMBER_BENEFITS_TEMP
            WHERE
                CLIENT_ID = P_CLIENT_ID
                AND   PLAN_ID = P_PLAN_ID
                AND   BM_BEN_TYPE IN (
                    'V',
                    'A'
                )
            GROUP BY
                BM_BEN_GROUP,
                BENDESC
        ) LOOP
            FOR A IN 1..L_AGE_FINAL.COUNT LOOP
                FOR G IN 1..L_GENDER.COUNT LOOP
                    FOR S IN 1..L_SMOKER.COUNT LOOP
                        L_ROW.BEN_GROUP := BG.BM_BEN_GROUP;
                        L_ROW.BENEFIT := BG.BENDESC;
                        L_ROW.SMOKER := L_SMOKER(S);
                        L_ROW.GENDER := L_GENDER(G);
                        L_ROW.AGE := L_AGE_FINAL(A);
                        L_ROW.RATE_AVG := 0;
                        L_ROW.CNT := 0;
                        L_ROW.VOLUME := 0;
                        L_ROW.NET_PREMIUM := 0;
                        FOR B IN (
                            SELECT
                                AVG(0) RATE_AVG,
                                COUNT(*) CNT,
                                SUM(COVERGAE) VOLUME,
                                SUM(NVL(MB.BEN_BILL,0) - NVL(GB_PKG.GET_ADMIN_AMT(CID => MB.CLIENT_ID,PL => MB.PLAN_ID,ID1 => MB.MEM_ID,BTYPE => MB.BM_BEN_TYPE,BENEFIT => MB
.CODE,BDESC => MB.BENDESC,DT => SYSDATE,SX => MB.MEM_GENDER,DOB => MB.MEM_DOB,SMK => MB.HW_SMOKER,CLASS1 => MB.BEN_CLASS,BG => NULL,DS1 => NULL,SAL
=> NULL,EDATE => NULL,TDATE => NULL,BD => NULL),0) ) NET_PREMIUM
                            FROM
                                MEMBER_BENEFITS_TEMP MB
                            WHERE
                                MB.CLIENT_ID = P_CLIENT_ID
                                AND   MB.PLAN_ID = P_PLAN_ID
                                AND   MB.BM_BEN_TYPE IN (
                                    'V',
                                    'A'
                                )
                                AND   MB.BM_BEN_GROUP = BG.BM_BEN_GROUP
                                AND   ( ( ( MONTHS_BETWEEN(TRUNC(SYSDATE),MB.MEM_DOB) / 12 ) / 5 + 1 ) * 5 ) BETWEEN L_AGE_INITIAL(A) AND L_AGE_FINAL(A)
                                AND   NVL(MB.MEM_GENDER,'M') = L_GENDER(G)
                                AND   NVL(MB.HW_SMOKER,'N') = L_SMOKER(S)
                        ) LOOP
                            L_ROW.RATE_AVG := NVL(B.RATE_AVG,0);
                            L_ROW.CNT := NVL(B.CNT,0);
                            L_ROW.VOLUME := NVL(B.VOLUME,0);
                            L_ROW.NET_PREMIUM := NVL(B.NET_PREMIUM,0);
                        END LOOP;

                        PIPE ROW ( L_ROW );
                    END LOOP;
                END LOOP;
            END LOOP;
        END LOOP;

    END REPORT_AGE_VOLUME;

END PKG_AGE_VOLUME;
/

