--
-- AOP_TEST3_PKG  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.AOP_TEST3_PKG AS
-- Run automated tests in table AOP_AUTOMATED_TEST; if p_id is null, all tests will be ran

    PROCEDURE RUN_AUTOMATED_TESTS (
        P_ID       IN AOP_AUTOMATED_TEST.ID%TYPE,
        P_APP_ID   IN NUMBER
    ) AS

        L_RETURN             BLOB;
        L_ERROR              VARCHAR2(4000);
        L_START              DATE;
        L_END                DATE;
        L_OUTPUT_FILENAME    VARCHAR2(150);
  --
        L_AOP_URL            VARCHAR2(1000);
        L_API_KEY            VARCHAR2(40);
        L_AOP_REMOTE_DEBUG   VARCHAR2(10);
        L_OUTPUT_CONVERTER   VARCHAR2(100);
    BEGIN
  -- note that session state needs to be set manually for the items (see pre-rendering page 8)
  -- set logging on by going to aop_api3_pkg g_logger_enabled true
  -- read plugin settings
        SELECT
            ATTRIBUTE_01 AS AOP_URL,
            ATTRIBUTE_02 AS API_KEY,
            ATTRIBUTE_03 AS AOP_REMOTE_DEBUG,
            ATTRIBUTE_04 AS OUTPUT_CONVERTER
        INTO
            L_AOP_URL,L_API_KEY,L_AOP_REMOTE_DEBUG,L_OUTPUT_CONVERTER
        FROM
            APEX_APPL_PLUGIN_SETTINGS
        WHERE
            APPLICATION_ID = P_APP_ID
            AND   PLUGIN_CODE = 'PLUGIN_BE.APEXRND.AOP';
  -- reset tests

        UPDATE AOP_AUTOMATED_TEST
            SET
                RECEIVED_BYTES = NULL,
                OUTPUT_BLOB = NULL,
                RESULT = NULL,
                PROCESSING_SECONDS = NULL,
                RUN_DATE = SYSDATE
        WHERE
            ID = P_ID
            OR   P_ID IS NULL;
  -- loop over reports

        FOR R IN (
            SELECT
                ID,
                DATA_TYPE,
                DATA_SOURCE,
                TEMPLATE_TYPE,
                TEMPLATE_SOURCE,
                OUTPUT_TYPE,
                OUTPUT_FILENAME,
                OUTPUT_TO,
                OUTPUT_TYPE_ITEM_NAME,
                FILENAME,
                SPECIAL,
                PROCEDURE_,
                APP_ID,
                PAGE_ID
            FROM
                AOP_AUTOMATED_TEST
            WHERE
                (
                    ID = P_ID
                    OR    P_ID IS NULL
                )
                AND   APP_ID = P_APP_ID
            ORDER BY
                SEQ_NR
        ) LOOP
            BEGIN
                L_START := SYSDATE;
                L_OUTPUT_FILENAME := NVL(R.OUTPUT_FILENAME,'output');
                L_RETURN := AOP_API3_PKG.PLSQL_CALL_TO_AOP(P_DATA_TYPE => R.DATA_TYPE,P_DATA_SOURCE => R.DATA_SOURCE,P_TEMPLATE_TYPE => R.TEMPLATE_TYPE,P_TEMPLATE_SOURCE
=> R.TEMPLATE_SOURCE,P_OUTPUT_TYPE => R.OUTPUT_TYPE,P_OUTPUT_FILENAME => L_OUTPUT_FILENAME,P_OUTPUT_TYPE_ITEM_NAME => R.OUTPUT_TYPE_ITEM_NAME
,P_OUTPUT_TO => R.OUTPUT_TO,P_PROCEDURE => R.PROCEDURE_,
                    --p_binds               in t_bind_table default c_binds,
                P_SPECIAL => R.SPECIAL,P_AOP_REMOTE_DEBUG => L_AOP_REMOTE_DEBUG,P_OUTPUT_CONVERTER => L_OUTPUT_CONVERTER,P_AOP_URL => L_AOP_URL,P_API_KEY
=> L_API_KEY,P_APP_ID => R.APP_ID,P_PAGE_ID => R.PAGE_ID);

                L_END := SYSDATE;
                UPDATE AOP_AUTOMATED_TEST
                    SET
                        RECEIVED_BYTES = DBMS_LOB.GETLENGTH(L_RETURN),
                        OUTPUT_BLOB = L_RETURN,
                        RESULT = 'ok',
                        PROCESSING_SECONDS = ROUND( (L_END - L_START) * 60 * 60 * 24,2)
                WHERE
                    ID = R.ID;

            EXCEPTION
                WHEN OTHERS THEN
                    L_END := SYSDATE;
                    L_ERROR := SUBSTR(SQLERRM,1,4000);
                    UPDATE AOP_AUTOMATED_TEST
                        SET
                            RECEIVED_BYTES = NULL,
                            OUTPUT_BLOB = NULL,
                            RESULT = L_ERROR,
                            PROCESSING_SECONDS = ROUND( (L_END - L_START) * 60 * 60 * 24,2)
                    WHERE
                        ID = R.ID;

            END;
        END LOOP;

    END RUN_AUTOMATED_TESTS;

END AOP_TEST3_PKG;
/

