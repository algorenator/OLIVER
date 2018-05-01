--
-- CLAIMS  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.CLAIMS AS
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
    ) RETURN VARCHAR2;

    FUNCTION IS_ELIGIBLE (
        PL_ID         VARCHAR2,
        MEM_ID        VARCHAR2,
        DEP_ID        NUMBER,
        SERV_DATE     DATE,
        BEN_CODE      NUMBER,
        CLAIM_ID1     VARCHAR2,
        SERVICE_ID1   NUMBER,
        CLIENTID      VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION NEXT_VISION_CLAIM (
        PL VARCHAR2,
        CLIENTID VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION LATE_APPLICANT (
        PL_ID         VARCHAR2,
        MEM_ID        VARCHAR2,
        DEP_ID        NUMBER,
        SERV_DATE     DATE,
        BEN_CODE      NUMBER,
        CLAIM_ID1     VARCHAR2,
        SERVICE_ID1   NUMBER,
        CLIENTID      VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GET_NAME (
        P_PLAN     VARCHAR2,
        P_ID       VARCHAR2,
        P_DEP_NO   INTEGER,
        CLIENTID   VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GET_AVAILABLE_AMT (
        PL_ID         VARCHAR2,
        MEM_ID        VARCHAR2,
        DEP_ID        NUMBER,
        SERV_DATE     DATE,
        BEN_CODE      NUMBER,
        CLAIM_ID1     VARCHAR2,
        SERVICE_ID1   NUMBER,
        CLIENTID      VARCHAR2
    ) RETURN NUMBER;

    FUNCTION GET_NEXT_FULL_COV_DATE (
        PL_ID         VARCHAR2,
        MEM_ID        VARCHAR2,
        DEP_ID        NUMBER,
        SERV_DATE     DATE,
        BEN_CODE      NUMBER,
        CLAIM_ID1     VARCHAR2,
        SERVICE_ID1   NUMBER,
        CLIENTID      VARCHAR2
    ) RETURN DATE;

    FUNCTION GET_IS_ELIGIBLE_FLAG (
        PL_ID         VARCHAR2,
        MEM_ID        VARCHAR2,
        DEP_ID        NUMBER,
        SERV_DATE     DATE,
        BEN_CODE      NUMBER,
        CLAIM_ID1     VARCHAR2,
        SERVICE_ID1   NUMBER,
        CLIENTID      VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GET_LAST_PURCHASE (
        P_PLAN     VARCHAR2,
        P_ID       VARCHAR2,
        P_DEP_NO   INTEGER,
        CLIENTID   VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GET_COMMENT_ID (
        P_PLAN       VARCHAR2,
        P_ID         VARCHAR2,
        P_DEP_NO     INTEGER,
        P_CLAIM_NO   VARCHAR2,
        CLIENTID     VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GET_PLAN_MEMBER_IDENTIFIER (
        P_PLAN VARCHAR2,
        P_CLIENT_ID VARCHAR2
    ) RETURN INTEGER;

    FUNCTION HAS_OPEN_CLAIMS (
        P_PLAN        VARCHAR2,
        P_ID          VARCHAR2,
        P_CLIENT_ID   VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GET_CLAIM_COMMENTS_AS_STRING (
        P_PLAN_ID      VARCHAR2,
        P_CLAIM_NUM    VARCHAR2,
        P_SERVICE_ID   NUMBER,
        P_CLIENT_ID    VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION NEXT_HSA_CLAIM (
        PL VARCHAR2,
        CLIENTID VARCHAR2
    ) RETURN VARCHAR2;

END CLAIMS;
/

