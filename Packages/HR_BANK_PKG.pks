--
-- HR_BANK_PKG  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.HR_BANK_PKG AS
    FUNCTION GET_EMPLOYER (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN VARCHAR2;

    FUNCTION FIRST_TIME (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN VARCHAR2;

    FUNCTION FIRST_TIME_ELIGIBLE (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN VARCHAR2;

    FUNCTION GET_REQUIRED_HRS (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN NUMBER;

    FUNCTION GET_MONTHLY_HRS (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN NUMBER;

    FUNCTION GET_MAX_HRS (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN NUMBER;

    FUNCTION IS_ELIGIBLE (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN VARCHAR2;

    FUNCTION GET_HR_BANK (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN NUMBER;

    FUNCTION GET_FORFEIT_HRS (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        MTH      DATE
    ) RETURN NUMBER;

    PROCEDURE POST_BATCHES (
        CLT_ID     VARCHAR2,
        PL_ID      VARCHAR2,
        USER_ID    VARCHAR2,
        TRAN_ID    VARCHAR2,
        BEN_TYPE   VARCHAR2
    );

    PROCEDURE POST_BATCHES_PEN (
        CLT_ID     VARCHAR2,
        PL_ID      VARCHAR2,
        USER_ID    VARCHAR2,
        TRAN_ID    VARCHAR2,
        BEN_TYPE   VARCHAR2
    );

    PROCEDURE POST_BATCHES_FUNDS (
        CLT_ID     VARCHAR2,
        PL_ID      VARCHAR2,
        USER_ID    VARCHAR2,
        TRAN_ID    VARCHAR2,
        BEN_TYPE   VARCHAR2
    );

    FUNCTION FIRST_ELIGIBLE_DATE (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2
    ) RETURN DATE;

    PROCEDURE ELIG_PROC (
        CLT_ID   VARCHAR2,
        PL_ID1   VARCHAR2,
        MEND     VARCHAR2
    );

    FUNCTION GET_HB_LRD (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        ER_ID    VARCHAR2,
        EE_ID    VARCHAR2,
        MTH      DATE
    ) RETURN DATE;
--PROCEDURE MONTH_END(PL_ID1 VARCHAR2,MTH DATE);

    FUNCTION GET_BEN_NO (
        P_PLAN_ID     VARCHAR2,
        P_CLIENT_ID   VARCHAR2,
        P_HB_ID       VARCHAR2
    ) RETURN NUMBER;

    FUNCTION GET_DEP_NO (
        P_PLAN_ID     VARCHAR2,
        P_CLIENT_ID   VARCHAR2,
        P_HD_ID       VARCHAR2
    ) RETURN NUMBER;

    FUNCTION ELIG_MONTH_UPTO (
        CLT_ID   VARCHAR2,
        PL_ID    VARCHAR2,
        EE_ID    VARCHAR2
    ) RETURN DATE;

END HR_BANK_PKG;
/

