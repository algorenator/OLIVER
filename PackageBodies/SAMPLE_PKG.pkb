--
-- SAMPLE_PKG  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.SAMPLE_PKG AS
    --
    -- Error Handling function
    --

    FUNCTION DEMO_ERROR_HANDLING (
        P_ERROR IN APEX_ERROR.T_ERROR
    ) RETURN APEX_ERROR.T_ERROR_RESULT IS
        L_RESULT            APEX_ERROR.T_ERROR_RESULT;
        L_REFERENCE_ID      NUMBER;
        L_CONSTRAINT_NAME   VARCHAR2(255);
    BEGIN
        L_RESULT := APEX_ERROR.INIT_ERROR_RESULT(P_ERROR => P_ERROR);
        -- If it's an internal error raised by APEX, like an invalid statement or
        -- code which can't be executed, the error text might contain security sensitive
        -- information. To avoid this security problem we can rewrite the error to
        -- a generic error message and log the original error message for further
        -- investigation by the help desk.
        IF
            P_ERROR.IS_INTERNAL_ERROR
        THEN
            -- mask all errors that are not common runtime errors (Access Denied
            -- errors raised by application / page authorization and all errors
            -- regarding session and session state)
            IF
                NOT P_ERROR.IS_COMMON_RUNTIME_ERROR
            THEN
                -- log error for example with an autonomous transaction and return
                -- l_reference_id as reference#
                -- l_reference_id := log_error (
                --                       p_error => p_error );
                --
    
                -- Change the message to the generic error message which doesn't expose
                -- any sensitive information.
                L_RESULT.MESSAGE := 'An unexpected internal application error has occurred. '
                || 'Please get in contact with your system administrator and provide '
                || 'reference# '
                || TO_CHAR(L_REFERENCE_ID,'999G999G999G990')
                || ' for further investigation.';

                L_RESULT.ADDITIONAL_INFO := NULL;
            END IF;

        ELSE
            -- Always show the error as inline error
            -- Note: If you have created manual tabular forms (using the package
            --       apex_item/htmldb_item in the SQL statement) you should still
            --       use "On error page" on that pages to avoid loosing entered data
            L_RESULT.DISPLAY_LOCATION :=
                CASE
                    WHEN L_RESULT.DISPLAY_LOCATION = APEX_ERROR.C_ON_ERROR_PAGE THEN APEX_ERROR.C_INLINE_IN_NOTIFICATION
                    ELSE L_RESULT.DISPLAY_LOCATION
                END;
    
            -- If it's a constraint violation like
            --
            --   -) ORA-00001: unique constraint violated
            --   -) ORA-02091: transaction rolled back (-> can hide a deferred constraint)
            --   -) ORA-02290: check constraint violated
            --   -) ORA-02291: integrity constraint violated - parent key not found
            --   -) ORA-02292: integrity constraint violated - child record found
            --
            -- we try to get a friendly error message from our constraint lookup configuration.
            -- If we don't find the constraint in our lookup table we fallback to
            -- the original ORA error message.

            IF
                P_ERROR.ORA_SQLCODE IN (
                    -1,
                    -2091,
                    -2290,
                    -2291,
                    -2292
                )
            THEN
                L_CONSTRAINT_NAME := APEX_ERROR.EXTRACT_CONSTRAINT_NAME(P_ERROR => P_ERROR);
                BEGIN
                    SELECT
                        MESSAGE
                    INTO
                        L_RESULT.MESSAGE
                    FROM
                        DEMO_CONSTRAINT_LOOKUP
                    WHERE
                        CONSTRAINT_NAME = L_CONSTRAINT_NAME;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL; -- not every constraint has to be in our lookup table
                END;

            END IF;
            -- If an ORA error has been raised, for example a raise_application_error(-20xxx, '...')
                -- in a table trigger or in a PL/SQL package called by a process and we
            -- haven't found the error in our lookup table, then we just want to see
            -- the actual error text and not the full error stack with all the ORA error numbers.

            IF
                P_ERROR.ORA_SQLCODE IS NOT NULL AND L_RESULT.MESSAGE = P_ERROR.MESSAGE
            THEN
                L_RESULT.MESSAGE := APEX_ERROR.GET_FIRST_ORA_ERROR_TEXT(P_ERROR => P_ERROR);
            END IF;
            -- If no associated page item/tabular form column has been set, we can use
            -- apex_error.auto_set_associated_item to automatically guess the affected
            -- error field by examine the ORA error for constraint names or column names.

            IF
                L_RESULT.PAGE_ITEM_NAME IS NULL AND L_RESULT.COLUMN_ALIAS IS NULL
            THEN
                APEX_ERROR.AUTO_SET_ASSOCIATED_ITEM(P_ERROR => P_ERROR,P_ERROR_RESULT => L_RESULT);
            END IF;

        END IF;

        RETURN L_RESULT;
    END DEMO_ERROR_HANDLING;
        
    
    ---
    --- Tag Cleaner function
    ---

    FUNCTION DEMO_TAGS_CLEANER (
        P_TAGS   IN VARCHAR2,
        P_CASE   IN VARCHAR2 DEFAULT 'U'
    ) RETURN VARCHAR2 IS

        TYPE TAGS IS
            TABLE OF VARCHAR2(255) INDEX BY VARCHAR2(255);
        L_TAGS_A        TAGS;
        L_TAG           VARCHAR2(255);
        L_TAGS          APEX_APPLICATION_GLOBAL.VC_ARR2;
        L_TAGS_STRING   VARCHAR2(32767);
        I               INTEGER;
    BEGIN
        L_TAGS := APEX_UTIL.STRING_TO_TABLE(P_TAGS,',');
        FOR I IN 1..L_TAGS.COUNT LOOP
            --remove all whitespace, including tabs, spaces, line feeds and carraige returns with a single space
            L_TAG := SUBSTR(TRIM(REGEXP_REPLACE(L_TAGS(I),'[[:space:]]{1,}',' ') ),1,255);

            IF
                L_TAG IS NOT NULL AND L_TAG != ' '
            THEN
                IF
                    P_CASE = 'U'
                THEN
                    L_TAG := UPPER(L_TAG);
                ELSIF P_CASE = 'L' THEN
                    L_TAG := LOWER(L_TAG);
                END IF;
                --add it to the associative array, if it is a duplicate, it will just be replaced

                L_TAGS_A(L_TAG) := L_TAG;
            END IF;

        END LOOP;

        L_TAG := NULL;
        L_TAG := L_TAGS_A.FIRST;
        WHILE L_TAG IS NOT NULL LOOP
            L_TAGS_STRING := L_TAGS_STRING
            || L_TAG;
            IF
                L_TAG != L_TAGS_A.LAST
            THEN
                L_TAGS_STRING := L_TAGS_STRING
                || ', ';
            END IF;

            L_TAG := L_TAGS_A.NEXT(L_TAG);
        END LOOP;

        RETURN SUBSTR(L_TAGS_STRING,1,4000);
    END DEMO_TAGS_CLEANER;
    ---
    --- Tag Synchronisation Procedure
    ---

    PROCEDURE DEMO_TAG_SYNC (
        P_NEW_TAGS       IN VARCHAR2,
        P_OLD_TAGS       IN VARCHAR2,
        P_CONTENT_TYPE   IN VARCHAR2,
        P_CONTENT_ID     IN NUMBER
    ) AS

        TYPE TAGS IS
            TABLE OF VARCHAR2(255) INDEX BY VARCHAR2(255);
        L_NEW_TAGS_A   TAGS;
        L_OLD_TAGS_A   TAGS;
        L_NEW_TAGS     APEX_APPLICATION_GLOBAL.VC_ARR2;
        L_OLD_TAGS     APEX_APPLICATION_GLOBAL.VC_ARR2;
        L_MERGE_TAGS   APEX_APPLICATION_GLOBAL.VC_ARR2;
        L_DUMMY_TAG    VARCHAR2(255);
        I              INTEGER;
    BEGIN
        L_OLD_TAGS := APEX_UTIL.STRING_TO_TABLE(P_OLD_TAGS,', ');
        L_NEW_TAGS := APEX_UTIL.STRING_TO_TABLE(P_NEW_TAGS,', ');
        IF
            L_OLD_TAGS.COUNT > 0
        THEN --do inserts and deletes
            --build the associative arrays
            FOR I IN 1..L_OLD_TAGS.COUNT LOOP
                L_OLD_TAGS_A(L_OLD_TAGS(I) ) := L_OLD_TAGS(I);
            END LOOP;

            FOR I IN 1..L_NEW_TAGS.COUNT LOOP
                L_NEW_TAGS_A(L_NEW_TAGS(I) ) := L_NEW_TAGS(I);
            END LOOP;
            --do the inserts

            FOR I IN 1..L_NEW_TAGS.COUNT LOOP
                BEGIN
                    L_DUMMY_TAG := L_OLD_TAGS_A(L_NEW_TAGS(I) );
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        INSERT INTO DEMO_TAGS (
                            TAG,
                            CONTENT_ID,
                            CONTENT_TYPE
                        ) VALUES (
                            L_NEW_TAGS(I),
                            P_CONTENT_ID,
                            P_CONTENT_TYPE
                        );

                        L_MERGE_TAGS(L_MERGE_TAGS.COUNT + 1) := L_NEW_TAGS(I);
                END;
            END LOOP;
            --do the deletes

            FOR I IN 1..L_OLD_TAGS.COUNT LOOP
                BEGIN
                    L_DUMMY_TAG := L_NEW_TAGS_A(L_OLD_TAGS(I) );
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        DELETE FROM DEMO_TAGS
                        WHERE
                            CONTENT_ID = P_CONTENT_ID
                            AND   TAG = L_OLD_TAGS(I);

                        L_MERGE_TAGS(L_MERGE_TAGS.COUNT + 1) := L_OLD_TAGS(I);
                END;
            END LOOP;

        ELSE --just do inserts
            FOR I IN 1..L_NEW_TAGS.COUNT LOOP
                INSERT INTO DEMO_TAGS (
                    TAG,
                    CONTENT_ID,
                    CONTENT_TYPE
                ) VALUES (
                    L_NEW_TAGS(I),
                    P_CONTENT_ID,
                    P_CONTENT_TYPE
                );

                L_MERGE_TAGS(L_MERGE_TAGS.COUNT + 1) := L_NEW_TAGS(I);
            END LOOP;
        END IF;

        FOR I IN 1..L_MERGE_TAGS.COUNT LOOP
            MERGE INTO DEMO_TAGS_TYPE_SUM S USING ( SELECT
                COUNT(*) TAG_COUNT
                                                    FROM
                DEMO_TAGS
                                                    WHERE
                TAG = L_MERGE_TAGS(I)
                AND   CONTENT_TYPE = P_CONTENT_TYPE
            )
            T ON (
                S.TAG = L_MERGE_TAGS(I)
                AND S.CONTENT_TYPE = P_CONTENT_TYPE
            )
            WHEN NOT MATCHED THEN INSERT (
                TAG,
                    CONTENT_TYPE,
                TAG_COUNT
            ) VALUES (
                L_MERGE_TAGS(I),
                    P_CONTENT_TYPE,
                T.TAG_COUNT
            )
            WHEN MATCHED THEN UPDATE SET S.TAG_COUNT = T.TAG_COUNT;

            MERGE INTO DEMO_TAGS_SUM S USING ( SELECT
                SUM(TAG_COUNT) TAG_COUNT
                                               FROM
                DEMO_TAGS_TYPE_SUM
                                               WHERE
                TAG = L_MERGE_TAGS(I)
            )
            T ON ( S.TAG = L_MERGE_TAGS(I) )
            WHEN NOT MATCHED THEN INSERT (
                TAG,
                TAG_COUNT
            ) VALUES (
                L_MERGE_TAGS(I),
                T.TAG_COUNT
            )
            WHEN MATCHED THEN UPDATE SET S.TAG_COUNT = T.TAG_COUNT;

        END LOOP;

    END DEMO_TAG_SYNC;

END SAMPLE_PKG;
/

