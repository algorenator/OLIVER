--
-- IS_ELIGIBLE  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.IS_ELIGIBLE (
    PLID    VARCHAR2,
    ER_ID   VARCHAR2,
    EE_ID   VARCHAR2,
    MTH     DATE,
    CLID    VARCHAR2
) RETURN VARCHAR2 AS
    PT   VARCHAR2(100);
BEGIN
    SELECT
        PL_TYPE
    INTO
        PT
    FROM
        PLAN_TYPES,
        TBL_PLAN
    WHERE
        PT_ID = PL_TYPE
        AND   PL_ID = PLID
        AND   PL_TYPE IN (
            'HB',
            'GB'
        );

    IF
        PT = 'HB'
    THEN
        RETURN HR_BANK_PKG.IS_ELIGIBLE(CLID,PLID,ER_ID,EE_ID,MTH);
    ELSIF PT = 'GB' THEN
        RETURN GB_PKG.IS_ELIGIBLE(PLID,ER_ID,EE_ID,MTH);
    ELSE
        RETURN NULL;
    END IF;

END;
/

