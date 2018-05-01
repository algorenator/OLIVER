--
-- AOP_SAMPLE3_PKG  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.AOP_SAMPLE3_PKG AS
/* Copyright 2017 - APEX RnD
*/
-- AOP Version
    C_AOP_VERSION CONSTANT VARCHAR2(5) := '3.1';
--
-- Store output in AOP Output table
--
    PROCEDURE AOP_STORE_DOCUMENT (
        P_OUTPUT_BLOB        IN BLOB,
        P_OUTPUT_FILENAME    IN VARCHAR2,
        P_OUTPUT_MIME_TYPE   IN VARCHAR2
    );
--
-- Send email from AOP
--

    PROCEDURE SEND_EMAIL_PRC (
        P_OUTPUT_BLOB        IN BLOB,
        P_OUTPUT_FILENAME    IN VARCHAR2,
        P_OUTPUT_MIME_TYPE   IN VARCHAR2
    );
--
-- AOP_PLSQL_PKG example
--

    PROCEDURE CALL_AOP_PLSQL3_PKG;
--
-- AOP_API3_PKG example
--

    PROCEDURE CALL_AOP_API3_PKG;

    PROCEDURE SCHEDULE_AOP_API3_PKG;
--
-- REST example (call this procedure from ORDS)
--

    FUNCTION GET_FILE (
        P_CUSTOMER_ID   IN NUMBER,
        P_OUTPUT_TYPE   IN VARCHAR2
    ) RETURN BLOB;
--
-- write to filesystem
--

    PROCEDURE WRITE_FILESYSTEM;
--
-- view the tags that are used in a template (docx)
--

    PROCEDURE GET_TAGS_IN_TEMPLATE;
--
-- all possible options for Excel cell styling
--

    FUNCTION TEST_EXCEL_STYLES RETURN CLOB;

END AOP_SAMPLE3_PKG;
/

