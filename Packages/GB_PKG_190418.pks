--
-- GB_PKG_190418  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.GB_PKG_190418 AS
    FUNCTION IS_ELIGIBLE (
        PL_ID   VARCHAR2,
        ER_ID   VARCHAR2,
        EE_ID   VARCHAR2,
        MTH     DATE
    ) RETURN VARCHAR2;

    FUNCTION GET_DEP_STATUS (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BENEFIT   VARCHAR2,
        DT        DATE
    ) RETURN VARCHAR2;

    FUNCTION GET_BEN_COVERAGE (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN VARCHAR2;

    FUNCTION GET_BILL (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN NUMBER;

    FUNCTION GET_ADMIN_AMT (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN NUMBER;

    FUNCTION GET_CARRIER_RATE (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN NUMBER;

    FUNCTION GET_ADMIN_RATE (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN NUMBER;

    FUNCTION GET_AGENT_RATE (
        CID       VARCHAR2,
        PL        VARCHAR2,
        ID1       VARCHAR2,
        BTYPE     VARCHAR2,
        BENEFIT   VARCHAR2,
        BDESC     VARCHAR2,
        DT        DATE,
        SX        VARCHAR2,
        DOB       DATE,
        SMK       VARCHAR2,
        CLASS1    VARCHAR2,
        BG        VARCHAR2,
        DS1       VARCHAR2,
        SAL       NUMBER,
        EDATE     DATE,
        TDATE     DATE,
        BD        DATE
    ) RETURN NUMBER;

    PROCEDURE GB_ADJ (
        CID               VARCHAR2,
        PL                VARCHAR2,
        ID1               VARCHAR2,
        SX                VARCHAR2,
        DOB               DATE,
        OLD_SMK           VARCHAR2,
        NEW_SMK           VARCHAR2,
        OLD_SMK_DATE      DATE,
        NEW_SMK_DATE      DATE,
        OLD_CLASS         VARCHAR2,
        NEW_CLASS         VARCHAR2,
        OLD_DEP_STATUS    VARCHAR2,
        NEW_DEP_STATUS    VARCHAR2,
        OLD_DS_DATE       DATE,
        NEW_DS_DATE       DATE,
        OLD_SALARY_DATE   DATE,
        NEW_SALARY_DATE   DATE,
        OLD_SALARY        NUMBER,
        NEW_SALARY        NUMBER,
        EDATE             DATE,
        TDATE             DATE,
        BD                DATE
    );
  /* TODO enter package declarations (types, exceptions, methods etc) here */

END GB_PKG_190418;
/

