--
-- AS_PDF3_MOD  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.AS_PDF3_MOD IS
/**********************************************
**
** Additional comment by Andreas Weiden:
**AS_PDF3_MOD
** The following methods were added by me for additinal functionality needed for PK_JRXML_REPGEN
**
** -   PR_GOTO_PAGE
** -   PR_GOTO_CURRENT_PAGE;
** -   PR_LINE
** -   PR_POLYGON
** -   PR_PATH
**
** Changed in parameter p_txt for procedure raw2page  from blob to raw
** Added global collection g_settings_per_tab to store different pageformat for each page. 
** changed add_page to write a MediaBox-entry with the g_settings_per_tab-content for each page
**
** Change in subset_font:Checking for raw-length reduced from 32778 to 32000 because of raw-length-error
** in specific cases
**
** Various changes for font-usage: The access to g_fonts(g_current_font) is very slow, replaced it with a specific font-record
** which is filled when g_current_font changes
**
** Changes in adler32: The num-value of a hex-byte is no longer calculated by a to_number, but taken from an associative array
** done for preformance
**
** Changes in put_image_methods: the adler32-value can be provided from outside
***/
/**********************************************
**
** Author: Anton Scheffer
** Date: 11-04-2012
** Website: http://technology.amis.nl
** See also: http://technology.amis.nl/?p=17718
**
** Changelog:
**   Date: 16-04-2012
**     changed code for parse_png
**   Date: 15-04-2012
**     only dbms_lob.freetemporary for temporary blobs
**   Date: 11-04-2012
**     Initial release of as_pdf3
**
******************************************************************************
******************************************************************************
Copyright (C) 2012 by Anton Scheffer
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
******************************************************************************
******************************************** */
--
    C_GET_PAGE_WIDTH CONSTANT PLS_INTEGER := 0;
    C_GET_PAGE_HEIGHT CONSTANT PLS_INTEGER := 1;
    C_GET_MARGIN_TOP CONSTANT PLS_INTEGER := 2;
    C_GET_MARGIN_RIGHT CONSTANT PLS_INTEGER := 3;
    C_GET_MARGIN_BOTTOM CONSTANT PLS_INTEGER := 4;
    C_GET_MARGIN_LEFT CONSTANT PLS_INTEGER := 5;
    C_GET_X CONSTANT PLS_INTEGER := 6;
    C_GET_Y CONSTANT PLS_INTEGER := 7;
    C_GET_FONTSIZE CONSTANT PLS_INTEGER := 8;
    C_GET_CURRENT_FONT CONSTANT PLS_INTEGER := 9;
    TYPE TVERTICES IS
        TABLE OF NUMBER INDEX BY PLS_INTEGER;
    PATH_MOVE_TO CONSTANT NUMBER := 1;
    PATH_LINE_TO CONSTANT NUMBER := 2;
    PATH_CURVE_TO CONSTANT NUMBER := 3;
    PATH_CLOSE CONSTANT NUMBER := 4;
    TYPE TPATHELEMENT IS RECORD ( NTYPE NUMBER,
    NVAL1 NUMBER,
    NVAL2 NUMBER,
    NVAL3 NUMBER,
    NVAL4 NUMBER,
    NVAL5 NUMBER,
    NVAL6 NUMBER );
    TYPE TPATH IS
        TABLE OF TPATHELEMENT INDEX BY BINARY_INTEGER;
--
    FUNCTION FILE2BLOB (
        P_DIR VARCHAR2,
        P_FILE_NAME VARCHAR2
    ) RETURN BLOB;
--

    FUNCTION CONV2UU (
        P_VALUE NUMBER,
        P_UNIT VARCHAR2
    ) RETURN NUMBER;
--

    PROCEDURE SET_PAGE_SIZE (
        P_WIDTH    NUMBER,
        P_HEIGHT   NUMBER,
        P_UNIT     VARCHAR2 := 'cm'
    );
--

    PROCEDURE SET_PAGE_FORMAT (
        P_FORMAT VARCHAR2 := 'A4'
    );
--

    PROCEDURE SET_PAGE_ORIENTATION (
        P_ORIENTATION VARCHAR2 := 'PORTRAIT'
    );
--

    PROCEDURE SET_MARGINS (
        P_TOP      NUMBER := NULL,
        P_LEFT     NUMBER := NULL,
        P_BOTTOM   NUMBER := NULL,
        P_RIGHT    NUMBER := NULL,
        P_UNIT     VARCHAR2 := 'cm'
    );
--

    PROCEDURE SET_INFO (
        P_TITLE      VARCHAR2 := NULL,
        P_AUTHOR     VARCHAR2 := NULL,
        P_SUBJECT    VARCHAR2 := NULL,
        P_KEYWORDS   VARCHAR2 := NULL
    );
--

    PROCEDURE INIT;
--

    FUNCTION GET_PDF RETURN BLOB;
--

    PROCEDURE SAVE_PDF (
        P_DIR        VARCHAR2 := 'MY_DIR',
        P_FILENAME   VARCHAR2 := 'my.pdf',
        P_FREEBLOB   BOOLEAN := TRUE
    );
--

    PROCEDURE TXT2PAGE (
        P_TXT VARCHAR2
    );
--

    PROCEDURE PUT_TXT (
        P_X                  NUMBER,
        P_Y                  NUMBER,
        P_TXT                VARCHAR2,
        P_DEGREES_ROTATION   NUMBER := NULL
    );
--

    FUNCTION STR_LEN (
        P_TXT VARCHAR2
    ) RETURN NUMBER;
--

    PROCEDURE WRITE (
        P_TXT           IN VARCHAR2,
        P_X             IN NUMBER := NULL,
        P_Y             IN NUMBER := NULL,
        P_LINE_HEIGHT   IN NUMBER := NULL,
        P_START         IN NUMBER := NULL -- left side of the available text box
       ,
        P_WIDTH         IN NUMBER := NULL -- width of the available text box
       ,
        P_ALIGNMENT     IN VARCHAR2 := NULL
    );
--

    PROCEDURE SET_FONT (
        P_INDEX           PLS_INTEGER,
        P_FONTSIZE_PT     NUMBER,
        P_OUTPUT_TO_DOC   BOOLEAN := TRUE
    );
--

    FUNCTION SET_FONT (
        P_FONTNAME        VARCHAR2,
        P_FONTSIZE_PT     NUMBER,
        P_OUTPUT_TO_DOC   BOOLEAN := TRUE
    ) RETURN PLS_INTEGER;
--

    PROCEDURE SET_FONT (
        P_FONTNAME        VARCHAR2,
        P_FONTSIZE_PT     NUMBER,
        P_OUTPUT_TO_DOC   BOOLEAN := TRUE
    );
--

    FUNCTION SET_FONT (
        P_FAMILY          VARCHAR2,
        P_STYLE           VARCHAR2 := 'N',
        P_FONTSIZE_PT     NUMBER := NULL,
        P_OUTPUT_TO_DOC   BOOLEAN := TRUE
    ) RETURN PLS_INTEGER;
--

    PROCEDURE SET_FONT (
        P_FAMILY          VARCHAR2,
        P_STYLE           VARCHAR2 := 'N',
        P_FONTSIZE_PT     NUMBER := NULL,
        P_OUTPUT_TO_DOC   BOOLEAN := TRUE
    );
--

    PROCEDURE NEW_PAGE;
--

    FUNCTION LOAD_TTF_FONT (
        P_FONT       BLOB,
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE,
        P_OFFSET     NUMBER := 1
    ) RETURN PLS_INTEGER;
--

    PROCEDURE LOAD_TTF_FONT (
        P_FONT       BLOB,
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE,
        P_OFFSET     NUMBER := 1
    );
--

    FUNCTION LOAD_TTF_FONT (
        P_DIR        VARCHAR2 := 'MY_FONTS',
        P_FILENAME   VARCHAR2 := 'BAUHS93.TTF',
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE
    ) RETURN PLS_INTEGER;
--

    PROCEDURE LOAD_TTF_FONT (
        P_DIR        VARCHAR2 := 'MY_FONTS',
        P_FILENAME   VARCHAR2 := 'BAUHS93.TTF',
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE
    );
--

    PROCEDURE LOAD_TTC_FONTS (
        P_TTC        BLOB,
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE
    );
--

    PROCEDURE LOAD_TTC_FONTS (
        P_DIR        VARCHAR2 := 'MY_FONTS',
        P_FILENAME   VARCHAR2 := 'CAMBRIA.TTC',
        P_ENCODING   VARCHAR2 := 'WINDOWS-1252',
        P_EMBED      BOOLEAN := FALSE,
        P_COMPRESS   BOOLEAN := TRUE
    );
--

    PROCEDURE SET_COLOR (
        P_RGB VARCHAR2 := '000000'
    );
--

    PROCEDURE SET_COLOR (
        P_RED     NUMBER := 0,
        P_GREEN   NUMBER := 0,
        P_BLUE    NUMBER := 0
    );
--

    PROCEDURE SET_BK_COLOR (
        P_RGB VARCHAR2 := 'ffffff'
    );
--

    PROCEDURE SET_BK_COLOR (
        P_RED     NUMBER := 0,
        P_GREEN   NUMBER := 0,
        P_BLUE    NUMBER := 0
    );
--

    PROCEDURE HORIZONTAL_LINE (
        P_X            IN NUMBER,
        P_Y            IN NUMBER,
        P_WIDTH        IN NUMBER,
        P_LINE_WIDTH   IN NUMBER := 0.5,
        P_LINE_COLOR   IN VARCHAR2 := '000000'
    );
--

    PROCEDURE VERTICAL_LINE (
        P_X            IN NUMBER,
        P_Y            IN NUMBER,
        P_HEIGHT       IN NUMBER,
        P_LINE_WIDTH   IN NUMBER := 0.5,
        P_LINE_COLOR   IN VARCHAR2 := '000000'
    );
--

    PROCEDURE RECT (
        P_X            IN NUMBER,
        P_Y            IN NUMBER,
        P_WIDTH        IN NUMBER,
        P_HEIGHT       IN NUMBER,
        P_LINE_COLOR   IN VARCHAR2 := NULL,
        P_FILL_COLOR   IN VARCHAR2 := NULL,
        P_LINE_WIDTH   IN NUMBER := 0.5
    );
--

    FUNCTION GET (
        P_WHAT IN PLS_INTEGER
    ) RETURN NUMBER;
--

    PROCEDURE PUT_IMAGE (
        P_IMG       BLOB,
        P_X         NUMBER,
        P_Y         NUMBER,
        P_WIDTH     NUMBER := NULL,
        P_HEIGHT    NUMBER := NULL,
        P_ALIGN     VARCHAR2 := 'center',
        P_VALIGN    VARCHAR2 := 'top',
        P_ADLER32   VARCHAR2 := NULL
    );
--

    PROCEDURE PUT_IMAGE (
        P_DIR         VARCHAR2,
        P_FILE_NAME   VARCHAR2,
        P_X           NUMBER,
        P_Y           NUMBER,
        P_WIDTH       NUMBER := NULL,
        P_HEIGHT      NUMBER := NULL,
        P_ALIGN       VARCHAR2 := 'center',
        P_VALIGN      VARCHAR2 := 'top',
        P_ADLER32     VARCHAR2 := NULL
    );
--

    PROCEDURE PUT_IMAGE (
        P_URL       VARCHAR2,
        P_X         NUMBER,
        P_Y         NUMBER,
        P_WIDTH     NUMBER := NULL,
        P_HEIGHT    NUMBER := NULL,
        P_ALIGN     VARCHAR2 := 'center',
        P_VALIGN    VARCHAR2 := 'top',
        P_ADLER32   VARCHAR2 := NULL
    );
--

    PROCEDURE SET_PAGE_PROC (
        P_SRC CLOB
    );
--

    TYPE TP_COL_WIDTHS IS
        TABLE OF NUMBER;
    TYPE TP_HEADERS IS
        TABLE OF VARCHAR2(32767);
--
    PROCEDURE QUERY2TABLE (
        P_QUERY     VARCHAR2,
        P_WIDTHS    TP_COL_WIDTHS := NULL,
        P_HEADERS   TP_HEADERS := NULL
    );
--

    PROCEDURE PR_GOTO_PAGE (
        I_NPAGE IN NUMBER
    );

    PROCEDURE PR_GOTO_CURRENT_PAGE;

    PROCEDURE PR_LINE (
        I_NX1           IN NUMBER,
        I_NY1           IN NUMBER,
        I_NX2           IN NUMBER,
        I_NY2           IN NUMBER,
        I_VCLINECOLOR   IN VARCHAR2 DEFAULT NULL,
        I_NLINEWIDTH    IN NUMBER DEFAULT 0.5,
        I_VCSTROKE      IN VARCHAR2 DEFAULT NULL
    );

    PROCEDURE PR_POLYGON (
        I_LXS           IN TVERTICES,
        I_LYS           IN TVERTICES,
        I_VCLINECOLOR   IN VARCHAR2 DEFAULT NULL,
        I_VCFILLCOLOR   IN VARCHAR2 DEFAULT NULL,
        I_NLINEWIDTH    IN NUMBER DEFAULT 0.5
    );

    PROCEDURE PR_PATH (
        I_LPATH         IN TPATH,
        I_VCLINECOLOR   IN VARCHAR2 DEFAULT NULL,
        I_VCFILLCOLOR   IN VARCHAR2 DEFAULT NULL,
        I_NLINEWIDTH    IN NUMBER DEFAULT 0.5
    );

    FUNCTION ADLER32 (
        P_SRC IN BLOB
    ) RETURN VARCHAR2;
$IF not DBMS_DB_VERSION.VER_LE_10 $THEN

    PROCEDURE REFCURSOR2TABLE (
        P_RC        SYS_REFCURSOR,
        P_WIDTHS    TP_COL_WIDTHS := NULL,
        P_HEADERS   TP_HEADERS := NULL
    );
--
$END

END;
/

