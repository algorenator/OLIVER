--
-- TMP_VALIDATE_ORDER  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.TMP_VALIDATE_ORDER (
    P_ID            VARCHAR2,
    P_CUSTOMER_ID   VARCHAR2,
    P_TOTAL         VARCHAR2,
    P_TIMESTAMP     VARCHAR2,
    P_USER_NAME     VARCHAR2
) RETURN VARCHAR2
    IS
BEGIN
    RETURN 'the order is not valid because the total is too low';
END TMP_VALIDATE_ORDER;
/

