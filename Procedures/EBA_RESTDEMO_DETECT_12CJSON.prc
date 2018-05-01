--
-- EBA_RESTDEMO_DETECT_12CJSON  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.EBA_RESTDEMO_DETECT_12CJSON (
    P_FORCE_ENABLED IN BOOLEAN DEFAULT NULL
)
    AUTHID CURRENT_USER
IS
    L_VALUE   NUMBER;
BEGIN
    IF
        P_FORCE_ENABLED IS NULL
    THEN
        BEGIN
            EXECUTE IMMEDIATE 'select json_value(''"a": 1'', ''$.a'') from dual' INTO
                L_VALUE;
            EXECUTE IMMEDIATE 'create or replace function eba_restdemo_json_12c return boolean is begin return true; end;';
        EXCEPTION
            WHEN OTHERS THEN
                EXECUTE IMMEDIATE 'create or replace function eba_restdemo_json_12c return boolean is begin return false; end;';
        END;

    ELSE
        IF
            P_FORCE_ENABLED
        THEN
            EXECUTE IMMEDIATE 'create or replace function eba_restdemo_json_12c return boolean is begin return true; end;';
        ELSE
            EXECUTE IMMEDIATE 'create or replace function eba_restdemo_json_12c return boolean is begin return false; end;';
        END IF;
    END IF;
END EBA_RESTDEMO_DETECT_12CJSON;
/

