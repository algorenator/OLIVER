--
-- TRANSLATE_DATE  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.TRANSLATE_DATE (
    I_DATE_STRING VARCHAR2
) RETURN DATE
    AS
BEGIN
-- you may optimize to not to go in all blocks based on the string format
-- order the blocks on the expected frequency
    BEGIN
        RETURN TO_DATE(I_DATE_STRING,'yyyymmdd');
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;
    BEGIN
        RETURN TO_CHAR(TO_DATE(I_DATE_STRING,'dd-mm-yyyy'),'DD-MON-YYYY');
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    BEGIN
        RETURN TO_DATE(I_DATE_STRING,'yyyy/mm/dd');
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;
    BEGIN
        RETURN TO_DATE(I_DATE_STRING,'yyyy-mm-dd');
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;
    BEGIN
        RETURN TO_DATE(I_DATE_STRING,'yyyy-mm-dd hh24:mi:ss');
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;
    BEGIN
 -- transform to local timestamp and than to date
        RETURN CAST(CAST(TO_TIMESTAMP_TZ(I_DATE_STRING,'dy month dd hh24:mi:ss tzr yyyy') AS TIMESTAMP WITH LOCAL TIME ZONE) AS DATE);
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    BEGIN
        RETURN TO_DATE(I_DATE_STRING,'dy, month dd, yyyy hh:mi:ss am');
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;
    RETURN NULL;
END;
/

