--
-- AGE_CALC  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.AGE_CALC (
    CLID    VARCHAR2,
    PLID    VARCHAR2,
    CDATE   DATE,
    DOB     DATE
) RETURN NUMBER AS
    R   NUMBER(6,2);
BEGIN
    SELECT
        MONTHS_BETWEEN(CDATE,DOB) / 12
    INTO
        R
    FROM
        DUAL;

    RETURN R;
END AGE_CALC;
/

