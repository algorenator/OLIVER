--
-- TMP_PLS_REMOVE_ME  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.TMP_PLS_REMOVE_ME (
    DATA VARCHAR2
) RETURN VARCHAR2
    IS
BEGIN
    RETURN DATA
    || ' processed';
END;
/

