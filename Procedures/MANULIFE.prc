--
-- MANULIFE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.MANULIFE (
    DT DATE,
    PL VARCHAR2
) IS

    CURSOR C IS SELECT DISTINCT
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
        CARRIER_TEMP A,
        TBL_MEMBER B,
        TBL_HW D
                WHERE
        A.CT_MEM_ID = B.MEM_ID
        AND   A.CT_MEM_ID = D.HW_ID
        AND   D.HW_PLAN = PL
        AND   A.CT_PLAN_ID = PL
    ORDER BY
        B.MEM_LAST_NAME,
        B.MEM_FIRST_NAME;

    REC              C%ROWTYPE;
    CURSOR DEP (
        SN NUMBER,
        EDATE DATE
    ) IS SELECT DISTINCT
        *
         FROM
        TBL_HW_BENEFICIARY
         WHERE
        HB_ID = SN
        AND   HB_PLAN = PL
        AND   (
            HB_TERM_DATE IS NULL
            OR    (
                HB_TERM_DATE IS NOT NULL
                AND   HB_LAST_MODIFIED_DATE IS NOT NULL
                AND   HB_LAST_MODIFIED_DATE >= (
                    SELECT
                        MAX(CARRIER_SENT_DATE)
                    FROM
                        CARRIER_HISTORY
                )
            )
        );
  
  
  
  
	

  -- for the dependents

  -- for the member's address

    RC_OUT           UTL_FILE.FILE_TYPE; -- Out file handle.	
    W_PARAFILE_OUT   VARCHAR2(400);
    W_CNT_T          NUMBER(9);
    W_CNT_E          NUMBER(9);
    W_CN_NO          NUMBER(10);
    CNO              NUMBER(10);
    W_ETOTAL         NUMBER(12,2);
    W_CN             NUMBER(1) := 0;
    W_TAILER         VARCHAR2(11);
    W_PROV           VARCHAR2(2);
    W_FAMILY         VARCHAR2(16);
    E_DATE           VARCHAR2(8);
    T_DATE           VARCHAR2(8);
    W_SEX            VARCHAR2(1);
    W_EFT_NUMBER     NUMBER(6);
    W_NET            NUMBER(9,2);
    W_DUMMY          VARCHAR2(1) := ' ';
    REF_DATE         DATE;
    W_EFF_DATE       DATE;
    DI               VARCHAR2(3);
    SX               VARCHAR2(1) := '1';
    DS               VARCHAR2(1);
BEGIN
    RC_OUT := UTL_FILE.FOPEN('TEXT_FILES','MANULIFE.TXT','W');
    W_CNT_T := 0;
    FOR REC IN C LOOP
        W_EFF_DATE := REC.HW_EFF_DATE;
	--if rec.division='A' THEN
        DI := '001';
  	--ELSIF REC.DIVISION='B' THEN
  	  -- DI:='002';
  	--ELSE
  	--	 DI:=NULL;
  	--END IF;
        SELECT
            DECODE(REC.MEM_GENDER,'F','2','1')
        INTO
            SX
        FROM
            DUAL;

        W_PARAFILE_OUT := '  M0056700UPDT'
        || RPAD(NVL(TO_CHAR(REC.MEM_DOB,'DDMMRRRR'),' '),8,' ')
        || RPAD(NVL(SUBSTR(REC.MEM_ID,1,9),' '),9,' ')
        || RPAD(NVL(SUBSTR(REC.MEM_ID,1,10),' '),10,' ')
        || RPAD(' ',9,' ')
        || RPAD(NVL(SUBSTR(REC.MEM_FIRST_NAME,1,30),' '),30,' ')
        || RPAD(' ',6,' ')
        || RPAD(NVL(SUBSTR(REC.MEM_LAST_NAME,1,30),' '),30,' ')
        || RPAD(NVL(TO_CHAR(REC.MEM_DOB,'RRRRMMDD'),' '),8,' ')
        || SX
        || RPAD(NVL(SUBSTR(REC.MEM_LANG_PREF,1,1),' '),1,' ')
        || ' '
        || DI
        || RPAD(' ',33,' ')
        || RPAD(NVL(TO_CHAR(REC.HW_EFF_DATE,'DDMMRRRR'),' '),8,' ')
        || RPAD(NVL(REC.MEM_PROV,'BC'),2,' ')
        || RPAD(' ',71,' ');

        UTL_FILE.PUT_LINE(RC_OUT,W_PARAFILE_OUT);
        W_CNT_T := 1;	
  	--FOR REC3 IN C3 LOOP
	
    ---------------------------Starting Line OF ADDRESS'S RECORD------------------
        W_PARAFILE_OUT := 'A0056700'
        || RPAD(' ',3,' ')
        || RPAD(NVL(TO_CHAR(SYSDATE,'RRRRMMDD'),' '),8,' ')
        || RPAD(NVL(SUBSTR(REC.MEM_ID,1,9),' '),9,' ')
        || RPAD(NVL(SUBSTR(REC.MEM_ID,1,10),' '),10,' ')
        || RPAD(' ',9,' ')
        || '2'
        || RPAD(NVL(SUBSTR(REC.MEM_ADDRESS1,1,30),' '),30,' ')
        || RPAD(' ',30,' ')
        || RPAD(NVL(SUBSTR(REC.MEM_CITY,1,30),' '),30,' ')
        || RPAD(NVL(SUBSTR(REC.MEM_PROV,1,2),' '),2,' ')
        || '1'
        || RPAD(NVL(SUBSTR(REC.MEM_POSTAL_CODE,1,6),' '),6,' ')
        || RPAD(' ',158,' ');

        W_CNT_T := W_CNT_T + 1;
        UTL_FILE.PUT_LINE(RC_OUT,W_PARAFILE_OUT);
	--END LOOP; 
        FOR REC2 IN DEP(REC.MEM_ID,REC.HW_EFF_DATE) LOOP
		
    ---------------------------Starting Line OF DEPENDENT'S RECORD------------------
            IF
                LTRIM(RTRIM(REC2.HB_RELATION) ) IS NULL
            THEN
                DS := '6';
            ELSIF REC2.HB_RELATION = 'S' THEN
                DS := '2';
            ELSIF REC2.HB_RELATION = 'C' THEN
                DS := '3';
            ELSE
                DS := '6';
            END IF;

            SELECT
                DECODE(REC2.HB_SEX,'F',2,1)
            INTO
                SX
            FROM
                DUAL;

            W_PARAFILE_OUT := 'PD0056700UPD'
            || RPAD(NVL(TO_CHAR(REC2.HB_EFF_DATE,'RRRRMMDD'),' '),8,' ')
            || RPAD(REC.MEM_ID,9,' ')
            || RPAD(REC.MEM_ID,10,' ')
            || RPAD(' ',9,' ')
            || RPAD(NVL(SUBSTR(REC2.HB_FIRST_NAME,1,30),' '),30,' ')
            || RPAD(' ',6,' ')
            || RPAD(NVL(SUBSTR(REC2.HB_LAST_NAME,1,18),' '),18,' ')
            || RPAD(NVL(TO_CHAR(REC2.HB_DOB,'RRRRMMDD'),' '),8,' ')
            || RPAD(NVL(SUBSTR(SX,1,1),' '),1,' ')
            || '1'
            || ' '
            || DS
            || '2'
            || '0'
            || RPAD(' ',27,' ');

            UTL_FILE.PUT_LINE(RC_OUT,W_PARAFILE_OUT);
        END LOOP;

    END LOOP;

    UTL_FILE.FCLOSE(RC_OUT);
    UPDATE CARRIER_HISTORY
        SET
            STATUS = 'S',
            CT_FILE = LOADBLOBFROMFILE('TEXT_FILES','MANULIFE.TXT'),
            CARRIER_SENT_DATE = SYSDATE,
            SENT_BY = 'TEST',
            CT_MIME_TYPE = 'text/plain',
            CT_FILE_NAME = 'MANULIFE.TXT'
    WHERE
        PLAN_ID = PL
        AND   UPPER(LTRIM(RTRIM(CARRIER_ID) ) ) = 'MANULIFE'
        AND   NVL(STATUS,'X') <> 'S';

    COMMIT;
END;
/

