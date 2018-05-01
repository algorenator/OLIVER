--
-- APEX_ERROR_HANDLING  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.APEX_ERROR_HANDLING (
    P_ERROR IN APEX_ERROR.T_ERROR
) RETURN APEX_ERROR.T_ERROR_RESULT IS
    L_RESULT            APEX_ERROR.T_ERROR_RESULT;
    L_REFERENCE_ID      NUMBER;
    L_CONSTRAINT_NAME   VARCHAR2(255);
BEGIN
--https://docs.oracle.com/database/apex-5.1/AEAPI/Example-of-an-Error-Handling-Function.htm#AEAPI2216
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
        /*    l_result.message         := 'An unexpected internal application error has occurred. '||
                                        'Please get in contact with XXX and provide '||
                                        'reference# '||to_char(l_reference_id, '999G999G999G990')||
                                        ' for further investigation.'||p_error.message;*/
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

        --
        -- Note: If you want to have friendlier ORA error messages, you can also define
        --       a text message with the name pattern APEX.ERROR.ORA-number
        --       There is no need to implement custom code for that.
        --

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
     /*   if p_error.ora_sqlcode in (-1, -2091, -2290, -2291, -2292) then
            l_constraint_name := apex_error.extract_constraint_name (
                                     p_error => p_error );

            begin
                select message
                  into l_result.message
                  from constraint_lookup
                 where constraint_name = l_constraint_name;
            exception when no_data_found then null; -- not every constraint has to be in our lookup table
            end;
        end if;*/

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
END APEX_ERROR_HANDLING;
/

