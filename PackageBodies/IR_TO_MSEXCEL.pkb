--
-- IR_TO_MSEXCEL  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER."IR_TO_MSEXCEL" AS

    FUNCTION GET_AFFECTED_REGION_ID (
        P_DYNAMIC_ACTION_ID   IN APEX_APPLICATION_PAGE_DA_ACTS.ACTION_ID%TYPE,
        P_HTML_REGION_ID      IN VARCHAR2
    ) RETURN APEX_APPLICATION_PAGE_DA_ACTS.AFFECTED_REGION_ID%TYPE IS
        V_AFFECTED_REGION_ID   APEX_APPLICATION_PAGE_DA_ACTS.AFFECTED_REGION_ID%TYPE;
    BEGIN
        SELECT
            AFFECTED_REGION_ID
        INTO
            V_AFFECTED_REGION_ID
        FROM
            APEX_APPLICATION_PAGE_DA_ACTS AAPDA
        WHERE
            AAPDA.ACTION_ID = P_DYNAMIC_ACTION_ID
            AND   PAGE_ID IN (
                V('APP_PAGE_ID'),
                0
            )
            AND   APPLICATION_ID = V('APP_ID')
            AND   ROWNUM < 2;

        IF
            V_AFFECTED_REGION_ID IS NULL
        THEN
            BEGIN
                SELECT
                    REGION_ID
                INTO
                    V_AFFECTED_REGION_ID
                FROM
                    APEX_APPLICATION_PAGE_REGIONS
                WHERE
                    STATIC_ID = P_HTML_REGION_ID
                    AND   PAGE_ID IN (
                        V('APP_PAGE_ID'),
                        0
                    )
                    AND   APPLICATION_ID = V('APP_ID');

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    SELECT
                        REGION_ID
                    INTO
                        V_AFFECTED_REGION_ID
                    FROM
                        APEX_APPLICATION_PAGE_REGIONS
                    WHERE
                        REGION_ID = LTRIM(P_HTML_REGION_ID,'R')
                        AND   PAGE_ID IN (
                            V('APP_PAGE_ID'),
                            0
                        )
                        AND   APPLICATION_ID = V('APP_ID');

            END;

        END IF;

        RETURN V_AFFECTED_REGION_ID;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'IR_TO_MSEXCEL.get_affected_region_id: No region found!');
    END GET_AFFECTED_REGION_ID;
  ------------------------------------------------------------------------------

    FUNCTION GET_AFFECTED_REGION_STATIC_ID (
        P_DYNAMIC_ACTION_ID   IN APEX_APPLICATION_PAGE_DA_ACTS.ACTION_ID%TYPE
    ) RETURN APEX_APPLICATION_PAGE_REGIONS.STATIC_ID%TYPE IS
        V_AFFECTED_REGION_SELECTOR   APEX_APPLICATION_PAGE_REGIONS.STATIC_ID%TYPE;
    BEGIN
        SELECT
            NVL(STATIC_ID,'R'
            || TO_CHAR(AFFECTED_REGION_ID) )
        INTO
            V_AFFECTED_REGION_SELECTOR
        FROM
            APEX_APPLICATION_PAGE_DA_ACTS AAPDA,
            APEX_APPLICATION_PAGE_REGIONS R
        WHERE
            AAPDA.ACTION_ID = P_DYNAMIC_ACTION_ID
            AND   AAPDA.AFFECTED_REGION_ID = R.REGION_ID
            AND   R.SOURCE_TYPE = 'Interactive Report'
            AND   AAPDA.PAGE_ID = V('APP_PAGE_ID')
            AND   AAPDA.APPLICATION_ID = V('APP_ID')
            AND   R.PAGE_ID = V('APP_PAGE_ID')
            AND   R.APPLICATION_ID = V('APP_ID');

        RETURN V_AFFECTED_REGION_SELECTOR;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GET_AFFECTED_REGION_STATIC_ID;
  ------------------------------------------------------------------------------

    FUNCTION RENDER (
        P_DYNAMIC_ACTION   IN APEX_PLUGIN.T_DYNAMIC_ACTION,
        P_PLUGIN           IN APEX_PLUGIN.T_PLUGIN
    ) RETURN APEX_PLUGIN.T_DYNAMIC_ACTION_RENDER_RESULT IS

        V_JAVASCRIPT_CODE            VARCHAR2(1000);
        V_RESULT                     APEX_PLUGIN.T_DYNAMIC_ACTION_RENDER_RESULT;
        V_PLUGIN_ID                  VARCHAR2(100);
        V_AFFECTED_REGION_SELECTOR   APEX_APPLICATION_PAGE_REGIONS.STATIC_ID%TYPE;
    BEGIN
        V_PLUGIN_ID := APEX_PLUGIN.GET_AJAX_IDENTIFIER;
        V_AFFECTED_REGION_SELECTOR := GET_AFFECTED_REGION_STATIC_ID(P_DYNAMIC_ACTION.ID);
        IF
            NVL(P_DYNAMIC_ACTION.ATTRIBUTE_03,'Y') = 'Y'
        THEN
            IF
                V_AFFECTED_REGION_SELECTOR IS NOT NULL
            THEN 
        -- add XLSX Icon to Affected IR Region
                V_JAVASCRIPT_CODE := 'addDownloadXLSXIcon('''
                || V_PLUGIN_ID
                || ''','''
                || V_AFFECTED_REGION_SELECTOR
                || ''');';
                APEX_JAVASCRIPT.ADD_ONLOAD_CODE(V_JAVASCRIPT_CODE,V_AFFECTED_REGION_SELECTOR);
            ELSE
        -- add XLSX Icon to all IR Regions on the page
                FOR I IN (
                    SELECT
                        NVL(STATIC_ID,'R'
                        || TO_CHAR(REGION_ID) ) AS AFFECTED_REGION_SELECTOR
                    FROM
                        APEX_APPLICATION_PAGE_REGIONS R
                    WHERE
                        R.PAGE_ID = V('APP_PAGE_ID')
                        AND   R.APPLICATION_ID = V('APP_ID')
                        AND   R.SOURCE_TYPE = 'Interactive Report'
                ) LOOP
                    V_JAVASCRIPT_CODE := 'addDownloadXLSXIcon('''
                    || V_PLUGIN_ID
                    || ''','''
                    || I.AFFECTED_REGION_SELECTOR
                    || ''');';

                    APEX_JAVASCRIPT.ADD_ONLOAD_CODE(V_JAVASCRIPT_CODE,I.AFFECTED_REGION_SELECTOR);
                END LOOP;
            END IF;
        END IF;

        APEX_JAVASCRIPT.ADD_LIBRARY(P_NAME => 'IR2MSEXCEL',P_DIRECTORY => P_PLUGIN.FILE_PREFIX);
        IF
            V_AFFECTED_REGION_SELECTOR IS NOT NULL
        THEN
            V_RESULT.JAVASCRIPT_FUNCTION := 'function(){get_excel_gpv('''
            || V_AFFECTED_REGION_SELECTOR
            || ''','''
            || V_PLUGIN_ID
            || ''')}';
        ELSE
            V_RESULT.JAVASCRIPT_FUNCTION := 'function(){console.log("No Affected Region Found!");}';
        END IF;

        V_RESULT.AJAX_IDENTIFIER := V_PLUGIN_ID;
        RETURN V_RESULT;
    END RENDER;
  ------------------------------------------------------------------------------

    FUNCTION AJAX (
        P_DYNAMIC_ACTION   IN APEX_PLUGIN.T_DYNAMIC_ACTION,
        P_PLUGIN           IN APEX_PLUGIN.T_PLUGIN
    ) RETURN APEX_PLUGIN.T_DYNAMIC_ACTION_AJAX_RESULT IS

        P_DOWNLOAD_TYPE        VARCHAR2(1);
        P_CUSTOM_WIDTH         VARCHAR2(1000);
        V_MAXIMUM_ROWS         NUMBER;
        V_DUMMY                APEX_PLUGIN.T_DYNAMIC_ACTION_AJAX_RESULT;
        V_AFFECTED_REGION_ID   APEX_APPLICATION_PAGE_DA_ACTS.AFFECTED_REGION_ID%TYPE;
    BEGIN
        P_DOWNLOAD_TYPE := NVL(P_DYNAMIC_ACTION.ATTRIBUTE_02,'E');
        V_AFFECTED_REGION_ID := GET_AFFECTED_REGION_ID(P_DYNAMIC_ACTION_ID => P_DYNAMIC_ACTION.ID,P_HTML_REGION_ID => APEX_APPLICATION.G_X03);

        V_MAXIMUM_ROWS := NVL(NVL(P_DYNAMIC_ACTION.ATTRIBUTE_01,XML_TO_XSLX.GET_MAX_ROWS(P_APP_ID => APEX_APPLICATION.G_X01,P_PAGE_ID => APEX_APPLICATION
.G_X02,P_REGION_ID => V_AFFECTED_REGION_ID) ),1000);

        IF
            P_DOWNLOAD_TYPE = 'E'
        THEN -- Excel XLSX
            XML_TO_XSLX.DOWNLOAD_FILE(P_APP_ID => APEX_APPLICATION.G_X01,P_PAGE_ID => APEX_APPLICATION.G_X02,P_REGION_ID => V_AFFECTED_REGION_ID,P_COL_LENGTH
=> APEX_APPLICATION.G_X04
            || P_CUSTOM_WIDTH,P_MAX_ROWS => V_MAXIMUM_ROWS);
        ELSIF P_DOWNLOAD_TYPE = 'X' THEN -- XML
            IR_TO_XML.GET_REPORT_XML(P_APP_ID => APEX_APPLICATION.G_X01,P_PAGE_ID => APEX_APPLICATION.G_X02,P_REGION_ID => V_AFFECTED_REGION_ID,P_RETURN_TYPE
=> 'X',P_GET_PAGE_ITEMS => 'N',P_ITEMS_LIST => NULL,P_COLLECTION_NAME => NULL,P_MAX_ROWS => V_MAXIMUM_ROWS);
        ELSIF P_DOWNLOAD_TYPE = 'T' THEN -- Debug txt
            IR_TO_XML.GET_REPORT_XML(P_APP_ID => APEX_APPLICATION.G_X01,P_PAGE_ID => APEX_APPLICATION.G_X02,P_REGION_ID => V_AFFECTED_REGION_ID,P_RETURN_TYPE
=> 'Q',P_GET_PAGE_ITEMS => 'N',P_ITEMS_LIST => NULL,P_COLLECTION_NAME => NULL,P_MAX_ROWS => V_MAXIMUM_ROWS);
        ELSIF P_DOWNLOAD_TYPE = 'M' THEN -- use Moritz Klein engine https://github.com/commi235                        
            APEXIR_XLSX_PKG.DOWNLOAD(P_IR_REGION_ID => V_AFFECTED_REGION_ID,P_APP_ID => APEX_APPLICATION.G_X01,P_IR_PAGE_ID => APEX_APPLICATION.G_X02
);
        ELSE
            RAISE_APPLICATION_ERROR(-20001,'GPV_IR_TO_MSEXCEL : unknown Return Type');
        END IF;

        RETURN V_DUMMY;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,SQLERRM
            || CHR(10)
            || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    END AJAX;

END IR_TO_MSEXCEL;
/

