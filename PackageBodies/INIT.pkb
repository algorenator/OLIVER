--
-- INIT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.INIT AS

    PROCEDURE SETCLIENTID (
        CID VARCHAR2
    )
        AS
    BEGIN
        DBMS_SESSION.SET_CONTEXT('OLIVER','ID',CID);
    END;

    FUNCTION BY_MEM_CLIENT (
        SCH VARCHAR2,
        TAB VARCHAR2
    ) RETURN VARCHAR2 AS
        CID   VARCHAR2(100) := SYS_CONTEXT('OLIVER','ID');
    BEGIN
  
--RETURN  'MEM_CLIENT_ID =SYS_CONTEXT('||''||'OLIVER'||''||','||''||'ID'||''||')';
        RETURN 'mem_client_id = SYS_CONTEXT(''OLIVER'',''ID'')';
--return null;
    END;

    FUNCTION BY_EMP_CLIENT (
        SCH VARCHAR2,
        TAB VARCHAR2
    ) RETURN VARCHAR2 AS
        CID   VARCHAR2(100) := SYS_CONTEXT('OLIVER','ID');
    BEGIN
  
--RETURN  'MEM_CLIENT_ID =SYS_CONTEXT('||''||'OLIVER'||''||','||''||'ID'||''||')';
        RETURN 'CO_CLIENT = SYS_CONTEXT(''OLIVER'',''ID'')';
--return null;
    END;

END INIT;
/

