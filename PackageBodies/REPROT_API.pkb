--
-- REPROT_API  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.REPROT_API AS

    FUNCTION GET_HR_BANK (
        P_PLAN_ID VARCHAR2,
        P_MEM_ID VARCHAR2
    ) RETURN NUMBER AS
        V_PL_HW_MONTHEND   DATE;
        V_HR_BANK          NUMBER;
    BEGIN
        SELECT
            PL_HW_MONTHEND
        INTO
            V_PL_HW_MONTHEND
        FROM
            TBL_PLAN
        WHERE
            PL_ID = P_PLAN_ID;

        SELECT
            SUM(NVL(THB_HOURS,0) )
        INTO
            V_HR_BANK
        FROM
            TBL_HR_BANK B
        WHERE
            B.THB_ID = P_MEM_ID
            AND   B.THB_PLAN = P_PLAN_ID
            AND   B.THB_MONTH = V_PL_HW_MONTHEND;

        RETURN V_HR_BANK;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END;

    FUNCTION FIRST_TIME (
        PL_ID   VARCHAR2,
        EE_ID   VARCHAR2,
        MTH     DATE
    ) RETURN VARCHAR2 AS
        CNT   NUMBER;
    BEGIN
        IF
            MTH IS NULL
        THEN
            RETURN 'FALSE';
        END IF;
        SELECT
            COUNT(*)
        INTO
            CNT
        FROM
            TBL_HR_BANK
        WHERE
            THB_ID = EE_ID
            AND   THB_PLAN = PL_ID
            AND   NVL(THB_DEDUCT_HRS,0) > 0
            AND   THB_MONTH < MTH;

        IF
            NVL(CNT,0) > 0
        THEN
            RETURN 'FALSE';
        ELSE
            RETURN 'TRUE';
        END IF;

    END FIRST_TIME;

    FUNCTION GET_COVERAGE (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_MEM_ID      VARCHAR2
    ) RETURN VARCHAR2 AS
        V_PL_HW_MONTHEND   DATE;
        V_ELIGIBILITY      VARCHAR2(1);
        V_COVERAGE         VARCHAR2(12);
    BEGIN
        SELECT
            PL_HW_MONTHEND
        INTO
            V_PL_HW_MONTHEND
        FROM
            TBL_PLAN
        WHERE
            PL_ID = P_PLAN_ID;

        FOR C_COUNT IN 1..12 LOOP
            V_ELIGIBILITY := HR_BANK_PKG.IS_ELIGIBLE(P_CLIENT_ID,P_PLAN_ID,NULL,P_MEM_ID,ADD_MONTHS(V_PL_HW_MONTHEND,-C_COUNT) );

            IF
                V_ELIGIBILITY = 'Y'
            THEN
                V_COVERAGE := SUBSTR(TO_CHAR(ADD_MONTHS(V_PL_HW_MONTHEND,-C_COUNT),'MON'),1,1)
                || V_COVERAGE;

            ELSE
                V_COVERAGE := '*'
                || V_COVERAGE;
            END IF;

        END LOOP;

        RETURN V_COVERAGE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END;

    FUNCTION GET_CONT_BY_MONTH (
        P_PLAN_ID     VARCHAR2,
        P_ER_ID       VARCHAR2,
        P_MONTH_END   DATE,
        P_MONTH       DATE
    ) RETURN NUMBER AS
        V_AMOUNT   NUMBER;
    BEGIN
        SELECT
            SUM(NVL(TH_AMOUNT,0) )
        INTO
            V_AMOUNT
        FROM
            TRANSACTION_HEADER
        WHERE
            TH_EMPLOYER = P_ER_ID
            AND   TH_PLAN_ID = P_PLAN_ID
            AND   TRUNC(TH_POSTED_DATE,'mm') = P_MONTH_END
            AND   TRUNC(TH_PERIOD,'mm') = P_MONTH;

        RETURN NVL(V_AMOUNT,0);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END GET_CONT_BY_MONTH;

    FUNCTION GET_CONT_BY_LATE_MONTH (
        P_PLAN_ID     VARCHAR2,
        P_ER_ID       VARCHAR2,
        P_MONTH_END   DATE,
        P_MONTH       DATE
    ) RETURN NUMBER AS
        V_AMOUNT   NUMBER;
    BEGIN
        SELECT
            SUM(NVL(TH_AMOUNT,0) )
        INTO
            V_AMOUNT
        FROM
            TRANSACTION_HEADER
        WHERE
            TH_EMPLOYER = P_ER_ID
            AND   TH_PLAN_ID = P_PLAN_ID
            AND   TRUNC(TH_POSTED_DATE,'mm') = P_MONTH_END
            AND   TRUNC(TH_PERIOD,'mm') < P_MONTH;

        RETURN NVL(V_AMOUNT,0);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END GET_CONT_BY_LATE_MONTH;

    PROCEDURE DOCUMENT_UPLOAD (
        P_DOC_NAME   VARCHAR2,
        P_PLAN_ID    VARCHAR2,
        P_NAME       VARCHAR2
    )
        AS
    BEGIN
        FOR C_BLOB IN (
            SELECT
                FILENAME,
                MIME_TYPE,
                BLOB_CONTENT
            FROM
                FLOWS_FILES.WWV_FLOW_FILE_OBJECTS$
            WHERE
                NAME = P_NAME
            ORDER BY
                CREATED_ON DESC
        ) LOOP
            UPDATE TBL_DOCUMENT
                SET
                    DOC_ATTACHMENT = C_BLOB.BLOB_CONTENT,
                    DOC_FILE_NAME = C_BLOB.FILENAME,
                    DOC_MIME_TYPE = C_BLOB.MIME_TYPE
            WHERE
                DOC_NAME = P_DOC_NAME
                AND   DOC_PLAN = P_PLAN_ID;

            EXIT;  --get latest upload file
        END LOOP;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END DOCUMENT_UPLOAD;

    FUNCTION GET_NOTES (
        P_PLAN_ID VARCHAR2,
        P_CLAIM_NUMBER VARCHAR2
    ) RETURN VARCHAR2 AS
        V_COMMENT_CODE   VARCHAR2(200);
        V_COMMENT_DESC   VARCHAR2(2000);
        V_RESULT         VARCHAR2(2000);
    BEGIN
  --select LISTAGG(CL_COMMENT, ':')  WITHIN GROUP (order by CL_CLAIM_NUMBER ) into v_comment_code
  --FROM TBL_CLAIMS where CL_CLAIM_NUMBER =P_CLAIM_NUMBER and cl_plan = p_plan_id;
        SELECT
            LISTAGG(TCC_COMMENT,
            ':') WITHIN GROUP(
            ORDER BY
                TCC_CLAIM
            )
        INTO
            V_COMMENT_CODE
        FROM
            TBL_CLAIM_COMMENTS
        WHERE
            TCC_PLAN = P_PLAN_ID
            AND   TCC_CLAIM = P_CLAIM_NUMBER;

        FOR C_NOTES IN (
            SELECT DISTINCT
                REGEXP_SUBSTR(V_COMMENT_CODE,'[^:]+',1,LEVEL) NOTE
            FROM
                DUAL
            CONNECT BY
                REGEXP_SUBSTR(V_COMMENT_CODE,'[^:]+',1,LEVEL) IS NOT NULL
            ORDER BY
                1
        ) LOOP  --notes
  --FOR c_notes in (select TCC_COMMENT note from tbl_claim_comments where tcc_plan = p_plan_id AND TCC_CLAIM = P_CLAIM_NUMBER) loop
            SELECT
                THC_DEC
            INTO
                V_COMMENT_DESC
            FROM
                TBL_HW_COMMENTS
            WHERE
                THC_PLAN = P_PLAN_ID
                AND   THC_ID = C_NOTES.NOTE;

            V_RESULT := V_RESULT
            || C_NOTES.NOTE
            || ' - '
            || V_COMMENT_DESC
            || CHR(10)
            || CHR(10);

        END LOOP;

        RETURN V_RESULT;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END GET_NOTES;

    FUNCTION GET_PAYMENT_INFO (
        P_PLAN_ID        VARCHAR2,
        P_CLIENT_ID      VARCHAR2,
        P_CLAIM_NUMBER   VARCHAR2
    ) RETURN VARCHAR2 AS
        V_PAYMENT_INFO   VARCHAR2(300);
    BEGIN
        FOR C_CLAIM IN (
            SELECT
                CL_PAYMENT_TYPE,
                CL_PAYMENT_NUMBER,
                SUM(NVL(CL_AMT_PAID,0) ) PAID
            FROM
                TBL_CLAIMS
            WHERE
                CL_CLAIM_NUMBER = P_CLAIM_NUMBER
                AND   CL_PLAN = P_PLAN_ID
                AND   CL_CLIENT_ID = P_CLIENT_ID
            GROUP BY
                CL_PAYMENT_TYPE,
                CL_PAYMENT_NUMBER
        ) LOOP
            IF
                C_CLAIM.CL_PAYMENT_TYPE = 'CHQ'
            THEN
                V_PAYMENT_INFO := V_PAYMENT_INFO
                || 'Payment ('
                || C_CLAIM.CL_PAYMENT_TYPE
                || ')'
                || C_CLAIM.CL_PAYMENT_NUMBER
                || ' for '
                || C_CLAIM.PAID
                || ' is enclosed'
                || CHR(10);

            ELSIF C_CLAIM.CL_PAYMENT_TYPE = 'EFT' THEN
                V_PAYMENT_INFO := V_PAYMENT_INFO
                || 'Payment ('
                || C_CLAIM.CL_PAYMENT_TYPE
                || ')'
                || C_CLAIM.CL_PAYMENT_NUMBER
                || ' for '
                || C_CLAIM.PAID
                || ' will be deposited directly into your account'
                || CHR(10);
            END IF;
        END LOOP;

        RETURN V_PAYMENT_INFO;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END GET_PAYMENT_INFO;

    FUNCTION GET_EMPLOYER_NAME (
        P_PLAN        VARCHAR2,
        P_CLIENT_ID   VARCHAR2,
        P_ID          VARCHAR2
    ) RETURN VARCHAR2 AS
        V_NAME   VARCHAR2(100);
    BEGIN
        SELECT
            CO_NAME
        INTO
            V_NAME
        FROM
            TBL_COMPMAST
        WHERE
            CO_PLAN = 'ADJ1'
            AND   CO_CLIENT = 'SUMA'
            AND   CO_NUMBER = (
                SELECT
                    HW_EMPLOYER
                FROM
                    TBL_HW
                WHERE
                    HW_PLAN = P_PLAN
                    AND   HW_ID = P_ID
                    AND   HW_CLIENT = P_CLIENT_ID
            );

        RETURN V_NAME;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END GET_EMPLOYER_NAME;

    FUNCTION GET_GRAND_AMOUNT_PAID (
        P_PLAN           VARCHAR2,
        P_CLIENT_ID      VARCHAR2,
        P_CLAIM_NUMBER   VARCHAR2
    ) RETURN VARCHAR2 AS
        V_AMOUNT   VARCHAR2(100);
    BEGIN
        SELECT
            TRIM(TO_CHAR(SUM(NVL(C2.CL_AMT_PAID,0) ),'$99999.99') )
        INTO
            V_AMOUNT
        FROM
            TBL_CLAIMS C2
        WHERE
            C2.CL_CLAIM_NUMBER = P_CLAIM_NUMBER
            AND   C2.CL_PLAN = P_PLAN
            AND   C2.CL_CLIENT_ID = P_CLIENT_ID;

        RETURN V_AMOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END GET_GRAND_AMOUNT_PAID;

    FUNCTION IS_VALID_DEPENDENT (
        P_PLAN        VARCHAR2,
        P_CLIENT_ID   VARCHAR2,
        P_ID          VARCHAR2,
        P_DEP_ID      INTEGER
    ) RETURN VARCHAR2 AS
        V_HW_COUPLE_DEP_NO   INTEGER;
    BEGIN
        SELECT
            HW_COUPLE_DEP_NO
        INTO
            V_HW_COUPLE_DEP_NO
        FROM
            TBL_HW,
            TBL_BENEFIT_COVERAGE_STATUS
        WHERE
            BDS_MEM_ID = HW_ID
            AND   BDS_PL_ID = HW_PLAN
            AND   BDS_COVERAGE = 'C'
            AND   HW_CLIENT = BDS_CLIENT_ID
            AND   HW_ID = P_ID
            AND   HW_PLAN = P_PLAN
            AND   HW_CLIENT = P_CLIENT_ID;

        IF
            V_HW_COUPLE_DEP_NO IS NOT NULL AND V_HW_COUPLE_DEP_NO <> P_DEP_ID
        THEN
            RETURN 'N';
        ELSE
            RETURN 'Y';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Y';
    END IS_VALID_DEPENDENT;

END REPROT_API;
/

