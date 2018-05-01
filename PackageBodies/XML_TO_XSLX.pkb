--
-- XML_TO_XSLX  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER."XML_TO_XSLX" IS

    STRING_HEIGHT            CONSTANT NUMBER DEFAULT 14.4;
    SUBTYPE T_COLOR IS VARCHAR2(7);
    SUBTYPE T_STYLE_STRING IS VARCHAR2(300);
    SUBTYPE T_FORMAT_MASK IS VARCHAR2(100);
    SUBTYPE T_FONT IS VARCHAR2(50);
    SUBTYPE T_LARGE_VARCHAR2 IS VARCHAR2(32767);
    BACK_COLOR               CONSTANT T_COLOR DEFAULT '#C6E0B4';
    TYPE T_STYLES IS
        TABLE OF BINARY_INTEGER INDEX BY T_STYLE_STRING;
    A_STYLES                 T_STYLES;
    TYPE T_COLOR_LIST IS
        TABLE OF BINARY_INTEGER INDEX BY T_COLOR;
    TYPE T_FONT_LIST IS
        TABLE OF BINARY_INTEGER INDEX BY T_FONT;
    A_FONT                   T_FONT_LIST;
    A_BACK_COLOR             T_COLOR_LIST;
    V_FONTS_XML              T_LARGE_VARCHAR2;
    V_BACK_XML               T_LARGE_VARCHAR2;
    V_STYLES_XML             CLOB;
    TYPE T_FORMAT_MASK_LIST IS
        TABLE OF BINARY_INTEGER INDEX BY T_FORMAT_MASK;
    A_FORMAT_MASK_LIST       T_FORMAT_MASK_LIST;
    V_FORMAT_MASK_XML        CLOB;
  
  ------------------------------------------------------------------------------
    T_SHEET_RELS             CLOB DEFAULT '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
  <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
    <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>
    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
    <Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>
  </Relationships>'
;
    T_WORKBOOK               CLOB DEFAULT '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
  <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
    <fileVersion appName="xl" lastEdited="4" lowestEdited="4" rupBuild="4506"/>
    <workbookPr filterPrivacy="1" defaultThemeVersion="124226"/>
    <bookViews>
      <workbookView xWindow="120" yWindow="120" windowWidth="24780" windowHeight="12150"/>
    </bookViews>
    <sheets>
      <sheet name="Sheet1" sheetId="1" r:id="rId1"/>
    </sheets>
    <definedNames><definedName name="_xlnm._FilterDatabase" localSheetId="0" hidden="1">Sheet1!$A$1:$H$1</definedName></definedNames>
    <calcPr calcId="125725"/>
    <fileRecoveryPr repairLoad="1"/>
  </workbook>'
;
    T_STYLE_TEMPLATE         CLOB DEFAULT '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
  <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac">
    #FORMAT_MASKS#
    #FONTS#
    #FILLS#
    <borders count="2">
      <border>
        <left/>
        <right/>
        <top/>
        <bottom/>
        <diagonal/>
      </border>
      <border>
        <left/>  
        <right/> 
          <top style="thin">
        <color indexed="64"/>
        </top>
        <bottom/>
        <diagonal/>
      </border>
    </borders>
    <cellStyleXfs count="1">
      <xf numFmtId="0" fontId="0" fillId="0" borderId="0" />
    </cellStyleXfs>
    #STYLES#
    <cellStyles count="1">
      <cellStyle name="Normal" xfId="0" builtinId="0"/>
    </cellStyles>
    <dxfs count="0"/>
    <tableStyles count="0" defaultTableStyle="TableStyleMedium9" defaultPivotStyle="PivotStyleLight16"/>
    <extLst>
      <ext uri="{EB79DEF2-80B8-43e5-95BD-54CBDDF9020C}" xmlns:x14="http://schemas.microsoft.com/office/spreadsheetml/2009/9/main">
        <x14:slicerStyles defaultSlicerStyle="SlicerStyleLight1"/>
      </ext>
    </extLst>
  </styleSheet>'
;
    DEFAULT_FONT             CONSTANT VARCHAR2(200) := '
   <font>
      <sz val="11" />
      <color theme="1" />
      <name val="Calibri" />
      <family val="2" />
      <scheme val="minor" />
    </font>'
;
    BOLD_FONT                CONSTANT VARCHAR2(200) := '
   <font>
      <b />
      <sz val="11" />
      <color theme="1" />
      <name val="Calibri" />
      <family val="2" />
      <scheme val="minor" />
    </font>'
;
    FONTS_CNT                CONSTANT BINARY_INTEGER := 2;
    DEFAULT_FILL             CONSTANT VARCHAR2(200) := '
    <fill>
      <patternFill patternType="none" />
    </fill>
    <fill>
      <patternFill patternType="gray125" />
    </fill>'
;
    DEFAULT_FILL_CNT         CONSTANT BINARY_INTEGER := 2;
    DEFAULT_STYLE            CONSTANT VARCHAR2(200) := '
      <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>';
    AGGREGATE_STYLE          CONSTANT VARCHAR2(250) := '
      <xf numFmtId="#FMTID#" borderId="1" fillId="0" fontId="1" xfId="0" applyAlignment="1" applyFont="1" applyBorder="1">
         <alignment wrapText="1" horizontal="right"  vertical="top"/>
     </xf>'
;
    HEADER_STYLE             CONSTANT VARCHAR2(200) := '     
      <xf numFmtId="0" borderId="0" #FILL# fontId="1" xfId="0" applyAlignment="1" applyFont="1" >
         <alignment wrapText="0" horizontal="#ALIGN#"/>
     </xf>'
;
    DEFAULT_STYLES_CNT       CONSTANT BINARY_INTEGER := 1;
    FORMAT_MASK_START_WITH   CONSTANT BINARY_INTEGER := 164;
    FORMAT_MASK              CONSTANT VARCHAR2(100) := '
      <numFmt numFmtId="'
    || FORMAT_MASK_START_WITH
    || '" formatCode="dd.mm.yyyy"/>';
    FORMAT_MASK_CNT          CONSTANT BINARY_INTEGER DEFAULT 1;
    CURSOR CUR_ROW (
        P_XML XMLTYPE
    ) IS SELECT
        ROWNUM COLL_NUM,
        EXTRACTVALUE(COLUMN_VALUE,'CELL/@background-color') AS BACKGROUND_COLOR,
        EXTRACTVALUE(COLUMN_VALUE,'CELL/@color') AS FONT_COLOR,
        EXTRACTVALUE(COLUMN_VALUE,'CELL/@data-type') AS DATA_TYPE,
        EXTRACTVALUE(COLUMN_VALUE,'CELL/@value') AS CELL_VALUE,
        EXTRACTVALUE(COLUMN_VALUE,'CELL') AS CELL_TEXT
         FROM
        TABLE (
            SELECT
                XMLSEQUENCE(EXTRACT(P_XML,'DOCUMENT/DATA/ROWSET/ROW/CELL') )
            FROM
                DUAL
        );
  ------------------------------------------------------------------------------

    FUNCTION CONVERT_DATE_FORMAT (
        P_FORMAT IN VARCHAR2
    ) RETURN VARCHAR2 IS
        V_STR   VARCHAR2(100);
    BEGIN
        V_STR := P_FORMAT;
        V_STR := UPPER(V_STR);
    --date
        V_STR := REPLACE(V_STR,'DAY','DDDD');
        V_STR := REPLACE(V_STR,'MONTH','MMMM');
        V_STR := REPLACE(V_STR,'MON','MMM');
        V_STR := REPLACE(V_STR,'R','Y');
        V_STR := REPLACE(V_STR,'FM','');
        V_STR := REPLACE(V_STR,'PM',' AM/PM');
    --time
        V_STR := REPLACE(V_STR,'MI','mm');
        V_STR := REPLACE(V_STR,'SS','ss');
        V_STR := REPLACE(V_STR,'HH24','hh');
    --v_str := regexp_replace(v_str,'(\W)','\\\1');
        V_STR := REGEXP_REPLACE(V_STR,'HH12([^ ]+)','h\1 AM/PM');
        V_STR := REPLACE(V_STR,'AM\/PM',' AM/PM');
        RETURN V_STR;
    END CONVERT_DATE_FORMAT;
  ------------------------------------------------------------------------------

    FUNCTION CONVERT_NUMBER_FORMAT (
        P_FORMAT IN VARCHAR2
    ) RETURN VARCHAR2 IS
        V_STR   VARCHAR2(100);
    BEGIN
        V_STR := P_FORMAT;
        V_STR := UPPER(V_STR);
    --number
        V_STR := REPLACE(V_STR,'9','#');
        V_STR := REPLACE(V_STR,'D','.');
        V_STR := REPLACE(V_STR,'G',',');
        V_STR := REPLACE(V_STR,'FM','');
    --currency
        V_STR := REPLACE(V_STR,'L',CONVERT('&quot;'
        || RTRIM(TO_CHAR(0,'FML0'),'0')
        || '&quot;','UTF8') );

        V_STR := REGEXP_SUBSTR(V_STR,'.G?[^G]+$');
        RETURN V_STR;
    END CONVERT_NUMBER_FORMAT;  
  ------------------------------------------------------------------------------

    FUNCTION ADD_FONT (
        P_FONT   IN T_COLOR,
        P_BOLD   IN VARCHAR2 DEFAULT NULL
    ) RETURN BINARY_INTEGER IS
        V_INDEX   T_FONT;
    BEGIN
        V_INDEX := P_FONT
        || P_BOLD;
        IF
            NOT A_FONT.EXISTS(V_INDEX)
        THEN
            A_FONT(V_INDEX) := A_FONT.COUNT + 1;
            V_FONTS_XML := V_FONTS_XML
            || '<font>'
            || CHR(10)
            || '   <sz val="11" />'
            || CHR(10)
            || '   <color rgb="'
            || LTRIM(P_FONT,'#')
            || '" />'
            || CHR(10)
            || '   <name val="Calibri" />'
            || CHR(10)
            || '   <family val="2" />'
            || CHR(10)
            || '   <scheme val="minor" />'
            || '</font>'
            || CHR(10);

            RETURN A_FONT.COUNT + FONTS_CNT - 1; --start with 0
        ELSE
            RETURN A_FONT(V_INDEX) + FONTS_CNT - 1;
        END IF;

    END ADD_FONT;
  ------------------------------------------------------------------------------

    FUNCTION ADD_BACK_COLOR (
        P_BACK IN T_COLOR
    ) RETURN BINARY_INTEGER
        IS
    BEGIN
        IF
            NOT A_BACK_COLOR.EXISTS(P_BACK)
        THEN
            A_BACK_COLOR(P_BACK) := A_BACK_COLOR.COUNT + 1;
            V_BACK_XML := V_BACK_XML
            || '<fill>'
            || CHR(10)
            || '   <patternFill patternType="solid">'
            || CHR(10)
            || '     <fgColor rgb="'
            || LTRIM(P_BACK,'#')
            || '" />'
            || CHR(10)
            || '     <bgColor indexed="64" />'
            || CHR(10)
            || '   </patternFill>'
            || '</fill>'
            || CHR(10);

            RETURN A_BACK_COLOR.COUNT + DEFAULT_FILL_CNT - 1; --start with 0
        ELSE
            RETURN A_BACK_COLOR(P_BACK) + DEFAULT_FILL_CNT - 1;
        END IF;
    END ADD_BACK_COLOR;
  ------------------------------------------------------------------------------

    FUNCTION ADD_FORMAT_MASK (
        P_MASK IN VARCHAR2
    ) RETURN BINARY_INTEGER
        IS
    BEGIN
        IF
            NOT A_FORMAT_MASK_LIST.EXISTS(P_MASK)
        THEN
            A_FORMAT_MASK_LIST(P_MASK) := A_FORMAT_MASK_LIST.COUNT + 1;
            V_FORMAT_MASK_XML := V_FORMAT_MASK_XML
            || '<numFmt numFmtId="'
            || ( FORMAT_MASK_START_WITH + A_FORMAT_MASK_LIST.COUNT )
            || '" formatCode="'
            || P_MASK
            || '"/>'
            || CHR(10);

            RETURN A_FORMAT_MASK_LIST.COUNT + FORMAT_MASK_CNT + FORMAT_MASK_START_WITH - 1;
        ELSE
            RETURN A_FORMAT_MASK_LIST(P_MASK) + FORMAT_MASK_CNT + FORMAT_MASK_START_WITH - 1;
        END IF;
    END ADD_FORMAT_MASK;  
  ------------------------------------------------------------------------------

    FUNCTION GET_FONT_COLORS_XML RETURN CLOB
        IS
    BEGIN
        RETURN TO_CLOB('<fonts count="'
        || (A_FONT.COUNT + FONTS_CNT)
        || '" x14ac:knownFonts="1">'
        || DEFAULT_FONT
        || CHR(10)
        || BOLD_FONT
        || CHR(10)
        || V_FONTS_XML
        || CHR(10)
        || '</fonts>'
        || CHR(10) );
    END GET_FONT_COLORS_XML;  
  ------------------------------------------------------------------------------

    FUNCTION GET_BACK_COLORS_XML RETURN CLOB
        IS
    BEGIN
        RETURN TO_CLOB('<fills count="'
        || (A_BACK_COLOR.COUNT + DEFAULT_FILL_CNT)
        || '">'
        || DEFAULT_FILL
        || V_BACK_XML
        || CHR(10)
        || '</fills>'
        || CHR(10) );
    END GET_BACK_COLORS_XML;  
  ------------------------------------------------------------------------------  

    FUNCTION GET_FORMAT_MASK_XML RETURN CLOB
        IS
    BEGIN
        RETURN TO_CLOB('<numFmts count="'
        || (A_FORMAT_MASK_LIST.COUNT + FORMAT_MASK_CNT)
        || '">'
        || FORMAT_MASK
        || V_FORMAT_MASK_XML
        || CHR(10)
        || '</numFmts>'
        || CHR(10) );
    END GET_FORMAT_MASK_XML;  
  ------------------------------------------------------------------------------  

    FUNCTION GET_CELLXFS_XML RETURN CLOB
        IS
    BEGIN
        RETURN TO_CLOB('<cellXfs count="'
        || (A_STYLES.COUNT + DEFAULT_STYLES_CNT)
        || '">'
        || DEFAULT_STYLE
        || CHR(10)
        || V_STYLES_XML
        || CHR(10)
        || '</cellXfs>'
        || CHR(10) );
    END GET_CELLXFS_XML;
  ------------------------------------------------------------------------------  

    FUNCTION GET_NUM_FMT_ID (
        P_DATA_TYPE     IN VARCHAR2,
        P_FORMAT_MASK   IN VARCHAR2
    ) RETURN BINARY_INTEGER
        IS
    BEGIN
        IF
            P_DATA_TYPE = 'NUMBER'
        THEN
            IF
                P_FORMAT_MASK IS NULL
            THEN
                RETURN 0;
            ELSE
                RETURN ADD_FORMAT_MASK(CONVERT_NUMBER_FORMAT(P_FORMAT_MASK) );
            END IF;

        ELSIF P_DATA_TYPE = 'DATE' THEN
            IF
                P_FORMAT_MASK IS NULL
            THEN
                RETURN FORMAT_MASK_START_WITH;  -- default date format
            ELSE
                RETURN ADD_FORMAT_MASK(CONVERT_DATE_FORMAT(P_FORMAT_MASK) );
            END IF;
        ELSE
            RETURN 2;  -- default  string format
        END IF;
    END GET_NUM_FMT_ID;  
  ------------------------------------------------------------------------------  
  -- get style_id for existent styles or 
  -- add new style and return style_id

    FUNCTION GET_STYLE_ID (
        P_FONT          IN T_COLOR,
        P_BACK          IN T_COLOR,
        P_DATA_TYPE     IN VARCHAR2,
        P_FORMAT_MASK   IN VARCHAR2,
        P_ALIGN         IN VARCHAR2
    ) RETURN BINARY_INTEGER IS
        V_STYLE           T_STYLE_STRING;
        V_FONT_COLOR_ID   BINARY_INTEGER;
        V_BACK_COLOR_ID   BINARY_INTEGER;
        V_STYLE_XML       T_LARGE_VARCHAR2;
    BEGIN
        V_STYLE := NVL(P_FONT,'      ')
        || NVL(P_BACK,'       ')
        || P_DATA_TYPE
        || P_FORMAT_MASK
        || P_ALIGN;
    --   

        IF
            A_STYLES.EXISTS(V_STYLE)
        THEN
            RETURN A_STYLES(V_STYLE) - 1 + DEFAULT_STYLES_CNT;
        ELSE
            A_STYLES(V_STYLE) := A_STYLES.COUNT + 1;
            V_STYLE_XML := '<xf borderId="0" xfId="0" ';
            V_STYLE_XML := V_STYLE_XML
            || REPLACE(' numFmtId="#FMTID#" ','#FMTID#',GET_NUM_FMT_ID(P_DATA_TYPE,P_FORMAT_MASK) );

            IF
                P_FONT IS NOT NULL
            THEN
                V_FONT_COLOR_ID := ADD_FONT(P_FONT);
                V_STYLE_XML := V_STYLE_XML
                || ' fontId="'
                || V_FONT_COLOR_ID
                || '"  applyFont="1" ';
            ELSE
                V_STYLE_XML := V_STYLE_XML
                || ' fontId="0" '; --default font
            END IF;

            IF
                P_BACK IS NOT NULL
            THEN
                V_BACK_COLOR_ID := ADD_BACK_COLOR(P_BACK);
                V_STYLE_XML := V_STYLE_XML
                || ' fillId="'
                || V_BACK_COLOR_ID
                || '"  applyFill="1" ';
            ELSE
                V_STYLE_XML := V_STYLE_XML
                || ' fillId="0" '; --default fill 
            END IF;

            V_STYLE_XML := V_STYLE_XML
            || '>'
            || CHR(10);
            V_STYLE_XML := V_STYLE_XML
            || '<alignment wrapText="1"';
            IF
                P_ALIGN IS NOT NULL
            THEN
                V_STYLE_XML := V_STYLE_XML
                || ' horizontal="'
                || LOWER(P_ALIGN)
                || '" ';
            END IF;

            V_STYLE_XML := V_STYLE_XML
            || '/>'
            || CHR(10);
            V_STYLE_XML := V_STYLE_XML
            || '</xf>'
            || CHR(10);
            V_STYLES_XML := V_STYLES_XML
            || TO_CLOB(V_STYLE_XML);
            RETURN A_STYLES.COUNT - 1 + DEFAULT_STYLES_CNT;
        END IF;

    END GET_STYLE_ID;
  ------------------------------------------------------------------------------  
  -- get style_id for existent styles or 
  -- add new style and return style_id

    FUNCTION GET_AGGREGATE_STYLE_ID (
        P_FONT          IN T_COLOR,
        P_BACK          IN T_COLOR,
        P_DATA_TYPE     IN VARCHAR2,
        P_FORMAT_MASK   IN VARCHAR2
    ) RETURN BINARY_INTEGER IS
        V_STYLE        T_STYLE_STRING;
        V_STYLE_XML    T_LARGE_VARCHAR2;
        V_NUM_FMT_ID   BINARY_INTEGER;
    BEGIN
        V_STYLE := NVL(P_FONT,'      ')
        || NVL(P_BACK,'       ')
        || P_DATA_TYPE
        || P_FORMAT_MASK
        || 'AGGREGATE';
    --   

        IF
            A_STYLES.EXISTS(V_STYLE)
        THEN
            RETURN A_STYLES(V_STYLE) - 1 + DEFAULT_STYLES_CNT;
        ELSE
            A_STYLES(V_STYLE) := A_STYLES.COUNT + 1;
            V_STYLE_XML := REPLACE(AGGREGATE_STYLE,'#FMTID#',GET_NUM_FMT_ID(P_DATA_TYPE,P_FORMAT_MASK) )
            || CHR(10);

            V_STYLES_XML := V_STYLES_XML
            || V_STYLE_XML;
            RETURN A_STYLES.COUNT - 1 + DEFAULT_STYLES_CNT;
        END IF;

    END GET_AGGREGATE_STYLE_ID;  
  ------------------------------------------------------------------------------

    FUNCTION GET_HEADER_STYLE_ID (
        P_BACK     IN T_COLOR DEFAULT BACK_COLOR,
        P_ALIGN    IN VARCHAR2,
        P_BORDER   IN BOOLEAN DEFAULT FALSE
    ) RETURN BINARY_INTEGER IS
        V_STYLE           T_STYLE_STRING;
        V_STYLE_XML       T_LARGE_VARCHAR2;
        V_NUM_FMT_ID      BINARY_INTEGER;
        V_BACK_COLOR_ID   BINARY_INTEGER;
    BEGIN
        V_STYLE := '      '
        || NVL(P_BACK,'       ')
        || 'CHARHEADER'
        || P_ALIGN;
    --   

        IF
            A_STYLES.EXISTS(V_STYLE)
        THEN
            RETURN A_STYLES(V_STYLE) - 1 + DEFAULT_STYLES_CNT;
        ELSE
            A_STYLES(V_STYLE) := A_STYLES.COUNT + 1;
            IF
                P_BACK IS NOT NULL
            THEN
                V_BACK_COLOR_ID := ADD_BACK_COLOR(P_BACK);
                V_STYLE_XML := REPLACE(HEADER_STYLE,'#FILL#',' fillId="'
                || V_BACK_COLOR_ID
                || '"  applyFill="1" ');
            ELSE
                V_STYLE_XML := REPLACE(HEADER_STYLE,'#FILL#',' fillId="0" '); --default fill 
            END IF;

            V_STYLE_XML := REPLACE(V_STYLE_XML,'#ALIGN#',LOWER(P_ALIGN) )
            || CHR(10);

            V_STYLES_XML := V_STYLES_XML
            || V_STYLE_XML;
            RETURN A_STYLES.COUNT - 1 + DEFAULT_STYLES_CNT;
        END IF;

    END GET_HEADER_STYLE_ID;    
  ------------------------------------------------------------------------------

    FUNCTION GET_STYLES_XML RETURN CLOB IS
        V_TEMPLATE   CLOB;
    BEGIN
        V_TEMPLATE := REPLACE(T_STYLE_TEMPLATE,'#FORMAT_MASKS#',GET_FORMAT_MASK_XML);
        V_TEMPLATE := REPLACE(V_TEMPLATE,'#FONTS#',GET_FONT_COLORS_XML);
        V_TEMPLATE := REPLACE(V_TEMPLATE,'#FILLS#',GET_BACK_COLORS_XML);
        V_TEMPLATE := REPLACE(V_TEMPLATE,'#STYLES#',GET_CELLXFS_XML);
        RETURN V_TEMPLATE;
    END GET_STYLES_XML;
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
            NVL(LENGTHB(P_VC_BUFFER),0) + NVL(LENGTHB(P_VC_ADDITION),0) < ( 32767 / 2 )
        THEN
      -- Danke f?r Frank Menne wegen utf-8
            P_VC_BUFFER := P_VC_BUFFER
            || CONVERT(P_VC_ADDITION,'utf8');
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

    FUNCTION GET_CELL_NAME (
        P_COL   IN BINARY_INTEGER,
        P_ROW   IN BINARY_INTEGER
    ) RETURN VARCHAR2
        IS
    BEGIN
  /*
   Author: Moritz Klein (https://github.com/commi235)
   https://github.com/commi235/xlsx_builder/blob/master/xlsx_builder_pkg.pkb
  */
        RETURN CASE
            WHEN P_COL > 702 THEN CHR(64 + TRUNC( (P_COL - 27) / 676) )
            || CHR(65 + MOD(TRUNC( (P_COL - 1) / 26) - 1,26) )
            || CHR(65 + MOD(P_COL - 1,26) )
            WHEN P_COL > 26 THEN CHR(64 + TRUNC( (P_COL - 1) / 26) )
            || CHR(65 + MOD(P_COL - 1,26) )
            ELSE CHR(64 + P_COL)
        END
        || P_ROW;
    END GET_CELL_NAME;
  ------------------------------------------------------------------------------  

    FUNCTION GET_COLLS_WIDTH_XML (
        P_WIDTH_STR     IN VARCHAR2,
        P_XML           IN XMLTYPE,
        P_COEFFICIENT   IN NUMBER
    ) RETURN CLOB IS
        V_XML                   CLOB;
        A_COL_NAME_PLUS_WIDTH   APEX_APPLICATION_GLOBAL.VC_ARR2;
        V_COL_WIDTH             NUMBER;
        V_COEFFICIENT           NUMBER;
    BEGIN
        A_COL_NAME_PLUS_WIDTH := APEX_UTIL.STRING_TO_TABLE(RTRIM(P_WIDTH_STR,','),',');
        V_COEFFICIENT := NVL(P_COEFFICIENT,WIDTH_COEFFICIENT);
        IF
            V_COEFFICIENT = 0
        THEN
            V_COEFFICIENT := WIDTH_COEFFICIENT;
        END IF;     
    --set column width
        V_XML := V_XML
        || TO_CLOB('<cols>'
        || CHR(10) );
        FOR I IN (
            SELECT
                ROWNUM RN
            FROM
                TABLE (
                    SELECT
                        XMLSEQUENCE(EXTRACT(P_XML,'DOCUMENT/DATA/HEADER/CELL') )
                    FROM
                        DUAL
                )
        ) LOOP
            BEGIN
                V_COL_WIDTH := ROUND(TO_NUMBER(A_COL_NAME_PLUS_WIDTH(I.RN) ) / V_COEFFICIENT);
            EXCEPTION
                WHEN OTHERS THEN
                    V_COL_WIDTH :=-1;
            END;

            IF
                V_COL_WIDTH >= 0
            THEN
                V_XML := V_XML
                || TO_CLOB('<col min="'
                || I.RN
                || '" max="'
                || I.RN
                || '" width="'
                || V_COL_WIDTH
                || '" customWidth="1" />'
                || CHR(10) );

            ELSE
                V_XML := V_XML
                || TO_CLOB('<col min="'
                || I.RN
                || '" max="'
                || I.RN
                || '" width="10" customWidth="0" />'
                || CHR(10) );
            END IF;

        END LOOP;

        V_XML := V_XML
        || TO_CLOB('</cols>'
        || CHR(10) );
        RETURN V_XML;
    END GET_COLLS_WIDTH_XML;
 
  ------------------------------------------------------------------------------  

    PROCEDURE ADD1FILE (
        P_ZIPPED_BLOB IN OUT BLOB,
        P_NAME      IN VARCHAR2,
        P_CONTENT   IN CLOB
    ) IS

        V_DESC_OFFSET   PLS_INTEGER := 1;
        V_SRC_OFFSET    PLS_INTEGER := 1;
        V_LANG          PLS_INTEGER := 0;
        V_WARNING       PLS_INTEGER := 0;
        V_BLOB          BLOB;
    BEGIN
        DBMS_LOB.CREATETEMPORARY(V_BLOB,TRUE);
        DBMS_LOB.CONVERTTOBLOB(V_BLOB,P_CONTENT,DBMS_LOB.GETLENGTH(P_CONTENT),V_DESC_OFFSET,V_SRC_OFFSET,DBMS_LOB.DEFAULT_CSID,V_LANG,V_WARNING
);

        AS_ZIP.ADD1FILE(P_ZIPPED_BLOB,P_NAME,V_BLOB);
        DBMS_LOB.FREETEMPORARY(V_BLOB);
    END ADD1FILE;  
  ------------------------------------------------------------------------------

    PROCEDURE GET_EXCEL (
        P_XML            IN XMLTYPE,
        V_CLOB           IN OUT NOCOPY CLOB,
        V_STRINGS_CLOB   IN OUT NOCOPY CLOB,
        P_WIDTH_STR      IN VARCHAR2,
        P_COEFFICIENT    IN NUMBER
    ) IS

        V_STRINGS           APEX_APPLICATION_GLOBAL.VC_ARR2;
        V_ROWNUM            BINARY_INTEGER DEFAULT 1;
        V_COLLS_COUNT       BINARY_INTEGER DEFAULT 0;
        V_AGG_CLOB          CLOB;
        V_AGG_STRINGS_CNT   BINARY_INTEGER DEFAULT 1;
        V_STYLE_ID          BINARY_INTEGER;
        V_BUFFER            T_LARGE_VARCHAR2;
        V_AGG_BUFFER        T_LARGE_VARCHAR2;
        V_STRING_BUFFER     T_LARGE_VARCHAR2;
    --

        PROCEDURE PRINT_CHAR_CELL (
            P_COLL       IN BINARY_INTEGER,
            P_ROW        IN BINARY_INTEGER,
            P_STRING     IN VARCHAR2,
            P_CLOB       IN OUT NOCOPY CLOB,
            P_BUFFER     IN OUT NOCOPY VARCHAR2,
            P_STYLE_ID   IN NUMBER DEFAULT NULL
        ) IS
            V_STYLE   VARCHAR2(20);
        BEGIN
            IF
                P_STYLE_ID IS NOT NULL
            THEN
                V_STYLE := ' s="'
                || P_STYLE_ID
                || '" ';
            END IF;

            ADD(P_CLOB,P_BUFFER,'<c r="'
            || GET_CELL_NAME(P_COLL,P_ROW)
            || '" t="s" '
            || V_STYLE
            || '>'
            || CHR(10)
            || '<v>'
            || TO_CHAR(V_STRINGS.COUNT)
            || '</v>'
            || CHR(10)
            || '</c>'
            || CHR(10) );

            V_STRINGS(V_STRINGS.COUNT + 1) := P_STRING;
        END PRINT_CHAR_CELL;
    --

        PROCEDURE PRINT_NUMBER_CELL (
            P_COLL       IN BINARY_INTEGER,
            P_ROW        IN BINARY_INTEGER,
            P_VALUE      IN VARCHAR2,
            P_CLOB       IN OUT NOCOPY CLOB,
            P_BUFFER     IN OUT NOCOPY VARCHAR2,
            P_STYLE_ID   IN NUMBER DEFAULT NULL
        ) IS
            V_STYLE   VARCHAR2(20);
        BEGIN
            IF
                P_STYLE_ID IS NOT NULL
            THEN
                V_STYLE := ' s="'
                || P_STYLE_ID
                || '" ';
            END IF;

            ADD(P_CLOB,P_BUFFER,'<c r="'
            || GET_CELL_NAME(P_COLL,P_ROW)
            || '" '
            || V_STYLE
            || '>'
            || CHR(10)
            || '<v>'
            || P_VALUE
            || '</v>'
            || CHR(10)
            || '</c>'
            || CHR(10) );

        END PRINT_NUMBER_CELL;
    --

    BEGIN PRAGMA INLINE ( ADD,'YES' ); PRAGMA INLINE ( GET_CELL_NAME,'YES' );
        DBMS_LOB.CREATETEMPORARY(V_AGG_CLOB,TRUE);
     
     --!
        ADD(V_CLOB,V_BUFFER,'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        || CHR(10) );
        ADD(V_CLOB,V_BUFFER,'<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
        <dimension ref="A1"/>
        <sheetViews>
          <sheetView tabSelected="1" workbookViewId="0">
            <pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/>
            <selection pane="bottomLeft" activeCell="A2" sqref="A2"/>
           </sheetView>
          </sheetViews>
        <sheetFormatPr baseColWidth="10" defaultColWidth="10" defaultRowHeight="15"/>'
        || CHR(10),TRUE);
        V_CLOB := V_CLOB
        || GET_COLLS_WIDTH_XML(P_WIDTH_STR,P_XML,P_COEFFICIENT);
     --!
        ADD(V_CLOB,V_BUFFER,'<sheetData>'
        || CHR(10) );
     --column header
        ADD(V_CLOB,V_BUFFER,'<row>'
        || CHR(10) );
        FOR I IN (
            SELECT
                EXTRACTVALUE(COLUMN_VALUE,'CELL') AS COLUMN_HEADER,
                EXTRACTVALUE(COLUMN_VALUE,'CELL/@header_align') AS ALIGN
            FROM
                TABLE (
                    SELECT
                        XMLSEQUENCE(EXTRACT(P_XML,'DOCUMENT/DATA/HEADER/CELL') )
                    FROM
                        DUAL
                )
        ) LOOP
            V_COLLS_COUNT := V_COLLS_COUNT + 1;
            PRINT_CHAR_CELL(P_COLL => V_COLLS_COUNT,P_ROW => V_ROWNUM,P_STRING => I.COLUMN_HEADER,P_CLOB => V_CLOB,P_BUFFER => V_BUFFER,P_STYLE_ID => GET_HEADER_STYLE_ID
(P_ALIGN => I.ALIGN) );

        END LOOP;

        V_ROWNUM := V_ROWNUM + 1;
        ADD(V_CLOB,V_BUFFER,'</row>'
        || CHR(10) );
        << ROWSET >> FOR ROWSET_XML IN (
            SELECT
                COLUMN_VALUE AS ROWSET,
                EXTRACTVALUE(COLUMN_VALUE,'ROWSET/BREAK_HEADER') AS BREAK_HEADER
            FROM
                TABLE (
                    SELECT
                        XMLSEQUENCE(EXTRACT(P_XML,'DOCUMENT/DATA/ROWSET') )
                    FROM
                        DUAL
                )
        ) LOOP
       --break header
            IF
                ROWSET_XML.BREAK_HEADER IS NOT NULL
            THEN
                ADD(V_CLOB,V_BUFFER,'<row>'
                || CHR(10) );
                PRINT_CHAR_CELL(P_COLL => 1,P_ROW => V_ROWNUM,P_STRING => ROWSET_XML.BREAK_HEADER,P_CLOB => V_CLOB,P_BUFFER => V_BUFFER,P_STYLE_ID => GET_HEADER_STYLE_ID
(P_BACK => NULL,P_ALIGN => 'left') );

                V_ROWNUM := V_ROWNUM + 1;
                ADD(V_CLOB,V_BUFFER,'</row>'
                || CHR(10) );
            END IF;

            << CELLS >> FOR ROW_XML IN (
                SELECT
                    COLUMN_VALUE AS ROW_
                FROM
                    TABLE (
                        SELECT
                            XMLSEQUENCE(EXTRACT(ROWSET_XML.ROWSET,'ROWSET/ROW') )
                        FROM
                            DUAL
                    )
            ) LOOP
                ADD(V_CLOB,V_BUFFER,'<row>'
                || CHR(10) );
                FOR CELL_XML IN (
                    SELECT
                        ROWNUM COLL_NUM,
                        EXTRACTVALUE(COLUMN_VALUE,'CELL/@background-color') AS BACKGROUND_COLOR,
                        EXTRACTVALUE(COLUMN_VALUE,'CELL/@color') AS FONT_COLOR,
                        EXTRACTVALUE(COLUMN_VALUE,'CELL/@data-type') AS DATA_TYPE,
                        EXTRACTVALUE(COLUMN_VALUE,'CELL/@value') AS CELL_VALUE,
                        EXTRACTVALUE(COLUMN_VALUE,'CELL/@format_mask') AS FORMAT_MASK,
                        EXTRACTVALUE(COLUMN_VALUE,'CELL/@align') AS ALIGN,
                        EXTRACTVALUE(COLUMN_VALUE,'CELL') AS CELL_TEXT
                    FROM
                        TABLE (
                            SELECT
                                XMLSEQUENCE(EXTRACT(ROW_XML.ROW_,'ROW/CELL') )
                            FROM
                                DUAL
                        )
                ) LOOP
                    BEGIN
                        V_STYLE_ID := GET_STYLE_ID(P_FONT => CELL_XML.FONT_COLOR,P_BACK => CELL_XML.BACKGROUND_COLOR,P_DATA_TYPE => CELL_XML.DATA_TYPE,P_FORMAT_MASK
=> CELL_XML.FORMAT_MASK,P_ALIGN => CELL_XML.ALIGN);

                        IF
                            CELL_XML.DATA_TYPE IN (
                                'NUMBER'
                            )
                        THEN
                            PRINT_NUMBER_CELL(P_COLL => CELL_XML.COLL_NUM,P_ROW => V_ROWNUM,P_VALUE => CELL_XML.CELL_VALUE,P_CLOB => V_CLOB,P_BUFFER => V_BUFFER,P_STYLE_ID
=> V_STYLE_ID);

                        ELSIF CELL_XML.DATA_TYPE IN (
                            'DATE'
                        ) THEN
                            ADD(V_CLOB,V_BUFFER,'<c r="'
                            || GET_CELL_NAME(CELL_XML.COLL_NUM,V_ROWNUM)
                            || '"  s="'
                            || V_STYLE_ID
                            || '">'
                            || CHR(10)
                            || '<v>'
                            || CELL_XML.CELL_VALUE
                            || '</v>'
                            || CHR(10)
                            || '</c>'
                            || CHR(10) );
                        ELSE --STRING
                            PRINT_CHAR_CELL(P_COLL => CELL_XML.COLL_NUM,P_ROW => V_ROWNUM,P_STRING => CELL_XML.CELL_TEXT,P_CLOB => V_CLOB,P_BUFFER => V_BUFFER,P_STYLE_ID
=> V_STYLE_ID);
                        END IF;

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END LOOP;

                ADD(V_CLOB,V_BUFFER,'</row>'
                || CHR(10) );
                V_ROWNUM := V_ROWNUM + 1;
            END LOOP CELLS;

            DBMS_LOB.TRIM(V_AGG_CLOB,0);
            V_AGG_BUFFER := '';
            V_AGG_STRINGS_CNT := 1;
            << AGGREGATES >> FOR ROW_XML IN (
                SELECT
                    COLUMN_VALUE AS ROW_
                FROM
                    TABLE (
                        SELECT
                            XMLSEQUENCE(EXTRACT(ROWSET_XML.ROWSET,'ROWSET/AGGREGATE') )
                        FROM
                            DUAL
                    )
            ) LOOP
                FOR CELL_XML_AGG IN (
                    SELECT
                        ROWNUM COLL_NUM,
                        EXTRACTVALUE(COLUMN_VALUE,'CELL') AS CELL_TEXT,
                        EXTRACTVALUE(COLUMN_VALUE,'CELL/@value') AS CELL_VALUE,
                        EXTRACTVALUE(COLUMN_VALUE,'CELL/@format_mask') AS FORMAT_MASK
                    FROM
                        TABLE (
                            SELECT
                                XMLSEQUENCE(EXTRACT(ROW_XML.ROW_,'AGGREGATE/CELL') )
                            FROM
                                DUAL
                        )
                ) LOOP
                    V_AGG_STRINGS_CNT := GREATEST(LENGTH(REGEXP_REPLACE('[^:]','') ) + 1,V_AGG_STRINGS_CNT);

                    V_STYLE_ID := GET_AGGREGATE_STYLE_ID(P_FONT => '',P_BACK => '',P_DATA_TYPE => 'CHAR',P_FORMAT_MASK => '');

                    PRINT_CHAR_CELL(P_COLL => CELL_XML_AGG.COLL_NUM,P_ROW => V_ROWNUM,P_STRING => RTRIM(CELL_XML_AGG.CELL_TEXT,CHR(10) ),P_CLOB => V_AGG_CLOB,
P_BUFFER => V_AGG_BUFFER,P_STYLE_ID => V_STYLE_ID);

                END LOOP;

                ADD(V_CLOB,V_BUFFER,'<row ht="'
                || (V_AGG_STRINGS_CNT * STRING_HEIGHT)
                || '">'
                || CHR(10),TRUE);

                ADD(V_AGG_CLOB,V_AGG_BUFFER,' ',TRUE);
                DBMS_LOB.COPY(DEST_LOB => V_CLOB,SRC_LOB => V_AGG_CLOB,AMOUNT => DBMS_LOB.GETLENGTH(V_AGG_CLOB),DEST_OFFSET => DBMS_LOB.GETLENGTH(V_CLOB)
,SRC_OFFSET => 1);

                ADD(V_CLOB,V_BUFFER,'</row>'
                || CHR(10) );
                V_ROWNUM := V_ROWNUM + 1;
            END LOOP AGGREGATES;

        END LOOP ROWSET;

        ADD(V_CLOB,V_BUFFER,'</sheetData>'
        || CHR(10) );
     --if p_autofilter then
        ADD(V_CLOB,V_BUFFER,'<autoFilter ref="A1:'
        || GET_CELL_NAME(V_COLLS_COUNT,V_ROWNUM)
        || '"/>');
     --end if;

        ADD(V_CLOB,V_BUFFER,'<pageMargins left="0.7" right="0.7" top="0.75" bottom="0.75" header="0.3" footer="0.3"/></worksheet>'
        || CHR(10),TRUE);
        ADD(V_STRINGS_CLOB,V_STRING_BUFFER,'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        || CHR(10) );
        ADD(V_STRINGS_CLOB,V_STRING_BUFFER,'<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="'
        || V_STRINGS.COUNT()
        || '" uniqueCount="'
        || V_STRINGS.COUNT()
        || '">'
        || CHR(10) );

        FOR I IN 1..V_STRINGS.COUNT () LOOP
            ADD(V_STRINGS_CLOB,V_STRING_BUFFER,'<si><t>'
            || DBMS_XMLGEN.CONVERT(SUBSTR(V_STRINGS(I),1,32000) )
            || '</t></si>'
            || CHR(10) );
        END LOOP;

        ADD(V_STRINGS_CLOB,V_STRING_BUFFER,'</sst>'
        || CHR(10),TRUE);
        DBMS_LOB.FREETEMPORARY(V_AGG_CLOB);
    END GET_EXCEL;
  ------------------------------------------------------------------------------

    FUNCTION GET_MAX_ROWS (
        P_APP_ID      IN NUMBER,
        P_PAGE_ID     IN NUMBER,
        P_REGION_ID   IN NUMBER
    ) RETURN NUMBER IS
        V_MAX_ROW_COUNT   NUMBER;
    BEGIN
        SELECT
            MAX_ROW_COUNT
        INTO
            V_MAX_ROW_COUNT
        FROM
            APEX_APPLICATION_PAGE_IR
        WHERE
            APPLICATION_ID = P_APP_ID
            AND   PAGE_ID = P_PAGE_ID
            AND   REGION_ID = P_REGION_ID;

        RETURN V_MAX_ROW_COUNT;
    END GET_MAX_ROWS;   
  ------------------------------------------------------------------------------  

    FUNCTION GET_FILE_NAME (
        P_APP_ID      IN NUMBER,
        P_PAGE_ID     IN NUMBER,
        P_REGION_ID   IN NUMBER
    ) RETURN VARCHAR2 IS
        V_FILENAME   VARCHAR2(255);
    BEGIN
        SELECT
            FILENAME
        INTO
            V_FILENAME
        FROM
            APEX_APPLICATION_PAGE_IR
        WHERE
            APPLICATION_ID = P_APP_ID
            AND   PAGE_ID = P_PAGE_ID
            AND   REGION_ID = P_REGION_ID;

        RETURN APEX_PLUGIN_UTIL.REPLACE_SUBSTITUTIONS(NVL(V_FILENAME,'Excel') );
    END GET_FILE_NAME;   
  ------------------------------------------------------------------------------

    PROCEDURE DOWNLOAD_FILE (
        P_APP_ID       IN NUMBER,
        P_PAGE_ID      IN NUMBER,
        P_REGION_ID    IN NUMBER,
        P_COL_LENGTH   IN VARCHAR2 DEFAULT NULL,
        P_MAX_ROWS     IN NUMBER
    ) IS
        T_TEMPLATE   BLOB;
        T_EXCEL      BLOB;
        V_CELLS      CLOB;
        V_STRINGS    CLOB;
        V_XML_DATA   XMLTYPE;
        ZIP_FILES    AS_ZIP.FILE_LIST;
    BEGIN PRAGMA INLINE ( GET_EXCEL,'YES' );
        DBMS_LOB.CREATETEMPORARY(T_EXCEL,TRUE);
        DBMS_LOB.CREATETEMPORARY(V_CELLS,TRUE);
        DBMS_LOB.CREATETEMPORARY(V_STRINGS,TRUE);
    --!!!!!
        SELECT
            FILE_CONTENT
        INTO
            T_TEMPLATE
        FROM
            APEX_APPL_PLUGIN_FILES
        WHERE
            FILE_NAME = 'ExcelTemplate.zip'
            AND   APPLICATION_ID = P_APP_ID
            AND   PLUGIN_NAME = 'AT.FRT.GPV_IR_TO_MSEXCEL';

        ZIP_FILES := AS_ZIP.GET_FILE_LIST(T_TEMPLATE);
        FOR I IN ZIP_FILES.FIRST ()..ZIP_FILES.LAST LOOP
            AS_ZIP.ADD1FILE(T_EXCEL,ZIP_FILES(I),AS_ZIP.GET_FILE(T_TEMPLATE,ZIP_FILES(I) ) );
        END LOOP;

        V_XML_DATA := IR_TO_XML.GET_REPORT_XML(P_APP_ID => P_APP_ID,P_PAGE_ID => P_PAGE_ID,P_REGION_ID => P_REGION_ID,P_GET_PAGE_ITEMS => 'N',P_ITEMS_LIST
=> NULL,P_MAX_ROWS => P_MAX_ROWS);

        GET_EXCEL(V_XML_DATA,V_CELLS,V_STRINGS,P_COL_LENGTH,WIDTH_COEFFICIENT);
        ADD1FILE(T_EXCEL,'xl/styles.xml',GET_STYLES_XML);
        ADD1FILE(T_EXCEL,'xl/worksheets/Sheet1.xml',V_CELLS);
        ADD1FILE(T_EXCEL,'xl/sharedStrings.xml',V_STRINGS);
        ADD1FILE(T_EXCEL,'xl/_rels/workbook.xml.rels',T_SHEET_RELS);
        ADD1FILE(T_EXCEL,'xl/workbook.xml',T_WORKBOOK);
        AS_ZIP.FINISH_ZIP(T_EXCEL);
 
    --htp.flush;
    --htp.init();
        OWA_UTIL.MIME_HEADER(CCONTENT_TYPE => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',BCLOSE_HEADER => FALSE);
        HTP.P('Content-Length: '
        || DBMS_LOB.GETLENGTH(T_EXCEL) );
        HTP.P('Content-disposition: attachment; filename='
        || GET_FILE_NAME(P_APP_ID,P_PAGE_ID,P_REGION_ID)
        || '.xlsx;');

        HTP.P('Cache-Control: must-revalidate, max-age=0');
        HTP.P('Expires: Thu, 01 Jan 1970 01:00:00 CET');
        OWA_UTIL.HTTP_HEADER_CLOSE;
        WPG_DOCLOAD.DOWNLOAD_FILE(T_EXCEL);
        DBMS_LOB.FREETEMPORARY(T_EXCEL);
        DBMS_LOB.FREETEMPORARY(V_CELLS);
        DBMS_LOB.FREETEMPORARY(V_STRINGS);
    END DOWNLOAD_FILE;

END;
/

