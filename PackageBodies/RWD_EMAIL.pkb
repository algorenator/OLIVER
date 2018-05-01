--
-- RWD_EMAIL  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.RWD_EMAIL IS

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

    FUNCTION PRINT_GLOBAL_HEADER RETURN CLOB
        IS
    BEGIN
        RETURN '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
        || '<html xmlns="http://www.w3.org/1999/xhtml">'
        || '<head>'
        || '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
        || '<meta name="viewport" content="width=device-width"/>'
        || '</head>';
    END PRINT_GLOBAL_HEADER;

    /*
    Global CSS
    */

    FUNCTION PRINT_GLOBAL_CSS RETURN CLOB
        IS
    BEGIN
        RETURN '<style type="text/css">a:hover,a:active{color:#2795b6!important}a:visited,h1 a:active,h1 a:visited,h2 a:active,h2 a:visited,h3 a:active,h3 a:visited,h4 a:active,h4 a:visited,h5 a:active,h5 a:visited,h6 a:active,h6 a:visited{color:#2ba6cb!important}table.button:active td,table.button:visited td{background:#2795b6!important}table.button:visited td a{color:#fff!important}table.button:hover td,table.large-button:hover td,table.medium-button:hover td,table.small-button:hover td,table.tiny-button:hover td{background:#2795b6!important}table.button td a:visited,table.button:active td a,table.button:hover td a,table.large-button td a:visited,table.large-button:active td a,table.large-button:hover td a,table.medium-button td a:visited,table.medium-button:active td a,table.medium-button:hover td a,table.small-button td a:visited,table.small-button:active td a,table.small-button:hover td a,table.tiny-button td a:visited,table.tiny-button:active td a,table.tiny-button:hover td a{color:#fff!important}table.secondary:hover td{background:#d0d0d0!important;color:#555}table.secondary td a:visited,table.secondary:active td a,table.secondary:hover td a{color:#555!important}table.success:hover td{background:#457a1a!important}table.alert:hover td{background:#970b0e!important}table.facebook:hover td{background:#2d4473!important}table.twitter:hover td{background:#0087bb!important}table.google-plus:hover td{background:#C00!important}@media only screen and (max-width:600px){table[class=body] img{width:auto!important;height:auto!important}table[class=body] center{min-width:0!important}table[class=body] .container{width:95%!important}table[class=body] .row{width:100%!important;display:block!important}table[class=body] .wrapper{display:block!important;padding-right:0!important}table[class=body] .column,table[class=body] .columns{table-layout:fixed!important;float:none!important;width:100%!important;padding-right:0!important;padding-left:0!important;display:block!important}table[class=body] .wrapper.first .column,table[class=body] .wrapper.first .columns{display:table!important}table[class=body] table.column td,table[class=body] table.columns td{width:100%!important}table[class=body] .column td.one,table[class=body] .columns td.one{width:8.333333%!important}table[class=body] .column td.two,table[class=body] .columns td.two{width:16.666666%!important}table[class=body] .column td.three,table[class=body] .columns td.three{width:25%!important}table[class=body] .column td.four,table[class=body] .columns td.four{width:33.333333%!important}table[class=body] .column td.five,table[class=body] .columns td.five{width:41.666666%!important}table[class=body] .column td.six,table[class=body] .columns td.six{width:50%!important}table[class=body] .column td.seven,table[class=body] .columns td.seven{width:58.333333%!important}table[class=body] .column td.eight,table[class=body] .columns td.eight{width:66.666666%!important}table[class=body] .column td.nine,table[class=body] .columns td.nine{width:75%!important}table[class=body] .column td.ten,table[class=body] .columns td.ten{width:83.333333%!important}table[class=body] .column td.eleven,table[class=body] .columns td.eleven{width:91.666666%!important}table[class=body] .column td.twelve,table[class=body] .columns td.twelve{width:100%!important}table[class=body] td.offset-by-eight,table[class=body] td.offset-by-eleven,table[class=body] td.offset-by-five,table[class=body] td.offset-by-four,table[class=body] td.offset-by-nine,table[class=body] td.offset-by-one,table[class=body] td.offset-by-seven,table[class=body] td.offset-by-six,table[class=body] td.offset-by-ten,table[class=body] td.offset-by-three,table[class=body] td.offset-by-two{padding-left:0!important}table[class=body] table.columns td.expander{width:1px!important}table[class=body] .text-pad-right{padding-left:10px!important}table[class=body] .text-pad-left{padding-right:10px!important}table[class=body] .hide-for-small,table[class=body] .show-for-desktop{display:none!important}table[class=body] .hide-for-desktop,table[class=body] .show-for-small{display:inherit!important}table[class=body] .right-text-pad{padding-left:10px!important}table[class=body] .left-text-pad{padding-right:10px!important}}</style>'
;
    END PRINT_GLOBAL_CSS;

    /*
    Global Body HTML tag
    */

    FUNCTION OUTER_BODY (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<body style="background:'
        || G_BODY_BACKGROUND
        || '; width: 100% !important; min-width: 100%; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; color: '
        || G_TEXT_COLOR
        || '; font-family: '
        || G_FONT_FAMILY
        || '; font-weight: normal; text-align: left; line-height: '
        || G_LINE_HEIGHT
        || '; font-size: '
        || G_FONT_SIZE
        || '; margin: 0; padding: 0;">'
        || P_CONTENT
        || '</body>';
    END OUTER_BODY;

    /*
    Global Mandatory Table to wrap the body content
    */

    FUNCTION INNER_BODY (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<table class="body" style="background:'
        || G_BODY_BACKGROUND
        || '; border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; height: 100%; width: 100%; color: '
        || G_TEXT_COLOR
        || '; font-family: '
        || G_FONT_FAMILY
        || '; font-weight: normal; line-height: '
        || G_LINE_HEIGHT
        || '; font-size: '
        || G_FONT_SIZE
        || '; margin: 0; padding: 0;">'
        || '<tr style="vertical-align: top; text-align: left; padding: 0;" align="left">'
        || P_CONTENT
        || '</tr>'
        || '</table>';
    END INNER_BODY;

    /* Email Footer */

    FUNCTION PRINT_GLOBAL_END RETURN CLOB
        IS
    BEGIN
        RETURN '</html>';
    END PRINT_GLOBAL_END;

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
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<table class="container" style="border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: inherit; width: 580px; margin: 0 auto; padding: 0;">'
        || '<tr style="vertical-align: top; text-align: left; padding: 0;" align="left">'
        || PRINT_STANDARD_TD(P_CONTENT)
        || '</tr>'
        || '</table>';
    END PRINT_CONTAINER;

    /*
    Separates each row of content.
    */

    FUNCTION PRINT_ROW (
        P_CONTENT                   IN CLOB,
        P_CLASSES                   IN VARCHAR2 DEFAULT NULL,
        P_DISPLAY                   IN VARCHAR2 DEFAULT 'block',
        P_HEADER_BACKGROUND_COLOR   IN VARCHAR2 DEFAULT 'transparent'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<table class="row '
        || P_CLASSES
        || '" style="border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%; position: relative; background: '
        || P_HEADER_BACKGROUND_COLOR
        || '; display: '
        || P_DISPLAY
        || '; padding: 0px;" bgcolor="'
        || P_HEADER_BACKGROUND_COLOR
        || '">'
        || '<tr style="vertical-align: top; text-align: left; padding: 0;" align="left">'
        || P_CONTENT
        || '</tr>'
        || '</table>';
    END PRINT_ROW;

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
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<td style="word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: '
        || P_ALIGN
        || '; color: '
        || G_TEXT_COLOR
        || '; font-family: '
        || G_FONT_FAMILY
        || '; font-weight: normal; line-height: '
        || G_LINE_HEIGHT
        || '; font-size: '
        || G_FONT_SIZE
        || '; margin: 0; padding: '
        || P_PADDING
        || ';" align="'
        || P_ALIGN
        || '" valign="top">'
        || P_CONTENT
        || '</td>';
    END PRINT_STANDARD_TD;

    /*
    Grid Standard TD Centered
    */

    FUNCTION PRINT_STANDARD_TD_CENTER (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_STANDARD_TD(P_CONTENT => '<center style="width: 100%; min-width: 580px;">'
        || P_CONTENT
        || '</center>',P_ALIGN => 'center');
    END PRINT_STANDARD_TD_CENTER;

    /*
    Wraps each .columns table, in order to create a gutter between columns
    and force them to expand to full width on small screens.
    */

    FUNCTION PRINT_COLUMN_WRAPPER (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<td class="wrapper" style="word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; position: relative; color: '
        || G_TEXT_COLOR
        || '; font-family: '
        || G_FONT_FAMILY
        || '; font-weight: normal; line-height: '
        || G_LINE_HEIGHT
        || '; font-size: '
        || G_FONT_SIZE
        || '; margin: 0; padding: 10px 20px 0px 0px;" align="left" valign="top">'
        || P_CONTENT
        || '</td>';
    END PRINT_COLUMN_WRAPPER;

    /*
    Can be any number between one and twelve (spelled out).
    Used to determine how wide your .columns tables are.
    The number of columns in each row should add up to 12, including offset columns .
    */

    FUNCTION PRINT_COL (
        P_CONTENT   IN CLOB,
        P_NUMBER    IN VARCHAR2,
        P_WIDTH     IN VARCHAR2
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<table class="'
        || P_NUMBER
        || ' columns" style="border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: '
        || P_WIDTH
        || '; margin: 0 auto; padding: 0;">'
        || '<tr style="vertical-align: top; text-align: left; padding: 0;" align="left">'
        || P_CONTENT
        || PRINT_EXPANDER
        || '</tr>'
        || '</table>';
    END PRINT_COL;

    /*
    1 Columns
    */

    FUNCTION PRINT_COL_1 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'one','30px');
    END PRINT_COL_1;

    /*
    2 Columns
    */

    FUNCTION PRINT_COL_2 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'two','80px');
    END PRINT_COL_2;

    /*
    3 Columns
    */

    FUNCTION PRINT_COL_3 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'three','130px');
    END PRINT_COL_3;

    /*
    4 Columns
    */

    FUNCTION PRINT_COL_4 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'four','180px');
    END PRINT_COL_4;

    /*
    5 Columns
    */

    FUNCTION PRINT_COL_5 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'five','230px');
    END PRINT_COL_5;

    /*
    6 Columns
    */

    FUNCTION PRINT_COL_6 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'six','280px');
    END PRINT_COL_6;

    /*
    7 Columns
    */

    FUNCTION PRINT_COL_7 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'seven','330px');
    END PRINT_COL_7;

    /*
    8 Columns
    */

    FUNCTION PRINT_COL_8 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'eight','380px');
    END PRINT_COL_8;

    /*
    9 Columns
    */

    FUNCTION PRINT_COL_9 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'nine','430px');
    END PRINT_COL_9;

    /*
    10 Columns
    */

    FUNCTION PRINT_COL_10 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'ten','480px');
    END PRINT_COL_10;

    /*
    11 Columns
    */

    FUNCTION PRINT_COL_11 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'eleven','530px');
    END PRINT_COL_11;

    /*
    12 Columns
    */

    FUNCTION PRINT_COL_12 (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_COL(P_CONTENT,'twelve','580px');
    END PRINT_COL_12;

    /*
    An empty (and invisible) element added after the content element in a .columns table.
    It forces the content td to expand to the full width of the screen on small devices,
    instead of just the width of the content within the td.
    */

    FUNCTION PRINT_EXPANDER RETURN CLOB
        IS
    BEGIN
        RETURN '<td class="expander" style="word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; visibility: hidden; width: 0px; color: '
        || G_TEXT_COLOR
        || '; font-family: '
        || G_FONT_FAMILY
        || '; font-weight: normal; line-height: '
        || G_LINE_HEIGHT
        || '; font-size: '
        || G_FONT_SIZE
        || '; margin: 0; padding: 0;" align="left" valign="top"></td>';
    END PRINT_EXPANDER;

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
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<td class="sub-columns '
        || P_CLASSES
        || '" style="word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: middle; text-align: '
        || P_ALIGN
        || '; min-width: 0px; width: '
        || P_WIDTH
        || '; color: '
        || G_TEXT_COLOR
        || '; font-family: '
        || G_FONT_FAMILY
        || '; font-weight: normal; line-height: '
        || G_LINE_HEIGHT
        || '; font-size: '
        || G_FONT_SIZE
        || '; margin: 0; padding: 0px 10px 10px 0px;" align="'
        || P_ALIGN
        || '" valign="middle">'
        || P_CONTENT
        || '</td>';
    END PRINT_SUB_COL;

    /*
    1 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_1 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'one',ROUND(100 * 1 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_1;

    /*
    2 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_2 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'two',ROUND(100 * 2 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_2;

    /*
    3 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_3 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'three',ROUND(100 * 3 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_3;

    /*
    4 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_4 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'four',ROUND(100 * 4 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_4;

    /*
    5 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_5 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'five',ROUND(100 * 5 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_5;

    /*
    6 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_6 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'six',ROUND(100 * 6 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_6;

    /*
    7 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_7 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'seven',ROUND(100 * 7 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_7;

    /*
    8 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_8 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'eight',ROUND(100 * 8 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_8;

    /*
    9 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_9 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'nine',ROUND(100 * 9 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_9;

    /*
    10 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_10 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'ten',ROUND(100 * 10 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_10;

    /*
    11 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_11 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'eleven',ROUND(100 * 11 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_11;

    /*
    12 Sub Columns
    */

    FUNCTION PRINT_SUB_COL_12 (
        P_CONTENT   IN CLOB,
        P_ALIGN     IN VARCHAR2 DEFAULT 'left'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_SUB_COL(P_CONTENT,'twelve',ROUND(100 * 12 / 12,4)
        || '%',P_ALIGN);
    END PRINT_SUB_COL_12;

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
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<td class="panel" style="word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: left; color: '
        || P_TEXT_COLOR
        || '; font-family: '
        || G_FONT_FAMILY
        || '; font-weight: normal; line-height: '
        || G_LINE_HEIGHT
        || '; font-size: '
        || G_FONT_SIZE
        || '; background: '
        || P_BACKGROUND_COLOR
        || '; margin: 0; padding: 10px; border: 1px solid #d9d9d9;" align="left" bgcolor="'
        || P_BACKGROUND_COLOR
        || '" valign="top">'
        || P_CONTENT
        || '</td>';
    END PRINT_PANEL;

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
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<p class="'
        || P_CLASSES
        || '" style="color: '
        || P_TEXT_COLOR
        || '; font-family: '
        || G_FONT_FAMILY
        || '; font-weight: normal; text-align: '
        || P_ALIGN
        || '; line-height: '
        || G_LINE_HEIGHT
        || '; font-size: '
        || P_FONT_SIZE
        || '; margin: 0 0 10px; padding: 0;" align="'
        || P_ALIGN
        || '">'
        || P_TEXT
        || '</p>';
    END PRINT_PARAGRAPH;

    /*
    Prints a bigger paragraph
    */

    FUNCTION PRINT_PARAGRAPH_LEAD (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_PARAGRAPH(P_TEXT => P_TEXT,P_CLASSES => 'lead',P_FONT_SIZE => '18px',P_ALIGN => P_ALIGN,P_TEXT_COLOR => P_TEXT_COLOR);
    END PRINT_PARAGRAPH_LEAD;

    /*
    Prints an H tag
    */

    FUNCTION PRINT_H (
        P_TEXT         IN VARCHAR2,
        P_H_SIZE       IN VARCHAR2,
        P_FONT_SIZE    IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<h'
        || P_H_SIZE
        || ' style="color: '
        || P_TEXT_COLOR
        || '; font-family: '
        || G_FONT_FAMILY
        || '; font-weight: normal; text-align: '
        || P_ALIGN
        || '; line-height: 1.3; word-break: normal; font-size: '
        || P_FONT_SIZE
        || '; margin: 0; padding: 0;" align="'
        || P_ALIGN
        || '">'
        || P_TEXT
        || '</h'
        || P_H_SIZE
        || '>';
    END PRINT_H;

    /*
    Prints an H1 tag
    */

    FUNCTION PRINT_H1 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_H(P_TEXT => P_TEXT,P_H_SIZE => '1',P_FONT_SIZE => '40px',P_ALIGN => P_ALIGN,P_TEXT_COLOR => P_TEXT_COLOR);
    END PRINT_H1;

    /*
    Prints an H2 tag
    */

    FUNCTION PRINT_H2 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_H(P_TEXT => P_TEXT,P_H_SIZE => '2',P_FONT_SIZE => '36px',P_ALIGN => P_ALIGN,P_TEXT_COLOR => P_TEXT_COLOR);
    END PRINT_H2;

    /*
    Prints an H3 tag
    */

    FUNCTION PRINT_H3 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_H(P_TEXT => P_TEXT,P_H_SIZE => '3',P_FONT_SIZE => '32px',P_ALIGN => P_ALIGN,P_TEXT_COLOR => P_TEXT_COLOR);
    END PRINT_H3;

    /*
    Prints an H4 tag
    */

    FUNCTION PRINT_H4 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_H(P_TEXT => P_TEXT,P_H_SIZE => '4',P_FONT_SIZE => '28px',P_ALIGN => P_ALIGN,P_TEXT_COLOR => P_TEXT_COLOR);
    END PRINT_H4;

    /*
    Prints an H5 tag
    */

    FUNCTION PRINT_H5 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_H(P_TEXT => P_TEXT,P_H_SIZE => '5',P_FONT_SIZE => '24px',P_ALIGN => P_ALIGN,P_TEXT_COLOR => P_TEXT_COLOR);
    END PRINT_H5;

    /*
    Prints an H6 tag
    */

    FUNCTION PRINT_H6 (
        P_TEXT         IN VARCHAR2,
        P_ALIGN        IN VARCHAR2 DEFAULT 'left',
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_H(P_TEXT => P_TEXT,P_H_SIZE => '6',P_FONT_SIZE => '20px',P_ALIGN => P_ALIGN,P_TEXT_COLOR => P_TEXT_COLOR);
    END PRINT_H6;

    /*
    Prints a small text
    */

    FUNCTION PRINT_SMALL_TEXT (
        P_TEXT         IN VARCHAR2,
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT G_TEXT_COLOR
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<small style="font-size: 10px;">'
        || P_TEXT
        || '</small>';
    END PRINT_SMALL_TEXT;

    /*
    Prints a label for the title bar
    */

    FUNCTION PRINT_TITLE (
        P_TEXT         IN VARCHAR2,
        P_TEXT_COLOR   IN VARCHAR2 DEFAULT '#ffffff'
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<span class="template-label" style="color: '
        || P_TEXT_COLOR
        || '; font-weight: bold; font-size: 11px;">'
        || P_TEXT
        || '</span>';
    END PRINT_TITLE;

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
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<table class="'
        || P_BUTTON_CLASSES
        || '" style="border-spacing: 0; border-collapse: collapse; vertical-align: top; text-align: left; width: 100%; overflow: hidden; padding: 0;">'
        || '<tr style="vertical-align: top; text-align: left; padding: 0;" align="left">'
        || '<td style="word-break: break-word; -webkit-hyphens: auto; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse !important; vertical-align: top; text-align: '
        || P_ALIGN
        || '; color: '
        || G_TEXT_COLOR
        || '; font-family: '
        || G_FONT_FAMILY
        || '; font-weight: normal; line-height: '
        || G_LINE_HEIGHT
        || '; font-size: '
        || G_FONT_SIZE
        || '; background: '
        || P_BACKGROUND_COLOR
        || '; margin: 0; padding: '
        || P_PADDING
        || '; border: '
        || P_BORDER
        || '; '
        || P_EXTRA_STYLE
        || '" align="'
        || P_ALIGN
        || '" valign="top" bgcolor="'
        || P_BACKGROUND_COLOR
        || '">'
        || P_CONTENT
        || '</td>'
        || '</tr>'
        || '</table>';
    END PRINT_BUTTON;

    FUNCTION PRINT_PLAIN_LINK (
        P_URL     IN CLOB,
        P_LABEL   IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_BUTTON(P_CONTENT => '<a href="'
        || P_URL
        || '" style="color: '
        || G_TEXT_COLOR
        || '; text-decoration: none;">'
        || P_LABEL
        || '</a>');
    END PRINT_PLAIN_LINK;

    FUNCTION PRINT_PRIMARY_BUTTON (
        P_URL     IN CLOB,
        P_LABEL   IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_BUTTON(P_CONTENT => '<a href="'
        || P_URL
        || '" style="color: '
        || G_PRIMARY_BUTTON_TEXT_COLOR
        || '; text-decoration: none; font-weight: bold; font-family: '
        || G_FONT_FAMILY
        || '; font-size: 16px;">'
        || P_LABEL
        || '</a>',P_ALIGN => 'center',P_PADDING => '8px 0',P_BACKGROUND_COLOR => G_PRIMARY_BUTTON_BGCOLOR,P_BORDER => '1px solid #2284a1',P_EXTRA_STYLE
=> 'display: block; width: auto !important;');
    END PRINT_PRIMARY_BUTTON;

    FUNCTION PRINT_BUTTON_FACEBOOK (
        P_URL     IN CLOB,
        P_LABEL   IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_BUTTON(P_CONTENT => '<a href="'
        || P_URL
        || '" style="color: #ffffff; text-decoration: none; font-weight: bold; font-family: '
        || G_FONT_FAMILY
        || '; font-size: 12px;">'
        || P_LABEL
        || '</a>',P_BUTTON_CLASSES => 'tiny-button facebook',P_ALIGN => 'center',P_PADDING => '5px 0 4px',P_BACKGROUND_COLOR => '#3b5998',P_BORDER
=> '1px solid #2d4473',P_EXTRA_STYLE => 'display: block; width: auto !important;');
    END PRINT_BUTTON_FACEBOOK;

    FUNCTION PRINT_BUTTON_TWITTER (
        P_URL     IN CLOB,
        P_LABEL   IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_BUTTON(P_CONTENT => '<a href="'
        || P_URL
        || '" style="color: #ffffff; text-decoration: none; font-weight: bold; font-family: '
        || G_FONT_FAMILY
        || '; font-size: 12px;">'
        || P_LABEL
        || '</a>',P_BUTTON_CLASSES => 'tiny-button twitter',P_ALIGN => 'center',P_PADDING => '5px 0 4px',P_BACKGROUND_COLOR => '#00acee',P_BORDER => '1px solid #0087bb',P_EXTRA_STYLE => 'display: block; width: auto !important;');
    END PRINT_BUTTON_TWITTER;

    FUNCTION PRINT_BUTTON_GOOGLE_PLUS (
        P_URL     IN CLOB,
        P_LABEL   IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_BUTTON(P_CONTENT => '<a href="'
        || P_URL
        || '" style="color: #ffffff; text-decoration: none; font-weight: bold; font-family: '
        || G_FONT_FAMILY
        || '; font-size: 12px;">'
        || P_LABEL
        || '</a>',P_BUTTON_CLASSES => 'tiny-button google-plus',P_ALIGN => 'center',P_PADDING => '5px 0 4px',P_BACKGROUND_COLOR => '#DB4A39',P_BORDER
=> '1px solid #cc0000',P_EXTRA_STYLE => 'display: block; width: auto !important;');
    END PRINT_BUTTON_GOOGLE_PLUS;

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
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<img src="'
        || P_IMG_URL
        || '" style="outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; width: auto; max-width: 100%; float: left; clear: both; display: block;" align="'
        || P_ALIGN
        || '" />';
    END PRINT_IMAGE;

    /*
    Simple line to separate content
    */

    FUNCTION PRINT_HR RETURN CLOB
        IS
    BEGIN
        RETURN '<hr style="color: #d9d9d9; height: 1px; background: #d9d9d9; border: none;" />';
    END PRINT_HR;

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
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_ROW(P_CONTENT => PRINT_STANDARD_TD_CENTER(PRINT_CONTAINER(PRINT_COLUMN_WRAPPER(PRINT_COL_12(PRINT_SUB_COL_6(PRINT_IMAGE
(P_LOGO_URL),'left')
        || PRINT_SUB_COL_6(PRINT_TITLE(P_TITLE),'right') ) ) ) ),P_CLASSES => 'header',P_DISPLAY => 'table',P_HEADER_BACKGROUND_COLOR => G_HEADER_BACKGROUND_COLOR
)
        || '<br />';
    END PRINT_DEFAULT_BODY_HEADER;

    FUNCTION PRINT_DEFAULT_BODY_FOOTER (
        P_FOOTER_LINKS IN VARCHAR2
    ) RETURN CLOB
        IS
    BEGIN
        RETURN '<br /><br />'
        || PRINT_ROW(PRINT_COLUMN_WRAPPER(PRINT_COL_12(PRINT_STANDARD_TD_CENTER(PRINT_PARAGRAPH(P_TEXT => P_FOOTER_LINKS,P_ALIGN => 'center') )
) ) );
    END PRINT_DEFAULT_BODY_FOOTER;

    FUNCTION PRINT_GLOBAL_BODY (
        P_CONTENT IN CLOB
    ) RETURN CLOB
        IS
    BEGIN
        RETURN PRINT_GLOBAL_HEADER
        || OUTER_BODY(PRINT_GLOBAL_CSS
        || INNER_BODY(PRINT_STANDARD_TD_CENTER(P_CONTENT) ) )
        || PRINT_GLOBAL_END;
    END PRINT_GLOBAL_BODY;

    /**********************************************
    ***********************************************
    ***********************************************
    PRESET TEMPLATES
    ***********************************************
    ***********************************************
    **********************************************/

    /* Basic Template */

    FUNCTION BASIC (
        P_CONTENT IN T_CONTENT
    ) RETURN CLOB IS
        L_BODY   CLOB;
    BEGIN
        /* Build the email body */
        L_BODY := PRINT_GLOBAL_BODY(PRINT_DEFAULT_BODY_HEADER(P_CONTENT.LOGO_URL,P_CONTENT.TITLE)
        || PRINT_CONTAINER(PRINT_ROW(PRINT_COLUMN_WRAPPER(PRINT_COL_12(PRINT_STANDARD_TD(PRINT_H1(P_CONTENT.WELCOME_TITLE)
        || PRINT_PARAGRAPH_LEAD(P_CONTENT.SUB_WELCOME_TITLE)
        || PRINT_PARAGRAPH(P_CONTENT.TOP_PARAGRAPH) ) ) ) )
        || PRINT_ROW(PRINT_COLUMN_WRAPPER(PRINT_COL_12(PRINT_PANEL(P_CONTENT => PRINT_PARAGRAPH(P_TEXT => P_CONTENT.BOTTOM_PARAGRAPH),P_BACKGROUND_COLOR
=> '#ECF8FF') ) ) )
        || '<br />'
        || PRINT_ROW(PRINT_COLUMN_WRAPPER(PRINT_COL_6(PRINT_PANEL(PRINT_H6(P_CONTENT.SOCIAL_TITLE)
        || PRINT_BUTTON_FACEBOOK(P_URL => '#',P_LABEL => 'Facebook')
        || PRINT_HR
        || PRINT_BUTTON_TWITTER(P_URL => '#',P_LABEL => 'Twitter')
        || PRINT_HR
        || PRINT_BUTTON_GOOGLE_PLUS(P_URL => '#',P_LABEL => 'Google+') ) ) )
        || PRINT_COLUMN_WRAPPER(PRINT_COL_6(PRINT_PANEL(PRINT_H6(P_CONTENT.CONTACT_INFO)
        || PRINT_PARAGRAPH(P_CONTENT.CONTACT_PHONE)
        || PRINT_PARAGRAPH(P_CONTENT.CONTACT_EMAIL) ) ) ) )
        || PRINT_DEFAULT_BODY_FOOTER(P_CONTENT.FOOTER_LINKS) ) );

        /* Returns email body */

        RETURN L_BODY;
    END BASIC;

    /* Hero Template */

    FUNCTION HERO (
        P_CONTENT IN T_CONTENT
    ) RETURN CLOB IS
        L_BODY   CLOB;
    BEGIN
        /* Build the email body */
        L_BODY := PRINT_GLOBAL_BODY(PRINT_DEFAULT_BODY_HEADER(P_CONTENT.LOGO_URL,P_CONTENT.TITLE)
        || PRINT_CONTAINER(PRINT_ROW(PRINT_COLUMN_WRAPPER(PRINT_COL_12(PRINT_STANDARD_TD(PRINT_H1(P_CONTENT.WELCOME_TITLE)
        || PRINT_PARAGRAPH_LEAD(P_CONTENT.SUB_WELCOME_TITLE)
        || PRINT_IMAGE(P_CONTENT.BIG_PICTURE_URL) ) ) ) )
        || PRINT_ROW(PRINT_COLUMN_WRAPPER(PRINT_COL_12(PRINT_PANEL(P_CONTENT => PRINT_PARAGRAPH(P_TEXT => P_CONTENT.TOP_PARAGRAPH),P_BACKGROUND_COLOR
=> '#ECF8FF') )
        || '<br />'
        || PRINT_COL_12(PRINT_H3(P_CONTENT.BOTTOM_PARAGRAPH_TITLE
        || PRINT_SMALL_TEXT(P_CONTENT.BOTTOM_PARAGRAPH_SUBTITLE) )
        || PRINT_PARAGRAPH(P_TEXT => P_CONTENT.BOTTOM_PARAGRAPH) ) ) )
        || '<br />'
        || PRINT_ROW(PRINT_COLUMN_WRAPPER(PRINT_COL_6(PRINT_PANEL(PRINT_H6(P_CONTENT.SOCIAL_TITLE)
        || PRINT_BUTTON_FACEBOOK(P_URL => '#',P_LABEL => 'Facebook')
        || PRINT_HR
        || PRINT_BUTTON_TWITTER(P_URL => '#',P_LABEL => 'Twitter')
        || PRINT_HR
        || PRINT_BUTTON_GOOGLE_PLUS(P_URL => '#',P_LABEL => 'Google+') ) ) )
        || PRINT_COLUMN_WRAPPER(PRINT_COL_6(PRINT_PANEL(PRINT_H6(P_CONTENT.CONTACT_INFO)
        || PRINT_PARAGRAPH(P_CONTENT.CONTACT_PHONE)
        || PRINT_PARAGRAPH(P_CONTENT.CONTACT_EMAIL) ) ) ) )
        || PRINT_DEFAULT_BODY_FOOTER(P_CONTENT.FOOTER_LINKS) ) );

        /* Returns email body */

        RETURN L_BODY;
    END HERO;

    /* Sidebar Template */

    FUNCTION SIDEBAR (
        P_CONTENT IN T_CONTENT
    ) RETURN CLOB IS
        L_BODY   CLOB;
    BEGIN
        /* Build the email body */
        L_BODY := PRINT_GLOBAL_BODY(PRINT_DEFAULT_BODY_HEADER(P_CONTENT.LOGO_URL,P_CONTENT.TITLE)
        || PRINT_CONTAINER(PRINT_ROW(PRINT_COLUMN_WRAPPER(PRINT_COL_6(PRINT_STANDARD_TD(PRINT_H1(P_CONTENT.WELCOME_TITLE)
        || PRINT_PARAGRAPH(P_CONTENT.SUB_WELCOME_TITLE)
        || PRINT_PARAGRAPH(P_CONTENT.LEFT_PARAGRAPH) ) )
        || '<br />'
        || PRINT_COL_6(PRINT_PANEL(PRINT_PARAGRAPH(P_CONTENT.TOP_PARAGRAPH) ) )
        || '<br />'
        || PRINT_COL_6(PRINT_STANDARD_TD(PRINT_PARAGRAPH(P_CONTENT.LEFT_PARAGRAPH)
        || PRINT_PRIMARY_BUTTON(P_URL => '#',P_LABEL => 'Click Me!') ) ) )
        || PRINT_COLUMN_WRAPPER(PRINT_COL_6(PRINT_PANEL(PRINT_H6(P_CONTENT.RIGHT_HEADER)
        || PRINT_PARAGRAPH(P_CONTENT.RIGHT_SUB_HEADER)
        || PRINT_PLAIN_LINK('#','Just a Plain Link »')
        || PRINT_HR
        || PRINT_PLAIN_LINK('#','Just a Plain Link »')
        || PRINT_HR
        || PRINT_PLAIN_LINK('#','Just a Plain Link »')
        || PRINT_HR
        || PRINT_PLAIN_LINK('#','Just a Plain Link »')
        || PRINT_HR
        || PRINT_PLAIN_LINK('#','Just a Plain Link »') ) )
        || '<br />'
        || PRINT_COL_6(PRINT_PANEL(PRINT_H6(P_CONTENT.SOCIAL_TITLE)
        || PRINT_BUTTON_FACEBOOK(P_URL => '#',P_LABEL => 'Facebook')
        || PRINT_HR
        || PRINT_BUTTON_TWITTER(P_URL => '#',P_LABEL => 'Twitter')
        || PRINT_HR
        || PRINT_BUTTON_GOOGLE_PLUS(P_URL => '#',P_LABEL => 'Google+')
        || '<br />'
        || PRINT_H6(P_CONTENT.CONTACT_INFO)
        || PRINT_PARAGRAPH(P_CONTENT.CONTACT_PHONE)
        || PRINT_PARAGRAPH(P_CONTENT.CONTACT_EMAIL) ) ) ) )
        || PRINT_DEFAULT_BODY_FOOTER(P_CONTENT.FOOTER_LINKS) ) );

        /* Returns email body */

        RETURN L_BODY;
    END SIDEBAR;

    /* Sidebar Hero Template */

    FUNCTION SIDEBAR_HERO (
        P_CONTENT IN T_CONTENT
    ) RETURN CLOB IS
        L_BODY   CLOB;
    BEGIN
        /* Build the email body */
        L_BODY := PRINT_GLOBAL_BODY(PRINT_DEFAULT_BODY_HEADER(P_CONTENT.LOGO_URL,P_CONTENT.TITLE)
        || PRINT_CONTAINER(PRINT_ROW(PRINT_COLUMN_WRAPPER(PRINT_COL_12(PRINT_STANDARD_TD(PRINT_H1(P_CONTENT.WELCOME_TITLE)
        || PRINT_PARAGRAPH(P_CONTENT.SUB_WELCOME_TITLE)
        || PRINT_IMAGE(P_CONTENT.BIG_PICTURE_URL) ) )
        || PRINT_COL_12(PRINT_PANEL(PRINT_PARAGRAPH(P_CONTENT.TOP_PARAGRAPH) ) ) ) )
        || '<br />'
        || PRINT_ROW(PRINT_COLUMN_WRAPPER(PRINT_COL_6(PRINT_STANDARD_TD(PRINT_PARAGRAPH(P_CONTENT.LEFT_PARAGRAPH)
        || PRINT_PRIMARY_BUTTON(P_URL => '#',P_LABEL => 'Click Me!') ) ) )
        || PRINT_COLUMN_WRAPPER(PRINT_COL_6(PRINT_PANEL(PRINT_H6(P_CONTENT.RIGHT_HEADER)
        || PRINT_PARAGRAPH(P_CONTENT.RIGHT_SUB_HEADER)
        || PRINT_PLAIN_LINK('#','Just a Plain Link »')
        || PRINT_HR
        || PRINT_PLAIN_LINK('#','Just a Plain Link »')
        || PRINT_HR
        || PRINT_PLAIN_LINK('#','Just a Plain Link »') ) )
        || '<br />'
        || PRINT_COL_6(PRINT_PANEL(PRINT_H6(P_CONTENT.SOCIAL_TITLE)
        || PRINT_BUTTON_FACEBOOK(P_URL => '#',P_LABEL => 'Facebook')
        || PRINT_HR
        || PRINT_BUTTON_TWITTER(P_URL => '#',P_LABEL => 'Twitter')
        || PRINT_HR
        || PRINT_BUTTON_GOOGLE_PLUS(P_URL => '#',P_LABEL => 'Google+')
        || '<br />'
        || PRINT_H6(P_CONTENT.CONTACT_INFO)
        || PRINT_PARAGRAPH(P_CONTENT.CONTACT_PHONE)
        || PRINT_PARAGRAPH(P_CONTENT.CONTACT_EMAIL) ) ) ) )
        || PRINT_DEFAULT_BODY_FOOTER(P_CONTENT.FOOTER_LINKS) ) );

        /* Returns email body */

        RETURN L_BODY;
    END SIDEBAR_HERO;

END RWD_EMAIL;
/

