--
-- FINDSTRBETWEEN  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.FINDSTRBETWEEN (
    PSTRING        IN VARCHAR2,
    PSTARTSTRING   IN VARCHAR2,
    PENDSTRING     IN VARCHAR2
) RETURN VARCHAR2 IS

    RETVAL          VARCHAR2(4000);
    ISTARTPOS       INTEGER;
    IENDPOS         INTEGER;
    PUSTRING        VARCHAR2(4000) := UPPER(PSTRING);
    PUSTARTSTRING   VARCHAR2(4000) := UPPER(PSTARTSTRING);
    PUENDSTRING     VARCHAR2(4000) := UPPER(PENDSTRING);
    VRESTSTRING     VARCHAR2(4000);
BEGIN
    
        -- Step # 1, find where to start
    ISTARTPOS := INSTR(PUSTRING,PUSTARTSTRING) + LENGTH(PUSTARTSTRING);

		-- Step # 2, make a new string out of pUString, from where pUStartString starts, to the end of pUString
    VRESTSTRING := SUBSTR(PUSTRING,ISTARTPOS,LENGTH(PUSTRING) - ISTARTPOS + 1);

        -- Step # 3, find where the return string/value should end

    IENDPOS := INSTR(VRESTSTRING,PUENDSTRING) - 1;

        -- Step # 4, extract the final string/value
    RETVAL := SUBSTR(VRESTSTRING,1,IENDPOS);
    RETURN RETVAL;
END FINDSTRBETWEEN;
/

