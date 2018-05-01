--
-- SAMPLE_PKG  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.SAMPLE_PKG IS
    --
    -- Error Handling function
    --
    FUNCTION DEMO_ERROR_HANDLING (
        P_ERROR IN APEX_ERROR.T_ERROR
    ) RETURN APEX_ERROR.T_ERROR_RESULT;
    
    --
    -- Tag Cleaner function
    --

    FUNCTION DEMO_TAGS_CLEANER (
        P_TAGS   IN VARCHAR2,
        P_CASE   IN VARCHAR2 DEFAULT 'U'
    ) RETURN VARCHAR2;
    
    --
    -- Tag Synchronisation Procedure
    --

    PROCEDURE DEMO_TAG_SYNC (
        P_NEW_TAGS       IN VARCHAR2,
        P_OLD_TAGS       IN VARCHAR2,
        P_CONTENT_TYPE   IN VARCHAR2,
        P_CONTENT_ID     IN NUMBER
    );

END SAMPLE_PKG;
/

