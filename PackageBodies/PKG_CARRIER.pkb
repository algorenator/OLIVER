--
-- PKG_CARRIER  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.PKG_CARRIER AS

    FUNCTION CREATE_TRAN_ID RETURN VARCHAR2
        IS
    BEGIN
        FOR I IN (
            SELECT
                NVL(MAX(SUBSTR(TRANSACTION_ID,10) ),0) + 1 SEQ
            FROM
                CARRIER_HISTORY
            WHERE
                REGEXP_LIKE ( SUBSTR(TRANSACTION_ID,10),
                '^[[:digit:]]+$' )
        ) LOOP
            RETURN TO_CHAR(SYSDATE,'FMYYYYMONDD')
            || TO_CHAR(I.SEQ,'FM000000');
        END LOOP;
    END CREATE_TRAN_ID;

    PROCEDURE EXPORT_PAYMENT_DATA (
        P_PLAN_ID VARCHAR2,
        P_CARRIER_ID VARCHAR2
    ) IS

        L_FILE           BLOB;
        L_LINES          CLOB;
        L_DEST_OFFSET    PLS_INTEGER := 1;
        L_SRC_OFFSET     PLS_INTEGER := 1;
        L_LANG_CONTEXT   PLS_INTEGER := 0;
        L_WARNING        PLS_INTEGER := 0;
    BEGIN
        IF
            P_PLAN_ID IS NULL OR P_CARRIER_ID IS NULL
        THEN
            RETURN;
        END IF;
        FOR M IN (
            SELECT
                B.MEM_ID,
                B.MEM_FIRST_NAME,
                B.MEM_LAST_NAME,
                B.MEM_GENDER,
                B.MEM_DOB,
                B.MEM_ADDRESS1,
                B.MEM_ADDRESS2,
                B.MEM_CITY,
                B.MEM_PROV,
                B.MEM_POSTAL_CODE,
                B.MEM_LANG_PREF,
                D.HW_EFF_DATE,
                D.HW_TERM_DATE
            FROM
                TBL_HW D,
                TBL_MEMBER B,
                CARRIER_VIEW A
            WHERE
                A.MEM_PLAN = P_PLAN_ID
                AND   B.MEM_ID = A.MEM_ID
                AND   B.MEM_PLAN = A.MEM_PLAN
                AND   D.HW_ID = B.MEM_ID
                AND   D.HW_PLAN = B.MEM_PLAN
            GROUP BY
                B.MEM_ID,
                B.MEM_FIRST_NAME,
                B.MEM_LAST_NAME,
                B.MEM_GENDER,
                B.MEM_DOB,
                B.MEM_ADDRESS1,
                B.MEM_ADDRESS2,
                B.MEM_CITY,
                B.MEM_PROV,
                B.MEM_POSTAL_CODE,
                B.MEM_LANG_PREF,
                D.HW_EFF_DATE,
                D.HW_TERM_DATE
            ORDER BY
                B.MEM_LAST_NAME,
                B.MEM_FIRST_NAME
        ) LOOP
            L_LINES := L_LINES
            || '  M0056700UPDT'
            || RPAD(NVL(TO_CHAR(M.MEM_DOB,'DDMMRRRR'),' '),8,' ')
            || RPAD(NVL(SUBSTR(M.MEM_ID,1,9),' '),9,' ')
            || RPAD(NVL(SUBSTR(M.MEM_ID,1,10),' '),10,' ')
            || RPAD(' ',9,' ')
            || RPAD(NVL(SUBSTR(M.MEM_FIRST_NAME,1,30),' '),30,' ')
            || RPAD(' ',6,' ')
            || RPAD(NVL(SUBSTR(M.MEM_LAST_NAME,1,30),' '),30,' ')
            || RPAD(NVL(TO_CHAR(M.MEM_DOB,'RRRRMMDD'),' '),8,' ')
            ||
                CASE M.MEM_GENDER
                    WHEN 'F' THEN '2'
                    ELSE '1'
                END
            || RPAD(NVL(SUBSTR(M.MEM_LANG_PREF,1,1),' '),1,' ')
            || ' '
            || '001'
            || RPAD(' ',33,' ')
            || RPAD(NVL(TO_CHAR(M.HW_EFF_DATE,'DDMMRRRR'),' '),8,' ')
            || RPAD(NVL(M.MEM_PROV,'BC'),2,' ')
            || RPAD(' ',71,' ')
            || CHR(13);

            L_LINES := L_LINES
            || 'A0056700'
            || RPAD(' ',3,' ')
            || RPAD(NVL(TO_CHAR(SYSDATE,'RRRRMMDD'),' '),8,' ')
            || RPAD(NVL(SUBSTR(M.MEM_ID,1,9),' '),9,' ')
            || RPAD(NVL(SUBSTR(M.MEM_ID,1,10),' '),10,' ')
            || RPAD(' ',9,' ')
            || '2'
            || RPAD(NVL(SUBSTR(M.MEM_ADDRESS1,1,30),' '),30,' ')
            || RPAD(' ',30,' ')
            || RPAD(NVL(SUBSTR(M.MEM_CITY,1,30),' '),30,' ')
            || RPAD(NVL(SUBSTR(M.MEM_PROV,1,2),' '),2,' ')
            || '1'
            || RPAD(NVL(SUBSTR(M.MEM_POSTAL_CODE,1,6),' '),6,' ')
            || RPAD(' ',158,' ')
            || CHR(13);

            FOR B IN (
                WITH H AS (
                    SELECT
                        MAX(CARRIER_SENT_DATE) LAST_DATE
                    FROM
                        CARRIER_HISTORY
                    WHERE
                        CARRIER_ID = P_CARRIER_ID
                ) SELECT
                    HB_EFF_DATE,
                    HB_FIRST_NAME,
                    HB_LAST_NAME,
                    HB_DOB,
                    HB_SEX,
                    HB_RELATION
                  FROM
                    H,
                    TBL_HW_BENEFICIARY
                  WHERE
                    HB_ID = M.MEM_ID
                    AND   HB_PLAN = P_PLAN_ID
                    AND   (
                        HB_TERM_DATE IS NULL
                        OR    (
                            HB_TERM_DATE IS NOT NULL
                            AND   HB_LAST_MODIFIED_DATE IS NOT NULL
                            AND   HB_LAST_MODIFIED_DATE >= H.LAST_DATE
                        )
                    )
                  GROUP BY
                    HB_EFF_DATE,
                    HB_FIRST_NAME,
                    HB_LAST_NAME,
                    HB_DOB,
                    HB_SEX,
                    HB_RELATION
            ) LOOP
                L_LINES := L_LINES
                || 'PD0056700UPD'
                || RPAD(NVL(TO_CHAR(B.HB_EFF_DATE,'RRRRMMDD'),' '),8,' ')
                || RPAD(M.MEM_ID,9,' ')
                || RPAD(M.MEM_ID,10,' ')
                || RPAD(' ',9,' ')
                || RPAD(NVL(SUBSTR(B.HB_FIRST_NAME,1,30),' '),30,' ')
                || RPAD(' ',6,' ')
                || RPAD(NVL(SUBSTR(B.HB_LAST_NAME,1,18),' '),18,' ')
                || RPAD(NVL(TO_CHAR(B.HB_DOB,'RRRRMMDD'),' '),8,' ')
                || RPAD(NVL(SUBSTR(
                    CASE
                        WHEN B.HB_SEX = 'F' THEN 2
                        ELSE 1
                    END,1,1),' '),1,' ')
                || '1'
                || ' '
                ||
                    CASE TRIM(B.HB_RELATION)
                        WHEN 'S' THEN '2'
                        WHEN 'C' THEN '3'
                        ELSE '6'
                    END
                || '2'
                || '0'
                || RPAD(' ',27,' ')
                || CHR(13);
            END LOOP;

        END LOOP;

        IF
            L_LINES IS NULL
        THEN
            RAISE_APPLICATION_ERROR(-20000,'no available data to generate the file.');
        END IF;
        DBMS_LOB.CREATETEMPORARY(L_FILE,TRUE,DBMS_LOB.CALL);
        DBMS_LOB.CONVERTTOBLOB(L_FILE,L_LINES,LENGTH(L_LINES),L_DEST_OFFSET,L_SRC_OFFSET,0,L_LANG_CONTEXT,L_WARNING);

        INSERT INTO CARRIER_HISTORY (
            PLAN_ID,
            CARRIER_ID,
            CARRIER_SENT_DATE,
            SENT_BY,
            TRANSACTION_ID,
            STATUS,
            CT_FILE_NAME,
            CT_MIME_TYPE,
            CT_FILE
        ) VALUES (
            P_PLAN_ID,
            P_CARRIER_ID,
            SYSDATE,
            NVL(V('APP_USER'),USER),
            CREATE_TRAN_ID,
            'S',
            P_CARRIER_ID
            || '.txt',
            'text/plain',
            L_FILE
        );

        DBMS_LOB.FREETEMPORARY(L_FILE);
    END EXPORT_PAYMENT_DATA;

END PKG_CARRIER;
/

