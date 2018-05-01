--
-- UTILS_PKG  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.UTILS_PKG AS

    FUNCTION GET_TABLES_ISSUES RETURN T_TABLES_ISSUES
        PIPELINED
    IS
        NEW_LINE   T_TABLE_ISSUE;
    BEGIN
        FOR R IN (
            SELECT
                TABLE_NAME
            FROM
                USER_TABLES T
            WHERE
                (
                    T.TABLE_NAME NOT LIKE 'DAT%'
                    AND   T.TABLE_NAME NOT LIKE 'DEMO%'
                )
                AND   NOT EXISTS (
                    SELECT
                        NULL
                    FROM
                        USER_TAB_COLUMNS C
                    WHERE
                        C.TABLE_NAME = T.TABLE_NAME
                        AND   (
                            C.COLUMN_NAME LIKE '%PLAN%'
                            OR    C.COLUMN_NAME LIKE '%CLIENT%'
                        )
                )
        ) LOOP
            NEW_LINE.TABLE_NAME := R.TABLE_NAME;
            NEW_LINE.PROBLEM := 'This table doesn''t have columns PLAN or CLIENT';
            PIPE ROW ( NEW_LINE );
        END LOOP;

        FOR R IN (
            SELECT
                TABLE_NAME,
                COLUMN_NAME
            FROM
                USER_TAB_COLUMNS C
            WHERE
                (
                    C.TABLE_NAME NOT LIKE 'DAT%'
                    AND   C.TABLE_NAME NOT LIKE 'DEMO%'
                )
                AND   (
                    C.COLUMN_NAME LIKE '%PLAN%'
                    OR    C.COLUMN_NAME LIKE '%CLIENT%'
                )
                AND   C.NUM_DISTINCT = 0
            GROUP BY
                TABLE_NAME,
                COLUMN_NAME
        ) LOOP
            NEW_LINE.TABLE_NAME := R.TABLE_NAME;
            NEW_LINE.PROBLEM := 'This table has the PLAN or CLIENT columns but contains ONLY null values in at least one of these columns';
            PIPE ROW ( NEW_LINE );
        END LOOP;

    END GET_TABLES_ISSUES;

    FUNCTION GET_ITEMS_ISSUES RETURN T_ITEMS_ISSUES
        PIPELINED
    IS
        NEW_LINE   T_ITEM_ISSUE;
    BEGIN
        FOR R IN (
            SELECT
                I.APPLICATION_ID,
                I.APPLICATION_NAME,
                I.PAGE_ID,
                PAGE_NAME,
                I.ITEM_ID,
                I.ITEM_NAME,
                I.LOV_DEFINITION
            FROM
                APEX_APPLICATION_PAGE_ITEMS I,
                APEX_APPLICATIONS A
            WHERE
                A.OWNER NOT LIKE 'APEX%'
                AND   I.WORKSPACE = A.WORKSPACE
                AND   I.APPLICATION_ID = A.APPLICATION_ID
                AND   LOWER(I.LOV_DEFINITION) LIKE 'select%'
                AND   (
                    LOWER(I.LOV_DEFINITION) NOT LIKE '%plan%'
                    OR    LOWER(I.LOV_DEFINITION) NOT LIKE '%client%'
                )
        ) LOOP
            NEW_LINE.APPLICATION_ID := R.APPLICATION_ID;
            NEW_LINE.APPLICATION_NAME := R.APPLICATION_NAME;
            NEW_LINE.PAGE_ID := R.PAGE_ID;
            NEW_LINE.PAGE_NAME := R.PAGE_NAME;
            NEW_LINE.ITEM_ID := R.ITEM_ID;
            NEW_LINE.ITEM_NAME := R.ITEM_NAME;
            NEW_LINE.PROBLEM := 'This apex ITEM has embedded sql query without the PLAN or CLIENT columns.';
            NEW_LINE.SQL_CLAUSE := R.LOV_DEFINITION;
            PIPE ROW ( NEW_LINE );
        END LOOP;

        FOR R IN (
            SELECT
                L.APPLICATION_ID,
                L.APPLICATION_NAME,
                L.LOV_ID,
                L.LIST_OF_VALUES_NAME,
                L.LIST_OF_VALUES_QUERY
            FROM
                APEX_APPLICATION_LOVS L,
                APEX_APPLICATIONS A
            WHERE
                A.OWNER NOT LIKE 'APEX%'
                AND   L.WORKSPACE = A.WORKSPACE
                AND   L.APPLICATION_ID = A.APPLICATION_ID
                AND   L.LOV_TYPE = 'Dynamic'
                AND   (
                    LOWER(L.LIST_OF_VALUES_QUERY) NOT LIKE '%plan%'
                    OR    LOWER(L.LIST_OF_VALUES_QUERY) NOT LIKE '%client%'
                )
        ) LOOP
            NEW_LINE.APPLICATION_ID := R.APPLICATION_ID;
            NEW_LINE.APPLICATION_NAME := R.APPLICATION_NAME;
            NEW_LINE.PAGE_ID := '';
            NEW_LINE.PAGE_NAME := '';
            NEW_LINE.ITEM_ID := R.LOV_ID;
            NEW_LINE.ITEM_NAME := R.LIST_OF_VALUES_NAME;
            NEW_LINE.PROBLEM := 'This apex SHARED LOV has sql query without the PLAN or CLIENT columns';
            NEW_LINE.SQL_CLAUSE := R.LIST_OF_VALUES_QUERY;
            PIPE ROW ( NEW_LINE );
        END LOOP;

    END GET_ITEMS_ISSUES;

    FUNCTION GET_PAGES_RARELY_UPDATED RETURN T_PAGES_RARELY_UPDATED
        PIPELINED
    IS
        NEW_LINE   T_PAGE_LAST_UPDATE;
    BEGIN
        FOR R IN (
            SELECT
                P.APPLICATION_ID,
                P.APPLICATION_NAME,
                P.PAGE_ID,
                P.PAGE_NAME,
                P.LAST_UPDATED_ON,
                P.LAST_UPDATED_BY
            FROM
                APEX_APPLICATION_PAGES P,
                APEX_APPLICATIONS A
            WHERE
                A.OWNER NOT LIKE 'APEX%'
                AND   P.WORKSPACE = A.WORKSPACE
                AND   P.APPLICATION_ID = A.APPLICATION_ID
                AND   P.LAST_UPDATED_ON < SYSDATE - 90
        ) LOOP
            NEW_LINE.APPLICATION_ID := R.APPLICATION_ID;
            NEW_LINE.APPLICATION_NAME := R.APPLICATION_NAME;
            NEW_LINE.PAGE_ID := R.PAGE_ID;
            NEW_LINE.PAGE_NAME := R.PAGE_NAME;
            NEW_LINE.DAYS_SINCE_LAST_UPDATE := TRUNC(SYSDATE - R.LAST_UPDATED_ON);
            NEW_LINE.LAST_UPDATED_ON := R.LAST_UPDATED_ON;
            NEW_LINE.LAST_UPDATED_BY := R.LAST_UPDATED_BY;
            PIPE ROW ( NEW_LINE );
        END LOOP;
    END GET_PAGES_RARELY_UPDATED;

    PROCEDURE UPDATE_MEMBERS_LOCATION IS
        JSON   CLOB;
        GLAT   VARCHAR2(255);
        GLNG   VARCHAR2(255);
    BEGIN
        FOR M IN (
            SELECT
                ROWID, --replace(replace(mem_address1 || '+' || mem_city || '+' || mem_prov || '+' || mem_country, ' ', '+'), ',', '+') address,
                MEM_POSTAL_CODE ADDRESS
            FROM
                TBL_MEMBER_LOCATION
            WHERE
                (
                    TRIM(LAT) IS NULL
                    OR   TRIM(LNG) IS NULL
                )
        ) LOOP
            BEGIN
                JSON := UTL_HTTP.REQUEST('https://maps.googleapis.com/maps/api/geocode/json?address='
                || M.ADDRESS
                || '&key=AIzaSyATnEtCKm1HXc18Du3RfJS8x9Bu2LU7S4A',NULL,'file:C:\app\rao\product\12.1.0\dbhome_1\wallet','WalletPasswd123');
      
        --dbms_output.put_line(m.address || '=>' || json);

                SELECT
                    JSON_VALUE(JSON,'$.results.geometry.location.lat'),
                    JSON_VALUE(JSON,'$.results.geometry.location.lng')
                INTO
                    GLAT,GLNG
                FROM
                    DUAL;

                IF
                    GLAT IS NOT NULL AND GLNG IS NOT NULL
                THEN
                    UPDATE TBL_MEMBER_LOCATION
                        SET
                            LAT = GLAT,
                            LNG = GLNG,
                            RSP = NULL
                    WHERE
                        ROWID = M.ROWID;

                    COMMIT;
                ELSE
                    UPDATE TBL_MEMBER_LOCATION
                        SET
                            RSP = JSON
                    WHERE
                        ROWID = M.ROWID;

                    COMMIT;
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    JSON := SQLERRM;
                    UPDATE TBL_MEMBER_LOCATION
                        SET
                            RSP = JSON
                    WHERE
                        ROWID = M.ROWID;

                    COMMIT;
            END;
        END LOOP;
    END UPDATE_MEMBERS_LOCATION;

    FUNCTION GET_CLOB_LENGTH (
        P_CLOB IN CLOB
    ) RETURN NUMBER AS

        V_TEMP_BLOB     BLOB;
        V_DEST_OFFSET   NUMBER := 1;
        V_SRC_OFFSET    NUMBER := 1;
        V_AMOUNT        INTEGER := DBMS_LOB.LOBMAXSIZE;
        V_BLOB_CSID     NUMBER := DBMS_LOB.DEFAULT_CSID;
        V_LANG_CTX      INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
        V_WARNING       INTEGER;
        V_TOTAL_SIZE    NUMBER := 0;
    BEGIN
        IF
            P_CLOB IS NOT NULL
        THEN
            DBMS_LOB.CREATETEMPORARY(LOB_LOC => V_TEMP_BLOB,CACHE => TRUE);
            DBMS_LOB.CONVERTTOBLOB(V_TEMP_BLOB,P_CLOB,V_AMOUNT,V_DEST_OFFSET,V_SRC_OFFSET,V_BLOB_CSID,V_LANG_CTX,V_WARNING);

            V_TOTAL_SIZE := DBMS_LOB.GETLENGTH(V_TEMP_BLOB);
            DBMS_LOB.FREETEMPORARY(V_TEMP_BLOB);
        ELSE
            V_TOTAL_SIZE := NULL;
        END IF;

        RETURN V_TOTAL_SIZE;
    END GET_CLOB_LENGTH;

    PROCEDURE APEX_BACKUP_JOB IS
        BKP   CLOB;
    BEGIN
    -- purge backups older than 30 days
        DELETE FROM APEX_APPLICATION_BACKUP
        WHERE
            BACKUP_ON < SYSDATE - 30;

        FOR B IN (
            SELECT
                DESCRIPTION,
                APP_ID,
                PAGE_ID
            FROM
                APEX_BACKUP_SCHEDULE
            WHERE
                ACTIVE = 'Y'
                AND   EXISTS (
                    SELECT
                        NULL
                    FROM
                        APEX_APPLICATIONS
                    WHERE
                        APPLICATION_ID = APP_ID
                )
        ) LOOP
            IF
                B.PAGE_ID IS NULL
            THEN
                BEGIN
                    BKP := WWV_FLOW_UTILITIES.EXPORT_APPLICATION_TO_CLOB(B.APP_ID);
                    INSERT INTO APEX_APPLICATION_BACKUP (
                        DESCRIPTION,
                        APP_ID,
                        BACKUP_ON,
                        APP_BACKUP,
                        APP_BACKUP_SIZE
                    ) VALUES (
                        B.DESCRIPTION,
                        B.APP_ID,
                        SYSDATE,
                        BKP,
                        TO_CHAR(GET_CLOB_LENGTH(BKP) / 1024 / 1024,'FM999G999G990D00')
                        || 'mb'
                    );

                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
                END;

            ELSE
                BEGIN
                    BKP := WWV_FLOW_UTILITIES.EXPORT_PAGE_TO_CLOB(B.APP_ID,B.PAGE_ID);
                    INSERT INTO APEX_APPLICATION_BACKUP (
                        DESCRIPTION,
                        APP_ID,
                        PAGE_ID,
                        BACKUP_ON,
                        APP_BACKUP,
                        APP_BACKUP_SIZE
                    ) VALUES (
                        B.DESCRIPTION,
                        B.APP_ID,
                        B.PAGE_ID,
                        SYSDATE,
                        BKP,
                        TO_CHAR(GET_CLOB_LENGTH(BKP) / 1024 / 1024,'FM999G999G990D00')
                        || 'mb'
                    );

                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
                END;
            END IF;
        END LOOP;

    END APEX_BACKUP_JOB;

    PROCEDURE CREATE_APEX_SESSION (
        P_APP_ID        VARCHAR2,
        P_APP_USER      NUMBER,
        P_APP_PAGE_ID   NUMBER DEFAULT 1
    ) AS
        L_WORKSPACE_ID   APEX_APPLICATIONS.WORKSPACE_ID%TYPE;
        L_CGIVAR_NAME    OWA.VC_ARR;
        L_CGIVAR_VAL     OWA.VC_ARR;
    BEGIN
        HTP.INIT;
        L_CGIVAR_NAME(1) := 'REQUEST_PROTOCOL';
        L_CGIVAR_VAL(1) := 'HTTP';
        OWA.INIT_CGI_ENV(NUM_PARAMS => 1,PARAM_NAME => L_CGIVAR_NAME,PARAM_VAL => L_CGIVAR_VAL);

        SELECT
            WORKSPACE_ID
        INTO
            L_WORKSPACE_ID
        FROM
            APEX_APPLICATIONS
        WHERE
            APPLICATION_ID = P_APP_ID;

        WWV_FLOW_API.SET_SECURITY_GROUP_ID(L_WORKSPACE_ID);
        APEX_APPLICATION.G_INSTANCE := 1;
        APEX_APPLICATION.G_FLOW_ID := P_APP_ID;
        APEX_APPLICATION.G_FLOW_STEP_ID := P_APP_PAGE_ID;
        APEX_CUSTOM_AUTH.POST_LOGIN(P_UNAME => P_APP_USER,P_SESSION_ID => NULL, -- could use apex_custom_auth.get_next_session_id
        P_APP_PAGE => APEX_APPLICATION.G_FLOW_ID
        || ':'
        || P_APP_PAGE_ID);

    END;

    PROCEDURE DELETE_APEX_SESSION (
        P_APP_ID NUMBER
    )
        IS
    BEGIN
        APEX_UTIL.CLEAR_APP_CACHE(P_APP_ID);
    END DELETE_APEX_SESSION;

    FUNCTION GET_NON_REFERENCED_PAGES (
        P_APP_ID NUMBER
    ) RETURN T_PAGES
        PIPELINED
    IS
        L_PAGE   T_PAGE;
    BEGIN
        FOR P IN (
            SELECT
                PAGE_ID,
                PAGE_NAME
            FROM
                APEX_APPLICATION_PAGES
            WHERE
                APPLICATION_ID = P_APP_ID
        ) LOOP
            L_PAGE.PAGE_ID := P.PAGE_ID;
            L_PAGE.PAGE_NAME := P.PAGE_NAME;
            PIPE ROW ( L_PAGE );
        END LOOP;
    END GET_NON_REFERENCED_PAGES;

    PROCEDURE HTP_PRN (
        PCLOB IN OUT NOCOPY CLOB
    ) IS
        V_EXCEL   VARCHAR2(32000);
        V_CLOB    CLOB := PCLOB;
    BEGIN
        WHILE LENGTH(V_CLOB) > 0 LOOP
            BEGIN
                IF
                    LENGTH(V_CLOB) > 16000
                THEN
                    V_EXCEL := SUBSTR(V_CLOB,1,16000);
                    HTP.PRN(V_EXCEL);
                    V_CLOB := SUBSTR(V_CLOB,LENGTH(V_EXCEL) + 1);
                ELSE
                    V_EXCEL := V_CLOB;
                    HTP.PRN(V_EXCEL);
                    V_CLOB := '';
                    V_EXCEL := '';
                END IF;

            END;
        END LOOP;
    END HTP_PRN;

    FUNCTION CHAR_2_DATE (
        P_DATE VARCHAR2
    ) RETURN DATE IS

        TYPE T_FORMAT IS
            TABLE OF VARCHAR2(255);
        L_FORMATS   T_FORMAT := T_FORMAT('DD-MON-RRRR','DD/MON/RRRR','DD-MM-RRRR','DD/MM/RRRR','MON-DD-RRRR','MON/DD/RRRR','MM-DD-RRRR','MON/DD/RRRR'
);
    BEGIN
        IF
            TRIM(P_DATE) IS NULL
        THEN
            RETURN NULL;
        END IF;
        FOR I IN 1..L_FORMATS.COUNT LOOP
            BEGIN
                RETURN TO_DATE(UPPER(P_DATE),L_FORMATS(I) );
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
        END LOOP;

        RETURN NULL;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END CHAR_2_DATE;

    FUNCTION CHAR_2_TIME (
        P_TIME VARCHAR2
    ) RETURN NUMBER IS

        TYPE T_FORMAT IS
            TABLE OF VARCHAR2(255);
        L_FORMATS   T_FORMAT := T_FORMAT('HH24:MI:SS','HH:MI:SS PM','HH24:MI','HH:MI PM');
        L_DATE      DATE;
    BEGIN
        IF
            TRIM(P_TIME) IS NULL
        THEN
            RETURN NULL;
        END IF;
        FOR I IN 1..L_FORMATS.COUNT LOOP
            BEGIN
                L_DATE := TO_DATE(UPPER(P_TIME),L_FORMATS(I) );
                RETURN L_DATE - TRUNC(L_DATE);
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
        END LOOP;

        RETURN NULL;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END CHAR_2_TIME;

    FUNCTION CHAR_2_DATETIME (
        P_DATETIME VARCHAR2
    ) RETURN DATE IS
        L_DATETIME   DATE;
        L_DATE       VARCHAR2(255);
        L_TIME       VARCHAR2(255);
        L_SPLIT      PLS_INTEGER;
    BEGIN
        IF
            TRIM(P_DATETIME) IS NULL
        THEN
            RETURN NULL;
        END IF;
        L_SPLIT := INSTR(P_DATETIME,' ');
        IF
            L_SPLIT > 0
        THEN
            L_DATE := SUBSTR(P_DATETIME,1,L_SPLIT);
            L_DATETIME := CHAR_2_DATE(L_DATE);
            L_TIME := SUBSTR(P_DATETIME,L_SPLIT + 1);
            L_DATETIME := L_DATETIME + NVL(CHAR_2_TIME(L_TIME),0);
        ELSE
            L_DATETIME := CHAR_2_DATE(P_DATETIME);
        END IF;

        RETURN L_DATETIME;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END CHAR_2_DATETIME;

END UTILS_PKG;
/

