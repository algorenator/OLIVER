--
-- IS_X  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER."IS_X" (
    MTH1   DATE,
    BD     DATE,
    X      NUMBER
) RETURN NUMBER
    IS
BEGIN
    IF
        X > 2 AND ABS(TRUNC(MONTHS_BETWEEN(TRUNC(BD,'mm'),TRUNC(MTH1,'mm') ) ) ) >= X
    THEN
        RETURN 1;
    ELSIF ABS(TRUNC(MONTHS_BETWEEN(TRUNC(BD,'mm'),TRUNC(MTH1,'mm') ) ) ) = X THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
/

