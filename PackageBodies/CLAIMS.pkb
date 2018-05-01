--
-- CLAIMS  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.CLAIMS AS

    FUNCTION COVERAGE (
        PL_ID         VARCHAR2,
        MEM_ID        VARCHAR2,
        DEP_ID        NUMBER,
        SERV_DATE     DATE,
        BEN_CODE      NUMBER,
        CLAIM_ID1     VARCHAR2,
        SERVICE_ID1   NUMBER,
        BENEFIT       VARCHAR2,
        CLIENTID      VARCHAR2
    ) RETURN VARCHAR2 AS
        C   VARCHAR2(10);
    BEGIN
        SELECT
            MAX(BDS_COVERAGE)
        INTO
            C
        FROM
            TBL_BENEFIT_COVERAGE_STATUS
        WHERE
            BDS_CLIENT_ID = CLIENTID
            AND   BDS_PL_ID = PL_ID
            AND   BDS_MEM_ID = MEM_ID
            AND   BDS_BENEFIT = BENEFIT
            AND   NVL(SERV_DATE,SYSDATE) BETWEEN NVL(BDS_EFF_DATE,NVL(SERV_DATE,SYSDATE) ) AND NVL(BDS_TERM_DATE,NVL(SERV_DATE,SYSDATE) );

        RETURN C;
    END;

    FUNCTION IS_ELIGIBLE (
        PL_ID         VARCHAR2,
        MEM_ID        VARCHAR2,
        DEP_ID        NUMBER,
        SERV_DATE     DATE,
        BEN_CODE      NUMBER,
        CLAIM_ID1     VARCHAR2,
        SERVICE_ID1   NUMBER,
        CLIENTID      VARCHAR2
    ) RETURN BOOLEAN AS
        CNT        NUMBER := 0;
        CLM_YEAR   NUMBER;
        CDNO       NUMBER;
    BEGIN
        IF
            SERV_DATE IS NOT NULL
        THEN
            CLM_YEAR := TO_NUMBER(TO_CHAR(SERV_DATE,'rrrr') ) + 1;
        ELSE
            CLM_YEAR := NULL;
        END IF;

        IF
            SERV_DATE IS NOT NULL AND SYSDATE >= TO_DATE('01-apr-'
            || TO_CHAR(CLM_YEAR),'dd-mon-rrrr')
        THEN
            RETURN FALSE;
        ELSIF NVL(DEP_ID,0) IN (
            0,
            99
        ) THEN
            SELECT
                COUNT(*),
                MAX(HW_COUPLE_DEP_NO)
            INTO
                CNT,CDNO
            FROM
                TBL_HW
            WHERE
                HW_CLIENT = CLIENTID
                AND   HW_PLAN = PL_ID
                AND   HW_ID = MEM_ID
                AND   UPPER(NVL(LTRIM(RTRIM(HW_EE_TYPE) ),'RE') ) = 'RE'
                AND   NVL(SERV_DATE,SYSDATE) >= NVL(HW_EFF_DATE,SYSDATE)
                AND   NVL(SERV_DATE,SYSDATE) <= NVL(HW_TERM_DATE,NVL(SERV_DATE,SYSDATE) );

            IF
                NVL(CNT,0) > 0
            THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;

        ELSIF NVL(COVERAGE(PL_ID,MEM_ID,DEP_ID,SERV_DATE,BEN_CODE,CLAIM_ID1,SERVICE_ID1,'VISION',CLIENTID),'F') <> 'S' THEN
            CNT := 0;
            SELECT
                MAX(HW_COUPLE_DEP_NO)
            INTO
                CDNO
            FROM
                TBL_HW
            WHERE
                HW_CLIENT = CLIENTID
                AND   HW_PLAN = PL_ID
                AND   HW_ID = MEM_ID
                AND   UPPER(NVL(LTRIM(RTRIM(HW_EE_TYPE) ),'RE') ) = 'RE'
                AND   NVL(SERV_DATE,SYSDATE) >= NVL(HW_EFF_DATE,SERV_DATE)
                AND   NVL(SERV_DATE,SYSDATE) <= NVL(HW_TERM_DATE,NVL(SERV_DATE,SYSDATE) );

            IF
                NVL(COVERAGE(PL_ID,MEM_ID,DEP_ID,SERV_DATE,BEN_CODE,CLAIM_ID1,SERVICE_ID1,'VISION',CLIENTID),'F') = 'C' AND NVL(CDNO,0) <> 0
            THEN
                SELECT
                    COUNT(*)
                INTO
                    CNT
                FROM
                    TBL_HW_DEPENDANTS
                WHERE
                    HD_CLIENT = CLIENTID
                    AND   HD_PLAN = PL_ID
                    AND   HD_ID = MEM_ID
                    AND   NVL(HD_BEN_NO,0) = NVL(DEP_ID,0)
                    AND   HD_BEN_NO = CDNO
                    AND   NVL(SERV_DATE,SYSDATE) >= NVL(HD_EFF_DATE,SERV_DATE)
                    AND   NVL(SERV_DATE,SYSDATE) <= NVL(HD_TERM_DATE,NVL(SERV_DATE,SYSDATE) );

            ELSE
                SELECT
                    COUNT(*)
                INTO
                    CNT
                FROM
                    TBL_HW_DEPENDANTS
                WHERE
                    HD_CLIENT = CLIENTID
                    AND   HD_PLAN = PL_ID
                    AND   HD_ID = MEM_ID
                    AND   NVL(HD_BEN_NO,0) = NVL(DEP_ID,0)
                    AND   NVL(SERV_DATE,SYSDATE) >= NVL(HD_EFF_DATE,SERV_DATE)
                    AND   NVL(SERV_DATE,SYSDATE) <= NVL(HD_TERM_DATE,NVL(SERV_DATE,SYSDATE) );

            END IF;

            IF
                NVL(CNT,0) > 0
            THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;

        ELSE
            RETURN FALSE;
        END IF;

    END;

    FUNCTION NEXT_VISION_CLAIM (
        PL VARCHAR2,
        CLIENTID VARCHAR2
    ) RETURN VARCHAR2 AS
        R   VARCHAR2(20);
    BEGIN
        SELECT
            'E'
            || NVL( (MAX(TO_NUMBER(SUBSTR(CL_CLAIM_NUMBER,2,10) ) ) + 1),0)
        INTO
            R
        FROM
            TBL_CLAIMS
        WHERE
            CL_CLIENT_ID = CLIENTID
            AND   CL_PLAN = PL;

        RETURN R;
    END NEXT_VISION_CLAIM;

    FUNCTION NEXT_HSA_CLAIM (
        PL VARCHAR2,
        CLIENTID VARCHAR2
    ) RETURN VARCHAR2 AS
        R   VARCHAR2(20);
    BEGIN
        SELECT
            'H'
            || NVL( (MAX(TO_NUMBER(SUBSTR(CL_CLAIM_NUMBER,2,10) ) ) + 1),0)
        INTO
            R
        FROM
            TBL_CLAIMS
        WHERE
            CL_CLIENT_ID = CLIENTID
            AND   CL_PLAN = PL;

        RETURN R;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'H1';
    END NEXT_HSA_CLAIM;

    FUNCTION LATE_APPLICANT (
        PL_ID         VARCHAR2,
        MEM_ID        VARCHAR2,
        DEP_ID        NUMBER,
        SERV_DATE     DATE,
        BEN_CODE      NUMBER,
        CLAIM_ID1     VARCHAR2,
        SERVICE_ID1   NUMBER,
        CLIENTID      VARCHAR2
    ) RETURN VARCHAR2 AS
        CNT   NUMBER := 0;
    BEGIN
        IF
            NVL(DEP_ID,0) = GET_PLAN_MEMBER_IDENTIFIER(PL_ID,CLIENTID)
        THEN
            SELECT
                COUNT(*)
            INTO
                CNT
            FROM
                TBL_HW
            WHERE
                HW_CLIENT = CLIENTID
                AND   HW_PLAN = PL_ID
                AND   HW_ID = MEM_ID
                AND   NVL(HW_LATE_APP,'N') = 'Y'
                AND   NVL(SERV_DATE,SYSDATE) BETWEEN HW_EFF_DATE AND ADD_MONTHS(HW_EFF_DATE,12);

            IF
                NVL(CNT,0) > 0
            THEN
                RETURN 'Late Applicant';
            ELSE
                RETURN NULL;
            END IF;

        ELSE
            SELECT
                COUNT(*)
            INTO
                CNT
            FROM
                TBL_HW_DEPENDANTS
            WHERE
                HD_CLIENT = CLIENTID
                AND   HD_PLAN = PL_ID
                AND   HD_ID = MEM_ID
                AND   NVL(HD_LATE_APP,'N') = 'Y'
                AND   NVL(HD_BEN_NO,0) = NVL(DEP_ID,0)
                AND   NVL(SERV_DATE,SYSDATE) BETWEEN HD_EFF_DATE AND ADD_MONTHS(HD_EFF_DATE,12);

            IF
                NVL(CNT,0) > 0
            THEN
                RETURN 'Late Applicant';
            ELSE
                RETURN NULL;
            END IF;

        END IF;
    END;

    FUNCTION GET_NAME (
        P_PLAN     VARCHAR2,
        P_ID       VARCHAR2,
        P_DEP_NO   INTEGER,
        CLIENTID   VARCHAR2
    ) RETURN VARCHAR2 AS
        V_NAME   VARCHAR2(100);
    BEGIN
        IF
            P_DEP_NO = GET_PLAN_MEMBER_IDENTIFIER(P_PLAN,CLIENTID)
        THEN  --get name from member 
            SELECT
                MEM_FIRST_NAME
                || ' '
                || MEM_LAST_NAME
            INTO
                V_NAME
            FROM
                TBL_MEMBER
            WHERE
                MEM_CLIENT_ID = CLIENTID
                AND   MEM_PLAN = P_PLAN
                AND   MEM_ID = P_ID;

        ELSE
            SELECT
                HD_FIRST_NAME
                || ' '
                || HD_LAST_NAME
            INTO
                V_NAME
            FROM
                TBL_HW_DEPENDANTS
            WHERE
                HD_CLIENT = CLIENTID
                AND   HD_PLAN = P_PLAN
                AND   HD_ID = P_ID
                AND   HD_BEN_NO = P_DEP_NO;

        END IF;

        RETURN V_NAME;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END GET_NAME;

    FUNCTION GET_AVAILABLE_AMT (
        PL_ID         VARCHAR2,
        MEM_ID        VARCHAR2,
        DEP_ID        NUMBER,
        SERV_DATE     DATE,
        BEN_CODE      NUMBER,
        CLAIM_ID1     VARCHAR2,
        SERVICE_ID1   NUMBER,
        CLIENTID      VARCHAR2
    ) RETURN NUMBER AS

        R    NUMBER(12,2) := 0;
        LT   NUMBER(12,2) := 0;
        R1   NUMBER(12,2) := 0;
    BEGIN
        IF
            IS_ELIGIBLE(PL_ID,MEM_ID,DEP_ID,NVL(SERV_DATE,SYSDATE),BEN_CODE,CLAIM_ID1,SERVICE_ID1,CLIENTID)
        THEN
            IF
                LATE_APPLICANT(PL_ID,MEM_ID,DEP_ID,NVL(SERV_DATE,SYSDATE),BEN_CODE,CLAIM_ID1,SERVICE_ID1,CLIENTID) IS NOT NULL
            THEN
                LT := 150;
                SELECT
                    LT - NVL(SUM(CL_AMT_PAID),0)
                INTO
                    R
                FROM
                    TBL_CLAIMS
                WHERE
                    CL_PLAN (+) = PL_ID
                    AND   CL_ID (+) = MEM_ID
                    AND   NVL(CL_DEP_NO(+),0) = NVL(DEP_ID,0)
                    AND   ( CL_SERVICE_DATE (+) BETWEEN ADD_MONTHS(NVL(SERV_DATE,SYSDATE),-1 * 12) AND GREATEST(NVL(SERV_DATE,SYSDATE),SYSDATE) )
                    AND   CL_SERVICE_DATE (+) <= GREATEST(NVL(SERV_DATE,SYSDATE),SYSDATE);

            ELSE
                LT := 500;
                SELECT
                    LT - NVL(SUM(CL_AMT_PAID),0)
                INTO
                    R
                FROM
                    TBL_CLAIMS
                WHERE
                    CL_PLAN (+) = PL_ID
                    AND   CL_ID (+) = MEM_ID
                    AND   NVL(CL_DEP_NO(+),0) = NVL(DEP_ID,0)
                    AND   ( CL_SERVICE_DATE (+) BETWEEN ADD_MONTHS(NVL(SERV_DATE,SYSDATE),-1 * 24) AND GREATEST(NVL(SERV_DATE,SYSDATE),SYSDATE) )
                    AND   CL_SERVICE_DATE (+) <= GREATEST(NVL(SERV_DATE,SYSDATE),SYSDATE);

            END IF;

            SELECT
                NVL(MAX(A.EPB_AMT_ALLOWED),0)
            INTO
                R1
            FROM
                EH_PLAN_BENEFIT A
            WHERE
                A.EPB_CLIENT = CLIENTID
                AND   A.EPB_PLAN = PL_ID
                AND   A.EPB_BEN_CODE = BEN_CODE
                AND   A.EPB_EFF_DATE = (
                    SELECT
                        MAX(B.EPB_EFF_DATE)
                    FROM
                        EH_PLAN_BENEFIT B
                    WHERE
                        B.EPB_CLIENT = CLIENTID
                        AND   B.EPB_PLAN = PL_ID
                        AND   B.EPB_BEN_CODE = BEN_CODE
                        AND   B.EPB_EFF_DATE <= SERV_DATE
                );

            IF
                NVL(R1,0) > 0 AND R1 < R
            THEN
                R := R1;
            END IF;

            IF
                R <= 0
            THEN
                RETURN 0;
            ELSE
                RETURN R;
            END IF;
        ELSE
            RETURN 0;
        END IF;
    END;

    FUNCTION GET_IS_ELIGIBLE_FLAG (
        PL_ID         VARCHAR2,
        MEM_ID        VARCHAR2,
        DEP_ID        NUMBER,
        SERV_DATE     DATE,
        BEN_CODE      NUMBER,
        CLAIM_ID1     VARCHAR2,
        SERVICE_ID1   NUMBER,
        CLIENTID      VARCHAR2
    ) RETURN VARCHAR2 AS
        CNT   NUMBER := 0;
    BEGIN
        IF
            NVL(DEP_ID,0) IN (
                0,
                99
            )
        THEN
            SELECT
                COUNT(*)
            INTO
                CNT
            FROM
                TBL_HW
            WHERE
                HW_CLIENT = CLIENTID
                AND   HW_PLAN = PL_ID
                AND   HW_ID = MEM_ID
                AND   SERV_DATE >= NVL(HW_EFF_DATE,SERV_DATE)
                AND   SERV_DATE <= NVL(HW_TERM_DATE,SERV_DATE);

            IF
                NVL(CNT,0) > 0
            THEN
                RETURN 'Y';
            ELSE
                RETURN 'N';
            END IF;

        ELSIF NVL(COVERAGE(PL_ID,MEM_ID,DEP_ID,SERV_DATE,BEN_CODE,CLAIM_ID1,SERVICE_ID1,'V',CLIENTID),'F') <> 'S' THEN
            SELECT
                COUNT(*)
            INTO
                CNT
            FROM
                TBL_HW_BENEFICIARY
            WHERE
                HB_CLIENT = CLIENTID
                AND   HB_PLAN = PL_ID
                AND   HB_ID = MEM_ID
                AND   NVL(HB_BEN_NO,0) = NVL(DEP_ID,0)
                AND   SERV_DATE >= NVL(HB_EFF_DATE,SERV_DATE)
                AND   SERV_DATE <= NVL(HB_TERM_DATE,SERV_DATE);

            IF
                NVL(CNT,0) > 0
            THEN
                RETURN 'Y';
            ELSE
                RETURN 'N';
            END IF;

        ELSE
            RETURN 'N';
        END IF;
    END;

    FUNCTION GET_NEXT_FULL_COV_DATE (
        PL_ID         VARCHAR2,
        MEM_ID        VARCHAR2,
        DEP_ID        NUMBER,
        SERV_DATE     DATE,
        BEN_CODE      NUMBER,
        CLAIM_ID1     VARCHAR2,
        SERVICE_ID1   NUMBER,
        CLIENTID      VARCHAR2
    ) RETURN DATE AS

        R      DATE;
        LT     NUMBER(12,2) := 0;
        MTHS   NUMBER(12,2) := 0;
    BEGIN
        IF
            IS_ELIGIBLE(PL_ID,MEM_ID,DEP_ID,SERV_DATE,BEN_CODE,CLAIM_ID1,SERVICE_ID1,CLIENTID)
        THEN
            IF
                LATE_APPLICANT(PL_ID,MEM_ID,DEP_ID,SERV_DATE,BEN_CODE,CLAIM_ID1,SERVICE_ID1,CLIENTID) IS NOT NULL
            THEN
                MTHS := 12;
            ELSE
                MTHS := 24;
            END IF;
        ELSE
            MTHS := 0;
        END IF;

        IF
            MTHS <> 0
        THEN
            SELECT
                ADD_MONTHS(NVL(MAX(CL_SERVICE_DATE),ADD_MONTHS(SYSDATE,-1 * MTHS) ),MTHS)
            INTO
                R
            FROM
                TBL_CLAIMS
            WHERE
                CL_CLIENT_ID (+) = CLIENTID
                AND   CL_PLAN (+) = PL_ID
                AND   CL_ID (+) = MEM_ID
                AND   NVL(CL_DEP_NO(+),0) = NVL(DEP_ID,0)
                AND   NVL(CL_AMT_PAID(+),0) > 0;

        ELSE
            R := NULL;
        END IF;

        RETURN R;
    END;

    FUNCTION GET_LAST_PURCHASE (
        P_PLAN     VARCHAR2,
        P_ID       VARCHAR2,
        P_DEP_NO   INTEGER,
        CLIENTID   VARCHAR2
    ) RETURN VARCHAR2 AS
        V_LAST_PURCHASE   VARCHAR2(20);
    BEGIN
        SELECT
            TO_CHAR(MAX(CL_SERVICE_DATE),'dd-Mon-yyyy')
        INTO
            V_LAST_PURCHASE
        FROM
            TBL_CLAIMS C4
        WHERE
            C4.CL_CLIENT_ID (+) = CLIENTID
            AND   C4.CL_DEP_NO = P_DEP_NO
            AND   C4.CL_PLAN = P_PLAN
            AND   C4.CL_ID = P_ID;

        RETURN V_LAST_PURCHASE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END GET_LAST_PURCHASE;

    FUNCTION GET_NEXT_AVAILABLE_24 (
        P_PLAN     VARCHAR2,
        P_ID       VARCHAR2,
        P_DEP_NO   INTEGER,
        CLIENTID   VARCHAR2
    ) RETURN VARCHAR2 AS
        V_NEXT_AVAILABLE_24   VARCHAR2(20);
    BEGIN
        V_NEXT_AVAILABLE_24 := TO_CHAR(ADD_MONTHS(TO_DATE(GET_LAST_PURCHASE(P_PLAN,P_ID,P_DEP_NO,CLIENTID),'dd-Mon-yyyy'),24),'dd-Mon-yyyy'
);

        RETURN V_NEXT_AVAILABLE_24;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END GET_NEXT_AVAILABLE_24;

    FUNCTION GET_COMMENT_ID (
        P_PLAN       VARCHAR2,
        P_ID         VARCHAR2,
        P_DEP_NO     INTEGER,
        P_CLAIM_NO   VARCHAR2,
        CLIENTID     VARCHAR2
    ) RETURN VARCHAR2 AS
        V_SERVICE_ID     NUMBER;
        V_COMMENT_CODE   VARCHAR2(50);
    BEGIN
        SELECT
            CL_SERVICE_ID
        INTO
            V_SERVICE_ID
        FROM
            TBL_CLAIMS
        WHERE
            CL_CLIENT_ID = CLIENTID
            AND   CL_CLAIM_NUMBER = P_CLAIM_NO
            AND   CL_DEP_NO = P_DEP_NO
            AND   CL_PLAN = P_PLAN
            AND   CL_ID = P_ID;

        SELECT
            LISTAGG(TCC_COMMENT,
            ',') WITHIN GROUP(
            ORDER BY
                TCC_CLAIM
            )
        INTO
            V_COMMENT_CODE
        FROM
            TBL_CLAIM_COMMENTS
        WHERE
            TCC_CLIENT = CLIENTID
            AND   TCC_PLAN = P_PLAN
            AND   TCC_CLAIM = P_CLAIM_NO
            AND   TCC_SERVICE_ID = V_SERVICE_ID;

        RETURN V_COMMENT_CODE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END GET_COMMENT_ID;

    FUNCTION GET_PLAN_MEMBER_IDENTIFIER (
        P_PLAN VARCHAR2,
        P_CLIENT_ID VARCHAR2
    ) RETURN INTEGER AS
        V_MEMBER_IDENTIFIER   INTEGER;
    BEGIN
        SELECT
            MAX(PL_MEMBER_IDENTIFIER)
        INTO
            V_MEMBER_IDENTIFIER
        FROM
            TBL_PLAN
        WHERE
            PL_ID = P_PLAN
            AND   PL_CLIENT_ID = P_CLIENT_ID;

        RETURN V_MEMBER_IDENTIFIER;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END GET_PLAN_MEMBER_IDENTIFIER;

    FUNCTION HAS_OPEN_CLAIMS (
        P_PLAN        VARCHAR2,
        P_ID          VARCHAR2,
        P_CLIENT_ID   VARCHAR2
    ) RETURN VARCHAR2 AS
        V_RESULT   VARCHAR2(1);
    BEGIN
        SELECT
            CASE
                WHEN CNT <> 0 THEN 'Y'
                ELSE 'N'
            END
        INTO
            V_RESULT
        FROM
            (
                SELECT
                    COUNT(*) CNT
                FROM
                    TBL_CLAIMS
                WHERE
                    CL_PLAN = P_PLAN
                    AND   CL_ID = P_ID
                    AND   CL_CLIENT_ID = P_CLIENT_ID
                    AND   CL_STATUS = 'O'
            );

        RETURN V_RESULT;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'N';
    END HAS_OPEN_CLAIMS;

    FUNCTION GET_CLAIM_COMMENTS_AS_STRING (
        P_PLAN_ID      VARCHAR2,
        P_CLAIM_NUM    VARCHAR2,
        P_SERVICE_ID   NUMBER,
        P_CLIENT_ID    VARCHAR2
    ) RETURN VARCHAR2 IS
        RETVAL   VARCHAR2(1000);
    BEGIN
        SELECT
            LISTAGG(TCC_COMMENT,
            ':') WITHIN GROUP(
            ORDER BY
                TCC_CLAIM
            )
        INTO
            RETVAL
        FROM
            TBL_CLAIM_COMMENTS
        WHERE
            TCC_PLAN = P_PLAN_ID
            AND   TCC_CLAIM = P_CLAIM_NUM
            AND   TCC_SERVICE_ID = P_SERVICE_ID
            AND   TCC_CLIENT = P_CLIENT_ID;

        RETURN RETVAL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GET_CLAIM_COMMENTS_AS_STRING;

END CLAIMS;
/

