--
-- MERGE_MEMBER_PENSION  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.MERGE_MEMBER_PENSION (
    NEW_MEM_ID   IN NUMBER,
    OLD_MEM_ID   IN NUMBER,
    PLAN_ID      IN VARCHAR2 DEFAULT NULL,
    CLIENT_ID    IN VARCHAR2 DEFAULT NULL,
    PLAN_TYPE    IN VARCHAR2 DEFAULT NULL
) IS

    CURSOR C1 IS SELECT
        *
                 FROM
        TBL_MEMBER
                 WHERE
        MEM_ID = NEW_MEM_ID
        AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );

    CURSOR C2 IS SELECT
        *
                 FROM
        TBL_MEMBER
                 WHERE
        MEM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );

    CURSOR P1 IS SELECT
        *
                 FROM
        TBL_PENMAST
                 WHERE
        PENM_ID = NEW_MEM_ID
        AND   TRIM(UPPER(PENM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(PENM_CLIENT) ) = TRIM(UPPER(CLIENT_ID) );

    CURSOR P2 IS SELECT
        *
                 FROM
        TBL_PENMAST
                 WHERE
        PENM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(PENM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(PENM_CLIENT) ) = TRIM(UPPER(CLIENT_ID) );

    CURSOR A2 IS SELECT
        *
                 FROM
        TBL_ANNUAL
                 WHERE
        ANN_ID = OLD_MEM_ID
        AND   TRIM(UPPER(ANN_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(ANN_CLIENT) ) = TRIM(UPPER(CLIENT_ID) );

    NEWREC    C1%ROWTYPE;
    OLDREC    C2%ROWTYPE;
    PNEW      P1%ROWTYPE;
    POLD      P2%ROWTYPE;
    AOLD      A2%ROWTYPE;
    CNT1      NUMBER := 0;
    CNT2      NUMBER := 0;
    CNT_OLD   NUMBER := 0;
BEGIN
    INIT.SETCLIENTID(CLIENT_ID);
    IF
        NEW_MEM_ID IS NULL OR OLD_MEM_ID IS NULL
    THEN
        RAISE_APPLICATION_ERROR(-20000,'Please Provide NEW and OLD Members');
    END IF;

    IF
        NEW_MEM_ID = OLD_MEM_ID
    THEN
        RAISE_APPLICATION_ERROR(-20000,'The two members should not be the same');
    END IF;
    
    OPEN C1;
    OPEN C2;
    FETCH C1 INTO NEWREC;
    FETCH C2 INTO OLDREC;
    
   IF
        C2%NOTFOUND
    THEN
        RAISE_APPLICATION_ERROR(-20000,'The Incorrect Member ID does not exist');
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

    IF
        NEWREC.MEM_DOB <> OLDREC.MEM_DOB
    THEN
        RAISE_APPLICATION_ERROR(-20000,'The date of birth for the Incorrect Member and the Correct Member do not match. This must be corrected in order to proceed'
);
    END IF;

    IF
        NEWREC.MEM_GENDER <> OLDREC.MEM_GENDER
    THEN
        RAISE_APPLICATION_ERROR(-20000,'The gender for the Incorrect Member and the Correct Member do not match. This must be corrected in order to proceed'
);
    END IF;
    
IF
        NEWREC.MEM_DOD <> OLDREC.MEM_DOD
    THEN
        RAISE_APPLICATION_ERROR(-20000,'The date of death for the Incorrect Member and the Correct Member do not match. This must be corrected in order to proceed'
);
    END IF;

    IF
        CNT2 > 0 AND CNT1 <= 0
    THEN
        UPDATE TBL_MEMBER
            SET
                MEM_ID = NEW_MEM_ID
        WHERE
            MEM_ID = OLDREC.MEM_ID
            AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(OLDREC.MEM_PLAN) )
            AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(OLDREC.MEM_CLIENT_ID) );

    ELSIF CNT2 > 0 AND CNT1 > 0 THEN
        UPDATE TBL_MEMBER
            SET
                MEM_SIN = NVL(NEWREC.MEM_SIN,OLDREC.MEM_SIN),
                MEM_FIRST_NAME = NVL(NEWREC.MEM_FIRST_NAME,OLDREC.MEM_FIRST_NAME),
                MEM_MIDDLE_NAME = NVL(NEWREC.MEM_MIDDLE_NAME,OLDREC.MEM_MIDDLE_NAME),
                MEM_LAST_NAME = NVL(NEWREC.MEM_LAST_NAME,OLDREC.MEM_LAST_NAME),
                MEM_GENDER = NVL(NEWREC.MEM_GENDER,OLDREC.MEM_GENDER),
                MEM_DOB = NVL(NEWREC.MEM_DOB,OLDREC.MEM_DOB),
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
                MEM_DOD =NVL(NEWREC.MEM_DOD,OLDREC.MEM_DOD),
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

/*
    IF
        CNT2 <= 0
    THEN
        RAISE_APPLICATION_ERROR(-20000,'Entered Old member does not exist');
*/

IF CNT2 > 0 AND CNT1 <= 0 THEN
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
                PENM_ENTRY_DATE = LEAST(NVL(PNEW.PENM_ENTRY_DATE,POLD.PENM_ENTRY_DATE),NVL(POLD.PENM_ENTRY_DATE,PNEW.PENM_ENTRY_DATE)),
                PENM_HIRE_DATE = LEAST(NVL(PNEW.PENM_HIRE_DATE,POLD.PENM_HIRE_DATE),NVL(POLD.PENM_HIRE_DATE,PNEW.PENM_HIRE_DATE)),
                PENM_STATUS = NVL(PNEW.PENM_STATUS,POLD.PENM_STATUS),
                PENM_STATUS_DATE = LEAST(NVL(PNEW.PENM_STATUS_DATE,POLD.PENM_STATUS_DATE),NVL(POLD.PENM_STATUS_DATE,PNEW.PENM_STATUS_DATE)),--least
                PENM_RECIPROCAL = NVL(PNEW.PENM_RECIPROCAL,POLD.PENM_RECIPROCAL),
                PENM_LOCAL = NVL(PNEW.PENM_LOCAL,POLD.PENM_LOCAL),
                PENM_EMPLOYER = NVL(PNEW.PENM_EMPLOYER,POLD.PENM_EMPLOYER),
                PENM_PAST_SERV = NVL(PNEW.PENM_PAST_SERV,0) + NVL(POLD.PENM_PAST_SERV,0),
                PENM_PAST_PENSION = NVL(PNEW.PENM_PAST_PENSION,0) + NVL(POLD.PENM_PAST_PENSION,0),
                PENM_CURR_SERV = NVL(PNEW.PENM_CURR_SERV,0) + NVL(POLD.PENM_CURR_SERV,0),
                PENM_CURR_PENSION = NVL(PNEW.PENM_CURR_PENSION,0) + NVL(POLD.PENM_CURR_PENSION,0),
                PENM_MARITAL_STATUS = NVL(PNEW.PENM_MARITAL_STATUS,POLD.PENM_MARITAL_STATUS),
                PENM_LRD = GREATEST(NVL(PNEW.PENM_LRD,POLD.PENM_LRD),NVL(POLD.PENM_LRD,PNEW.PENM_LRD)),
                PENM_VP_PENSION = NVL(PNEW.PENM_VP_PENSION,0) + NVL(POLD.PENM_VP_PENSION,0),
                PENM_PROCESS_DATE = GREATEST(NVL(PNEW.PENM_PROCESS_DATE,POLD.PENM_PROCESS_DATE),NVL(POLD.PENM_PROCESS_DATE,PNEW.PENM_PROCESS_DATE)),
                PENM_VETSED_DATE = GREATEST(NVL(PNEW.PENM_VETSED_DATE,POLD.PENM_VETSED_DATE),NVL(POLD.PENM_VETSED_DATE,PNEW.PENM_VETSED_DATE)),
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
    << TBL_PEN_BENEFICIARY >> SELECT
        COUNT(*)
    INTO
        CNT_OLD
                             FROM
        TBL_PEN_BENEFICIARY
                             WHERE
        PB_ID = OLD_MEM_ID
        AND   TRIM(UPPER(PB_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PB_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    IF
        CNT_OLD <= 0
    THEN
        GOTO TBL_PEN_EXIT_STAT_TRANS;
    ELSE
        UPDATE TBL_PEN_BENEFICIARY
            SET
                PB_ID = NEW_MEM_ID
        WHERE
            PB_ID = OLD_MEM_ID
            AND   TRIM(PB_PLAN) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(PB_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    END IF;
--TBL_PEN_EXIT_STAT_TRANS :Updating OLD_MEM_ID with NEW_MEM_ID when OLD_MEM_ID is exist and NEW_MEM_ID does not exist

    << TBL_PEN_EXIT_STAT_TRANS >> SELECT
        COUNT(*)
    INTO
        CNT_OLD
                                 FROM
        TBL_PEN_EXIT_STAT_TRANS
                                 WHERE
        PEST_MEM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(PEST_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PEST_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    IF
        CNT_OLD <= 0
    THEN
        GOTO TBL_PENWD;
    ELSE
        UPDATE TBL_PEN_EXIT_STAT_TRANS
            SET
                PEST_MEM_ID = NEW_MEM_ID
        WHERE
            PEST_MEM_ID = OLD_MEM_ID
            AND   TRIM(PEST_PLAN) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(PEST_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    END IF;

--TBL_PENWD :Updating OLD_MEM_ID with NEW_MEM_ID when OLD_MEM_ID is exist and NEW_MEM_ID does not exist

    << TBL_PENWD >> SELECT
        COUNT(*)
    INTO
        CNT_OLD
                   FROM
        TBL_PENWD
                   WHERE
        PW_MEM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(PW_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(PW_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    IF
        CNT_OLD <= 0
    THEN
        GOTO TBL_PAST_UNITS;
    ELSE
        UPDATE TBL_PENWD
            SET
                PW_MEM_ID = NEW_MEM_ID
        WHERE
            PW_MEM_ID = OLD_MEM_ID
            AND   TRIM(UPPER(PW_PLAN) ) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(PW_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    END IF;
--TBL_PAST_UNITS :Updating OLD_MEM_ID with NEW_MEM_ID when OLD_MEM_ID is exist and NEW_MEM_ID does not exist

    << TBL_PAST_UNITS >> SELECT
        COUNT(*)
    INTO
        CNT_OLD
                        FROM
        TBL_PAST_UNITS
                        WHERE
        TPU_ID = OLD_MEM_ID
        AND   TRIM(UPPER(TPU_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(TPU_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    IF
        CNT_OLD <= 0
    THEN
        GOTO TBL_MEM_UNITS;
    ELSE
        UPDATE TBL_PAST_UNITS
            SET
                TPU_ID = NEW_MEM_ID
        WHERE
            TPU_ID = OLD_MEM_ID
            AND   TRIM(UPPER(TPU_PLAN) ) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(TPU_CLIENT) = TRIM(UPPER(CLIENT_ID) );

    END IF;

 --TBL_MEM_UNITS :Updating OLD_MEM_ID with NEW_MEM_ID when OLD_MEM_ID is exist and NEW_MEM_ID does not exist

    << TBL_MEM_UNITS >> SELECT
        COUNT(*)
    INTO
        CNT_OLD
                       FROM
        TBL_MEM_UNITS
                       WHERE
        MPU_ID = OLD_MEM_ID
        AND   TRIM(UPPER(MPU_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(MU_CLIENT) ) = TRIM(UPPER(CLIENT_ID) );

    IF
        CNT_OLD <= 0
    THEN
        GOTO TBL_EMPLOYMENT_HIST;
    ELSE
        UPDATE TBL_MEM_UNITS
            SET
                MPU_ID = NEW_MEM_ID
        WHERE
            MPU_ID = OLD_MEM_ID
            AND   TRIM(UPPER(MPU_PLAN) ) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(UPPER(MU_CLIENT) ) = TRIM(UPPER(CLIENT_ID) );

    END IF;
 --TBL_EMPLOYMENT_HIST :Updating OLD_MEM_ID with NEW_MEM_ID when OLD_MEM_ID is exist and NEW_MEM_ID does not exist

    << TBL_EMPLOYMENT_HIST >> SELECT
        COUNT(*)
    INTO
        CNT_OLD
                             FROM
        TBL_EMPLOYMENT_HIST
                             WHERE
        TEH_ID = OLD_MEM_ID
        AND   TRIM(UPPER(TEH_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(TEH_CLIENT) ) = TRIM(UPPER(CLIENT_ID) );

    IF
        CNT_OLD <= 0
    THEN
        GOTO TBL_DOCUMENT;
    ELSE
        UPDATE TBL_EMPLOYMENT_HIST
            SET
                TEH_ID = NEW_MEM_ID
        WHERE
            TEH_ID = OLD_MEM_ID
            AND   TRIM(UPPER(TEH_PLAN) ) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(UPPER(TEH_CLIENT) ) = TRIM(UPPER(CLIENT_ID) );

    END IF;

 --TBL_DOCUMENT :Updating OLD_MEM_ID with NEW_MEM_ID when OLD_MEM_ID is exist and NEW_MEM_ID does not exist

    << TBL_DOCUMENT >> SELECT
        COUNT(*)
    INTO
        CNT_OLD
                      FROM
        TBL_DOCUMENT
                      WHERE
        DOC_MEM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(DOC_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(DOC_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );

    IF
        CNT_OLD <= 0
    THEN
        GOTO TBL_MEMBER_NOTES;
    ELSE
        UPDATE TBL_DOCUMENT
            SET
                DOC_MEM_ID = NEW_MEM_ID
        WHERE
            DOC_MEM_ID = OLD_MEM_ID
            AND   TRIM(UPPER(DOC_PLAN) ) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(UPPER(DOC_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );

    END IF;
 --TBL_MEMBER_NOTES :Updating OLD_MEM_ID with NEW_MEM_ID when OLD_MEM_ID is exist and NEW_MEM_ID does not exist

    << TBL_MEMBER_NOTES >> SELECT
        COUNT(*)
    INTO
        CNT_OLD
                          FROM
        TBL_MEMBER_NOTES
                          WHERE
        MN_ID = OLD_MEM_ID
        AND   TRIM(UPPER(MN_PLAN_ID) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(TMN_CLIENT) ) = TRIM(UPPER(CLIENT_ID) );

    IF
        CNT_OLD <= 0
    THEN
        GOTO TBL_RETIREES;
    ELSE
        UPDATE TBL_MEMBER_NOTES
            SET
                MN_ID = NEW_MEM_ID
        WHERE
            MN_ID = OLD_MEM_ID
            AND   TRIM(UPPER(MN_PLAN_ID) ) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(UPPER(TMN_CLIENT) ) = TRIM(UPPER(CLIENT_ID) );

    END IF;
 --TBL_RETIREES :Updating OLD_MEM_ID with NEW_MEM_ID when OLD_MEM_ID is exist and NEW_MEM_ID does not exist

    << TBL_RETIREES >> SELECT
        COUNT(*)
    INTO
        CNT_OLD
                      FROM
        TBL_RETIREES
                      WHERE
        RET_MEM_ID = OLD_MEM_ID
        AND   TRIM(UPPER(RET_PLAN_ID) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(RET_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );

    IF
        CNT_OLD <= 0
    THEN
        GOTO TBL_ANNUAL;
    ELSE
        UPDATE TBL_RETIREES
            SET
                RET_MEM_ID = NEW_MEM_ID
        WHERE
            RET_MEM_ID = OLD_MEM_ID
            AND   TRIM(UPPER(RET_PLAN_ID) ) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(UPPER(RET_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );

    END IF;

  --TBL_ANNUAL :Updating OLD_MEM_ID with NEW_MEM_ID when OLD_MEM_ID is exist and NEW_MEM_ID does not exist

    << TBL_ANNUAL >> OPEN A2;
    LOOP
        FETCH A2 INTO AOLD;
        EXIT WHEN A2%NOTFOUND;
        SELECT
            COUNT(*)
        INTO
            CNT1
        FROM
            TBL_ANNUAL
        WHERE
            ANN_ID = NEW_MEM_ID
            AND   TRIM(UPPER(ANN_PLAN) ) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(UPPER(ANN_CLIENT) ) = TRIM(UPPER(CLIENT_ID) )
            AND   ANN_YEAR = AOLD.ANN_YEAR
            AND   TRIM(UPPER(NVL(ANN_ACCOUNT,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_ACCOUNT,'X') ) )
            AND   TRIM(UPPER(NVL(ANN_STATUS,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_STATUS,'X') ) );

        SELECT
            COUNT(*)
        INTO
            CNT2
        FROM
            TBL_ANNUAL
        WHERE
            ANN_ID = OLD_MEM_ID
            AND   TRIM(UPPER(ANN_PLAN) ) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(UPPER(ANN_CLIENT) ) = TRIM(UPPER(CLIENT_ID) )
            AND   ANN_YEAR = AOLD.ANN_YEAR
            AND   TRIM(UPPER(NVL(ANN_ACCOUNT,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_ACCOUNT,'X') ) )
            AND   TRIM(UPPER(NVL(ANN_STATUS,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_STATUS,'X') ) );

          IF
            CNT2 > 0 AND CNT1 <= 0
        THEN
            UPDATE TBL_ANNUAL
                SET
                    ANN_ID = NEW_MEM_ID
            WHERE
                ANN_ID = OLD_MEM_ID
                AND   TRIM(UPPER(ANN_PLAN) ) = TRIM(UPPER(PLAN_ID) )
                AND   TRIM(UPPER(ANN_CLIENT) ) = TRIM(UPPER(CLIENT_ID) )
                AND   ANN_YEAR = AOLD.ANN_YEAR
                AND   TRIM(UPPER(NVL(ANN_ACCOUNT,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_ACCOUNT,'X') ) )
                AND   TRIM(UPPER(NVL(ANN_STATUS,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_STATUS,'X') ) );

        END IF;

--Update old it with NEW ID ,when new id does not have same record as OLD ID for fields --ID,PLAN,CLIENT,STATUS,ACCOUNT and YEAR
/*
    IF
        CNT2 > 0 AND CNT1 > 0
    THEN
        UPDATE TBL_ANNUAL
            SET
                ANN_ID = NEW_MEM_ID
        WHERE
            ANN_ID = AOLD.ANN_ID
            AND   TRIM(UPPER(ANN_PLAN) ) = TRIM(UPPER(AOLD.ANN_PLAN) )
            AND   TRIM(UPPER(ANN_CLIENT) ) = TRIM(UPPER(AOLD.ANN_CLIENT) )
           AND ANN_YEAR=AOLD.ANN_YEAR AND ANN_ACCOUNT=AOLD.ANN_ACCOUNT  AND TRIM(UPPER(NVL(ANN_STATUS,'X')) ) = TRIM(UPPER(NVL(AOLD.ANN_STATUS,'X')) )
            AND   NOT EXISTS (
                SELECT
                    1
                FROM
                    TBL_ANNUAL
                WHERE
                    ANN_ID = NEW_MEM_ID
                    AND   ANN_YEAR = AOLD.ANN_YEAR
                    AND   TRIM(UPPER(ANN_STATUS) ) = TRIM(UPPER(AOLD.ANN_STATUS) )
                    AND   TRIM(UPPER(ANN_ACCOUNT) ) = TRIM(UPPER(AOLD.ANN_ACCOUNT) )
                    AND   TRIM(UPPER(ANN_PLAN) ) = TRIM(UPPER(AOLD.ANN_PLAN) )
                    AND   TRIM(UPPER(ANN_CLIENT) ) = TRIM(UPPER(AOLD.ANN_CLIENT) )
            );

    END IF;
*/

        IF
            CNT2 > 0 AND CNT1 > 0
        THEN
            UPDATE TBL_ANNUAL
                SET
                    ANN_EE_CONTS = NVL(ANN_EE_CONTS,0) + NVL(AOLD.ANN_EE_CONTS,0),
                    ANN_ER_CONTS = NVL(ANN_ER_CONTS,0) + NVL(AOLD.ANN_ER_CONTS,0),
                    ANN_EARNINGS = NVL(ANN_EARNINGS,0) + NVL(AOLD.ANN_EARNINGS,0),
                    ANN_HRS = NVL(ANN_HRS,0) + NVL(AOLD.ANN_HRS,0),
                    ANN_PEN_VALUE = NVL(ANN_PEN_VALUE,0) + NVL(AOLD.ANN_PEN_VALUE,0),
                    ANN_CRED_SERV = NVL(ANN_CRED_SERV,0) + NVL(AOLD.ANN_CRED_SERV,0),
                    ANN_PA = NVL(ANN_PA,0) + NVL(AOLD.ANN_PA,0),
                    ANN_VOL_UNITS = NVL(ANN_VOL_UNITS,0) + NVL(AOLD.ANN_VOL_UNITS,0),
                    EE_INT = NVL(EE_INT,0) + NVL(AOLD.EE_INT,0),
                    ER_INT = NVL(ER_INT,0) + NVL(AOLD.ER_INT,0),
                    VOL_INT = NVL(VOL_INT,0) + NVL(AOLD.VOL_INT,0),
                    ANN_LRD = GREATEST(NVL(ANN_LRD,AOLD.ANN_LRD),AOLD.ANN_LRD),
                    ANN_COMP = NVL(ANN_COMP,AOLD.ANN_COMP)
            WHERE
                ANN_ID = NEW_MEM_ID
                AND   TRIM(UPPER(ANN_PLAN) ) = TRIM(UPPER(PLAN_ID) )
                AND   TRIM(UPPER(ANN_CLIENT) ) = TRIM(UPPER(CLIENT_ID) )
                AND   ANN_YEAR = AOLD.ANN_YEAR
                AND   TRIM(UPPER(NVL(ANN_ACCOUNT,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_ACCOUNT,'X') ) )
                AND   TRIM(UPPER(NVL(ANN_STATUS,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_STATUS,'X') ) );
                /*AND   EXISTS (
                    SELECT
                        1
                    FROM
                        TBL_ANNUAL
                    WHERE
                        ANN_ID = NEW_MEM_ID
                        AND   ANN_YEAR = AOLD.ANN_YEAR
                        AND   TRIM(UPPER(NVL(ANN_STATUS,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_STATUS,'X') ) )
                        AND   TRIM(UPPER(NVL(ANN_ACCOUNT,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_ACCOUNT,'X') ) )
                        AND   TRIM(UPPER(ANN_PLAN) ) = TRIM(UPPER(AOLD.ANN_PLAN) )
                        AND   TRIM(UPPER(ANN_CLIENT) ) = TRIM(UPPER(AOLD.ANN_CLIENT) )
                );*/

        END IF;

        DELETE FROM TBL_ANNUAL
        WHERE
            ANN_ID = OLD_MEM_ID
            AND   TRIM(UPPER(ANN_PLAN) ) = TRIM(UPPER(PLAN_ID) )
            AND   TRIM(UPPER(ANN_CLIENT) ) = TRIM(UPPER(CLIENT_ID) )
            AND   ANN_YEAR = AOLD.ANN_YEAR
            AND   TRIM(UPPER(NVL(ANN_ACCOUNT,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_ACCOUNT,'X') ) )
            AND   TRIM(UPPER(NVL(ANN_STATUS,'X') ) ) = TRIM(UPPER(NVL(AOLD.ANN_STATUS,'X') ) );

    END LOOP;
  
    --CLOSE A1;

    CLOSE A2;
END MERGE_MEMBER_PENSION;
/

