--
-- COPY_CLIENT  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.COPY_CLIENT (
    OLD_CLIENT_ID   IN VARCHAR2,
    NEW_CLIENT_ID   IN VARCHAR2
) IS
--------------------------------------------------------------------------------------------------------------------
--Procedure     :DUPLICATE_CLIENT_CREATRION
--Project       :Oliver
--Purpose       :Creates duplicate client with existing data
/*Tables Used   :OLIVER.APEX_ACCESS_CONTROL,OLIVER.BENEFITS_AGE_BASED,OLIVER.BENEFITS_DEP_BASED,OLIVER.BENEFITS_VOLUME_BASED,
                OLIVER.TBL_MEMBER, OLIVER.TBL_COMPMAST,OLIVER.TBL_HW
*/
-----------------------------MODIFICATION HISTORY----------------------------------------------------------------------------
--  Name                  Date                Comments

--  Ramana                09/04/2018          New Procedure
----------------------------------------------------------------------------------------------------------

    OLD_CLIENT   VARCHAR2(50) := UPPER(OLD_CLIENT_ID);
    NEW_CLIENT   VARCHAR2(50) := UPPER(NEW_CLIENT_ID);
BEGIN
    INIT.SETCLIENTID(OLD_CLIENT);
    IF
        OLD_CLIENT IS NULL OR NEW_CLIENT IS NULL
    THEN
        RAISE_APPLICATION_ERROR(-20001,'PLEASE ENTER VALUES FOR OLD_CLIENT_ID AND NEW_CLIENT_ID');
    END IF;

    IF
        OLD_CLIENT = NEW_CLIENT
    THEN
        RAISE_APPLICATION_ERROR(-20001,'OLD_CLIENT_ID AND NEW_CLIENT_ID SHOULD NOT BE SAME');
    END IF;
    INSERT INTO OLIVER.BENEFITS_AGE_BASED (
        BAB_CLIENT_ID,
        BAB_PLAN_ID,
        BAB_BENEFIT,
        BAB_CLASS,
        BAB_EFF_DATE,
        BAB_TERM_DATE,
        BAB_SMOKER,
        BAB_GENDER,
        BAB_AGE,
        BAB_RATE,
        BAB_ADMIN_RATE,
        BAB_AGENT,
        BAB_AGENT_RATE,
        BAB_ID,
        BAB_CARRIER
    )
        ( SELECT
            NEW_CLIENT,
            BAB_PLAN_ID,
            BAB_BENEFIT,
            BAB_CLASS,
            BAB_EFF_DATE,
            BAB_TERM_DATE,
            BAB_SMOKER,
            BAB_GENDER,
            BAB_AGE,
            BAB_RATE,
            BAB_ADMIN_RATE,
            BAB_AGENT,
            BAB_AGENT_RATE,
            BAB_ID,
            BAB_CARRIER
          FROM
            OLIVER.BENEFITS_AGE_BASED
          WHERE
            BAB_CLIENT_ID = OLD_CLIENT
        );

--OLIVER.BENEFITS_DEP_BASED 

    INSERT INTO OLIVER.BENEFITS_DEP_BASED (
        BDB_CLIENT_ID,
        BDB_PLAN_ID,
        BDB_BENEFIT,
        BDB_DEP_STATUS,
        BDB_RATE,
        BDB_AGENT,
        BDB_ADMIN_RATE,
        BDB_CLASS,
        BDB_EFF_DATE,
        BDB_TERM_DATE,
        BDB_AGENT_RATE,
        BDB_ID,
        BDB_CARRIER
    )
        ( SELECT
            NEW_CLIENT,
            BDB_PLAN_ID,
            BDB_BENEFIT,
            BDB_DEP_STATUS,
            BDB_RATE,
            BDB_AGENT,
            BDB_ADMIN_RATE,
            BDB_CLASS,
            BDB_EFF_DATE,
            BDB_TERM_DATE,
            BDB_AGENT_RATE,
            BDB_ID,
            BDB_CARRIER
          FROM
            OLIVER.BENEFITS_DEP_BASED
          WHERE
            BDB_CLIENT_ID = OLD_CLIENT
        );
--OLIVER.BENEFITS_VOLUME_BASED

    INSERT INTO OLIVER.BENEFITS_VOLUME_BASED (
        BVB_BENEFIT,
        BVB_VOLUME,
        BVB_NEM,
        BVB_MAX,
        BVB_RATE,
        BVB_AGENT,
        BVB_ADMIN_RATE,
        BVB_EFFECTIVE_DATE,
        BVB_TERM_DATE,
        BVB_CLASS,
        BVB_UNIT,
        BVB_CLIENT_ID,
        BVB_PLAN_ID,
        BVB_AGENT_RATE,
        BVB_ID,
        VOLUME_SELECT,
        BVB_CARRIER
    )
        ( SELECT
            BVB_BENEFIT,
            BVB_VOLUME,
            BVB_NEM,
            BVB_MAX,
            BVB_RATE,
            BVB_AGENT,
            BVB_ADMIN_RATE,
            BVB_EFFECTIVE_DATE,
            BVB_TERM_DATE,
            BVB_CLASS,
            BVB_UNIT,
            NEW_CLIENT,
            BVB_PLAN_ID,
            BVB_AGENT_RATE,
            BVB_ID,
            VOLUME_SELECT,
            BVB_CARRIER
          FROM
            OLIVER.BENEFITS_VOLUME_BASED
          WHERE
            BVB_CLIENT_ID = OLD_CLIENT
        );
    
-----------

    INSERT INTO OLIVER.CONT_INT_RATES (
        EIR_EFF_DATE,
        EIR_RATE,
        EIR_CLIENT,
        EIR_PLAN
    )
        ( SELECT
            EIR_EFF_DATE,
            EIR_RATE,
            NEW_CLIENT,
            EIR_PLAN
          FROM
            OLIVER.CONT_INT_RATES
          WHERE
            EIR_CLIENT = OLD_CLIENT
        );
-----
    
--OLIVER.TBL_AGREEMENT

    INSERT INTO OLIVER.TBL_AGREEMENT (
        TA_ID,
        TA_DESC,
        TA_PLAN_ID,
        TA_CLIENT_ID,
        TA_EFF_DATE,
        TA_TERM_DATE
    )
        ( SELECT
            TA_ID,
            TA_DESC,
            TA_PLAN_ID,
            NEW_CLIENT,
            TA_EFF_DATE,
            TA_TERM_DATE
          FROM
            OLIVER.TBL_AGREEMENT
          WHERE
            TA_CLIENT_ID = OLD_CLIENT
        );

    INSERT INTO TBL_MEM_PEN_STATUS_HIST (
        TMPSH_CLIENT,
        TMPSH_PLAN,
        TMPSH_MEM_ID,
        TMPSH_STATUS,
        TMPSH_STATUS_DATE,
        TMPSH_CREATED_DATE,
        TMPSH_CREATED_BY
    )
        ( SELECT
            NEW_CLIENT,
            TMPSH_PLAN,
            TMPSH_MEM_ID,
            TMPSH_STATUS,
            TMPSH_STATUS_DATE,
            TMPSH_CREATED_DATE,
            TMPSH_CREATED_BY
          FROM
            TBL_MEM_PEN_STATUS_HIST
          WHERE
            TMPSH_CLIENT = OLD_CLIENT
        );   
--OLIVER.TBL_AGREEMENT_DESC

    INSERT INTO OLIVER.TBL_AGREEMENT_DESC (
        TADC_CODE,
        TADC_DESC,
        TADC_PLAN,
        TADC_CLIENT
    )
        ( SELECT
            TADC_CODE,
            TADC_DESC,
            TADC_PLAN,
            NEW_CLIENT
          FROM
            OLIVER.TBL_AGREEMENT_DESC
          WHERE
            TADC_CLIENT = OLD_CLIENT
        );

--OLIVER.TBL_AGREEMENT_DETAILS 

    INSERT INTO OLIVER.TBL_AGREEMENT_DETAILS (
        TAD_AGREE_ID,
        TAD_ER_ID,
        TAD_OCCUP_ID,
        TAD_YEAR_ID,
        TAD_EFF_DATE,
        TAD_UNIT_TYPE,
        TAD_RATE,
        TAD_CLIENT_ID,
        TAD_PLAN_ID,
        TAD_FUND,
        TAD_EE_PORTION,
        TAD_ER_PORTION
    )
        ( SELECT
            TAD_AGREE_ID,
            TAD_ER_ID,
            TAD_OCCUP_ID,
            TAD_YEAR_ID,
            TAD_EFF_DATE,
            TAD_UNIT_TYPE,
            TAD_RATE,
            NEW_CLIENT,
            TAD_PLAN_ID,
            TAD_FUND,
            TAD_EE_PORTION,
            TAD_ER_PORTION
          FROM
            OLIVER.TBL_AGREEMENT_DETAILS
          WHERE
            TAD_CLIENT_ID = OLD_CLIENT
        );
    
 --OLIVER.TBL_AGREEMENT_TYPES

    INSERT INTO OLIVER.TBL_AGREEMENT_TYPES (
        TAT_ID,
        TAT_CODE,
        TAT_DESC,
        TAT_PLAN_ID,
        TAT_CLIENT_ID
    )
        ( SELECT
            TAT_ID,
            TAT_CODE,
            TAT_DESC,
            TAT_PLAN_ID,
            NEW_CLIENT
          FROM
            OLIVER.TBL_AGREEMENT_TYPES
          WHERE
            TAT_CLIENT_ID = OLD_CLIENT
        );
    
--OLIVER.TBL_ANNUAL

    INSERT INTO OLIVER.TBL_ANNUAL (
        ANN_ID,
        ANN_PLAN,
        ANN_YEAR,
        ANN_STATUS,
        ANN_COMP,
        ANN_EE_CONTS,
        ANN_ER_CONTS,
        ANN_EARNINGS,
        ANN_HRS,
        ANN_CRED_SERV,
        ANN_PA,
        ANN_PEN_VALUE,
        ANN_LRD,
        ANN_CLIENT,
        ANN_VOL_UNITS,
        EE_INT,
        ER_INT,
        VOL_INT,
        ANN_ACCOUNT
    )
        ( SELECT
            ANN_ID,
            ANN_PLAN,
            ANN_YEAR,
            ANN_STATUS,
            ANN_COMP,
            ANN_EE_CONTS,
            ANN_ER_CONTS,
            ANN_EARNINGS,
            ANN_HRS,
            ANN_CRED_SERV,
            ANN_PA,
            ANN_PEN_VALUE,
            ANN_LRD,
            NEW_CLIENT,
            ANN_VOL_UNITS,
            EE_INT,
            ER_INT,
            VOL_INT,
            ANN_ACCOUNT
          FROM
            OLIVER.TBL_ANNUAL
          WHERE
            ANN_CLIENT = OLD_CLIENT
        );

--TBL_BENEFIC_RELATION  

    INSERT INTO OLIVER.TBL_BENEFIC_RELATION (
        TBR_CLIENT,
        TBR_PLAN,
        TBR_REL_CODE,
        TBR_REL_DESC
    )
        ( SELECT
            NEW_CLIENT,
            TBR_PLAN,
            TBR_REL_CODE,
            TBR_REL_DESC
          FROM
            OLIVER.TBL_BENEFIC_RELATION
          WHERE
            TBR_CLIENT = OLD_CLIENT
        );

    INSERT INTO OLIVER.TBL_BENEFIT_LIMIT (
        TBL_CLIENT,
        TBL_PLAN,
        TBL_FFF_DATE,
        TBL_STATUS,
        TBL_PERIOD,
        TBL_AMT,
        TBL_BENEFIT
    )
        ( SELECT
            NEW_CLIENT,
            TBL_PLAN,
            TBL_FFF_DATE,
            TBL_STATUS,
            TBL_PERIOD,
            TBL_AMT,
            TBL_BENEFIT
          FROM
            OLIVER.TBL_BENEFIT_LIMIT
          WHERE
            TBL_CLIENT = OLD_CLIENT
        );

    INSERT INTO OLIVER.TBL_BENEFITS (
        BEN_PLAN,
        BEN_ID,
        BEN_VOLUME,
        BEN_NMAX,
        BEN_ADMIN_RATE,
        BEN_RATE,
        BEN_UNIT,
        BEN_EFF_DATE,
        BEN_CARRIER,
        BEN_POLICT_NO,
        BEN_CLIENT
    )
        ( SELECT
            BEN_PLAN,
            BEN_ID,
            BEN_VOLUME,
            BEN_NMAX,
            BEN_ADMIN_RATE,
            BEN_RATE,
            BEN_UNIT,
            BEN_EFF_DATE,
            BEN_CARRIER,
            BEN_POLICT_NO,
            NEW_CLIENT
          FROM
            OLIVER.TBL_BENEFITS
          WHERE
            BEN_CLIENT = OLD_CLIENT
        );
--

--OLIVER.TBL_BENEFITS_CLASS

    INSERT INTO OLIVER.TBL_BENEFITS_CLASS (
        BC_ID,
        BC_PLAN_ID,
        BC_CLIENT_ID,
        BC_DESC,
        BC_KEY,
        BC_WP,
        DATE_CREATED,
        CREATED_BY
    )
        ( SELECT
            BC_ID,
            BC_PLAN_ID,
            NEW_CLIENT,
            BC_DESC,
            ( (
                SELECT
                    MAX(BC_KEY)
                FROM
                    TBL_BENEFITS_CLASS
            ) + ROWNUM ),
            BC_WP,
            DATE_CREATED,
            CREATED_BY
          FROM
            OLIVER.TBL_BENEFITS_CLASS
          WHERE
            BC_CLIENT_ID = OLD_CLIENT
        );

--OLIVER.TBL_BENEFITS_MASTER 

    INSERT INTO OLIVER.TBL_BENEFITS_MASTER (
        BM_CODE,
        BM_DESC,
        BM_PLAN,
        BM_EFF_DATE,
        BM_CLIENT_ID,
        BM_BEN_TYPE,
        BM_TERM_DATE,
        BM_COVERAGE_TYPE,
        BM_ID,
        BM_CARRIER,
        BM_POLICY,
        BM_BEN_GROUP
    )
        ( SELECT
            BM_CODE,
            BM_DESC,
            BM_PLAN,
            BM_EFF_DATE,
            NEW_CLIENT,
            BM_BEN_TYPE,
            BM_TERM_DATE,
            BM_COVERAGE_TYPE,
            BM_ID,
            BM_CARRIER,
            BM_POLICY,
            BM_BEN_GROUP
          FROM
            OLIVER.TBL_BENEFITS_MASTER
          WHERE
            BM_CLIENT_ID = OLD_CLIENT
        );

    INSERT INTO OLIVER.TBL_CARRIER (
        TC_CLIENT,
        TC_PLAN,
        TC_CARRIER_ID,
        TC_CARRIER_NAME,
        TC_EFF_DATE,
        TC_TERM_DATE,
        TC_ADDRESS1,
        TC_ADDESS2,
        TC_CITY,
        TC_PROV,
        TC_POSTAL_CODE,
        TC_TELEPHONE1,
        TC_TELEPHONE2,
        TC_EMAIL,
        TC_FAX
    )
        ( SELECT
            OLD_CLIENT,
            TC_PLAN,
            TC_CARRIER_ID,
            TC_CARRIER_NAME,
            TC_EFF_DATE,
            TC_TERM_DATE,
            TC_ADDRESS1,
            TC_ADDESS2,
            TC_CITY,
            TC_PROV,
            TC_POSTAL_CODE,
            TC_TELEPHONE1,
            TC_TELEPHONE2,
            TC_EMAIL,
            TC_FAX
          FROM
            OLIVER.TBL_CARRIER
          WHERE
            TC_CLIENT = OLD_CLIENT
        );

    INSERT INTO OLIVER.TBL_CALENDAR (
        ID,
        EVENT,
        NOTE,
        EVENTDATE,
        USERID,
        PLAN_ID,
        CLIENT_ID,
        DATECREATED,
        DATEMODIFIED,
        MODIFIEDBY,
        ISDELETED,
        STATUS
    )
        ( SELECT
            ID,
            EVENT,
            NOTE,
            EVENTDATE,
            USERID,
            PLAN_ID,
            NEW_CLIENT,
            DATECREATED,
            DATEMODIFIED,
            MODIFIEDBY,
            ISDELETED,
            STATUS
          FROM
            OLIVER.TBL_CALENDAR
          WHERE
            CLIENT_ID = OLD_CLIENT
        );
------

    INSERT INTO OLIVER.TBL_BENEFIT_COVERAGE_STATUS (
        BDS_PL_ID,
        BDS_MEM_ID,
        BDS_BENEFIT,
        BDS_COVERAGE,
        BDS_EFF_DATE,
        BDS_TERM_DATE,
        BDS_CLIENT_ID,
        BDS_COUPLE_DEP_NO
    )
        ( SELECT
            BDS_PL_ID,
            BDS_MEM_ID,
            BDS_BENEFIT,
            BDS_COVERAGE,
            BDS_EFF_DATE,
            BDS_TERM_DATE,
            NEW_CLIENT,
            BDS_COUPLE_DEP_NO
          FROM
            OLIVER.TBL_BENEFIT_COVERAGE_STATUS
          WHERE
            BDS_CLIENT_ID = OLD_CLIENT
        );

    INSERT INTO OLIVER.TBL_CLAIM_FILE (
        PLAN_ID,
        CLIENT_ID,
        MEM_ID,
        OUTPUT_BLOB,
        FILENAME,
        MIME_TYPE,
        CREATE_DATE,
        CREATE_BY,
        CLAIM_ID
    )
        ( SELECT
            PLAN_ID,
            NEW_CLIENT,
            MEM_ID,
            OUTPUT_BLOB,
            FILENAME,
            MIME_TYPE,
            CREATE_DATE,
            CREATE_BY,
            CLAIM_ID
          FROM
            OLIVER.TBL_CLAIM_FILE
          WHERE
            CLIENT_ID = OLD_CLIENT
        );
-------

    INSERT INTO TBL_CLAIM_COMMENTS (
        TCC_PLAN,
        TCC_CLAIM,
        TCC_SERVICE_ID,
        TCC_COMMENT,
        TCC_CLIENT
    )
        ( SELECT
            TCC_PLAN,
            TCC_CLAIM,
            TCC_SERVICE_ID,
            TCC_COMMENT,
            NEW_CLIENT
          FROM
            TBL_CLAIM_COMMENTS
          WHERE
            TCC_CLIENT = OLD_CLIENT
        );    
------
-------------

    INSERT INTO TBL_CLIENTS (
        CLIENT_ID,
        CLIENT_NAME,
        CLIENT_SU,
        CLIENT_CONTACT,
        CLIENT_ADDRESS,
        CLIENT_CITY,
        CLIENT_PROV,
        CLIENT_POSTAL_CODE,
        CLIENT_COUNTRY,
        CLIENT_PHONE,
        CLIENT_EMAIL,
        CLIENT_EFF_DATE,
        CLIENT_TERM_DATE
    )
        ( SELECT
            NEW_CLIENT,
            NEW_CLIENT,
            CLIENT_SU,
            CLIENT_CONTACT,
            CLIENT_ADDRESS,
            CLIENT_CITY,
            CLIENT_PROV,
            CLIENT_POSTAL_CODE,
            CLIENT_COUNTRY,
            CLIENT_PHONE,
            CLIENT_EMAIL,
            CLIENT_EFF_DATE,
            CLIENT_TERM_DATE
          FROM
            TBL_CLIENTS
          WHERE
            CLIENT_ID = OLD_CLIENT
        );
-------------

    INSERT INTO OLIVER.TBL_CLAIMS (
        CL_PLAN,
        CL_ID,
        CL_DEP_NO,
        CL_CLAIM_NUMBER,
        CL_CLAIM_TYPE,
        CL_AMT_CLAIMED,
        CL_AMT_PAID,
        CL_USER,
        CL_DATE_RECD,
        CL_DATE_PAID,
        CL_PAYMENT_NUMBER,
        CL_BEN_CODE,
        CL_SERVICE_DATE,
        CL_COMMENT,
        CL_STATUS,
        CL_SERVICE_ID,
        CL_PAYMENT_TYPE,
        CL_SELECTED,
        CL_KEY,
        CL_OTHER_INS_AMT,
        CL_TRAN_DATE,
        CL_CLIENT_ID,
        CL_REJECTED
    )
        ( SELECT
            CL_PLAN,
            CL_ID,
            CL_DEP_NO,
            CL_CLAIM_NUMBER,
            CL_CLAIM_TYPE,
            CL_AMT_CLAIMED,
            CL_AMT_PAID,
            CL_USER,
            CL_DATE_RECD,
            CL_DATE_PAID,
            CL_PAYMENT_NUMBER,
            CL_BEN_CODE,
            CL_SERVICE_DATE,
            CL_COMMENT,
            CL_STATUS,
            CL_SERVICE_ID,
            CL_PAYMENT_TYPE,
            CL_SELECTED,
            CL_KEY,
            CL_OTHER_INS_AMT,
            CL_TRAN_DATE,
            NEW_CLIENT,
            CL_REJECTED
          FROM
            OLIVER.TBL_CLAIMS
          WHERE
            CL_CLIENT_ID = OLD_CLIENT
        );

   
--OLIVER.TBL_COMPHW

    INSERT INTO OLIVER.TBL_COMPHW (
        CH_NUMBER,
        CH_DIV,
        CH_CONTACT,
        CH_ADDRESS1,
        CH_ADDRESS2,
        CH_CITY,
        CH_PROV,
        CH_COUNTRY,
        CH_PHONE1,
        CH_PHONE2,
        CH_FAX,
        CH_EMAIL1,
        CH_EMAIL2,
        CH_LANG_PREF,
        CH_PLAN,
        CH_LAST_MODIFIED_BY,
        CH_LAST_MODIFIED_DATE,
        CH_OS_BAL,
        CH_EFF_DATE,
        CH_TERM_DATE,
        CH_CLIENT_ID,
        CH_POSTAL_CODE,
        CH_LRD
    )
        ( SELECT
            CH_NUMBER,
            CH_DIV,
            CH_CONTACT,
            CH_ADDRESS1,
            CH_ADDRESS2,
            CH_CITY,
            CH_PROV,
            CH_COUNTRY,
            CH_PHONE1,
            CH_PHONE2,
            CH_FAX,
            CH_EMAIL1,
            CH_EMAIL2,
            CH_LANG_PREF,
            CH_PLAN,
            CH_LAST_MODIFIED_BY,
            CH_LAST_MODIFIED_DATE,
            CH_OS_BAL,
            CH_EFF_DATE,
            CH_TERM_DATE,
            NEW_CLIENT,
            CH_POSTAL_CODE,
            CH_LRD
          FROM
            OLIVER.TBL_COMPHW
          WHERE
            CH_CLIENT_ID = OLD_CLIENT
        );
-- TBL_MEMBER

    INSERT INTO OLIVER.TBL_MEMBER (
        MEM_ID,
        MEM_SIN,
        MEM_FIRST_NAME,
        MEM_MIDDLE_NAME,
        MEM_LAST_NAME,
        MEM_GENDER,
        MEM_DOB,
        MEM_ADDRESS1,
        MEM_ADDRESS2,
        MEM_CITY,
        MEM_PROV,
        MEM_COUNTRY,
        MEM_POSTAL_CODE,
        MEM_EMAIL,
        MEM_HOME_PHONE,
        MEM_WORK_PHONE,
        MEM_CELL_PHONE,
        MEM_FAX,
        MEM_LANG_PREF,
        MEM_LAST_MODIFIED_BY,
        MEM_LAST_MODIFIED_DATE,
        MEM_PLAN,
        MEM_ATTACHMENT,
        MEM_FILE_NAME,
        MEM_MIME_TYPE,
        MEM_DOD,
        MEM_TITLE,
        MEM_CREATED_BY,
        MEM_CREATED_DATE,
        MEM_CLIENT_ID
    )
        ( SELECT
            MEM_ID,
            MEM_SIN,
            MEM_FIRST_NAME,
            MEM_MIDDLE_NAME,
            MEM_LAST_NAME,
            MEM_GENDER,
            MEM_DOB,
            MEM_ADDRESS1,
            MEM_ADDRESS2,
            MEM_CITY,
            MEM_PROV,
            MEM_COUNTRY,
            MEM_POSTAL_CODE,
            MEM_EMAIL,
            MEM_HOME_PHONE,
            MEM_WORK_PHONE,
            MEM_CELL_PHONE,
            MEM_FAX,
            MEM_LANG_PREF,
            MEM_LAST_MODIFIED_BY,
            MEM_LAST_MODIFIED_DATE,
            MEM_PLAN,
            MEM_ATTACHMENT,
            MEM_FILE_NAME,
            MEM_MIME_TYPE,
            MEM_DOD,
            MEM_TITLE,
            MEM_CREATED_BY,
            MEM_CREATED_DATE,
            NEW_CLIENT
          FROM
            OLIVER.TBL_MEMBER
          WHERE
            MEM_CLIENT_ID = OLD_CLIENT
        );
--Data loads for TBL_COMPMAST

    INSERT INTO OLIVER.TBL_COMPMAST (
        CO_NUMBER,
        CO_DIV,
        CO_NAME,
        CO_PLAN,
        CO_LAST_MODIFIED_BY,
        CO_LAST_MODIFIED_DATE,
        CO_ATTACHMENT,
        CO_FILE_NAME,
        CO_MIME_TYPE,
        CO_CLIENT,
        CO_TYPE,
        CO_CREATED_DATE,
        CO_CREATED_BY,
        CO_EDITED_DATE,
        CO_EDITED_BY
    )
        ( SELECT
            CO_NUMBER,
            CO_DIV,
            CO_NAME,
            CO_PLAN,
            CO_LAST_MODIFIED_BY,
            CO_LAST_MODIFIED_DATE,
            CO_ATTACHMENT,
            CO_FILE_NAME,
            CO_MIME_TYPE,
            NEW_CLIENT,
            CO_TYPE,
            CO_CREATED_DATE,
            CO_CREATED_BY,
            CO_EDITED_DATE,
            CO_EDITED_BY
          FROM
            OLIVER.TBL_COMPMAST
          WHERE
            CO_CLIENT = OLD_CLIENT
        );
--Data loads for TBL_HW

    INSERT INTO OLIVER.TBL_HW (
        HW_PLAN,
        HW_ID,
        HW_EFF_DATE,
        HW_TERM_DATE,
        HW_COVERAGE,
        HW_EMPLOYER,
        HW_DIV,
        HW_BILLING_CODE,
        HW_TERM_CODE,
        HW_APP_RECD,
        HW_LAST_MODIFIED_DATE,
        HW_LAST_MODIFIED_BY,
        HW_LOCAL,
        HW_LOCAL_EFF_DATE,
        HW_RECIPROCAL,
        HW_RECIPROCAL_DATE,
        HW_SUSPENED,
        HW_SUSP_DATE,
        HW_SUSP_REASON,
        HW_CLASS,
        HW_STATUS,
        HW_MEM_CATEGORY,
        HW_SUB_PLAN,
        HW_SUBSIDIZED,
        HW_LATE_APP,
        HW_LATE_EFF_DATE,
        HW_LATE_TERM_DATE,
        HW_CLIENT,
        HW_SMOKER,
        HW_EE_TYPE,
        HW_COUPLE_DEP_NO,
        HW_VISION_ELIGIBLE,
        HW_SPOUSAL_SMOKER,
        HW_DEP_STATUS,
        HW_SMOKER_EFF_DATE,
        HW_SP_SMOKER_EFF_DATE,
        HW_DEP_STATUS_EFF_DATE,
        HW_CLASS_EFF_DATE
    )
        ( SELECT
            HW_PLAN,
            HW_ID,
            HW_EFF_DATE,
            HW_TERM_DATE,
            HW_COVERAGE,
            HW_EMPLOYER,
            HW_DIV,
            HW_BILLING_CODE,
            HW_TERM_CODE,
            HW_APP_RECD,
            HW_LAST_MODIFIED_DATE,
            HW_LAST_MODIFIED_BY,
            HW_LOCAL,
            HW_LOCAL_EFF_DATE,
            HW_RECIPROCAL,
            HW_RECIPROCAL_DATE,
            HW_SUSPENED,
            HW_SUSP_DATE,
            HW_SUSP_REASON,
            HW_CLASS,
            HW_STATUS,
            HW_MEM_CATEGORY,
            HW_SUB_PLAN,
            HW_SUBSIDIZED,
            HW_LATE_APP,
            HW_LATE_EFF_DATE,
            HW_LATE_TERM_DATE,
            NEW_CLIENT,
            HW_SMOKER,
            HW_EE_TYPE,
            HW_COUPLE_DEP_NO,
            HW_VISION_ELIGIBLE,
            HW_SPOUSAL_SMOKER,
            HW_DEP_STATUS,
            HW_SMOKER_EFF_DATE,
            HW_SP_SMOKER_EFF_DATE,
            HW_DEP_STATUS_EFF_DATE,
            HW_CLASS_EFF_DATE
          FROM
            OLIVER.TBL_HW
          WHERE
            HW_CLIENT = OLD_CLIENT
        );
        
--OLIVER.TBL_COMPPEN

    INSERT INTO OLIVER.TBL_COMPPEN (
        CP_NUMBER,
        CP_DIV,
        CP_CONTACT,
        CP_ADDRESS1,
        CP_ADDRESS2,
        CP_CITY,
        CP_PROV,
        CP_COUNTRY,
        CP_PHONE1,
        CP_PHONE2,
        CP_FAX,
        CP_EMAIL1,
        CP_EMAIL2,
        CP_LANG_PREF,
        CP_PLAN,
        CP_LAST_MODIFIED_BY,
        CP_LAST_MODIFIED_DATE,
        CP_OS_BAL,
        CP_EFF_DATE,
        CP_TERM_DATE,
        CP_LRD,
        CP_WORK_PROV,
        CP_CLIENT,
        CP_CREATED_DATE,
        CP_CREATED_BY,
        CP_POST_CODE
    )
        ( SELECT
            CP_NUMBER,
            CP_DIV,
            CP_CONTACT,
            CP_ADDRESS1,
            CP_ADDRESS2,
            CP_CITY,
            CP_PROV,
            CP_COUNTRY,
            CP_PHONE1,
            CP_PHONE2,
            CP_FAX,
            CP_EMAIL1,
            CP_EMAIL2,
            CP_LANG_PREF,
            CP_PLAN,
            CP_LAST_MODIFIED_BY,
            CP_LAST_MODIFIED_DATE,
            CP_OS_BAL,
            CP_EFF_DATE,
            CP_TERM_DATE,
            CP_LRD,
            CP_WORK_PROV,
            NEW_CLIENT,
            CP_CREATED_DATE,
            CP_CREATED_BY,
            CP_POST_CODE
          FROM
            OLIVER.TBL_COMPPEN
          WHERE
            CP_CLIENT = OLD_CLIENT
        );

--OLIVER.TBL_DATAREFRESH 

    INSERT INTO OLIVER.TBL_DATAREFRESH (
        CLIENT_ID,
        PLAN_ID,
        REFRESHDATE
    )
        ( SELECT
            NEW_CLIENT,
            PLAN_ID,
            REFRESHDATE
          FROM
            OLIVER.TBL_DATAREFRESH
          WHERE
            CLIENT_ID = OLD_CLIENT
        );       
        
--OLIVER.TBL_DISABILITY

    INSERT INTO OLIVER.TBL_DISABILITY (
        DIS_PLAN,
        DIS_ID,
        DIS_TYPE,
        DIS_START_DATE,
        DIS_RECOVERY_DATE,
        DIS_COMMENT,
        DIS_CLIENT
    )
        ( SELECT
            DIS_PLAN,
            DIS_ID,
            DIS_TYPE,
            DIS_START_DATE,
            DIS_RECOVERY_DATE,
            DIS_COMMENT,
            NEW_CLIENT
          FROM
            OLIVER.TBL_DISABILITY
          WHERE
            DIS_CLIENT = OLD_CLIENT
        );

--LIVER.TBL_DOCUMENT 

    INSERT INTO OLIVER.TBL_DOCUMENT (
        DOC_KEY,
        DOC_NAME,
        DOC_DESC,
        DOC_ATTACHMENT,
        DOC_FILE_NAME,
        DOC_MIME_TYPE,
        DOC_PLAN,
        DOC_MEM_ID,
        DOC_ER_ID,
        DOC_CLIENT_ID,
        DOC_TYPE
    )
        ( SELECT
            DOC_KEY,
            DOC_NAME,
            DOC_DESC,
            DOC_ATTACHMENT,
            DOC_FILE_NAME,
            DOC_MIME_TYPE,
            DOC_PLAN,
            DOC_MEM_ID,
            DOC_ER_ID,
            NEW_CLIENT,
            DOC_TYPE
          FROM
            OLIVER.TBL_DOCUMENT
          WHERE
            DOC_CLIENT_ID = OLD_CLIENT
        );
    
--OLIVER.TBL_DOCUMENT_SEARCH

    INSERT INTO OLIVER.TBL_DOCUMENT_SEARCH (
        SEARCHTERM,
        PLANID,
        CLIENTID
    )
        ( SELECT
            SEARCHTERM,
            PLANID,
            NEW_CLIENT
          FROM
            OLIVER.TBL_DOCUMENT_SEARCH
          WHERE
            CLIENTID = OLD_CLIENT
        );
 
--LIVER.TBL_EMPLOYER_AGREEMENTS

    INSERT INTO OLIVER.TBL_EMPLOYER_AGREEMENTS (
        TEA_CLT_ID,
        TEA_PLAN_ID,
        TEA_ER_ID,
        TEA_AGREEMENT_ID,
        TEA_EFF_DATE,
        TEA_TERM_DATE,
        TEA_CREATED_BY,
        TEA_CREATED_DATE,
        TEA_ID,
        IS_DELETED
    )
        ( SELECT
            NEW_CLIENT,
            TEA_PLAN_ID,
            TEA_ER_ID,
            TEA_AGREEMENT_ID,
            TEA_EFF_DATE,
            TEA_TERM_DATE,
            TEA_CREATED_BY,
            TEA_CREATED_DATE,
            TEA_ID,
            IS_DELETED
          FROM
            OLIVER.TBL_EMPLOYER_AGREEMENTS
          WHERE
            TEA_CLT_ID = OLD_CLIENT
        );
    
--OLIVER.TBL_EMPLOYER_CLASSES

    INSERT INTO OLIVER.TBL_EMPLOYER_CLASSES (
        TEC_CLIENT_ID,
        TEC_PLAN_ID,
        TEC_ER_ID,
        TEC_CLASS,
        TEC_EFF_DATE,
        TEC_TERM_DATE,
        TEC_CREATE_DATE,
        TEC_CREATED_BY,
        TEC_CLASS_KEY
    )
        ( SELECT
            NEW_CLIENT,
            TEC_PLAN_ID,
            TEC_ER_ID,
            TEC_CLASS,
            TEC_EFF_DATE,
            TEC_TERM_DATE,
            TEC_CREATE_DATE,
            TEC_CREATED_BY,
            TEC_CLASS_KEY
          FROM
            OLIVER.TBL_EMPLOYER_CLASSES
          WHERE
            TEC_CLIENT_ID = OLD_CLIENT
        );
    
--LIVER.TBL_EMPLOYER_CONTACTS

    INSERT INTO OLIVER.TBL_EMPLOYER_CONTACTS (
        TEC_ID,
        TEC_DIV,
        TEC_LOC,
        TEC_CONTACT,
        TEC_ADDRESS1,
        TEC_ADDRESS2,
        TEC_CITY,
        TEC_POST_CODE,
        TEC_COUNTRY,
        TEC_PHONE1,
        TEC_PHONE2,
        TEC_EMAIL1,
        TEC_EMAIL2,
        TEC_FAX,
        TEC_PRIMARY,
        TEC_NOTE,
        TEC_PROV,
        TEC_LAST_MODIFIED_BY,
        TEC_LAST_MODIFIED_DATE,
        TEC_PLAN,
        TEC_EFFECTIVE_DATE,
        TEC_TERM_DATE,
        TEC_KEY,
        TEC_CLIENT,
        TEC_TITLE
    )
        ( SELECT
            TEC_ID,
            TEC_DIV,
            TEC_LOC,
            TEC_CONTACT,
            TEC_ADDRESS1,
            TEC_ADDRESS2,
            TEC_CITY,
            TEC_POST_CODE,
            TEC_COUNTRY,
            TEC_PHONE1,
            TEC_PHONE2,
            TEC_EMAIL1,
            TEC_EMAIL2,
            TEC_FAX,
            TEC_PRIMARY,
            TEC_NOTE,
            TEC_PROV,
            TEC_LAST_MODIFIED_BY,
            TEC_LAST_MODIFIED_DATE,
            TEC_PLAN,
            TEC_EFFECTIVE_DATE,
            TEC_TERM_DATE,
            TEC_KEY,
            NEW_CLIENT,
            TEC_TITLE
          FROM
            OLIVER.TBL_EMPLOYER_CONTACTS
          WHERE
            TEC_CLIENT = OLD_CLIENT
        );

    INSERT INTO OLIVER.TBL_EMPLOYER_FUND_RATES (
        PFR_CLIENT_ID,
        PFR_PLAN_ID,
        PFR_EMPLOYER,
        PFR_FUND_ID,
        PFR_EFF_DATE,
        PFR_RATE,
        PFR_CLIENT
    )
        ( SELECT
            PFR_CLIENT_ID,
            PFR_PLAN_ID,
            PFR_EMPLOYER,
            PFR_FUND_ID,
            PFR_EFF_DATE,
            PFR_RATE,
            NEW_CLIENT
          FROM
            OLIVER.TBL_EMPLOYER_FUND_RATES
          WHERE
            PFR_CLIENT = OLD_CLIENT
        );

    INSERT INTO OLIVER.TBL_EMPLOYER_INVOICES_HW (
        EIH_CLIENT_ID,
        EIH_PLAN_ID,
        EIH_ER_ID,
        EIH_MTH,
        EIH_LIFE_EE,
        EIH_LIFE_ER,
        EIH_ADD_EE,
        EIH_ADD_ER,
        EIH_OL_EE,
        EIH_OL_ER,
        EIH_DL_EE,
        EIH_DL_ER,
        EIH_LTD_EE,
        EIH_LTD_ER,
        EIH_WI_EE,
        EIH_WI_ER,
        EIH_EH_EE,
        EIH_EH_ER,
        EIH_DENT_EE,
        EIH_DENT_ER,
        EIH_OPEN_BAL,
        EIH_PAYMENTS,
        EIH_MISC,
        EIH_ADJ,
        EIH_CURR,
        EIH_CLOSE_BAL,
        EIH_INVOICE_NUM,
        EIH_DESCRIPTION,
        EIH_PAID_DATE,
        EIH_CHEQ_NO
    )
        ( SELECT
            NEW_CLIENT,
            EIH_PLAN_ID,
            EIH_ER_ID,
            EIH_MTH,
            EIH_LIFE_EE,
            EIH_LIFE_ER,
            EIH_ADD_EE,
            EIH_ADD_ER,
            EIH_OL_EE,
            EIH_OL_ER,
            EIH_DL_EE,
            EIH_DL_ER,
            EIH_LTD_EE,
            EIH_LTD_ER,
            EIH_WI_EE,
            EIH_WI_ER,
            EIH_EH_EE,
            EIH_EH_ER,
            EIH_DENT_EE,
            EIH_DENT_ER,
            EIH_OPEN_BAL,
            EIH_PAYMENTS,
            EIH_MISC,
            EIH_ADJ,
            EIH_CURR,
            EIH_CLOSE_BAL,
            EIH_INVOICE_NUM,
            EIH_DESCRIPTION,
            EIH_PAID_DATE,
            EIH_CHEQ_NO
          FROM
            OLIVER.TBL_EMPLOYER_INVOICES_HW
          WHERE
            EIH_CLIENT_ID = OLD_CLIENT
        );    
--OLIVER.TBL_EMPLOYER_NOTES 

    INSERT INTO OLIVER.TBL_EMPLOYER_NOTES (
        EN_KEY,
        EN_ID,
        EN_DATE,
        EN_LAST_MODIFIED_BY,
        EN_LAST_MODIFIED_DATE,
        EN_NOTE,
        EN_PLAN_ID,
        EN_TYPE,
        TEN_CLIENT
    )
        ( SELECT
            EN_KEY,
            EN_ID,
            EN_DATE,
            EN_LAST_MODIFIED_BY,
            EN_LAST_MODIFIED_DATE,
            EN_NOTE,
            EN_PLAN_ID,
            EN_TYPE,
            NEW_CLIENT
          FROM
            OLIVER.TBL_EMPLOYER_NOTES
          WHERE
            TEN_CLIENT = OLD_CLIENT
        );
 
--OLIVER.TBL_EMPLOYMENT_HIST

    INSERT INTO OLIVER.TBL_EMPLOYMENT_HIST (
        TEH_ID,
        TEH_ER_ID,
        TEH_EFF_DATE,
        TEH_TREM_DATE,
        TEH_SALARY,
        TEH_PROCESS_DATE,
        TEH_LAST_MODIFIED_BY,
        TEH_LAST_MODIFIED_DATE,
        TEH_OCCU,
        TEH_EMPLOYMENT_TYPE,
        TEH_PLAN,
        TEH_CLIENT,
        TEH_UNION_LOCAL,
        TEH_AGREE_ID,
        TEH_HIRE_DATE
    )
        ( SELECT
            TEH_ID,
            TEH_ER_ID,
            TEH_EFF_DATE,
            TEH_TREM_DATE,
            TEH_SALARY,
            TEH_PROCESS_DATE,
            TEH_LAST_MODIFIED_BY,
            TEH_LAST_MODIFIED_DATE,
            TEH_OCCU,
            TEH_EMPLOYMENT_TYPE,
            TEH_PLAN,
            NEW_CLIENT,
            TEH_UNION_LOCAL,
            TEH_AGREE_ID,
            TEH_HIRE_DATE
          FROM
            OLIVER.TBL_EMPLOYMENT_HIST
          WHERE
            TEH_CLIENT = OLD_CLIENT
        );
------------------

    INSERT INTO TBL_EMPLOYMENT_TYPES (
        TET_CLIENT,
        TET_PLAN,
        TET_CODE,
        TET_DESC,
        TET_EFF_DATE,
        TET_TERM_DATE
    )
        ( SELECT
            NEW_CLIENT,
            TET_PLAN,
            TET_CODE,
            TET_DESC,
            TET_EFF_DATE,
            TET_TERM_DATE
          FROM
            TBL_EMPLOYMENT_TYPES
          WHERE
            TET_CLIENT = OLD_CLIENT
        );
------------
----------

    INSERT INTO OLIVER.TBL_ER_RATES (
        TER_ID,
        TER_PLAN,
        TER_EFF_DATE,
        TER_RATE,
        TER_EE_RATE,
        TER_HW_RATE,
        TER_CLIENT
    )
        ( SELECT
            TER_ID,
            TER_PLAN,
            TER_EFF_DATE,
            TER_RATE,
            TER_EE_RATE,
            TER_HW_RATE,
            NEW_CLIENT
          FROM
            OLIVER.TBL_ER_RATES
          WHERE
            TER_CLIENT = OLD_CLIENT
        );

----------
-------------

    INSERT INTO TBL_ER_RATES_HW (
        TER_ID,
        TER_PLAN,
        TER_EFF_DATE,
        TER_RATE,
        TER_EE_RATE,
        TER_HW_RATE,
        TER_CLIENT
    )
        ( SELECT
            TER_ID,
            TER_PLAN,
            TER_EFF_DATE,
            TER_RATE,
            TER_EE_RATE,
            TER_HW_RATE,
            NEW_CLIENT
          FROM
            TBL_ER_RATES_HW
          WHERE
            TER_CLIENT = OLD_CLIENT
        );
-----------------

    INSERT INTO OLIVER.TBL_FUNDS (
        FUND_ID,
        FUND_NAME,
        FUND_TAXABLE,
        FUND_EFFECT_DATE,
        FUND_TERM_DATE,
        FUND_DESC,
        FUND_CLIENT,
        FUND_PLAN
    )
        ( SELECT
            FUND_ID,
            FUND_NAME,
            FUND_TAXABLE,
            FUND_EFFECT_DATE,
            FUND_TERM_DATE,
            FUND_DESC,
            NEW_CLIENT,
            FUND_PLAN
          FROM
            OLIVER.TBL_FUNDS
          WHERE
            FUND_CLIENT = OLD_CLIENT
        );
-----------------

    INSERT INTO OLIVER.TBL_GRADUAL_RATES (
        TGR_ER_ID,
        TGR_CLIENT,
        TGR_PLAN,
        TGR_CLASS,
        TGR_MTHS,
        TGR_EFF_DATE,
        TGR_ER_RRATE,
        TGR_EE_RATE
    )
        ( SELECT
            TGR_ER_ID,
            NEW_CLIENT,
            TGR_PLAN,
            TGR_CLASS,
            TGR_MTHS,
            TGR_EFF_DATE,
            TGR_ER_RRATE,
            TGR_EE_RATE
          FROM
            OLIVER.TBL_GRADUAL_RATES
          WHERE
            TGR_CLIENT = OLD_CLIENT
        );
---------
--OLIVER.TBL_HR_BANK 

    INSERT INTO OLIVER.TBL_HR_BANK (
        THB_ID,
        THB_PLAN,
        THB_FROM_DATE,
        THB_TO_DATE,
        THB_MONTH,
        THB_HOURS,
        THB_DEDUCT_HRS,
        THB_CLOSING_HRS,
        THB_POSTED_DATE,
        THB_EMPLOYER,
        THB_MODIFIED_BY,
        THB_MODIFIED_DATE,
        THB_FUND_CODE,
        THB_CLIENT_ID
    )
        ( SELECT
            THB_ID,
            THB_PLAN,
            THB_FROM_DATE,
            THB_TO_DATE,
            THB_MONTH,
            THB_HOURS,
            THB_DEDUCT_HRS,
            THB_CLOSING_HRS,
            THB_POSTED_DATE,
            THB_EMPLOYER,
            THB_MODIFIED_BY,
            THB_MODIFIED_DATE,
            THB_FUND_CODE,
            NEW_CLIENT
          FROM
            OLIVER.TBL_HR_BANK
          WHERE
            THB_CLIENT_ID = OLD_CLIENT
        );
-------

    INSERT INTO OLIVER.TBL_HSA_ATTACHMENTS (
        ID,
        CLAIM_NUMBER,
        ATTACHMENT,
        DATE_CREATED,
        PLAN_ID,
        CLIENT_ID,
        MIME_TYPE,
        FILENAME,
        CL_KEY
    )
        ( SELECT
            ID,
            CLAIM_NUMBER,
            ATTACHMENT,
            DATE_CREATED,
            PLAN_ID,
            NEW_CLIENT,
            MIME_TYPE,
            FILENAME,
            CL_KEY
          FROM
            OLIVER.TBL_HSA_ATTACHMENTS
          WHERE
            CLIENT_ID = OLD_CLIENT
        );
-------
 
--OLIVER.TBL_HW_BENEFICIARY 

    INSERT INTO OLIVER.TBL_HW_BENEFICIARY (
        HB_PLAN,
        HB_ID,
        HB_BEN_NO,
        HB_LAST_NAME,
        HB_FIRST_NAME,
        HB_DOB,
        HB_RELATION,
        HB_BE_PER,
        HB_EFF_DATE,
        HB_TERM_DATE,
        HB_SEX,
        HB_LAST_MODIFIED_BY,
        HB_LAST_MODIFIED_DATE,
        HB_KEY,
        HB_BENEFIT,
        HB_CLIENT,
        HB_LATE_APPLICANT
    )
        ( SELECT
            HB_PLAN,
            HB_ID,
            HB_BEN_NO,
            HB_LAST_NAME,
            HB_FIRST_NAME,
            HB_DOB,
            HB_RELATION,
            HB_BE_PER,
            HB_EFF_DATE,
            HB_TERM_DATE,
            HB_SEX,
            HB_LAST_MODIFIED_BY,
            HB_LAST_MODIFIED_DATE,
            HB_KEY,
            HB_BENEFIT,
            NEW_CLIENT,
            HB_LATE_APPLICANT
          FROM
            OLIVER.TBL_HW_BENEFICIARY
          WHERE
            HB_CLIENT = OLD_CLIENT
        ); 
 
--OLIVER.TBL_HW_COMMENTS

    INSERT INTO OLIVER.TBL_HW_COMMENTS (
        THC_ID,
        THC_DEC,
        THC_PLAN,
        THC_BENEFIT,
        THC_CLAIM,
        THC_ISACTIVE,
        THC_CLIENT
    )
        ( SELECT
            THC_ID,
            THC_DEC,
            THC_PLAN,
            THC_BENEFIT,
            THC_CLAIM,
            THC_ISACTIVE,
            NEW_CLIENT
          FROM
            OLIVER.TBL_HW_COMMENTS
          WHERE
            THC_CLIENT = OLD_CLIENT
        );
 
-- OLIVER.TBL_HW_DEPENDANTS

    INSERT INTO OLIVER.TBL_HW_DEPENDANTS (
        HD_PLAN,
        HD_ID,
        HD_BEN_NO,
        HD_LAST_NAME,
        HD_FIRST_NAME,
        HD_DOB,
        HD_RELATION,
        HD_BE_PER,
        HD_EFF_DATE,
        HD_TERM_DATE,
        HD_SEX,
        HD_LAST_MODIFIED_BY,
        HD_LAST_MODIFIED_DATE,
        HD_KEY,
        HD_LATE_APP,
        HD_LATE_EFF_DATE,
        HD_LATE_TERM_DATE,
        HD_CLIENT
    )
        ( SELECT
            HD_PLAN,
            HD_ID,
            HD_BEN_NO,
            HD_LAST_NAME,
            HD_FIRST_NAME,
            HD_DOB,
            HD_RELATION,
            HD_BE_PER,
            HD_EFF_DATE,
            HD_TERM_DATE,
            HD_SEX,
            HD_LAST_MODIFIED_BY,
            HD_LAST_MODIFIED_DATE,
            HD_KEY,
            HD_LATE_APP,
            HD_LATE_EFF_DATE,
            HD_LATE_TERM_DATE,
            NEW_CLIENT
          FROM
            OLIVER.TBL_HW_DEPENDANTS
          WHERE
            HD_CLIENT = OLD_CLIENT
        );

--OLIVER.TBL_HW_HISTORY 

    INSERT INTO OLIVER.TBL_HW_HISTORY (
        HW_ID,
        HW_CLIENT_ID,
        HW_PLAN_ID,
        HW_SMK_EFF_DATE,
        HW_SP_SMK_EFF_DATE,
        HW_DEP_STAT_EFF_DATE,
        DATE_CREATED,
        CREATED_BY,
        HW_SMOKING_STATUS,
        HW_DEP_STATUS,
        HW_CLASS_EFF_DATE,
        HW_CLASS
    )
        ( SELECT
            HW_ID,
            NEW_CLIENT,
            HW_PLAN_ID,
            HW_SMK_EFF_DATE,
            HW_SP_SMK_EFF_DATE,
            HW_DEP_STAT_EFF_DATE,
            DATE_CREATED,
            CREATED_BY,
            HW_SMOKING_STATUS,
            HW_DEP_STATUS,
            HW_CLASS_EFF_DATE,
            HW_CLASS
          FROM
            OLIVER.TBL_HW_HISTORY
          WHERE
            HW_CLIENT_ID = OLD_CLIENT
        );
 
--OLIVER.TBL_HW_WAIVER

    INSERT INTO OLIVER.TBL_HW_WAIVER (
        THW_CLIENT,
        THW_PLAN,
        THW_MEM_ID,
        THW_BENEFIT,
        THW_START_DATE,
        THW_END_DATE,
        THW_WAIVER_COVERAGE,
        THW_RATE,
        THW_ADMIN_RATE,
        THW_AGENT_RATE,
        THW_BILL,
        THW_REASON
    )
        ( SELECT
            NEW_CLIENT,
            THW_PLAN,
            THW_MEM_ID,
            THW_BENEFIT,
            THW_START_DATE,
            THW_END_DATE,
            THW_WAIVER_COVERAGE,
            THW_RATE,
            THW_ADMIN_RATE,
            THW_AGENT_RATE,
            THW_BILL,
            THW_REASON
          FROM
            OLIVER.TBL_HW_WAIVER
          WHERE
            THW_CLIENT = OLD_CLIENT
        );
-------------

    INSERT INTO OLIVER.TBL_HW_WAIVER_TYPES (
        THWT_CLIENT,
        THWT_PLAN,
        THWT_CODE,
        THWT_DESC,
        THWT_EFF_DATE,
        THWT_TERM_DATE
    )
        ( SELECT
            NEW_CLIENT,
            THWT_PLAN,
            THWT_CODE,
            THWT_DESC,
            THWT_EFF_DATE,
            THWT_TERM_DATE
          FROM
            OLIVER.TBL_HW_WAIVER_TYPES
          WHERE
            THWT_CLIENT = OLD_CLIENT
        );
---------------

    INSERT INTO TBL_INVOICES (
        TI_CLIENT_ID,
        TI_PLAN_ID,
        TE_ER_ID,
        TI_EE_ID,
        TI_INVOICE_NUM,
        TI_DESC,
        TI_MTH,
        TI_BENEFIT,
        TI_BILL_AMT,
        TI_PAYMENT,
        TI_PAYMENT_NUM,
        TI_ADMIN,
        TI_AGENT,
        TI_MISC,
        TI_ADJ,
        TI_COMMENT,
        TI_CREATED_BY,
        TI_CREATED_DATE
    )
        ( SELECT
            NEW_CLIENT,
            TI_PLAN_ID,
            TE_ER_ID,
            TI_EE_ID,
            TI_INVOICE_NUM,
            TI_DESC,
            TI_MTH,
            TI_BENEFIT,
            TI_BILL_AMT,
            TI_PAYMENT,
            TI_PAYMENT_NUM,
            TI_ADMIN,
            TI_AGENT,
            TI_MISC,
            TI_ADJ,
            TI_COMMENT,
            TI_CREATED_BY,
            TI_CREATED_DATE
          FROM
            TBL_INVOICES
          WHERE
            TI_CLIENT_ID = OLD_CLIENT
        );
-----------

    INSERT INTO OLIVER.TBL_MARITAL_STATUS (
        TMS_CLIENT,
        TMS_PLAN,
        TMS_MEM_ID,
        TMS_EFF_DATE,
        TMS_TERM_DATE,
        TMS_BENEFIT,
        TMS_STATUS,
        TMS_CREATED_BY,
        TMS_CREATED_DATE,
        TMS_KEY,
        TMS_LAST_UPDATED_BY,
        TMS_LAST_UPDATED_DATE
    )
        ( SELECT
            NEW_CLIENT,
            TMS_PLAN,
            TMS_MEM_ID,
            TMS_EFF_DATE,
            TMS_TERM_DATE,
            TMS_BENEFIT,
            TMS_STATUS,
            TMS_CREATED_BY,
            TMS_CREATED_DATE,
            TMS_KEY,
            TMS_LAST_UPDATED_BY,
            TMS_LAST_UPDATED_DATE
          FROM
            OLIVER.TBL_MARITAL_STATUS
          WHERE
            TMS_CLIENT = OLD_CLIENT
        );
--OLIVER.TBL_MEM_FUNDS

    INSERT INTO OLIVER.TBL_MEM_FUNDS (
        TMF_ID,
        TMF_PLAN,
        TMF_UNITS,
        TMF_FUND,
        TMF_RATE,
        TMF_AMT,
        TMF_FROM,
        TMF_TO,
        TMF_PERIOD,
        TMF_ENTERED_DATE,
        TMF_EMPLOYER,
        TMF_USER,
        TMF_BATCH,
        TMF_DESC,
        TMF_CLIENT
    )
        ( SELECT
            TMF_ID,
            TMF_PLAN,
            TMF_UNITS,
            TMF_FUND,
            TMF_RATE,
            TMF_AMT,
            TMF_FROM,
            TMF_TO,
            TMF_PERIOD,
            TMF_ENTERED_DATE,
            TMF_EMPLOYER,
            TMF_USER,
            TMF_BATCH,
            TMF_DESC,
            NEW_CLIENT
          FROM
            OLIVER.TBL_MEM_FUNDS
          WHERE
            TMF_CLIENT = OLD_CLIENT
        );
 
--LIVER.TBL_MEM_UNITS

    INSERT INTO OLIVER.TBL_MEM_UNITS (
        MPU_ID,
        MPU_PLAN,
        MPU_UNITS,
        MPU_FUND,
        MPU_RATE,
        MPU_AMT,
        MPU_FROM,
        MPU_TO,
        MPU_PERIOD,
        MPU_ENTERED_DATE,
        MPU_EMPLOYER,
        MPU_USER,
        MU_BATCH,
        MU_DESC,
        MU_CLIENT,
        TRANS_TYPE,
        UNITS_TYPE,
        MU_EE_UNITS,
        MU_ER_UNITS,
        MU_VOL_UNITS,
        MU_RECD_DATE,
        MU_EE_ACCOUNT,
        MU_ER_ACCOUNT,
        MU_VOL_ACCOUNT
    )
        ( SELECT
            MPU_ID,
            MPU_PLAN,
            MPU_UNITS,
            MPU_FUND,
            MPU_RATE,
            MPU_AMT,
            MPU_FROM,
            MPU_TO,
            MPU_PERIOD,
            MPU_ENTERED_DATE,
            MPU_EMPLOYER,
            MPU_USER,
            MU_BATCH,
            MU_DESC,
            NEW_CLIENT,
            TRANS_TYPE,
            UNITS_TYPE,
            MU_EE_UNITS,
            MU_ER_UNITS,
            MU_VOL_UNITS,
            MU_RECD_DATE,
            MU_EE_ACCOUNT,
            MU_ER_ACCOUNT,
            MU_VOL_ACCOUNT
          FROM
            OLIVER.TBL_MEM_UNITS
          WHERE
            MU_CLIENT = OLD_CLIENT
        );
 
--OLIVER.TBL_MEM_VOL_BENEFITS 

    INSERT INTO OLIVER.TBL_MEM_VOL_BENEFITS (
        MVB_CLIENT,
        MVB_PLAN,
        MVB_ID,
        MVB_BENEFIT,
        MVB_VOLUME,
        MVB_EFFECTIVE_DATE,
        MVB_TERM_DATE,
        MVB_POST_DATE
    )
        ( SELECT
            NEW_CLIENT,
            MVB_PLAN,
            MVB_ID,
            MVB_BENEFIT,
            MVB_VOLUME,
            MVB_EFFECTIVE_DATE,
            MVB_TERM_DATE,
            MVB_POST_DATE
          FROM
            OLIVER.TBL_MEM_VOL_BENEFITS
          WHERE
            MVB_CLIENT = OLD_CLIENT
        );
 
--OLIVER.TBL_MEMBER_LOCATION

    INSERT INTO OLIVER.TBL_MEMBER_LOCATION (
        MEM_CLIENT_ID,
        MEM_PLAN,
        MEM_ID,
        MEM_FIRST_NAME,
        MEM_LAST_NAME,
        MEM_GENDER,
        MEM_DOB,
        MEM_ADDRESS1,
        MEM_CITY,
        MEM_PROV,
        MEM_COUNTRY,
        MEM_POSTAL_CODE,
        LAT,
        LNG,
        RSP
    )
        ( SELECT
            NEW_CLIENT,
            MEM_PLAN,
            MEM_ID,
            MEM_FIRST_NAME,
            MEM_LAST_NAME,
            MEM_GENDER,
            MEM_DOB,
            MEM_ADDRESS1,
            MEM_CITY,
            MEM_PROV,
            MEM_COUNTRY,
            MEM_POSTAL_CODE,
            LAT,
            LNG,
            RSP
          FROM
            OLIVER.TBL_MEMBER_LOCATION
          WHERE
            MEM_CLIENT_ID = OLD_CLIENT
        );
 
--OLIVER.TBL_MEMBER_NOTES

    INSERT INTO OLIVER.TBL_MEMBER_NOTES (
        MN_KEY,
        MN_ID,
        MN_DATE,
        MN_LAST_MODIFIED_BY,
        MN_LAST_MODIFIED_DATE,
        MN_NOTE,
        MN_PLAN_ID,
        MN_TYPE,
        TMN_CLIENT
    )
        ( SELECT
            MN_KEY,
            MN_ID,
            MN_DATE,
            MN_LAST_MODIFIED_BY,
            MN_LAST_MODIFIED_DATE,
            MN_NOTE,
            MN_PLAN_ID,
            MN_TYPE,
            NEW_CLIENT
          FROM
            OLIVER.TBL_MEMBER_NOTES
          WHERE
            TMN_CLIENT = OLD_CLIENT
        );
        
        INSERT INTO OLIVER.TBL_NETFUND_RETURN (
    TNR_CLIENT_ID,
    TNR_PLAN_ID,
    TNR_YEAR,
    TNR_RETURN_PERCENTAGE
) (SELECT
    NEW_CLIENT,
    TNR_PLAN_ID,
    TNR_YEAR,
    TNR_RETURN_PERCENTAGE
FROM
    OLIVER.TBL_NETFUND_RETURN WHERE TNR_CLIENT_ID=OLD_CLIENT);
 
--OLIVER.TBL_OCCUPATIONS

    INSERT INTO OLIVER.TBL_OCCUPATIONS (
        TO_CLIENT,
        TO_PLAN,
        TO_CODE,
        TO_DESC
    )
        ( SELECT
            NEW_CLIENT,
            TO_PLAN,
            TO_CODE,
            TO_DESC
          FROM
            OLIVER.TBL_OCCUPATIONS
          WHERE
            TO_CLIENT = OLD_CLIENT
        ); 
        
INSERT INTO OLIVER.TBL_OPTION_FACTORS_JS (
    OFJS_CLIENT,
    OFJS_PLAN,
    OFJS_TO_OPTION,
    OFJS_MEM_AGE,
    OFJS_SP_AGE,
    OFJS_FACTOR,
    OFJS_EFF_DATE,
    OFJS_TERM_DATE,
    OFJS_CREATED_DATE,
    OFJS_CREATED_BY,
    OFJS_FROM_OPTION
) (SELECT
    NEW_CLIENT,
    OFJS_PLAN,
    OFJS_TO_OPTION,
    OFJS_MEM_AGE,
    OFJS_SP_AGE,
    OFJS_FACTOR,
    OFJS_EFF_DATE,
    OFJS_TERM_DATE,
    OFJS_CREATED_DATE,
    OFJS_CREATED_BY,
    OFJS_FROM_OPTION
FROM
    OLIVER.TBL_OPTION_FACTORS_JS WHERE OFJS_CLIENT=OLD_CLIENT);

INSERT INTO OLIVER.TBL_OPTION_FACTORS_LO_G (
    OFLG_CLIENT,
    OFLG_PLAN,
    OFLG_TO_OPTION,
    OFLG_AGE,
    OFLG_FACTOR,
    OFLG_EFF_DATE,
    OFLG_TERM_DATE,
    OFLG_CREATED_DATE,
    OFLG_CREATED_BY,
    OFLG_FROM_OPTION
) (SELECT
    NEW_CLIENT,
    OFLG_PLAN,
    OFLG_TO_OPTION,
    OFLG_AGE,
    OFLG_FACTOR,
    OFLG_EFF_DATE,
    OFLG_TERM_DATE,
    OFLG_CREATED_DATE,
    OFLG_CREATED_BY,
    OFLG_FROM_OPTION
FROM
    OLIVER.TBL_OPTION_FACTORS_LO_G WHERE OFLG_CLIENT=OLD_CLIENT);
--OLIVER.TBL_PAST_UNITS

    INSERT INTO OLIVER.TBL_PAST_UNITS (
        TPU_ID,
        TPU_PLAN,
        TPU_UNITS,
        TPU_FUND,
        TPU_RATE,
        TPU_AMT,
        TPU_FROM,
        TPU_TO,
        TPU_PERIOD,
        TPU_ENTERED_DATE,
        TPU_EMPLOYER,
        TPU_USER,
        TPU_BATCH,
        TPU_DESC,
        TPU_CLIENT,
        TPU_TRANS_TYPE,
        TPU_UNITS_TYPE,
        TPU_EE_UNITS,
        TPU_ER_UNITS,
        TPU_VOL_UNITS,
        TPU_RECD_DATE
    )
        ( SELECT
            TPU_ID,
            TPU_PLAN,
            TPU_UNITS,
            TPU_FUND,
            TPU_RATE,
            TPU_AMT,
            TPU_FROM,
            TPU_TO,
            TPU_PERIOD,
            TPU_ENTERED_DATE,
            TPU_EMPLOYER,
            TPU_USER,
            TPU_BATCH,
            TPU_DESC,
            NEW_CLIENT,
            TPU_TRANS_TYPE,
            TPU_UNITS_TYPE,
            TPU_EE_UNITS,
            TPU_ER_UNITS,
            TPU_VOL_UNITS,
            TPU_RECD_DATE
          FROM
            OLIVER.TBL_PAST_UNITS
          WHERE
            TPU_CLIENT = OLD_CLIENT
        );
INSERT INTO OLIVER.TBL_PAYMENTS_RECD (
    TPR_CLIENT_ID,
    TPR_PLAN_ID,
    TPR_ER_ID,
    TPR_EE_ID,
    TPR_RECD_DATE,
    TPR_PAYMENT_TYPE,
    TPR_PAYMENT_NUMBER,
    TPR_PAYMENT_DATE,
    TPR_PAYMENT_AMT,
    TPR_COMMENT,
    TPR_USER
)( SELECT
    NEW_CLIENT,
    TPR_PLAN_ID,
    TPR_ER_ID,
    TPR_EE_ID,
    TPR_RECD_DATE,
    TPR_PAYMENT_TYPE,
    TPR_PAYMENT_NUMBER,
    TPR_PAYMENT_DATE,
    TPR_PAYMENT_AMT,
    TPR_COMMENT,
    TPR_USER
FROM
    OLIVER.TBL_PAYMENTS_RECD WHERE TPR_CLIENT_ID=OLD_CLIENT);
--OLIVER.TBL_PEN_BENEFICIARY

    INSERT INTO OLIVER.TBL_PEN_BENEFICIARY (
        PB_PLAN,
        PB_ID,
        PB_BEN_NO,
        PB_LAST_NAME,
        PB_FIRST_NAME,
        PB_DOB,
        PB_RELATION,
        PB_BE_PER,
        PB_EFF_DATE,
        PB_TERM_DATE,
        PB_SEX,
        PB_LAST_MODIFIED_BY,
        PB_LAST_MODIFIED_DATE,
        PB_KEY,
        PB_BENEFIT,
        PB_MPE,
        PB_WITHDRAW,
        PB_WITHDRAW_DATE,
        PB_ADDRESS1,
        PB_ADDESS2,
        PB_CITY,
        PB_PROV,
        PB_COUNTRY,
        PB_BEN_ID,
        PB_BEN_SIN,
        PB_CLIENT,
        PB_MIDDLE_NAME,
        PB_POSTAL_CODE
    )
        ( SELECT
            PB_PLAN,
            PB_ID,
            PB_BEN_NO,
            PB_LAST_NAME,
            PB_FIRST_NAME,
            PB_DOB,
            PB_RELATION,
            PB_BE_PER,
            PB_EFF_DATE,
            PB_TERM_DATE,
            PB_SEX,
            PB_LAST_MODIFIED_BY,
            PB_LAST_MODIFIED_DATE,
            PB_KEY,
            PB_BENEFIT,
            PB_MPE,
            PB_WITHDRAW,
            PB_WITHDRAW_DATE,
            PB_ADDRESS1,
            PB_ADDESS2,
            PB_CITY,
            PB_PROV,
            PB_COUNTRY,
            PB_BEN_ID,
            PB_BEN_SIN,
            NEW_CLIENT,
            PB_MIDDLE_NAME,
            PB_POSTAL_CODE
          FROM
            OLIVER.TBL_PEN_BENEFICIARY
          WHERE
            PB_CLIENT = OLD_CLIENT
        );

--OLIVER.TBL_PEN_EXIT_STAT_TRANS

    INSERT INTO OLIVER.TBL_PEN_EXIT_STAT_TRANS (
        PEST_ID,
        PEST_MEM_ID,
        PEST_STATUS,
        PEST_DATE_CREATED,
        PEST_PLAN,
        PEST_CLIENT,
        PEST_TYPE
    )
        ( SELECT
            PEST_ID,
            PEST_MEM_ID,
            PEST_STATUS,
            PEST_DATE_CREATED,
            PEST_PLAN,
            NEW_CLIENT,
            PEST_TYPE
          FROM
            OLIVER.TBL_PEN_EXIT_STAT_TRANS
          WHERE
            PEST_CLIENT = OLD_CLIENT
        );

INSERT INTO OLIVER.TBL_PEN_CALC_FORMULA (
    TPCF_CLIENT,
    TPCF_PLAN,
    TPCF_EFF_DATE,
    TPCF_TERM_DATE,
    TPCF_RATE,
    TPCF_UNIT_TYPE,
    TPCF_UNIT_QTY,
    TPCF_CREATED_DATE
) (SELECT
    NEW_CLIENT,
    TPCF_PLAN,
    TPCF_EFF_DATE,
    TPCF_TERM_DATE,
    TPCF_RATE,
    TPCF_UNIT_TYPE,
    TPCF_UNIT_QTY,
    TPCF_CREATED_DATE
FROM
    OLIVER.TBL_PEN_CALC_FORMULA WHERE TPCF_CLIENT=OLD_CLIENT);
    
INSERT INTO OLIVER.TBL_PEN_EXIT_FILE (
    PLAN_ID,
    CLIENT_ID,
    MEM_ID,
    OUTPUT_BLOB,
    FILENAME,
    MIME_TYPE,
    CREATE_DATE,
    CREATE_BY,
    ID
) (SELECT
    PLAN_ID,
    NEW_CLIENT,
    MEM_ID,
    OUTPUT_BLOB,
    FILENAME,
    MIME_TYPE,
    CREATE_DATE,
    CREATE_BY,
    ID
FROM
    OLIVER.TBL_PEN_EXIT_FILE WHERE CLIENT_ID=OLD_CLIENT);
    
    INSERT INTO OLIVER.TBL_PEN_OPT_DETAILS (
    TPO_CLIENT,
    TPO_PLAN,
    TPO_MEM_ID,
    TPO_PEN_FORM,
    TPO_PEN_AMT,
    TPO_FACTOR,
    TPO_INT_AMT,
    TPO_INT_FACTOR,
    TPO_ID,
    TPO_CODE
) (SELECT
    TPO_CLIENT,
    TPO_PLAN,
    TPO_MEM_ID,
    TPO_PEN_FORM,
    TPO_PEN_AMT,
    TPO_FACTOR,
    TPO_INT_AMT,
    TPO_INT_FACTOR,
    TPO_ID,
    TPO_CODE
FROM
    OLIVER.TBL_PEN_OPT_DETAILS WHERE TPO_CLIENT=OLD_CLIENT);
    
    INSERT INTO OLIVER.TBL_PEN_OPT_HEADER (
    TPH_CLIENT,
    TPH_PLAN,
    TPH_MEM_ID,
    TPH_RET_DATE,
    TPH_OAS_AMT,
    TPH_CPP_AMT,
    TPH_RED_AMT,
    TPH_RET_TYPE,
    TPH_NORM_FORM,
    TPH_MEM_AGE,
    TPH_SP_AGE,
    TPH_CALC_DATE,
    TPH_CREATE_BY,
    TPH_CREATED_DATE
) (SELECT
    NEW_CLIENT,
    TPH_PLAN,
    TPH_MEM_ID,
    TPH_RET_DATE,
    TPH_OAS_AMT,
    TPH_CPP_AMT,
    TPH_RED_AMT,
    TPH_RET_TYPE,
    TPH_NORM_FORM,
    TPH_MEM_AGE,
    TPH_SP_AGE,
    TPH_CALC_DATE,
    TPH_CREATE_BY,
    TPH_CREATED_DATE
FROM
    OLIVER.TBL_PEN_OPT_HEADER WHERE TPH_CLIENT=OLD_CLIENT);
--OLIVER.TBL_PENMAST

    INSERT INTO OLIVER.TBL_PENMAST (
        PENM_ID,
        PENM_PLAN,
        PENM_ENTRY_DATE,
        PENM_HIRE_DATE,
        PENM_STATUS,
        PENM_STATUS_DATE,
        PENM_RECIPROCAL,
        PENM_LOCAL,
        PENM_EMPLOYER,
        PENM_PAST_SERV,
        PENM_PAST_PENSION,
        PENM_CURR_SERV,
        PENM_CURR_PENSION,
        PENM_MARITAL_STATUS,
        PENM_LRD,
        PENM_VP_PENSION,
        PENM_PROCESS_DATE,
        PENM_CLIENT,
        PENM_VETSED_DATE,
        PENM_PAST_PENSION_LI,
        PENM_LAST_MODIFIED_DATE,
        PENM_LAST_MODIFIED_BY
    )
        ( SELECT
            PENM_ID,
            PENM_PLAN,
            PENM_ENTRY_DATE,
            PENM_HIRE_DATE,
            PENM_STATUS,
            PENM_STATUS_DATE,
            PENM_RECIPROCAL,
            PENM_LOCAL,
            PENM_EMPLOYER,
            PENM_PAST_SERV,
            PENM_PAST_PENSION,
            PENM_CURR_SERV,
            PENM_CURR_PENSION,
            PENM_MARITAL_STATUS,
            PENM_LRD,
            PENM_VP_PENSION,
            PENM_PROCESS_DATE,
            NEW_CLIENT,
            PENM_VETSED_DATE,
            PENM_PAST_PENSION_LI,
            PENM_LAST_MODIFIED_DATE,
            PENM_LAST_MODIFIED_BY
          FROM
            OLIVER.TBL_PENMAST
          WHERE
            PENM_CLIENT = OLD_CLIENT
        );

--OLIVER.TBL_PENSION_FORMS

    INSERT INTO OLIVER.TBL_PENSION_FORMS (
        ID,
        DESCRIPTION,
        TPF_CLIENT,
        TPF_PLAN,
        TPF_EFF_DATE,
        TPF_TERM_DATE,
        TPF_CREATED_DATE,
        TPF_CREATED_BY,
        OLIVER_TEMP_FORM
    )
        ( SELECT
            ID,
            DESCRIPTION,
            NEW_CLIENT,
            TPF_PLAN,
            TPF_EFF_DATE,
            TPF_TERM_DATE,
            TPF_CREATED_DATE,
            TPF_CREATED_BY,
            OLIVER_TEMP_FORM
          FROM
            OLIVER.TBL_PENSION_FORMS
          WHERE
            TPF_CLIENT = OLD_CLIENT
        );

--OLIVER.TBL_PENSION_STATUS

    INSERT INTO OLIVER.TBL_PENSION_STATUS (
        TPS_CLIENT,
        TPS_PLAN,
        TPS_STATUS,
        TPS_STATUS_DESC,
        TPS_EFF_DATE,
        TPS_TERM_DATE,
        TPS_CREATED_DATE,
        TPS_CREATED_BY
    )
        ( SELECT
            NEW_CLIENT,
            TPS_PLAN,
            TPS_STATUS,
            TPS_STATUS_DESC,
            TPS_EFF_DATE,
            TPS_TERM_DATE,
            TPS_CREATED_DATE,
            TPS_CREATED_BY
          FROM
            OLIVER.TBL_PENSION_STATUS
          WHERE
            TPS_CLIENT = OLD_CLIENT
        );

--

    INSERT INTO OLIVER.TBL_PENWD (
        PW_CLIENT,
        PW_PLAN,
        PW_MEM_ID,
        PW_NLI_WDRAW_EE,
        PW_LI_WDRAW_EE,
        PW_LI_WDRAW_ER,
        PW_NLI_WDRAW_ER,
        PW_TERM_DATE,
        PW_PROCESS_DATE,
        PW_COMMENT,
        PW_CREATED_BY,
        PW_CREATION_DATE,
        PW_LAST_UPDATED_BY,
        PW_LAST_UPDATED_DATE,
        PW_SOL_RATIO,
        PW_EE_DUE,
        PW_ER_DUE,
        PW_DUE_DATE,
        PW_SHORT_INT_RATE,
        PW_LONG_INT_RATE
    )
        ( SELECT
            NEW_CLIENT,
            PW_PLAN,
            PW_MEM_ID,
            PW_NLI_WDRAW_EE,
            PW_LI_WDRAW_EE,
            PW_LI_WDRAW_ER,
            PW_NLI_WDRAW_ER,
            PW_TERM_DATE,
            PW_PROCESS_DATE,
            PW_COMMENT,
            PW_CREATED_BY,
            PW_CREATION_DATE,
            PW_LAST_UPDATED_BY,
            PW_LAST_UPDATED_DATE,
            PW_SOL_RATIO,
            PW_EE_DUE,
            PW_ER_DUE,
            PW_DUE_DATE,
            PW_SHORT_INT_RATE,
            PW_LONG_INT_RATE
          FROM
            OLIVER.TBL_PENWD
          WHERE
            PW_CLIENT = OLD_CLIENT
        );

--OLIVER.TBL_PLAN

    INSERT INTO OLIVER.TBL_PLAN (
        PL_ID,
        PL_ADMINISTRATOR,
        PL_CONTACT,
        PL_NAME,
        PL_ADDRESS1,
        PL_ADDRESS2,
        PL_CITY,
        PL_PROV,
        PL_COUNTRY,
        PL_PHONE1,
        PL_PHONE2,
        PL_FAX,
        PL_EMAIL,
        PL_POST_CODE,
        PL_HW_MONTHEND,
        PL_EFF_DATE,
        PL_JURISDICTION,
        PL_TERM_DATE,
        PL_CLIENT_ID,
        PL_TYPE,
        PL_STATUS,
        PL_MEMBER_IDENTIFIER,
        PL_GST_NUMBER,
        PL_PAY_GRACE_PERIOD,
        PL_LOGO
    )
        ( SELECT
            PL_ID,
            PL_ADMINISTRATOR,
            PL_CONTACT,
            PL_NAME,
            PL_ADDRESS1,
            PL_ADDRESS2,
            PL_CITY,
            PL_PROV,
            PL_COUNTRY,
            PL_PHONE1,
            PL_PHONE2,
            PL_FAX,
            PL_EMAIL,
            PL_POST_CODE,
            PL_HW_MONTHEND,
            PL_EFF_DATE,
            PL_JURISDICTION,
            PL_TERM_DATE,
            NEW_CLIENT,
            PL_TYPE,
            PL_STATUS,
            PL_MEMBER_IDENTIFIER,
            PL_GST_NUMBER,
            PL_PAY_GRACE_PERIOD,
            PL_LOGO
          FROM
            OLIVER.TBL_PLAN
          WHERE
            PL_CLIENT_ID = OLD_CLIENT
        );
INSERT INTO OLIVER.TBL_PLAN_ACCOUNTS (
    TPA_CLIENT,
    TPA_PLAN,
    TPA_ACCOUNT,
    TPA_ACCOUNT_NAME,
    TPA_EFF_DATE,
    TPA_TERM_DATE
) (SELECT
    NEW_CLIENT,
    TPA_PLAN,
    TPA_ACCOUNT,
    TPA_ACCOUNT_NAME,
    TPA_EFF_DATE,
    TPA_TERM_DATE
FROM
    OLIVER.TBL_PLAN_ACCOUNTS WHERE TPA_CLIENT=OLD_CLIENT);
    
    INSERT INTO OLIVER.TBL_PLAN_BANK (
    TPB_CLIENT,
    TPB_PLAN,
    TPB_SUB_PLAN,
    TPB_EFF_DATE,
    TPB_TRANSIT,
    TPB_BRANCH,
    TPB_ACCOUNT,
    TPB_PLAN_TYPE
)(SELECT
    NEW_CLIENT,
    TPB_PLAN,
    TPB_SUB_PLAN,
    TPB_EFF_DATE,
    TPB_TRANSIT,
    TPB_BRANCH,
    TPB_ACCOUNT,
    TPB_PLAN_TYPE
FROM
    OLIVER.TBL_PLAN_BANK WHERE TPB_CLIENT=OLD_CLIENT);

INSERT INTO OLIVER.TBL_PLAN_FUND_RATES (
    PFR_CLIENT_ID,
    PFR_PLAN_ID,
    PFR_FUND_ID,
    PFR_EFF_DATE,
    PFR_RATE
) (SELECT
    NEW_CLIENT,
    PFR_PLAN_ID,
    PFR_FUND_ID,
    PFR_EFF_DATE,
    PFR_RATE
FROM
    OLIVER.TBL_PLAN_FUND_RATES WHERE PFR_CLIENT_ID=OLD_CLIENT);

    INSERT INTO OLIVER.TBL_PLAN_HR_BANK_CLASS_RATES (
        PHBCR_PLAN,
        PHBCR_CLASS,
        PHBCR_EFF_DATE,
        PHBCR_MIN_HRS,
        PHBCR_MAX_HRS,
        PHBCR_MONTHLY_HRS,
        PHBCR_SELF_PAY_MTHS,
        PH_FORFEIT_MTHS,
        PHCR_CLIENT_ID
    )
        ( SELECT
            PHBCR_PLAN,
            PHBCR_CLASS,
            PHBCR_EFF_DATE,
            PHBCR_MIN_HRS,
            PHBCR_MAX_HRS,
            PHBCR_MONTHLY_HRS,
            PHBCR_SELF_PAY_MTHS,
            PH_FORFEIT_MTHS,
            NEW_CLIENT
          FROM
            OLIVER.TBL_PLAN_HR_BANK_CLASS_RATES
          WHERE
            PHCR_CLIENT_ID = OLD_CLIENT
        );

--OLIVER.TBL_PLAN_HR_BANK_RATES

    INSERT INTO OLIVER.TBL_PLAN_HR_BANK_RATES (
        PHBR_PLAN,
        PHBR_EFF_DATE,
        PHBR_MIN_HRS,
        PHBR_MAX_HRS,
        PHBR_MONTHLY_HRS,
        PHBR_SELF_PAY_MTHS,
        PH_FORFEIT_MTHS,
        PHBR_CLIENT_ID,
        PHBR_TOPUP_ALLOWED,
        PHBR_KEY
    )
        ( SELECT
            PHBR_PLAN,
            PHBR_EFF_DATE,
            PHBR_MIN_HRS,
            PHBR_MAX_HRS,
            PHBR_MONTHLY_HRS,
            PHBR_SELF_PAY_MTHS,
            PH_FORFEIT_MTHS,
            NEW_CLIENT,
            PHBR_TOPUP_ALLOWED,
            PHBR_KEY
          FROM
            OLIVER.TBL_PLAN_HR_BANK_RATES
          WHERE
            PHBR_CLIENT_ID = OLD_CLIENT
        );
INSERT INTO OLIVER.TBL_PLAN_PARAMETERS (
    TPP_CLIENT,
    TPP_PLAN,
    TPP_ER,
    TPP_EFF_DATE,
    TPP_UNITS,
    TPP_AVG_MTHS,
    TPP_PLAN_TYPE,
    TPP_VESTING_MTHS,
    TPP_SOLV_RATIO,
    TPP_SOLV_THRESHOLD,
    TPP_INDEXED,
    TPP_SUPP,
    TPP_BRIDGE,
    TPP_VP_A_UNITS,
    TPP_MAX_UNITS_ALLOWED,
    TPP_INHOUSE_PAYROLL,
    TPP_TRANSER_ALLOWED,
    TPP_TRANSFER_SERVICE,
    TPP_TRANSFER_PENSION,
    TPP_VARIANCE_THRESHOLD,
    TPP_ELIG_HRS,
    TPP_ELIG_MTHS,
    TPP_VEST_ELIG_YMPE,
    TPP_VESTING_HRS,
    TPP_VETST_CONSE_HRS,
    TPP_VEST_CONSE_MTHS,
    TPP_VEST_TOT_SERV,
    TPP_PARTICIP_HRS,
    TPP_TARGET_CONCERN,
    TPP_PLYEAR_START,
    TPP_PLYEAR_END
)( SELECT
    NEW_CLIENT,
    TPP_PLAN,
    TPP_ER,
    TPP_EFF_DATE,
    TPP_UNITS,
    TPP_AVG_MTHS,
    TPP_PLAN_TYPE,
    TPP_VESTING_MTHS,
    TPP_SOLV_RATIO,
    TPP_SOLV_THRESHOLD,
    TPP_INDEXED,
    TPP_SUPP,
    TPP_BRIDGE,
    TPP_VP_A_UNITS,
    TPP_MAX_UNITS_ALLOWED,
    TPP_INHOUSE_PAYROLL,
    TPP_TRANSER_ALLOWED,
    TPP_TRANSFER_SERVICE,
    TPP_TRANSFER_PENSION,
    TPP_VARIANCE_THRESHOLD,
    TPP_ELIG_HRS,
    TPP_ELIG_MTHS,
    TPP_VEST_ELIG_YMPE,
    TPP_VESTING_HRS,
    TPP_VETST_CONSE_HRS,
    TPP_VEST_CONSE_MTHS,
    TPP_VEST_TOT_SERV,
    TPP_PARTICIP_HRS,
    TPP_TARGET_CONCERN,
    TPP_PLYEAR_START,
    TPP_PLYEAR_END
FROM
    OLIVER.TBL_PLAN_PARAMETERS WHERE TPP_CLIENT=OLD_CLIENT);

INSERT INTO OLIVER.TBL_PLAN_RULES (
    TPR_CLIENT_ID,
    TPR_PLAN_ID,
    TPR_PROV,
    TPR_EFF_DATE,
    TPR_ELIG_MIN_MTHS,
    TPR_VEST_LOCKED_MTHS,
    TPR_VESTING_AT_NRD,
    TPR_MIN_ER_CONTS,
    TPR_EXCESS_EE_CONTS,
    TPR_MIN_EE_CONTS_INT,
    TPR_PORT_TERMI_EMPL,
    TPR_NRD_AGE,
    TPR_ERD_AGE,
    TPR_POSTPONE_PEN_CREDIT,
    TPR_INTEGRATION_ALLOWED,
    TPR_INDEING_PERCENT,
    TPR_AIR_REQD,
    TPR_AIR_MTHS,
    TPR_PEN_PERCENT,
    TPR_CV_PERCENT
) (SELECT
    NEW_CLIENT,
    TPR_PLAN_ID,
    TPR_PROV,
    TPR_EFF_DATE,
    TPR_ELIG_MIN_MTHS,
    TPR_VEST_LOCKED_MTHS,
    TPR_VESTING_AT_NRD,
    TPR_MIN_ER_CONTS,
    TPR_EXCESS_EE_CONTS,
    TPR_MIN_EE_CONTS_INT,
    TPR_PORT_TERMI_EMPL,
    TPR_NRD_AGE,
    TPR_ERD_AGE,
    TPR_POSTPONE_PEN_CREDIT,
    TPR_INTEGRATION_ALLOWED,
    TPR_INDEING_PERCENT,
    TPR_AIR_REQD,
    TPR_AIR_MTHS,
    TPR_PEN_PERCENT,
    TPR_CV_PERCENT
FROM
    OLIVER.TBL_PLAN_RULES WHERE TPR_CLIENT_ID=OLD_CLIENT);


INSERT INTO OLIVER.TBL_PORTAL_GROUP (
    CLIENTID,
    GROUPID,
    PORTALID,
    PLANID
) (SELECT
    NEW_CLIENT,
    GROUPID,
    PORTALID,
    PLANID
FROM
    OLIVER.TBL_PORTAL_GROUP WHERE CLIENTID=OLD_CLIENT);
    
    
    INSERT INTO OLIVER.TBL_RETIREES (
        RET_MEM_ID,
        RET_CLIENT_ID,
        RET_PLAN_ID,
        RET_RETIRE_DATE,
        RET_PEN_OPTION,
        RET_PEN_TYPE,
        RET_PEN_AMT,
        RET_BRIDGE_AMT,
        RET_GTEE_MTHS,
        RET_SURVIVOR_PER,
        RET_SURVIVOR_SIN,
        RET_END_GTEE_DATE,
        RET_SUPP1_AMT,
        RET_SUPP2_AMT,
        RET_RED_AMT,
        RET_TAX_CODE,
        RET_CREATED_DATE,
        RET_CREATED_BY,
        RET_MODIFIED_DATE,
        RET_MODIFIED_BY
    )
        ( SELECT
            RET_MEM_ID,
            NEW_CLIENT,
            RET_PLAN_ID,
            RET_RETIRE_DATE,
            RET_PEN_OPTION,
            RET_PEN_TYPE,
            RET_PEN_AMT,
            RET_BRIDGE_AMT,
            RET_GTEE_MTHS,
            RET_SURVIVOR_PER,
            RET_SURVIVOR_SIN,
            RET_END_GTEE_DATE,
            RET_SUPP1_AMT,
            RET_SUPP2_AMT,
            RET_RED_AMT,
            RET_TAX_CODE,
            RET_CREATED_DATE,
            RET_CREATED_BY,
            RET_MODIFIED_DATE,
            RET_MODIFIED_BY
          FROM
            OLIVER.TBL_RETIREES
          WHERE
            RET_CLIENT_ID = OLD_CLIENT
        );
        
INSERT INTO OLIVER.TBL_RELATIONS (
    R_KEY,
    R_CODE,
    R_DESCRIPTION,
    PLAN_ID,
    CLIENT_ID
) (SELECT
    R_KEY,
    R_CODE,
    R_DESCRIPTION,
    PLAN_ID,
    NEW_CLIENT
FROM
    OLIVER.TBL_RELATIONS WHERE CLIENT_ID=OLD_CLIENT);

INSERT INTO OLIVER.TBL_YRLY_PARAMETERS (
    TYP_CLIENT,
    TYP_PLAN,
    TYP_YEAR,
    TYP_SALARY_CAP,
    TYP_DB_LIMIT,
    RRSP_LIMIT,
    DPSP_LIMIT,
    CONTRIB_CAP
)(SELECT
    NEW_CLIENT,
    TYP_PLAN,
    TYP_YEAR,
    TYP_SALARY_CAP,
    TYP_DB_LIMIT,
    RRSP_LIMIT,
    DPSP_LIMIT,
    CONTRIB_CAP
FROM
    OLIVER.TBL_YRLY_PARAMETERS WHERE TYP_CLIENT=OLD_CLIENT);

    INSERT INTO OLIVER.TRAN_HEADER_TEMP_FUNDS (
        THTF_EMPLOYER,
        THTF_PLAN_ID,
        THTF_START_DATE,
        THTF_END_DATE,
        THTF_PERIOD,
        THTF_UNITS,
        THTF_RATE,
        THTF_AMOUNT,
        THTF_PAYMENT_TYPE,
        THTF_COMMENT,
        THTF_USER,
        THTF_DATE_TIME,
        THTF_MEM_ID,
        THTF_TRAN_ID,
        THTF_POST,
        THTF_CHEQUE,
        THTF_POSTED_DATE,
        THTF_EARNED,
        THTF_RECD_AMT,
        THTF_VARIANCE_AMT,
        THTF_VAR_REASON,
        THTF_CLIENT_ID,
        THTF_DEPOSIT_NUMBER,
        THTF_AGREE_ID,
        THTF_DEPOSIT_SLIP_DATE,
        THTF_WRITE_OFF_AMT
    )
        ( SELECT
            THTF_EMPLOYER,
            THTF_PLAN_ID,
            THTF_START_DATE,
            THTF_END_DATE,
            THTF_PERIOD,
            THTF_UNITS,
            THTF_RATE,
            THTF_AMOUNT,
            THTF_PAYMENT_TYPE,
            THTF_COMMENT,
            THTF_USER,
            THTF_DATE_TIME,
            THTF_MEM_ID,
            THTF_TRAN_ID,
            THTF_POST,
            THTF_CHEQUE,
            THTF_POSTED_DATE,
            THTF_EARNED,
            THTF_RECD_AMT,
            THTF_VARIANCE_AMT,
            THTF_VAR_REASON,
            NEW_CLIENT,
            THTF_DEPOSIT_NUMBER,
            THTF_AGREE_ID,
            THTF_DEPOSIT_SLIP_DATE,
            THTF_WRITE_OFF_AMT
          FROM
            OLIVER.TRAN_HEADER_TEMP_FUNDS
          WHERE
            THTF_CLIENT_ID = OLD_CLIENT
        );

--OLIVER.TRAN_HEADER_TEMP_PEN

    INSERT INTO OLIVER.TRAN_HEADER_TEMP_PEN (
        THTP_EMPLOYER,
        THTP_PLAN_ID,
        THTP_START_DATE,
        THTP_END_DATE,
        THTP_PERIOD,
        THTP_UNITS,
        THTP_RATE,
        THTP_AMOUNT,
        THTP_PAYMENT_TYPE,
        THTP_COMMENT,
        THTP_USER,
        THTP_DATE_TIME,
        THTP_MEM_ID,
        THTP_TRAN_ID,
        THTP_POST,
        THTP_CHEQUE,
        THTP_POSTED_DATE,
        THTP_EARNED,
        THTP_RECD_AMT,
        THTP_VARIANCE_AMT,
        THTP_VAR_REASON,
        THT_CLIENT_ID,
        THTP_DEPOSIT_NUMBER,
        THTP_AGREE_ID,
        THTP_EE_UNITS,
        THTP_ER_UNITS,
        THTP_EARNINGS,
        THTP_VOL_UNITS,
        THTP_HRS,
        THTP_EE_ACCOUNT,
        THTP_ER_ACCOUNT,
        THTP_VOL_ACCOUNT,
        THTP_DEPOSIT_SLIP_DATE,
        THTP_WRITE_OFF_AMT
    )
        ( SELECT
            THTP_EMPLOYER,
            THTP_PLAN_ID,
            THTP_START_DATE,
            THTP_END_DATE,
            THTP_PERIOD,
            THTP_UNITS,
            THTP_RATE,
            THTP_AMOUNT,
            THTP_PAYMENT_TYPE,
            THTP_COMMENT,
            THTP_USER,
            THTP_DATE_TIME,
            THTP_MEM_ID,
            THTP_TRAN_ID,
            THTP_POST,
            THTP_CHEQUE,
            THTP_POSTED_DATE,
            THTP_EARNED,
            THTP_RECD_AMT,
            THTP_VARIANCE_AMT,
            THTP_VAR_REASON,
            NEW_CLIENT,
            THTP_DEPOSIT_NUMBER,
            THTP_AGREE_ID,
            THTP_EE_UNITS,
            THTP_ER_UNITS,
            THTP_EARNINGS,
            THTP_VOL_UNITS,
            THTP_HRS,
            THTP_EE_ACCOUNT,
            THTP_ER_ACCOUNT,
            THTP_VOL_ACCOUNT,
            THTP_DEPOSIT_SLIP_DATE,
            THTP_WRITE_OFF_AMT
          FROM
            OLIVER.TRAN_HEADER_TEMP_PEN
          WHERE
            THT_CLIENT_ID = OLD_CLIENT
        );

--OLIVER.TRANSACTION_DETAIL

    INSERT INTO OLIVER.TRANSACTION_DETAIL (
        TD_TRAN_ID,
        TD_EMPLOYER,
        TD_PLAN_ID,
        TD_START_DATE,
        TD_END_DATE,
        TD_PERIOD,
        TD_UNITS,
        TD_AMOUNT,
        TD_COMMENT,
        TD_USER,
        TD_DATE_TIME,
        TD_MEM_ID,
        TD_KEY,
        TD_POSTED_DATE,
        TD_POSTED_USER,
        TDT_PEN_UNITS,
        TDT_FUNDS_UNITS,
        TD_CLIENT_ID,
        TDT_EE_UNITS,
        TDT_ER_UNITS,
        TD_UNITS_TYPE,
        TD_OCCU,
        TD_RATE,
        TD_EARNINGS,
        TD_VOL_UNITS,
        TD_HRS,
        TD_ER_RATE,
        TD_EE_RATE,
        TD_MEM_SIN,
        TD_EE_ACCOUNT,
        TD_ER_ACCOUNT,
        TD_VOL_ACCOUNT
    )
        ( SELECT
            TD_TRAN_ID,
            TD_EMPLOYER,
            TD_PLAN_ID,
            TD_START_DATE,
            TD_END_DATE,
            TD_PERIOD,
            TD_UNITS,
            TD_AMOUNT,
            TD_COMMENT,
            TD_USER,
            TD_DATE_TIME,
            TD_MEM_ID,
            TD_KEY,
            TD_POSTED_DATE,
            TD_POSTED_USER,
            TDT_PEN_UNITS,
            TDT_FUNDS_UNITS,
            NEW_CLIENT,
            TDT_EE_UNITS,
            TDT_ER_UNITS,
            TD_UNITS_TYPE,
            TD_OCCU,
            TD_RATE,
            TD_EARNINGS,
            TD_VOL_UNITS,
            TD_HRS,
            TD_ER_RATE,
            TD_EE_RATE,
            TD_MEM_SIN,
            TD_EE_ACCOUNT,
            TD_ER_ACCOUNT,
            TD_VOL_ACCOUNT
          FROM
            OLIVER.TRANSACTION_DETAIL
          WHERE
            TD_CLIENT_ID = OLD_CLIENT
        );

--  OLIVER.TRANSACTION_DETAIL_TEMP

    INSERT INTO OLIVER.TRANSACTION_DETAIL_TEMP (
        TDT_TRAN_ID,
        TDT_EMPLOYER,
        TDT_PLAN_ID,
        TDT_START_DATE,
        TDT_END_DATE,
        TDT_PERIOD,
        TDT_UNITS,
        TDT_AMOUNT,
        TDT_COMMENT,
        TDT_USER,
        TDT_DATE_TIME,
        TDT_MEM_ID,
        TDT_KEY,
        TDT_LAST_NAME,
        TDT_FIRST_NAME,
        TDT_PEN_UNITS,
        TDT_FUNDS_UNITS,
        TDT_CLIENT_ID,
        TDT_OCCU,
        TDT_RATE,
        TDT_EARNINGS,
        TDT_VOL_UNITS,
        TDT_HRS,
        TDT_EE_UNITS,
        TDT_ER_UNITS,
        TDT_ER_RATE,
        TDT_EE_RATE,
        TDT_MEM_SIN
    )
        ( SELECT
            TDT_TRAN_ID,
            TDT_EMPLOYER,
            TDT_PLAN_ID,
            TDT_START_DATE,
            TDT_END_DATE,
            TDT_PERIOD,
            TDT_UNITS,
            TDT_AMOUNT,
            TDT_COMMENT,
            TDT_USER,
            TDT_DATE_TIME,
            TDT_MEM_ID,
            TDT_KEY,
            TDT_LAST_NAME,
            TDT_FIRST_NAME,
            TDT_PEN_UNITS,
            TDT_FUNDS_UNITS,
            NEW_CLIENT,
            TDT_OCCU,
            TDT_RATE,
            TDT_EARNINGS,
            TDT_VOL_UNITS,
            TDT_HRS,
            TDT_EE_UNITS,
            TDT_ER_UNITS,
            TDT_ER_RATE,
            TDT_EE_RATE,
            TDT_MEM_SIN
          FROM
            OLIVER.TRANSACTION_DETAIL_TEMP
          WHERE
            TDT_CLIENT_ID = OLD_CLIENT
        );

--OLIVER.TRANSACTION_HEADER

    INSERT INTO OLIVER.TRANSACTION_HEADER (
        TH_EMPLOYER,
        TH_PLAN_ID,
        TH_START_DATE,
        TH_END_DATE,
        TH_PERIOD,
        TH_UNITS,
        TH_RATE,
        TH_AMOUNT,
        TH_PAYMENT_TYPE,
        TH_COMMENT,
        TH_USER,
        TH_DATE_TIME,
        TH_MEM_ID,
        TH_TRAN_ID,
        TH_POSTED_DATE,
        TH_POSTED_USER,
        TH_CHEQUE,
        TH_UNITS_EARNED,
        TH_RECD_AMT,
        TH_VARIANCE_AMT,
        TH_VAR_REASON,
        TH_CLIENT_ID,
        TH_DEPOSIT_NUMBER,
        TH_AGREE_ID,
        TH_DEPOSIT_SLIP_DATE,
        TH_WRITE_OFF_AMT
    )
        ( SELECT
            TH_EMPLOYER,
            TH_PLAN_ID,
            TH_START_DATE,
            TH_END_DATE,
            TH_PERIOD,
            TH_UNITS,
            TH_RATE,
            TH_AMOUNT,
            TH_PAYMENT_TYPE,
            TH_COMMENT,
            TH_USER,
            TH_DATE_TIME,
            TH_MEM_ID,
            TH_TRAN_ID,
            TH_POSTED_DATE,
            TH_POSTED_USER,
            TH_CHEQUE,
            TH_UNITS_EARNED,
            TH_RECD_AMT,
            TH_VARIANCE_AMT,
            TH_VAR_REASON,
            NEW_CLIENT,
            TH_DEPOSIT_NUMBER,
            TH_AGREE_ID,
            TH_DEPOSIT_SLIP_DATE,
            TH_WRITE_OFF_AMT
          FROM
            OLIVER.TRANSACTION_HEADER
          WHERE
            TH_CLIENT_ID = OLD_CLIENT
        );

--OLIVER.TRANSACTION_HEADER_PEN

    INSERT INTO OLIVER.TRANSACTION_HEADER_PEN (
        THP_EMPLOYER,
        THP_PLAN_ID,
        THP_START_DATE,
        THP_END_DATE,
        THP_PERIOD,
        THP_UNITS,
        THP_RATE,
        THP_AMOUNT,
        THP_PAYMENT_TYPE,
        THP_COMMENT,
        THP_USER,
        THP_DATE_TIME,
        THP_MEM_ID,
        THP_TRAN_ID,
        THP_POSTED_DATE,
        THP_POSTED_USER,
        THP_CHEQUE,
        THP_UNITS_EARNED,
        THP_RECD_AMT,
        THP_VARIANCE_AMT,
        THP_VAR_REASON,
        THP_CLIENT_ID,
        THP_DEPOSIT_NUMBER,
        THP_AGREE_ID,
        THP_EARNINGS,
        THP_VOL_UNITS,
        THP_HRS,
        THP_EE_UNITS,
        THP_ER_UNITS,
        THP_EE_ACCOUNT,
        THP_ER_ACCOUNT,
        THP_VOL_ACCOUNT,
        THP_DEPOSIT_SLIP_DATE,
        THP_WRITE_OFF_AMT
    )
        ( SELECT
            THP_EMPLOYER,
            THP_PLAN_ID,
            THP_START_DATE,
            THP_END_DATE,
            THP_PERIOD,
            THP_UNITS,
            THP_RATE,
            THP_AMOUNT,
            THP_PAYMENT_TYPE,
            THP_COMMENT,
            THP_USER,
            THP_DATE_TIME,
            THP_MEM_ID,
            THP_TRAN_ID,
            THP_POSTED_DATE,
            THP_POSTED_USER,
            THP_CHEQUE,
            THP_UNITS_EARNED,
            THP_RECD_AMT,
            THP_VARIANCE_AMT,
            THP_VAR_REASON,
            NEW_CLIENT,
            THP_DEPOSIT_NUMBER,
            THP_AGREE_ID,
            THP_EARNINGS,
            THP_VOL_UNITS,
            THP_HRS,
            THP_EE_UNITS,
            THP_ER_UNITS,
            THP_EE_ACCOUNT,
            THP_ER_ACCOUNT,
            THP_VOL_ACCOUNT,
            THP_DEPOSIT_SLIP_DATE,
            THP_WRITE_OFF_AMT
          FROM
            OLIVER.TRANSACTION_HEADER_PEN
          WHERE
            THP_CLIENT_ID = OLD_CLIENT
        );

--OLIVER.TRANSACTION_HEADER_TEMP

    INSERT INTO OLIVER.TRANSACTION_HEADER_TEMP (
        THT_EMPLOYER,
        THT_PLAN_ID,
        THT_START_DATE,
        THT_END_DATE,
        THT_PERIOD,
        THT_UNITS,
        THT_RATE,
        THT_AMOUNT,
        THT_PAYMENT_TYPE,
        THT_COMMENT,
        THT_USER,
        THT_DATE_TIME,
        THT_MEM_ID,
        THT_TRAN_ID,
        THT_POST,
        THT_CHEQUE,
        THT_POSTED_DATE,
        THT_EARNED,
        THT_RECD_AMT,
        THT_VARIANCE_AMT,
        THT_VAR_REASON,
        THT_CLIENT_ID,
        THT_DEPOSIT_NUMBER,
        THT_AGREE_ID,
        THT_EE_UNITS,
        THT_ER_UNITS,
        THT_EE_ACCOUNT,
        THT_ER_ACCOUNT,
        THT_DEPOSIT_SLIP_DATE,
        THT_WRITE_OFF_AMT
    )
        ( SELECT
            THT_EMPLOYER,
            THT_PLAN_ID,
            THT_START_DATE,
            THT_END_DATE,
            THT_PERIOD,
            THT_UNITS,
            THT_RATE,
            THT_AMOUNT,
            THT_PAYMENT_TYPE,
            THT_COMMENT,
            THT_USER,
            THT_DATE_TIME,
            THT_MEM_ID,
            THT_TRAN_ID,
            THT_POST,
            THT_CHEQUE,
            THT_POSTED_DATE,
            THT_EARNED,
            THT_RECD_AMT,
            THT_VARIANCE_AMT,
            THT_VAR_REASON,
            NEW_CLIENT,
            THT_DEPOSIT_NUMBER,
            THT_AGREE_ID,
            THT_EE_UNITS,
            THT_ER_UNITS,
            THT_EE_ACCOUNT,
            THT_ER_ACCOUNT,
            THT_DEPOSIT_SLIP_DATE,
            THT_WRITE_OFF_AMT
          FROM
            OLIVER.TRANSACTION_HEADER_TEMP
          WHERE
            THT_CLIENT_ID = OLD_CLIENT
        );



END COPY_CLIENT;
/

