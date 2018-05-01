--
-- MACHINIST_DIV1  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.MACHINIST_DIV1 AS
    FUNCTION STANDARD_ACCOUNT (
        CLTID          VARCHAR2,
        PLID           VARCHAR2,
        MEMID          VARCHAR2,
        DT             DATE,
        PROJ_PCT_INC   NUMBER,
        INT_PCT_INC    NUMBER,
        STOP_WORKING   VARCHAR2,
        DOB            DATE
    ) RETURN NUMBER;

    FUNCTION VOL_ACCOUNT (
        CLTID          VARCHAR2,
        PLID           VARCHAR2,
        MEMID          VARCHAR2,
        DT             DATE,
        PROJ_PCT_INC   NUMBER,
        INT_PCT_INC    NUMBER,
        STOP_WORKING   VARCHAR2,
        DOB            DATE
    ) RETURN NUMBER;

    FUNCTION STANDARD_ACCOUNT_PENSION (
        CLTID          VARCHAR2,
        PLID           VARCHAR2,
        MEMID          VARCHAR2,
        DT             DATE,
        PROJ_PCT_INC   NUMBER,
        INT_PCT_INC    NUMBER,
        STOP_WORKING   VARCHAR2,
        DOB            DATE
    ) RETURN NUMBER;

    FUNCTION SUPP_ACCOUNT (
        CLTID          VARCHAR2,
        PLID           VARCHAR2,
        MEMID          VARCHAR2,
        DT             DATE,
        PROJ_PCT_INC   NUMBER,
        INT_PCT_INC    NUMBER,
        STOP_WORKING   VARCHAR2,
        DOB            DATE
    ) RETURN NUMBER;

    FUNCTION MEM_REQD_ACCOUNT (
        CLTID          VARCHAR2,
        PLID           VARCHAR2,
        MEMID          VARCHAR2,
        DT             DATE,
        PROJ_PCT_INC   NUMBER,
        INT_PCT_INC    NUMBER,
        STOP_WORKING   VARCHAR2,
        DOB            DATE
    ) RETURN NUMBER;
  /* TODO enter package declarations (types, exceptions, methods etc) here */

END MACHINIST_DIV1;
/

