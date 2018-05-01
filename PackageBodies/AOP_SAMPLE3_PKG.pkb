--
-- AOP_SAMPLE3_PKG  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.AOP_SAMPLE3_PKG AS
--
-- Store output in AOP Output table
--

    PROCEDURE AOP_STORE_DOCUMENT (
        P_OUTPUT_BLOB        IN BLOB,
        P_OUTPUT_FILENAME    IN VARCHAR2,
        P_OUTPUT_MIME_TYPE   IN VARCHAR2
    )
        AS
    BEGIN
        INSERT INTO AOP_OUTPUT (
            OUTPUT_BLOB,
            FILENAME,
            MIME_TYPE,
            LAST_UPDATE_DATE
        ) VALUES (
            P_OUTPUT_BLOB,
            P_OUTPUT_FILENAME,
            P_OUTPUT_MIME_TYPE,
            SYSDATE
        );

        COMMIT;
    END AOP_STORE_DOCUMENT;
--
-- Send email from AOP
--

    PROCEDURE SEND_EMAIL_PRC (
        P_OUTPUT_BLOB        IN BLOB,
        P_OUTPUT_FILENAME    IN VARCHAR2,
        P_OUTPUT_MIME_TYPE   IN VARCHAR2
    ) AS
        L_ID   NUMBER;
    BEGIN
        L_ID := APEX_MAIL.SEND(P_TO => 'support@apexofficeprint.com',P_FROM => 'support@apexofficeprint.com',P_SUBJ => 'Mail from APEX with attachment'
,P_BODY => 'Please review the attachment.',P_BODY_HTML => '<b>Please</b> review the attachment.');

        APEX_MAIL.ADD_ATTACHMENT(P_MAIL_ID => L_ID,P_ATTACHMENT => P_OUTPUT_BLOB,P_FILENAME => P_OUTPUT_FILENAME,P_MIME_TYPE => P_OUTPUT_MIME_TYPE
);

        COMMIT;
    END SEND_EMAIL_PRC;
--
-- AOP_PLSQL3_PKG example
--

    PROCEDURE CALL_AOP_PLSQL3_PKG AS

        C_MIME_TYPE_DOCX   VARCHAR2(100) := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        C_MIME_TYPE_XLSX   VARCHAR2(100) := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        C_MIME_TYPE_PPTX   VARCHAR2(100) := 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
        C_MIME_TYPE_PDF    VARCHAR2(100) := 'application/pdf';
        L_TEMPLATE         BLOB;
        L_OUTPUT_FILE      BLOB;
    BEGIN
        SELECT
            TEMPLATE_BLOB
        INTO
            L_TEMPLATE
        FROM
            AOP_TEMPLATE
        WHERE
            ID = 1;

        L_OUTPUT_FILE := AOP_PLSQL3_PKG.MAKE_AOP_REQUEST(P_JSON => '[{ "filename": "file1", "data": [{ "cust_first_name": "APEX Office Print" }] }]'
,P_TEMPLATE => L_TEMPLATE,P_OUTPUT_TYPE => 'docx',P_AOP_REMOTE_DEBUG => 'Yes');

        INSERT INTO AOP_OUTPUT (
            OUTPUT_BLOB,
            FILENAME,
            MIME_TYPE,
            LAST_UPDATE_DATE
        ) VALUES (
            L_OUTPUT_FILE,
            'output.docx',
            C_MIME_TYPE_DOCX,
            SYSDATE
        );

    END CALL_AOP_PLSQL3_PKG;
--
-- AOP_API3_PKG example
--

    PROCEDURE CALL_AOP_API3_PKG AS
        L_BINDS             WWV_FLOW_PLUGIN_UTIL.T_BIND_LIST;
        L_RETURN            BLOB;
        L_OUTPUT_FILENAME   VARCHAR2(100) := 'output';
    BEGIN
  -- define bind variables
        L_BINDS(1).NAME := 'p_id';
        L_BINDS(1).VALUE := '1';
        FOR I IN 1..L_BINDS.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('AOP: Bind '
            || TO_CHAR(I)
            || ': '
            || L_BINDS(I).NAME
            || ': '
            || L_BINDS(I).VALUE);
        END LOOP;

        L_RETURN := AOP_API3_PKG.PLSQL_CALL_TO_AOP(P_DATA_TYPE => 'SQL',P_DATA_SOURCE => q'[
                  select
                    'file1' as "filename",
                    cursor(
                      select
                        c.cust_first_name as "cust_first_name",
                        c.cust_last_name as "cust_last_name",
                        c.cust_city as "cust_city",
                        cursor(select o.order_total as "order_total",
                                      'Order ' || rownum as "order_name",
                                  cursor(select p.product_name as "product_name",
                                                i.quantity as "quantity",
                                                i.unit_price as "unit_price", APEX_WEB_SERVICE.BLOB2CLOBBASE64(p.product_image) as "image"
                                           from demo_order_items i, demo_product_info p
                                          where o.order_id = i.order_id
                                            and i.product_id = p.product_id
                                        ) "product"
                                 from demo_orders o
                                where c.customer_id = o.customer_id
                              ) "orders"
                      from demo_customers c
                      where customer_id = :p_id
                    ) as "data"
                  from dual
                ]'
,P_TEMPLATE_TYPE => 'SQL',P_TEMPLATE_SOURCE => q'[
                   select template_type, template_blob
                    from aop_template
                   where id = 1
                ]'
,P_OUTPUT_TYPE => 'docx',P_OUTPUT_FILENAME => L_OUTPUT_FILENAME,P_BINDS => L_BINDS,P_AOP_URL => 'http://www.apexofficeprint.com/api/',P_API_KEY
=> '1C511A58ECC73874E0530100007FD01A',P_APP_ID => 232);

        INSERT INTO AOP_OUTPUT (
            OUTPUT_BLOB,
            FILENAME,
            MIME_TYPE,
            LAST_UPDATE_DATE
        ) VALUES (
            L_RETURN,
            L_OUTPUT_FILENAME,
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            SYSDATE
        );

    END CALL_AOP_API3_PKG;
-- procedure which can be scheduled with dbms_scheduler
-- to automatically receive a PDF with a specific Interactive Report
-- debugging is set to Yes
-- set dbms_output or htp output on
-- view the debug output with: select * from apex_debug_messages;
-- view the JSON with: select clob001 from apex_collections where collection_name = 'AOP_DEBUG';

    PROCEDURE SCHEDULE_AOP_API3_PKG AS
        L_BINDS             WWV_FLOW_PLUGIN_UTIL.T_BIND_LIST;
        L_RETURN            BLOB;
        L_OUTPUT_FILENAME   VARCHAR2(100) := 'output';
        L_ID                NUMBER;
    BEGIN
        AOP_API3_PKG.CREATE_APEX_SESSION(P_APP_ID => 232,
    --p_user_name    => 'DIMI',
        P_PAGE_ID => 5,P_ENABLE_DEBUG => 'Yes');

        APEX_UTIL.SET_SESSION_STATE('P5_CUSTOMER_ID','2');
        L_RETURN := AOP_API3_PKG.PLSQL_CALL_TO_AOP(P_DATA_TYPE => AOP_API3_PKG.C_SOURCE_TYPE_RPT,P_DATA_SOURCE => 'ir1|PRIMARY',P_TEMPLATE_TYPE
=> AOP_API3_PKG.C_SOURCE_TYPE_APEX,P_TEMPLATE_SOURCE => 'aop_interactive.docx',P_OUTPUT_TYPE => 'pdf',P_OUTPUT_FILENAME => L_OUTPUT_FILENAME
,P_BINDS => L_BINDS,P_AOP_URL => 'http://www.apexofficeprint.com/api/',P_API_KEY => '1C511A58ECC73874E0530100007FD01A',P_APP_ID => 232,P_PAGE_ID
=> 5);

        L_ID := APEX_MAIL.SEND(P_TO => 'support@apexofficeprint.com',P_FROM => 'support@apexofficeprint.com',P_SUBJ => 'Mail from APEX with attachment PLSQL 2'
,P_BODY => 'Please review the attachment.',P_BODY_HTML => '<b>Please</b> review the attachment.');

        APEX_MAIL.ADD_ATTACHMENT(P_MAIL_ID => L_ID,P_ATTACHMENT => L_RETURN,P_FILENAME => L_OUTPUT_FILENAME,P_MIME_TYPE => AOP_API3_PKG.C_MIME_TYPE_PDF
);

        APEX_MAIL.PUSH_QUEUE;
    END SCHEDULE_AOP_API3_PKG;
--
-- REST example (call this procedure from ORDS)
--

    FUNCTION GET_FILE (
        P_CUSTOMER_ID   IN NUMBER,
        P_OUTPUT_TYPE   IN VARCHAR2
    ) RETURN BLOB AS

        PRAGMA AUTONOMOUS_TRANSACTION;
        L_BINDS             WWV_FLOW_PLUGIN_UTIL.T_BIND_LIST;
        L_TEMPLATE          VARCHAR2(100);
        L_OUTPUT_FILENAME   VARCHAR2(100);
        L_RETURN            BLOB;
    BEGIN
        IF
            P_OUTPUT_TYPE = 'xlsx'
        THEN
            L_TEMPLATE := 'aop_IR_template.xlsx';
        ELSE
            L_TEMPLATE := 'aop_interactive.docx';
        END IF;

        L_RETURN := AOP_API3_PKG.PLSQL_CALL_TO_AOP(P_DATA_TYPE => AOP_API3_PKG.C_SOURCE_TYPE_RPT,P_DATA_SOURCE => 'ir1|PRIMARY',P_TEMPLATE_TYPE
=> AOP_API3_PKG.C_SOURCE_TYPE_APEX,P_TEMPLATE_SOURCE => L_TEMPLATE,P_OUTPUT_TYPE => P_OUTPUT_TYPE,P_OUTPUT_FILENAME => L_OUTPUT_FILENAME
,P_BINDS => L_BINDS,P_AOP_URL => 'http://www.apexofficeprint.com/api/',P_API_KEY => '1C511A58ECC73874E0530100007FD01A',P_APP_ID => 232,P_PAGE_ID
=> 5,P_USER_NAME => 'ADMIN',P_INIT_CODE => q'[apex_util.set_session_state('P5_CUSTOMER_ID',']'
        || TO_CHAR(P_CUSTOMER_ID)
        || q'[');]',P_AOP_REMOTE_DEBUG => 'No');
  -- we have to do a commit in order to call this function from a SQL statement

        COMMIT;
        RETURN L_RETURN;
    END GET_FILE;
--
-- write to filesystem
-- MAKE SURE YOU CREATE A DIRECTORY FIRST CALLED AOP_OUTPUT
-- CREATE DIRECTORY AOP_OUTPUT AS '/tmp';
--

    PROCEDURE WRITE_FILESYSTEM AS
  -- aop

        L_BINDS             WWV_FLOW_PLUGIN_UTIL.T_BIND_LIST;
        L_OUTPUT_FILENAME   VARCHAR2(100) := 'output';
  -- file
        L_FILE              UTL_FILE.FILE_TYPE;
        L_BUFFER            RAW(32767);
        L_AMOUNT            BINARY_INTEGER := 32767;
        L_POS               INTEGER := 1;
        L_BLOB              BLOB;
        L_BLOB_LEN          INTEGER;
    BEGIN
  -- loop over records
        L_BINDS(1).NAME := 'p_id';
        FOR R IN (
            SELECT
                1 AS ID
            FROM
                DUAL
            UNION ALL
            SELECT
                2 AS ID
            FROM
                DUAL
        ) LOOP
            L_POS := 1;
            L_BINDS(1).VALUE := R.ID;
    -- call AOP
            L_BLOB := AOP_API3_PKG.PLSQL_CALL_TO_AOP(P_DATA_TYPE => 'SQL',P_DATA_SOURCE => q'[
                  select
                    'file1' as "filename",
                    cursor(
                      select
                        c.cust_first_name as "cust_first_name",
                        c.cust_last_name as "cust_last_name",
                        c.cust_city as "cust_city",
                        cursor(select o.order_total as "order_total",
                                      'Order ' || rownum as "order_name",
                                  cursor(select p.product_name as "product_name",
                                                i.quantity as "quantity",
                                                i.unit_price as "unit_price", APEX_WEB_SERVICE.BLOB2CLOBBASE64(p.product_image) as "image"
                                           from demo_order_items i, demo_product_info p
                                          where o.order_id = i.order_id
                                            and i.product_id = p.product_id
                                        ) "product"
                                 from demo_orders o
                                where c.customer_id = o.customer_id
                              ) "orders"
                      from demo_customers c
                      where customer_id = :p_id
                    ) as "data"
                  from dual
                ]'
,P_TEMPLATE_TYPE => 'APEX',P_TEMPLATE_SOURCE => 'aop_template_d01.docx',P_OUTPUT_TYPE => 'pdf',P_OUTPUT_FILENAME => L_OUTPUT_FILENAME,P_BINDS
=> L_BINDS,P_AOP_URL => 'http://www.apexofficeprint.com/api/',P_API_KEY => '1C511A58ECC73874E0530100007FD01A',P_APP_ID => 232);

            L_OUTPUT_FILENAME := TO_CHAR(R.ID)
            || '_'
            || L_OUTPUT_FILENAME;
      -- write to file system
            BEGIN
                L_BLOB_LEN := DBMS_LOB.GETLENGTH(L_BLOB);
        -- Open the destination file.
                L_FILE := UTL_FILE.FOPEN('AOP_OUTPUT',L_OUTPUT_FILENAME,'w',32767);
        -- Read chunks of the BLOB and write them to the file
        -- until complete.
                WHILE L_POS < L_BLOB_LEN LOOP
                    DBMS_LOB.READ(L_BLOB,L_AMOUNT,L_POS,L_BUFFER);
                    UTL_FILE.PUT_RAW(L_FILE,L_BUFFER,TRUE);
                    L_POS := L_POS + L_AMOUNT;
                END LOOP;
        -- Close the file.

                UTL_FILE.FCLOSE(L_FILE);
            EXCEPTION
                WHEN OTHERS THEN
          -- Close the file if something goes wrong.
                    IF
                        UTL_FILE.IS_OPEN(L_FILE)
                    THEN
                        UTL_FILE.FCLOSE(L_FILE);
                    END IF;
                    RAISE;
            END;

        END LOOP;

    END WRITE_FILESYSTEM;
--
-- view the tags that are used in a template (docx)
--

    PROCEDURE GET_TAGS_IN_TEMPLATE AS
        L_OUTPUT   VARCHAR2(100);
        L_BLOB     BLOB;
        L_CLOB     CLOB;
    BEGIN
        L_BLOB := AOP_API3_PKG.PLSQL_CALL_TO_AOP(P_DATA_SOURCE => q'[
                  select
                    'file1' as "filename",
                    cursor(
                      select sysdate from dual
                    ) as "data"
                  from dual
                ]'
,P_TEMPLATE_SOURCE => 'aop_template_d01.docx',P_OUTPUT_TYPE => 'count_tags',P_OUTPUT_FILENAME => L_OUTPUT,P_AOP_URL => 'http://www.apexofficeprint.com/api/'
,P_API_KEY => '1C511A58ECC73874E0530100007FD01A',P_APP_ID => 232);

        L_CLOB := AOP_API3_PKG.BLOB2CLOB(L_BLOB);
        SYS.HTP.P(L_CLOB);
  -- returns: {"{cust_last_name}":1,"{cust_first_name}":2,"{cust_city}":1,"{#orders}":2,"{#product}":2,"{product_name}":2,"{/product}":2,"{order_total}":2,"{/orders}":2,"{%image}":1,"{unit_price}":1,"{#quantity<3}":1,"{quantity}":2,"{/quantity<3}":2,"{^quantity<3}":1,"{ unit_price*quantity }":1}
    END GET_TAGS_IN_TEMPLATE;
--
-- all possible options for Excel cell styling
--

    FUNCTION TEST_EXCEL_STYLES RETURN CLOB
        AS
    BEGIN
        RETURN '[{"data": [{
            "tag1": "Lorem ipsum",
            "info1":"in bold and arial",
            "tag1_font_bold":"y",
            "tag1_font_name":"Arial",
            "tag2": "Lorem ipsum",
            "info2":"arial font",
            "tag2_font_name":"Arial",
            "tag3": "Lorem ipsum",
            "info3":"font 20",
            "tag3_font_size":"20",
            "tag4": "Lorem ipsum",
            "info4":"font color #1782A6",
            "tag4_font_color":"#1782A6",
            "tag5": "Lorem ipsum",
            "info5":"underline single",
            "tag5_font_underline":"single",
            "tag6": "Lorem ipsum",
            "info6":"underline double double",
            "tag6_font_underline":"double",
            "tag7": "Lorem ipsum",
            "info7":"underline single financieel",
            "tag7_font_underline":"single-financial",
            "tag8": "Lorem ipsum",
            "info8":"underline dubbel financieel",
            "tag8_font_underline":"double-financial",
            "tag9": "Lorem ipsum",
            "info9":"left:thin, top:medium, right:thick, bottom:hair",
            "tag9_border_left":"thin",
            "tag9_border_top":"medium",
            "tag9_border_right":"thick",
            "tag9_border_bottom":"hair",
            "tag10": "Lorem ipsum",
            "info10":"left:dotted, top:medium-dashed, right:dash-dot, bottom:medium-dash-dot",
            "tag10_border_left":"dotted",
            "tag10_border_top":"medium-dashed",
            "tag10_border_right":"dash-dot",
            "tag10_border_bottom":"medium-dash-dot",
            "tag11": "Lorem ipsum",
            "info11":"left:dash-dot-dot, top:medium-dash-dot-dot, right:slash-dash-dot, bottom:double",
            "tag11_border_left":"dash-dot-dot",
            "tag11_border_top":"medium-dash-dot-dot",
            "tag11_border_right":"slash-dash-dot",
            "tag11_border_bottom":"double",
            "tag29": "Lorem ipsum",
            "info29":"diagonal border, up-wards",
            "tag29_border_diagonal":"dash-dot-dot",
            "tag29_border_diagonal_direction":"up-wards",
            "tag29_border_diagonal_color":"#FFFFFF",
            "tag30": "Lorem ipsum",
            "info30":"diagonal border, down-wards, colored",
            "tag30_border_diagonal":"dotted",
            "tag30_border_diagonal_direction":"down-wards",
            "tag30_border_diagonal_color":"4E8A0E",
            "tag31": "Lorem ipsum",
            "info31":"diagonal border, both",
            "tag31_border_diagonal":"slash-dash-dot",
            "tag31_border_diagonal_direction":"both",
            "tag31_border_diagonal_color":"ED4043",
            "tag12": "Lorem ipsum",
            "info12":"background green, font color blue",
            "tag12_cell_background":"1DF248",
            "tag12_font_color":"020EB8",
            "tag13": "Lorem ipsum",
            "info13":"pattern: dark-gray, pattern green, background yellow",
            "tag13_cell_pattern":"dark-gray",
            "tag13_cell_color":"FF17881D",
            "tag13_background_color":"FFE9E76B",
            "tag14": "Lorem ipsum",
            "info14":"pattern: medium-gray",
            "tag14_cell_pattern":"medium-gray",
            "tag15": "Lorem ipsum",
            "info15":"pattern: light-gray",
            "tag15_cell_pattern":"light-gray",
            "tag16": "Lorem ipsum",
            "info16":"pattern: gray-0625",
            "tag16_cell_pattern":"",
            "tag17": "Lorem ipsum",
            "info17":"pattern: dark-horizontal",
            "tag17_cell_pattern":"dark-horizontal",
            "tag18": "Lorem ipsum",
            "info18":"pattern: dark-vertical",
            "tag18_cell_pattern":"dark-vertical",
            "tag19": "Lorem ipsum",
            "info19":"pattern: dark-down",
            "tag19_cell_pattern":"dark-down",
            "tag20": "Lorem ipsum",
            "info20":"pattern: dark-up",
            "tag20_cell_pattern":"dark-up",
            "tag21": "Lorem ipsum",
            "info21":"pattern: dark-grid",
            "tag21_cell_pattern":"dark-grid",
            "tag22": "Lorem ipsum",
            "info22":"pattern: dark-trellis",
            "tag22_cell_pattern":"dark-trellis",
            "tag23": "Lorem ipsum",
            "info23":"pattern: light-horizontal",
            "tag23_cell_pattern":"light-horizontal",
            "tag24": "Lorem ipsum",
            "info24":"pattern: light-vertical",
            "tag24_cell_pattern":"light-vertical",
            "tag25": "Lorem ipsum",
            "info25":"pattern: light-down",
            "tag25_cell_pattern":"light-down",
            "tag26": "Lorem ipsum",
            "info26":"pattern: light-up",
            "tag26_cell_pattern":"light-up",
            "tag27": "Lorem ipsum",
            "info27":"pattern: light-grid",
            "tag27_cell_pattern":"light-grid",
            "tag28": "Lorem ipsum",
            "info28":"pattern: light-trellis",
            "tag28_cell_pattern":"light-trellis",
            "tag32": "Lorem ipsum",
            "info32":"horizonal alignment: center",
            "tag32_text_h_alignment":"center",
            "tag33": "Lorem ipsum",
            "info33":"horizonal alignment: right",
            "tag33_text_h_alignment":"right",
            "tag34": "Lorem ipsum",
            "info34":"horizonal alignment: fill",
            "tag34_text_h_alignment":"fill",
            "tag35": "Lorem ipsum",
            "info35":"horizonal alignment: justify",
            "tag35_text_h_alignment":"justify",
            "tag36": "Lorem ipsum",
            "info36":"horizonal alignment: center-continous",
            "tag36_text_h_alignment":"center-continous",
            "tag37": "Lorem ipsum",
            "info37":"horizonal alignment: distributed",
            "tag37_text_h_alignment":"distributed",
            "tag38": "Lorem ipsum",
            "info38":"horizonal alignment: left (was right)",
            "tag38_text_h_alignment":"left",
            "tag39": "Lorem ipsum",
            "info39":"vertical alignment: top",
            "tag39_text_v_alignment":"top",
            "tag40": "Lorem ipsum",
            "info40":"vertical alignment: center",
            "tag40_text_v_alignment":"center",
            "tag41": "Lorem ipsum",
            "info41":"vertical alignment: justify",
            "tag41_text_v_alignment":"justify",
            "tag42": "Lorem ipsum",
            "info42":"vertical alignment: distributed",
            "tag42_text_v_alignment":"distributed",
            "tag43": "Lorem ipsum",
            "info43":"vertical alignment: bottom (was top)",
            "tag43_text_v_alignment":"bottom",
            "tag44": "Lorem ipsum",
            "info44":"text rotation: 90",
            "tag44_text_rotation":"90",
            "tag45": "Lorem ipsum",
            "info45":"text rotation: 45",
            "tag45_text_rotation":"45",
            "tag46": "Lorem ipsum",
            "info46":"text rotation: 0",
            "tag46_text_rotation":"0",
            "tag47": "Lorem ipsum",
            "info47":"text rotation: -45",
            "tag47_text_rotation":"-45",
            "tag48": "Lorem ipsum",
            "info48":"text rotation: -180",
            "tag48_text_rotation":"-180",
            "tag49": "Lorem ipsum",
            "info49":"text rotation: aligned-vertically",
            "tag49_text_rotation":"aligned-vertically",
            "tag50": "Lorem ipsum",
            "info50":"text indent: (Number of spaces to indent = indent value * 3)",
            "tag50_text_indent":"2",
            "tag51": "Lorem ipsum Lorem ipsumLorem ipsum",
            "info51":"text wrap: y",
            "tag51_text_wrap":"y",
            "tag52": "Lorem ipsum Lorem ipsumLorem ipsum",
            "info52":"text shrink: y",
            "tag52_text_shrink":"y",
            "tag53": "Lorem ipsum",
            "info53":"cell locked: y",
            "tag53_cell_locked":"y",
            "tag54": "Lorem ipsum",
            "info54":"cell hidden: y",
            "tag54_cell_hidden":"y"
            }],
            "filename": "file1"}]'
;
    END TEST_EXCEL_STYLES;

END AOP_SAMPLE3_PKG;
/

