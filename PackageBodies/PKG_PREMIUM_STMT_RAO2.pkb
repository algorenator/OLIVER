--
-- PKG_PREMIUM_STMT_RAO2  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.PKG_PREMIUM_STMT_rao2
IS
   FUNCTION GET_EMPLOYERS (P_PLAN_ID        VARCHAR2,
                           P_CLIENT_ID      VARCHAR2,
                           P_EMPLOYER_ID    VARCHAR2)
      RETURN T_EMPLOYERS
      PIPELINED
   IS
      L_EMPLOYER     T_EMPLOYER;
      L_ROWS_COUNT   PLS_INTEGER := 0;
   BEGIN
      FOR E
         IN (WITH PLAN
                  AS (SELECT P.PL_ID,
                             P.PL_HW_MONTHEND,
                             P.PL_NAME,
                             P.PL_GST_NUMBER,
                             P.PL_PAY_GRACE_PERIOD,
                             PL_ADDRESS1 || ' ' || PL_ADDRESS2 PL_ADDRESS,
                             PL_CITY || ', ' || PL_PROV PL_CITY,
                             PL_POST_CODE,
                             PL_PHONE1 PL_PHONE,
                             APEX_WEB_SERVICE.BLOB2CLOBBASE64 (PL_LOGO)
                                PL_LOGO
                        FROM PLAN_TYPES PT, TBL_PLAN P
                       WHERE     P.PL_ID = P_PLAN_ID
                             AND P.PL_CLIENT_ID = P_CLIENT_ID
                             AND PT.PT_ID = P.PL_TYPE
                             AND PT.PT_GROUP_TYPE = 'HW'
                             AND PT.PT_ID = 'GB'),
                  POL
                  AS (SELECT MAX (BM.BM_POLICY) BM_POLICY, P_PLAN_ID PLAN_ID
                        FROM TBL_BENEFITS_MASTER BM
                       WHERE     BM.BM_PLAN = P_PLAN_ID
                             AND BM.BM_CLIENT_ID = P_CLIENT_ID)
             SELECT TO_CHAR (PLAN.PL_HW_MONTHEND, 'FMMonth YYYY') MONTH_END,
                    M.CO_NAME,
                    M.CO_NUMBER,
                    POL.BM_POLICY POLICY_NUMBER,
                    W.CH_ADDRESS1 || ' ' || W.CH_ADDRESS2 ADDRESS,
                    PLAN.PL_NAME REFERENCE,
                    W.CH_CITY || ' ' || W.CH_PROV CITY,
                    TO_CHAR (SYSDATE, 'DD-MON-YYYY') DATE_PREPARED,
                    W.CH_POSTAL_CODE,
                    TO_CHAR (PLAN.PL_HW_MONTHEND, 'DD-MON-YYYY') BILLING_DATE,
                    W.CH_CONTACT,
                    TO_CHAR (
                       (SELECT EIH_CLOSE_BAL
                          FROM (SELECT EIH_MTH,
                                       EIH_CLOSE_BAL,
                                       MAX (
                                          EIH_MTH)
                                       OVER (
                                          PARTITION BY EIH_CLIENT_ID,
                                                       EIH_PLAN_ID,
                                                       EIH_ER_ID)
                                          MAX_EIH_MTH
                                  FROM TBL_EMPLOYER_INVOICES_HW
                                 WHERE     EIH_CLIENT_ID = M.CO_CLIENT
                                       AND EIH_PLAN_ID = M.CO_PLAN
                                       AND EIH_ER_ID = M.CO_NUMBER)
                         WHERE EIH_MTH = MAX_EIH_MTH),
                       'FM999G999G990D00')
                       PREVIOUS_STMT,
                    '21254' LAST_CHEQUE,
                    TO_CHAR (SYSDATE, 'DD-MON-YYYY') LAST_CHEQUE_DATE,
                    TO_CHAR (
                       (SELECT SUM (TPR_PAYMENT_AMT)
                          FROM TBL_PAYMENTS_RECD
                         WHERE     TPR_CLIENT_ID = M.CO_CLIENT
                               AND TPR_PLAN_ID = M.CO_PLAN
                               AND TPR_ER_ID = M.CO_NUMBER
                               AND TRUNC (TPR_RECD_DATE) = TRUNC (SYSDATE)),
                       'FM999G999G990D00')
                       PREVIOUS_PAYMENT,
                    0 MISC,
                    (SELECT NVL (SUM (BEN_BILL), 0)
                       FROM TBL_MEMBER_BENEFIT_ADJ
                      WHERE     CLIENT_ID = M.CO_CLIENT
                            AND PLAN_ID = M.CO_PLAN
                            AND EMPLOYER = M.CO_NUMBER)
                       ADJ_PRIOR_PERIODS,
                    (SELECT SUM (ADMIN_AMT)
                       FROM MEMBER_BENEFITS_TEMP
                      WHERE     CLIENT_ID = M.CO_CLIENT
                            AND PLAN_ID = M.CO_PLAN
                            AND EMPLOYER = M.CO_NUMBER)
                       ADMIN_FEE,
                    0 HSA_ADMIN_FEE,                             -- function ?
                    (SELECT SUM (BEN_BILL)
                       FROM MEMBER_BENEFITS_TEMP
                      WHERE     CLIENT_ID = M.CO_CLIENT
                            AND PLAN_ID = M.CO_PLAN
                            AND EMPLOYER = M.CO_NUMBER)
                       CURRENT_PERIOD,
                    PLAN.PL_GST_NUMBER GST_NUMBER,
                    0 GST_PAYABLE,                               -- function ?
                    0 PST_PAYABLE,                               -- function ?
                    TO_CHAR (
                         PLAN.PL_HW_MONTHEND
                       + NVL (PLAN.PL_PAY_GRACE_PERIOD, 14),
                       'DD-MON-YYYY')
                       TOTAL_DUE_DATE,
                    M.CO_NUMBER EMPLOYEER_ID,
                    PLAN.PL_ADDRESS,
                    PLAN.PL_CITY,
                    PLAN.PL_POST_CODE,
                    PLAN.PL_PHONE,
                    PLAN.PL_LOGO
               FROM POL,
                    PLAN,
                    TBL_COMPHW W,
                    TBL_COMPMAST M
              WHERE     M.CO_PLAN = P_PLAN_ID
                    AND M.CO_CLIENT = P_CLIENT_ID
                    AND W.CH_PLAN(+) = M.CO_PLAN
                    AND W.CH_CLIENT_ID(+) = M.CO_CLIENT
                    AND W.CH_NUMBER(+) = M.CO_NUMBER
                    AND (P_EMPLOYER_ID IS NULL OR M.CO_NUMBER = P_EMPLOYER_ID)
                    AND PLAN.PL_ID(+) = M.CO_PLAN
                    AND POL.PLAN_ID(+) = M.CO_PLAN)
      LOOP
         L_EMPLOYER.MONTH_END := E.MONTH_END;
         L_EMPLOYER.CO_NAME := E.CO_NAME;
         L_EMPLOYER.CO_NUMBER := E.CO_NUMBER;
         L_EMPLOYER.POLICY_NUMBER := E.POLICY_NUMBER;
         L_EMPLOYER.ADDRESS := E.ADDRESS;
         L_EMPLOYER.REFERENCE := E.REFERENCE;
         L_EMPLOYER.CITY := E.CITY;
         L_EMPLOYER.DATE_PREPARED := E.DATE_PREPARED;
         L_EMPLOYER.CH_POSTAL_CODE := E.CH_POSTAL_CODE;
         L_EMPLOYER.BILLING_DATE := E.BILLING_DATE;
         L_EMPLOYER.CH_CONTACT := E.CH_CONTACT;
         L_EMPLOYER.PREVIOUS_STMT := E.PREVIOUS_STMT;
         L_EMPLOYER.LAST_CHEQUE := E.LAST_CHEQUE;
         L_EMPLOYER.LAST_CHEQUE_DATE := E.LAST_CHEQUE_DATE;
         L_EMPLOYER.PREVIOUS_PAYMENT := E.PREVIOUS_PAYMENT;
         L_EMPLOYER.MISC := E.MISC;
         L_EMPLOYER.ADJ_PRIOR_PERIODS := E.ADJ_PRIOR_PERIODS;
         L_EMPLOYER.ADMIN_FEE := E.ADMIN_FEE;
         L_EMPLOYER.HSA_ADMIN_FEE := E.HSA_ADMIN_FEE;
         L_EMPLOYER.CURRENT_PERIOD := E.CURRENT_PERIOD;
         L_EMPLOYER.GST_NUMBER := E.GST_NUMBER;
         L_EMPLOYER.GST_PAYABLE := E.GST_PAYABLE;
         L_EMPLOYER.PST_PAYABLE := E.PST_PAYABLE;
         L_EMPLOYER.SUBTOTAL_CURR_CHARGES :=
              NVL (E.ADJ_PRIOR_PERIODS, 0)
            + NVL (E.ADMIN_FEE, 0)
            + NVL (E.HSA_ADMIN_FEE, 0)
            + NVL (E.CURRENT_PERIOD, 0)
            + NVL (E.GST_PAYABLE, 0)
            + NVL (E.PST_PAYABLE, 0);

         L_EMPLOYER.TOTAL_DUE_NOW := L_EMPLOYER.SUBTOTAL_CURR_CHARGES;
         L_EMPLOYER.TOTAL_DUE_DATE := E.TOTAL_DUE_DATE;
         L_EMPLOYER.EMPLOYEER_ID := E.EMPLOYEER_ID;
         L_EMPLOYER.PL_ADDRESS := E.PL_ADDRESS;
         L_EMPLOYER.PL_CITY := E.PL_CITY;
         L_EMPLOYER.PL_POST_CODE := E.PL_POST_CODE;
         L_EMPLOYER.PL_PHONE := E.PL_PHONE;
         L_EMPLOYER.PL_LOGO := E.PL_LOGO;
         PIPE ROW (L_EMPLOYER);
         L_ROWS_COUNT := L_ROWS_COUNT + 1;
      END LOOP;

      IF L_ROWS_COUNT = 0
      THEN
         PIPE ROW (L_EMPLOYER);
      END IF;
   END GET_EMPLOYERS;

   FUNCTION GET_EMPLOYER_CLASSES (P_PLAN_ID        VARCHAR2,
                                  P_CLIENT_ID      VARCHAR2,
                                  P_EMPLOYER_ID    VARCHAR2)
      RETURN T_BEN_CLASSES
      PIPELINED
   IS
      L_MOC_CLASS    T_BEN_CLASS;
      L_ROWS_COUNT   PLS_INTEGER := 0;
   BEGIN
      FOR C IN (  SELECT TEC_CLASS
                    FROM TBL_EMPLOYER_CLASSES
                   WHERE     TEC_PLAN_ID = P_PLAN_ID
                         AND TEC_CLIENT_ID = P_CLIENT_ID
                         AND TEC_ER_ID = P_EMPLOYER_ID
                       
                         AND (SELECT COUNT (*)
                                FROM MEMBER_BENEFITS_TEMP B
                               WHERE     B.PLAN_ID = P_PLAN_ID
                                     AND B.CLIENT_ID = P_CLIENT_ID
                                     AND B.EMPLOYER = P_EMPLOYER_ID
                                     AND B.BEN_CLASS = TEC_CLASS) > 0 
                GROUP BY TEC_CLASS)
      LOOP
         PIPE ROW (C);
         L_ROWS_COUNT := L_ROWS_COUNT + 1;
      END LOOP;

      IF L_ROWS_COUNT = 0
      THEN
         PIPE ROW (L_MOC_CLASS);
      END IF;
   END GET_EMPLOYER_CLASSES;

   FUNCTION GET_MEMBERS_BENEFITS (P_PLAN_ID        VARCHAR2,
                                  P_CLIENT_ID      VARCHAR2,
                                  P_EMPLOYER_ID    VARCHAR2,
                                  P_BEN_CLASS      VARCHAR2,
                                  P_SAL_DATE       DATE)
      RETURN T_MEMBERS_BENEFITS
      PIPELINED
   IS
      L_MEMBER_BENEFITS   T_MEMBER_BENEFITS;
   BEGIN
      FOR M
         IN (  SELECT B.MEM_FIRST_NAME || ' ' || B.MEM_LAST_NAME MEM_NAME,
                      B.MEM_ID,
                      B.BM_BEN_GROUP BENEFIT_GROUP,
                      COVERGAE,
                      BEN_BILL,
                      GET_SALARY (B.CLIENT_ID,
                                  B.PLAN_ID,
                                  B.MEM_ID,
                                  NULL,
                                  P_SAL_DATE)
                         MEM_SALARY
                 FROM MEMBER_BENEFITS_TEMP B
                WHERE     B.PLAN_ID = P_PLAN_ID
                      AND B.CLIENT_ID = P_CLIENT_ID
                      AND B.EMPLOYER = P_EMPLOYER_ID
                      AND B.BEN_CLASS = P_BEN_CLASS
             ORDER BY B.MEM_ID)
      LOOP
         IF     L_MEMBER_BENEFITS.MEM_ID IS NOT NULL
            AND L_MEMBER_BENEFITS.MEM_ID <> M.MEM_ID
         THEN
            PIPE ROW (L_MEMBER_BENEFITS);
            L_MEMBER_BENEFITS := NULL;
         END IF;

         IF L_MEMBER_BENEFITS.MEM_ID IS NULL
         THEN
            L_MEMBER_BENEFITS.MEM_NAME := M.MEM_NAME;
            L_MEMBER_BENEFITS.MEM_ID := M.MEM_ID;
            L_MEMBER_BENEFITS.MEM_SALARY := M.MEM_SALARY;
         END IF;

         IF M.BENEFIT_GROUP = 'LIFE'
         THEN
            L_MEMBER_BENEFITS.LIFE_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.LIFE_BILL := M.BEN_BILL;
         END IF;

         IF M.BENEFIT_GROUP = 'ADD'
         THEN
            L_MEMBER_BENEFITS.ADD_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.ADD_BILL := M.BEN_BILL;
         END IF;

         IF M.BENEFIT_GROUP = 'LTD'
         THEN
            L_MEMBER_BENEFITS.LTD_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.LTD_BILL := M.BEN_BILL;
         END IF;

         IF M.BENEFIT_GROUP = 'STD'
         THEN
            L_MEMBER_BENEFITS.STD_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.STD_BILL := M.BEN_BILL;
         END IF;

         IF M.BENEFIT_GROUP = 'EHB'
         THEN
            L_MEMBER_BENEFITS.EHB_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.EHB_BILL := M.BEN_BILL;
         END IF;

         IF M.BENEFIT_GROUP = 'VISION'
         THEN
            L_MEMBER_BENEFITS.VISION_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.VISION_BILL := M.BEN_BILL;
         END IF;

         IF M.BENEFIT_GROUP = 'DENT'
         THEN
            L_MEMBER_BENEFITS.DENT_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.EFAP_BILL := M.BEN_BILL;
         END IF;

         IF M.BENEFIT_GROUP = 'EFAP'
         THEN
            L_MEMBER_BENEFITS.EFAP_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.EFAP_BILL := M.BEN_BILL;
         END IF;

         IF M.BENEFIT_GROUP = 'OLIFE'
         THEN
            L_MEMBER_BENEFITS.OLIFE_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.OLIFE_BILL := M.BEN_BILL;
         END IF;

         IF M.BENEFIT_GROUP = 'VADD'
         THEN
            L_MEMBER_BENEFITS.VADD_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.VADD_BILL := M.BEN_BILL;
         END IF;

         IF M.BENEFIT_GROUP = 'OSPOUSE'
         THEN
            L_MEMBER_BENEFITS.OSPOUSE_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.OSPOUSE_BILL := M.BEN_BILL;
         END IF;

         IF M.BENEFIT_GROUP = 'OCHILD'
         THEN
            L_MEMBER_BENEFITS.OCHILD_COVERAGE := M.COVERGAE;
            L_MEMBER_BENEFITS.OCHILD_BILL := M.BEN_BILL;
         END IF;
      END LOOP;

      IF L_MEMBER_BENEFITS.MEM_ID IS NOT NULL
      THEN
         PIPE ROW (L_MEMBER_BENEFITS);
      END IF;
   END GET_MEMBERS_BENEFITS;

   FUNCTION GET_BENEFITS_SUMMARY (P_PLAN_ID        VARCHAR2,
                                  P_CLIENT_ID      VARCHAR2,
                                  P_EMPLOYER_ID    VARCHAR2)
      RETURN T_BENEFITS_SUMMARY
      PIPELINED
   IS
      L_BEN_SUMMARY   T_BEN_SUMMARY;
      L_ROWS_COUNT    PLS_INTEGER := 0;
   BEGIN
      FOR S
         IN (  SELECT B.BENDESC BEN_DESC,
                      BM.BM_BEN_TYPE REL_CODE,
                      SUBSTR (BM.BM_CODE, -1) FLEX_CODE,
                      COUNT (*) EMP_COUNT,
                      SUM (
                         CASE
                            WHEN TRIM (
                                    TRANSLATE (B.COVERGAE,
                                               ' .,0123456789',
                                               '              '))
                                    IS NULL
                            THEN
                               NVL (TO_NUMBER (B.COVERGAE), 0)
                            ELSE
                               0
                         END)
                         VOL_BILLED,
                      SUM (B.BEN_BILL) PRM_BILLED,
                      0.00 RET_PREMIUMS,
                      0.00 RET_CREDITS,
                      SUM (B.BEN_BILL) + 0.00 + 0.00 BEN_TOTALS
                 FROM TBL_BENEFITS_MASTER BM, MEMBER_BENEFITS_TEMP B
                WHERE     B.PLAN_ID = P_PLAN_ID
                      AND B.CLIENT_ID = P_CLIENT_ID
                      AND B.EMPLOYER = P_EMPLOYER_ID
                      AND BM.BM_PLAN = B.PLAN_ID
                      AND BM.BM_CLIENT_ID = B.CLIENT_ID
                      AND BM.BM_CODE = B.CODE
             GROUP BY B.BENDESC, BM.BM_BEN_TYPE, BM.BM_CODE)
      LOOP
         L_BEN_SUMMARY.BEN_DESC := S.BEN_DESC;
         L_BEN_SUMMARY.REL_CODE := S.REL_CODE;
         L_BEN_SUMMARY.FLEX_CODE := S.FLEX_CODE;
         L_BEN_SUMMARY.EMP_COUNT := S.EMP_COUNT;
         L_BEN_SUMMARY.VOL_BILLED := S.VOL_BILLED;
         L_BEN_SUMMARY.PRM_BILLED := S.PRM_BILLED;
         L_BEN_SUMMARY.RET_PREMIUMS := S.RET_PREMIUMS;
         L_BEN_SUMMARY.RET_CREDITS := S.RET_CREDITS;
         L_BEN_SUMMARY.BEN_TOTALS := S.BEN_TOTALS;
         PIPE ROW (L_BEN_SUMMARY);
         L_ROWS_COUNT := L_ROWS_COUNT + 1;
      END LOOP;

      IF L_ROWS_COUNT = 0
      THEN
         PIPE ROW (L_BEN_SUMMARY);
      END IF;
   END GET_BENEFITS_SUMMARY;

   FUNCTION GET_REPORT_DATA (P_PLAN_ID        VARCHAR2,
                             P_CLIENT_ID      VARCHAR2,
                             P_EMPLOYER_ID    VARCHAR2)
      RETURN CLOB
   IS
      L_CURSOR   SYS_REFCURSOR;
      L_RETURN   CLOB;
   BEGIN
      --logger.log('AOP test start');
      APEX_JSON.INITIALIZE_CLOB_OUTPUT (DBMS_LOB.CALL, TRUE, 2);
      DELETE FROM MEMBER_BENEFITS_TEMP;
      Insert into MEMBER_BENEFITS_TEMP (BM_BEN_GROUP,EMPLOYER,BM_BEN_TYPE,CLIENT_ID,PLAN_ID,MEM_ID,BEN_CLASS,CODE,BENDESC,MEM_LAST_NAME,MEM_FIRST_NAME,MEM_DOB,MEM_GENDER,COVERGAE,BEN_BILL,HW_SMOKER,CARRIER_RATE,ADMIN_RATE,AGENT_RATE,ADMIN_AMT)
      (SELECT BM_BEN_GROUP,EMPLOYER,BM_BEN_TYPE,CLIENT_ID,PLAN_ID,MEM_ID,BEN_CLASS,CODE,BENDESC,MEM_LAST_NAME,MEM_FIRST_NAME,MEM_DOB,MEM_GENDER,COVERGAE,BEN_BILL,HW_SMOKER,CARRIER_RATE,ADMIN_RATE,AGENT_RATE,ADMIN_AMT FROM MEMBER_BENEFITS_TEMP);
      
      
      OPEN L_CURSOR FOR
         SELECT 'premium_statement_report' "filename",
                CURSOR (
                   SELECT CURSOR (
                             SELECT MONTH_END AS "month_end",
                                    CO_NAME AS "co_name",
                                    CO_NUMBER AS "co_number",
                                    POLICY_NUMBER AS "policy_number",
                                    ADDRESS AS "address",
                                    REFERENCE AS "reference",
                                    CITY AS "city",
                                    DATE_PREPARED AS "date_prepared",
                                    CH_POSTAL_CODE AS "ch_postal_code",
                                    BILLING_DATE AS "billing_date",
                                    CH_CONTACT AS "ch_contact",
                                    PREVIOUS_STMT AS "previous_stmt",
                                    LAST_CHEQUE AS "last_cheque",
                                    LAST_CHEQUE_DATE AS "last_cheque_date",
                                    PREVIOUS_PAYMENT AS "previous_payment",
                                    TO_CHAR (MISC, 'FML999G999G990D00')
                                       AS "misc",
                                    TO_CHAR (ADJ_PRIOR_PERIODS,
                                             'FML999G999G990D00')
                                       AS "adj_prior_periods",
                                    TO_CHAR (ADMIN_FEE, 'FML999G999G990D00')
                                       AS "admin_fee",
                                    TO_CHAR (HSA_ADMIN_FEE,
                                             'FML999G999G990D00')
                                       AS "hsa_admin_fee",
                                    TO_CHAR (CURRENT_PERIOD,
                                             'FML999G999G990D00')
                                       AS "current_period",
                                    GST_NUMBER AS "gst_number",
                                    TO_CHAR (GST_PAYABLE,
                                             'FML999G999G990D00')
                                       AS "gst_payable",
                                    TO_CHAR (PST_PAYABLE,
                                             'FML999G999G990D00')
                                       AS "pst_payable",
                                    TO_CHAR (SUBTOTAL_CURR_CHARGES,
                                             'FML999G999G990D00')
                                       AS "subtotal_curr_charges",
                                    TO_CHAR (TOTAL_DUE_NOW,
                                             'FML999G999G990D00')
                                       AS "total_due_now",
                                    TOTAL_DUE_DATE AS "total_due_date",
                                    CO_NUMBER AS "employeer_id",
                                    PL_ADDRESS AS "pl_address",
                                    PL_CITY AS "pl_city",
                                    PL_POST_CODE AS "pl_post_code",
                                    PL_PHONE AS "pl_phone",
                                    PL_LOGO AS "pl_logo",
                                    120 AS "pl_logo_max_width",
                                    120 AS "pl_logo_max_height",
                                    CURSOR (
                                       SELECT BEN_CLASS AS "ben_class",
                                              CURSOR (
                                                 SELECT MEM_NAME
                                                           AS "mem_name",
                                                        MEM_ID AS "mem_id",
                                                        TO_CHAR (
                                                           NVL (MEM_SALARY,
                                                                0),
                                                           'FML999G999G990D00')
                                                           AS "mem_salary",
                                                        TO_CHAR (
                                                           NVL (
                                                              LIFE_COVERAGE,
                                                              0),
                                                           'FML999G999G990D00')
                                                           AS "life_coverage",
                                                        TO_CHAR (
                                                           NVL (LIFE_BILL, 0),
                                                           'FML999G999G990D00')
                                                           AS "life_bill",
                                                        TO_CHAR (
                                                           NVL (ADD_COVERAGE,
                                                                0),
                                                           'FML999G999G990D00')
                                                           AS "add_coverage",
                                                        TO_CHAR (
                                                           NVL (ADD_BILL, 0),
                                                           'FML999G999G990D00')
                                                           AS "add_bill",
                                                        TO_CHAR (
                                                           NVL (LTD_COVERAGE,
                                                                0),
                                                           'FML999G999G990D00')
                                                           AS "ltd_coverage",
                                                        TO_CHAR (
                                                           NVL (LTD_BILL, 0),
                                                           'FML999G999G990D00')
                                                           AS "ltd_bill",
                                                        STD_COVERAGE
                                                           AS "std_coverage",
                                                        TO_CHAR (
                                                           NVL (STD_BILL, 0),
                                                           'FML999G999G990D00')
                                                           AS "std_bill",
                                                        DECODE (
                                                           EHB_COVERAGE,
                                                           'S', 'Single',
                                                           'C', 'Cloupe',
                                                           'F', 'Family',
                                                           EHB_COVERAGE)
                                                           AS "ehb_coverage",
                                                        TO_CHAR (
                                                           NVL (EHB_BILL, 0),
                                                           'FML999G999G990D00')
                                                           AS "ehb_bill",
                                                        VISION_COVERAGE
                                                           AS "vision_coverage",
                                                        TO_CHAR (
                                                           NVL (VISION_BILL,
                                                                0),
                                                           'FML999G999G990D00')
                                                           AS "vision_bill",
                                                        DENT_COVERAGE
                                                           AS "dent_coverage",
                                                        TO_CHAR (
                                                           NVL (DENT_BILL, 0),
                                                           'FML999G999G990D00')
                                                           AS "dent_bill",
                                                        EFAP_COVERAGE
                                                           AS "efap_coverage",
                                                        TO_CHAR (
                                                           NVL (EFAP_BILL, 0),
                                                           'FML999G999G990D00')
                                                           AS "efap_bill",
                                                        OLIFE_COVERAGE
                                                           AS "olife_coverage",
                                                        TO_CHAR (
                                                           NVL (OLIFE_BILL,
                                                                0),
                                                           'FML999G999G990D00')
                                                           AS "olife_bill",
                                                        VADD_COVERAGE
                                                           AS "vadd_coverage",
                                                        TO_CHAR (
                                                           NVL (VADD_BILL, 0),
                                                           'FML999G999G990D00')
                                                           AS "vadd_bill",
                                                        OSPOUSE_COVERAGE
                                                           AS "ospouse_coverage",
                                                        TO_CHAR (
                                                           NVL (OSPOUSE_BILL,
                                                                0),
                                                           'FML999G999G990D00')
                                                           AS "ospouse_bill",
                                                        OCHILD_COVERAGE
                                                           AS "ochild_coverage",
                                                        TO_CHAR (
                                                           NVL (OCHILD_BILL,
                                                                0),
                                                           'FML999G999G990D00')
                                                           AS "ochild_bill",
                                                        TO_CHAR (
                                                             NVL (LIFE_BILL,
                                                                  0)
                                                           + NVL (ADD_BILL,
                                                                  0)
                                                           + NVL (LTD_BILL,
                                                                  0)
                                                           + NVL (STD_BILL,
                                                                  0)
                                                           + NVL (EHB_BILL,
                                                                  0)
                                                           + NVL (
                                                                VISION_BILL,
                                                                0)
                                                           + NVL (DENT_BILL,
                                                                  0)
                                                           + NVL (EFAP_BILL,
                                                                  0)
                                                           + NVL (OLIFE_BILL,
                                                                  0)
                                                           + NVL (VADD_BILL,
                                                                  0)
                                                           + NVL (
                                                                OSPOUSE_BILL,
                                                                0)
                                                           + NVL (
                                                                OCHILD_BILL,
                                                                0),
                                                           'FML999G999G990D00')
                                                           AS "mem_total"
                                                   FROM TABLE (
                                                           GET_MEMBERS_BENEFITS (
                                                              P_PLAN_ID,
                                                              P_CLIENT_ID,
                                                              P_EMPLOYER_ID,
                                                              BEN_CLASS,
                                                              TO_DATE (
                                                                 E.MONTH_END,
                                                                 'FMMonth YYYY',
                                                                 'NLS_DATE_LANGUAGE=american'))))
                                                 AS "MEMBER_BENEFITS_TEMP"
                                         FROM TABLE (
                                                 GET_EMPLOYER_CLASSES (
                                                    P_PLAN_ID,
                                                    P_CLIENT_ID,
                                                    P_EMPLOYER_ID)))
                                       AS "employer_classes",
                                    CURSOR (
                                       SELECT BEN_DESC AS "ben_desc",
                                              REL_CODE AS "rel_code",
                                              FLEX_CODE AS "flex_code",
                                              EMP_COUNT AS "emp_count",
                                              TO_CHAR (NVL (VOL_BILLED, 0),
                                                       'FML999G999G990D00')
                                                 AS "vol_billed",
                                              TO_CHAR (NVL (PRM_BILLED, 0),
                                                       'FML999G999G990D00')
                                                 AS "prm_billed",
                                              TO_CHAR (NVL (RET_PREMIUMS, 0),
                                                       'FML999G999G990D00')
                                                 AS "ret_premiums",
                                              TO_CHAR (NVL (RET_CREDITS, 0),
                                                       'FML999G999G990D00')
                                                 AS "ret_credits",
                                              TO_CHAR (NVL (BEN_TOTALS, 0),
                                                       'FML999G999G990D00')
                                                 AS "ben_totals"
                                         FROM TABLE (
                                                 GET_BENEFITS_SUMMARY (
                                                    P_PLAN_ID,
                                                    P_CLIENT_ID,
                                                    P_EMPLOYER_ID)))
                                       AS "benefits_summary",
                                    CURSOR (
                                       SELECT TO_CHAR (
                                                 NVL (SUM (PRM_BILLED), 0),
                                                 'FML999G999G990D00')
                                                 AS "prm_billed_t",
                                              TO_CHAR (
                                                 NVL (SUM (RET_PREMIUMS), 0),
                                                 'FML999G999G990D00')
                                                 AS "ret_premiums_t",
                                              TO_CHAR (
                                                 NVL (SUM (RET_CREDITS), 0),
                                                 'FML999G999G990D00')
                                                 AS "ret_credits_t",
                                              TO_CHAR (
                                                 NVL (SUM (BEN_TOTALS), 0),
                                                 'FML999G999G990D00')
                                                 AS "ben_totals_t"
                                         FROM TABLE (
                                                 GET_BENEFITS_SUMMARY (
                                                    P_PLAN_ID,
                                                    P_CLIENT_ID,
                                                    P_EMPLOYER_ID)))
                                       AS "benefits_totals"
                               FROM TABLE (
                                       GET_EMPLOYERS (P_PLAN_ID,
                                                      P_CLIENT_ID,
                                                      P_EMPLOYER_ID)) E)
                             "employers"
                     FROM DUAL)
                   "data"
           FROM DUAL;

      APEX_JSON.WRITE (L_CURSOR);
      L_RETURN := APEX_JSON.GET_CLOB_OUTPUT;

      --logger.log('AOP test finishied');
      RETURN L_RETURN;
   END GET_REPORT_DATA;
END PKG_PREMIUM_STMT_rao2;
/

