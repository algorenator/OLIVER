--
-- XML_TO_XSLX  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER."XML_TO_XSLX" AUTHID CURRENT_USER IS
    WIDTH_COEFFICIENT CONSTANT NUMBER := 6;
    PROCEDURE DOWNLOAD_FILE (
        P_APP_ID       IN NUMBER,
        P_PAGE_ID      IN NUMBER,
        P_REGION_ID    IN NUMBER,
        P_COL_LENGTH   IN VARCHAR2 DEFAULT NULL,
        P_MAX_ROWS     IN NUMBER
    );

    FUNCTION CONVERT_DATE_FORMAT (
        P_FORMAT IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION CONVERT_NUMBER_FORMAT (
        P_FORMAT IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GET_MAX_ROWS (
        P_APP_ID      IN NUMBER,
        P_PAGE_ID     IN NUMBER,
        P_REGION_ID   IN NUMBER
    ) RETURN NUMBER;
  /*
  -- format test cases
  select xml_to_xslx.convert_date_format('dd.mm.yyyy hh24:mi:ss'),to_char(sysdate,'dd.mm.yyyy hh24:mi:ss') from dual
  union
  select xml_to_xslx.convert_date_format('dd.mm.yyyy hh12:mi:ss'),to_char(sysdate,'dd.mm.yyyy hh12:mi:ss') from dual
  union
  select xml_to_xslx.convert_date_format('day-mon-yyyy'),to_char(sysdate,'day-mon-yyyy') from dual
  union
  select xml_to_xslx.convert_date_format('month'),to_char(sysdate,'month') from dual
  union
  select xml_to_xslx.convert_date_format('RR-MON-DD'),to_char(sysdate,'RR-MON-DD') from dual 
  union
  select xml_to_xslx.convert_number_format('FML999G999G999G999G990D0099'),to_char(123456789/451,'FML999G999G999G999G990D0099') from dual
  union
  select xml_to_xslx.convert_date_format('DD-MON-YYYY HH:MIPM'),to_char(sysdate,'DD-MON-YYYY HH:MIPM') from dual 
  union
  select xml_to_xslx.convert_date_format('fmDay, fmDD fmMonth, YYYY'),to_char(sysdate,'fmDay, fmDD fmMonth, YYYY') from dual 
  */

END;
/

