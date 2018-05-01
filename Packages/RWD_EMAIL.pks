--
-- RWD_EMAIL  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.RWD_EMAIL IS

    /**********************************************
    ***********************************************
    ***********************************************
    CONSTANTS
    ***********************************************
    ***********************************************
    **********************************************/
    G_HEADER_BACKGROUND_COLOR CONSTANT VARCHAR2(25) := '#ffffff';
    G_PRIMARY_BUTTON_BGCOLOR CONSTANT VARCHAR2(25) := '#4A96C9';
    G_PRIMARY_BUTTON_TEXT_COLOR CONSTANT VARCHAR2(25) := '#FFFFFF';
    G_TEXT_COLOR CONSTANT VARCHAR2(25) := '#222222';
    G_BODY_BACKGROUND CONSTANT VARCHAR2(25) := 'transparent';
    G_FONT_FAMILY CONSTANT VARCHAR2(100) := '''Helvetica'', ''Arial'', sans-serif';
    G_LINE_HEIGHT CONSTANT VARCHAR2(25) := '19px';
    G_FONT_SIZE CONSTANT VARCHAR2(25) := '14px';

    /**********************************************
    ***********************************************
    ***********************************************
    TYPES
    ***********************************************
    ***********************************************
    **********************************************/
    TYPE T_CONTENT IS RECORD ( LOGO_URL VARCHAR2(4000),
    TITLE VARCHAR2(4000),
    WELCOME_TITLE VARCHAR2(4000),
    SUB_WELCOME_TITLE VARCHAR2(4000),
    BIG_PICTURE_URL VARCHAR2(4000),
    TOP_PARAGRAPH VARCHAR2(4000),
    BOTTOM_PARAGRAPH VARCHAR2(4000),
    BOTTOM_PARAGRAPH_TITLE VARCHAR2(4000),
    BOTTOM_PARAGRAPH_SUBTITLE VARCHAR2(4000),
    LEFT_PARAGRAPH VARCHAR2(4000),
    RIGHT_HEADER VARCHAR2(4000),
    RIGHT_SUB_HEADER VARCHAR2(4000),
    SOCIAL_TITLE VARCHAR2(4000),
    CONTACT_INFO VARCHAR2(4000),
    CONTACT_PHONE VARCHAR2(4000),
    CONTACT_EMAIL VARCHAR2(4000),
    FOOTER_LINKS VARCHAR2(4000) );

    /**********************************************
    ***********************************************
    ***********************************************
    GLOBAL STUFF
    ***********************************************
    ***********************************************
    **********************************************/

    /*
    Global Header
    */
    FUNCTION PRINT_GLOBAL_HEADER RETURN CLOB;

    /*
    Global CSS
    */

    FUNCTION PRINT_GLOBAL_CSS RETURN CLOB;

    /*
    Global Body HTML tag
    */

    FUNCTION OUTER_BODY (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    Global Mandatory Table to wrap the body content
    */

    FUNCTION INNER_BODY (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /* Email Footer */

    FUNCTION PRINT_GLOBAL_END RETURN CLOB;

    /**********************************************
    ***********************************************
    ***********************************************
    GRID
    ***********************************************
    ***********************************************
    **********************************************/

    /*
    Constrains the content to a 580px wrapper on large screens (95% on small screens) and centers it within the body.
    */

    FUNCTION PRINT_CONTAINER (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    Separates each row of content.
    */

    FUNCTION PRINT_ROW (
        P_CONTENT                   IN CLOB,
        P_CLASSES                   IN VARCHAR2 DEFAULT NULL,
        P_DISPLAY                   IN VARCHAR2 DEFAULT 'block',
        P_HEADER_BACKGROUND_COLOR   IN VARCHAR2 DEFAULT 'transparent'
    ) RETURN CLOB;

    /*
    Grid Standard TD
    */

    FUNCTION PRINT_STANDARD_TD (
        P_CONTENT            IN CLOB,
        P_ALIGN              IN VARCHAR2 DEFAULT 'left',
        P_PADDING            IN VARCHAR2 DEFAULT '0 0 10px',
        P_BACKGROUND_COLOR   IN VARCHAR2 DEFAULT 'transparent',
        P_BORDER             IN VARCHAR2 DEFAULT 'none',
        P_EXTRA_ATTRIBUTES   IN VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    /*
    Grid Standard TD Centered
    */

    FUNCTION PRINT_STANDARD_TD_CENTER (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    Wraps each .columns table, in order to create a gutter between columns
    and force them to expand to full width on small screens.
    */

    FUNCTION PRINT_COLUMN_WRAPPER (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    Can be any number between one and twelve (spelled out).
    Used to determine how wide your .columns tables are.
    The number of columns in each row should add up to 12, including offset columns .
    */

    FUNCTION PRINT_COL (
        P_CONTENT   IN CLOB,
        P_NUMBER    IN VARCHAR2,
        P_WIDTH     IN VARCHAR2
    ) RETURN CLOB;

    /*
    1 Columns
    */

    FUNCTION PRINT_COL_1 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    2 Columns
    */

    FUNCTION PRINT_COL_2 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    3 Columns
    */

    FUNCTION PRINT_COL_3 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    4 Columns
    */

    FUNCTION PRINT_COL_4 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    5 Columns
    */

    FUNCTION PRINT_COL_5 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    6 Columns
    */

    FUNCTION PRINT_COL_6 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    7 Columns
    */

    FUNCTION PRINT_COL_7 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    8 Columns
    */

    FUNCTION PRINT_COL_8 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    9 Columns
    */

    FUNCTION PRINT_COL_9 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    10 Columns
    */

    FUNCTION PRINT_COL_10 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    11 Columns
    */

    FUNCTION PRINT_COL_11 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    12 Columns
    */

    FUNCTION PRINT_COL_12 (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /*
    An empty (and invisible) element added after the content element in a .columns table.
    It forces the content td to expand to the full width of the screen on small devices,
    instead of just the width of the content within the td.
    */

    FUNCTION PRINT_EXPANDER RETURN CLOB;

    /**********************************************
    ***********************************************
    ***********************************************
    SUB GRID
    ***********************************************
    ***********************************************
    **********************************************/

    /*
    Can be any number between one and twelve (spelled out).
    Used to determine how wide your .columns tables are.
    The number of sub columns in each row should add up to 12, including offset sub columns .
    */

    FUNCTION PRINT_SUB_COL (
        P_CONTENT   IN CLOB,
        P_CLASSES   IN VARCHAR2,
        P_WIDTH     IN VARCHAR2,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    1 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_1 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    2 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_2 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    3 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_3 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    4 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_4 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    5 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_5 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    6 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_6 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    7 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_7 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    8 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_8 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    9 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_9 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    10 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_10 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    11 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_11 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;
    /*

    12 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_12 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /**********************************************
    ***********************************************
    ***********************************************
    PANELS
    ***********************************************
    ***********************************************
    **********************************************/

    FUNCTION PRINT_PANEL (
        P_CONTENT            IN CLOB,
        P_BACKGROUND_COLOR   IN VARCHAR2 DEFAULT '#f2f2f2',
        P_TEXT_COLOR         IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB;

    /**********************************************
    ***********************************************
    ***********************************************
    TYPOGRAPHY
    ***********************************************
    ***********************************************
    **********************************************/

    /*
    Prints a standard paragraph
    */

    FUNCTION PRINT_PARAGRAPH (
        P_TEXT         IN VARCHAR2,
        P_CLASSES      IN VARCHAR2 DEFAULT NULL,
        P_FONT_SIZE    IN VARCHAR2 DEFAULT '14px',
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB;

    /*
    Prints a bigger paragraph
    */

    FUNCTION PRINT_PARAGRAPH_LEAD (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB;

    /*
    Prints an H tag
    */

    FUNCTION PRINT_H (
        P_TEXT         IN VARCHAR2,
        P_H_SIZE       IN VARCHAR2,
        P_FONT_SIZE    IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB;

    /*
    Prints an H1 tag
    */

    FUNCTION PRINT_H1 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB;

    /*
    Prints an H2 tag
    */

    FUNCTION PRINT_H2 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB;

    /*
    Prints an H3 tag
    */

    FUNCTION PRINT_H3 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB;

    /*
    Prints an H4 tag
    */

    FUNCTION PRINT_H4 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB;

    /*
    Prints an H5 tag
    */

    FUNCTION PRINT_H5 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB;

    /*
    Prints an H6 tag
    */

    FUNCTION PRINT_H6 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB;

    /*
    Prints a small text
    */

    FUNCTION PRINT_SMALL_TEXT (
        P_TEXT         IN VARCHAR2,
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB;

    /*
    Prints a label for the title bar
    */

    FUNCTION PRINT_TITLE (
        P_TEXT         IN VARCHAR2,
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT '#ffffff'
    ) RETURN CLOB;

    /**********************************************
    ***********************************************
    ***********************************************
    BUTTONS
    ***********************************************
    ***********************************************
    **********************************************/

    FUNCTION PRINT_BUTTON (
        P_CONTENT            IN CLOB,
        P_BUTTON_CLASSES     IN VARCHAR2 DEFAULT 'button',
        P_ALIGN              IN VARCHAR2 DEFAULT 'left',
        P_PADDING            IN VARCHAR2 DEFAULT '0 0 10px',
        P_BACKGROUND_COLOR   IN VARCHAR2 DEFAULT 'transparent',
        P_BORDER             IN VARCHAR2 DEFAULT 'none',
        P_EXTRA_STYLE        IN VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION PRINT_PLAIN_LINK (
        P_URL     IN CLOB,
        P_LABEL   IN CLOB
    ) RETURN CLOB;

    FUNCTION PRINT_PRIMARY_BUTTON (
        P_URL     IN CLOB,
        P_LABEL   IN CLOB
    ) RETURN CLOB;

    FUNCTION PRINT_BUTTON_FACEBOOK (
        P_URL     IN CLOB,
        P_LABEL   IN CLOB
    ) RETURN CLOB;

    FUNCTION PRINT_BUTTON_TWITTER (
        P_URL     IN CLOB,
        P_LABEL   IN CLOB
    ) RETURN CLOB;

    FUNCTION PRINT_BUTTON_GOOGLE_PLUS (
        P_URL     IN CLOB,
        P_LABEL   IN CLOB
    ) RETURN CLOB;

    /**********************************************
    ***********************************************
    ***********************************************
    OTHER FEATURES
    ***********************************************
    ***********************************************
    **********************************************/

    /*
    Print an image through a URL
    Can be aligned left, center or right
    */

    FUNCTION PRINT_IMAGE (
        P_IMG_URL   IN VARCHAR2,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB;

    /*
    Simple line to separate content
    */

    FUNCTION PRINT_HR RETURN CLOB;

    /**********************************************
    ***********************************************
    ***********************************************
    COMMON PATTERNS
    ***********************************************
    ***********************************************
    **********************************************/

    FUNCTION PRINT_DEFAULT_BODY_HEADER (
        P_LOGO_URL   IN VARCHAR2,
        P_TITLE      IN VARCHAR2
    ) RETURN CLOB;

    FUNCTION PRINT_DEFAULT_BODY_FOOTER (
        P_FOOTER_LINKS IN VARCHAR2
    ) RETURN CLOB;

    FUNCTION PRINT_GLOBAL_BODY (
        P_CONTENT IN CLOB
    ) RETURN CLOB;

    /**********************************************
    ***********************************************
    ***********************************************
    PRESET TEMPLATES
    ***********************************************
    ***********************************************
    **********************************************/

    FUNCTION BASIC (
        P_CONTENT IN T_CONTENT
    ) RETURN CLOB;

    FUNCTION HERO (
        P_CONTENT IN T_CONTENT
    ) RETURN CLOB;

    FUNCTION SIDEBAR (
        P_CONTENT IN T_CONTENT
    ) RETURN CLOB;

    FUNCTION SIDEBAR_HERO (
        P_CONTENT IN T_CONTENT
    ) RETURN CLOB;

END RWD_EMAIL;
/

