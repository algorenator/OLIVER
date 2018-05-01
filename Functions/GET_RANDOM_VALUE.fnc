--
-- GET_RANDOM_VALUE  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.GET_RANDOM_VALUE (
    P_TABLE VARCHAR2,
    P_COL VARCHAR2
) RETURN VARCHAR2 IS
    V_QUERY_STR   VARCHAR2(1000);
    V_RES_STR     VARCHAR2(1000);
BEGIN
    V_QUERY_STR := 'select max(col1) from ( '
    || ' select rowid,'
    || P_COL
    || ' col1, '
    || ' row_number() over (order by dbms_random.value) r'
    || ' from '
    || P_TABLE
    || ' where '
    || P_COL
    || ' is not null'
    || ') where r=1';

--DBMS_OUTPUT.PUT_LINE(v_query_str);

    EXECUTE IMMEDIATE V_QUERY_STR INTO
        V_RES_STR;
    RETURN V_RES_STR;
END;
/

