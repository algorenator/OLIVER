--
-- MERGE_MEMBER_HB1  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.MERGE_MEMBER_HB1 (
    OLD_MEM_ID   IN VARCHAR2,
   NEW_MEM_ID   IN VARCHAR2,
    PLAN_ID      IN VARCHAR2 DEFAULT NULL,
    CLIENT_ID    IN VARCHAR2 DEFAULT NULL,
    PLAN_TYPE    IN VARCHAR2 DEFAULT NULL
) IS

--------------------------------------------------------------------------------------------------------------------
--Procedure     :MERGE_MEMBER_HB
--Project       :Oliver
--Purpose       :Merge Member process for Hour bank data
/*Tables Used   :OLIVER.TBL_MEMBER,
                 OLIVER.TBL_HR_BANK ,
                 TRANSACTION_DETAIL,
                 OLIVER.TBL_HW,
                 OLIVER.TBL_MEMBER_NOTES,
                 OLIVER.TBL_HW_DEPENDANTS, 
                 OLIVER.TBL_HW_BENEFICIARY,
*/
-----------------------------MODIFICATION HISTORY----------------------------------------------------------------------------
--  Name                  Date                Comments

--  Ramana                25/04/2018          New Procedure
----------------------------------------------------------------------------------------------------------
CURSOR C1 IS SELECT
        *
                 FROM
        TBL_MEMBER
                 WHERE
        TRIM(MEM_ID) = TRIM(OLD_MEM_ID)
        AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );


    CURSOR C2 IS SELECT
        *
                 FROM
        TBL_MEMBER
                 WHERE
        TRIM(MEM_ID) = TRIM(NEW_MEM_ID)
        AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );

CURSOR HB1 IS 
SELECT * FROM OLIVER.TBL_HR_BANK  
   WHERE TRIM(THB_ID)=TRIM(OLD_MEM_ID) 
   AND TRIM(UPPER(THB_PLAN))=TRIM(UPPER(PLAN_ID))
   AND TRIM(UPPER(THB_CLIENT_ID))=TRIM(UPPER(CLIENT_ID));

CURSOR HW IS   
SELECT * FROM TBL_HW 
WHERE TRIM(HW_ID)=TRIM(OLD_MEM_ID)
AND TRIM(HW_PLAN)=TRIM(PLAN_ID)
AND TRIM(HW_CLIENT)=TRIM(CLIENT_ID);
 CURSOR TD IS
 SELECT * FROM TRANSACTION_DETAIL
 WHERE TRIM(TD_MEM_ID)=TRIM(OLD_MEM_ID)
 AND TRIM(TD_PLAN_ID)=TRIM(PLAN_ID)
 AND TRIM(TD_CLIENT_ID)=TRIM(CLIENT_ID);

    OLDREC    C1%ROWTYPE;
    NEWREC    C2%ROWTYPE;
    HB_OLD HB1%ROWTYPE;
    HW_REC HW%ROWTYPE;
    TD_REC TD%ROWTYPE;

    CNT1      NUMBER := 0;
    CNT2      NUMBER := 0;
    CNT_OLD   NUMBER := 0;
    V_POST_DATE DATE;
    V_EMPLOYER VARCHAR2(50);
BEGIN
    INIT.SETCLIENTID(CLIENT_ID);
    IF
        OLD_MEM_ID IS NULL OR NEW_MEM_ID IS NULL
    THEN
        RAISE_APPLICATION_ERROR(-20000,'Please Provide NEW and OLD Members');
    END IF;

    IF
        OLD_MEM_ID = NEW_MEM_ID
    THEN
        RAISE_APPLICATION_ERROR(-20000,'The two members should not be the same');
    END IF;

    OPEN C1;
    OPEN C2;
    FETCH C1 INTO OLDREC;
    FETCH C2 INTO NEWREC;

   IF
        C1%NOTFOUND
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
        TRIM(MEM_ID) = TRIM(OLD_MEM_ID)
        AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );

    SELECT
        COUNT(*)
    INTO
        CNT2
    FROM
        TBL_MEMBER
    WHERE
        TRIM(MEM_ID) = TRIM(NEW_MEM_ID)
        AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(PLAN_ID) )
        AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(CLIENT_ID) );

    IF
        OLDREC.MEM_DOB <> NEWREC.MEM_DOB
    THEN
        RAISE_APPLICATION_ERROR(-20000,'The date of birth for the Incorrect Member and the Correct Member do not match. This must be corrected in order to proceed'
);
    END IF;

    IF
        OLDREC.MEM_GENDER <> NEWREC.MEM_GENDER
    THEN
        RAISE_APPLICATION_ERROR(-20000,'The gender for the Incorrect Member and the Correct Member do not match. This must be corrected in order to proceed'
);
    END IF;

IF
        OLDREC.MEM_DOD <> NEWREC.MEM_DOD
    THEN
        RAISE_APPLICATION_ERROR(-20000,'The date of death for the Incorrect Member and the Correct Member do not match. This must be corrected in order to proceed'
);
    END IF;

    IF
        CNT1 > 0 AND CNT2 <= 0
    THEN
        UPDATE TBL_MEMBER
            SET
                MEM_ID = TRIM(NEW_MEM_ID)
        WHERE
            TRIM(MEM_ID) = TRIM(OLD_MEM_ID)
            AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(OLDREC.MEM_PLAN) )
            AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(OLDREC.MEM_CLIENT_ID) );

    ELSIF CNT1 > 0 AND CNT2 > 0 THEN
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
            TRIM(MEM_ID) = TRIM(NEW_MEM_ID)
            AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(NEWREC.MEM_PLAN) )
            AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(NEWREC.MEM_CLIENT_ID) );

    END IF;

    DELETE FROM TBL_MEMBER
    WHERE
        TRIM(MEM_ID) = TRIM(OLD_MEM_ID)
        AND   TRIM(UPPER(MEM_PLAN) ) = TRIM(UPPER(OLDREC.MEM_PLAN) )
        AND   TRIM(UPPER(MEM_CLIENT_ID) ) = TRIM(UPPER(OLDREC.MEM_CLIENT_ID) );

    CLOSE C1;
    CLOSE C2;
    OPEN HB1;
    LOOP
FETCH HB1 INTO HB_OLD;
IF  HB1%NOTFOUND THEN 
GOTO TBL_HW;
END IF;
/* SELECT COUNT(*) INTO CNT1 FROM OLIVER.TBL_HR_BANK
   WHERE TRIM(THB_ID)=TRIM(OLD_MEM_ID)
   AND TRIM(UPPER(THB_PLAN))=TRIM(UPPER(PLAN_ID))
   AND TRIM(UPPER(THB_CLIENT_ID))=TRIM(UPPER(CLIENT_ID) )
   AND TRIM(UPPER(THB_MONTH))=TRIM(UPPER(HB_OLD.THB_MONTH));*/

   SELECT MAX(THB_EMPLOYER),MAX(THB_POSTED_DATE),COUNT(*) INTO V_EMPLOYER,V_POST_DATE,CNT2 FROM OLIVER.TBL_HR_BANK
   WHERE TRIM(THB_ID)=TRIM(NEW_MEM_ID)
   AND TRIM(UPPER(THB_PLAN))=TRIM(UPPER(PLAN_ID))
   AND TRIM(UPPER(THB_CLIENT_ID))=TRIM(UPPER(CLIENT_ID) )
   AND TRIM(UPPER(THB_MONTH))=TRIM(UPPER(HB_OLD.THB_MONTH));


IF CNT2<=0 THEN
UPDATE OLIVER.TBL_HR_BANK
SET THB_ID=NEW_MEM_ID
WHERE THB_ID=OLD_MEM_ID  
AND TRIM(UPPER(THB_CLIENT_ID))=TRIM(UPPER(CLIENT_ID) )
 AND TRIM(UPPER(THB_PLAN))=TRIM(UPPER(PLAN_ID))
AND TRIM(UPPER(THB_MONTH))=TRIM(UPPER(HB_OLD.THB_MONTH));
ELSE 
UPDATE 
OLIVER.TBL_HR_BANK
SET THB_HOURS=NVL(THB_HOURS,0)+NVL(HB_OLD.THB_HOURS,0),
THB_DEDUCT_HRS=NVL(THB_DEDUCT_HRS,0)+NVL(HB_OLD.THB_DEDUCT_HRS,0),
THB_CLOSING_HRS=NVL(THB_CLOSING_HRS,0)+NVL(HB_OLD.THB_CLOSING_HRS,0),
THB_POSTED_DATE=GREATEST(NVL(THB_POSTED_DATE,HB_OLD.THB_POSTED_DATE),NVL(HB_OLD.THB_POSTED_DATE,THB_POSTED_DATE)),
THB_EMPLOYER=
CASE 
WHEN V_POST_DATE is not null and V_POST_DATE>=HB_OLD.THB_POSTED_DATE
THEN V_EMPLOYER
else
HB_OLD.THB_EMPLOYER
END,
THB_MODIFIED_BY='SYSTEM',
THB_MODIFIED_DATE=SYSDATE,
THB_FUND_CODE=NVL(THB_FUND_CODE,HB_OLD.THB_FUND_CODE)
 WHERE TRIM(THB_ID)=TRIM(NEW_MEM_ID)
   AND TRIM(UPPER(THB_PLAN))=TRIM(UPPER(PLAN_ID))
   AND TRIM(UPPER(THB_CLIENT_ID))=TRIM(UPPER(CLIENT_ID) )
   AND TRIM(UPPER(THB_MONTH))=TRIM(UPPER(HB_OLD.THB_MONTH));

 END IF;

DELETE FROM OLIVER.TBL_HR_BANK
WHERE THB_ID=OLD_MEM_ID  
AND TRIM(UPPER(THB_CLIENT_ID))=TRIM(UPPER(CLIENT_ID) )
 AND TRIM(UPPER(THB_PLAN))=TRIM(UPPER(PLAN_ID))
AND TRIM(UPPER(THB_MONTH))=TRIM(UPPER(HB_OLD.THB_MONTH));

END LOOP;
CLOSE HB1;

<<TBL_HW>>
OPEN HW;
FETCH HW INTO HW_REC;
IF HW%NOTFOUND THEN
GOTO TRANSACTION_DETAIL;
END IF;

SELECT COUNT(*) INTO CNT2 FROM OLIVER.TBL_HW
WHERE TRIM(HW_ID)=TRIM(NEW_MEM_ID)
AND TRIM(HW_PLAN)=TRIM(PLAN_ID)
AND TRIM(HW_CLIENT)=TRIM(CLIENT_ID);

IF  CNT2<=0 THEN
UPDATE OLIVER.TBL_HW
SET HW_ID=NEW_MEM_ID
WHERE HW_ID=OLD_MEM_ID 
AND TRIM(HW_PLAN)=TRIM(PLAN_ID)
AND TRIM(HW_CLIENT)=TRIM(CLIENT_ID);
ELSE
UPDATE OLIVER.TBL_HW
SET 
 HW_EFF_DATE=GREATEST(NVL(HW_EFF_DATE,HW_REC.HW_EFF_DATE),NVL(HW_REC.HW_EFF_DATE,HW_EFF_DATE)),
  HW_TERM_DATE=GREATEST(NVL(HW_TERM_DATE,HW_REC.HW_TERM_DATE),NVL(HW_REC.HW_TERM_DATE,HW_TERM_DATE)),
  HW_COVERAGE=NVL(HW_COVERAGE,HW_REC.HW_COVERAGE),
    HW_EMPLOYER=NVL(HW_EMPLOYER,HW_REC.HW_EMPLOYER),
    HW_DIV=NVL(HW_DIV,HW_REC.HW_DIV),
    HW_BILLING_CODE=NVL(HW_BILLING_CODE,HW_REC.HW_BILLING_CODE),
    HW_TERM_CODE=NVL(HW_TERM_CODE,HW_REC.HW_TERM_CODE),
    HW_APP_RECD=NVL(HW_APP_RECD,HW_REC.HW_APP_RECD),
    HW_LAST_MODIFIED_DATE=NVL(HW_LAST_MODIFIED_DATE,HW_REC.HW_LAST_MODIFIED_DATE),
    HW_LAST_MODIFIED_BY=NVL(HW_LAST_MODIFIED_BY,HW_REC.HW_LAST_MODIFIED_BY),
    HW_LOCAL=NVL(HW_LOCAL,HW_REC.HW_LOCAL),
    HW_LOCAL_EFF_DATE=GREATEST(NVL(HW_LOCAL_EFF_DATE,HW_REC.HW_LOCAL_EFF_DATE),NVL(HW_REC.HW_LOCAL_EFF_DATE,HW_LOCAL_EFF_DATE)),
    HW_RECIPROCAL=NVL(HW_RECIPROCAL,HW_REC.HW_RECIPROCAL),
    HW_RECIPROCAL_DATE=GREATEST(NVL(HW_RECIPROCAL_DATE,HW_REC.HW_RECIPROCAL_DATE),NVL(HW_REC.HW_RECIPROCAL_DATE,HW_RECIPROCAL_DATE)),
    HW_SUSPENED=NVL(HW_SUSPENED,HW_REC.HW_SUSPENED),
    HW_SUSP_DATE=GREATEST(NVL(HW_SUSP_DATE,HW_REC.HW_SUSP_DATE),NVL(HW_REC.HW_SUSP_DATE,HW_SUSP_DATE)),
    HW_SUSP_REASON=NVL(HW_SUSP_REASON,HW_REC.HW_SUSP_REASON),
    HW_CLASS=NVL(HW_CLASS,HW_REC.HW_CLASS),
    HW_STATUS=NVL(HW_STATUS,HW_REC.HW_STATUS),
    HW_MEM_CATEGORY=NVL(HW_MEM_CATEGORY,HW_REC.HW_MEM_CATEGORY),
    HW_SUB_PLAN=NVL(HW_SUB_PLAN,HW_REC.HW_SUB_PLAN),
    HW_SUBSIDIZED=NVL(HW_SUBSIDIZED,HW_REC.HW_SUBSIDIZED),
    HW_LATE_APP=NVL(HW_LATE_APP,HW_REC.HW_LATE_APP),
    HW_LATE_EFF_DATE=GREATEST(NVL(HW_LATE_EFF_DATE,HW_REC.HW_LATE_EFF_DATE),NVL(HW_REC.HW_LATE_EFF_DATE,HW_LATE_EFF_DATE)),
    HW_LATE_TERM_DATE=GREATEST(NVL(HW_LATE_TERM_DATE,HW_REC.HW_LATE_TERM_DATE),NVL(HW_REC.HW_LATE_TERM_DATE,HW_LATE_TERM_DATE)),
     HW_SMOKER=NVL(HW_SMOKER,HW_REC.HW_SMOKER),
    HW_EE_TYPE=NVL(HW_EE_TYPE,HW_REC.HW_EE_TYPE),
    HW_COUPLE_DEP_NO=NVL(HW_COUPLE_DEP_NO,HW_REC.HW_COUPLE_DEP_NO),
        HW_VISION_ELIGIBLE=NVL(HW_VISION_ELIGIBLE,HW_REC.HW_VISION_ELIGIBLE),
    HW_SPOUSAL_SMOKER=NVL(HW_SPOUSAL_SMOKER,HW_REC.HW_SPOUSAL_SMOKER),
    HW_DEP_STATUS=NVL(HW_DEP_STATUS,HW_REC.HW_DEP_STATUS),
    HW_SMOKER_EFF_DATE=GREATEST(NVL(HW_SMOKER_EFF_DATE,HW_REC.HW_SMOKER_EFF_DATE),NVL(HW_REC.HW_SMOKER_EFF_DATE,HW_SMOKER_EFF_DATE)),
    HW_SP_SMOKER_EFF_DATE=GREATEST(NVL(HW_SP_SMOKER_EFF_DATE,HW_REC.HW_SP_SMOKER_EFF_DATE),NVL(HW_REC.HW_SP_SMOKER_EFF_DATE,HW_SP_SMOKER_EFF_DATE)),
    HW_DEP_STATUS_EFF_DATE=GREATEST(NVL(HW_DEP_STATUS_EFF_DATE,HW_REC.HW_DEP_STATUS_EFF_DATE),NVL(HW_REC.HW_DEP_STATUS_EFF_DATE,HW_DEP_STATUS_EFF_DATE)),
    HW_CLASS_EFF_DATE=GREATEST(NVL(HW_CLASS_EFF_DATE,HW_REC.HW_CLASS_EFF_DATE),NVL(HW_REC.HW_CLASS_EFF_DATE,HW_CLASS_EFF_DATE))
WHERE HW_ID=NEW_MEM_ID 
AND TRIM(HW_PLAN)=TRIM(PLAN_ID)
AND TRIM(HW_CLIENT)=TRIM(CLIENT_ID);

END IF;

DELETE FROM OLIVER.TBL_HW
WHERE HW_ID=OLD_MEM_ID 
AND TRIM(HW_PLAN)=TRIM(PLAN_ID)
AND TRIM(HW_CLIENT)=TRIM(CLIENT_ID);
CLOSE HW;

<<TRANSACTION_DETAIL>>
SELECT COUNT(*) INTO CNT_OLD FROM TRANSACTION_DETAIL
WHERE TD_MEM_ID=OLD_MEM_ID
AND TRIM(TD_PLAN_ID)=TRIM(PLAN_ID)
 AND TRIM(TD_CLIENT_ID)=TRIM(CLIENT_ID);

IF CNT_OLD<=0 THEN
GOTO TBL_MEMBER_NOTES;
ELSE
 UPDATE TRANSACTION_DETAIL
 SET TD_MEM_ID=NEW_MEM_ID
WHERE TD_MEM_ID=OLD_MEM_ID
AND TRIM(TD_PLAN_ID)=TRIM(PLAN_ID)
 AND TRIM(TD_CLIENT_ID)=TRIM(CLIENT_ID);
 END IF;


<<TBL_MEMBER_NOTES>>
SELECT COUNT(*) INTO CNT_OLD FROM OLIVER.TBL_MEMBER_NOTES
WHERE TRIM(MN_ID)=TRIM(OLD_MEM_ID)
AND TRIM(MN_PLAN_ID)=TRIM(PLAN_ID)
AND TRIM(TMN_CLIENT)=TRIM(CLIENT_ID);

IF CNT_OLD<=0 THEN
GOTO  TBL_HW_DEPENDANTS;
ELSE
UPDATE OLIVER.TBL_MEMBER_NOTES
SET MN_ID=NEW_MEM_ID
WHERE TRIM(MN_ID)=TRIM(OLD_MEM_ID)
AND TRIM(MN_PLAN_ID)=TRIM(PLAN_ID)
AND TRIM(TMN_CLIENT)=TRIM(CLIENT_ID);
END IF;
<<TBL_HW_DEPENDANTS>>

SELECT COUNT(*) INTO CNT_OLD FROM OLIVER.TBL_HW_DEPENDANTS
WHERE HD_ID=OLD_MEM_ID
AND TRIM(HD_PLAN)=TRIM(PLAN_ID)
AND TRIM(HD_CLIENT)=TRIM(CLIENT_ID);

IF CNT_OLD<=0 THEN
GOTO TBL_HW_BENEFICIARY;
ELSE
UPDATE OLIVER.TBL_HW_DEPENDANTS
SET HD_ID=NEW_MEM_ID
WHERE HD_ID=OLD_MEM_ID
AND TRIM(HD_PLAN)=TRIM(PLAN_ID)
AND TRIM(HD_CLIENT)=TRIM(CLIENT_ID);
END IF;

<<TBL_HW_BENEFICIARY>>

SELECT  COUNT(*) INTO CNT_OLD FROM OLIVER.TBL_HW_BENEFICIARY
WHERE TRIM(HB_ID)=TRIM(OLD_MEM_ID)
AND TRIM(HB_PLAN)=TRIM(PLAN_ID)
AND TRIM(HB_CLIENT)=TRIM(CLIENT_ID);

IF CNT_OLD>0 THEN
UPDATE OLIVER.TBL_HW_BENEFICIARY
SET HB_ID=NEW_MEM_ID
WHERE TRIM(HB_ID)=TRIM(OLD_MEM_ID)
AND TRIM(HB_PLAN)=TRIM(PLAN_ID)
AND TRIM(HB_CLIENT)=TRIM(CLIENT_ID);
END IF;

END MERGE_MEMBER_HB1;
/

