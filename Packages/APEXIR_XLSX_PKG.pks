--
-- APEXIR_XLSX_PKG  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER."APEXIR_XLSX_PKG" AUTHID CURRENT_USER AS
  /*
   This is mock package to make other packages compilable
   
   to use original commi235/APEX_IR_XLSX generating engine,
   please download it from https://github.com/commi235/APEX_IR_XLSX
  */
    PROCEDURE DOWNLOAD (
        P_IR_REGION_ID          NUMBER := NULL,
        P_APP_ID                NUMBER := NV('APP_ID'),
        P_IR_PAGE_ID            NUMBER := NV('APP_PAGE_ID'),
        P_IR_SESSION_ID         NUMBER := NV('SESSION'),
        P_IR_REQUEST            VARCHAR2 := V('REQUEST'),
        P_IR_VIEW_MODE          VARCHAR2 := NULL,
        P_COLUMN_HEADERS        BOOLEAN := TRUE,
        P_COL_HDR_HELP          BOOLEAN := TRUE,
        P_AGGREGATES            IN BOOLEAN := TRUE,
        P_PROCESS_HIGHLIGHTS    IN BOOLEAN := TRUE,
        P_SHOW_REPORT_TITLE     IN BOOLEAN := TRUE,
        P_SHOW_FILTERS          IN BOOLEAN := TRUE,
        P_SHOW_HIGHLIGHTS       IN BOOLEAN := TRUE,
        P_ORIGINAL_LINE_BREAK   IN VARCHAR2 := '<br />',
        P_REPLACE_LINE_BREAK    IN VARCHAR2 := CHR(13)
        || CHR(10),
        P_APPEND_DATE           IN BOOLEAN := TRUE
    );

END APEXIR_XLSX_PKG;
/

