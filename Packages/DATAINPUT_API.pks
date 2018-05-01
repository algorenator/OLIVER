--
-- DATAINPUT_API  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.DATAINPUT_API IS
    FUNCTION BLOB_TO_CLOB (
        BLOB_IN IN BLOB
    ) RETURN CLOB;

    PROCEDURE FILE_UPLOAD (
        P_PEN_AGREEMENT   VARCHAR2,
        P_TRAN_ID         VARCHAR2,
        P_CLIENT_ID       VARCHAR2,
        P_PLAN_ID         VARCHAR2,
        P_EMPLOYER        VARCHAR2,
        P_PERIOD          DATE,
        P_APP_ID          NUMBER,
        P_SESSION_ID      NUMBER,
        P_CREATED_BY      VARCHAR2,
        P_LAYOUT          VARCHAR2,
        P_POSITION        VARCHAR2
    );

    FUNCTION VALIDATE_DEAIL_INPUT (
        P_TDT_EMPLOYER       VARCHAR2,
        P_TDT_PLAN_ID        VARCHAR2,
        P_TDT_UNITS          NUMBER,
        P_TDT_MEM_ID         VARCHAR2,
        P_MONTH              DATE,
        P_TRAN_ID            VARCHAR2,
        P_BEN_AGREEMENT_ID   VARCHAR2,
        P_PEN_AGREEMENT_ID   VARCHAR2,
        P_BEN_EARN           VARCHAR2,
        P_PEN_EARN           VARCHAR2
    ) RETURN VARCHAR2;

END DATAINPUT_API;
/

