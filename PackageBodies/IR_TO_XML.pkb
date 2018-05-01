--
-- IR_TO_XML  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.IR_TO_XML AS   
/*
** Minor bugfixes by J.P.Lourens  9-Oct-2016
*/

    SUBTYPE LARGEVARCHAR2 IS VARCHAR2(32767);
    CURSOR CUR_HIGHLIGHT (
        P_REPORT_ID                 IN APEX_APPLICATION_PAGE_IR_RPT.REPORT_ID%TYPE,
        P_DELIMETERED_COLUMN_LIST   IN VARCHAR2
    ) IS SELECT
        REZ.*,
        ROWNUM COND_NUMBER,
        'HIGHLIGHT_'
        || ROWNUM COND_NAME
         FROM
        (
            SELECT
                REPORT_ID,
                CASE
                        WHEN CONDITION_OPERATOR IN (
                            'not in',
                            'in'
                        ) THEN GET_HIGHLIGHT_IN_COND_SQL(CONDITION_EXPRESSION,CONDITION_SQL,CONDITION_COLUMN_NAME)
                        ELSE REPLACE(REPLACE(REPLACE(REPLACE(CONDITION_SQL,'#APXWS_EXPR#',''''
                        || CONDITION_EXPRESSION
                        || ''''),'#APXWS_EXPR2#',''''
                        || CONDITION_EXPRESSION2
                        || ''''),'#APXWS_HL_ID#','1'),'#APXWS_CC_EXPR#','"'
                        || CONDITION_COLUMN_NAME
                        || '"')
                    END
                CONDITION_SQL,
                CONDITION_COLUMN_NAME,
                CONDITION_ENABLED,
                HIGHLIGHT_ROW_COLOR,
                HIGHLIGHT_ROW_FONT_COLOR,
                HIGHLIGHT_CELL_COLOR,
                HIGHLIGHT_CELL_FONT_COLOR
            FROM
                APEX_APPLICATION_PAGE_IR_COND
            WHERE
                CONDITION_TYPE = 'Highlight'
                AND   REPORT_ID = P_REPORT_ID
                AND   INSTR(':'
                || P_DELIMETERED_COLUMN_LIST
                || ':',':'
                || CONDITION_COLUMN_NAME
                || ':') > 0
                AND   CONDITION_ENABLED = 'Yes'
            ORDER BY --rows highlights first 
                NVL2(HIGHLIGHT_ROW_COLOR,1,0) DESC,
                NVL2(HIGHLIGHT_ROW_FONT_COLOR,1,0) DESC,
                HIGHLIGHT_SEQUENCE
        ) REZ;

    TYPE T_COL_NAMES IS
        TABLE OF APEX_APPLICATION_PAGE_IR_COL.REPORT_LABEL%TYPE INDEX BY APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE;
    TYPE T_COL_FORMAT_MASK IS
        TABLE OF APEX_APPLICATION_PAGE_IR_COMP.COMPUTATION_FORMAT_MASK%TYPE INDEX BY APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE;
    TYPE T_HEADER_ALIGNMENT IS
        TABLE OF APEX_APPLICATION_PAGE_IR_COL.HEADING_ALIGNMENT%TYPE INDEX BY APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE;
    TYPE T_COLUMN_ALIGNMENT IS
        TABLE OF APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIGNMENT%TYPE INDEX BY APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE;
    TYPE T_COLUMN_TYPES IS
        TABLE OF APEX_APPLICATION_PAGE_IR_COL.COLUMN_TYPE%TYPE INDEX BY APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE;
    TYPE T_HIGHLIGHT IS
        TABLE OF CUR_HIGHLIGHT%ROWTYPE INDEX BY BINARY_INTEGER;
    TYPE IR_REPORT IS RECORD ( REPORT                      APEX_IR.T_REPORT,
    IR_DATA                     APEX_APPLICATION_PAGE_IR_RPT%ROWTYPE,
    DISPLAYED_COLUMNS           APEX_APPLICATION_GLOBAL.VC_ARR2,
    BREAK_ON                    APEX_APPLICATION_GLOBAL.VC_ARR2,
    BREAK_REALLY_ON             APEX_APPLICATION_GLOBAL.VC_ARR2, -- "break on" except hidden columns
    SUM_COLUMNS_ON_BREAK        APEX_APPLICATION_GLOBAL.VC_ARR2,
    AVG_COLUMNS_ON_BREAK        APEX_APPLICATION_GLOBAL.VC_ARR2,
    MAX_COLUMNS_ON_BREAK        APEX_APPLICATION_GLOBAL.VC_ARR2,
    MIN_COLUMNS_ON_BREAK        APEX_APPLICATION_GLOBAL.VC_ARR2,
    MEDIAN_COLUMNS_ON_BREAK     APEX_APPLICATION_GLOBAL.VC_ARR2,
    COUNT_COLUMNS_ON_BREAK      APEX_APPLICATION_GLOBAL.VC_ARR2,
    COUNT_DISTNT_COL_ON_BREAK   APEX_APPLICATION_GLOBAL.VC_ARR2,
    SKIPPED_COLUMNS             BINARY_INTEGER DEFAULT 0, -- when scpecial coluns like apxws_row_pk is used
    START_WITH                  BINARY_INTEGER DEFAULT 0, -- position of first displayed column in query
    END_WITH                    BINARY_INTEGER DEFAULT 0, -- position of last displayed column in query    
    AGG_COLS_CNT                BINARY_INTEGER DEFAULT 0,
    HIDDEN_COLS_CNT             BINARY_INTEGER DEFAULT 0,
    COLUMN_NAMES                T_COL_NAMES,       -- column names in report header
    COL_FORMAT_MASK             T_COL_FORMAT_MASK, -- format like $3849,56
    ROW_HIGHLIGHT               T_HIGHLIGHT,
    COL_HIGHLIGHT               T_HIGHLIGHT,
    HEADER_ALIGNMENT            T_HEADER_ALIGNMENT,
    COLUMN_ALIGNMENT            T_COLUMN_ALIGNMENT,
    COLUMN_TYPES                T_COLUMN_TYPES );
    TYPE T_CELL_DATA IS RECORD ( VALUE                       VARCHAR2(100),
    TEXT                        LARGEVARCHAR2,
    DATATYPE                    VARCHAR2(50) );
    L_REPORT                    IR_REPORT;
    V_DEBUG                     CLOB;
    V_DEBUG_BUFFER              LARGEVARCHAR2;
    V_DEFAULT_DATE_NLS          VARCHAR2(50); 
  ------------------------------------------------------------------------------
  /**
  * http://mk-commi.blogspot.co.at/2014/11/concatenating-varchar2-values-into-clob.html  
  
  * Procedure concatenates a VARCHAR2 to a CLOB.
  * It uses another VARCHAR2 as a buffer until it reaches 32767 characters.
  * Then it flushes the current buffer to the CLOB and resets the buffer using
  * the actual VARCHAR2 to add.
  * Your final call needs to be done setting p_eof to TRUE in order to
  * flush everything to the CLOB.
  *
  * @param p_clob        The CLOB buffer.
  * @param p_vc_buffer   The intermediate VARCHAR2 buffer. (must be VARCHAR2(32767))
  * @param p_vc_addition The VARCHAR2 value you want to append.
  * @param p_eof         Indicates if complete buffer should be flushed to CLOB.
  */

    PROCEDURE ADD (
        P_CLOB          IN OUT NOCOPY CLOB,
        P_VC_BUFFER     IN OUT NOCOPY VARCHAR2,
        P_VC_ADDITION   IN VARCHAR2,
        P_EOF           IN BOOLEAN DEFAULT FALSE
    )
        AS
    BEGIN
     
    -- Standard Flow
        IF
            NVL(LENGTHB(P_VC_BUFFER),0) + NVL(LENGTHB(P_VC_ADDITION),0) < 32767
        THEN
            P_VC_BUFFER := P_VC_BUFFER
            || P_VC_ADDITION;
        ELSE
            IF
                P_CLOB IS NULL
            THEN
                DBMS_LOB.CREATETEMPORARY(P_CLOB,TRUE);
            END IF;
            DBMS_LOB.WRITEAPPEND(P_CLOB,LENGTH(P_VC_BUFFER),P_VC_BUFFER);
            P_VC_BUFFER := P_VC_ADDITION;
        END IF;
     
    -- Full Flush requested

        IF
            P_EOF
        THEN
            IF
                P_CLOB IS NULL
            THEN
                P_CLOB := P_VC_BUFFER;
            ELSE
                DBMS_LOB.WRITEAPPEND(P_CLOB,LENGTH(P_VC_BUFFER),P_VC_BUFFER);
            END IF;

            P_VC_BUFFER := NULL;
        END IF;

    END ADD;
  ------------------------------------------------------------------------------

    PROCEDURE LOG (
        P_MESSAGE   IN VARCHAR2,
        P_EOF       IN BOOLEAN DEFAULT FALSE
    )
        IS
    BEGIN
        ADD(V_DEBUG,V_DEBUG_BUFFER,P_MESSAGE
        || CHR(10),P_EOF);
        APEX_DEBUG_MESSAGE.LOG_MESSAGE(P_MESSAGE => SUBSTR(P_MESSAGE,1,32767),P_ENABLED => FALSE,P_LEVEL => 4);

    END LOG; 
  ------------------------------------------------------------------------------

    FUNCTION GET_LOG RETURN CLOB
        IS
    BEGIN
        LOG('LogFinish',TRUE);
        RETURN V_DEBUG;
    END GET_LOG; 
  ------------------------------------------------------------------------------

    FUNCTION BCOLL (
        P_FONT_COLOR     IN VARCHAR2 DEFAULT NULL,
        P_BACK_COLOR     IN VARCHAR2 DEFAULT NULL,
        P_ALIGN          IN VARCHAR2 DEFAULT NULL,
        P_WIDTH          IN VARCHAR2 DEFAULT NULL,
        P_COLUMN_ALIAS   IN VARCHAR2 DEFAULT NULL,
        P_COLMN_TYPE     IN VARCHAR2 DEFAULT NULL,
        P_VALUE          IN VARCHAR2 DEFAULT NULL,
        P_FORMAT_MASK    IN VARCHAR2 DEFAULT NULL,
        P_HEADER_ALIGN   IN VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 IS
        V_STR   VARCHAR2(500);
    BEGIN
        V_STR := V_STR
        || '<CELL ';
        IF
            P_COLUMN_ALIAS IS NOT NULL
        THEN
            V_STR := V_STR
            || 'column-alias="'
            || P_COLUMN_ALIAS
            || '" ';
        END IF;

        IF
            P_FONT_COLOR IS NOT NULL
        THEN
            V_STR := V_STR
            || 'color="'
            || P_FONT_COLOR
            || '" ';
        END IF;

        IF
            P_COLMN_TYPE IS NOT NULL
        THEN
            V_STR := V_STR
            || 'data-type="'
            || P_COLMN_TYPE
            || '" ';
        END IF;

        IF
            P_BACK_COLOR IS NOT NULL
        THEN
            V_STR := V_STR
            || 'background-color="'
            || P_BACK_COLOR
            || '" ';
        END IF;

        IF
            P_ALIGN IS NOT NULL
        THEN
            V_STR := V_STR
            || 'align="'
            || LOWER(P_ALIGN)
            || '" ';
        END IF;

        IF
            P_WIDTH IS NOT NULL
        THEN
            V_STR := V_STR
            || 'width="'
            || P_WIDTH
            || '" ';
        END IF;

        IF
            P_VALUE IS NOT NULL
        THEN
            V_STR := V_STR
            || 'value="'
            || P_VALUE
            || '" ';
        END IF;

        IF
            P_FORMAT_MASK IS NOT NULL
        THEN
            V_STR := V_STR
            || 'format_mask="'
            || P_FORMAT_MASK
            || '" ';
        END IF;

        IF
            P_HEADER_ALIGN IS NOT NULL
        THEN
            V_STR := V_STR
            || 'header_align="'
            || LOWER(P_HEADER_ALIGN)
            || '" ';
        END IF;

        V_STR := V_STR
        || '>';
        RETURN V_STR;
    END BCOLL;
  ------------------------------------------------------------------------------

    FUNCTION ECOLL (
        I BINARY_INTEGER
    ) RETURN VARCHAR2
        IS
    BEGIN
        RETURN '</CELL>';
    END ECOLL;
    ------------------------------------------------------------------------------

    FUNCTION GET_COLUMN_NAMES (
        P_COLUMN_ALIAS   IN APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE
    ) RETURN APEX_APPLICATION_PAGE_IR_COL.REPORT_LABEL%TYPE
        IS
    BEGIN
        RETURN L_REPORT.COLUMN_NAMES(P_COLUMN_ALIAS);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'get_column_names: p_column_alias='
            || P_COLUMN_ALIAS
            || ' '
            || SQLERRM);
    END GET_COLUMN_NAMES;
  ------------------------------------------------------------------------------

    FUNCTION GET_COL_FORMAT_MASK (
        P_COLUMN_ALIAS   IN APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE
    ) RETURN APEX_APPLICATION_PAGE_IR_COMP.COMPUTATION_FORMAT_MASK%TYPE
        IS
    BEGIN
        RETURN REPLACE(L_REPORT.COL_FORMAT_MASK(P_COLUMN_ALIAS),'"','');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'get_column_names: p_column_alias='
            || P_COLUMN_ALIAS
            || ' '
            || SQLERRM);
    END GET_COL_FORMAT_MASK;
  ------------------------------------------------------------------------------

    FUNCTION GET_HEADER_ALIGNMENT (
        P_COLUMN_ALIAS   IN APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE
    ) RETURN APEX_APPLICATION_PAGE_IR_COL.HEADING_ALIGNMENT%TYPE
        IS
    BEGIN
        RETURN L_REPORT.HEADER_ALIGNMENT(P_COLUMN_ALIAS);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'get_column_names: p_column_alias='
            || P_COLUMN_ALIAS
            || ' '
            || SQLERRM);
    END GET_HEADER_ALIGNMENT;
  ------------------------------------------------------------------------------

    FUNCTION GET_COLUMN_ALIGNMENT (
        P_COLUMN_ALIAS   IN APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE
    ) RETURN APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIGNMENT%TYPE
        IS
    BEGIN
        RETURN L_REPORT.COLUMN_ALIGNMENT(P_COLUMN_ALIAS);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'get_column_names: p_column_alias='
            || P_COLUMN_ALIAS
            || ' '
            || SQLERRM);
    END GET_COLUMN_ALIGNMENT;
  ------------------------------------------------------------------------------

    FUNCTION GET_COLUMN_TYPES (
        P_COLUMN_ALIAS   IN APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE
    ) RETURN APEX_APPLICATION_PAGE_IR_COL.COLUMN_TYPE%TYPE
        IS
    BEGIN
        RETURN L_REPORT.COLUMN_TYPES(P_COLUMN_ALIAS);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'get_column_names: p_column_alias='
            || P_COLUMN_ALIAS
            || ' '
            || SQLERRM);
    END GET_COLUMN_TYPES;
  ------------------------------------------------------------------------------  

    FUNCTION GET_COLUMN_ALIAS (
        P_NUM IN BINARY_INTEGER
    ) RETURN VARCHAR2
        IS
    BEGIN
        RETURN L_REPORT.DISPLAYED_COLUMNS(P_NUM);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'get_column_alias: p_num='
            || P_NUM
            || ' '
            || SQLERRM);
    END GET_COLUMN_ALIAS;
  ------------------------------------------------------------------------------

    FUNCTION GET_COLUMN_ALIAS_SQL (
        P_NUM IN BINARY_INTEGER -- column number in sql-query
    ) RETURN VARCHAR2
        IS
    BEGIN
        RETURN L_REPORT.DISPLAYED_COLUMNS(P_NUM - L_REPORT.START_WITH + 1);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'get_column_alias_sql: p_num='
            || P_NUM
            || ' '
            || SQLERRM);
    END GET_COLUMN_ALIAS_SQL;
  ------------------------------------------------------------------------------

    FUNCTION GET_CURRENT_ROW (
        P_CURRENT_ROW   IN APEX_APPLICATION_GLOBAL.VC_ARR2,
        P_ID            IN BINARY_INTEGER
    ) RETURN LARGEVARCHAR2
        IS
    BEGIN
        RETURN P_CURRENT_ROW(P_ID);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'get_current_row: p_id='
            || P_ID
            || ' '
            || SQLERRM);
    END GET_CURRENT_ROW; 
  ------------------------------------------------------------------------------
  -- :::: -> :

    FUNCTION RR (
        P_STR IN VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        RETURN LTRIM(RTRIM(REGEXP_REPLACE(P_STR,'[:]+',':'),':'),':');
    END;
  ------------------------------------------------------------------------------   

    FUNCTION GET_XMLVAL (
        P_STR IN VARCHAR2
    ) RETURN VARCHAR2 IS
        V_TMP   LARGEVARCHAR2;
    BEGIN
    -- p_str can be encoded html-string 
    -- wee need forst convert to text
        V_TMP := REGEXP_REPLACE(P_STR,'<(BR)\s*/*>',CHR(13)
        || CHR(10),1,0,'i');

        V_TMP := REGEXP_REPLACE(V_TMP,'<[^<>]+>',' ',1,0,'i');
        V_TMP := UTL_I18N.UNESCAPE_REFERENCE(V_TMP); 
    -- and finally encode them
        V_TMP := SUBSTR(V_TMP,1,2000);
        V_TMP := UTL_I18N.ESCAPE_REFERENCE(V_TMP,'UTF8');
        RETURN V_TMP;
    END GET_XMLVAL;  
  ------------------------------------------------------------------------------

    FUNCTION INTERSECT_ARRAYS (
        P_ONE   IN APEX_APPLICATION_GLOBAL.VC_ARR2,
        P_TWO   IN APEX_APPLICATION_GLOBAL.VC_ARR2
    ) RETURN APEX_APPLICATION_GLOBAL.VC_ARR2 IS
        V_RET   APEX_APPLICATION_GLOBAL.VC_ARR2;
    BEGIN
        FOR I IN 1..P_ONE.COUNT LOOP
            FOR B IN 1..P_TWO.COUNT LOOP
                IF
                    P_ONE(I) = P_TWO(B)
                THEN
                    V_RET(V_RET.COUNT + 1) := P_ONE(I);
                    EXIT;
                END IF;
            END LOOP;
        END LOOP;

        RETURN V_RET;
    END INTERSECT_ARRAYS;
  ------------------------------------------------------------------------------

    FUNCTION GET_QUERY_COLUMN_LIST RETURN APEX_APPLICATION_GLOBAL.VC_ARR2 IS
        V_CUR           INTEGER;
        V_COLLS_COUNT   BINARY_INTEGER;
        V_COLUMNS       APEX_APPLICATION_GLOBAL.VC_ARR2;
        V_DESC_TAB      DBMS_SQL.DESC_TAB2;
        V_SQL           LARGEVARCHAR2;
    BEGIN
        V_CUR := DBMS_SQL.OPEN_CURSOR(2);
        V_SQL := APEX_PLUGIN_UTIL.REPLACE_SUBSTITUTIONS(P_VALUE => L_REPORT.REPORT.SQL_QUERY,P_ESCAPE => FALSE);

        LOG(V_SQL);
        DBMS_SQL.PARSE(V_CUR,V_SQL,DBMS_SQL.NATIVE);
        DBMS_SQL.DESCRIBE_COLUMNS2(V_CUR,V_COLLS_COUNT,V_DESC_TAB);
        FOR I IN 1..V_COLLS_COUNT LOOP
            IF
                UPPER(V_DESC_TAB(I).COL_NAME) != 'APXWS_ROW_PK'
            THEN --skip internal primary key if need
                V_COLUMNS(V_COLUMNS.COUNT + 1) := V_DESC_TAB(I).COL_NAME;
                LOG('Query column = '
                || V_DESC_TAB(I).COL_NAME);
            END IF;
        END LOOP;

        DBMS_SQL.CLOSE_CURSOR(V_CUR);
        RETURN V_COLUMNS;
    EXCEPTION
        WHEN OTHERS THEN
            IF
                DBMS_SQL.IS_OPEN(V_CUR)
            THEN
                DBMS_SQL.CLOSE_CURSOR(V_CUR);
            END IF;
            RAISE_APPLICATION_ERROR(-20001,'get_query_column_list: '
            || SQLERRM);
    END GET_QUERY_COLUMN_LIST;  
  ------------------------------------------------------------------------------

    FUNCTION GET_COLS_AS_TABLE (
        P_DELIMETERED_COLUMN_LIST      IN VARCHAR2,
        P_DISPLAYED_NONBREAK_COLUMNS   IN APEX_APPLICATION_GLOBAL.VC_ARR2
    ) RETURN APEX_APPLICATION_GLOBAL.VC_ARR2
        IS
    BEGIN
        RETURN INTERSECT_ARRAYS(APEX_UTIL.STRING_TO_TABLE(RR(P_DELIMETERED_COLUMN_LIST) ),P_DISPLAYED_NONBREAK_COLUMNS);
    END GET_COLS_AS_TABLE;
  
  ------------------------------------------------------------------------------

    FUNCTION GET_HIDDEN_COLUMNS_CNT (
        P_APP_ID      IN NUMBER,
        P_PAGE_ID     IN NUMBER,
        P_REGION_ID   IN NUMBER
    ) RETURN NUMBER
  -- J.P.Lourens 9-Oct-16 added p_region_id as input variable, and added v_get_query_column_list
     IS
        V_CNT                     NUMBER;
        V_GET_QUERY_COLUMN_LIST   VARCHAR2(32676);
    BEGIN
        V_GET_QUERY_COLUMN_LIST := APEX_UTIL.TABLE_TO_STRING(GET_QUERY_COLUMN_LIST);
        SELECT
            COUNT(*)
        INTO
            V_CNT
        FROM
            APEX_APPLICATION_PAGE_IR_COL
        WHERE
            APPLICATION_ID = P_APP_ID
            AND   PAGE_ID = P_PAGE_ID
       -- J.P.Lourens 9-Oct-16 added p_region_id to ensure correct results when having multiple IR on a page
            AND   REGION_ID = P_REGION_ID
            AND   (
                DISPLAY_TEXT_AS = 'HIDDEN'
       -- J.P.Lourens 9-Oct-2016 modified get_hidden_columns_cnt to INCLUDE columns which are
       --                        - selected in the IR query, and thus included in v_get_query_column_list
       --                        - not included in the report, thus missing from l_report.ir_data.report_columns
                OR    INSTR(':'
                || L_REPORT.IR_DATA.REPORT_COLUMNS
                || ':',':'
                || COLUMN_ALIAS
                || ':') = 0
            )
            AND   INSTR(':'
            || V_GET_QUERY_COLUMN_LIST
            || ':',':'
            || COLUMN_ALIAS
            || ':') > 0;
       
       --and instr(':'||l_report.ir_data.report_columns||':',':'||column_alias||':') > 0;       

        RETURN V_CNT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END GET_HIDDEN_COLUMNS_CNT;     
  
  ------------------------------------------------------------------------------ 

    PROCEDURE INIT_T_REPORT (
        P_APP_ID      IN NUMBER,
        P_PAGE_ID     IN NUMBER,
        P_REGION_ID   IN NUMBER
    ) IS
        L_REPORT_ID       NUMBER;
        V_QUERY_TARGETS   APEX_APPLICATION_GLOBAL.VC_ARR2;
        L_NEW_REPORT      IR_REPORT;
    BEGIN
        L_REPORT := L_NEW_REPORT;
    --get base report id    
        LOG('l_region_id='
        || P_REGION_ID);
        L_REPORT_ID := APEX_IR.GET_LAST_VIEWED_REPORT_ID(P_PAGE_ID => P_PAGE_ID,P_REGION_ID => P_REGION_ID);
        LOG('l_base_report_id='
        || L_REPORT_ID);
        SELECT
            R.*
        INTO
            L_REPORT.IR_DATA
        FROM
            APEX_APPLICATION_PAGE_IR_RPT R
        WHERE
            APPLICATION_ID = P_APP_ID
            AND   PAGE_ID = P_PAGE_ID
            AND   SESSION_ID = V('APP_SESSION')
            AND   APPLICATION_USER = V('APP_USER')
            AND   BASE_REPORT_ID = L_REPORT_ID;

        LOG('l_report_id='
        || L_REPORT_ID);
        L_REPORT_ID := L_REPORT.IR_DATA.REPORT_ID;
        L_REPORT.REPORT := APEX_IR.GET_REPORT(P_PAGE_ID => P_PAGE_ID,P_REGION_ID => P_REGION_ID);

        L_REPORT.IR_DATA.REPORT_COLUMNS := APEX_UTIL.TABLE_TO_STRING(GET_COLS_AS_TABLE(L_REPORT.IR_DATA.REPORT_COLUMNS,GET_QUERY_COLUMN_LIST
) );
    
    -- J.P.Lourens 9-Oct-16 added p_region_id as input variable

        L_REPORT.HIDDEN_COLS_CNT := GET_HIDDEN_COLUMNS_CNT(P_APP_ID,P_PAGE_ID,P_REGION_ID);
        << DISPLAYED_COLUMNS >> FOR I IN (
            SELECT
                COLUMN_ALIAS,
                REPORT_LABEL,
                HEADING_ALIGNMENT,
                COLUMN_ALIGNMENT,
                COLUMN_TYPE,
                FORMAT_MASK AS COMPUTATION_FORMAT_MASK,
                NVL(INSTR(':'
                || L_REPORT.IR_DATA.REPORT_COLUMNS
                || ':',':'
                || COLUMN_ALIAS
                || ':'),0) COLUMN_ORDER,
                NVL(INSTR(':'
                || L_REPORT.IR_DATA.BREAK_ENABLED_ON
                || ':',':'
                || COLUMN_ALIAS
                || ':'),0) BREAK_COLUMN_ORDER
            FROM
                APEX_APPLICATION_PAGE_IR_COL
            WHERE
                APPLICATION_ID = P_APP_ID
                AND   PAGE_ID = P_PAGE_ID
                AND   REGION_ID = P_REGION_ID
                AND   DISPLAY_TEXT_AS != 'HIDDEN' --l_report.ir_data.report_columns can include HIDDEN columns
                AND   INSTR(':'
                || L_REPORT.IR_DATA.REPORT_COLUMNS
                || ':',':'
                || COLUMN_ALIAS
                || ':') > 0
            UNION
            SELECT
                COMPUTATION_COLUMN_ALIAS,
                COMPUTATION_REPORT_LABEL,
                'center' AS HEADING_ALIGNMENT,
                'right' AS COLUMN_ALIGNMENT,
                COMPUTATION_COLUMN_TYPE,
                COMPUTATION_FORMAT_MASK,
                NVL(INSTR(':'
                || L_REPORT.IR_DATA.REPORT_COLUMNS
                || ':',':'
                || COMPUTATION_COLUMN_ALIAS
                || ':'),0) COLUMN_ORDER,
                NVL(INSTR(':'
                || L_REPORT.IR_DATA.BREAK_ENABLED_ON
                || ':',':'
                || COMPUTATION_COLUMN_ALIAS
                || ':'),0) BREAK_COLUMN_ORDER
            FROM
                APEX_APPLICATION_PAGE_IR_COMP
            WHERE
                APPLICATION_ID = P_APP_ID
                AND   PAGE_ID = P_PAGE_ID
                AND   REPORT_ID = L_REPORT_ID
                AND   INSTR(':'
                || L_REPORT.IR_DATA.REPORT_COLUMNS
                || ':',':'
                || COMPUTATION_COLUMN_ALIAS
                || ':') > 0
            ORDER BY
                BREAK_COLUMN_ORDER ASC,
                COLUMN_ORDER ASC
        ) LOOP
            L_REPORT.COLUMN_NAMES(I.COLUMN_ALIAS) := I.REPORT_LABEL;
            L_REPORT.COL_FORMAT_MASK(I.COLUMN_ALIAS) := I.COMPUTATION_FORMAT_MASK;
            L_REPORT.HEADER_ALIGNMENT(I.COLUMN_ALIAS) := I.HEADING_ALIGNMENT;
            L_REPORT.COLUMN_ALIGNMENT(I.COLUMN_ALIAS) := I.COLUMN_ALIGNMENT;
            L_REPORT.COLUMN_TYPES(I.COLUMN_ALIAS) := I.COLUMN_TYPE;
            IF
                I.COLUMN_ORDER > 0
            THEN
                IF
                    I.BREAK_COLUMN_ORDER = 0
                THEN 
          --displayed column
                    L_REPORT.DISPLAYED_COLUMNS(L_REPORT.DISPLAYED_COLUMNS.COUNT + 1) := I.COLUMN_ALIAS;
                ELSE  
          --break column
                    L_REPORT.BREAK_REALLY_ON(L_REPORT.BREAK_REALLY_ON.COUNT + 1) := I.COLUMN_ALIAS;
                END IF;
            END IF;

            LOG('column='
            || I.COLUMN_ALIAS
            || ' l_report.column_names='
            || I.REPORT_LABEL);
            LOG('column='
            || I.COLUMN_ALIAS
            || ' l_report.col_format_mask='
            || I.COMPUTATION_FORMAT_MASK);
            LOG('column='
            || I.COLUMN_ALIAS
            || ' l_report.header_alignment='
            || I.HEADING_ALIGNMENT);
            LOG('column='
            || I.COLUMN_ALIAS
            || ' l_report.column_alignment='
            || I.COLUMN_ALIGNMENT);
            LOG('column='
            || I.COLUMN_ALIAS
            || ' l_report.column_types='
            || I.COLUMN_TYPE);
        END LOOP DISPLAYED_COLUMNS;    
    
    -- calculate columns count with aggregation separately

        L_REPORT.SUM_COLUMNS_ON_BREAK := GET_COLS_AS_TABLE(L_REPORT.IR_DATA.SUM_COLUMNS_ON_BREAK,L_REPORT.DISPLAYED_COLUMNS);
        L_REPORT.AVG_COLUMNS_ON_BREAK := GET_COLS_AS_TABLE(L_REPORT.IR_DATA.AVG_COLUMNS_ON_BREAK,L_REPORT.DISPLAYED_COLUMNS);
        L_REPORT.MAX_COLUMNS_ON_BREAK := GET_COLS_AS_TABLE(L_REPORT.IR_DATA.MAX_COLUMNS_ON_BREAK,L_REPORT.DISPLAYED_COLUMNS);
        L_REPORT.MIN_COLUMNS_ON_BREAK := GET_COLS_AS_TABLE(L_REPORT.IR_DATA.MIN_COLUMNS_ON_BREAK,L_REPORT.DISPLAYED_COLUMNS);
        L_REPORT.MEDIAN_COLUMNS_ON_BREAK := GET_COLS_AS_TABLE(L_REPORT.IR_DATA.MEDIAN_COLUMNS_ON_BREAK,L_REPORT.DISPLAYED_COLUMNS);
        L_REPORT.COUNT_COLUMNS_ON_BREAK := GET_COLS_AS_TABLE(L_REPORT.IR_DATA.COUNT_COLUMNS_ON_BREAK,L_REPORT.DISPLAYED_COLUMNS);
        L_REPORT.COUNT_DISTNT_COL_ON_BREAK := GET_COLS_AS_TABLE(L_REPORT.IR_DATA.COUNT_DISTNT_COL_ON_BREAK,L_REPORT.DISPLAYED_COLUMNS); 
      
    -- calculate total count of columns with aggregation
        L_REPORT.AGG_COLS_CNT := L_REPORT.SUM_COLUMNS_ON_BREAK.COUNT + L_REPORT.AVG_COLUMNS_ON_BREAK.COUNT + L_REPORT.MAX_COLUMNS_ON_BREAK.COUNT
+ L_REPORT.MIN_COLUMNS_ON_BREAK.COUNT + L_REPORT.MEDIAN_COLUMNS_ON_BREAK.COUNT + L_REPORT.COUNT_COLUMNS_ON_BREAK.COUNT + L_REPORT.COUNT_DISTNT_COL_ON_BREAK
.COUNT;

        LOG('l_report.report_columns='
        || RR(L_REPORT.IR_DATA.REPORT_COLUMNS) );
        LOG('l_report.break_on='
        || RR(L_REPORT.IR_DATA.BREAK_ENABLED_ON) );
        LOG('l_report.sum_columns_on_break='
        || RR(L_REPORT.IR_DATA.SUM_COLUMNS_ON_BREAK) );
        LOG('l_report.avg_columns_on_break='
        || RR(L_REPORT.IR_DATA.AVG_COLUMNS_ON_BREAK) );
        LOG('l_report.max_columns_on_break='
        || RR(L_REPORT.IR_DATA.MAX_COLUMNS_ON_BREAK) );
        LOG('l_report.min_columns_on_break='
        || RR(L_REPORT.IR_DATA.MIN_COLUMNS_ON_BREAK) );
        LOG('l_report.median_columns_on_break='
        || RR(L_REPORT.IR_DATA.MEDIAN_COLUMNS_ON_BREAK) );
        LOG('l_report.count_columns_on_break='
        || RR(L_REPORT.IR_DATA.COUNT_DISTNT_COL_ON_BREAK) );
        LOG('l_report.count_distnt_col_on_break='
        || RR(L_REPORT.IR_DATA.COUNT_COLUMNS_ON_BREAK) );
        LOG('l_report.break_really_on='
        || APEX_UTIL.TABLE_TO_STRING(L_REPORT.BREAK_REALLY_ON) );
        LOG('l_report.agg_cols_cnt='
        || L_REPORT.AGG_COLS_CNT);
        LOG('l_report.hidden_cols_cnt='
        || L_REPORT.HIDDEN_COLS_CNT);
        FOR C IN CUR_HIGHLIGHT(P_REPORT_ID => L_REPORT_ID,P_DELIMETERED_COLUMN_LIST => L_REPORT.IR_DATA.REPORT_COLUMNS) LOOP
            IF
                C.HIGHLIGHT_ROW_COLOR IS NOT NULL OR C.HIGHLIGHT_ROW_FONT_COLOR IS NOT NULL
            THEN
          --is row highlight
                L_REPORT.ROW_HIGHLIGHT(L_REPORT.ROW_HIGHLIGHT.COUNT + 1) := C;
            ELSE
                L_REPORT.COL_HIGHLIGHT(L_REPORT.COL_HIGHLIGHT.COUNT + 1) := C;
            END IF;

            V_QUERY_TARGETS(V_QUERY_TARGETS.COUNT + 1) := C.CONDITION_SQL
            || ' as HLIGHTS_'
            || ( V_QUERY_TARGETS.COUNT + 1 );

        END LOOP;

        IF
            V_QUERY_TARGETS.COUNT > 0
        THEN
      -- uwr485kv is random name 
            L_REPORT.REPORT.SQL_QUERY := 'SELECT '
            || APEX_UTIL.TABLE_TO_STRING(V_QUERY_TARGETS,','
            || CHR(10) )
            || ', uwr485kv.* from ('
            || L_REPORT.REPORT.SQL_QUERY
            || ') uwr485kv';
        END IF;

        L_REPORT.REPORT.SQL_QUERY := L_REPORT.REPORT.SQL_QUERY;
        LOG('l_report.report.sql_query='
        || CHR(10)
        || L_REPORT.REPORT.SQL_QUERY
        || CHR(10) );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'No Interactive Report found on Page='
            || P_PAGE_ID
            || ' Application='
            || P_APP_ID
            || ' Please make sure that the report was running at least once by this session.');
        WHEN OTHERS THEN
            LOG('Exception in init_t_report');
            LOG(' Page='
            || P_PAGE_ID);
            LOG(' Application='
            || P_APP_ID);
            RAISE;
    END INIT_T_REPORT;  
  ------------------------------------------------------------------------------

    FUNCTION IS_CONTROL_BREAK (
        P_CURR_ROW   IN APEX_APPLICATION_GLOBAL.VC_ARR2,
        P_PREV_ROW   IN APEX_APPLICATION_GLOBAL.VC_ARR2
    ) RETURN BOOLEAN IS
        V_START_WITH   BINARY_INTEGER;
        V_END_WITH     BINARY_INTEGER;
    BEGIN
        IF
            NVL(L_REPORT.BREAK_REALLY_ON.COUNT,0) = 0
        THEN
            RETURN FALSE; --no control break
        END IF;

        V_START_WITH := 1 + L_REPORT.SKIPPED_COLUMNS + L_REPORT.ROW_HIGHLIGHT.COUNT + L_REPORT.COL_HIGHLIGHT.COUNT;

        V_END_WITH := L_REPORT.SKIPPED_COLUMNS + L_REPORT.ROW_HIGHLIGHT.COUNT + L_REPORT.COL_HIGHLIGHT.COUNT + NVL(L_REPORT.BREAK_REALLY_ON.COUNT
,0);

        FOR I IN V_START_WITH..V_END_WITH LOOP
            IF
                P_CURR_ROW(I) != P_PREV_ROW(I)
            THEN
                RETURN TRUE;
            END IF;
        END LOOP;

        RETURN FALSE;
    END IS_CONTROL_BREAK;
  ------------------------------------------------------------------------------

    FUNCTION GET_CELL_DATE (
        P_QUERY_VALUE   IN VARCHAR2,
        P_FORMAT_MASK   IN VARCHAR2
    ) RETURN T_CELL_DATA IS
        FORMAT_ERROR EXCEPTION;
        PRAGMA EXCEPTION_INIT ( FORMAT_ERROR,-01830 );
        V_DATA   T_CELL_DATA;
    BEGIN
        V_DATA.VALUE := TO_DATE(P_QUERY_VALUE) - TO_DATE('01-03-1900','DD-MM-YYYY') + 61;

        V_DATA.DATATYPE := 'DATE';
        IF
            P_FORMAT_MASK IS NOT NULL
        THEN
            V_DATA.TEXT := TO_CHAR(TO_DATE(P_QUERY_VALUE),P_FORMAT_MASK);
        ELSE
            V_DATA.TEXT := TO_CHAR(TO_DATE(P_QUERY_VALUE),V_DEFAULT_DATE_NLS);
        END IF;

        RETURN V_DATA;
    EXCEPTION
        WHEN INVALID_NUMBER OR FORMAT_ERROR THEN
            V_DATA.VALUE := NULL;
            V_DATA.DATATYPE := 'STRING';
            V_DATA.TEXT := P_QUERY_VALUE;
            RETURN V_DATA;
    END GET_CELL_DATE;
  ------------------------------------------------------------------------------

    FUNCTION GET_FORMATTED_NUMBER (
        P_STR_TO_CONVERT   IN VARCHAR2,
        P_FORMAT_STRING    IN VARCHAR2,
        P_NLS              IN VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 IS
        V_STR   VARCHAR2(100);
    BEGIN
        V_STR := TRIM(TO_CHAR(TO_NUMBER(P_STR_TO_CONVERT),P_FORMAT_STRING,P_NLS) );
        IF
            INSTR(V_STR,'#') > 0 AND LTRIM(V_STR,'#') IS NULL
        THEN --format fail
            RAISE INVALID_NUMBER;
        ELSE
            RETURN V_STR;
        END IF;

    END GET_FORMATTED_NUMBER;  
  ------------------------------------------------------------------------------

    FUNCTION GET_CELL_NUMBER (
        P_QUERY_VALUE   IN VARCHAR2,
        P_FORMAT_MASK   IN VARCHAR2
    ) RETURN T_CELL_DATA IS
        CONVERSION_ERROR EXCEPTION;
        PRAGMA EXCEPTION_INIT ( CONVERSION_ERROR,-06502 );
        V_DATA   T_CELL_DATA;
    BEGIN
        V_DATA.DATATYPE := 'NUMBER';
        V_DATA.VALUE := GET_FORMATTED_NUMBER(P_QUERY_VALUE,'9999999999999990D00000000','NLS_NUMERIC_CHARACTERS = ''.,''');
        IF
            P_FORMAT_MASK IS NOT NULL
        THEN
            V_DATA.TEXT := GET_FORMATTED_NUMBER(P_QUERY_VALUE,P_FORMAT_MASK);
        ELSE
            V_DATA.TEXT := P_QUERY_VALUE;
        END IF;

        RETURN V_DATA;
    EXCEPTION
        WHEN INVALID_NUMBER OR CONVERSION_ERROR THEN
            V_DATA.VALUE := NULL;
            V_DATA.DATATYPE := 'STRING';
            V_DATA.TEXT := P_QUERY_VALUE;
            RETURN V_DATA;
    END GET_CELL_NUMBER;  
  ------------------------------------------------------------------------------

    FUNCTION PRINT_ROW (
        P_CURRENT_ROW IN APEX_APPLICATION_GLOBAL.VC_ARR2
    ) RETURN VARCHAR2 IS

        V_CLOB              LARGEVARCHAR2; --change
        V_COLUMN_ALIAS      APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE;
        V_FORMAT_MASK       APEX_APPLICATION_PAGE_IR_COMP.COMPUTATION_FORMAT_MASK%TYPE;
        V_ROW_COLOR         VARCHAR2(10);
        V_ROW_BACK_COLOR    VARCHAR2(10);
        V_CELL_COLOR        VARCHAR2(10);
        V_CELL_BACK_COLOR   VARCHAR2(10);
        V_COLUMN_TYPE       VARCHAR2(10);
        V_CELL_DATA         T_CELL_DATA;
    BEGIN
      --check that row need to be highlighted
        << ROW_HIGHLIGHTS >> FOR H IN 1..L_REPORT.ROW_HIGHLIGHT.COUNT LOOP
            BEGIN 
      -- J.P.Lourens 9-Oct-16 
      -- current_row is based on report_sql which starts with the highlight columns, then the skipped columns and then the rest
      -- So to capture the highlight values the value for l_report.skipped_columns should NOT be taken into account
                IF
                    GET_CURRENT_ROW(P_CURRENT_ROW,/*l_report.skipped_columns + */L_REPORT.ROW_HIGHLIGHT(H).COND_NUMBER) IS NOT NULL
                THEN
                    V_ROW_COLOR := L_REPORT.ROW_HIGHLIGHT(H).HIGHLIGHT_ROW_FONT_COLOR;
                    V_ROW_BACK_COLOR := L_REPORT.ROW_HIGHLIGHT(H).HIGHLIGHT_ROW_COLOR;
                END IF;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    LOG('row_highlights: ='
                    || ' end_with='
                    || L_REPORT.END_WITH
                    || ' agg_cols_cnt='
                    || L_REPORT.AGG_COLS_CNT
                    || ' COND_NUMBER='
                    || L_REPORT.ROW_HIGHLIGHT(H).COND_NUMBER
                    || ' h='
                    || H);
            END;
        END LOOP ROW_HIGHLIGHTS;
    --

        << VISIBLE_COLUMNS >> FOR I IN L_REPORT.START_WITH..L_REPORT.END_WITH LOOP
            V_CELL_COLOR := NULL;
            V_CELL_BACK_COLOR := NULL;
            V_CELL_DATA.VALUE := NULL;
            V_CELL_DATA.TEXT := NULL;
            V_COLUMN_ALIAS := GET_COLUMN_ALIAS_SQL(I);
            V_COLUMN_TYPE := GET_COLUMN_TYPES(V_COLUMN_ALIAS);
            V_FORMAT_MASK := GET_COL_FORMAT_MASK(V_COLUMN_ALIAS);
            IF
                V_COLUMN_TYPE = 'DATE'
            THEN
                V_CELL_DATA := GET_CELL_DATE(GET_CURRENT_ROW(P_CURRENT_ROW,I),V_FORMAT_MASK);
            ELSIF V_COLUMN_TYPE = 'NUMBER' THEN
                V_CELL_DATA := GET_CELL_NUMBER(GET_CURRENT_ROW(P_CURRENT_ROW,I),V_FORMAT_MASK);
            ELSE --STRING
                V_FORMAT_MASK := NULL;
                V_CELL_DATA.VALUE := NULL;
                V_CELL_DATA.DATATYPE := 'STRING';
                V_CELL_DATA.TEXT := GET_CURRENT_ROW(P_CURRENT_ROW,I);
            END IF; 
       
      --check that cell need to be highlighted

            << CELL_HIGHLIGHTS >> FOR H IN 1..L_REPORT.COL_HIGHLIGHT.COUNT LOOP
                BEGIN
          -- J.P.Lourens 9-Oct-16 
          -- current_row is based on report_sql which starts with the highlight columns, then the skipped columns and then the rest
          -- So to capture the highlight values the value for l_report.skipped_columns should NOT be taken into account
                    IF
                        GET_CURRENT_ROW(P_CURRENT_ROW,/*l_report.skipped_columns + */L_REPORT.COL_HIGHLIGHT(H).COND_NUMBER) IS NOT NULL AND V_COLUMN_ALIAS = L_REPORT.COL_HIGHLIGHT(H).CONDITION_COLUMN_NAME
                    THEN
                        V_CELL_COLOR := L_REPORT.COL_HIGHLIGHT(H).HIGHLIGHT_CELL_FONT_COLOR;
                        V_CELL_BACK_COLOR := L_REPORT.COL_HIGHLIGHT(H).HIGHLIGHT_CELL_COLOR;
                    END IF;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        LOG('col_highlights: ='
                        || ' end_with='
                        || L_REPORT.END_WITH
                        || ' agg_cols_cnt='
                        || L_REPORT.AGG_COLS_CNT
                        || ' COND_NUMBER='
                        || L_REPORT.COL_HIGHLIGHT(H).COND_NUMBER
                        || ' h='
                        || H);
                END;
            END LOOP CELL_HIGHLIGHTS;

            V_CLOB := V_CLOB
            || BCOLL(P_FONT_COLOR => NVL(V_CELL_COLOR,V_ROW_COLOR),P_BACK_COLOR => NVL(V_CELL_BACK_COLOR,V_ROW_BACK_COLOR),P_ALIGN => GET_COLUMN_ALIGNMENT
(V_COLUMN_ALIAS),P_COLUMN_ALIAS => V_COLUMN_ALIAS,P_COLMN_TYPE => V_CELL_DATA.DATATYPE,P_VALUE => V_CELL_DATA.VALUE,P_FORMAT_MASK => V_FORMAT_MASK
)
            || GET_XMLVAL(V_CELL_DATA.TEXT)
            || ECOLL(I);

        END LOOP VISIBLE_COLUMNS;

        RETURN '<ROW>'
        || V_CLOB
        || '</ROW>'
        || CHR(10);
    END PRINT_ROW;
  
  ------------------------------------------------------------------------------  

    FUNCTION PRINT_HEADER RETURN VARCHAR2 IS
        V_HEADER_XML     LARGEVARCHAR2;
        V_COLUMN_ALIAS   APEX_APPLICATION_PAGE_IR_COL.COLUMN_ALIAS%TYPE;
    BEGIN
        V_HEADER_XML := '<HEADER>';
        << HEADERS >> FOR I IN 1..L_REPORT.DISPLAYED_COLUMNS.COUNT LOOP
            V_COLUMN_ALIAS := GET_COLUMN_ALIAS(I);
      -- if current column is not control break column
            IF
                APEX_PLUGIN_UTIL.GET_POSITION_IN_LIST(L_REPORT.BREAK_ON,V_COLUMN_ALIAS) IS NULL
            THEN
                V_HEADER_XML := V_HEADER_XML
                || BCOLL(P_COLUMN_ALIAS => V_COLUMN_ALIAS,P_HEADER_ALIGN => GET_HEADER_ALIGNMENT(V_COLUMN_ALIAS),P_ALIGN => GET_COLUMN_ALIGNMENT(V_COLUMN_ALIAS
),P_COLMN_TYPE => GET_COLUMN_TYPES(V_COLUMN_ALIAS),P_FORMAT_MASK => GET_COL_FORMAT_MASK(V_COLUMN_ALIAS) )
                || GET_XMLVAL(REGEXP_REPLACE(GET_COLUMN_NAMES(V_COLUMN_ALIAS),'<[^>]*>',' ') )
                || ECOLL(I);

            END IF;

        END LOOP HEADERS;

        RETURN V_HEADER_XML
        || '</HEADER>'
        || CHR(10);
    END PRINT_HEADER; 
  ------------------------------------------------------------------------------  

    FUNCTION PRINT_CONTROL_BREAK_HEADER (
        P_CURRENT_ROW IN APEX_APPLICATION_GLOBAL.VC_ARR2
    ) RETURN VARCHAR2 IS
        V_CB_XML   LARGEVARCHAR2;
    BEGIN
        IF
            NVL(L_REPORT.BREAK_REALLY_ON.COUNT,0) = 0
        THEN
            RETURN ''; --no control break
        END IF;

        << BREAK_COLUMNS >> FOR I IN 1..NVL(L_REPORT.BREAK_REALLY_ON.COUNT,0) LOOP
      --TODO: Add column header
            V_CB_XML := V_CB_XML
            || GET_COLUMN_NAMES(L_REPORT.BREAK_REALLY_ON(I) )
            || ': '
            || GET_CURRENT_ROW(P_CURRENT_ROW,I + L_REPORT.SKIPPED_COLUMNS + L_REPORT.ROW_HIGHLIGHT.COUNT + L_REPORT.COL_HIGHLIGHT.COUNT)
            || ',';
        END LOOP VISIBLE_COLUMNS;

        RETURN '<BREAK_HEADER>'
        || GET_XMLVAL(RTRIM(V_CB_XML,',') )
        || '</BREAK_HEADER>'
        || CHR(10);

    END PRINT_CONTROL_BREAK_HEADER;
  ------------------------------------------------------------------------------

    FUNCTION FIND_REL_POSITION (
        P_CURR_COL_NAME   IN VARCHAR2,
        P_AGG_ROWS        IN APEX_APPLICATION_GLOBAL.VC_ARR2
    ) RETURN BINARY_INTEGER IS
        V_RELATIVE_POSITION   BINARY_INTEGER;
    BEGIN
        << AGGREGATED_ROWS >> FOR I IN 1..P_AGG_ROWS.COUNT LOOP
            IF
                P_CURR_COL_NAME = P_AGG_ROWS(I)
            THEN
                RETURN I;
            END IF;
        END LOOP AGGREGATED_ROWS;

        RETURN NULL;
    END FIND_REL_POSITION;
  ------------------------------------------------------------------------------

    FUNCTION GET_AGG_TEXT (
        P_CURR_COL_NAME         IN VARCHAR2,
        P_AGG_ROWS              IN APEX_APPLICATION_GLOBAL.VC_ARR2,
        P_CURRENT_ROW           IN APEX_APPLICATION_GLOBAL.VC_ARR2,
        P_AGG_TEXT              IN VARCHAR2,
        P_POSITION              IN BINARY_INTEGER, --start position in sql-query
        P_COL_NUMBER            IN BINARY_INTEGER, --column position when displayed
        P_DEFAULT_FORMAT_MASK   IN VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 IS

        V_TMP_POS         BINARY_INTEGER;  -- current column position in sql-query 
        V_FORMAT_MASK     APEX_APPLICATION_PAGE_IR_COMP.COMPUTATION_FORMAT_MASK%TYPE;
        V_AGG_VALUE       LARGEVARCHAR2;
        V_ROW_VALUE       LARGEVARCHAR2;
        V_G_FORMAT_MASK   VARCHAR2(100);
        V_COL_ALIAS       VARCHAR2(255);
    BEGIN
        V_TMP_POS := FIND_REL_POSITION(P_CURR_COL_NAME,P_AGG_ROWS);
        IF
            V_TMP_POS IS NOT NULL
        THEN
            V_COL_ALIAS := GET_COLUMN_ALIAS_SQL(P_COL_NUMBER);
            V_G_FORMAT_MASK := GET_COL_FORMAT_MASK(V_COL_ALIAS);
            V_FORMAT_MASK := NVL(V_G_FORMAT_MASK,P_DEFAULT_FORMAT_MASK);
            V_ROW_VALUE := GET_CURRENT_ROW(P_CURRENT_ROW,P_POSITION + L_REPORT.HIDDEN_COLS_CNT + V_TMP_POS);
            V_AGG_VALUE := TRIM(TO_CHAR(V_ROW_VALUE,V_FORMAT_MASK) );
            RETURN GET_XMLVAL(P_AGG_TEXT
            || V_AGG_VALUE
            || ' '
            || CHR(10) );
        ELSE
            RETURN '';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            LOG('!Exception in get_agg_text');
            LOG('p_col_number='
            || P_COL_NUMBER);
            LOG('v_col_alias='
            || V_COL_ALIAS);
            LOG('v_g_format_mask='
            || V_G_FORMAT_MASK);
            LOG('p_default_format_mask='
            || P_DEFAULT_FORMAT_MASK);
            LOG('v_tmp_pos='
            || V_TMP_POS);
            LOG('p_position='
            || P_POSITION);
        -- J.P.Lourens 9-Oct-16 added to log     
            LOG('l_report.hidden_cols_cnt='
            || L_REPORT.HIDDEN_COLS_CNT);
            LOG('v_row_value='
            || V_ROW_VALUE);
            LOG('v_format_mask='
            || V_FORMAT_MASK);
            RAISE;
    END GET_AGG_TEXT;
  ------------------------------------------------------------------------------

    FUNCTION PRINT_AGGREGATE (
        P_CURRENT_ROW IN APEX_APPLICATION_GLOBAL.VC_ARR2
    ) RETURN VARCHAR2 IS
        V_AGGREGATE_XML   LARGEVARCHAR2;
        V_POSITION        BINARY_INTEGER;
    BEGIN
        IF
            L_REPORT.AGG_COLS_CNT = 0
        THEN
            RETURN ''; --no aggregate
        END IF;
        V_AGGREGATE_XML := '<AGGREGATE>';
        << VISIBLE_COLUMNS >> FOR I IN L_REPORT.START_WITH..L_REPORT.END_WITH LOOP
            V_POSITION := L_REPORT.END_WITH; --aggregate are placed after displayed columns and computations
            V_AGGREGATE_XML := V_AGGREGATE_XML
            || BCOLL(P_COLUMN_ALIAS => GET_COLUMN_ALIAS_SQL(I),
                                                  --p_value => v_sum_value,
            P_FORMAT_MASK => GET_COL_FORMAT_MASK(GET_COLUMN_ALIAS_SQL(I) ) );
      -- and second to XML-tag text to display as text concatenated with other aggregates
      -- one column cah have only one aggregate of each type

            V_AGGREGATE_XML := V_AGGREGATE_XML
            || GET_AGG_TEXT(P_CURR_COL_NAME => GET_COLUMN_ALIAS_SQL(I),P_AGG_ROWS => L_REPORT.SUM_COLUMNS_ON_BREAK,P_CURRENT_ROW => P_CURRENT_ROW,P_AGG_TEXT
=> ' ',P_POSITION => V_POSITION,P_COL_NUMBER => I);

            V_POSITION := V_POSITION + L_REPORT.SUM_COLUMNS_ON_BREAK.COUNT;
            V_AGGREGATE_XML := V_AGGREGATE_XML
            || GET_AGG_TEXT(P_CURR_COL_NAME => GET_COLUMN_ALIAS_SQL(I),P_AGG_ROWS => L_REPORT.AVG_COLUMNS_ON_BREAK,P_CURRENT_ROW => P_CURRENT_ROW,P_AGG_TEXT
=> 'Avgerage:',P_POSITION => V_POSITION,P_COL_NUMBER => I,P_DEFAULT_FORMAT_MASK => '999G999G999G999G990D000');

            V_POSITION := V_POSITION + L_REPORT.AVG_COLUMNS_ON_BREAK.COUNT;
            V_AGGREGATE_XML := V_AGGREGATE_XML
            || GET_AGG_TEXT(P_CURR_COL_NAME => GET_COLUMN_ALIAS_SQL(I),P_AGG_ROWS => L_REPORT.MAX_COLUMNS_ON_BREAK,P_CURRENT_ROW => P_CURRENT_ROW,P_AGG_TEXT
=> 'Max:',P_POSITION => V_POSITION,P_COL_NUMBER => I);

            V_POSITION := V_POSITION + L_REPORT.MAX_COLUMNS_ON_BREAK.COUNT;
            V_AGGREGATE_XML := V_AGGREGATE_XML
            || GET_AGG_TEXT(P_CURR_COL_NAME => GET_COLUMN_ALIAS_SQL(I),P_AGG_ROWS => L_REPORT.MIN_COLUMNS_ON_BREAK,P_CURRENT_ROW => P_CURRENT_ROW,P_AGG_TEXT
=> 'Min:',P_POSITION => V_POSITION,P_COL_NUMBER => I);

            V_POSITION := V_POSITION + L_REPORT.MIN_COLUMNS_ON_BREAK.COUNT;
            V_AGGREGATE_XML := V_AGGREGATE_XML
            || GET_AGG_TEXT(P_CURR_COL_NAME => GET_COLUMN_ALIAS_SQL(I),P_AGG_ROWS => L_REPORT.MEDIAN_COLUMNS_ON_BREAK,P_CURRENT_ROW => P_CURRENT_ROW
,P_AGG_TEXT => 'Median:',P_POSITION => V_POSITION,P_COL_NUMBER => I,P_DEFAULT_FORMAT_MASK => '999G999G999G999G990D000');

            V_POSITION := V_POSITION + L_REPORT.MEDIAN_COLUMNS_ON_BREAK.COUNT;
            V_AGGREGATE_XML := V_AGGREGATE_XML
            || GET_AGG_TEXT(P_CURR_COL_NAME => GET_COLUMN_ALIAS_SQL(I),P_AGG_ROWS => L_REPORT.COUNT_COLUMNS_ON_BREAK,P_CURRENT_ROW => P_CURRENT_ROW,
P_AGG_TEXT => 'Count:',P_POSITION => V_POSITION,P_COL_NUMBER => I);

            V_POSITION := V_POSITION + L_REPORT.COUNT_COLUMNS_ON_BREAK.COUNT;
            V_AGGREGATE_XML := V_AGGREGATE_XML
            || GET_AGG_TEXT(P_CURR_COL_NAME => GET_COLUMN_ALIAS_SQL(I),P_AGG_ROWS => L_REPORT.COUNT_DISTNT_COL_ON_BREAK,P_CURRENT_ROW => P_CURRENT_ROW
,P_AGG_TEXT => 'Count distinct:',P_POSITION => V_POSITION,P_COL_NUMBER => I);

            V_AGGREGATE_XML := V_AGGREGATE_XML
            || ECOLL(I);
        END LOOP VISIBLE_COLUMNS;

        RETURN V_AGGREGATE_XML
        || '</AGGREGATE>'
        || CHR(10);
    END PRINT_AGGREGATE;    
  ------------------------------------------------------------------------------    

    FUNCTION GET_DEFAULT_DATE_NLS RETURN VARCHAR2 IS
        V_FORMAT   VARCHAR2(50);
    BEGIN
        SELECT
            VALUE
        INTO
            V_FORMAT
        FROM
            V$NLS_PARAMETERS
        WHERE
            PARAMETER = 'NLS_DATE_FORMAT';

        RETURN V_FORMAT;
    END GET_DEFAULT_DATE_NLS;
  ------------------------------------------------------------------------------

    PROCEDURE GET_XML_FROM_IR (
        V_DATA       IN OUT NOCOPY CLOB,
        P_MAX_ROWS   IN INTEGER
    ) IS

        V_CUR              INTEGER;
        V_RESULT           INTEGER;
        V_COLLS_COUNT      BINARY_INTEGER;
        V_ROW              APEX_APPLICATION_GLOBAL.VC_ARR2;
        V_PREV_ROW         APEX_APPLICATION_GLOBAL.VC_ARR2;
        V_COLUMNS          APEX_APPLICATION_GLOBAL.VC_ARR2;
        V_CURRENT_ROW      NUMBER DEFAULT 0;
        V_DESC_TAB         DBMS_SQL.DESC_TAB2;
        V_INSIDE           BOOLEAN DEFAULT FALSE;
        V_SQL              LARGEVARCHAR2;
        V_BIND_VARIABLES   DBMS_SQL.VARCHAR2_TABLE;
        V_BUFFER           LARGEVARCHAR2;
        V_BIND_VAR_NAME    VARCHAR2(255);
        V_BINDED           BOOLEAN;
    BEGIN
        V_DEFAULT_DATE_NLS := GET_DEFAULT_DATE_NLS;
        EXECUTE IMMEDIATE 'alter session set nls_date_format="dd.mm.yyyy hh24:mi:ss"';
        V_CUR := DBMS_SQL.OPEN_CURSOR(2);
        V_SQL := APEX_PLUGIN_UTIL.REPLACE_SUBSTITUTIONS(P_VALUE => L_REPORT.REPORT.SQL_QUERY,P_ESCAPE => FALSE);

        DBMS_SQL.PARSE(V_CUR,V_SQL,DBMS_SQL.NATIVE);
        DBMS_SQL.DESCRIBE_COLUMNS2(V_CUR,V_COLLS_COUNT,V_DESC_TAB);    
    --skip internal primary key if need
        FOR I IN 1..V_DESC_TAB.COUNT LOOP
            IF
                LOWER(V_DESC_TAB(I).COL_NAME) = 'apxws_row_pk'
            THEN
                L_REPORT.SKIPPED_COLUMNS := 1;
            END IF;
        END LOOP;

        L_REPORT.START_WITH := 1 + L_REPORT.SKIPPED_COLUMNS + NVL(L_REPORT.BREAK_REALLY_ON.COUNT,0) + L_REPORT.ROW_HIGHLIGHT.COUNT + L_REPORT.COL_HIGHLIGHT
.COUNT;

        L_REPORT.END_WITH := L_REPORT.SKIPPED_COLUMNS + NVL(L_REPORT.BREAK_REALLY_ON.COUNT,0) + L_REPORT.DISPLAYED_COLUMNS.COUNT + L_REPORT.ROW_HIGHLIGHT
.COUNT + L_REPORT.COL_HIGHLIGHT.COUNT;

        LOG('l_report.start_with='
        || L_REPORT.START_WITH);
        LOG('l_report.end_with='
        || L_REPORT.END_WITH);
        LOG('l_report.skipped_columns='
        || L_REPORT.SKIPPED_COLUMNS);
        V_BIND_VARIABLES := WWV_FLOW_UTILITIES.GET_BINDS(V_SQL);
        ADD(V_DATA,V_BUFFER,PRINT_HEADER);
        LOG('<<bind variables>>');
        << BIND_VARIABLES >> FOR I IN 1..V_BIND_VARIABLES.COUNT LOOP
            V_BIND_VAR_NAME := LTRIM(V_BIND_VARIABLES(I),':');
            IF
                V_BIND_VAR_NAME = 'APXWS_MAX_ROW_CNT'
            THEN      
         -- remove max_rows
                DBMS_SQL.BIND_VARIABLE(V_CUR,'APXWS_MAX_ROW_CNT',P_MAX_ROWS);
                LOG('Bind variable ('
                || I
                || ')'
                || V_BIND_VAR_NAME
                || '<'
                || P_MAX_ROWS
                || '>');

            ELSE
                V_BINDED := FALSE; 
        --first look report bind variables (filtering, search etc)
                << BIND_REPORT_VARIABLES >> FOR A IN 1..L_REPORT.REPORT.BINDS.COUNT LOOP
                    IF
                        V_BIND_VAR_NAME = L_REPORT.REPORT.BINDS(A).NAME
                    THEN
                        DBMS_SQL.BIND_VARIABLE(V_CUR,V_BIND_VAR_NAME,L_REPORT.REPORT.BINDS(A).VALUE);

                        LOG('Bind variable as report variable ('
                        || I
                        || ')'
                        || V_BIND_VAR_NAME
                        || '<'
                        || L_REPORT.REPORT.BINDS(A).VALUE
                        || '>');

                        V_BINDED := TRUE;
                        EXIT;
                    END IF;
                END LOOP BIND_REPORT_VARIABLES;
        -- substantive strings in sql-queries can have bind variables too
        -- these variables are not in v_report.binds
        -- and need to be binded separately

                IF
                    NOT V_BINDED
                THEN
                    DBMS_SQL.BIND_VARIABLE(V_CUR,V_BIND_VAR_NAME,V(V_BIND_VAR_NAME) );
                    LOG('Bind variable ('
                    || I
                    || ')'
                    || V_BIND_VAR_NAME
                    || '<'
                    || V(V_BIND_VAR_NAME)
                    || '>');

                END IF;

            END IF;

        END LOOP;

        FOR I IN 1..V_COLLS_COUNT LOOP
            V_ROW(I) := ' ';
        END LOOP;

        LOG('<<define_columns>>');
        FOR I IN 1..V_COLLS_COUNT LOOP
            LOG('define column '
            || I);
            DBMS_SQL.DEFINE_COLUMN(V_CUR,I,V_ROW(I),32767);
        END LOOP DEFINE_COLUMNS;

        V_RESULT := DBMS_SQL.EXECUTE(V_CUR);
        LOG('<<main_cycle>>');
        << MAIN_CYCLE >> LOOP
            IF
                DBMS_SQL.FETCH_ROWS(V_CUR) > 0
            THEN
                LOG('<<fetch>>');
           -- get column values of the row 
                V_CURRENT_ROW := V_CURRENT_ROW + 1;
                << QUERY_COLUMNS >> FOR I IN 1..V_COLLS_COUNT LOOP
                    DBMS_SQL.COLUMN_VALUE(V_CUR,I,V_ROW(I) );
                END LOOP;     
            --check control break

                IF
                    V_CURRENT_ROW > 1
                THEN
                    IF
                        IS_CONTROL_BREAK(V_ROW,V_PREV_ROW)
                    THEN
                        ADD(V_DATA,V_BUFFER,'</ROWSET>'
                        || CHR(10) );
                        V_INSIDE := FALSE;
                    END IF;
                END IF;

                IF
                    NOT V_INSIDE
                THEN
                    ADD(V_DATA,V_BUFFER,'<ROWSET>'
                    || CHR(10) );
                    ADD(V_DATA,V_BUFFER,PRINT_CONTROL_BREAK_HEADER(V_ROW) );
              --print aggregates
                    ADD(V_DATA,V_BUFFER,PRINT_AGGREGATE(V_ROW) );
                    V_INSIDE := TRUE;
                END IF;            --            

                << QUERY_COLUMNS >> FOR I IN 1..V_COLLS_COUNT LOOP
                    V_PREV_ROW(I) := V_ROW(I);
                END LOOP;

                ADD(V_DATA,V_BUFFER,PRINT_ROW(V_ROW) );
            ELSE
                EXIT;
            END IF;
        END LOOP MAIN_CYCLE;

        IF
            V_INSIDE
        THEN
            ADD(V_DATA,V_BUFFER,'</ROWSET>');
            V_INSIDE := FALSE;
        END IF;

        ADD(V_DATA,V_BUFFER,' ',TRUE);
        DBMS_SQL.CLOSE_CURSOR(V_CUR);
    END GET_XML_FROM_IR;
  ------------------------------------------------------------------------------

    PROCEDURE GET_FINAL_XML (
        P_CLOB             IN OUT NOCOPY CLOB,
        P_APP_ID           IN NUMBER,
        P_REGION_ID        IN NUMBER,
        P_PAGE_ID          IN NUMBER,
        P_ITEMS_LIST       IN VARCHAR2,
        P_GET_PAGE_ITEMS   IN CHAR,
        P_MAX_ROWS         IN NUMBER
    ) IS
        V_ROWS     APEX_APPLICATION_GLOBAL.VC_ARR2;
        V_BUFFER   LARGEVARCHAR2;
    BEGIN
        ADD(P_CLOB,V_BUFFER,'<?xml version="1.0" encoding="UTF-8"?>'
        || CHR(10)
        || '<DOCUMENT>'
        || CHR(10) );

        ADD(P_CLOB,V_BUFFER,'<DATA>'
        || CHR(10),TRUE);
        GET_XML_FROM_IR(P_CLOB,P_MAX_ROWS);
        ADD(P_CLOB,V_BUFFER,'</DATA>'
        || CHR(10) );
        ADD(P_CLOB,V_BUFFER,'</DOCUMENT>'
        || CHR(10),TRUE);
    END GET_FINAL_XML;
  ------------------------------------------------------------------------------

    PROCEDURE DOWNLOAD_FILE (
        P_DATA          IN CLOB,
        P_MIME_HEADER   IN VARCHAR2,
        P_FILE_NAME     IN VARCHAR2
    ) IS

        V_BLOB          BLOB;
        V_DESC_OFFSET   PLS_INTEGER := 1;
        V_SRC_OFFSET    PLS_INTEGER := 1;
        V_LANG          PLS_INTEGER := 0;
        V_WARNING       PLS_INTEGER := 0;
    BEGIN
        DBMS_LOB.CREATETEMPORARY(V_BLOB,TRUE);
        DBMS_LOB.CONVERTTOBLOB(V_BLOB,P_DATA,DBMS_LOB.GETLENGTH(P_DATA),V_DESC_OFFSET,V_SRC_OFFSET,DBMS_LOB.DEFAULT_CSID,V_LANG,V_WARNING
);

        SYS.HTP.INIT;
        SYS.OWA_UTIL.MIME_HEADER(P_MIME_HEADER,FALSE);
        SYS.HTP.P('Content-length: '
        || SYS.DBMS_LOB.GETLENGTH(V_BLOB) );

        SYS.HTP.P('Content-Disposition: attachment; filename="'
        || P_FILE_NAME
        || '"');
        SYS.OWA_UTIL.HTTP_HEADER_CLOSE;
        SYS.WPG_DOCLOAD.DOWNLOAD_FILE(V_BLOB);
        DBMS_LOB.FREETEMPORARY(V_BLOB);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'Download file '
            || SQLERRM);
    END DOWNLOAD_FILE;
  ------------------------------------------------------------------------------

    PROCEDURE SET_COLLECTION (
        P_COLLECTION_NAME   IN VARCHAR2,
        P_DATA              IN CLOB
    ) IS
        V_TMP   CHAR;
    BEGIN
        IF
            APEX_COLLECTION.COLLECTION_EXISTS(P_COLLECTION_NAME) = FALSE
        THEN
            APEX_COLLECTION.CREATE_COLLECTION(P_COLLECTION_NAME);
        END IF;

        BEGIN
            SELECT
                '1' --clob001
            INTO
                V_TMP
            FROM
                APEX_COLLECTIONS
            WHERE
                COLLECTION_NAME = P_COLLECTION_NAME
                AND   SEQ_ID = 1;

            APEX_COLLECTION.UPDATE_MEMBER(P_COLLECTION_NAME => P_COLLECTION_NAME,P_SEQ => 1,P_CLOB001 => P_DATA);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                APEX_COLLECTION.ADD_MEMBER(P_COLLECTION_NAME => P_COLLECTION_NAME,P_CLOB001 => P_DATA);
        END;

    END SET_COLLECTION;
  ------------------------------------------------------------------------------

    PROCEDURE GET_REPORT_XML (
        P_APP_ID            IN NUMBER,
        P_PAGE_ID           IN NUMBER,
        P_REGION_ID         IN NUMBER,
        P_RETURN_TYPE       IN CHAR DEFAULT 'X', -- "Q" for debug information, "X" for XML-Data
        P_GET_PAGE_ITEMS    IN CHAR DEFAULT 'N', -- Y,N - include page items in XML
        P_ITEMS_LIST        IN VARCHAR2,         -- "," delimetered list of items that for including in XML
        P_COLLECTION_NAME   IN VARCHAR2,         -- name of APEX COLLECTION to save XML, when null - download as file
        P_MAX_ROWS          IN NUMBER            -- maximum rows for export                            
    ) IS
        V_DATA   CLOB;
    BEGIN
        DBMS_LOB.TRIM(V_DEBUG,0);
        DBMS_LOB.CREATETEMPORARY(V_DATA,TRUE);
    --APEX_DEBUG_MESSAGE.ENABLE_DEBUG_MESSAGES(p_level => 7);
        LOG('version=1.6');
        LOG('p_app_id='
        || P_APP_ID);
        LOG('p_page_id='
        || P_PAGE_ID);
        LOG('p_region_id='
        || P_REGION_ID);
        LOG('p_return_type='
        || P_RETURN_TYPE);
        LOG('p_get_page_items='
        || P_GET_PAGE_ITEMS);
        LOG('p_items_list='
        || P_ITEMS_LIST);
        LOG('p_collection_name='
        || P_COLLECTION_NAME);
        LOG('p_max_rows='
        || P_MAX_ROWS);
        IF
            P_RETURN_TYPE = 'Q'
        THEN  -- debug information                    
            BEGIN
                INIT_T_REPORT(P_APP_ID,P_PAGE_ID,P_REGION_ID);
                GET_FINAL_XML(V_DATA,P_APP_ID,P_PAGE_ID,P_REGION_ID,P_ITEMS_LIST,P_GET_PAGE_ITEMS,P_MAX_ROWS);
                IF
                    P_COLLECTION_NAME IS NOT NULL
                THEN
                    SET_COLLECTION(UPPER(P_COLLECTION_NAME),V_DATA);
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    LOG('Error in IR_TO_XML.get_report_xml '
                    || SQLERRM
                    || CHR(10)
                    || CHR(10)
                    || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            END;

            LOG(' ',TRUE);
            DOWNLOAD_FILE(V_DEBUG,'text/txt','log.txt');
        ELSIF P_RETURN_TYPE = 'X' THEN --XML-Data
            INIT_T_REPORT(P_APP_ID,P_PAGE_ID,P_REGION_ID);
            GET_FINAL_XML(V_DATA,P_APP_ID,P_PAGE_ID,P_REGION_ID,P_ITEMS_LIST,P_GET_PAGE_ITEMS,P_MAX_ROWS);
            IF
                P_COLLECTION_NAME IS NOT NULL
            THEN
                SET_COLLECTION(UPPER(P_COLLECTION_NAME),V_DATA);
            ELSE
                DOWNLOAD_FILE(V_DATA,'application/xml','report_data.xml');
            END IF;

        ELSE
            RAISE_APPLICATION_ERROR(-20001,'Unknown parameter p_download_type='
            || P_RETURN_TYPE);
            DBMS_LOB.FREETEMPORARY(V_DATA);
        END IF;

        DBMS_LOB.FREETEMPORARY(V_DATA);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'get_report_xml:'
            || SQLERRM);
            RAISE;
    END GET_REPORT_XML; 
  ------------------------------------------------------------------------------

    FUNCTION GET_REPORT_XML (
        P_APP_ID           IN NUMBER,
        P_PAGE_ID          IN NUMBER,
        P_REGION_ID        IN NUMBER,
        P_GET_PAGE_ITEMS   IN CHAR DEFAULT 'N', -- Y,N - include page items in XML
        P_ITEMS_LIST       IN VARCHAR2,         -- "," delimetered list of items that for including in XML
        P_MAX_ROWS         IN NUMBER            -- maximum rows for export                            
    ) RETURN XMLTYPE IS
        V_DATA   CLOB;
    BEGIN
        DBMS_LOB.TRIM(V_DEBUG,0);
        DBMS_LOB.CREATETEMPORARY(V_DATA,TRUE,DBMS_LOB.CALL);
        LOG('p_app_id='
        || P_APP_ID);
        LOG('p_page_id='
        || P_PAGE_ID);
        LOG('p_get_page_items='
        || P_GET_PAGE_ITEMS);
        LOG('p_items_list='
        || P_ITEMS_LIST);
        LOG('p_max_rows='
        || P_MAX_ROWS);
        INIT_T_REPORT(P_APP_ID,P_PAGE_ID,P_REGION_ID);
        GET_FINAL_XML(V_DATA,P_APP_ID,P_PAGE_ID,P_REGION_ID,P_ITEMS_LIST,P_GET_PAGE_ITEMS,P_MAX_ROWS);
        RETURN XMLTYPE(V_DATA);
    END GET_REPORT_XML; 
  
  ------------------------------------------------------------------------------
  /* 
    function to handle cases of 'in' and 'not in' conditions for highlights
   	used in cursor cur_highlight
    
    Author: Srihari Ravva
  */

    FUNCTION GET_HIGHLIGHT_IN_COND_SQL (
        P_CONDITION_EXPRESSION    IN APEX_APPLICATION_PAGE_IR_COND.CONDITION_EXPRESSION%TYPE,
        P_CONDITION_SQL           IN APEX_APPLICATION_PAGE_IR_COND.CONDITION_SQL%TYPE,
        P_CONDITION_COLUMN_NAME   IN APEX_APPLICATION_PAGE_IR_COND.CONDITION_COLUMN_NAME%TYPE
    ) RETURN VARCHAR2 IS

        V_CONDITION_SQL_TMP   VARCHAR2(32767);
        V_CONDITION_SQL       VARCHAR2(32767);
        V_ARR_COND_EXPR       APEX_APPLICATION_GLOBAL.VC_ARR2;
        V_ARR_COND_SQL        APEX_APPLICATION_GLOBAL.VC_ARR2;
    BEGIN
        V_CONDITION_SQL := REPLACE(REPLACE(P_CONDITION_SQL,'#APXWS_HL_ID#','1'),'#APXWS_CC_EXPR#','"'
        || P_CONDITION_COLUMN_NAME
        || '"');

        V_CONDITION_SQL_TMP := SUBSTR(V_CONDITION_SQL,INSTR(V_CONDITION_SQL,'#'),INSTR(V_CONDITION_SQL,'#',-1) - INSTR(V_CONDITION_SQL,'#') + 1
);

        V_ARR_COND_EXPR := APEX_UTIL.STRING_TO_TABLE(P_CONDITION_EXPRESSION,',');
        V_ARR_COND_SQL := APEX_UTIL.STRING_TO_TABLE(V_CONDITION_SQL_TMP,',');
        FOR I IN 1..V_ARR_COND_EXPR.COUNT LOOP
		-- consider everything as varchar2
		-- 'in' and 'not in' highlight conditions are not possible for DATE columns from IR
            V_CONDITION_SQL := REPLACE(V_CONDITION_SQL,V_ARR_COND_SQL(I),''''
            || TO_CHAR(V_ARR_COND_EXPR(I) )
            || '''');
        END LOOP;

        RETURN V_CONDITION_SQL;
    END GET_HIGHLIGHT_IN_COND_SQL;

BEGIN
    DBMS_LOB.CREATETEMPORARY(V_DEBUG,TRUE,DBMS_LOB.CALL);
END IR_TO_XML;
/

