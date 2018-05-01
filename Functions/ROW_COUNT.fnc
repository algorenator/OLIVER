--
-- ROW_COUNT  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.ROW_COUNT (
    TAB_NAME VARCHAR2
) RETURN NUMBER AS
    ROWS   NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '
    || TAB_NAME INTO
        ROWS;
    RETURN ROWS;
END;
/
