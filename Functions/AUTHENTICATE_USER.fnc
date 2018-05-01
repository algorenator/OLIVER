--
-- AUTHENTICATE_USER  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.AUTHENTICATE_USER (
    P_USERNAME   IN VARCHAR2,
    P_PASSWORD   IN VARCHAR2
) RETURN BOOLEAN IS
    V_COUNT   INTEGER;
BEGIN
  --select count(*) into v_count from users where lower(user_name) = lower(p_username) and password= p_password and  upper(client_id) = upper(v('P101_SUBDOMAIN'));
    SELECT
        COUNT(*)
    INTO
        V_COUNT
    FROM
        USERS
    WHERE
        LOWER(USER_NAME) = LOWER(P_USERNAME)
        AND   PASSWORD = P_PASSWORD;

    IF
        V_COUNT > 0
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END AUTHENTICATE_USER;
/

