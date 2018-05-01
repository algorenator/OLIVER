--
-- AUDIT_UTILS  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.AUDIT_UTILS AS

    FUNCTION GET_COLUMN_COMPARASION (
        TABLE_OWNER VARCHAR2,
        T_NAME VARCHAR2
    ) RETURN CLOB IS
        V_TEXT   CLOB;
    BEGIN
        FOR GETREC IN (
            SELECT
                COLUMN_NAME
            FROM
                ALL_TAB_COLUMNS
            WHERE
                TABLE_NAME = T_NAME
                AND   OWNER = TABLE_OWNER
                AND   DATA_TYPE <> 'BLOB'
        ) LOOP
            V_TEXT := V_TEXT
            || ' or( (:old.'
            || GETREC.COLUMN_NAME
            || ' <> :new.'
            || GETREC.COLUMN_NAME
            || ') or (:old.'
            || GETREC.COLUMN_NAME
            || ' IS NULL and  :new.'
            || GETREC.COLUMN_NAME
            || ' IS NOT NULL)  or (:old.'
            || GETREC.COLUMN_NAME
            || ' IS NOT NULL and  :new.'
            || GETREC.COLUMN_NAME
            || ' IS NULL))'
            || CHR(10)
            || '                ';
        END LOOP;

        V_TEXT := LTRIM(V_TEXT,' or');
        RETURN V_TEXT;
    END;

    FUNCTION GET_COLUMNS_FOR_TABLE (
        TABLE_OWNER   VARCHAR2,
        T_NAME        VARCHAR2,
        PREFIX        VARCHAR2
    ) RETURN CLOB IS
        V_TEXT   CLOB;
    BEGIN
        FOR GETREC IN (
            SELECT
                COLUMN_NAME
            FROM
                ALL_TAB_COLUMNS
            WHERE
                TABLE_NAME = T_NAME
                AND   OWNER = TABLE_OWNER
                AND   DATA_TYPE <> 'BLOB'
        ) LOOP
            V_TEXT := V_TEXT
            || ','
            || PREFIX
            || GETREC.COLUMN_NAME
            || CHR(10)
            || '                             ';
        END LOOP;

        RETURN LTRIM(V_TEXT,',');
    END;

    PROCEDURE CREATE_AUDIT_TABLES (
        TABLE_OWNER VARCHAR2
    ) IS

        CURSOR C_TABLES (
            TABLE_OWNER VARCHAR2
        ) IS SELECT
            OT.SCHEMA AS OWNER,
            OT.TNAME AS TABLE_NAME
             FROM
            AUDIT_TABLES OT;

        V_SQL     VARCHAR2(8000);
        V_COUNT   NUMBER := 0;
        V_AUD     VARCHAR2(30);
    BEGIN
        FOR R_TABLE IN C_TABLES(TABLE_OWNER) LOOP
            BEGIN
                V_AUD := 'AUDIT_'
                || R_TABLE.TABLE_NAME;
                V_SQL := 'create table '
                || V_AUD
                || ' as select * from '
                || R_TABLE.OWNER
                || '.'
                || R_TABLE.TABLE_NAME
                || ' where 0 = 1';

                DBMS_OUTPUT.PUT_LINE('Info: '
                || V_SQL);
                EXECUTE IMMEDIATE RTRIM(V_SQL);
                V_SQL := 'alter table '
                || V_AUD
                || ' add ( AUDIT_ACTION char(1), AUDIT_BY varchar2(2000), AUDIT_AT TIMESTAMP)';
                EXECUTE IMMEDIATE V_SQL;
                V_COUNT := C_TABLES%ROWCOUNT;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Failed to create table '
                    || V_AUD
                    || ' due to '
                    || SQLERRM);
            END;
        END LOOP;

        IF
            V_COUNT = 0
        THEN
            DBMS_OUTPUT.PUT_LINE('No audit tables created');
        ELSE
            DBMS_OUTPUT.PUT_LINE(V_COUNT
            || ' audit tables created.');
        END IF;

    END CREATE_AUDIT_TABLES;

    PROCEDURE CREATE_AUDIT_TRIGGERS (
        TABLE_OWNER    VARCHAR2,
        AUDIT_SCHEMA   VARCHAR2 DEFAULT 'OLIVER'
    ) IS

        CURSOR C_TAB_INC (
            TABLE_OWNER VARCHAR2
        ) IS SELECT
            OT.SCHEMA AS OWNER,
            OT.TNAME AS TABLE_NAME
             FROM
            AUDIT_TABLES OT;

        V_QUERY   VARCHAR2(32767);
        V_COUNT   NUMBER := 0;
    BEGIN
        FOR R_TAB_INC IN C_TAB_INC(TABLE_OWNER) LOOP
            BEGIN
                EXECUTE IMMEDIATE 'GRANT SELECT,INSERT,UPDATE,DELETE on '
                || AUDIT_SCHEMA
                || '.AUDIT_'
                || R_TAB_INC.TABLE_NAME
                || ' TO '
                || TABLE_OWNER;

                V_QUERY := 'CREATE OR REPLACE TRIGGER '
                || TABLE_OWNER
                || '.AUDIT_'
                || R_TAB_INC.TABLE_NAME
                || '_AIUD'
                || ' AFTER INSERT OR UPDATE OR DELETE ON '
                || R_TAB_INC.OWNER
                || '.'
                || R_TAB_INC.TABLE_NAME
                || ' FOR EACH ROW'
                || CHR(10)
                || '/* Generated automatically by AUDIT_UTILS.CREATE_AUDIT_TRIGGERS() */'
                || CHR(10)
                || 'DECLARE '
                || CHR(10)
                || ' v_user varchar2(2000):=null;'
                || CHR(10)
                || ' v_action varchar2(15);'
                || CHR(10)
                || 'BEGIN'
                || CHR(10)
                || '   SELECT SYS_CONTEXT (''USERENV'', ''session_user'')||'' | ''
            ||  SYS_CONTEXT (''USERENV'', ''IP_ADDRESS'')||'' | ''
            ||  SYS_CONTEXT (''USERENV'', ''OS_USER'')||'' | ''
            ||  SYS_CONTEXT (''USERENV'', ''MODULE'')||'' | ''
              session_user'
                || CHR(10)
                || '   INTO v_user'
                || CHR(10)
                || '   FROM DUAL;'
                || CHR(10)
                || CHR(10)
                || 'BEGIN'
                || CHR(10)
                || 'v_user:=v_user||CHR(10)||owa_util.get_cgi_env(''HTTP_HOST'');           '
                || CHR(10)
                || 'v_user:=v_user||CHR(10)||owa_util.get_cgi_env(''HTTP_PORT'');           '
                || CHR(10)
                || 'v_user:=v_user||CHR(10)||owa_util.get_cgi_env(''HTTP_REFERER'');        '
                || CHR(10)
                || 'v_user:=v_user||CHR(10)||owa_util.get_cgi_env(''HTTP_USER_AGENT'');     '
                || CHR(10)
                || 'v_user:=v_user||CHR(10)||owa_util.get_cgi_env(''PATH_INFO'');           '
                || CHR(10)
                || 'v_user:=v_user||CHR(10)||owa_util.get_cgi_env(''REMOTE_ADDR'');         '
                || CHR(10)
                || 'v_user:=v_user||CHR(10)||owa_util.get_cgi_env(''REMOTE_USER'');         '
                || CHR(10)
                || 'v_user:=v_user||CHR(10)||owa_util.get_cgi_env(''REQUEST_METHOD'');      '
                || CHR(10)
                || 'v_user:=v_user||CHR(10)||owa_util.get_cgi_env(''REQUEST_PROTOCOL'');    '
                || CHR(10)
                || 'v_user:=v_user||CHR(10)||apex_authentication.get_login_username_cookie; '
                || CHR(10)
                || 'EXCEPTION WHEN OTHERS THEN NULL;'
                || CHR(10)
                || 'END;'
                || CHR(10)
                || ' if inserting then '
                || CHR(10)
                || ' v_action:=''INSERT'';'
                || CHR(10)
                || '      insert into '
                || AUDIT_SCHEMA
                || '.AUDIT_'
                || R_TAB_INC.TABLE_NAME
                || '('
                || GET_COLUMNS_FOR_TABLE(R_TAB_INC.OWNER,R_TAB_INC.TABLE_NAME,NULL)
                || '    ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)'
                || CHR(10)
                || '      values ('
                || GET_COLUMNS_FOR_TABLE(R_TAB_INC.OWNER,R_TAB_INC.TABLE_NAME,':new.')
                || '    ,''I'',v_user,SYSDATE);'
                || CHR(10)
                || ' elsif updating then '
                || CHR(10)
                || ' v_action:=''UPDATE'';'
                || CHR(10)
                || '   if '
                || GET_COLUMN_COMPARASION(R_TAB_INC.OWNER,R_TAB_INC.TABLE_NAME)
                || ' then '
                || CHR(10)
                || '      insert into '
                || AUDIT_SCHEMA
                || '.AUDIT_'
                || R_TAB_INC.TABLE_NAME
                || '('
                || GET_COLUMNS_FOR_TABLE(R_TAB_INC.OWNER,R_TAB_INC.TABLE_NAME,NULL)
                || '    ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)'
                || CHR(10)
                || '      values ('
                || GET_COLUMNS_FOR_TABLE(R_TAB_INC.OWNER,R_TAB_INC.TABLE_NAME,':new.')
                || '    ,''U'',v_user,SYSDATE);'
                || CHR(10)
                || '   end if;'
                || ' elsif deleting then'
                || CHR(10)
                || ' v_action:=''DELETING'';'
                || CHR(10)
                || '      insert into '
                || AUDIT_SCHEMA
                || '.AUDIT_'
                || R_TAB_INC.TABLE_NAME
                || '('
                || GET_COLUMNS_FOR_TABLE(R_TAB_INC.OWNER,R_TAB_INC.TABLE_NAME,NULL)
                || '    ,AUDIT_ACTION,AUDIT_BY,AUDIT_AT)'
                || CHR(10)
                || '      values ('
                || GET_COLUMNS_FOR_TABLE(R_TAB_INC.OWNER,R_TAB_INC.TABLE_NAME,':old.')
                || '    ,''D'',v_user,SYSDATE);'
                || CHR(10)
                || '   end if;'
                || CHR(10)
                || ' EXCEPTION WHEN OTHERS THEN NULL;'
                || CHR(10)
                || ' END;';

                DBMS_OUTPUT.PUT_LINE('CREATE TRIGGER '
                || REPLACE(R_TAB_INC.TABLE_NAME,'TABLE_','TRIGGER_') );

                EXECUTE IMMEDIATE V_QUERY;
                DBMS_OUTPUT.PUT_LINE('Audit trigger '
                || REPLACE(R_TAB_INC.TABLE_NAME,'TABLE_','TRIGGER_')
                || ' created.');

                V_COUNT := C_TAB_INC%ROWCOUNT;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Failed to create audit trigger for '
                    || R_TAB_INC.OWNER
                    || '.'
                    || R_TAB_INC.TABLE_NAME
                    || ' due to '
                    || SQLERRM);
            END;
        END LOOP;

        IF
            V_COUNT = 0
        THEN
            DBMS_OUTPUT.PUT_LINE('No audit triggers created');
        END IF;
    END CREATE_AUDIT_TRIGGERS;

    PROCEDURE POPULATE_APEX_LOG
        AS
    BEGIN
        INSERT INTO AUDIT_APEX_ACTIVITY_LOG (
            WORKSPACE,
            APEX_USER,
            APPLICATION_ID,
            APPLICATION_NAME,
            APPLICATION_SCHEMA_OWNER,
            PAGE_ID,
            PAGE_NAME,
            VIEW_DATE,
            THINK_TIME,
            LOG_CONTEXT,
            ELAPSED_TIME,
            ROWS_QUERIED,
            IP_ADDRESS,
            AGENT,
            APEX_SESSION_ID,
            ERROR_MESSAGE,
            ERROR_ON_COMPONENT_TYPE,
            ERROR_ON_COMPONENT_NAME,
            PAGE_VIEW_MODE,
            REGIONS_FROM_CACHE,
            WORKSPACE_ID
        )
            SELECT
                ALOG.WORKSPACE,
                ALOG.APEX_USER,
                ALOG.APPLICATION_ID,
                ALOG.APPLICATION_NAME,
                ALOG.APPLICATION_SCHEMA_OWNER,
                ALOG.PAGE_ID,
                ALOG.PAGE_NAME,
                ALOG.VIEW_DATE,
                ALOG.THINK_TIME,
                ALOG.LOG_CONTEXT,
                ALOG.ELAPSED_TIME,
                ALOG.ROWS_QUERIED,
                ALOG.IP_ADDRESS,
                ALOG.AGENT,
                ALOG.APEX_SESSION_ID,
                ALOG.ERROR_MESSAGE,
                ALOG.ERROR_ON_COMPONENT_TYPE,
                ALOG.ERROR_ON_COMPONENT_NAME,
                ALOG.PAGE_VIEW_MODE,
                ALOG.REGIONS_FROM_CACHE,
                ALOG.WORKSPACE_ID
            FROM
                APEX_WORKSPACE_ACTIVITY_LOG ALOG,
                AUDIT_APEX_ACTIVITY_LOG X
            WHERE
                ALOG.VIEW_DATE = X.VIEW_DATE (+)
                AND   NVL(ALOG.APEX_SESSION_ID,'') = NVL(X.APEX_SESSION_ID(+),'')
                AND   ALOG.APPLICATION_SCHEMA_OWNER = USER
                AND   X.ROWID IS NULL
                AND   ALOG.APEX_SESSION_ID IS NOT NULL;

        INSERT INTO AUDIT_APEX_ACCESS_LOG (
            WORKSPACE,
            APPLICATION_ID,
            APPLICATION_NAME,
            USER_NAME,
            AUTHENTICATION_METHOD,
            APPLICATION_SCHEMA_OWNER,
            ACCESS_DATE,
            IP_ADDRESS,
            AUTHENTICATION_RESULT,
            CUSTOM_STATUS_TEXT,
            WORKSPACE_ID
        )
            SELECT
                ALOG.WORKSPACE,
                ALOG.APPLICATION_ID,
                ALOG.APPLICATION_NAME,
                ALOG.USER_NAME,
                ALOG.AUTHENTICATION_METHOD,
                ALOG.APPLICATION_SCHEMA_OWNER,
                ALOG.ACCESS_DATE,
                ALOG.IP_ADDRESS,
                ALOG.AUTHENTICATION_RESULT,
                ALOG.CUSTOM_STATUS_TEXT,
                ALOG.WORKSPACE_ID
            FROM
                APEX_WORKSPACE_ACCESS_LOG ALOG,
                AUDIT_APEX_ACCESS_LOG X
            WHERE
                ALOG.ACCESS_DATE = X.ACCESS_DATE (+)
                AND   X.ROWID IS NULL
                AND   ALOG.APPLICATION_SCHEMA_OWNER = USER;

        COMMIT;
    END;

END AUDIT_UTILS;
/

