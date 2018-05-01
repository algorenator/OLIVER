--
-- HSA_PKG  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.HSA_PKG AS

    FUNCTION GET_HSA_CLAIM_NUM (
        PLAN_ID VARCHAR2,
        CLIENT_ID VARCHAR2
    ) RETURN VARCHAR2 AS
        V_RESULT   TBL_CLAIMS.CL_CLAIM_NUMBER%TYPE;
    BEGIN
        SELECT
            'H'
            || NVL( (MAX(TO_NUMBER(SUBSTR(CL_CLAIM_NUMBER,2,10) ) ) + 1),0)
        INTO
            V_RESULT
        FROM
            TBL_CLAIMS
        WHERE
            CL_CLIENT_ID = CLIENT_ID
            AND   CL_PLAN = PLAN_ID;

        RETURN V_RESULT;
    END GET_HSA_CLAIM_NUM;

    PROCEDURE CREATE_HSA_CLAIM (
        P_MEM_ID             TBL_MEMBER.MEM_ID%TYPE,
        P_SERVICE_DATE       DATE,
        P_SERVICE            TBL_CLAIMS.CL_SERVICE_ID%TYPE,
        P_AMOUNT             TBL_CLAIMS.CL_AMT_CLAIMED%TYPE,
        P_PLAN_ID            TBL_CLAIMS.CL_PLAN%TYPE,
        P_CLIENT_ID          TBL_CLAIMS.CL_CLIENT_ID%TYPE,
        P_CLAIM_NUMBER_OUT   OUT TBL_CLAIMS.CL_CLAIM_NUMBER%TYPE,
        P_CL_KEY_OUT         OUT TBL_CLAIMS.CL_KEY%TYPE,
        P_DEP_NO             TBL_CLAIMS.CL_DEP_NO%TYPE
    ) AS
        V_CLAIM_TYPE   TBL_CLAIMS.CL_CLAIM_TYPE%TYPE := 'H';
    BEGIN
    
    --get the new claim number before inserting
        SELECT
            CLAIMS.NEXT_HSA_CLAIM(P_PLAN_ID,P_CLIENT_ID)
        INTO
            P_CLAIM_NUMBER_OUT
        FROM
            DUAL;

        INSERT INTO TBL_CLAIMS (
            CL_PLAN,
            CL_ID,
            CL_DEP_NO,
            CL_CLAIM_NUMBER,
            CL_CLAIM_TYPE,
            CL_AMT_CLAIMED,
            CL_AMT_PAID,
            CL_USER,
            CL_DATE_RECD,
            CL_DATE_PAID,
            CL_PAYMENT_NUMBER,
            CL_BEN_CODE,
            CL_SERVICE_DATE,
            CL_COMMENT,
            CL_STATUS,
            CL_SERVICE_ID,
            CL_PAYMENT_TYPE,
            CL_SELECTED,
            CL_KEY,
            CL_OTHER_INS_AMT,
            CL_TRAN_DATE,
            CL_CLIENT_ID
        ) VALUES (
            P_PLAN_ID, --plan id
            P_MEM_ID,  --member id
            P_DEP_NO,      --dep no
            P_CLAIM_NUMBER_OUT,--claim no
            V_CLAIM_TYPE,--claim type (H for HSA)
            P_AMOUNT,  --amt claimed
            NULL,      --amt paid
            NULL,      --user
            NULL,      --date recd
            NULL,      --date paid
            NULL,      --payment num
            NULL,      --ben code
            P_SERVICE_DATE,--serv date
            NULL,      --comment
            'I',       --status
            P_SERVICE, --service id
            NULL,      --pay type
            NULL,      --cl_selelected
            NULL,      --cl_key
            NULL,      --ins amt
            SYSDATE,   --trans date
            P_CLIENT_ID     --client id
        );

        SELECT
            TBL_CLAIMS_SEQ.CURRVAL
        INTO
            P_CL_KEY_OUT
        FROM
            DUAL;

    END CREATE_HSA_CLAIM;

    FUNCTION GET_HSA_DEPENDANT_NAME (
        P_MEM_ID      VARCHAR2,
        P_DEP_NO      NUMBER,
        P_PLAN_ID     VARCHAR2,
        P_CLIENT_ID   VARCHAR2
    ) RETURN VARCHAR2 AS
        V_RESULT   VARCHAR2(255);
    BEGIN
        SELECT
            INITCAP(HD_FIRST_NAME
            || ' '
            || HD_LAST_NAME)
        INTO
            V_RESULT
        FROM
            TBL_HW_DEPENDANTS
        WHERE
            HD_ID = P_MEM_ID
            AND   HD_PLAN = P_PLAN_ID
            AND   HD_CLIENT = P_CLIENT_ID
            AND   HD_BEN_NO = P_DEP_NO;

        RETURN V_RESULT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GET_HSA_DEPENDANT_NAME;

    FUNCTION GET_HSA_MEMBER_NAME (
        P_MEM_ID      VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_CLIENT_ID   VARCHAR2
    ) RETURN VARCHAR2 AS
        V_RESULT   VARCHAR2(255);
    BEGIN
        SELECT
            INITCAP(MEM_FIRST_NAME
            || ' '
            || MEM_LAST_NAME)
        INTO
            V_RESULT
        FROM
            TBL_MEMBER
        WHERE
            MEM_ID = P_MEM_ID
            AND   MEM_PLAN = P_PLAN_ID
            AND   MEM_CLIENT_ID = P_CLIENT_ID;

        RETURN V_RESULT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GET_HSA_MEMBER_NAME;

END HSA_PKG;
/

