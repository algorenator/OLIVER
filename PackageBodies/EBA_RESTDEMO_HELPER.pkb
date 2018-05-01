--
-- EBA_RESTDEMO_HELPER  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.EBA_RESTDEMO_HELPER AS

    TYPE T_HTTP_STATUS_CODES IS
        TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
    TYPE T_SERVICE_URL_PARAMETERS IS
        TABLE OF EBA_RESTDEMO_URLPARAMETERS%ROWTYPE INDEX BY BINARY_INTEGER;
    TYPE T_SERVICE_COLUMN_MAPPINGS IS
        TABLE OF EBA_RESTDEMO_COLUMN_MAPPINGS%ROWTYPE INDEX BY BINARY_INTEGER;
    LF                          CONSTANT VARCHAR2(1) := CHR(10);
    G_SERVICE_URL_PARAMETERS    T_SERVICE_URL_PARAMETERS;
    G_SERVICE_COLUMN_MAPPINGS   T_SERVICE_COLUMN_MAPPINGS;
    G_SERVICE_DATA              EBA_RESTDEMO_SERVICES%ROWTYPE;
    G_HTTP_STATUS_CODES         T_HTTP_STATUS_CODES;
    G_SERVICE_PASSWORDS         APEX_APPLICATION_GLOBAL.VC_ARR2;
    G_START_TIME                TIMESTAMP WITH TIME ZONE;
    G_REST_DATA                 CLOB;
    C_INDENT                    VARCHAR2(4) := '    ';
    G_DB_CHARSET                VARCHAR2(255);
    -----------------------------------------------------------------------------------------------------
    -- Timing functions
    --

    PROCEDURE START_TIMER
        IS
    BEGIN
        G_START_TIME := SYSTIMESTAMP;
    END START_TIMER;

    FUNCTION GET_ELAPSED_TIME RETURN NUMBER
        IS
    BEGIN
        RETURN EXTRACT ( SECOND FROM ( SYSTIMESTAMP - G_START_TIME ) ) * 100;
    END GET_ELAPSED_TIME;
    -----------------------------------------------------------------------------------------------------
    -- General helper functions
    --

    PROCEDURE LOAD (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_FORCE        IN BOOLEAN DEFAULT FALSE
    )
        IS
    BEGIN
        IF
            G_DB_CHARSET IS NULL
        THEN
            BEGIN
                SELECT
                    VALUE
                INTO
                    G_DB_CHARSET
                FROM
                    SYS.NLS_DATABASE_PARAMETERS
                WHERE
                    PARAMETER = 'NLS_CHARACTERSET';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    G_DB_CHARSET := 'al32utf8';
            END;
        END IF;

        IF
            P_FORCE OR ( P_SERVICE_ID IS NOT NULL AND ( G_SERVICE_DATA.ID IS NULL OR G_SERVICE_DATA.ID != P_SERVICE_ID ) )
        THEN
            SELECT
                *
            INTO
                G_SERVICE_DATA
            FROM
                EBA_RESTDEMO_SERVICES
            WHERE
                ID = P_SERVICE_ID;

            SELECT
                *
            BULK COLLECT INTO
                G_SERVICE_COLUMN_MAPPINGS
            FROM
                EBA_RESTDEMO_COLUMN_MAPPINGS
            WHERE
                SERVICE_ID = P_SERVICE_ID
            ORDER BY
                COLUMN_SEQ;

            SELECT
                *
            BULK COLLECT INTO
                G_SERVICE_URL_PARAMETERS
            FROM
                EBA_RESTDEMO_URLPARAMETERS
            WHERE
                SERVICE_ID = P_SERVICE_ID;

        END IF;

    END LOAD;

    FUNCTION PREPARE_URL (
        P_URL        IN VARCHAR2,
        P_METHOD     IN VARCHAR2 DEFAULT 'GET',
        P_GENERATE   IN BOOLEAN DEFAULT FALSE
    ) RETURN VARCHAR2 IS

        L_URL           VARCHAR2(32767) := P_URL;
        L_FIRST_PARAM   BOOLEAN := TRUE;
        L_PARAM_ADDED   BOOLEAN := FALSE;
    BEGIN
        IF
            INSTR(P_URL,'?') > 0
        THEN
            L_FIRST_PARAM := FALSE;
        END IF;
        FOR H IN 1..G_SERVICE_URL_PARAMETERS.COUNT LOOP
            IF
                G_SERVICE_URL_PARAMETERS(H).PARAM_FOR = P_METHOD
            THEN
                IF
                    L_FIRST_PARAM
                THEN
                    L_URL := L_URL
                    || '?';
                    L_FIRST_PARAM := FALSE;
                ELSE
                    L_URL := L_URL
                    || '&';
                END IF;

                L_PARAM_ADDED := TRUE;
                L_URL := L_URL
                || G_SERVICE_URL_PARAMETERS(H).PARAM_NAME
                || '='
                || CASE
                    WHEN P_GENERATE THEN ''' || sys.utl_url.escape('''
                    || G_SERVICE_URL_PARAMETERS(H).PARAM_VALUE
                    || ''') '
                    || CASE
                        WHEN H < G_SERVICE_URL_PARAMETERS.COUNT THEN ' || '''
                    END
                    ELSE SYS.UTL_URL.ESCAPE(G_SERVICE_URL_PARAMETERS(H).PARAM_VALUE)
                END;

                L_PARAM_ADDED := TRUE;
            END IF;
        END LOOP;

        IF
            P_GENERATE
        THEN
            L_URL := ''''
            || L_URL
            || CASE
                WHEN NOT L_PARAM_ADDED THEN ''''
            END;
        END IF;

        RETURN L_URL;
    END PREPARE_URL;

    FUNCTION PATH_JSON_TO_XML (
        P_PATH IN VARCHAR2
    ) RETURN VARCHAR2 IS

        L_STEPS   WWV_FLOW_T_VARCHAR2;
        L_STEP    VARCHAR2(32767);
        L_PATH    VARCHAR2(32767) := '';
        L_IDX     NUMBER;
        L_OCC     NUMBER := 1;
    BEGIN
        L_STEPS := WWV_FLOW_STRING.SPLIT(P_PATH,'.');
        FOR I IN 1..L_STEPS.COUNT LOOP
            L_STEP := TRIM ( BOTH '"' FROM L_STEPS(I) );
            L_STEP := REPLACE(L_STEP,'/','_');
            L_OCC := 1;
            L_IDX := 0;
            WHILE L_IDX IS NOT NULL LOOP
                BEGIN
                    L_IDX := TO_NUMBER(REGEXP_SUBSTR(L_STEP,'(\[)(\d*)(\])',1,L_OCC,'i',2) );
                EXCEPTION
                    WHEN OTHERS THEN
                        L_IDX := NULL;
                END;

                IF
                    L_IDX IS NOT NULL
                THEN
                    L_IDX := L_IDX + 1;
                    L_STEP := REGEXP_REPLACE(L_STEP,'(\[)(\d*)(\])','/row['
                    || L_IDX
                    || ']',1,L_OCC,'i');

                    L_OCC := L_OCC + 1;
                END IF;

            END LOOP;

            IF
                L_STEP LIKE '-%'
            THEN
                L_STEP := '_'
                || SUBSTR(L_STEP,2);
            END IF;

            L_PATH := L_PATH
            || REGEXP_REPLACE(L_STEP,'[^][:alnum:][/_-]','_');
            IF
                I < L_STEPS.COUNT
            THEN
                L_PATH := L_PATH
                || '/';
            END IF;
        END LOOP;

        RETURN L_PATH;
    END PATH_JSON_TO_XML;
    -----------------------------------------------------------------------------------------------------
    -- Authentication / Credentials functions
    --

    PROCEDURE OAUTH_AUTHENTICATE (
        P_PASSWORD IN VARCHAR2 DEFAULT NULL
    )
        IS
    BEGIN
        IF
            G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2'
        THEN
            START_TIMER;
            APEX_WEB_SERVICE.OAUTH_AUTHENTICATE(P_TOKEN_URL => G_SERVICE_DATA.OAUTH_TOKEN_URL,P_CLIENT_ID => G_SERVICE_DATA.OAUTH_CLIENTID,P_CLIENT_SECRET
=> COALESCE(P_PASSWORD,GET_PASSWORD(G_SERVICE_DATA.ID) ) );

            LOG(G_SERVICE_DATA.ID,G_SERVICE_DATA.NAME,'OAUTH_AUTHENTICATE',G_SERVICE_DATA.OAUTH_TOKEN_URL,NULL,APEX_WEB_SERVICE.G_STATUS_CODE
,GET_ELAPSED_TIME,NULL,NULL);

        END IF;
    END OAUTH_AUTHENTICATE;

    FUNCTION GET_PASSWORD (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE
    ) RETURN VARCHAR2 IS
        L_PASSWORD     VARCHAR2(255);
        L_SERVICE_ID   EBA_RESTDEMO_SERVICES.ID%TYPE;
    BEGIN
        IF
            G_SERVICE_PASSWORDS.COUNT = 0
        THEN
            G_SERVICE_PASSWORDS := APEX_UTIL.STRING_TO_TABLE(V('P0_CREDENTIALS') );
        END IF;

        FOR I IN 1..G_SERVICE_PASSWORDS.COUNT LOOP
            L_SERVICE_ID := TO_NUMBER(SUBSTR(G_SERVICE_PASSWORDS(I),1,INSTR(G_SERVICE_PASSWORDS(I),'#') - 1) );

            IF
                L_SERVICE_ID = P_SERVICE_ID
            THEN
                L_PASSWORD := SUBSTR(G_SERVICE_PASSWORDS(I),INSTR(G_SERVICE_PASSWORDS(I),'#') + 1);

                EXIT;
            END IF;

        END LOOP;

        IF
            L_PASSWORD IS NOT NULL
        THEN
            RETURN UTL_RAW.CAST_TO_VARCHAR2(HEXTORAW(L_PASSWORD) );
        ELSE
            RETURN NULL;
        END IF;

    END GET_PASSWORD;

    FUNCTION REQUIRES_PASSWORD (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE
    ) RETURN BOOLEAN
        IS
    BEGIN
        LOAD(P_SERVICE_ID);
        IF
            G_SERVICE_DATA.AUTH_TYPE = 'NONE'
        THEN
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
    END REQUIRES_PASSWORD;

    PROCEDURE UPDATE_PASSWORD (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_PASSWORD     IN VARCHAR2
    ) IS
        L_SERVICE_ID   EBA_RESTDEMO_SERVICES.ID%TYPE;
        L_UPDATED      BOOLEAN := FALSE;
    BEGIN
        IF
            G_SERVICE_PASSWORDS.COUNT = 0
        THEN
            G_SERVICE_PASSWORDS := APEX_UTIL.STRING_TO_TABLE(V('P0_CREDENTIALS') );
        END IF;

        FOR I IN 1..G_SERVICE_PASSWORDS.COUNT LOOP
            L_SERVICE_ID := TO_NUMBER(SUBSTR(G_SERVICE_PASSWORDS(I),1,INSTR(G_SERVICE_PASSWORDS(I),'#') - 1) );

            IF
                L_SERVICE_ID = P_SERVICE_ID
            THEN
                G_SERVICE_PASSWORDS(I) := P_SERVICE_ID
                || '#'
                || RAWTOHEX(UTL_RAW.CAST_TO_RAW(P_PASSWORD) );

                L_UPDATED := TRUE;
                EXIT;
            END IF;

        END LOOP;

        IF
            NOT L_UPDATED
        THEN
            G_SERVICE_PASSWORDS(G_SERVICE_PASSWORDS.COUNT + 1) := P_SERVICE_ID
            || '#'
            || RAWTOHEX(UTL_RAW.CAST_TO_RAW(P_PASSWORD) );
        END IF;

        APEX_UTIL.SET_SESSION_STATE('P0_CREDENTIALS',APEX_UTIL.TABLE_TO_STRING(G_SERVICE_PASSWORDS) );
    END UPDATE_PASSWORD;

    FUNCTION PASSWORD_IS_VALID (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_PASSWORD     IN VARCHAR2
    ) RETURN BOOLEAN IS
        L_DUMMY   VARCHAR2(32767);
    BEGIN
        LOAD(P_SERVICE_ID);
        IF
            G_SERVICE_DATA.AUTH_TYPE = 'BASIC'
        THEN
            L_DUMMY := APEX_WEB_SERVICE.MAKE_REST_REQUEST(P_URL => PREPARE_URL(G_SERVICE_DATA.ENDPOINT),P_HTTP_METHOD => 'GET',P_USERNAME => G_SERVICE_DATA
.AUTH_BASIC_USERNAME,P_PASSWORD => P_PASSWORD,P_SCHEME => 'Basic');

        ELSIF G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2' THEN
            OAUTH_AUTHENTICATE(P_PASSWORD);
        END IF;

        IF
            APEX_WEB_SERVICE.G_STATUS_CODE BETWEEN 200 AND 399
        THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;

    END PASSWORD_IS_VALID;
    -----------------------------------------------------------------------------------------------------
    --
    -- Service Metadata functions
    --
    --

    FUNCTION CREATE_SERVICE (
        P_NAME                  IN EBA_RESTDEMO_SERVICES.NAME%TYPE,
        P_SERVICE_TYPE          IN EBA_RESTDEMO_SERVICES.SERVICE_TYPE%TYPE,
        P_ENDPOINT              IN EBA_RESTDEMO_SERVICES.ENDPOINT%TYPE,
        P_AUTH_TYPE             IN EBA_RESTDEMO_SERVICES.AUTH_TYPE%TYPE,
        P_AUTH_BASIC_USERNAME   IN EBA_RESTDEMO_SERVICES.AUTH_BASIC_USERNAME%TYPE,
        P_AUTH_BASIC_PASSWORD   IN EBA_RESTDEMO_SERVICES.AUTH_BASIC_PASSWORD%TYPE,
        P_OAUTH_TOKEN_URL       IN EBA_RESTDEMO_SERVICES.OAUTH_TOKEN_URL%TYPE,
        P_OAUTH_CLIENTID        IN EBA_RESTDEMO_SERVICES.OAUTH_CLIENTID%TYPE,
        P_OAUTH_CLIENTSECRET    IN EBA_RESTDEMO_SERVICES.OAUTH_CLIENTSECRET%TYPE,
        P_RESPONSE_CHARSET      IN EBA_RESTDEMO_SERVICES.RESPONSE_CHARSET%TYPE,
        P_RESPONSE_TYPE         IN EBA_RESTDEMO_SERVICES.RESPONSE_TYPE%TYPE,
        P_DATA_ROW_SELECTOR     IN EBA_RESTDEMO_SERVICES.DATA_ROW_SELECTOR%TYPE,
        P_DATA_ALLOW_INSERT     IN EBA_RESTDEMO_SERVICES.DATA_ALLOW_INSERT%TYPE,
        P_DATA_ALLOW_UPDATE     IN EBA_RESTDEMO_SERVICES.DATA_ALLOW_INSERT%TYPE,
        P_DATA_ALLOW_DELETE     IN EBA_RESTDEMO_SERVICES.DATA_ALLOW_INSERT%TYPE
    ) RETURN NUMBER IS
        L_SERVICE_ID   NUMBER;
    BEGIN
        INSERT INTO EBA_RESTDEMO_SERVICES (
            NAME,
            SERVICE_TYPE,
            ENDPOINT,
            AUTH_TYPE,
            AUTH_BASIC_USERNAME,
            AUTH_BASIC_PASSWORD,
            OAUTH_TOKEN_URL,
            OAUTH_CLIENTID,
            OAUTH_CLIENTSECRET,
            RESPONSE_CHARSET,
            RESPONSE_TYPE,
            DATA_ROW_SELECTOR,
            DATA_ALLOW_INSERT,
            DATA_ALLOW_UPDATE,
            DATA_ALLOW_DELETE
        ) VALUES (
            P_NAME,
            P_SERVICE_TYPE,
            P_ENDPOINT,
            P_AUTH_TYPE,
            P_AUTH_BASIC_USERNAME,
            NULL,
            P_OAUTH_TOKEN_URL,
            P_OAUTH_CLIENTID,
            NULL,
            P_RESPONSE_CHARSET,
            P_RESPONSE_TYPE,
            P_DATA_ROW_SELECTOR,
            P_DATA_ALLOW_INSERT,
            P_DATA_ALLOW_UPDATE,
            P_DATA_ALLOW_DELETE
        ) RETURNING ID INTO L_SERVICE_ID;

        LOG(L_SERVICE_ID,P_NAME,'SERVICE_CREATE',NULL,NULL,NULL,NULL,NULL,NULL);

        RETURN L_SERVICE_ID;
    END CREATE_SERVICE;

    PROCEDURE CREATE_HRSAMPLE_SERVICE IS
        L_SERVICE_ID       NUMBER;
        L_WORKSPACE_NAME   VARCHAR2(255);
    BEGIN
        SELECT
            WORKSPACE
        INTO
            L_WORKSPACE_NAME
        FROM
            APEX_APPLICATIONS
        WHERE
            APPLICATION_ID = V('APP_ID');

        INSERT INTO EBA_RESTDEMO_SERVICES (
            NAME,
            SERVICE_TYPE,
            ENDPOINT,
            AUTH_TYPE,
            RESPONSE_TYPE,
            DATA_ROW_SELECTOR,
            DATA_ALLOW_INSERT,
            DATA_ALLOW_UPDATE,
            DATA_ALLOW_DELETE
        ) VALUES (
            'oracle.example.hr',
            'ORDS',
            OWA_UTIL.GET_CGI_ENV('REQUEST_PROTOCOL')
            || '://'
            || OWA_UTIL.GET_CGI_ENV('HTTP_HOST')
            || OWA_UTIL.GET_CGI_ENV('SCRIPT_NAME')
            || '/'
            || LOWER(L_WORKSPACE_NAME)
            || '/'
            || 'hr/employees',
            'NONE',
            'JSON',
            'items',
            'N',
            'N',
            'N'
        ) RETURNING ID INTO L_SERVICE_ID;

        INSERT INTO EBA_RESTDEMO_COLUMN_MAPPINGS (
            SERVICE_ID,
            COLUMN_SEQ,
            COLUMN_NAME,
            COLUMN_SELECTOR,
            PRIMARY_KEY,
            DATA_TYPE,
            DATA_TYPE_LEN,
            DATA_TYPE_PREC,
            DATA_TYPE_SCALE,
            DATA_FORMAT_MASK
        ) VALUES (
            L_SERVICE_ID,
            1,
            'EMPNO',
            'empno',
            'Y',
            'NUMBER',
            NULL,
            NULL,
            NULL,
            NULL
        );

        INSERT INTO EBA_RESTDEMO_COLUMN_MAPPINGS (
            SERVICE_ID,
            COLUMN_SEQ,
            COLUMN_NAME,
            COLUMN_SELECTOR,
            PRIMARY_KEY,
            DATA_TYPE,
            DATA_TYPE_LEN,
            DATA_TYPE_PREC,
            DATA_TYPE_SCALE,
            DATA_FORMAT_MASK
        ) VALUES (
            L_SERVICE_ID,
            2,
            'ENAME',
            'ename',
            'N',
            'VARCHAR2',
            20,
            NULL,
            NULL,
            NULL
        );

        LOG(L_SERVICE_ID,'oracle.example.hr','SERVICE_CREATE',NULL,NULL,NULL,NULL,NULL,NULL);

    END CREATE_HRSAMPLE_SERVICE;

    FUNCTION SUPPORTS_DML (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE
    ) RETURN BOOLEAN IS
        L_DML_OK   BOOLEAN := TRUE;
    BEGIN
        LOAD(P_SERVICE_ID);
        IF
            G_SERVICE_DATA.DATA_ALLOW_INSERT = 'Y' OR G_SERVICE_DATA.DATA_ALLOW_UPDATE = 'Y' OR G_SERVICE_DATA.DATA_ALLOW_DELETE = 'Y'
        THEN
            L_DML_OK := TRUE;
        ELSE
            L_DML_OK := FALSE;
        END IF;

        IF
            L_DML_OK
        THEN
            L_DML_OK := FALSE;
            FOR I IN 1..G_SERVICE_COLUMN_MAPPINGS.COUNT LOOP
                IF
                    G_SERVICE_COLUMN_MAPPINGS(I).PRIMARY_KEY = 'Y'
                THEN
                    L_DML_OK := TRUE;
                    EXIT;
                END IF;
            END LOOP;

        END IF;

        RETURN L_DML_OK;
    END SUPPORTS_DML;

    FUNCTION GET_COLUMN_HEADINGS (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE
    ) RETURN VARCHAR2 IS
        L_COLUMN_HEADINGS   VARCHAR2(32767);
    BEGIN
        LOAD(P_SERVICE_ID);
        FOR I IN 1..G_SERVICE_COLUMN_MAPPINGS.COUNT LOOP
            L_COLUMN_HEADINGS := L_COLUMN_HEADINGS
            || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
            || ':';
        END LOOP;

        RETURN SUBSTR(L_COLUMN_HEADINGS,1,LENGTH(L_COLUMN_HEADINGS) - 1);
    END GET_COLUMN_HEADINGS;

    PROCEDURE DELETE_SERVICE (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE
    )
        IS
    BEGIN
        DELETE FROM EBA_RESTDEMO_SERVICES WHERE
            ID = P_SERVICE_ID;

    END DELETE_SERVICE;

    PROCEDURE PURGE_LOG
        IS
    BEGIN
        EXECUTE IMMEDIATE 'truncate table eba_restdemo_log';
        LOG(0,'- Application Action -','RESET_LOG',NULL,NULL,NULL,NULL,NULL,'Log purged');

    END PURGE_LOG;

    PROCEDURE RESET_DATA (
        P_INSTALL_SAMPLE IN BOOLEAN
    )
        IS
    BEGIN
        DELETE FROM EBA_RESTDEMO_SERVICES;

        DELETE FROM EBA_RESTDEMO_LOG;

        LOG(0,'- Application Action -','RESET_DATA',NULL,NULL,NULL,NULL,NULL,'Application reset');

    END RESET_DATA;

    PROCEDURE SAMPLE_DATA_TYPES (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE
    ) IS

        TYPE T_COLUMN IS
            TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
        TYPE T_TABLE IS
            TABLE OF T_COLUMN INDEX BY BINARY_INTEGER;
        L_TABLE          T_TABLE;
        L_TYPES          T_COLUMN;
        L_SQL            VARCHAR2(32767);
        L_NUMBER         NUMBER;
        L_IS_NUMBER      BOOLEAN;
        L_DATE           DATE;
        L_IS_DATE        BOOLEAN;
        L_THE_FORMAT     VARCHAR2(255);
        L_DATE_FORMATS   T_COLUMN;
    BEGIN
        LOAD(P_SERVICE_ID,TRUE);
        IF
            G_SERVICE_COLUMN_MAPPINGS.COUNT = 0
        THEN
            RETURN;
        END IF;
        L_DATE_FORMATS(L_DATE_FORMATS.COUNT + 1) := 'DD-MON-RR';
        L_DATE_FORMATS(L_DATE_FORMATS.COUNT + 1) := 'YYYY-MM-DD';
        L_DATE_FORMATS(L_DATE_FORMATS.COUNT + 1) := 'YYYY-MM-DD HH24:MI:SS';
        L_DATE_FORMATS(L_DATE_FORMATS.COUNT + 1) := 'YYYY-MM-DD"T"HH24:MI:SS"Z"';
        L_DATE_FORMATS(L_DATE_FORMATS.COUNT + 1) := 'YYYYMMDDHH24MISS';
        L_DATE_FORMATS(L_DATE_FORMATS.COUNT + 1) := WWV_FLOW.G_DATE_FORMAT;
        L_DATE_FORMATS(L_DATE_FORMATS.COUNT + 1) := WWV_FLOW.G_DATE_TIME_FORMAT;
        L_DATE_FORMATS(L_DATE_FORMATS.COUNT + 1) := WWV_FLOW.G_NLS_DATE_FORMAT;
        FOR I IN 1..G_SERVICE_COLUMN_MAPPINGS.COUNT LOOP
            G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE := 'VARCHAR2';
            G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE_LEN := 4000;
        END LOOP;

        L_SQL := 'select ';
        FOR I IN 1..LEAST(G_SERVICE_COLUMN_MAPPINGS.COUNT,100) LOOP
            L_SQL := L_SQL
            || '"'
            || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
            || '",';
        END LOOP;

        FOR I IN ( G_SERVICE_COLUMN_MAPPINGS.COUNT + 1 )..100 LOOP
            L_SQL := L_SQL
            || 'null,';
        END LOOP;

        L_SQL := SUBSTR(L_SQL,1,LENGTH(L_SQL) - 1);
        L_SQL := L_SQL
        || ' from ('
        || GET_SQL_QUERY(P_MAX_COLUMNS => 100)
        || ') where rownum <= 25';

        EXECUTE IMMEDIATE L_SQL BULK COLLECT INTO
            L_TABLE(1),L_TABLE(2),L_TABLE(3),L_TABLE(4),L_TABLE(5),L_TABLE(6),L_TABLE(7),L_TABLE(8),L_TABLE(9),L_TABLE(10),L_TABLE(11),L_TABLE
(12),L_TABLE(13),L_TABLE(14),L_TABLE(15),L_TABLE(16),L_TABLE(17),L_TABLE(18),L_TABLE(19),L_TABLE(20),L_TABLE(21),L_TABLE(22),L_TABLE
(23),L_TABLE(24),L_TABLE(25),L_TABLE(26),L_TABLE(27),L_TABLE(28),L_TABLE(29),L_TABLE(30),L_TABLE(31),L_TABLE(32),L_TABLE(33),L_TABLE
(34),L_TABLE(35),L_TABLE(36),L_TABLE(37),L_TABLE(38),L_TABLE(39),L_TABLE(40),L_TABLE(41),L_TABLE(42),L_TABLE(43),L_TABLE(44),L_TABLE
(45),L_TABLE(46),L_TABLE(47),L_TABLE(48),L_TABLE(49),L_TABLE(50),L_TABLE(51),L_TABLE(52),L_TABLE(53),L_TABLE(54),L_TABLE(55),L_TABLE
(56),L_TABLE(57),L_TABLE(58),L_TABLE(59),L_TABLE(60),L_TABLE(61),L_TABLE(62),L_TABLE(63),L_TABLE(64),L_TABLE(65),L_TABLE(66),L_TABLE
(67),L_TABLE(68),L_TABLE(69),L_TABLE(70),L_TABLE(71),L_TABLE(72),L_TABLE(73),L_TABLE(74),L_TABLE(75),L_TABLE(76),L_TABLE(77),L_TABLE
(78),L_TABLE(79),L_TABLE(80),L_TABLE(81),L_TABLE(82),L_TABLE(83),L_TABLE(84),L_TABLE(85),L_TABLE(86),L_TABLE(87),L_TABLE(88),L_TABLE
(89),L_TABLE(90),L_TABLE(91),L_TABLE(92),L_TABLE(93),L_TABLE(94),L_TABLE(95),L_TABLE(96),L_TABLE(97),L_TABLE(98),L_TABLE(99),L_TABLE
(100);

        FOR C IN 1..LEAST(G_SERVICE_COLUMN_MAPPINGS.COUNT,100) LOOP
            -- 1st check: NUMBER
            L_IS_NUMBER := NULL;
            FOR R IN 1..L_TABLE(C).COUNT LOOP
                BEGIN
                    L_NUMBER := TO_NUMBER(L_TABLE(C) (R) );
                    IF
                        L_NUMBER IS NOT NULL
                    THEN
                        L_IS_NUMBER := TRUE;
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        L_IS_NUMBER := FALSE;
                END;

                IF
                    NOT L_IS_NUMBER
                THEN
                    EXIT;
                END IF;
            END LOOP;
            -- 1st check: DATE

            IF
                NOT L_IS_NUMBER
            THEN
                FOR F IN 1..L_DATE_FORMATS.COUNT LOOP
                    L_IS_DATE := NULL;
                    FOR R IN 1..L_TABLE(C).COUNT LOOP
                        BEGIN
                            L_DATE := TO_DATE(L_TABLE(C) (R),L_DATE_FORMATS(F) );

                            IF
                                L_DATE IS NOT NULL
                            THEN
                                L_THE_FORMAT := L_DATE_FORMATS(F);
                                L_IS_DATE := TRUE;
                            END IF;

                        EXCEPTION
                            WHEN OTHERS THEN
                                L_IS_DATE := FALSE;
                                L_THE_FORMAT := NULL;
                        END;

                        IF
                            NOT L_IS_DATE
                        THEN
                            EXIT;
                        END IF;
                    END LOOP;

                    IF
                        L_IS_DATE OR L_IS_DATE IS NULL
                    THEN
                        EXIT;
                    END IF;
                END LOOP;
            END IF;

            IF
                L_IS_NUMBER
            THEN
                G_SERVICE_COLUMN_MAPPINGS(C).DATA_TYPE := 'NUMBER';
                G_SERVICE_COLUMN_MAPPINGS(C).DATA_TYPE_LEN := NULL;
                G_SERVICE_COLUMN_MAPPINGS(C).DATA_FORMAT_MASK := NULL;
            ELSIF L_IS_DATE THEN
                G_SERVICE_COLUMN_MAPPINGS(C).DATA_TYPE := 'DATE';
                G_SERVICE_COLUMN_MAPPINGS(C).DATA_TYPE_LEN := NULL;
                G_SERVICE_COLUMN_MAPPINGS(C).DATA_FORMAT_MASK := L_THE_FORMAT;
            ELSE
                G_SERVICE_COLUMN_MAPPINGS(C).DATA_TYPE := 'VARCHAR2';
                G_SERVICE_COLUMN_MAPPINGS(C).DATA_TYPE_LEN := 4000;
                G_SERVICE_COLUMN_MAPPINGS(C).DATA_FORMAT_MASK := NULL;
            END IF;

            UPDATE EBA_RESTDEMO_COLUMN_MAPPINGS
                SET
                    DATA_TYPE = G_SERVICE_COLUMN_MAPPINGS(C).DATA_TYPE,
                    DATA_TYPE_LEN = G_SERVICE_COLUMN_MAPPINGS(C).DATA_TYPE_LEN,
                    DATA_FORMAT_MASK = G_SERVICE_COLUMN_MAPPINGS(C).DATA_FORMAT_MASK
            WHERE
                ID = G_SERVICE_COLUMN_MAPPINGS(C).ID;

        END LOOP;

        LOAD(P_SERVICE_ID,TRUE);
    END SAMPLE_DATA_TYPES;

    PROCEDURE POPULATE_COLUMN_MAPPING (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE
    ) IS

        TYPE T_COLUMN_NAMES IS
            TABLE OF NUMBER INDEX BY VARCHAR2(30);
        L_DESCRIBED            BOOLEAN := FALSE;
        L_DESCR_XML            XMLTYPE;
        L_PK_COLUMN            VARCHAR2(255);
        L_HAS_DATATYPES        BOOLEAN := FALSE;
        L_PARSED_JSON          APEX_JSON.T_VALUES;
        L_COLUMN_MEMBERS       WWV_FLOW_T_VARCHAR2;
        L_JSON_VALUE           APEX_JSON.T_VALUE;
        L_COLUMN_NAMES         T_COLUMN_NAMES;
        L_COLUMN_NAME          VARCHAR2(30);
        L_COL_SEQ              NUMBER;

        PROCEDURE TRAVERSE_JSON (
            P_SELECTOR_PREFIX   IN VARCHAR2,
            P_COLUMN_MEMBERS    IN WWV_FLOW_T_VARCHAR2
        ) IS
            L_NEW_COLUMN_MEMBERS   WWV_FLOW_T_VARCHAR2;
        BEGIN
            IF
                P_COLUMN_MEMBERS IS NOT NULL
            THEN
                FOR I IN 1..P_COLUMN_MEMBERS.COUNT LOOP
                    L_JSON_VALUE := APEX_JSON.GET_VALUE(P_VALUES => L_PARSED_JSON,P_PATH =>
                        CASE
                            WHEN G_SERVICE_DATA.DATA_ROW_SELECTOR = '.' THEN NULL
                            ELSE G_SERVICE_DATA.DATA_ROW_SELECTOR
                        END
                    || '[%d].'
                    || P_SELECTOR_PREFIX
                    || P_COLUMN_MEMBERS(I),P0 => 1);

                    IF
                        L_JSON_VALUE.KIND IN (
                            1,
                            2,
                            3,
                            4,
                            5
                        )
                    THEN
                        L_COLUMN_NAME := REGEXP_REPLACE(SUBSTR(P_COLUMN_MEMBERS(I),1,27),'[^[:alnum:]_-]','_');

                        IF
                            ASCII(UPPER(SUBSTR(L_COLUMN_NAME,1,1) ) ) < 65 OR ASCII(UPPER(SUBSTR(L_COLUMN_NAME,1,1) ) ) > 90
                        THEN
                            L_COLUMN_NAME := 'C'
                            || L_COLUMN_NAME;
                        END IF;

                        IF
                            L_COLUMN_NAMES.EXISTS(L_COLUMN_NAME)
                        THEN
                            L_COLUMN_NAMES(L_COLUMN_NAME) := NVL(L_COLUMN_NAMES(L_COLUMN_NAME),0) + 1;
                            L_COLUMN_NAME := L_COLUMN_NAME
                            || '_'
                            || L_COLUMN_NAMES(L_COLUMN_NAME);
                        ELSE
                            L_COLUMN_NAMES(L_COLUMN_NAME) := 1;
                        END IF;

                        IF
                            UPPER(L_COLUMN_NAME) IN (
                                'ACCESS',
                                'ADD',
                                'ALL',
                                'ALTER',
                                'AND',
                                'ANY',
                                'AS',
                                'ASC',
                                'AUDIT',
                                'BETWEEN',
                                'BY',
                                'CHAR',
                                'CHECK',
                                'CLUSTER',
                                'COLUMN',
                                'COLUMN_VALUE',
                                'COMMENT',
                                'COMPRESS',
                                'CONNECT',
                                'CREATE',
                                'CURRENT',
                                'DATE',
                                'DECIMAL',
                                'DEFAULT',
                                'DELETE',
                                'DESC',
                                'DISTINCT',
                                'DROP',
                                'ELSE',
                                'EXCLUSIVE',
                                'EXISTS',
                                'FILE',
                                'FLOAT',
                                'FOR',
                                'FROM',
                                'GRANT',
                                'GROUP',
                                'HAVING',
                                'IDENTIFIED',
                                'IMMEDIATE',
                                'IN',
                                'INCREMENT',
                                'INDEX',
                                'INITIAL',
                                'INSERT',
                                'INTEGER',
                                'INTERSECT',
                                'INTO',
                                'IS',
                                'LEVEL',
                                'LIKE',
                                'LOCK',
                                'LONG',
                                'MAXEXTENTS',
                                'MINUS',
                                'MLSLABEL',
                                'MODE',
                                'MODIFY',
                                'NESTED_TABLE_ID',
                                'NOAUDIT',
                                'NOCOMPRESS',
                                'NOT',
                                'NOWAIT',
                                'NULL',
                                'NUMBER',
                                'OF',
                                'OFFLINE',
                                'ON',
                                'ONLINE',
                                'OPTION',
                                'OR',
                                'ORDER',
                                'PCTFREE',
                                'PRIOR',
                                'PUBLIC',
                                'RAW',
                                'RENAME',
                                'RESOURCE',
                                'REVOKE',
                                'ROW',
                                'ROWID',
                                'ROWNUM',
                                'ROWS',
                                'SELECT',
                                'SESSION',
                                'SET',
                                'SHARE',
                                'SIZE',
                                'SMALLINT',
                                'START',
                                'SUCCESSFUL',
                                'SYNONYM',
                                'SYSDATE',
                                'TABLE',
                                'THEN',
                                'TO',
                                'TRIGGER',
                                'UID',
                                'UNION',
                                'UNIQUE',
                                'UPDATE',
                                'USER',
                                'VALIDATE',
                                'VALUES',
                                'VARCHAR',
                                'VARCHAR2',
                                'VIEW',
                                'WHENEVER',
                                'WHERE',
                                'WITH'
                            )
                        THEN
                            L_COLUMN_NAME := L_COLUMN_NAME
                            || '_';
                        END IF;

                        INSERT INTO EBA_RESTDEMO_COLUMN_MAPPINGS (
                            SERVICE_ID,
                            COLUMN_SEQ,
                            COLUMN_NAME,
                            COLUMN_SELECTOR,
                            PRIMARY_KEY,
                            DATA_TYPE,
                            DATA_TYPE_LEN
                        ) VALUES (
                            P_SERVICE_ID,
                            L_COL_SEQ,
                            UPPER(L_COLUMN_NAME),
                            P_SELECTOR_PREFIX
                            || P_COLUMN_MEMBERS(I),
                            'N',
                            'VARCHAR2',
                            4000
                        );

                        L_COL_SEQ := L_COL_SEQ + 1;
                    ELSIF L_JSON_VALUE.KIND = 6 THEN
                        L_NEW_COLUMN_MEMBERS := APEX_JSON.GET_MEMBERS(P_VALUES => L_PARSED_JSON,P_PATH =>
                            CASE
                                WHEN G_SERVICE_DATA.DATA_ROW_SELECTOR = '.' THEN NULL
                                ELSE G_SERVICE_DATA.DATA_ROW_SELECTOR
                            END
                        || '[%d].'
                        || P_SELECTOR_PREFIX
                        || P_COLUMN_MEMBERS(I),P0 => 1);

                        TRAVERSE_JSON(P_SELECTOR_PREFIX
                        || P_COLUMN_MEMBERS(I)
                        || '.',L_NEW_COLUMN_MEMBERS);
                    END IF;

                END LOOP;

            END IF;
        END TRAVERSE_JSON;

    BEGIN
        LOAD(P_SERVICE_ID);
        DELETE FROM EBA_RESTDEMO_COLUMN_MAPPINGS WHERE
            SERVICE_ID = P_SERVICE_ID;
        -- pass I: parse and evaluate "describedby" link

        GRAB_DATA;
        IF
            G_SERVICE_DATA.RESPONSE_TYPE = 'XML'
        THEN
            EXECUTE IMMEDIATE '
               begin
                   for field in (
                       select rownum seq, tag
                       from xmltable(
                         ''//'
            ||
                CASE
                    WHEN G_SERVICE_DATA.DATA_ROW_SELECTOR = '.' THEN NULL
                    ELSE G_SERVICE_DATA.DATA_ROW_SELECTOR
                END
            || '[1]/*[not(*)]''
                         passing xmltype( eba_restdemo_helper.get_data_clob( :p_service_id ) )
                         columns tag varchar2(30) path ''local-name()''
                       )
                   ) loop
                       insert into eba_restdemo_column_mappings (
                           service_id,
                           column_seq,
                           column_name,
                           column_selector,
                           primary_key,
                           data_type,
                           data_type_len
                       ) values (
                           :p_service_id,
                           field.seq,
                           upper(field.tag),
                           field.tag,
                           ''N'',
                           ''VARCHAR2'',
                           4000
                       );
                   end loop;
               end;'
                USING P_SERVICE_ID;
        ELSIF G_SERVICE_DATA.RESPONSE_TYPE = 'JSON' THEN
            IF
                G_ORDS_DESCRLINK IS NOT NULL
            THEN
                L_DESCR_XML := APEX_JSON.TO_XMLTYPE(EBA_RESTDEMO_HELPER.GET_DATA_CLOB(P_SERVICE_ID,G_ORDS_DESCRLINK) );
                FOR FIELD IN (
                    SELECT
                        ROWNUM SEQ,
                        COL_NAME,
                        CASE
                                WHEN COL_TYPE IN (
                                    'VARCHAR2',
                                    'NUMBER',
                                    'DATE'
                                ) THEN COL_TYPE
                                ELSE 'VARCHAR2'
                            END
                        AS COL_TYPE
                    FROM
                        XMLTABLE ( '/json/members/row' PASSING L_DESCR_XML COLUMNS COL_NAME VARCHAR2(30) PATH 'name/text()',COL_TYPE VARCHAR2(30) PATH 'type/text()' )
                ) LOOP
                    INSERT INTO EBA_RESTDEMO_COLUMN_MAPPINGS (
                        SERVICE_ID,
                        COLUMN_SEQ,
                        COLUMN_NAME,
                        COLUMN_SELECTOR,
                        PRIMARY_KEY,
                        DATA_FORMAT_MASK,
                        DATA_TYPE,
                        DATA_TYPE_LEN
                    ) VALUES (
                        P_SERVICE_ID,
                        FIELD.SEQ,
                        UPPER(FIELD.COL_NAME),
                        FIELD.COL_NAME,
                        'N',
                            CASE
                                WHEN FIELD.COL_TYPE = 'DATE' THEN 'YYYY-MM-DD"T"HH24:MI:SS"Z"'
                                ELSE NULL
                            END,
                        FIELD.COL_TYPE,
                            CASE
                                WHEN FIELD.COL_TYPE = 'VARCHAR2' THEN 4000
                                ELSE NULL
                            END
                    );

                END LOOP;

                BEGIN
                    SELECT
                        PK_COLUMN
                    INTO
                        L_PK_COLUMN
                    FROM
                        XMLTABLE ( '/json/primarykey/row[1]' PASSING L_DESCR_XML COLUMNS PK_COLUMN VARCHAR2(255) PATH 'text()' );

                    UPDATE EBA_RESTDEMO_COLUMN_MAPPINGS
                        SET
                            PRIMARY_KEY = 'Y'
                    WHERE
                        SERVICE_ID = P_SERVICE_ID
                        AND   COLUMN_NAME = UPPER(L_PK_COLUMN);

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                END;

                L_DESCRIBED := TRUE;
                L_HAS_DATATYPES := TRUE;
            END IF;
            -- pass II: check which row attributes actually exist in the first row

            IF
                NOT L_DESCRIBED
            THEN
                APEX_JSON.PARSE(P_VALUES => L_PARSED_JSON,P_SOURCE => EBA_RESTDEMO_HELPER.GET_DATA_CLOB(P_SERVICE_ID) );

                L_COLUMN_MEMBERS := APEX_JSON.GET_MEMBERS(P_VALUES => L_PARSED_JSON,P_PATH => CASE
                    WHEN G_SERVICE_DATA.DATA_ROW_SELECTOR = '.' THEN NULL
                    ELSE G_SERVICE_DATA.DATA_ROW_SELECTOR
                END
                || '[%d]',P0 => 1);

                L_COL_SEQ := 1;
                TRAVERSE_JSON(NULL,L_COLUMN_MEMBERS);
            END IF;

        END IF;

        IF
            NOT L_HAS_DATATYPES
        THEN
            SAMPLE_DATA_TYPES(P_SERVICE_ID);
        END IF;
    END POPULATE_COLUMN_MAPPING;

    FUNCTION HAS_COLUMN_MAPPINGS (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE
    ) RETURN BOOLEAN
        IS
    BEGIN
        LOAD(P_SERVICE_ID);
        RETURN(G_SERVICE_COLUMN_MAPPINGS.COUNT >= 1);
    END HAS_COLUMN_MAPPINGS;
    -----------------------------------------------------------------------------------------------------
    --
    -- SQL Generation functions
    --
    --

    FUNCTION GET_PK_VALUE (
        P_COLLECTION_NAME IN VARCHAR2
    ) RETURN VARCHAR2 IS
        L_PK_VALUE   VARCHAR2(500);
    BEGIN
        SELECT
            C003
        INTO
            L_PK_VALUE
        FROM
            APEX_COLLECTIONS
        WHERE
            COLLECTION_NAME = P_COLLECTION_NAME
            AND   UPPER(C005) IN (
                'Y',
                'YES'
            )
            AND   ROWNUM = 1;

        RETURN L_PK_VALUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000,'No PK value exists in collection');
    END GET_PK_VALUE;

    FUNCTION GENERATE_JSON_BODY (
        P_COLLECTION_NAME IN VARCHAR2
    ) RETURN VARCHAR2 IS
        L_JSON   VARCHAR2(32767);
    BEGIN
        L_JSON := '{';
        FOR I IN (
            SELECT
                LOWER(C001) COLUMN_NAME,
                C002 DATA_TYPE,
                C003 DATA_VALUE,
                C004 FORMAT_MASK
            FROM
                APEX_COLLECTIONS
            WHERE
                COLLECTION_NAME = P_COLLECTION_NAME
        ) LOOP
            IF
                I.DATA_TYPE = 'VARCHAR2'
            THEN
                L_JSON := L_JSON
                || APEX_JAVASCRIPT.ADD_ATTRIBUTE(I.COLUMN_NAME,I.DATA_VALUE);

            ELSIF I.DATA_TYPE = 'NUMBER' THEN
                L_JSON := L_JSON
                || APEX_JAVASCRIPT.ADD_ATTRIBUTE(I.COLUMN_NAME,TO_NUMBER(I.DATA_VALUE) );
            ELSE
                L_JSON := L_JSON
                || APEX_JAVASCRIPT.ADD_ATTRIBUTE(I.COLUMN_NAME,TO_CHAR(TO_DATE(I.DATA_VALUE,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD"T"HH24:MI:SS"Z"')
);
            END IF;
        END LOOP;

        L_JSON := RTRIM(L_JSON,',');
        L_JSON := L_JSON
        || '}';
        RETURN L_JSON;
    END GENERATE_JSON_BODY;

    FUNCTION GENERATE_PLSQL_FOR_HTTPHEADERS (
        P_SERVICE_ID    IN EBA_RESTDEMO_SERVICES.ID%TYPE DEFAULT NULL,
        P_HTTP_METHOD   IN VARCHAR2
    ) RETURN VARCHAR2 IS
        L_PLSQL           VARCHAR2(32767);
        L_USERAGENT_SET   BOOLEAN := FALSE;
        L_HDR_IDX         PLS_INTEGER := 1;
    BEGIN
        L_PLSQL := C_INDENT
        || '-- Set HTTP Request Headers'
        || LF
        || C_INDENT
        || 'apex_web_service.g_request_headers.delete;'
        || LF
        || LF;

        FOR H IN (
            SELECT
                ROWNUM AS SEQ,
                INITCAP(HEADER_NAME) AS HEADER_NAME,
                HEADER_VALUE
            FROM
                EBA_RESTDEMO_HTTP_HEADERS
            WHERE
                SERVICE_ID = P_SERVICE_ID
                AND   INSTR(HEADER_FOR,P_HTTP_METHOD) != 0
                AND   HEADER_ACTIVE = 'Y'
            ORDER BY
                HEADER_SEQ
        ) LOOP
            L_PLSQL := L_PLSQL
            || C_INDENT
            || 'apex_web_service.g_request_headers('
            || L_HDR_IDX
            || ').name  := q''#'
            || H.HEADER_NAME
            || '#'';'
            || LF;

            L_PLSQL := L_PLSQL
            || C_INDENT
            || 'apex_web_service.g_request_headers('
            || L_HDR_IDX
            || ').value := q''#'
            || H.HEADER_VALUE
            || '#'';'
            || LF;

            L_HDR_IDX := L_HDR_IDX + 1;
            IF
                LOWER(H.HEADER_NAME) = 'user-agent'
            THEN
                L_USERAGENT_SET := TRUE;
            END IF;
        END LOOP;

        IF
            NOT L_USERAGENT_SET
        THEN
            L_PLSQL := L_PLSQL
            || C_INDENT
            || 'apex_web_service.g_request_headers('
            || L_HDR_IDX
            || ').name  := q''#User-Agent#'';'
            || LF;

            L_PLSQL := L_PLSQL
            || C_INDENT
            || 'apex_web_service.g_request_headers('
            || L_HDR_IDX
            || ').value := q''#Oracle Application Express / REST Client Assistant#'';'
            || LF;

        END IF;

        RETURN L_PLSQL
        || LF;
    END GENERATE_PLSQL_FOR_HTTPHEADERS;

    FUNCTION GENERATE_OAUTH_CODE RETURN VARCHAR2
        IS
    BEGIN
        IF
            G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2'
        THEN
            RETURN C_INDENT
            || '-- Perform Authentication with OAuth Client Credentials'
            || LF
            || C_INDENT
            || 'apex_web_service.oauth_authenticate( '
            || LF
            || C_INDENT
            || C_INDENT
            || 'p_token_url     => '''
            || G_SERVICE_DATA.OAUTH_TOKEN_URL
            || ''','
            || LF
            || C_INDENT
            || C_INDENT
            || 'p_client_id     => '''
            || G_SERVICE_DATA.OAUTH_CLIENTID
            || ''','
            || LF
            || C_INDENT
            || C_INDENT
            || 'p_client_secret => ''{OAuth2 Client Secret}'');'
            || LF;

        ELSE
            RETURN NULL;
        END IF;
    END GENERATE_OAUTH_CODE;

    FUNCTION GENERATE_MAKE_REST_REQUEST (
        P_ENDPOINT_OVERRIDE    IN VARCHAR2 DEFAULT NULL,
        P_DYNAMIC_PAGINATION   IN BOOLEAN DEFAULT FALSE
    ) RETURN VARCHAR2 IS
        L_PLSQL   VARCHAR2(32767);
    BEGIN
        L_PLSQL := C_INDENT
        || '-- load REST response into a collection'
        || LF;
        IF
            G_SERVICE_DATA.RESPONSE_CHARSET IS NULL OR LOWER(G_SERVICE_DATA.RESPONSE_CHARSET) = LOWER(G_DB_CHARSET)
        THEN
            L_PLSQL := L_PLSQL
            || C_INDENT
            || 'l_response := apex_web_service.make_rest_request('
            || LF;
        ELSE
            L_PLSQL := L_PLSQL
            || C_INDENT
            || 'l_response_blob := apex_web_service.make_rest_request_b('
            || LF;
        END IF;

        IF
            P_DYNAMIC_PAGINATION
        THEN
            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || 'p_url              => case '
            || LF
            || C_INDENT
            || C_INDENT
            || '                          -- TODO: replace with your page item names here'
            || LF
            || C_INDENT
            || C_INDENT
            || '                          when :{APEX_ITEM_SHOW_PAGE} = ''next'' and :{APEX_ITEM_URL_NEXT_PAGE} is not null then :{APEX_ITEM_URL_NEXT_PAGE}'
            || LF
            || C_INDENT
            || C_INDENT
            || '                          when :{APEX_ITEM_SHOW_PAGE} = ''prev'' and :{APEX_ITEM_URL_PREV_PAGE} is not null then :{APEX_ITEM_URL_PREV_PAGE}'
            || LF
            || C_INDENT
            || C_INDENT
            || '                          else '
            ||
                CASE
                    WHEN P_ENDPOINT_OVERRIDE IS NOT NULL THEN ''''
                    || P_ENDPOINT_OVERRIDE
                    || ''''
                    ELSE PREPARE_URL(G_SERVICE_DATA.ENDPOINT,'GET',TRUE)
                END
            || LF
            || C_INDENT
            || C_INDENT
            || '                      end,'
            || LF;
        ELSE
            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || 'p_url              => '
            ||
                CASE
                    WHEN P_ENDPOINT_OVERRIDE IS NOT NULL THEN ''''
                    || P_ENDPOINT_OVERRIDE
                    || ''''
                    ELSE PREPARE_URL(G_SERVICE_DATA.ENDPOINT,'GET',TRUE)
                END
            || ','
            || LF;
        END IF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || 'p_http_method      => ''GET''';
        IF
            G_SERVICE_DATA.AUTH_TYPE = 'BASIC'
        THEN
            L_PLSQL := L_PLSQL
            || ','
            || LF
            || C_INDENT
            || C_INDENT
            || 'p_username         => '''
            || G_SERVICE_DATA.AUTH_BASIC_USERNAME
            || ''','
            || LF
            || C_INDENT
            || C_INDENT
            || 'p_password         => ''{Password}'','
            || LF
            || C_INDENT
            || C_INDENT
            || 'p_scheme           => ''Basic'' );';
        ELSIF G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2' THEN
            L_PLSQL := L_PLSQL
            || ','
            || LF
            || C_INDENT
            || C_INDENT
            || 'p_scheme           => ''OAUTH_CLIENT_CRED'' );';
        ELSE
            L_PLSQL := L_PLSQL
            || ');';
        END IF;

        IF
            NOT ( G_SERVICE_DATA.RESPONSE_CHARSET IS NULL OR LOWER(G_SERVICE_DATA.RESPONSE_CHARSET) = LOWER(G_DB_CHARSET) )
        THEN
            L_PLSQL := L_PLSQL
            || LF
            || LF
            || C_INDENT
            || '-- convert encoding of the REST response data to database characterset'
            || LF
            || C_INDENT
            || 'declare'
            || LF
            || C_INDENT
            || C_INDENT
            || 'l_srcoff number := 1;'
            || LF
            || C_INDENT
            || C_INDENT
            || 'l_dstoff number := 1;'
            || LF
            || C_INDENT
            || C_INDENT
            || 'l_lngctx number := 0;'
            || LF
            || C_INDENT
            || C_INDENT
            || 'l_warn   number;'
            || LF
            || C_INDENT
            || 'begin'
            || LF
            || C_INDENT
            || C_INDENT
            || 'sys.dbms_lob.createtemporary( l_response, true, dbms_lob.call );'
            || LF
            || C_INDENT
            || C_INDENT
            || 'sys.dbms_lob.converttoclob('
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'dest_lob     => l_response,'
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'src_blob     => l_response_blob,'
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'amount       => sys.dbms_lob.lobmaxsize,'
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'dest_offset  => l_dstoff,'
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'src_offset   => l_srcoff,'
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'blob_csid    => nls_charset_id( '''
            || G_SERVICE_DATA.RESPONSE_CHARSET
            || '''),'
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'lang_context => l_lngctx,'
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'warning      => l_warn'
            || LF
            || C_INDENT
            || C_INDENT
            || ');'
            || LF
            || C_INDENT
            || C_INDENT
            || 'sys.dbms_lob.freetemporary( l_response_blob );'
            || LF
            || C_INDENT
            || 'end;';
        END IF;

        L_PLSQL := L_PLSQL
        || LF
        || LF;
        L_PLSQL := L_PLSQL
        || C_INDENT
        || 'apex_collection.create_or_truncate_collection( ''REST_COLLECTION'' );'
        || LF
        || C_INDENT
        || 'apex_collection.add_member('
        || LF
        || C_INDENT
        || C_INDENT
        || 'p_collection_name => ''REST_COLLECTION'','
        || LF
        || C_INDENT
        || C_INDENT
        || 'p_clob001 =>         l_response );'
        || LF;

        RETURN L_PLSQL;
    END GENERATE_MAKE_REST_REQUEST;

    FUNCTION GET_SQL_QUERY_JSON (
        P_GENERATE            IN VARCHAR2 DEFAULT NULL,
        P_ENDPOINT_OVERRIDE   IN VARCHAR2 DEFAULT NULL,
        P_MAX_COLUMNS         IN NUMBER DEFAULT NULL
    ) RETURN VARCHAR2 IS
        L_SQL               VARCHAR2(32767);
        L_MAX_COLNAME_LEN   NUMBER := 0;
        L_COL_CNT           NUMBER;
    BEGIN
        L_COL_CNT :=
            CASE
                WHEN P_GENERATE IS NOT NULL OR P_MAX_COLUMNS IS NULL THEN G_SERVICE_COLUMN_MAPPINGS.COUNT
                ELSE LEAST(G_SERVICE_COLUMN_MAPPINGS.COUNT,P_MAX_COLUMNS)
            END;

        L_SQL := 'select '
        || LF;
        FOR I IN 1..L_COL_CNT LOOP
            IF
                LENGTH(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME) > L_MAX_COLNAME_LEN
            THEN
                L_MAX_COLNAME_LEN := LENGTH(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME);
            END IF;

            L_SQL := L_SQL
            || C_INDENT;
            IF
                G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'DATE'
            THEN
                L_SQL := L_SQL
                || 'to_date( '
                || 'j."'
                || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
                || '"';

                IF
                    G_SERVICE_COLUMN_MAPPINGS(I).DATA_FORMAT_MASK IS NOT NULL
                THEN
                    L_SQL := L_SQL
                    || ', '
                    || SYS.DBMS_ASSERT.ENQUOTE_LITERAL(G_SERVICE_COLUMN_MAPPINGS(I).DATA_FORMAT_MASK);

                END IF;

                L_SQL := L_SQL
                || ' ) as "'
                || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
                || '"';

            ELSE
                L_SQL := L_SQL
                || 'j."'
                || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
                || '"';
            END IF;

            IF
                I < L_COL_CNT
            THEN
                L_SQL := L_SQL
                || ', ';
            END IF;
            L_SQL := L_SQL
            || LF;
        END LOOP;

        L_SQL := L_SQL
        || 'from '
        ||
            CASE
                WHEN P_GENERATE = 'QUERY' THEN 'apex_collections c, '
            END
        || 'json_table('
        || LF;

        L_SQL := L_SQL
        || C_INDENT
        ||
            CASE
                WHEN P_GENERATE = 'QUERY' THEN 'c.clob001'
                WHEN P_GENERATE = 'LOAD' THEN 'l_response'
                ELSE 'eba_restdemo_helper.get_data_clob '
            END
        || ' format json,'
        || LF;

        L_SQL := L_SQL
        || C_INDENT
        || SYS.DBMS_ASSERT.ENQUOTE_LITERAL('$'
        ||
            CASE
                WHEN G_SERVICE_DATA.DATA_ROW_SELECTOR = '.' THEN NULL
                ELSE '.'
                || G_SERVICE_DATA.DATA_ROW_SELECTOR
            END
        || '[*]')
        || LF;

        L_SQL := L_SQL
        || C_INDENT
        || 'columns ('
        || LF;
        FOR I IN 1..L_COL_CNT LOOP
            L_SQL := L_SQL
            || C_INDENT
            || C_INDENT
            || RPAD('"'
            || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
            || '"',L_MAX_COLNAME_LEN + 4)
            || ' ';

            IF
                G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'VARCHAR2'
            THEN
                L_SQL := L_SQL
                || G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE;
                L_SQL := L_SQL
                || RPAD('('
                || G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE_LEN
                || ')',7);

            ELSIF G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'DATE' THEN
                L_SQL := L_SQL
                || 'VARCHAR2(4000) ';
            ELSIF G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'NUMBER' THEN
                L_SQL := L_SQL
                || G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE
                || '         ';
            END IF;

            L_SQL := L_SQL
            || ' path '
            || SYS.DBMS_ASSERT.ENQUOTE_LITERAL('$.'
            || REPLACE(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_SELECTOR,'$','\u0024') );

            IF
                I < L_COL_CNT
            THEN
                L_SQL := L_SQL
                || ',';
            END IF;
            L_SQL := L_SQL
            || LF;
        END LOOP;

        L_SQL := L_SQL
        || C_INDENT
        || ')'
        || LF
        || ') j';
        IF
            P_GENERATE = 'QUERY'
        THEN
            L_SQL := L_SQL
            || LF
            || 'where c.collection_name = ''REST_COLLECTION''';
        END IF;

        RETURN L_SQL;
    END GET_SQL_QUERY_JSON;

    FUNCTION GET_SQL_QUERY_JSON_11G (
        P_GENERATE            IN VARCHAR2 DEFAULT NULL,
        P_ENDPOINT_OVERRIDE   IN VARCHAR2 DEFAULT NULL,
        P_MAX_COLUMNS         IN NUMBER DEFAULT NULL
    ) RETURN VARCHAR2 IS
        L_SQL               VARCHAR2(32767);
        L_MAX_COLNAME_LEN   NUMBER := 0;
        L_COL_CNT           NUMBER;
    BEGIN
        L_COL_CNT :=
            CASE
                WHEN P_GENERATE IS NOT NULL OR P_MAX_COLUMNS IS NULL THEN G_SERVICE_COLUMN_MAPPINGS.COUNT
                ELSE LEAST(G_SERVICE_COLUMN_MAPPINGS.COUNT,P_MAX_COLUMNS)
            END;

        L_SQL := 'select '
        || LF;
        FOR I IN 1..L_COL_CNT LOOP
            IF
                LENGTH(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME) > L_MAX_COLNAME_LEN
            THEN
                L_MAX_COLNAME_LEN := LENGTH(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME);
            END IF;

            L_SQL := L_SQL
            || C_INDENT;
            IF
                G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'DATE'
            THEN
                L_SQL := L_SQL
                || 'to_date( x."'
                || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
                || '"';

                IF
                    G_SERVICE_COLUMN_MAPPINGS(I).DATA_FORMAT_MASK IS NOT NULL
                THEN
                    L_SQL := L_SQL
                    || ', '
                    || SYS.DBMS_ASSERT.ENQUOTE_LITERAL(G_SERVICE_COLUMN_MAPPINGS(I).DATA_FORMAT_MASK);

                END IF;

                L_SQL := L_SQL
                || ' ) as "'
                || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
                || '"';

            ELSE
                L_SQL := L_SQL
                || 'x."'
                || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
                || '"';
            END IF;

            IF
                I < L_COL_CNT
            THEN
                L_SQL := L_SQL
                || ', ';
            END IF;
            L_SQL := L_SQL
            || LF;
        END LOOP;

        L_SQL := L_SQL
        || 'from '
        ||
            CASE
                WHEN P_GENERATE = 'QUERY' THEN 'apex_collections c, '
            END
        || 'xmltable('
        || LF;

        L_SQL := L_SQL
        || C_INDENT
        || '''/json/'
        || REPLACE(
            CASE
                WHEN G_SERVICE_DATA.DATA_ROW_SELECTOR = '.' THEN NULL
                ELSE G_SERVICE_DATA.DATA_ROW_SELECTOR
            END,'.','/')
        || '/row'''
        || LF;

        L_SQL := L_SQL
        || C_INDENT
        || 'passing apex_json.to_xmltype( '
        ||
            CASE
                WHEN P_GENERATE = 'QUERY' THEN 'c.clob001'
                WHEN P_GENERATE = 'LOAD' THEN 'l_response'
                ELSE 'eba_restdemo_helper.get_data_clob '
            END
        || ' )'
        || LF;

        L_SQL := L_SQL
        || C_INDENT
        || 'columns'
        || LF;
        FOR I IN 1..L_COL_CNT LOOP
            L_SQL := L_SQL
            || C_INDENT
            || C_INDENT
            || RPAD('"'
            || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
            || '"',L_MAX_COLNAME_LEN + 4)
            || ' ';

            IF
                G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'VARCHAR2'
            THEN
                L_SQL := L_SQL
                || G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE;
                L_SQL := L_SQL
                || RPAD('('
                || NVL(G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE_LEN,4000)
                || ')',7);

            ELSIF G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'DATE' THEN
                L_SQL := L_SQL
                || 'VARCHAR2(4000) ';
            ELSIF G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'NUMBER' THEN
                L_SQL := L_SQL
                || G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE
                || '         ';
            END IF;

            L_SQL := L_SQL
            || ' path '
            || SYS.DBMS_ASSERT.ENQUOTE_LITERAL(PATH_JSON_TO_XML(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_SELECTOR) );

            IF
                I < L_COL_CNT
            THEN
                L_SQL := L_SQL
                || ',';
            END IF;
            L_SQL := L_SQL
            || LF;
        END LOOP;

        L_SQL := L_SQL
        || ') x';
        IF
            P_GENERATE = 'QUERY'
        THEN
            L_SQL := L_SQL
            || LF
            || 'where c.collection_name = ''REST_COLLECTION''';
        END IF;

        RETURN L_SQL;
    END GET_SQL_QUERY_JSON_11G;

    FUNCTION GET_SQL_QUERY_XML (
        P_GENERATE            IN VARCHAR2 DEFAULT NULL,
        P_ENDPOINT_OVERRIDE   IN VARCHAR2 DEFAULT NULL,
        P_MAX_COLUMNS         IN NUMBER DEFAULT NULL
    ) RETURN VARCHAR2 IS
        L_SQL               VARCHAR2(32767);
        L_MAX_COLNAME_LEN   NUMBER := 0;
        L_COL_CNT           NUMBER;
    BEGIN
        L_COL_CNT :=
            CASE
                WHEN P_GENERATE IS NOT NULL OR P_MAX_COLUMNS IS NULL THEN G_SERVICE_COLUMN_MAPPINGS.COUNT
                ELSE LEAST(G_SERVICE_COLUMN_MAPPINGS.COUNT,P_MAX_COLUMNS)
            END;

        L_SQL := 'select'
        || LF;
        FOR I IN 1..L_COL_CNT LOOP
            IF
                LENGTH(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME) > L_MAX_COLNAME_LEN
            THEN
                L_MAX_COLNAME_LEN := LENGTH(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME);
            END IF;

            IF
                G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'DATE'
            THEN
                L_SQL := L_SQL
                || C_INDENT
                || 'to_date( x."'
                || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
                || '"';

                IF
                    G_SERVICE_COLUMN_MAPPINGS(I).DATA_FORMAT_MASK IS NOT NULL
                THEN
                    L_SQL := L_SQL
                    || ', '
                    || SYS.DBMS_ASSERT.ENQUOTE_LITERAL(G_SERVICE_COLUMN_MAPPINGS(I).DATA_FORMAT_MASK);

                END IF;

                L_SQL := L_SQL
                || ' ) as "'
                || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
                || '"';

            ELSE
                L_SQL := L_SQL
                || C_INDENT
                || 'x."'
                || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
                || '"';
            END IF;

            IF
                I < L_COL_CNT
            THEN
                L_SQL := L_SQL
                || ', '
                || LF;
            END IF;

        END LOOP;

        L_SQL := L_SQL
        || LF
        || 'from '
        ||
            CASE
                WHEN P_GENERATE = 'QUERY' THEN 'apex_collections c, '
            END
        || 'xmltable('
        || LF;

        L_SQL := L_SQL
        || C_INDENT
        || SYS.DBMS_ASSERT.ENQUOTE_LITERAL('//'
        || CASE
            WHEN G_SERVICE_DATA.DATA_ROW_SELECTOR = '.' THEN NULL
            ELSE G_SERVICE_DATA.DATA_ROW_SELECTOR
        END)
        || LF;

        L_SQL := L_SQL
        || C_INDENT
        || 'passing xmltype( '
        ||
            CASE
                WHEN P_GENERATE = 'QUERY' THEN 'c.clob001'
                WHEN P_GENERATE = 'LOAD' THEN 'l_response'
                ELSE 'eba_restdemo_helper.get_data_clob '
            END
        || ' )'
        || LF;

        L_SQL := L_SQL
        || C_INDENT
        || 'columns '
        || LF;
        FOR I IN 1..L_COL_CNT LOOP
            L_SQL := L_SQL
            || C_INDENT
            || C_INDENT
            || '"'
            || RPAD(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
            || '"',L_MAX_COLNAME_LEN + 4);

            IF
                G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'VARCHAR2'
            THEN
                L_SQL := L_SQL
                || 'VARCHAR2'
                || RPAD('('
                || NVL(G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE_LEN,4000)
                || ')',7);

            ELSIF G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'DATE' THEN
                L_SQL := L_SQL
                || 'VARCHAR2(4000) ';
            ELSIF G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'NUMBER' THEN
                L_SQL := L_SQL
                || 'NUMBER         ';
                NULL;
            END IF;

            L_SQL := L_SQL
            || ' path '
            || SYS.DBMS_ASSERT.ENQUOTE_LITERAL(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_SELECTOR);

            IF
                I < L_COL_CNT
            THEN
                L_SQL := L_SQL
                || ','
                || LF;
            END IF;

        END LOOP;

        L_SQL := L_SQL
        || LF
        || ') x';
        IF
            P_GENERATE = 'QUERY'
        THEN
            L_SQL := L_SQL
            || LF
            || 'where c.collection_name = ''REST_COLLECTION''';
        END IF;

        RETURN L_SQL;
    END GET_SQL_QUERY_XML;

    FUNCTION GET_SQL_QUERY (
        P_MAX_COLUMNS IN NUMBER DEFAULT 50
    ) RETURN VARCHAR2
        IS
    BEGIN
        IF
            G_SERVICE_DATA.RESPONSE_TYPE = 'XML'
        THEN
            RETURN GET_SQL_QUERY_XML(P_MAX_COLUMNS => P_MAX_COLUMNS);
        ELSE
            IF
                EBA_RESTDEMO_JSON_12C
            THEN
                RETURN GET_SQL_QUERY_JSON(P_MAX_COLUMNS => P_MAX_COLUMNS);
            ELSE
                RETURN GET_SQL_QUERY_JSON_11G(P_MAX_COLUMNS => P_MAX_COLUMNS);
            END IF;
        END IF;
    END GET_SQL_QUERY;

    FUNCTION GENERATE_ONLOAD_PLSQL (
        P_SERVICE_ID          IN EBA_RESTDEMO_SERVICES.ID%TYPE DEFAULT NULL,
        P_ENDPOINT_OVERRIDE   IN VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 IS
        L_SQL   VARCHAR2(32767) := '';
    BEGIN
        LOAD(P_SERVICE_ID);
        L_SQL := L_SQL
        || 'declare'
        || LF
        || C_INDENT
        || 'l_response      clob;'
        || LF;

        IF
            NOT ( G_SERVICE_DATA.RESPONSE_CHARSET IS NULL OR LOWER(G_SERVICE_DATA.RESPONSE_CHARSET) = LOWER(G_DB_CHARSET) )
        THEN
            L_SQL := L_SQL
            || C_INDENT
            || 'l_response_blob blob;'
            || LF;
        END IF;

        L_SQL := L_SQL
        || 'begin'
        || LF;
        L_SQL := L_SQL
        || GENERATE_PLSQL_FOR_HTTPHEADERS(P_SERVICE_ID,'GET');
        L_SQL := L_SQL
        || GENERATE_OAUTH_CODE;
        L_SQL := L_SQL
        || GENERATE_MAKE_REST_REQUEST;
        L_SQL := L_SQL
        || 'end;';
        RETURN L_SQL;
    END GENERATE_ONLOAD_PLSQL;

    FUNCTION GENERATE_SQL_CODE (
        P_SERVICE_ID          IN EBA_RESTDEMO_SERVICES.ID%TYPE DEFAULT NULL,
        P_ENDPOINT_OVERRIDE   IN VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 IS
        L_SQL   VARCHAR2(32767) := '';
    BEGIN
        LOAD(P_SERVICE_ID);
        IF
            G_SERVICE_DATA.RESPONSE_TYPE = 'XML'
        THEN
            L_SQL := L_SQL
            || GET_SQL_QUERY_XML(P_GENERATE => 'QUERY',P_ENDPOINT_OVERRIDE => P_ENDPOINT_OVERRIDE);

        ELSE
            IF
                EBA_RESTDEMO_JSON_12C
            THEN
                L_SQL := L_SQL
                || GET_SQL_QUERY_JSON(P_GENERATE => 'QUERY',P_ENDPOINT_OVERRIDE => P_ENDPOINT_OVERRIDE);

            ELSE
                L_SQL := L_SQL
                || GET_SQL_QUERY_JSON_11G(P_GENERATE => 'QUERY',P_ENDPOINT_OVERRIDE => P_ENDPOINT_OVERRIDE);
            END IF;
        END IF;

        RETURN L_SQL;
    END GENERATE_SQL_CODE;

    FUNCTION GENERATE_DML_CODE (
        P_SERVICE_ID        IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_METHOD            IN VARCHAR2,
        P_COLLECTION_NAME   IN VARCHAR2
    ) RETURN VARCHAR2 IS
        L_PLSQL   VARCHAR2(32767);
    BEGIN
        LOAD(P_SERVICE_ID);
        L_PLSQL := L_PLSQL
        || '-- PL/SQL code to perform DML on REST service'
        || LF;
        L_PLSQL := L_PLSQL
        || 'declare'
        || LF;
        L_PLSQL := L_PLSQL
        || C_INDENT
        || 'l_response clob;'
        || LF;
        L_PLSQL := L_PLSQL
        || 'begin'
        || LF;
        L_PLSQL := L_PLSQL
        || GENERATE_PLSQL_FOR_HTTPHEADERS(P_SERVICE_ID,P_METHOD);
        L_PLSQL := L_PLSQL
        || GENERATE_OAUTH_CODE;
        IF
            P_METHOD IN (
                'POST',
                'PUT'
            )
        THEN
            L_PLSQL := L_PLSQL
            || C_INDENT
            || '-- construct JSON object to pass to the server; replace literal values '
            || LF
            || C_INDENT
            || '-- with page items.'
            || LF
            || LF;

            L_PLSQL := L_PLSQL
            || C_INDENT
            || 'apex_json.initialize_clob_output(DBMS_LOB.CALL, true, 2);'
            || LF
            || C_INDENT
            || 'apex_json.open_object;'
            || LF;

            FOR I IN (
                SELECT
                    LOWER(C001) COLUMN_NAME,
                    C002 DATA_TYPE,
                    C003 DATA_VALUE,
                    C004 FORMAT_MASK
                FROM
                    APEX_COLLECTIONS
                WHERE
                    COLLECTION_NAME = P_COLLECTION_NAME
            ) LOOP
                L_PLSQL := L_PLSQL
                || C_INDENT
                || 'apex_json.write( '''
                || I.COLUMN_NAME
                || ''', ';

                IF
                    I.DATA_TYPE = 'VARCHAR2'
                THEN
                    L_PLSQL := L_PLSQL
                    || ''''
                    || REPLACE(I.DATA_VALUE,'''','''''')
                    || '''';

                ELSIF I.DATA_TYPE = 'NUMBER' THEN
                    L_PLSQL := L_PLSQL
                    || 'to_number( '''
                    || I.DATA_VALUE
                    || ''')';
                ELSE
                    L_PLSQL := L_PLSQL
                    || 'to_date( '''
                    || TO_CHAR(TO_DATE(I.DATA_VALUE,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                    || ''', ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')';
                END IF;

                L_PLSQL := L_PLSQL
                || ');'
                || LF;
            END LOOP;

            L_PLSQL := L_PLSQL
            || C_INDENT
            || 'apex_json.close_object;'
            || LF
            || LF;
        END IF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || 'l_response := apex_web_service.make_rest_request('
        || LF
        || C_INDENT
        || C_INDENT
        || 'p_url         => '
        ||
            CASE
                WHEN P_METHOD = 'POST' THEN PREPARE_URL(G_SERVICE_DATA.ENDPOINT,'POST',TRUE)
                ELSE PREPARE_URL(RTRIM(G_SERVICE_DATA.ENDPOINT,'/')
                || '/'
                || GET_PK_VALUE(P_COLLECTION_NAME),P_METHOD,TRUE)
            END
        || ','
        || LF
        || C_INDENT
        || C_INDENT
        || 'p_http_method => '''
        || P_METHOD
        || ''','
        || LF;

        IF
            G_SERVICE_DATA.AUTH_TYPE = 'BASIC'
        THEN
            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || 'p_username         => '''
            || G_SERVICE_DATA.AUTH_BASIC_USERNAME
            || ''','
            || LF
            || C_INDENT
            || C_INDENT
            || 'p_password         => ''{Password}'','
            || LF
            || C_INDENT
            || C_INDENT
            || 'p_scheme           => ''Basic'','
            || LF;
        ELSIF G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2' THEN
            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || 'p_scheme           => ''OAUTH_CLIENT_CRED'','
            || LF;
        END IF;

        IF
            P_METHOD = 'DELETE'
        THEN
            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || 'p_body        => null );'
            || LF;
        ELSE
            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || 'p_body        => apex_json.get_clob_output );'
            || LF;
        END IF;

        L_PLSQL := L_PLSQL
        || 'end;'
        || LF;
        RETURN L_PLSQL;
    END GENERATE_DML_CODE;

    FUNCTION GENERATE_EXTRACTLINKS_CODE (
        P_SERVICE_ID        IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_ORDS_LINKS_TYPE   IN VARCHAR2
    ) RETURN VARCHAR2 IS
        L_SQL   VARCHAR2(32767) := '';
    BEGIN
        LOAD(P_SERVICE_ID);
        L_SQL := L_SQL
        || '-- INSTRUCTIONS '
        || LF
        || '-- '
        || LF
        || '-- 1. create 3 items on your Application Express page: '
        || LF
        || '--    - {APEX_ITEM_URL_NEXT_PAGE}: holds the REST data URL for the next page'
        || LF
        || '--    - {APEX_ITEM_URL_PREV_PAGE}: holds the REST data URL for the previous page'
        || LF
        || '--    - {APEX_ITEM_SHOW_PAGE}:     determines whether to move forward or backwards '
        || LF
        || '-- '
        || LF
        || '-- 2. create two page buttons:'
        || LF
        || '--    - "PREV": redirect to the same page and set :{APEX_ITEM_SHOW_PAGE} to "prev"'
        || LF
        || '--    -         conditional; show only when {APEX_ITEM_URL_PREV_PAGE} is NOT NULL'
        || LF
        || '--    - "NEXT": redirect to the same page and set :{APEX_ITEM_SHOW_PAGE} to "next"'
        || LF
        || '--    -         conditional; show only when {APEX_ITEM_URL_NEXT_PAGE} is NOT NULL'
        || LF
        || '--'
        || LF
        || '-- 3. replace the on Page Load code with the following. Replace all occurrences of'
        || LF
        || '--    :{APEX_ITEM_...} with your page item names.'
        || LF
        || '--'
        || LF
        || LF;

        L_SQL := L_SQL
        || 'declare'
        || LF
        || C_INDENT
        || 'l_response      clob;'
        || LF;

        IF
            NOT ( G_SERVICE_DATA.RESPONSE_CHARSET IS NULL OR LOWER(G_SERVICE_DATA.RESPONSE_CHARSET) = LOWER(G_DB_CHARSET) )
        THEN
            L_SQL := L_SQL
            || C_INDENT
            || 'l_response_blob blob;'
            || LF;
        END IF;

        L_SQL := L_SQL
        || 'begin'
        || LF;
        L_SQL := L_SQL
        || GENERATE_PLSQL_FOR_HTTPHEADERS(P_SERVICE_ID,'GET');
        L_SQL := L_SQL
        || GENERATE_OAUTH_CODE
        || LF;
        L_SQL := L_SQL
        || GENERATE_MAKE_REST_REQUEST(P_DYNAMIC_PAGINATION => TRUE)
        || LF;
        IF
            P_ORDS_LINKS_TYPE = 'ORDS_1'
        THEN
            IF
                EBA_RESTDEMO_JSON_12C
            THEN
                L_SQL := L_SQL
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || 'j.next_page, '
                || LF
                || C_INDENT
                || C_INDENT
                || 'nvl( j.prev1_page, j.prev2_page ) '
                || LF
                || C_INDENT
                || '  -- TODO: replace with your page item names here'
                || LF
                || C_INDENT
                || '  into :{APEX_ITEM_URL_NEXT_PAGE}, :{APEX_ITEM_URL_PREV_PAGE}'
                || LF
                || C_INDENT
                || 'from apex_collections c, json_table( '
                || LF
                || C_INDENT
                || C_INDENT
                || 'c.clob001,'
                || LF
                || C_INDENT
                || C_INDENT
                || '''$'''
                || LF
                || C_INDENT
                || C_INDENT
                || 'columns('
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'next_page  varchar2(500) path ''$.next."\u0024ref"'','
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'prev1_page varchar2(500) path ''$.prev."\u0024ref"'','
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'prev2_page varchar2(500) path ''$.previous."\u0024ref"'''
                || LF
                || C_INDENT
                || C_INDENT
                || ')'
                || LF
                || C_INDENT
                || ') j'
                || LF
                || C_INDENT
                || 'where c.collection_name = ''REST_COLLECTION'';'
                || LF;

            ELSE
                L_SQL := L_SQL
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || 'x.next_page, '
                || LF
                || C_INDENT
                || C_INDENT
                || 'nvl( x.prev1_page, x.prev2_page ) '
                || LF
                || C_INDENT
                || '  -- TODO: replace with your page item names here'
                || LF
                || C_INDENT
                || '  into :{APEX_ITEM_URL_NEXT_PAGE}, :{APEX_ITEM_URL_PREV_PAGE}'
                || LF
                || C_INDENT
                || 'from apex_collections c, xmltable( '
                || LF
                || C_INDENT
                || C_INDENT
                || '''/json'''
                || LF
                || C_INDENT
                || C_INDENT
                || 'passing apex_json.to_xmltype( c.clob001 )'
                || LF
                || C_INDENT
                || C_INDENT
                || 'columns'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'next_page  varchar2(500) path ''next/_ref'','
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'prev1_page varchar2(500) path ''prev/_ref'','
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'prev2_page varchar2(500) path ''previous/_ref'''
                || LF
                || C_INDENT
                || ') x'
                || LF
                || C_INDENT
                || 'where c.collection_name = ''REST_COLLECTION'';'
                || LF;
            END IF;
        ELSIF P_ORDS_LINKS_TYPE = 'ORDS_2' THEN
            L_SQL := L_SQL
            || C_INDENT
            || '-- TODO: replace with your page item names here'
            || LF
            || C_INDENT
            || ':{APEX_ITEM_URL_NEXT_PAGE} := null;'
            || LF
            || C_INDENT
            || ':{APEX_ITEM_URL_PREV_PAGE} := null;'
            || LF
            || C_INDENT
            || LF
            || C_INDENT
            || 'for l in ( '
            || LF;

            IF
                EBA_RESTDEMO_JSON_12C
            THEN
                L_SQL := L_SQL
                || C_INDENT
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'j.link_type, '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'j.link '
                || LF
                || C_INDENT
                || C_INDENT
                || 'from apex_collections c, json_table( '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'c.clob001,'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || '''$.links[*]'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'columns('
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link_type varchar2(500) path ''$.rel'','
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link      varchar2(500) path ''$.href'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || ')'
                || LF
                || C_INDENT
                || C_INDENT
                || ') j'
                || LF
                || C_INDENT
                || C_INDENT
                || 'where c.collection_name = ''REST_COLLECTION'''
                || LF;

            ELSE
                L_SQL := L_SQL
                || C_INDENT
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'x.link_type, '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'x.link '
                || LF
                || C_INDENT
                || C_INDENT
                || 'from apex_collections c, xmltable( '
                || LF
                || C_INDENT
                || C_INDENT
                || '''//links/row'''
                || LF
                || C_INDENT
                || C_INDENT
                || 'passing apex_json.to_xmltype( c.clob001 )'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'columns'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link_type varchar2(500) path ''rel'','
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link      varchar2(500) path ''href'''
                || LF
                || C_INDENT
                || C_INDENT
                || ') x'
                || LF
                || C_INDENT
                || C_INDENT
                || 'where c.collection_name = ''REST_COLLECTION'''
                || LF;
            END IF;

            L_SQL := L_SQL
            || C_INDENT
            || ') loop '
            || LF
            || C_INDENT
            || C_INDENT
            || '-- TODO: replace with your page item names here'
            || LF
            || C_INDENT
            || C_INDENT
            || 'if l.link_type = ''next'' then :{APEX_ITEM_URL_NEXT_PAGE} := l.link; end if;'
            || LF
            || C_INDENT
            || C_INDENT
            || 'if l.link_type in (''prev'', ''previous'' ) then :{APEX_ITEM_URL_PREV_PAGE} := l.link; end if;'
            || LF
            || C_INDENT
            || 'end loop;'
            || LF;

        END IF;

        L_SQL := L_SQL
        || 'end;'
        || LF;
        RETURN L_SQL;
    END GENERATE_EXTRACTLINKS_CODE;
    -----------------------------------------------------------------------------------------------------
    --
    -- REST Request Helper functions
    --
    --

    PROCEDURE SET_HTTP_HEADERS (
        P_SERVICE_ID    IN EBA_RESTDEMO_SERVICES.ID%TYPE DEFAULT NULL,
        P_HTTP_METHOD   IN VARCHAR2
    ) IS
        L_PLSQL            VARCHAR2(32767);
        L_USER_AGENT_SET   BOOLEAN := FALSE;
        L_HEADERS_CNT      PLS_INTEGER;
    BEGIN
        APEX_WEB_SERVICE.G_REQUEST_HEADERS.DELETE;
        FOR H IN (
            SELECT
                ROWNUM AS SEQ,
                HEADER_NAME,
                HEADER_VALUE
            FROM
                EBA_RESTDEMO_HTTP_HEADERS
            WHERE
                SERVICE_ID = P_SERVICE_ID
                AND   INSTR(HEADER_FOR,P_HTTP_METHOD) != 0
                AND   HEADER_ACTIVE = 'Y'
            ORDER BY
                HEADER_SEQ
        ) LOOP
            APEX_WEB_SERVICE.G_REQUEST_HEADERS(H.SEQ).NAME := H.HEADER_NAME;
            APEX_WEB_SERVICE.G_REQUEST_HEADERS(H.SEQ).VALUE := H.HEADER_VALUE;
            IF
                LOWER(H.HEADER_NAME) = 'user-agent'
            THEN
                L_USER_AGENT_SET := TRUE;
            END IF;
        END LOOP;

        IF
            NOT L_USER_AGENT_SET
        THEN
            L_HEADERS_CNT := APEX_WEB_SERVICE.G_REQUEST_HEADERS.COUNT;
            APEX_WEB_SERVICE.G_REQUEST_HEADERS(L_HEADERS_CNT + 1).NAME := 'User-Agent';
            APEX_WEB_SERVICE.G_REQUEST_HEADERS(L_HEADERS_CNT + 1).VALUE := 'Oracle Application Express / REST Client Assistant';
        END IF;

    END SET_HTTP_HEADERS;

    FUNCTION HTTP_GET_STATUS_TEXT (
        P_STATUS_CODE IN NUMBER
    ) RETURN VARCHAR2
        IS
    BEGIN
        IF
            G_HTTP_STATUS_CODES.COUNT = 0
        THEN
            G_HTTP_STATUS_CODES(200) := 'OK';
            G_HTTP_STATUS_CODES(201) := 'Created';
            G_HTTP_STATUS_CODES(204) := 'No Content';
            G_HTTP_STATUS_CODES(400) := 'Bad Request';
            G_HTTP_STATUS_CODES(401) := 'Unauthorized';
            G_HTTP_STATUS_CODES(403) := 'Forbidden';
            G_HTTP_STATUS_CODES(404) := 'Not found';
            G_HTTP_STATUS_CODES(405) := 'HTTP Method not allowed';
            G_HTTP_STATUS_CODES(407) := 'Proxy Auth required';
            G_HTTP_STATUS_CODES(500) := 'Unknown Server error';
            G_HTTP_STATUS_CODES(501) := 'Not implemented';
            G_HTTP_STATUS_CODES(502) := 'Bad Gateway';
            G_HTTP_STATUS_CODES(503) := 'Service unavailable';
        END IF;

        IF
            P_STATUS_CODE IS NULL
        THEN
            RETURN 'No request executed';
        ELSE
            RETURN G_HTTP_STATUS_CODES(P_STATUS_CODE);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END HTTP_GET_STATUS_TEXT;
    -----------------------------------------------------------------------------------------------------
    --
    -- Extract ORDS Links from Response
    --
    --

    PROCEDURE EXTRACT_LINKS
        IS
    BEGIN
        G_ORDS_NEXTLINK := NULL;
        G_ORDS_PREVLINK := NULL;
        G_ORDS_FIRSTLINK := NULL;
        G_ORDS_DESCRLINK := NULL;
        G_ORDS_LINKTYPE := NULL;
        IF
            EBA_RESTDEMO_JSON_12C
        THEN
            EXECUTE IMMEDIATE q'#
            begin
                for i in (
                    select linktype, link
                      from json_table(
                          eba_restdemo_helper.get_data_clob format json,
                          '$.links[*]'
                          columns (
                              linktype varchar2(20)  path '$.rel',
                              link     varchar2(500) path '$.href'
                          )
                      )
                ) loop
                    if i.linktype = 'next'        then eba_restdemo_helper.g_ords_nextlink  := i.link; eba_restdemo_helper.g_ords_linktype := 'ORDS_2'; end if;
                    if i.linktype = 'prev'        then eba_restdemo_helper.g_ords_prevlink  := i.link; eba_restdemo_helper.g_ords_linktype := 'ORDS_2'; end if;
                    if i.linktype = 'first'       then eba_restdemo_helper.g_ords_firstlink := i.link; eba_restdemo_helper.g_ords_linktype := 'ORDS_2'; end if;
                    if i.linktype = 'describedby' then eba_restdemo_helper.g_ords_descrlink := i.link; eba_restdemo_helper.g_ords_linktype := 'ORDS_2'; end if;
                end loop;
            end;#'
;
        ELSE
            EXECUTE IMMEDIATE q'#
            begin
                for i in (
                    select linktype, link
                      from xmltable(
                          '/json/links/row'
                          passing apex_json.to_xmltype( eba_restdemo_helper.get_data_clob )
                          columns
                              linktype varchar2(20)  path 'rel/text()',
                              link     varchar2(500) path 'href/text()'
                      )
                ) loop
                    if i.linktype = 'next'        then eba_restdemo_helper.g_ords_nextlink  := i.link; eba_restdemo_helper.g_ords_linktype := 'ORDS_2'; end if;
                    if i.linktype = 'prev'        then eba_restdemo_helper.g_ords_prevlink  := i.link; eba_restdemo_helper.g_ords_linktype := 'ORDS_2'; end if;
                    if i.linktype = 'first'       then eba_restdemo_helper.g_ords_firstlink := i.link; eba_restdemo_helper.g_ords_linktype := 'ORDS_2'; end if;
                    if i.linktype = 'describedby' then eba_restdemo_helper.g_ords_descrlink := i.link; eba_restdemo_helper.g_ords_linktype := 'ORDS_2'; end if;
                end loop;
            end;#'
;
        END IF;
        IF
            G_ORDS_LINKTYPE IS NULL
        THEN
            FOR I IN (
                SELECT
                    LINKTYPE,
                    LINK
                FROM
                    XMLTABLE ( '/json/(next|prev|previous|first)' PASSING APEX_JSON.TO_XMLTYPE(EBA_RESTDEMO_HELPER.GET_DATA_CLOB) COLUMNS LINKTYPE VARCHAR2(
20) PATH 'local-name()',LINK VARCHAR2(500) PATH '_ref/text()' )
            ) LOOP
                IF
                    I.LINKTYPE = 'next'
                THEN
                    EBA_RESTDEMO_HELPER.G_ORDS_NEXTLINK := I.LINK;
                END IF;

                IF
                    I.LINKTYPE IN (
                        'prev',
                        'previous'
                    )
                THEN
                    EBA_RESTDEMO_HELPER.G_ORDS_PREVLINK := I.LINK;
                END IF;

                IF
                    I.LINKTYPE = 'first'
                THEN
                    EBA_RESTDEMO_HELPER.G_ORDS_FIRSTLINK := I.LINK;
                END IF;

                G_ORDS_LINKTYPE := 'ORDS_1';
            END LOOP;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END EXTRACT_LINKS;

    FUNCTION GET_ORDS_PREVLINK RETURN VARCHAR2
        IS
    BEGIN
        RETURN G_ORDS_PREVLINK;
    END GET_ORDS_PREVLINK;

    FUNCTION GET_ORDS_NEXTLINK RETURN VARCHAR2
        IS
    BEGIN
        RETURN G_ORDS_NEXTLINK;
    END GET_ORDS_NEXTLINK;

    FUNCTION GET_ORDS_FIRSTLINK RETURN VARCHAR2
        IS
    BEGIN
        RETURN G_ORDS_FIRSTLINK;
    END GET_ORDS_FIRSTLINK;

    FUNCTION GET_ORDS_LINKTYPE RETURN VARCHAR2
        IS
    BEGIN
        RETURN G_ORDS_LINKTYPE;
    END GET_ORDS_LINKTYPE;
    -----------------------------------------------------------------------------------------------------
    --
    -- REST Request functions'- Add REST Service Assistant -'
    --
    --

    PROCEDURE GRAB_DATA (
        P_SERVICE_ID          IN EBA_RESTDEMO_SERVICES.ID%TYPE DEFAULT NULL,
        P_ENDPOINT_OVERRIDE   IN VARCHAR2 DEFAULT NULL,
        P_REUSE_OAUTH         IN BOOLEAN DEFAULT FALSE
    ) IS
        EXC_HTTP_ERROR EXCEPTION;
        PRAGMA EXCEPTION_INIT ( EXC_HTTP_ERROR,-29273 );
        L_URL   VARCHAR2(32767);
    BEGIN
        LOAD(P_SERVICE_ID);
        IF
            NOT P_REUSE_OAUTH
        THEN
            OAUTH_AUTHENTICATE;
        END IF;
        SET_HTTP_HEADERS(P_SERVICE_ID,'GET');
        L_URL := PREPARE_URL(G_SERVICE_DATA.ENDPOINT,'GET');
        START_TIMER;
        IF
            G_SERVICE_DATA.RESPONSE_CHARSET IS NULL OR LOWER(G_SERVICE_DATA.RESPONSE_CHARSET) = LOWER(G_DB_CHARSET)
        THEN
            G_REST_DATA := APEX_WEB_SERVICE.MAKE_REST_REQUEST(P_URL => COALESCE(P_ENDPOINT_OVERRIDE,L_URL),P_HTTP_METHOD => 'GET',P_USERNAME => G_SERVICE_DATA
.AUTH_BASIC_USERNAME,P_PASSWORD => GET_PASSWORD(P_SERVICE_ID),P_SCHEME =>
                CASE
                    WHEN G_SERVICE_DATA.AUTH_TYPE = 'BASIC' THEN 'Basic'
                    WHEN G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2' THEN 'OAUTH_CLIENT_CRED'
                    ELSE NULL
                END
            );
        ELSE
            DECLARE
                L_SRCOFF   NUMBER := 1;
                L_DSTOFF   NUMBER := 1;
                L_LNGCTX   NUMBER := 0;
                L_WARN     NUMBER;
                L_DATA     BLOB;
            BEGIN
                L_DATA := APEX_WEB_SERVICE.MAKE_REST_REQUEST_B(P_URL => COALESCE(P_ENDPOINT_OVERRIDE,L_URL),P_HTTP_METHOD => 'GET',P_USERNAME => G_SERVICE_DATA
.AUTH_BASIC_USERNAME,P_PASSWORD => GET_PASSWORD(P_SERVICE_ID),P_SCHEME =>
                    CASE
                        WHEN G_SERVICE_DATA.AUTH_TYPE = 'BASIC' THEN 'Basic'
                        WHEN G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2' THEN 'OAUTH_CLIENT_CRED'
                        ELSE NULL
                    END
                );

                SYS.DBMS_LOB.CREATETEMPORARY(G_REST_DATA,TRUE,DBMS_LOB.CALL);
                SYS.DBMS_LOB.CONVERTTOCLOB(DEST_LOB => G_REST_DATA,SRC_BLOB => L_DATA,AMOUNT => SYS.DBMS_LOB.LOBMAXSIZE,DEST_OFFSET => L_DSTOFF,SRC_OFFSET
=> L_SRCOFF,BLOB_CSID => NLS_CHARSET_ID(G_SERVICE_DATA.RESPONSE_CHARSET),LANG_CONTEXT => L_LNGCTX,WARNING => L_WARN);

                SYS.DBMS_LOB.FREETEMPORARY(L_DATA);
            END;
        END IF;

        LOG(G_SERVICE_DATA.ID,G_SERVICE_DATA.NAME,'HTTP_GET',COALESCE(P_ENDPOINT_OVERRIDE,L_URL),DBMS_LOB.GETLENGTH(G_REST_DATA),APEX_WEB_SERVICE
.G_STATUS_CODE,GET_ELAPSED_TIME,NULL,NULL);

        IF
            G_SERVICE_DATA.RESPONSE_TYPE = 'JSON'
        THEN
            EXTRACT_LINKS;
        END IF;
    EXCEPTION
        WHEN EXC_HTTP_ERROR THEN
            LOG(G_SERVICE_DATA.ID,G_SERVICE_DATA.NAME,'HTTP_GET',COALESCE(P_ENDPOINT_OVERRIDE,L_URL),NULL,APEX_WEB_SERVICE.G_STATUS_CODE,GET_ELAPSED_TIME
,SQLCODE,SQLERRM);

            G_REST_DATA := SQLERRM;
    END GRAB_DATA;

    FUNCTION GRAB_DATA_CLOB (
        P_URL_ENDPOINT         IN VARCHAR2,
        P_AUTH_TYPE            IN VARCHAR2,
        P_BASICAUTH_USERNAME   IN VARCHAR2 DEFAULT NULL,
        P_BASICAUTH_PASSWORD   IN VARCHAR2 DEFAULT NULL,
        P_OAUTH_TOKEN_URL      IN VARCHAR2 DEFAULT NULL,
        P_OAUTH_CLIENTID       IN VARCHAR2 DEFAULT NULL,
        P_OAUTH_CLIENTSECRET   IN VARCHAR2 DEFAULT NULL
    ) RETURN CLOB IS
        G_RESPONSE   CLOB;
    BEGIN
        APEX_WEB_SERVICE.G_REQUEST_HEADERS.DELETE;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS(1).NAME := 'User-Agent';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS(1).VALUE := 'Oracle Application Express / REST Client Assistant';
        IF
            P_AUTH_TYPE = 'OAUTH2'
        THEN
            START_TIMER;
            APEX_WEB_SERVICE.OAUTH_AUTHENTICATE(P_TOKEN_URL => P_OAUTH_TOKEN_URL,P_CLIENT_ID => P_OAUTH_CLIENTID,P_CLIENT_SECRET => P_OAUTH_CLIENTSECRET
);

            LOG(0,'- Add REST Service Assistant -','OAUTH_AUTHENTICATE',P_OAUTH_TOKEN_URL,NULL,APEX_WEB_SERVICE.G_STATUS_CODE,GET_ELAPSED_TIME
,NULL,NULL);

        END IF;

        START_TIMER;
        G_RESPONSE := APEX_WEB_SERVICE.MAKE_REST_REQUEST(P_URL => P_URL_ENDPOINT,P_HTTP_METHOD => 'GET',P_USERNAME => P_BASICAUTH_USERNAME,P_PASSWORD
=> P_BASICAUTH_PASSWORD,P_SCHEME =>
            CASE
                WHEN P_AUTH_TYPE = 'BASIC' THEN 'Basic'
                WHEN P_AUTH_TYPE = 'OAUTH2' THEN 'OAUTH_CLIENT_CRED'
                ELSE NULL
            END
        );

        LOG(0,'- Add REST Service Assistant -','HTTP_GET',P_URL_ENDPOINT,DBMS_LOB.GETLENGTH(G_RESPONSE),APEX_WEB_SERVICE.G_STATUS_CODE,GET_ELAPSED_TIME
,NULL,NULL);

        RETURN G_RESPONSE;
    EXCEPTION
        WHEN OTHERS THEN
            LOG(0,'- Add REST Service Assistant -','HTTP_GET',P_URL_ENDPOINT,NULL,APEX_WEB_SERVICE.G_STATUS_CODE,GET_ELAPSED_TIME,SQLCODE,SQLERRM
);

            G_RESPONSE := SQLERRM;
            RETURN G_RESPONSE;
    END GRAB_DATA_CLOB;

    FUNCTION GET_DATA_CLOB (
        P_SERVICE_ID          IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_ENDPOINT_OVERRIDE   IN VARCHAR2 DEFAULT NULL
    ) RETURN CLOB
        IS
    BEGIN
        GRAB_DATA(P_SERVICE_ID,P_ENDPOINT_OVERRIDE);
        RETURN GET_DATA_CLOB;
    END GET_DATA_CLOB;

    FUNCTION GET_DATA_CLOB RETURN CLOB
        IS
    BEGIN
        RETURN G_REST_DATA;
    END GET_DATA_CLOB;

    FUNCTION POST_ROW (
        P_SERVICE_ID        IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_COLLECTION_NAME   IN VARCHAR2
    ) RETURN VARCHAR2 IS
        L_JSON       VARCHAR2(32767);
        L_RESPONSE   VARCHAR2(32767);
        L_URL        VARCHAR2(32767);
    BEGIN
        LOAD(P_SERVICE_ID);
        OAUTH_AUTHENTICATE;
        L_JSON := GENERATE_JSON_BODY(P_COLLECTION_NAME);
        SET_HTTP_HEADERS(P_SERVICE_ID,'POST');
        L_URL := PREPARE_URL(G_SERVICE_DATA.ENDPOINT,'POST');
        START_TIMER;
        L_RESPONSE := APEX_WEB_SERVICE.MAKE_REST_REQUEST(P_URL => L_URL,P_HTTP_METHOD => 'POST',P_USERNAME => G_SERVICE_DATA.AUTH_BASIC_USERNAME,
P_PASSWORD => GET_PASSWORD(P_SERVICE_ID),P_SCHEME =>
            CASE
                WHEN G_SERVICE_DATA.AUTH_TYPE = 'BASIC' THEN 'Basic'
                WHEN G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2' THEN 'OAUTH_CLIENT_CRED'
                ELSE NULL
            END,P_BODY => L_JSON);

        LOG(G_SERVICE_DATA.ID,G_SERVICE_DATA.NAME,'HTTP_POST',L_URL,DBMS_LOB.GETLENGTH(L_RESPONSE),APEX_WEB_SERVICE.G_STATUS_CODE,GET_ELAPSED_TIME
,NULL,NULL);

        APEX_WEB_SERVICE.G_REQUEST_HEADERS.DELETE;
        RETURN L_RESPONSE;
    END POST_ROW;

    FUNCTION PUT_ROW (
        P_SERVICE_ID        IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_COLLECTION_NAME   IN VARCHAR2
    ) RETURN VARCHAR2 IS

        L_JSON          VARCHAR2(32767);
        L_PRIMARY_KEY   VARCHAR2(4000);
        L_RESPONSE      VARCHAR2(32767);
        L_URL           VARCHAR2(32767);
    BEGIN
        LOAD(P_SERVICE_ID);
        OAUTH_AUTHENTICATE;
        L_JSON := GENERATE_JSON_BODY(P_COLLECTION_NAME);
        L_URL := PREPARE_URL(RTRIM(G_SERVICE_DATA.ENDPOINT,'/')
        || '/'
        || GET_PK_VALUE(P_COLLECTION_NAME),'PUT');

        SET_HTTP_HEADERS(P_SERVICE_ID,'PUT');
        START_TIMER;
        L_RESPONSE := APEX_WEB_SERVICE.MAKE_REST_REQUEST(P_URL => L_URL,P_HTTP_METHOD => 'PUT',P_USERNAME => G_SERVICE_DATA.AUTH_BASIC_USERNAME,P_PASSWORD
=> GET_PASSWORD(P_SERVICE_ID),P_SCHEME =>
            CASE
                WHEN G_SERVICE_DATA.AUTH_TYPE = 'BASIC' THEN 'Basic'
                WHEN G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2' THEN 'OAUTH_CLIENT_CRED'
                ELSE NULL
            END,P_BODY => L_JSON);

        LOG(G_SERVICE_DATA.ID,G_SERVICE_DATA.NAME,'HTTP_PUT',L_URL,DBMS_LOB.GETLENGTH(L_RESPONSE),APEX_WEB_SERVICE.G_STATUS_CODE,GET_ELAPSED_TIME
,NULL,NULL);

        APEX_WEB_SERVICE.G_REQUEST_HEADERS.DELETE;
        RETURN L_RESPONSE;
    END PUT_ROW;

    FUNCTION DELETE_ROW (
        P_SERVICE_ID        IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_COLLECTION_NAME   IN VARCHAR2
    ) RETURN VARCHAR2 IS
        L_RESPONSE   VARCHAR2(32767);
        L_URL        VARCHAR2(32767);
    BEGIN
        LOAD(P_SERVICE_ID);
        OAUTH_AUTHENTICATE;
        SET_HTTP_HEADERS(P_SERVICE_ID,'DELETE');
        L_URL := PREPARE_URL(RTRIM(G_SERVICE_DATA.ENDPOINT,'/')
        || '/'
        || GET_PK_VALUE(P_COLLECTION_NAME),'DELETE');

        START_TIMER;
        L_RESPONSE := APEX_WEB_SERVICE.MAKE_REST_REQUEST(P_URL => L_URL,P_HTTP_METHOD => 'DELETE',P_USERNAME => G_SERVICE_DATA.AUTH_BASIC_USERNAME
,P_PASSWORD => GET_PASSWORD(P_SERVICE_ID),P_SCHEME =>
            CASE
                WHEN G_SERVICE_DATA.AUTH_TYPE = 'BASIC' THEN 'Basic'
                WHEN G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2' THEN 'OAUTH_CLIENT_CRED'
                ELSE NULL
            END
        );

        LOG(G_SERVICE_DATA.ID,G_SERVICE_DATA.NAME,'HTTP_DELETE',L_URL,DBMS_LOB.GETLENGTH(L_RESPONSE),APEX_WEB_SERVICE.G_STATUS_CODE,GET_ELAPSED_TIME
,NULL,NULL);

        RETURN L_RESPONSE;
    END DELETE_ROW;
    -----------------------------------------------------------------------------------------------------
    --
    -- Other functions
    --
    --

    FUNCTION GET_VERSION RETURN VARCHAR2
        IS
    BEGIN
        RETURN '5.1.2';
    END GET_VERSION;

    FUNCTION GENERATE_TABLE_FUNCTION (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_TABLE_NAME   IN VARCHAR2,
        P_MAX_ROWS     IN NUMBER DEFAULT NULL
    ) RETURN VARCHAR2 IS

        L_PLSQL             VARCHAR2(32767) := '';
        L_QUERY             VARCHAR2(32767) := '';
        L_MAX_COLNAME_LEN   PLS_INTEGER := 0;
        L_COL_CNT           PLS_INTEGER;
    BEGIN
        LOAD(P_SERVICE_ID);
        GRAB_DATA;
        L_PLSQL := L_PLSQL
        || '--------------------------------------------------------------'
        || LF
        || '-- make sure to use the point (.) as the decimal character'
        || LF
        || '-- to correctly process XML and JSON responses'
        || LF
        || '--'
        || LF
        || 'alter session set nls_numeric_characters = ''.,'';'
        || LF
        || LF;

        L_PLSQL := L_PLSQL
        || 'create type '
        || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME
        || '_T')
        || ' as object ('
        || LF;

        L_COL_CNT := G_SERVICE_COLUMN_MAPPINGS.COUNT;
        FOR I IN 1..L_COL_CNT LOOP
            IF
                LENGTH(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME) > L_MAX_COLNAME_LEN
            THEN
                L_MAX_COLNAME_LEN := LENGTH(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME);
            END IF;
        END LOOP;

        FOR I IN 1..L_COL_CNT LOOP
            L_PLSQL := L_PLSQL
            || C_INDENT
            || RPAD('"'
            || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
            || '"',L_MAX_COLNAME_LEN + 4);

            IF
                G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'VARCHAR2'
            THEN
                L_PLSQL := L_PLSQL
                || 'VARCHAR2'
                || '('
                || NVL(G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE_LEN,4000)
                || ')';

            ELSE
                L_PLSQL := L_PLSQL
                || G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE;
            END IF;

            IF
                I < L_COL_CNT
            THEN
                L_PLSQL := L_PLSQL
                || ',';
            END IF;
            L_PLSQL := L_PLSQL
            || LF;
        END LOOP;

        L_PLSQL := L_PLSQL
        || ');'
        || LF
        || '/'
        || LF
        || LF;

        L_PLSQL := L_PLSQL
        || 'create type '
        || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME
        || '_CT')
        || ' '
        || 'as table of '
        || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME
        || '_T')
        || LF
        || '/'
        || LF
        || LF;

        L_PLSQL := L_PLSQL
        || 'create or replace function '
        || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME)
        || '('
        || LF
        || C_INDENT
        || 'p_max_rows in number default '
        ||
            CASE
                WHEN P_MAX_ROWS IS NULL THEN 'null'
                ELSE TO_CHAR(P_MAX_ROWS)
            END
        || LF
        || ') return '
        || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME
        || '_CT')
        || ' pipelined'
        || LF;

        L_PLSQL := L_PLSQL
        || 'is'
        || LF
        || C_INDENT
        || 'l_response    clob;'
        || LF
        || C_INDENT
        || 'l_url         varchar2(32767);'
        || LF
        || C_INDENT
        || 'l_finish      boolean          := false;'
        || LF
        || C_INDENT
        || 'l_rows_loaded number           := 0;'
        || LF
        || 'begin'
        || LF;

        L_PLSQL := L_PLSQL
        || GENERATE_PLSQL_FOR_HTTPHEADERS(P_SERVICE_ID,'GET');
        L_PLSQL := L_PLSQL
        || GENERATE_OAUTH_CODE;
        L_PLSQL := L_PLSQL
        || C_INDENT
        || 'l_url := '
        || PREPARE_URL(G_SERVICE_DATA.ENDPOINT,'GET',TRUE)
        || ';'
        || LF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || 'while not l_finish loop'
        || LF;
        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || 'l_response := apex_web_service.make_rest_request('
        || LF;
        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || 'p_url              => l_url,'
        || LF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || 'p_http_method      => ''GET''';
        IF
            G_SERVICE_DATA.AUTH_TYPE = 'BASIC'
        THEN
            L_PLSQL := L_PLSQL
            || ','
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'p_username         => '''
            || G_SERVICE_DATA.AUTH_BASIC_USERNAME
            || ''','
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'p_password         => ''{Password}'','
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'p_scheme           => ''Basic'' );';
        ELSIF G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2' THEN
            L_PLSQL := L_PLSQL
            || ','
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'p_scheme           => ''OAUTH_CLIENT_CRED'' );';
        ELSE
            L_PLSQL := L_PLSQL
            || ');';
        END IF;

        L_PLSQL := L_PLSQL
        || LF
        || LF;
        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || 'for c in ('
        || LF;
        IF
            G_SERVICE_DATA.RESPONSE_TYPE = 'XML'
        THEN
            L_QUERY := GET_SQL_QUERY_XML(P_GENERATE => 'LOAD');
        ELSE
            IF
                EBA_RESTDEMO_JSON_12C
            THEN
                L_QUERY := GET_SQL_QUERY_JSON(P_GENERATE => 'LOAD');
            ELSE
                L_QUERY := GET_SQL_QUERY_JSON_11G(P_GENERATE => 'LOAD');
            END IF;
        END IF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || REPLACE(L_QUERY,LF,LF
        || C_INDENT
        || C_INDENT
        || C_INDENT);

        L_PLSQL := L_PLSQL
        || LF
        || C_INDENT
        || C_INDENT
        || ') loop'
        || LF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || 'if l_rows_loaded < p_max_rows or p_max_rows is null then'
        || LF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || 'pipe row ( '
        || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME
        || '_T')
        || '( '
        || LF;

        FOR I IN 1..L_COL_CNT LOOP
            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'c."'
            || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
            || '"';

            IF
                I < L_COL_CNT
            THEN
                L_PLSQL := L_PLSQL
                || ',';
            END IF;
            L_PLSQL := L_PLSQL
            || LF;
        END LOOP;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || ') );'
        || LF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || 'l_rows_loaded := l_rows_loaded + 1;'
        || LF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || 'end if;'
        || LF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || 'end loop;'
        || LF
        || LF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || 'if l_rows_loaded >= p_max_rows then '
        || LF
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || 'l_finish := true;'
        || LF
        || C_INDENT
        || C_INDENT
        || 'end if;'
        || LF;

        IF
            G_ORDS_LINKTYPE = 'ORDS_1'
        THEN
            IF
                EBA_RESTDEMO_JSON_12C
            THEN
                L_PLSQL := L_PLSQL
                || C_INDENT
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'j.next_page into l_url'
                || LF
                || C_INDENT
                || C_INDENT
                || 'from json_table( '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'l_response,'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || '''$'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'columns('
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'next_page varchar2(500) path ''$.next."\u0024ref"'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || ')'
                || LF
                || C_INDENT
                || C_INDENT
                || ') j;'
                || LF;

            ELSE
                L_PLSQL := L_PLSQL
                || C_INDENT
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'x.next_page into l_url '
                || LF
                || C_INDENT
                || C_INDENT
                || 'from xmltable( '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || '''/json'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'passing apex_json.to_xmltype( l_response )'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'columns'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'next_page varchar2(500) path ''next/_ref'''
                || LF
                || C_INDENT
                || C_INDENT
                || ') x;'
                || LF;
            END IF;
        ELSIF G_ORDS_LINKTYPE = 'ORDS_2' THEN
            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || 'l_url := null;'
            || LF
            || C_INDENT
            || C_INDENT
            || 'for l in ( '
            || LF;

            IF
                EBA_RESTDEMO_JSON_12C
            THEN
                L_PLSQL := L_PLSQL
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'j.link_type, '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'j.link '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'from json_table( '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'l_response,'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || '''$.links[*]'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'columns('
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link_type varchar2(500) path ''$.rel'','
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link      varchar2(500) path ''$.href'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || ')'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || ') j'
                || LF;

            ELSE
                L_PLSQL := L_PLSQL
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'x.link_type, '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'x.link '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'from xmltable( '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || '''//links/row'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'passing apex_json.to_xmltype( l_response )'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'columns'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link_type varchar2(500) path ''rel'','
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link      varchar2(500) path ''href'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || ') x'
                || LF;
            END IF;

            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || ') loop '
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'if l.link_type = ''next'' then l_url := l.link; end if;'
            || LF
            || C_INDENT
            || C_INDENT
            || 'end loop;'
            || LF;

        ELSE
            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || 'l_url := null;'
            || LF;
        END IF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || 'if l_url is null then l_finish := true; end if;'
        || LF
        || C_INDENT
        || 'end loop;'
        || LF
        || 'end '
        || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME)
        || ';'
        || LF
        || '/';

        L_PLSQL := L_PLSQL
        || LF
        || '-- Now select this function as follows: '
        || LF
        || '-- select * from table('
        || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME)
        || '())'
        || LF;

        RETURN L_PLSQL;
    END GENERATE_TABLE_FUNCTION;

    FUNCTION GENERATE_LOAD_INTO_TABLE (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_TABLE_NAME   IN VARCHAR2,
        P_MAX_ROWS     IN NUMBER DEFAULT NULL
    ) RETURN VARCHAR2 IS

        L_PLSQL             VARCHAR2(32767) := '';
        L_QUERY             VARCHAR2(32767) := '';
        L_MAX_COLNAME_LEN   PLS_INTEGER := 0;
        L_COL_CNT           PLS_INTEGER;
    BEGIN
        LOAD(P_SERVICE_ID);
        GRAB_DATA;
        L_PLSQL := L_PLSQL
        || '--------------------------------------------------------------'
        || LF
        || '-- make sure to use the point (.) as the decimal character'
        || LF
        || '-- to correctly process XML and JSON responses'
        || LF
        || '--'
        || LF
        || 'alter session set nls_numeric_characters = ''.,'';'
        || LF
        || LF;

        L_PLSQL := L_PLSQL
        || 'create table '
        || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME)
        || ' ('
        || LF;

        L_COL_CNT := G_SERVICE_COLUMN_MAPPINGS.COUNT;
        FOR I IN 1..L_COL_CNT LOOP
            IF
                LENGTH(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME) > L_MAX_COLNAME_LEN
            THEN
                L_MAX_COLNAME_LEN := LENGTH(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME);
            END IF;
        END LOOP;

        FOR I IN 1..L_COL_CNT LOOP
            L_PLSQL := L_PLSQL
            || C_INDENT
            || RPAD(G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME,L_MAX_COLNAME_LEN + 2);

            IF
                G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE = 'VARCHAR2'
            THEN
                L_PLSQL := L_PLSQL
                || 'VARCHAR2'
                || '('
                || NVL(G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE_LEN,4000)
                || ')';

            ELSE
                L_PLSQL := L_PLSQL
                || G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE;
            END IF;

            IF
                I < L_COL_CNT
            THEN
                L_PLSQL := L_PLSQL
                || ',';
            END IF;
            L_PLSQL := L_PLSQL
            || LF;
        END LOOP;

        L_PLSQL := L_PLSQL
        || ');'
        || LF
        || LF;
        L_PLSQL := L_PLSQL
        || 'declare'
        || LF
        || C_INDENT
        || 'C_MAX_ROWS    number           := '
        ||
            CASE
                WHEN P_MAX_ROWS IS NULL THEN 'null'
                ELSE TO_CHAR(P_MAX_ROWS)
            END
        || ';'
        || LF
        || LF
        || C_INDENT
        || 'l_response    clob;'
        || LF
        || C_INDENT
        || 'l_url         varchar2(32767);'
        || LF
        || C_INDENT
        || 'l_finish      boolean          := false;'
        || LF
        || C_INDENT
        || 'l_rows_loaded number           := 0;'
        || LF
        || 'begin'
        || LF;

        L_PLSQL := L_PLSQL
        || GENERATE_PLSQL_FOR_HTTPHEADERS(P_SERVICE_ID,'GET');
        L_PLSQL := L_PLSQL
        || GENERATE_OAUTH_CODE;
        L_PLSQL := L_PLSQL
        || C_INDENT
        || 'l_url := '
        || PREPARE_URL(G_SERVICE_DATA.ENDPOINT,'GET',TRUE)
        || ';'
        || LF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || 'while not l_finish loop'
        || LF;
        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || 'l_response := apex_web_service.make_rest_request('
        || LF;
        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || 'p_url              => l_url,'
        || LF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || 'p_http_method      => ''GET''';
        IF
            G_SERVICE_DATA.AUTH_TYPE = 'BASIC'
        THEN
            L_PLSQL := L_PLSQL
            || ','
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'p_username         => '''
            || G_SERVICE_DATA.AUTH_BASIC_USERNAME
            || ''','
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'p_password         => ''{Password}'','
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'p_scheme           => ''Basic'' );';
        ELSIF G_SERVICE_DATA.AUTH_TYPE = 'OAUTH2' THEN
            L_PLSQL := L_PLSQL
            || ','
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'p_scheme           => ''OAUTH_CLIENT_CRED'' );';
        ELSE
            L_PLSQL := L_PLSQL
            || ');';
        END IF;

        L_PLSQL := L_PLSQL
        || LF
        || LF;
        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || 'insert into '
        || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME)
        || ' ('
        || LF;

        IF
            G_SERVICE_DATA.RESPONSE_TYPE = 'XML'
        THEN
            L_QUERY := GET_SQL_QUERY_XML(P_GENERATE => 'LOAD');
        ELSE
            IF
                EBA_RESTDEMO_JSON_12C
            THEN
                L_QUERY := GET_SQL_QUERY_JSON(P_GENERATE => 'LOAD');
            ELSE
                L_QUERY := GET_SQL_QUERY_JSON_11G(P_GENERATE => 'LOAD');
            END IF;
        END IF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || REPLACE(L_QUERY,LF,LF
        || C_INDENT
        || C_INDENT
        || C_INDENT);

        L_PLSQL := L_PLSQL
        || LF
        || C_INDENT
        || C_INDENT
        || ');'
        || LF
        || LF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || 'l_rows_loaded := l_rows_loaded + nvl( sql%rowcount, 0 );'
        || LF;
        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || 'if l_rows_loaded >= C_MAX_ROWS then '
        || LF
        || C_INDENT
        || C_INDENT
        || C_INDENT
        || 'l_finish := true;'
        || LF
        || C_INDENT
        || C_INDENT
        || 'end if;'
        || LF;

        IF
            G_ORDS_LINKTYPE = 'ORDS_1'
        THEN
            IF
                EBA_RESTDEMO_JSON_12C
            THEN
                L_PLSQL := L_PLSQL
                || C_INDENT
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'j.next_page into l_url'
                || LF
                || C_INDENT
                || C_INDENT
                || 'from json_table( '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'l_response,'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || '''$'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'columns('
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'next_page varchar2(500) path ''$.next."\u0024ref"'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || ')'
                || LF
                || C_INDENT
                || C_INDENT
                || ') j;'
                || LF;

            ELSE
                L_PLSQL := L_PLSQL
                || C_INDENT
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'x.next_page into l_url '
                || LF
                || C_INDENT
                || C_INDENT
                || 'from xmltable( '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || '''/json'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'passing apex_json.to_xmltype( l_response )'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'columns'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'next_page varchar2(500) path ''next/_ref'''
                || LF
                || C_INDENT
                || C_INDENT
                || ') x;'
                || LF;
            END IF;
        ELSIF G_ORDS_LINKTYPE = 'ORDS_2' THEN
            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || 'l_url := null;'
            || LF
            || C_INDENT
            || C_INDENT
            || 'for l in ( '
            || LF;

            IF
                EBA_RESTDEMO_JSON_12C
            THEN
                L_PLSQL := L_PLSQL
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'j.link_type, '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'j.link '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'from json_table( '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'l_response,'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || '''$.links[*]'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'columns('
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link_type varchar2(500) path ''$.rel'','
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link      varchar2(500) path ''$.href'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || ')'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || ') j'
                || LF;

            ELSE
                L_PLSQL := L_PLSQL
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'select'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'x.link_type, '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'x.link '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'from xmltable( '
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || '''//links/row'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'passing apex_json.to_xmltype( l_response )'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'columns'
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link_type varchar2(500) path ''rel'','
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || 'link      varchar2(500) path ''href'''
                || LF
                || C_INDENT
                || C_INDENT
                || C_INDENT
                || ') x'
                || LF;
            END IF;

            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || ') loop '
            || LF
            || C_INDENT
            || C_INDENT
            || C_INDENT
            || 'if l.link_type = ''next'' then l_url := l.link; end if;'
            || LF
            || C_INDENT
            || C_INDENT
            || 'end loop;'
            || LF;

        ELSE
            L_PLSQL := L_PLSQL
            || C_INDENT
            || C_INDENT
            || 'l_url := null;'
            || LF;
        END IF;

        L_PLSQL := L_PLSQL
        || C_INDENT
        || C_INDENT
        || 'if l_url is null then l_finish := true; end if;'
        || LF
        || C_INDENT
        || 'end loop;'
        || LF
        || 'end;'
        || LF
        || '/';

        RETURN L_PLSQL;
    END GENERATE_LOAD_INTO_TABLE;

    PROCEDURE LOAD_INTO_TABLE (
        P_SERVICE_ID   IN EBA_RESTDEMO_SERVICES.ID%TYPE,
        P_TABLE_NAME   IN VARCHAR2,
        P_MAX_ROWS     IN NUMBER DEFAULT NULL
    ) IS

        L_FIRST      BOOLEAN := TRUE;
        L_FINISH     BOOLEAN := FALSE;
        L_SQL        VARCHAR2(32767);
        L_URL        VARCHAR2(500);
        L_CUR_ROWS   NUMBER;
        L_ROWS       NUMBER := 0;
    BEGIN
        LOAD(P_SERVICE_ID);
        START_TIMER;
        L_SQL := 'create table '
        || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME)
        || ' ( ';
        FOR I IN 1..G_SERVICE_COLUMN_MAPPINGS.COUNT LOOP
            L_SQL := L_SQL
            || G_SERVICE_COLUMN_MAPPINGS(I).COLUMN_NAME
            || ' ';
            IF
                G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE IN (
                    'DATE',
                    'NUMBER'
                )
            THEN
                L_SQL := L_SQL
                || G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE
                || ' ';
            ELSE
                L_SQL := L_SQL
                || G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE
                || '('
                || G_SERVICE_COLUMN_MAPPINGS(I).DATA_TYPE_LEN
                || ') ';
            END IF;

            IF
                I < G_SERVICE_COLUMN_MAPPINGS.COUNT
            THEN
                L_SQL := L_SQL
                || ', ';
            END IF;
        END LOOP;

        L_SQL := L_SQL
        || ')';
        EXECUTE IMMEDIATE L_SQL;
        LOG(G_SERVICE_DATA.ID,G_SERVICE_DATA.NAME,'TABLE_CREATE',NULL,NULL,NULL,GET_ELAPSED_TIME,NULL,P_TABLE_NAME);

        L_URL := NULL;
        WHILE NOT L_FINISH LOOP
            GRAB_DATA(P_SERVICE_ID => NULL,P_ENDPOINT_OVERRIDE => L_URL,P_REUSE_OAUTH => NOT L_FIRST);

            L_FIRST := FALSE;
            IF
                APEX_WEB_SERVICE.G_STATUS_CODE BETWEEN 400 AND 599
            THEN
                RAISE_APPLICATION_ERROR(-20000,'ERROR WHILE FETCHING DATA FROM REST SERVICE',TRUE);
            END IF;

            START_TIMER;
            L_SQL := 'insert into '
            || SYS.DBMS_ASSERT.ENQUOTE_NAME(P_TABLE_NAME)
            || ' ';
            L_SQL := L_SQL
            || '( select * from ('
            || GET_SQL_QUERY(P_MAX_COLUMNS => NULL)
            || ') '
            ||
                CASE
                    WHEN P_MAX_ROWS IS NOT NULL THEN 'where rownum <= '
                    || ( P_MAX_ROWS - L_ROWS )
                END
            || ')';

            EXECUTE IMMEDIATE L_SQL;
            L_CUR_ROWS := SQL%ROWCOUNT;
            LOG(G_SERVICE_DATA.ID,G_SERVICE_DATA.NAME,'TABLE_INSERT',NULL,NULL,NULL,GET_ELAPSED_TIME,NULL,L_CUR_ROWS
            || CASE
                WHEN L_CUR_ROWS = 1 THEN ' row.'
                ELSE ' rows.'
            END);

            L_ROWS := L_ROWS + L_CUR_ROWS;
            IF
                GET_ORDS_NEXTLINK IS NOT NULL AND ( P_MAX_ROWS IS NULL OR L_ROWS < P_MAX_ROWS )
            THEN
                L_URL := GET_ORDS_NEXTLINK;
            ELSE
                L_FINISH := TRUE;
            END IF;

        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            LOG(G_SERVICE_DATA.ID,G_SERVICE_DATA.NAME,'TABLE_LOAD',NULL,NULL,NULL,NULL,SQLCODE,SQLERRM);

            RAISE;
    END LOAD_INTO_TABLE;

    PROCEDURE HTP_PRINT_CLOB (
        P_CLOB     IN CLOB,
        P_ESCAPE   IN BOOLEAN DEFAULT FALSE
    ) IS
        L_POS   NUMBER := 1;
        L_CHK   NUMBER := 4000;
    BEGIN
        WHILE L_POS < DBMS_LOB.GETLENGTH(P_CLOB) LOOP
            IF
                P_ESCAPE
            THEN
                HTP.PRN(APEX_ESCAPE.HTML(DBMS_LOB.SUBSTR(P_CLOB,L_CHK,L_POS) ) );
            ELSE
                HTP.PRN(DBMS_LOB.SUBSTR(P_CLOB,L_CHK,L_POS) );
            END IF;

            L_POS := L_POS + L_CHK;
        END LOOP;
    END HTP_PRINT_CLOB;

    PROCEDURE LOG (
        P_SERVICE_ID        EBA_RESTDEMO_LOG.SERVICE_ID%TYPE,
        P_SERVICE_NAME      EBA_RESTDEMO_LOG.SERVICE_NAME%TYPE,
        P_ACTION            EBA_RESTDEMO_LOG.ACTION%TYPE,
        P_URL               EBA_RESTDEMO_LOG.URL%TYPE,
        P_RESPONSE_LENGTH   EBA_RESTDEMO_LOG.RESPONSE_LENGTH%TYPE,
        P_RESPONSE_STATUS   EBA_RESTDEMO_LOG.RESPONSE_STATUS%TYPE,
        P_ELAPSED_TIME      EBA_RESTDEMO_LOG.ELAPSED_TIME%TYPE,
        P_ERROR_CODE        EBA_RESTDEMO_LOG.ERROR_CODE%TYPE,
        P_MESSAGE           EBA_RESTDEMO_LOG.MESSAGE%TYPE
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO EBA_RESTDEMO_LOG (
            SERVICE_ID,
            SERVICE_NAME,
            ACTION,
            URL,
            RESPONSE_LENGTH,
            RESPONSE_STATUS,
            ELAPSED_TIME,
            ERROR_CODE,
            MESSAGE,
            USERNAME
        ) VALUES (
            P_SERVICE_ID,
            P_SERVICE_NAME,
            P_ACTION,
            P_URL,
            P_RESPONSE_LENGTH,
            P_RESPONSE_STATUS,
            P_ELAPSED_TIME,
            P_ERROR_CODE,
            P_MESSAGE,
            NVL(WWV_FLOW.G_USER,USER)
        );

        COMMIT;
    END LOG;

END EBA_RESTDEMO_HELPER;
/

