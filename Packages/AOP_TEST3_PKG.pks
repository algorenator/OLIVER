--
-- AOP_TEST3_PKG  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.AOP_TEST3_PKG AS
/* Copyright 2017 - APEX RnD
*/
-- AOP Version
    C_AOP_VERSION CONSTANT VARCHAR2(5) := '3.1';
-- Run automated tests in table AOP_AUTOMATED_TEST; if p_id is null, all tests will be ran
    PROCEDURE RUN_AUTOMATED_TESTS (
        P_ID       IN AOP_AUTOMATED_TEST.ID%TYPE,
        P_APP_ID   IN NUMBER
    );
-- to convert base64 you can use http://base64converter.com

END AOP_TEST3_PKG;
/

