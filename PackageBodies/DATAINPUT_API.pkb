--
-- DATAINPUT_API  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.DATAINPUT_API IS

    FUNCTION BLOB_TO_CLOB (
        BLOB_IN IN BLOB
    ) RETURN CLOB AS

        V_CLOB      CLOB;
        V_VARCHAR   VARCHAR2(32767);
        V_START     PLS_INTEGER := 1;
        V_BUFFER    PLS_INTEGER := 32767;
    BEGIN
        DBMS_LOB.CREATETEMPORARY(V_CLOB,TRUE);
        FOR I IN 1..CEIL(DBMS_LOB.GETLENGTH(BLOB_IN) / V_BUFFER) LOOP
            V_VARCHAR := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(BLOB_IN,V_BUFFER,V_START) );

            DBMS_LOB.WRITEAPPEND(V_CLOB,LENGTH(V_VARCHAR),V_VARCHAR);
            V_START := V_START + V_BUFFER;
        END LOOP;

        RETURN V_CLOB;
    END BLOB_TO_CLOB;

    PROCEDURE FILE_UPLOAD (
        P_PEN_AGREEMENT   VARCHAR2,
        P_TRAN_ID         VARCHAR2,
        P_CLIENT_ID       VARCHAR2,
        P_PLAN_ID         VARCHAR2,
        P_EMPLOYER        VARCHAR2,
        P_PERIOD          DATE,
        P_APP_ID          NUMBER,
        P_SESSION_ID      NUMBER,
        P_CREATED_BY      VARCHAR2,
        P_LAYOUT          VARCHAR2,
        P_POSITION        VARCHAR2
    ) AS
      --datainput_api.file_upload ('2016JUN06150751', '0005', TO_DATE('01-JUN-2016','DD-MON-YYYY'), 112,4189511905658, 'ADMIN','D', 'COMMA', '1919') ;

        V_CLOB              CLOB;
        V_BLOB              BLOB;
        V_CLOB_LINE         VARCHAR2(4000);
        V_CLOB_LINE_COUNT   NUMBER;
        V_MEM_ID            VARCHAR2(15);
        V_HOURS             NUMBER;
        V_PENSION           NUMBER;
        V_FUNDS             NUMBER;
        V_OCCUPATION        VARCHAR2(15);
        V_LENGTH            NUMBER;
        V_MEM_FIRST_NAME    VARCHAR2(100);
        V_MEM_LAST_NAME     VARCHAR2(100);
        V_MEM_ID_START      INTEGER := REGEXP_SUBSTR(P_POSITION,'[^,]+',1,1);
        V_MEM_ID_END        INTEGER := REGEXP_SUBSTR(P_POSITION,'[^,]+',1,2);
        V_HOURS_START       INTEGER := REGEXP_SUBSTR(P_POSITION,'[^,]+',1,3);
        V_HOURS_END         INTEGER := REGEXP_SUBSTR(P_POSITION,'[^,]+',1,4);
    BEGIN
        BEGIN
            FOR C_BLOB IN (
                SELECT
                    BLOB_CONTENT
                FROM
                    WWV_FLOW_FILE_OBJECTS$
                WHERE
                    FLOW_ID = P_APP_ID
                    AND   SESSION_ID = P_SESSION_ID
                    AND   CREATED_BY = P_CREATED_BY
                ORDER BY
                    CREATED_ON DESC
            ) LOOP
                V_BLOB := C_BLOB.BLOB_CONTENT;
                EXIT;                                     --get latest upload file
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

        V_CLOB := BLOB_TO_CLOB(V_BLOB);
        V_CLOB_LINE_COUNT := LENGTH(V_CLOB) - NVL(LENGTH(REPLACE(V_CLOB,CHR(10) ) ),0) + 1;

        FOR I IN 1..V_CLOB_LINE_COUNT LOOP
            V_CLOB_LINE := REGEXP_SUBSTR(V_CLOB,'^.*$',1,I,'m');
            V_CLOB_LINE := REPLACE(V_CLOB_LINE,CHR(13) ); --CHR(13)Carriage return.
            V_CLOB_LINE := REPLACE(V_CLOB_LINE,CHR(10) );   --CHR(10) Line feed
            IF
                P_LAYOUT = 'COMMA'
            THEN                                    --delimited format with comma
                V_MEM_ID := REGEXP_SUBSTR(V_CLOB_LINE,'[^,]+',1,1);
                V_PENSION := REGEXP_SUBSTR(V_CLOB_LINE,'[^,]+',1,2);
            --v_funds := to_number(REGEXP_SUBSTR(v_clob_line, '[^,]+', 1, 4));
                V_OCCUPATION := REGEXP_SUBSTR(V_CLOB_LINE,'[^,]+',1,3);
                V_HOURS := TO_NUMBER(REGEXP_SUBSTR(V_CLOB_LINE,'[^,]+',1,4) );
                V_FUNDS := TO_NUMBER(REGEXP_SUBSTR(V_CLOB_LINE,'[^,]+',1,5) );
            ELSIF P_LAYOUT = 'TAB' THEN                                      --delimited format with tab
                V_MEM_ID := REGEXP_SUBSTR(V_CLOB_LINE,'[^'
                || CHR(9)
                || ']+',1,1);

                V_HOURS := TO_NUMBER(REGEXP_SUBSTR(V_CLOB_LINE,'[^'
                || CHR(9)
                || ']+',1,2) );

            ELSIF P_LAYOUT = 'FIX' THEN                                                     --fix length
                V_MEM_ID := SUBSTR(V_CLOB_LINE,V_MEM_ID_START,V_MEM_ID_END - V_MEM_ID_START + 1);
                V_HOURS := TO_NUMBER(TRIM(SUBSTR(V_CLOB_LINE,V_HOURS_START,V_HOURS_END - V_HOURS_START + 1) ) );

            END IF;

            BEGIN
                SELECT
                    MEM_FIRST_NAME,
                    MEM_LAST_NAME
                INTO
                    V_MEM_FIRST_NAME,V_MEM_LAST_NAME
                FROM
                    TBL_MEMBER
                WHERE
                    MEM_ID = V_MEM_ID
                    AND   ROWNUM < 2;

                IF
                    V_OCCUPATION IS NULL
                THEN                                --get occupation from database
                    V_OCCUPATION := GET_OCCUPATION_LATEST(P_CLIENT_ID,P_PLAN_ID,V_MEM_ID,SYSDATE);
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            INSERT INTO TRANSACTION_DETAIL_TEMP (
                TDT_TRAN_ID,
                TDT_PLAN_ID,
                TDT_EMPLOYER,
                TDT_PERIOD,
                TDT_UNITS,
                TDT_USER,
                TDT_DATE_TIME,
                TDT_MEM_ID,
                TDT_FIRST_NAME,
                TDT_LAST_NAME,
                TDT_PEN_UNITS,
                TDT_FUNDS_UNITS,
                TDT_CLIENT_ID,
                TDT_OCCU,
                TDT_AMOUNT
            ) VALUES (
                P_TRAN_ID,
                P_PLAN_ID,
                P_EMPLOYER,
                P_PERIOD,
                V_HOURS,
                P_CREATED_BY,
                SYSDATE,
                V_MEM_ID,
                V_MEM_FIRST_NAME,
                V_MEM_LAST_NAME,
                V_PENSION,
                V_FUNDS,
                P_CLIENT_ID,
                V_OCCUPATION,
                V_PENSION * PENSION_PKG.GET_CONT_RATE(P_CLIENT_ID,P_PLAN_ID,SYSDATE,P_PEN_AGREEMENT,P_EMPLOYER,V_MEM_ID,V_OCCUPATION,'PENSION','Y')
            );

        END LOOP;

        DELETE TRANSACTION_DETAIL_TEMP
        WHERE
            TDT_TRAN_ID = P_TRAN_ID
            AND   TDT_MEM_ID IS NULL
            AND   TDT_PLAN_ID = P_PLAN_ID
            AND   TDT_CLIENT_ID = P_CLIENT_ID;              --remove empty data

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END FILE_UPLOAD;

    FUNCTION VALIDATE_DEAIL_INPUT (
        P_TDT_EMPLOYER       VARCHAR2,
        P_TDT_PLAN_ID        VARCHAR2,
        P_TDT_UNITS          NUMBER,
        P_TDT_MEM_ID         VARCHAR2,
        P_MONTH              DATE,
        P_TRAN_ID            VARCHAR2,
        P_BEN_AGREEMENT_ID   VARCHAR2,
        P_PEN_AGREEMENT_ID   VARCHAR2,
        P_BEN_EARN           VARCHAR2,
        P_PEN_EARN           VARCHAR2
    ) RETURN VARCHAR2 AS

        V_COUNT                 INTEGER;
        V_DUPLICATE_COUNT       INTEGER;
        V_DEATIL_HOURS          NUMBER;
        V_DEATIL_PENSION        NUMBER;
        V_DEATIL_FUNDS          NUMBER;
        V_ERROR_MESSAGE         VARCHAR2(200);
        V_THT_UNITS             NUMBER;
        V_PEN_UNITS             NUMBER;
        V_FUND_UNITS            NUMBER;
        V_THT_AMOUNT            NUMBER;
        V_THT_RATE              NUMBER;
        V_MEM_DOB               DATE;
        V_SUBMIT_AMOUNT         NUMBER;
        V_DETAIL_BEN_AMOUNT     NUMBER;
        V_DETAIL_PEN_AMOUNT     NUMBER;
        V_DETAIL_FUND_AMOUNT    NUMBER;
        V_DETAIL_TOTAL_AMOUNT   NUMBER;
    BEGIN
        IF
            P_TDT_MEM_ID IS NOT NULL
        THEN
            SELECT
                COUNT(*)
            INTO
                V_DUPLICATE_COUNT
            FROM
                TRANSACTION_DETAIL_TEMP
            WHERE
                TDT_TRAN_ID = P_TRAN_ID
                AND   TDT_MEM_ID = P_TDT_MEM_ID;

            SELECT
                SUM(NVL(TDT_UNITS,0) ),
                SUM(NVL(TDT_PEN_UNITS,0) ),
                SUM(NVL(TDT_FUNDS_UNITS,0) ),
                SUM(NVL(TDT_PEN_UNITS,0) * PENSION_PKG.GET_CONT_RATE(TDT_CLIENT_ID,P_TDT_PLAN_ID,SYSDATE,P_PEN_AGREEMENT_ID,P_TDT_EMPLOYER,P_TDT_MEM_ID
,TDT_OCCU,'PENSION',NVL(P_PEN_EARN,'N') ) ),
                SUM(NVL(TDT_UNITS,0) * PENSION_PKG.GET_CONT_RATE(TDT_CLIENT_ID,P_TDT_PLAN_ID,SYSDATE,P_BEN_AGREEMENT_ID,P_TDT_EMPLOYER,P_TDT_MEM_ID
,TDT_OCCU,'HW',NVL(P_BEN_EARN,'N') ) )
            INTO
                V_DEATIL_HOURS,V_DEATIL_PENSION,V_DEATIL_FUNDS,V_DETAIL_PEN_AMOUNT,V_DETAIL_BEN_AMOUNT
            FROM
                TRANSACTION_DETAIL_TEMP
            WHERE
                TDT_TRAN_ID = P_TRAN_ID;

         --get total funds detail amount

            BEGIN
                SELECT
                    NVL(SUM(NVL(DTF_AMT,0) ),0)
                INTO
                    V_DETAIL_FUND_AMOUNT
                FROM
                    TRAN_DETAILS_TEMP_FUNDS_DET
                WHERE
                    DTF_TRAN_ID = P_TRAN_ID;

            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            V_DETAIL_TOTAL_AMOUNT := NVL(V_DETAIL_BEN_AMOUNT,0) + NVL(V_DETAIL_PEN_AMOUNT,0) + NVL(V_DETAIL_FUND_AMOUNT,0);

            BEGIN                                         --benefits or hour bank
                SELECT
                    THT_UNITS,
                    THT_RECD_AMT
                INTO
                    V_THT_UNITS,V_SUBMIT_AMOUNT
                FROM
                    TRANSACTION_HEADER_TEMP
                WHERE
                    THT_TRAN_ID = P_TRAN_ID;

            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            BEGIN                                                       --pension
                SELECT
                    THTP_UNITS
                INTO
                    V_PEN_UNITS
                FROM
                    TRAN_HEADER_TEMP_PEN
                WHERE
                    THTP_TRAN_ID = P_TRAN_ID;

            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            BEGIN
                SELECT
                    SUM(NVL(HTFD_UNITS,0) )
                INTO
                    V_FUND_UNITS
                FROM
                    TRAN_HEADDER_TEMP_FUNDS_DET
                WHERE
                    HTFD_TRAN_ID = P_TRAN_ID;

            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            SELECT
                COUNT(*)
            INTO
                V_COUNT
            FROM
                TBL_MEMBER
            WHERE
                MEM_ID = P_TDT_MEM_ID;

            IF
                V_COUNT = 0
            THEN
                V_ERROR_MESSAGE := ' NEW MEMBER, ';
            ELSE
                SELECT
                    MEM_DOB
                INTO
                    V_MEM_DOB
                FROM
                    TBL_MEMBER
                WHERE
                    MEM_ID = P_TDT_MEM_ID
                    AND   ROWNUM < 2;

            END IF;

         /****
         IF P_TDT_UNITS >= HR_BANK_PKG.GET_MAX_HRS(P_TDT_PLAN_ID,P_TDT_EMPLOYER,P_TDT_MEM_ID,P_MONTH) THEN
           V_ERROR_MESSAGE := V_ERROR_MESSAGE ||'HOURS CANNOT EXCEED 1500,';
         END IF;
         *****/
         /****
         IF P_TDT_UNITS = 0 THEN
           V_ERROR_MESSAGE := V_ERROR_MESSAGE ||'HOURS CANNOT BE 0,';
         END IF;
         ****/
         /****
         IF P_MONTH > SYSDATE OR P_MONTH <= ADD_MONTHS(SYSDATE,-36) THEN
           V_ERROR_MESSAGE := V_ERROR_MESSAGE ||'Month Error,';
         end if;
         ****/

            IF
                V_DUPLICATE_COUNT > 1
            THEN
                V_ERROR_MESSAGE := V_ERROR_MESSAGE
                || ' Duplicate Member, ';
            END IF;
            IF
                NVL(V_DEATIL_HOURS,0) <> NVL(V_THT_UNITS,0)
            THEN
                V_ERROR_MESSAGE := V_ERROR_MESSAGE
                || ' Variance of Benefit Units: '
                || TO_CHAR(V_THT_UNITS - V_DEATIL_HOURS)
                || ',';
            END IF;

            IF
                NVL(V_DEATIL_PENSION,0) <> NVL(V_PEN_UNITS,0)
            THEN
                V_ERROR_MESSAGE := V_ERROR_MESSAGE
                || ' Variance of Pension Units: '
                || TO_CHAR(V_PEN_UNITS - V_DEATIL_PENSION)
                || ',';
            END IF;

            IF
                NVL(V_DEATIL_FUNDS,0) <> NVL(V_FUND_UNITS,0)
            THEN
                V_ERROR_MESSAGE := V_ERROR_MESSAGE
                || ' Variance of Fund Units: '
                || TO_CHAR(V_FUND_UNITS - V_DEATIL_FUNDS)
                || ',';
            END IF;

            IF
                NVL(V_SUBMIT_AMOUNT,0) <> NVL(V_DETAIL_TOTAL_AMOUNT,0)
            THEN
                V_ERROR_MESSAGE := V_ERROR_MESSAGE
                || ' Variance Amount ( '
                || TO_CHAR(NVL(V_SUBMIT_AMOUNT,0) - NVL(V_DETAIL_TOTAL_AMOUNT,0),'$999,999.99')
                || '), ';
            END IF;

            IF
                ROUND(MONTHS_BETWEEN(SYSDATE,V_MEM_DOB) / 12,2) < 20 OR ROUND(MONTHS_BETWEEN(SYSDATE,V_MEM_DOB) / 12,2) >= 80
            THEN
                V_ERROR_MESSAGE := V_ERROR_MESSAGE
                || ' Error Age, ';
            END IF;

         /****
         IF P_TDT_EMPLOYER <> hr_bank_pkg.GET_EMPLOYER(P_TDT_PLAN_ID,P_TDT_MEM_ID,P_MONTH) THEN
           V_ERROR_MESSAGE := V_ERROR_MESSAGE ||'Original Employer='||hr_bank_pkg.GET_EMPLOYER(P_TDT_PLAN_ID,P_TDT_MEM_ID,P_MONTH)||',';
         END IF;
         ****/

            V_ERROR_MESSAGE := RTRIM(V_ERROR_MESSAGE,',');
        END IF;

        RETURN V_ERROR_MESSAGE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END VALIDATE_DEAIL_INPUT;

END DATAINPUT_API;
/

