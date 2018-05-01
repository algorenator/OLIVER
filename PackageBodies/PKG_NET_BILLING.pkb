--
-- PKG_NET_BILLING  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.PKG_NET_BILLING IS

    FUNCTION GET_BEN_TOTALS (
        P_CLIENT_ID     VARCHAR2,
        P_PLAN_ID       VARCHAR2,
        P_EMPLOYER_ID   VARCHAR2
    ) RETURN T_BENEFITS
        PIPELINED
    IS
        L_ROW   T_BENEFIT;
    BEGIN

    -- get benefit values
        FOR B IN (
            SELECT
                BM_BEN_TYPE,
                CODE,
                BENDESC BEN_NAME,
                DECODE(COVERGAE,'F','Family','C','Couple','S','Single','') DEP_CODE,
                COUNT(MEM_ID) LIVES_NUM,
                NVL(SUM(
                    CASE
                        WHEN TRIM(TRANSLATE(COVERGAE,' .,0123456789','              ') ) IS NULL THEN NVL(TO_NUMBER(COVERGAE),0)
                        ELSE 0
                    END
                ),0) BILLED_VOL,
                NVL(SUM(BEN_BILL),0) CONTRACT_PREM,
                NVL(SUM(ADMIN_AMT),0) ADMIN_AMT
            FROM
                /*MEMBER_BENEFITS*/
                MEMBER_BENEFITS_TEMP
            WHERE
                CLIENT_ID = P_CLIENT_ID
                AND   PLAN_ID = P_PLAN_ID
                AND   (P_EMPLOYER_ID = 'ALL' or EMPLOYER = P_EMPLOYER_ID)
                AND   BM_BEN_TYPE IN (
                    'D',
                    'V'
                )
            GROUP BY
                BM_BEN_TYPE,
                CODE,
                BENDESC,
                DECODE(COVERGAE,'F','Family','C','Couple','S','Single','')
            ORDER BY
                3
        ) LOOP
            L_ROW := NULL;
            L_ROW.BEN_TYPE := B.BM_BEN_TYPE;
            L_ROW.BEN_NAME := B.BEN_NAME;
            L_ROW.DEP_CODE := B.DEP_CODE;
            L_ROW.LIVES_NUM := B.LIVES_NUM;
            L_ROW.BILLED_VOL := B.BILLED_VOL;
            L_ROW.CONTRACT_PREM := B.CONTRACT_PREM;
      -- get adjustment values
            FOR A IN (
                SELECT
                    NVL(SUM(BEN_BILL),0) CONTRACT_ADJ,
                    NVL(SUM(ADMIN_AMT),0) NET_ADJ
                FROM
                    MEMBER_BENEFITS_ADJ
                WHERE
                    CLIENT_ID = P_CLIENT_ID
                    AND   PLAN_ID = P_PLAN_ID
                    AND   (P_EMPLOYER_ID = 'ALL' or EMPLOYER = P_EMPLOYER_ID)
                    AND   BM_BEN_TYPE = B.BM_BEN_TYPE
                    AND   CODE = B.CODE
            ) LOOP
                L_ROW.CONTRACT_ADJ := A.CONTRACT_ADJ;
                L_ROW.CONTRACT_BILL := L_ROW.CONTRACT_PREM + L_ROW.CONTRACT_ADJ;
                L_ROW.NET_PREM := B.CONTRACT_PREM - B.ADMIN_AMT;
                L_ROW.NET_ADJ := A.NET_ADJ;
                L_ROW.NET_BILL := L_ROW.NET_PREM + L_ROW.NET_ADJ;
            END LOOP;

            PIPE ROW ( L_ROW );
        END LOOP;
    END GET_BEN_TOTALS;

    FUNCTION GET_AOP_JSON (
        P_CLIENT_ID     VARCHAR2,
        P_PLAN_ID       VARCHAR2,
        P_CARRIER_ID    VARCHAR2,
        P_EMPLOYER_ID   VARCHAR2
    ) RETURN CLOB IS
        L_CURSOR   SYS_REFCURSOR;
        L_RETURN   CLOB;
    BEGIN

      delete MEMBER_BENEFITS_TEMP;

      INSERT INTO MEMBER_BENEFITS_TEMP (
        BM_BEN_GROUP, EMPLOYER, BM_BEN_TYPE, CLIENT_ID, PLAN_ID,
        MEM_ID, BEN_CLASS, CODE, BENDESC, MEM_LAST_NAME, MEM_FIRST_NAME,
        MEM_DOB, MEM_GENDER, COVERGAE, BEN_BILL, HW_SMOKER, CARRIER_RATE,
        ADMIN_RATE, AGENT_RATE, ADMIN_AMT)
      (SELECT BM_BEN_GROUP, EMPLOYER, BM_BEN_TYPE, CLIENT_ID, PLAN_ID,
       MEM_ID, BEN_CLASS, CODE, BENDESC, MEM_LAST_NAME, MEM_FIRST_NAME,
       MEM_DOB, MEM_GENDER, COVERGAE, BEN_BILL, HW_SMOKER, CARRIER_RATE,
       ADMIN_RATE, AGENT_RATE, ADMIN_AMT
       FROM MEMBER_BENEFITS
       WHERE client_id = p_client_id AND plan_id = p_plan_id
       and (P_EMPLOYER_ID = 'ALL' or employer=P_EMPLOYER_ID)
      );

        APEX_JSON.INITIALIZE_CLOB_OUTPUT(DBMS_LOB.CALL,TRUE,2);
        OPEN L_CURSOR FOR WITH M AS (
            SELECT
                PL_HW_MONTHEND,
                TO_CHAR(PL_HW_MONTHEND,'Month YYYY') BILL_MONTH
            FROM
                TBL_PLAN
            WHERE
                PL_CLIENT_ID = P_CLIENT_ID
                AND   PL_ID = P_PLAN_ID
                AND   PL_TYPE = 'GB'
        ),B AS (
            SELECT
                T.*
            FROM
                TABLE ( PKG_NET_BILLING.GET_BEN_TOTALS(P_CLIENT_ID,P_PLAN_ID,P_EMPLOYER_ID) ) T
        ) SELECT
            'net_billing_report' "filename",
            CURSOR (
                SELECT
                    CURSOR (
                        SELECT
                            (
                                SELECT
                                    TC_CARRIER_NAME
                                FROM
                                    TBL_CARRIER
                                WHERE
                                    TC_CARRIER_ID = P_CARRIER_ID
                                    AND   TC_CLIENT = P_CLIENT_ID
                                    AND   TC_PLAN = P_PLAN_ID
                            ) AS "carrier",
                            CASE
                              WHEN P_EMPLOYER_ID = 'ALL' THEN 'ALL EMPLOYERS'
                              ELSE (SELECT CO_NAME FROM TBL_COMPMAST WHERE CO_CLIENT = P_CLIENT_ID AND CO_PLAN = P_PLAN_ID AND CO_NUMBER = P_EMPLOYER_ID)
                            END AS "employer",
                            BILL_MONTH AS "bill_month",
                            TO_CHAR(SYSDATE,'DD-mon-YYYY') AS "print_date",
                            CURSOR (
                                SELECT
                                    BEN_TYPE AS "ben_type",
                                    BEN_NAME AS "ben_name",
                                    DEP_CODE AS "dep_code",
                                    LIVES_NUM AS "lives_num",
                                    TO_CHAR(NVL(BILLED_VOL,0),'FML999G999G990D00') AS "billed_vol",
                                    TO_CHAR(NVL(CONTRACT_PREM,0),'FML999G999G990D00') AS "contract_prem",
                                    TO_CHAR(NVL(CONTRACT_ADJ,0),'FML999G999G990D00') AS "contract_adj",
                                    TO_CHAR(NVL(CONTRACT_BILL,0),'FML999G999G990D00') AS "contract_bill",
                                    TO_CHAR(NVL(NET_PREM,0),'FML999G999G990D00') AS "net_prem",
                                    TO_CHAR(NVL(NET_ADJ,0),'FML999G999G990D00') AS "net_adj",
                                    TO_CHAR(NVL(NET_BILL,0),'FML999G999G990D00') AS "net_bill"
                                FROM
                                    B
                                WHERE
                                    BEN_TYPE = 'V'
                            ) AS "vol",
                            CURSOR (
                                SELECT
                                    TO_CHAR(NVL(SUM(CONTRACT_PREM),0),'FML999G999G990D00') AS "contract_prem",
                                    TO_CHAR(NVL(SUM(CONTRACT_ADJ),0),'FML999G999G990D00') AS "contract_adj",
                                    TO_CHAR(NVL(SUM(CONTRACT_BILL),0),'FML999G999G990D00') AS "contract_bill",
                                    TO_CHAR(NVL(SUM(NET_PREM),0),'FML999G999G990D00') AS "net_prem",
                                    TO_CHAR(NVL(SUM(NET_ADJ),0),'FML999G999G990D00') AS "net_adj",
                                    TO_CHAR(NVL(SUM(NET_BILL),0),'FML999G999G990D00') AS "net_bill"
                                FROM
                                    B
                                WHERE
                                    BEN_TYPE = 'V'
                            ) AS "vol_tot",
                            CURSOR (
                                SELECT
                                    BEN_TYPE AS "ben_type",
                                    BEN_NAME AS "ben_name",
                                    DEP_CODE AS "dep_code",
                                    LIVES_NUM AS "lives_num",
                                    TO_CHAR(NVL(BILLED_VOL,0),'FML999G999G990D00') AS "billed_vol",
                                    TO_CHAR(NVL(CONTRACT_PREM,0),'FML999G999G990D00') AS "contract_prem",
                                    TO_CHAR(NVL(CONTRACT_ADJ,0),'FML999G999G990D00') AS "contract_adj",
                                    TO_CHAR(NVL(CONTRACT_BILL,0),'FML999G999G990D00') AS "contract_bill",
                                    TO_CHAR(NVL(NET_PREM,0),'FML999G999G990D00') AS "net_prem",
                                    TO_CHAR(NVL(NET_ADJ,0),'FML999G999G990D00') AS "net_adj",
                                    TO_CHAR(NVL(NET_BILL,0),'FML999G999G990D00') AS "net_bill"
                                FROM
                                    B
                                WHERE
                                    BEN_TYPE = 'D'
                            ) AS "dep",
                            CURSOR (
                                SELECT
                                    TO_CHAR(NVL(SUM(CONTRACT_PREM),0),'FML999G999G990D00') AS "contract_prem",
                                    TO_CHAR(NVL(SUM(CONTRACT_ADJ),0),'FML999G999G990D00') AS "contract_adj",
                                    TO_CHAR(NVL(SUM(CONTRACT_BILL),0),'FML999G999G990D00') AS "contract_bill",
                                    TO_CHAR(NVL(SUM(NET_PREM),0),'FML999G999G990D00') AS "net_prem",
                                    TO_CHAR(NVL(SUM(NET_ADJ),0),'FML999G999G990D00') AS "net_adj",
                                    TO_CHAR(NVL(SUM(NET_BILL),0),'FML999G999G990D00') AS "net_bill"
                                FROM
                                    B
                                WHERE
                                    BEN_TYPE = 'D'
                            ) AS "dep_tot",
                            CURSOR (
                                SELECT
                                    TO_CHAR(NVL(SUM(CONTRACT_PREM),0),'FML999G999G990D00') AS "contract_prem",
                                    TO_CHAR(NVL(SUM(CONTRACT_ADJ),0),'FML999G999G990D00') AS "contract_adj",
                                    TO_CHAR(NVL(SUM(CONTRACT_BILL),0),'FML999G999G990D00') AS "contract_bill",
                                    TO_CHAR(NVL(SUM(NET_PREM),0),'FML999G999G990D00') AS "net_prem",
                                    TO_CHAR(NVL(SUM(NET_ADJ),0),'FML999G999G990D00') AS "net_adj",
                                    TO_CHAR(NVL(SUM(NET_BILL),0),'FML999G999G990D00') AS "net_bill"
                                FROM
                                    B
                            ) AS "tot"
                        FROM
                            M
                    ) AS "report"
                FROM
                    DUAL
            ) "data"
          FROM DUAL;

        APEX_JSON.WRITE(L_CURSOR);
        L_RETURN := APEX_JSON.GET_CLOB_OUTPUT;
        RETURN L_RETURN;
    END GET_AOP_JSON;

END PKG_NET_BILLING;

/

