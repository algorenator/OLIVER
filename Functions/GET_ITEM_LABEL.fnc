--
-- GET_ITEM_LABEL  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.GET_ITEM_LABEL (
    P_ITEM_NAME   VARCHAR2,
    P_LANG        VARCHAR2 DEFAULT 'EN'
) RETURN VARCHAR2 IS
    V_ITEM_LABEL    ITEM_LABELS.ITEM_LABEL%TYPE;
    V2_ITEM_LABEL   ITEM_LABELS.ITEM_LABEL%TYPE;
BEGIN
    SELECT
        ITEM_LABEL
    INTO
        V_ITEM_LABEL
    FROM
        ITEM_LABELS
    WHERE
        UPPER(ITEM_NAME) = UPPER(P_ITEM_NAME)
        AND   UPPER(LANG) = UPPER(P_LANG)
        AND   ISVALUE = 'N';

    RETURN V_ITEM_LABEL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        SELECT
            PI.LABEL
        INTO
            V_ITEM_LABEL
        FROM
            APEX_APPLICATION_PAGE_ITEMS PI
        WHERE
            PI.APPLICATION_ID = V('APP_ID')
            AND   (
                PI.PAGE_ID = V('APP_PAGE_ID')
                OR    PI.PAGE_ID = '0'
            )
            AND   PI.ITEM_NAME = P_ITEM_NAME;

        BEGIN
            SELECT
                ITEM_LABEL
            INTO
                V2_ITEM_LABEL
            FROM
                ITEM_LABELS
            WHERE
                UPPER(ITEM_NAME) = UPPER(V_ITEM_LABEL)
                AND   UPPER(LANG) = UPPER(P_LANG)
                AND   ISVALUE = 'Y';

            RETURN V2_ITEM_LABEL;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
                RETURN V_ITEM_LABEL;
        END;

        RETURN V_ITEM_LABEL;
END GET_ITEM_LABEL;
/

