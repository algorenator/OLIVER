--
-- MERGE_MEMBER1  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.MERGE_MEMBER1 (
    NEW_MEM_ID   IN NUMBER,
    OLD_MEM_ID   IN NUMBER,
    PLAN_ID      IN VARCHAR2 DEFAULT 'BCGEU',
    CLIENT_ID    IN VARCHAR2 DEFAULT 'DT',
    PLAN_TYPE    IN VARCHAR2 DEFAULT NULL
) IS

    CURSOR C1 IS SELECT
        *
                 FROM
        TBL_MEMBER
                 WHERE
        MEM_ID = NEW_MEM_ID
        AND   UPPER(MEM_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(MEM_CLIENT_ID) = UPPER(CLIENT_ID);

    CURSOR C2 IS SELECT
        *
                 FROM
        TBL_MEMBER
                 WHERE
        MEM_ID = OLD_MEM_ID
        AND   UPPER(MEM_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(MEM_CLIENT_ID) = UPPER(CLIENT_ID);

    CURSOR P1 IS SELECT
        *
                 FROM
        TBL_PENMAST
                 WHERE
        PENM_ID = NEW_MEM_ID
        AND   UPPER(PENM_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(PENM_CLIENT) = UPPER(CLIENT_ID);

    CURSOR P2 IS SELECT
        *
                 FROM
        TBL_PENMAST
                 WHERE
        PENM_ID = OLD_MEM_ID
        AND   UPPER(PENM_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(PENM_CLIENT) = UPPER(CLIENT_ID);

    CURSOR B1 IS SELECT
        *
                 FROM
        TBL_PEN_BENEFICIARY
                 WHERE
        PB_ID = NEW_MEM_ID
        AND   UPPER(PB_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(PB_CLIENT) = UPPER(CLIENT_ID);

    CURSOR B2 IS SELECT
        *
                 FROM
        TBL_PEN_BENEFICIARY
                 WHERE
        PB_ID = OLD_MEM_ID
        AND   UPPER(PB_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(PB_CLIENT) = UPPER(CLIENT_ID);

    CURSOR PS1 IS SELECT
        *
                  FROM
        TBL_PEN_EXIT_STAT_TRANS
                  WHERE
        PEST_MEM_ID = NEW_MEM_ID
        AND   UPPER(PEST_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(PEST_CLIENT) = UPPER(CLIENT_ID);

    CURSOR PS2 IS SELECT
        *
                  FROM
        TBL_PEN_EXIT_STAT_TRANS
                  WHERE
        PEST_MEM_ID = OLD_MEM_ID
        AND   UPPER(PEST_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(PEST_CLIENT) = UPPER(CLIENT_ID);

    CURSOR PW1 IS SELECT
        *
                  FROM
        TBL_PENWD
                  WHERE
        PW_MEM_ID = NEW_MEM_ID
        AND   UPPER(PW_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(PW_CLIENT) = UPPER(CLIENT_ID);

    CURSOR PW2 IS SELECT
        *
                  FROM
        TBL_PENWD
                  WHERE
        PW_MEM_ID = OLD_MEM_ID
        AND   UPPER(PW_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(PW_CLIENT) = UPPER(CLIENT_ID);

    CURSOR PU1 IS SELECT
        *
                  FROM
        TBL_PAST_UNITS
                  WHERE
        TPU_ID = NEW_MEM_ID
        AND   UPPER(TPU_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(TPU_CLIENT) = UPPER(CLIENT_ID);

    CURSOR PU2 IS SELECT
        *
                  FROM
        TBL_PAST_UNITS
                  WHERE
        TPU_ID = OLD_MEM_ID
        AND   UPPER(TPU_PLAN) = UPPER(PLAN_ID)
        AND   UPPER(TPU_CLIENT) = UPPER(TPU_CLIENT);

    NEWREC   C1%ROWTYPE;
    OLDREC   C2%ROWTYPE;
    PNEW     P1%ROWTYPE;
    POLD     P2%ROWTYPE;
    B_NEW    B1%ROWTYPE;
    B_OLD    B2%ROWTYPE;
    PSN      PS1%ROWTYPE;
    PSO      PS2%ROWTYPE;
    PW_NEW   PW1%ROWTYPE;
    PW_OLD   PW2%ROWTYPE;
    PUNEW    PU1%ROWTYPE;
    PUOLD    PU2%ROWTYPE;
    CNT1     NUMBER := 0;
    CNT2     NUMBER := 0;
BEGIN
    IF
        NEW_MEM_ID IS NULL OR OLD_MEM_ID IS NULL
    THEN
        RAISE_APPLICATION_ERROR(-20000,'Input Parameters NEW_MEM_ID or OLD_MEM_ID can not be NULL');
    END IF;

    IF
        NEW_MEM_ID = OLD_MEM_ID
    THEN
        RAISE_APPLICATION_ERROR(-20002,'NEW_MEM_ID and OLD_MEM_ID should not be same');
    END IF;
    OPEN C1;
    OPEN C2;
    FETCH C1 INTO NEWREC;
    FETCH C2 INTO OLDREC;
    IF
        C2%NOTFOUND
    THEN
        GOTO TBL_PENMAST;
    END IF;
    SELECT
        COUNT(*)
    INTO
        CNT1
    FROM
        TBL_MEMBER
    WHERE
        MEM_ID = NEW_MEM_ID
        AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );

    SELECT
        COUNT(*)
    INTO
        CNT2
    FROM
        TBL_MEMBER
    WHERE
        MEM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );

--i--If OLD ID does not exist or (OLD_ID and NEW_ID values are same)  then do not update any data

    IF
        CNT2 <= 0
    THEN
        RAISE_APPLICATION_ERROR(-20001,'Entered OLD_MEM_ID Does not exist');

--ii-IF Old ID exist and New ID does not ,Update OLD ID value with with New ID value.
    ELSIF CNT2 > 0 AND CNT1 <= 0 THEN
        UPDATE TBL_MEMBER
            SET
                MEM_ID = NEW_MEM_ID
        WHERE
            MEM_ID = OLDREC.MEM_ID
            AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(OLDREC.MEM_PLAN) )
            AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(OLDREC.MEM_CLIENT_ID) );

    ELSIF
--iii-If Old and New ID values exist , Update NEW ID fields with OLD ID fields when NEW ID fields are BLANK and OLD ID fields are NOT BLANK

     CNT2 > 0 AND CNT1 > 0 THEN
        UPDATE TBL_MEMBER
            SET
                MEM_SIN = NVL(NEWREC.MEM_SIN,OLDREC.MEM_SIN),
                MEM_FIRST_NAME = NVL(NEWREC.MEM_FIRST_NAME,OLDREC.MEM_FIRST_NAME),
                MEM_MIDDLE_NAME = NVL(NEWREC.MEM_MIDDLE_NAME,OLDREC.MEM_MIDDLE_NAME),
                MEM_LAST_NAME = NVL(NEWREC.MEM_LAST_NAME,OLDREC.MEM_LAST_NAME),
                MEM_GENDER = NVL(NEWREC.MEM_GENDER,NEWREC.MEM_GENDER),
                MEM_DOB = LEAST(NVL(NEWREC.MEM_DOB,OLDREC.MEM_DOB),OLDREC.MEM_DOB),
                MEM_ADDRESS1 = NVL(NEWREC.MEM_ADDRESS1,OLDREC.MEM_ADDRESS1),
                MEM_ADDRESS2 = NVL(NEWREC.MEM_ADDRESS2,OLDREC.MEM_ADDRESS2),
                MEM_CITY = NVL(NEWREC.MEM_CITY,OLDREC.MEM_CITY),
                MEM_PROV = NVL(NEWREC.MEM_PROV,OLDREC.MEM_PROV),
                MEM_COUNTRY = NVL(NEWREC.MEM_COUNTRY,OLDREC.MEM_COUNTRY),
                MEM_POSTAL_CODE = NVL(NEWREC.MEM_POSTAL_CODE,OLDREC.MEM_POSTAL_CODE),
                MEM_EMAIL = NVL(NEWREC.MEM_EMAIL,OLDREC.MEM_EMAIL),
                MEM_HOME_PHONE = NVL(NEWREC.MEM_HOME_PHONE,OLDREC.MEM_HOME_PHONE),
                MEM_WORK_PHONE = NVL(NEWREC.MEM_WORK_PHONE,OLDREC.MEM_WORK_PHONE),
                MEM_CELL_PHONE = NVL(NEWREC.MEM_CELL_PHONE,OLDREC.MEM_CELL_PHONE),
                MEM_FAX = NVL(NEWREC.MEM_FAX,OLDREC.MEM_FAX),
                MEM_LANG_PREF = NVL(NEWREC.MEM_LANG_PREF,OLDREC.MEM_LANG_PREF),
                MEM_ATTACHMENT = NVL(NEWREC.MEM_ATTACHMENT,OLDREC.MEM_ATTACHMENT),
                MEM_FILE_NAME = NVL(NEWREC.MEM_FILE_NAME,OLDREC.MEM_FILE_NAME),
                MEM_MIME_TYPE = NVL(NEWREC.MEM_MIME_TYPE,OLDREC.MEM_MIME_TYPE),
                MEM_DOD = GREATEST(NVL(NEWREC.MEM_DOD,OLDREC.MEM_DOD),OLDREC.MEM_DOD),
                MEM_TITLE = NVL(NEWREC.MEM_TITLE,OLDREC.MEM_TITLE),
                MEM_LAST_MODIFIED_BY = 'SYSTEM',
                MEM_LAST_MODIFIED_DATE = SYSDATE
        WHERE
            MEM_ID = NEW_MEM_ID
            AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(NEWREC.MEM_PLAN) )
            AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(NEWREC.MEM_CLIENT_ID) );

    END IF;

    DELETE FROM TBL_MEMBER
    WHERE
        MEM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(OLDREC.MEM_PLAN) )
        AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(OLDREC.MEM_CLIENT_ID) );

    CLOSE C1;
    CLOSE C2;
    << TBL_PENMAST >> OPEN P1;
    OPEN P2;
    FETCH P1 INTO PNEW;
    FETCH P2 INTO POLD;
    IF
        P2%NOTFOUND
    THEN
        GOTO TBL_PEN_BENEFICIARY;
    END IF;
    SELECT
        COUNT(*)
    INTO
        CNT1
    FROM
        TBL_PENMAST
    WHERE
        PENM_ID = NEW_MEM_ID
        AND   TRIM(UPPER(PENM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PENM_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    SELECT
        COUNT(*)
    INTO
        CNT2
    FROM
        TBL_PENMAST
    WHERE
        PENM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(PENM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PENM_CLIENT) = TRIM(UPPER(CLIENT_ID) );

--i--If OLD ID does not exist or (OLD_ID and NEW_ID values are same)  then do not update any data

    IF
        CNT2 <= 0
    THEN
        RAISE_APPLICATION_ERROR(-20001,'Entered OLD_MEM_ID Does not exist');

--ii-IF Old ID exist and New ID does not ,Update OLD ID value with with New ID value.
    ELSIF CNT2 > 0 AND CNT1 <= 0 THEN
        UPDATE TBL_PENMAST
            SET
                PENM_ID = NEW_MEM_ID
        WHERE
            PENM_ID = POLD.PENM_ID
            AND   TRIM(PENM_PLAN) = TRIM(UPPER(POLD.PENM_PLAN) )
            AND   TRIM(PENM_CLIENT) = TRIM(UPPER(POLD.PENM_CLIENT) );

    ELSIF
--iii-If Old and New ID values exist , Update NEW ID fields with OLD ID fields when NEW ID fields are BLANK and OLD ID fields are NOT BLANK

     CNT2 > 0 AND CNT1 > 0 THEN
        UPDATE TBL_PENMAST
            SET
                PENM_ENTRY_DATE = LEAST(NVL(PNEW.PENM_ENTRY_DATE,POLD.PENM_ENTRY_DATE),POLD.PENM_ENTRY_DATE),
                PENM_HIRE_DATE = LEAST(NVL(PNEW.PENM_HIRE_DATE,POLD.PENM_HIRE_DATE),POLD.PENM_HIRE_DATE),
                PENM_STATUS = NVL(PNEW.PENM_STATUS,POLD.PENM_STATUS),
                PENM_STATUS_DATE = GREATEST(NVL(PNEW.PENM_STATUS_DATE,POLD.PENM_STATUS_DATE),POLD.PENM_STATUS_DATE),
                PENM_RECIPROCAL = NVL(PNEW.PENM_RECIPROCAL,POLD.PENM_RECIPROCAL),
                PENM_LOCAL = NVL(PNEW.PENM_LOCAL,POLD.PENM_LOCAL),
                PENM_EMPLOYER = NVL(PNEW.PENM_EMPLOYER,POLD.PENM_EMPLOYER),
                PENM_PAST_SERV = NVL(PNEW.PENM_PAST_SERV,0) + NVL(POLD.PENM_PAST_SERV,0),
                PENM_PAST_PENSION = NVL(PNEW.PENM_PAST_PENSION,0) + NVL(POLD.PENM_PAST_PENSION,0),
                PENM_CURR_SERV = NVL(PNEW.PENM_CURR_SERV,0) + NVL(POLD.PENM_CURR_SERV,0),
                PENM_CURR_PENSION = NVL(PNEW.PENM_CURR_PENSION,0) + NVL(POLD.PENM_CURR_PENSION,0),
                PENM_MARITAL_STATUS = NVL(PNEW.PENM_MARITAL_STATUS,POLD.PENM_MARITAL_STATUS),
                PENM_LRD = GREATEST(NVL(PNEW.PENM_LRD,POLD.PENM_LRD),POLD.PENM_LRD),
                PENM_VP_PENSION = NVL(PNEW.PENM_VP_PENSION,0) + NVL(POLD.PENM_VP_PENSION,0),
                PENM_PROCESS_DATE = GREATEST(NVL(PNEW.PENM_PROCESS_DATE,POLD.PENM_PROCESS_DATE),POLD.PENM_PROCESS_DATE),
                PENM_VETSED_DATE = GREATEST(NVL(PNEW.PENM_VETSED_DATE,POLD.PENM_VETSED_DATE),POLD.PENM_VETSED_DATE),
                PENM_PAST_PENSION_LI = NVL(PNEW.PENM_PAST_PENSION_LI,0) + NVL(POLD.PENM_PAST_PENSION_LI,0),
                PENM_LAST_MODIFIED_DATE = SYSDATE,
                PENM_LAST_MODIFIED_BY = 'SYSTEM'
        WHERE
            PENM_ID = NEW_MEM_ID
            AND   TRIM(PENM_PLAN) = TRIM(UPPER(PNEW.PENM_PLAN) )
            AND   TRIM(PENM_CLIENT) = TRIM(UPPER(PNEW.PENM_CLIENT) );

    END IF;

    DELETE FROM TBL_PENMAST
    WHERE
        PENM_ID = OLD_MEM_ID
        AND   TRIM(PENM_PLAN) = TRIM(UPPER(POLD.PENM_PLAN) )
        AND   TRIM(PENM_CLIENT) = TRIM(UPPER(POLD.PENM_CLIENT) );

    CLOSE P1;
    CLOSE P2;
    << TBL_PEN_BENEFICIARY >> OPEN B1;
    OPEN B2;
    FETCH B1 INTO B_NEW;
    FETCH B2 INTO B_OLD;
    IF
        B2%NOTFOUND
    THEN
        GOTO TBL_PEN_EXIT_STAT_TRANS;
    END IF;
    SELECT
        COUNT(*)
    INTO
        CNT1
    FROM
        TBL_PEN_BENEFICIARY
    WHERE
        PB_ID = NEW_MEM_ID
        AND   TRIM(UPPER(PB_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PB_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    SELECT
        COUNT(*)
    INTO
        CNT2
    FROM
        TBL_PEN_BENEFICIARY
    WHERE
        PB_ID = OLD_MEM_ID
        AND   TRIM(UPPER(PB_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PB_CLIENT) = TRIM(UPPER(CLIENT_ID) );
--i--If OLD ID does not exist or (OLD_ID and NEW_ID values are same)  then do not update any data

    IF
        CNT2 <= 0
    THEN
        RAISE_APPLICATION_ERROR(-20001,'Entered OLD_MEM_ID Does not exist');

--ii-IF Old ID exist and New ID does not ,Update OLD ID value with with New ID value.
    ELSIF CNT2 > 0 AND CNT1 <= 0 THEN
        UPDATE TBL_PEN_BENEFICIARY
            SET
                PB_ID = NEW_MEM_ID
        WHERE
            PB_ID = B_OLD.PB_ID
            AND   TRIM(PB_PLAN) = TRIM(UPPER(B_OLD.PB_PLAN) )
            AND   TRIM(PB_CLIENT) = TRIM(UPPER(B_OLD.PB_CLIENT) );

    ELSIF
--iii-If Old and New ID values exist , Update NEW ID fields with OLD ID fields when NEW ID fields are BLANK and OLD ID fields are NOT BLANK

     CNT2 > 0 AND CNT1 > 0 THEN
        UPDATE TBL_PEN_BENEFICIARY
            SET
                PB_BEN_NO = NVL(B_NEW.PB_BEN_NO,B_OLD.PB_BEN_NO),
                PB_LAST_NAME = NVL(B_NEW.PB_LAST_NAME,B_OLD.PB_LAST_NAME),
                PB_FIRST_NAME = NVL(B_NEW.PB_FIRST_NAME,B_OLD.PB_FIRST_NAME),
                PB_DOB = LEAST(NVL(B_NEW.PB_DOB,B_OLD.PB_DOB),B_OLD.PB_DOB),
                PB_RELATION = NVL(B_NEW.PB_RELATION,B_OLD.PB_RELATION),
                PB_BE_PER = NVL(B_NEW.PB_BE_PER,B_OLD.PB_BE_PER),             -----------Review
                PB_EFF_DATE = LEAST(NVL(B_NEW.PB_EFF_DATE,B_OLD.PB_EFF_DATE),B_OLD.PB_EFF_DATE),          --Review
                PB_TERM_DATE = LEAST(NVL(B_NEW.PB_TERM_DATE,B_OLD.PB_TERM_DATE),B_OLD.PB_TERM_DATE),------Review
                PB_SEX = NVL(B_NEW.PB_SEX,B_OLD.PB_SEX),
                PB_LAST_MODIFIED_BY = 'SYSTEM',
                PB_LAST_MODIFIED_DATE = 'KEY',
                PB_BENEFIT = NVL(B_NEW.PB_BENEFIT,B_OLD.PB_BENEFIT),
                PB_MPE = NVL(B_NEW.PB_MPE,0) + NVL(B_OLD.PB_MPE,0),
                PB_WITHDRAW = NVL(B_NEW.PB_WITHDRAW,0) + NVL(B_OLD.PB_WITHDRAW,0),
                PB_WITHDRAW_DATE = GREATEST(NVL(B_NEW.PB_WITHDRAW_DATE,B_OLD.PB_WITHDRAW_DATE),B_OLD.PB_WITHDRAW_DATE),
                PB_ADDRESS1 = NVL(B_NEW.PB_ADDRESS1,B_OLD.PB_ADDRESS1),
                PB_ADDESS2 = NVL(B_NEW.PB_ADDESS2,B_OLD.PB_ADDESS2),
                PB_CITY = NVL(B_NEW.PB_CITY,B_OLD.PB_CITY),
                PB_PROV = NVL(B_NEW.PB_PROV,B_OLD.PB_PROV),
                PB_COUNTRY = NVL(B_NEW.PB_COUNTRY,B_OLD.PB_COUNTRY),
                PB_BEN_ID = NVL(B_NEW.PB_BEN_ID,B_OLD.PB_BEN_ID),
                PB_BEN_SIN = NVL(B_NEW.PB_BEN_SIN,B_OLD.PB_BEN_SIN),
                PB_MIDDLE_NAME = NVL(B_NEW.PB_MIDDLE_NAME,B_OLD.PB_MIDDLE_NAME),
                PB_POSTAL_CODE = NVL(B_NEW.PB_POSTAL_CODE,B_OLD.PB_POSTAL_CODE)
        WHERE
            PB_ID = NEW_MEM_ID
            AND   TRIM(UPPER(PB_PLAN) ) = TRIM(UPPER(B_NEW.PB_PLAN) )
            AND   TRIM(UPPER(PB_CLIENT) ) = TRIM(UPPER(B_NEW.PB_CLIENT) );

    END IF;

    DELETE FROM TBL_PEN_BENEFICIARY
    WHERE
        PB_ID = OLD_MEM_ID
        AND   TRIM(PB_PLAN) = TRIM(UPPER(B_OLD.PB_PLAN) )
        AND   TRIM(PB_CLIENT) = TRIM(UPPER(B_OLD.PB_CLIENT) );

    CLOSE B1;
    CLOSE B2;
    << TBL_PEN_EXIT_STAT_TRANS >> OPEN PS1;
    OPEN PS2;
    FETCH PS1 INTO PSN;
    FETCH PS2 INTO PSO;
    IF
        PS2%NOTFOUND
    THEN
        GOTO TBL_PENWD;
 --RAISE_APPLICATION_ERROR(-20003,'NO DATA FOUND FOR ENTERED OLD_MEM_ID VALUES');
    END IF;
    SELECT
        COUNT(*)
    INTO
        CNT1
    FROM
        TBL_PEN_EXIT_STAT_TRANS
    WHERE
        PEST_MEM_ID = NEW_MEM_ID
        AND   TRIM(UPPER(PEST_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PEST_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    SELECT
        COUNT(*)
    INTO
        CNT2
    FROM
        TBL_PEN_EXIT_STAT_TRANS
    WHERE
        PEST_MEM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(PEST_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PEST_CLIENT) = TRIM(UPPER(CLIENT_ID) );
--i--If OLD ID does not exist or (OLD_ID and NEW_ID values are same)  then do not update any data

    IF
        CNT2 <= 0
    THEN
        RAISE_APPLICATION_ERROR(-20001,'Entered OLD_MEM_ID Does not exist');

--ii-IF Old ID exist and New ID does not ,Update OLD ID value with with New ID value.
    ELSIF CNT2 > 0 AND CNT1 <= 0 THEN
        UPDATE TBL_PEN_EXIT_STAT_TRANS
            SET
                PEST_MEM_ID = NEW_MEM_ID
        WHERE
            PEST_MEM_ID = PSO.PEST_MEM_ID
            AND   TRIM(PEST_PLAN) = TRIM(UPPER(PSO.PEST_PLAN) )
            AND   TRIM(PEST_CLIENT) = TRIM(UPPER(PSO.PEST_CLIENT) );

    ELSIF

  --iii-If Old and New ID values exist , Update NEW ID fields with OLD ID fields when NEW ID fields are BLANK and OLD ID fields are NOT BLANK

     CNT2 > 0 AND CNT1 > 0 THEN
        UPDATE TBL_PEN_EXIT_STAT_TRANS
            SET
                PEST_STATUS = NVL(PSN.PEST_STATUS,PSO.PEST_STATUS),
                PEST_TYPE = NVL(PSN.PEST_TYPE,PSO.PEST_TYPE)
        WHERE
            PEST_MEM_ID = NEW_MEM_ID
            AND   TRIM(PEST_PLAN) = TRIM(UPPER(PSN.PEST_PLAN) )
            AND   TRIM(PEST_CLIENT) = TRIM(UPPER(PSN.PEST_CLIENT) );

    END IF;

    DELETE FROM TBL_PEN_EXIT_STAT_TRANS
    WHERE
        PEST_MEM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(PEST_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PEST_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    CLOSE PS1;
    CLOSE PS2;
    << TBL_PENWD >> OPEN PW1;
    OPEN PW2;
    FETCH PW1 INTO PW_NEW;
    FETCH PW2 INTO PW_OLD;
    IF
        PW2%NOTFOUND
    THEN
        GOTO TBL_PAST_UNITS;
    END IF;
    SELECT
        COUNT(*)
    INTO
        CNT1
    FROM
        TBL_PENWD
    WHERE
        PW_MEM_ID = NEW_MEM_ID
        AND   TRIM(UPPER(PW_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PW_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    SELECT
        COUNT(*)
    INTO
        CNT2
    FROM
        TBL_PENWD
    WHERE
        PW_MEM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(PW_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PW_CLIENT) = TRIM(UPPER(CLIENT_ID) );
--i--If OLD ID does not exist or (OLD_ID and NEW_ID values are same)  then do not update any data

    IF
        CNT2 <= 0
    THEN
        RAISE_APPLICATION_ERROR(-20001,'Entered OLD_MEM_ID Does not exist');

--ii-IF Old ID exist and New ID does not ,Update OLD ID value with with New ID value.
    ELSIF CNT2 > 0 AND CNT1 <= 0 THEN
        UPDATE TBL_PENWD
            SET
                PW_MEM_ID = NEW_MEM_ID
        WHERE
            PW_MEM_ID = PW_OLD.PW_MEM_ID
            AND   TRIM(PW_PLAN) = TRIM(UPPER(PW_OLD.PW_PLAN) )
            AND   TRIM(PW_CLIENT) = TRIM(UPPER(PW_OLD.PW_CLIENT) );

    ELSIF
 
  --iii-If Old and New ID values exist , Update NEW ID fields with OLD ID fields when NEW ID fields are BLANK and OLD ID fields are NOT BLANK

     CNT2 > 0 AND CNT1 > 0 THEN
        UPDATE TBL_PENWD
            SET
                PW_NLI_WDRAW_EE = NVL(PW_NEW.PW_NLI_WDRAW_EE,0) + NVL(PW_OLD.PW_NLI_WDRAW_EE,0),
                PW_LI_WDRAW_EE = NVL(PW_NEW.PW_LI_WDRAW_EE,0) + NVL(PW_OLD.PW_LI_WDRAW_EE,0),
                PW_LI_WDRAW_ER = NVL(PW_NEW.PW_LI_WDRAW_ER,0) + NVL(PW_OLD.PW_LI_WDRAW_ER,0),
                PW_NLI_WDRAW_ER = NVL(PW_NEW.PW_NLI_WDRAW_ER,0) + NVL(PW_OLD.PW_NLI_WDRAW_ER,0),
                PW_TERM_DATE = LEAST(NVL(PW_NEW.PW_TERM_DATE,PW_OLD.PW_TERM_DATE),PW_OLD.PW_TERM_DATE),
                PW_PROCESS_DATE = GREATEST(NVL(PW_NEW.PW_PROCESS_DATE,PW_OLD.PW_PROCESS_DATE),PW_OLD.PW_PROCESS_DATE),
                PW_COMMENT = NVL(PW_NEW.PW_COMMENT,PW_OLD.PW_COMMENT),
                PW_LAST_UPDATED_BY = 'SYSTEM',
                PW_LAST_UPDATED_DATE = SYSDATE,
                PW_SOL_RATIO = NVL(PW_NEW.PW_SOL_RATIO,PW_OLD.PW_SOL_RATIO),--REVIEW
                PW_EE_DUE = NVL(PW_NEW.PW_EE_DUE,0) + NVL(PW_OLD.PW_EE_DUE,0),
                PW_ER_DUE = NVL(PW_NEW.PW_ER_DUE,0) + NVL(PW_OLD.PW_ER_DUE,0),
                PW_DUE_DATE = GREATEST(NVL(PW_NEW.PW_DUE_DATE,PW_OLD.PW_DUE_DATE),PW_OLD.PW_DUE_DATE),
                PW_SHORT_INT_RATE = NVL(PW_NEW.PW_SHORT_INT_RATE,PW_OLD.PW_SHORT_INT_RATE),--REVIEW
                PW_LONG_INT_RATE = NVL(PW_NEW.PW_LONG_INT_RATE,PW_OLD.PW_LONG_INT_RATE)--REVIEW
        WHERE
            PW_MEM_ID = NEW_MEM_ID
            AND   TRIM(UPPER(PW_PLAN) ) = TRIM(UPPER(PW_NEW.PW_PLAN) )
            AND   TRIM(UPPER(PW_CLIENT) ) = TRIM(UPPER(PW_NEW.PW_CLIENT) );

    END IF;

    DELETE FROM TBL_PENWD
    WHERE
        PW_MEM_ID = PW_OLD.PW_MEM_ID
        AND   TRIM(UPPER(PW_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PW_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    CLOSE PW1;
    CLOSE PW2;
    << TBL_PAST_UNITS >> OPEN PU1;
    OPEN PU2;
    FETCH PU1 INTO PUNEW;
    FETCH PU2 INTO PUOLD;
    IF
        PU2%NOTFOUND
    THEN
        RAISE_APPLICATION_ERROR(-20003,'NO DATA FOUND FOR ENTERED OLD_MEM_ID VALUES');
    END IF;
    SELECT
        COUNT(*)
    INTO
        CNT1
    FROM
        TBL_PAST_UNITS
    WHERE
        TPU_ID = NEW_MEM_ID
        AND   TRIM(UPPER(TPU_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(TPU_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    SELECT
        COUNT(*)
    INTO
        CNT2
    FROM
        TBL_PAST_UNITS
    WHERE
        TPU_ID = OLD_MEM_ID
        AND   TRIM(UPPER(TPU_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(TPU_CLIENT) = TRIM(UPPER(CLIENT_ID) );
--i--If OLD ID does not exist or (OLD_ID and NEW_ID values are same)  then do not update any data

    IF
        CNT2 <= 0
    THEN
        RAISE_APPLICATION_ERROR(-20001,'Entered OLD_MEM_ID Does not exist');

--ii-IF Old ID exist and New ID does not ,Update OLD ID value with with New ID value.
    ELSIF CNT2 > 0 AND CNT1 <= 0 THEN
        UPDATE TBL_PAST_UNITS
            SET
                TPU_ID = NEW_MEM_ID
        WHERE
            TPU_ID = PUOLD.TPU_ID
            AND   TRIM(TPU_PLAN) = TRIM(UPPER(PUOLD.TPU_PLAN) )
            AND   TRIM(TPU_CLIENT) = TRIM(UPPER(PUOLD.TPU_CLIENT) );

    ELSIF
 
  --iii-If Old and New ID values exist , Update NEW ID fields with OLD ID fields when NEW ID fields are BLANK and OLD ID fields are NOT BLANK

     CNT2 > 0 AND CNT1 > 0 THEN
        UPDATE TBL_PAST_UNITS
            SET
                TPU_UNITS = NVL(PUNEW.TPU_UNITS,0) + NVL(PUOLD.TPU_UNITS,0),
                TPU_FUND = NVL(PUNEW.TPU_FUND,PUOLD.TPU_FUND),
                TPU_RATE = NVL(PUNEW.TPU_RATE,0) + NVL(PUOLD.TPU_RATE,0),
                TPU_AMT = NVL(PUNEW.TPU_AMT,0) + NVL(PUOLD.TPU_AMT,0),
                TPU_FROM = LEAST(NVL(PUNEW.TPU_FROM,PUOLD.TPU_FROM),PUOLD.TPU_FROM),--review
                TPU_TO = GREATEST(NVL(PUNEW.TPU_TO,PUOLD.TPU_TO),PUOLD.TPU_TO),--review
                TPU_PERIOD = NVL(PUNEW.TPU_PERIOD,PUOLD.TPU_PERIOD),--review
                TPU_ENTERED_DATE = GREATEST(NVL(PUNEW.TPU_ENTERED_DATE,PUOLD.TPU_ENTERED_DATE),PUOLD.TPU_ENTERED_DATE),--review
                TPU_EMPLOYER = NVL(PUNEW.TPU_EMPLOYER,PUOLD.TPU_EMPLOYER),
                TPU_USER = NVL(PUNEW.TPU_USER,PUOLD.TPU_USER),--review
                TPU_BATCH = NVL(PUNEW.TPU_BATCH,PUOLD.TPU_BATCH),
                TPU_DESC = NVL(PUNEW.TPU_DESC,PUOLD.TPU_DESC),
                TPU_TRANS_TYPE = NVL(PUNEW.TPU_TRANS_TYPE,PUOLD.TPU_TRANS_TYPE),
                TPU_UNITS_TYPE = NVL(PUNEW.TPU_UNITS_TYPE,PUOLD.TPU_UNITS_TYPE),
                TPU_EE_UNITS = NVL(PUNEW.TPU_EE_UNITS,0) + NVL(PUOLD.TPU_EE_UNITS,0),
                TPU_ER_UNITS = NVL(PUNEW.TPU_ER_UNITS,0) + NVL(PUOLD.TPU_ER_UNITS,0),
                TPU_VOL_UNITS = NVL(PUNEW.TPU_VOL_UNITS,0) + NVL(PUOLD.TPU_VOL_UNITS,0),--review
                TPU_RECD_DATE = NVL(PUNEW.TPU_RECD_DATE,PUOLD.TPU_RECD_DATE)
        WHERE
            TPU_ID = NEW_MEM_ID
            AND   TRIM(UPPER(TPU_PLAN) ) = TRIM(UPPER(PUNEW.TPU_PLAN) )
            AND   TRIM(UPPER(TPU_CLIENT) ) = TRIM(UPPER(PUNEW.TPU_CLIENT) );

    END IF;

    DELETE FROM TBL_PAST_UNITS
    WHERE
        TPU_ID = PUOLD.TPU_ID
        AND   TRIM(TPU_PLAN) = TRIM(UPPER(PUOLD.TPU_PLAN) )
        AND   TRIM(TPU_CLIENT) = TRIM(UPPER(PUOLD.TPU_CLIENT) );

    CLOSE PW1;
    CLOSE PW2;
END MERGE_MEMBER1;
/

