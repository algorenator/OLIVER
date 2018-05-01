--
-- UPDATE_PLAN  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.UPDATE_PLAN (
    OLD_CLIENT_ID   IN VARCHAR2,
    OLD_PLAN_ID     IN VARCHAR2,
    NEW_PLAN_ID     IN VARCHAR2
) IS
--------------------------------------------------------------------------------------------------------------------
--Procedure     :UPDATE_PLAN
--Project       :Oliver
--Purpose       :Updates Plan for New Client
-----------------------------MODIFICATION HISTORY----------------------------------------------------------------------------
--  Name                  Date                Comments

--  Ramana                23/04/2018          New Procedure
----------------------------------------------------------------------------------------------------------

    OLD_CLIENT   VARCHAR2(50) := UPPER(OLD_CLIENT_ID);
    OLD_PLAN     VARCHAR2(50) := UPPER(OLD_PLAN_ID);
    NEW_PLAN     VARCHAR2(50) := UPPER(NEW_PLAN_ID);
BEGIN
    INIT.SETCLIENTID(OLD_CLIENT);
    IF
        OLD_CLIENT_ID IS NULL OR OLD_PLAN_ID IS NULL OR NEW_PLAN_ID IS NULL
    THEN
        RAISE_APPLICATION_ERROR(-20001,'PLEASE ENTER VALID INPUT VALUES');
    END IF;

    IF
        OLD_PLAN_ID = NEW_PLAN_ID
    THEN
        RAISE_APPLICATION_ERROR(-20001,'OLD_PLAN_ID AND NEW_PLAN_ID SHOULD NOT BE SAME');
    END IF;
        UPDATE OLIVER.BENEFITS_AGE_BASED
        SET
            BAB_PLAN_ID = NEW_PLAN
    WHERE
        BAB_CLIENT_ID = OLD_CLIENT
        AND   BAB_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.BENEFITS_DEP_BASED
        SET
            BDB_PLAN_ID = NEW_PLAN
    WHERE
        BDB_CLIENT_ID = OLD_CLIENT
        AND   BDB_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.BENEFITS_VOLUME_BASED
        SET
            BVB_PLAN_ID = NEW_PLAN
    WHERE
        BVB_CLIENT_ID = OLD_CLIENT
        AND   BVB_PLAN_ID = OLD_PLAN;
        
        update OLIVER.CONT_INT_RATES
       SET
            EIR_PLAN = NEW_PLAN
    WHERE
        EIR_CLIENT = OLD_CLIENT
        AND   EIR_PLAN = OLD_PLAN;
        
    UPDATE OLIVER.TBL_AGREEMENT
        SET
            TA_PLAN_ID = NEW_PLAN
    WHERE
        TA_CLIENT_ID = OLD_CLIENT
        AND   TA_PLAN_ID = OLD_PLAN;
        
        update oliver.TBL_MEM_PEN_STATUS_HIST
        SET
            TMPSH_PLAN = NEW_PLAN
    WHERE
        TMPSH_CLIENT = OLD_CLIENT
        AND   TMPSH_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_AGREEMENT_DESC
        SET
            TADC_PLAN = NEW_PLAN
    WHERE
        TADC_CLIENT = OLD_CLIENT
        AND   TADC_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_AGREEMENT_DETAILS
        SET
            TAD_PLAN_ID = NEW_PLAN
    WHERE
        TAD_CLIENT_ID = OLD_CLIENT
        AND   TAD_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TBL_AGREEMENT_TYPES
        SET
            TAT_PLAN_ID = NEW_PLAN
    WHERE
        TAT_CLIENT_ID = OLD_CLIENT
        AND   TAT_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TBL_ANNUAL
        SET
            ANN_PLAN = NEW_PLAN
    WHERE
        ANN_CLIENT = OLD_CLIENT
        AND   ANN_PLAN = OLD_PLAN;
        
update OLIVER.TBL_BENEFIC_RELATION
SET
            TBR_PLAN = NEW_PLAN
    WHERE
        TBR_CLIENT = OLD_CLIENT
        AND   TBR_PLAN = OLD_PLAN;

update OLIVER.TBL_BENEFIT_LIMIT
SET
            TBL_PLAN = NEW_PLAN
    WHERE
        TBL_CLIENT = OLD_CLIENT
        AND   TBL_PLAN = OLD_PLAN;
update OLIVER.TBL_BENEFITS 
SET
            BEN_PLAN = NEW_PLAN
    WHERE
        BEN_CLIENT = OLD_CLIENT
        AND   BEN_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_BENEFITS_CLASS
        SET
            BC_PLAN_ID = NEW_PLAN
    WHERE
        BC_CLIENT_ID = OLD_CLIENT
        AND   BC_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TBL_BENEFITS_MASTER
        SET
            BM_PLAN = NEW_PLAN
    WHERE
        BM_CLIENT_ID = OLD_CLIENT
        AND   BM_PLAN = OLD_PLAN;


update OLIVER.TBL_CARRIER
SET
            TC_PLAN = NEW_PLAN
    WHERE
        TC_CLIENT = OLD_CLIENT
        AND   TC_PLAN = OLD_PLAN;

update OLIVER.TBL_CALENDAR
SET
            PLAN_ID = NEW_PLAN
    WHERE
        CLIENT_ID = OLD_CLIENT
        AND   PLAN_ID = OLD_PLAN;


update OLIVER.TBL_BENEFIT_COVERAGE_STATUS
SET
            BDS_PL_ID = NEW_PLAN
    WHERE
        BDS_CLIENT_ID = OLD_CLIENT
        AND   BDS_PL_ID = OLD_PLAN;
        
        
update OLIVER.TBL_CLAIM_FILE
SET
            PLAN_ID = NEW_PLAN
    WHERE
        CLIENT_ID = OLD_CLIENT
        AND   PLAN_ID = OLD_PLAN;
        
update oliver.TBL_CLAIM_COMMENTS
SET
            TCC_PLAN = NEW_PLAN
    WHERE
        TCC_CLAIM = OLD_CLIENT
        AND   TCC_PLAN = OLD_PLAN;
        
        

    UPDATE OLIVER.TBL_CLAIMS
        SET
            CL_PLAN = NEW_PLAN
    WHERE
        CL_CLIENT_ID = OLD_CLIENT
        AND   CL_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_COMPHW
        SET
            CH_PLAN = NEW_PLAN
    WHERE
        CH_CLIENT_ID = OLD_CLIENT
        AND   CH_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_MEMBER
        SET
            MEM_PLAN = NEW_PLAN
    WHERE
        MEM_CLIENT_ID = OLD_CLIENT
        AND   MEM_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_COMPMAST
        SET
            CO_PLAN = NEW_PLAN
    WHERE
        CO_CLIENT = OLD_CLIENT
        AND   CO_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_HW
        SET
            HW_PLAN = NEW_PLAN
    WHERE
        HW_CLIENT = OLD_CLIENT
        AND   HW_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_COMPPEN
        SET
            CP_PLAN = NEW_PLAN
    WHERE
        CP_CLIENT = OLD_CLIENT
        AND   CP_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_DATAREFRESH
        SET
            PLAN_ID = NEW_PLAN
    WHERE
        CLIENT_ID = OLD_CLIENT
        AND   PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TBL_DISABILITY
        SET
            DIS_PLAN = NEW_PLAN
    WHERE
        DIS_CLIENT = OLD_CLIENT
        AND   DIS_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_DOCUMENT
        SET
            DOC_PLAN = NEW_PLAN
    WHERE
        DOC_CLIENT_ID = OLD_CLIENT
        AND   DOC_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_DOCUMENT_SEARCH
        SET
            PLANID = NEW_PLAN
    WHERE
        CLIENTID = OLD_CLIENT
        AND   PLANID = OLD_PLAN;

    UPDATE OLIVER.TBL_EMPLOYER_AGREEMENTS
        SET
            TEA_PLAN_ID = NEW_PLAN
    WHERE
        TEA_CLT_ID = OLD_CLIENT
        AND   TEA_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TBL_EMPLOYER_CLASSES
        SET
            TEC_PLAN_ID = NEW_PLAN
    WHERE
        TEC_CLIENT_ID = OLD_CLIENT
        AND   TEC_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TBL_EMPLOYER_CONTACTS
        SET
            TEC_PLAN = NEW_PLAN
    WHERE
        TEC_CLIENT = OLD_CLIENT
        AND   TEC_PLAN = OLD_PLAN;
        
        
update oliver.TBL_EMPLOYER_FUND_RATES        
SET
            PFR_PLAN_ID = NEW_PLAN
    WHERE
        PFR_CLIENT_ID = OLD_CLIENT
        AND   PFR_PLAN_ID = OLD_PLAN;       
        
        
update OLIVER.TBL_EMPLOYER_INVOICES_HW
SET
            EIH_PLAN_ID = NEW_PLAN
    WHERE
        EIH_CLIENT_ID = OLD_CLIENT
        AND   EIH_PLAN_ID = OLD_PLAN;  
        
        
        
        
        
        
        
        
        
        
        
        

    UPDATE OLIVER.TBL_EMPLOYER_NOTES
        SET
            EN_PLAN_ID = NEW_PLAN
    WHERE
        TEN_CLIENT = OLD_CLIENT
        AND   EN_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TBL_EMPLOYMENT_HIST
        SET
            TEH_PLAN = NEW_PLAN
    WHERE
        TEH_CLIENT = OLD_CLIENT
        AND   TEH_PLAN = OLD_PLAN;
        
update oliver.TBL_EMPLOYMENT_TYPES
SET
            TET_PLAN = NEW_PLAN
    WHERE
        TET_CLIENT = OLD_CLIENT
        AND   TET_PLAN = OLD_PLAN;
        
        
update OLIVER.TBL_ER_RATES        
SET
            TER_PLAN = NEW_PLAN
    WHERE
        TER_CLIENT = OLD_CLIENT
        AND   TER_PLAN = OLD_PLAN;        
        
        
update oliver.TBL_ER_RATES_HW       
SET
            TER_PLAN = NEW_PLAN
    WHERE
        TER_CLIENT = OLD_CLIENT
        AND   TER_PLAN = OLD_PLAN;        
        
update OLIVER.TBL_FUNDS         
SET
            FUND_PLAN = NEW_PLAN
    WHERE
        FUND_CLIENT = OLD_CLIENT
        AND   FUND_PLAN = OLD_PLAN;     
        

update OLIVER.TBL_GRADUAL_RATES
SET
            TGR_PLAN = NEW_PLAN
    WHERE
        TGR_CLIENT = OLD_CLIENT
        AND   TGR_PLAN = OLD_PLAN; 
        
     

    UPDATE OLIVER.TBL_HR_BANK
        SET
            THB_PLAN = NEW_PLAN
    WHERE
        THB_CLIENT_ID = OLD_CLIENT
        AND   THB_PLAN = OLD_PLAN;

update OLIVER.TBL_HSA_ATTACHMENTS
SET
            PLAN_ID = NEW_PLAN
    WHERE
        CLIENT_ID = OLD_CLIENT
        AND   PLAN_ID = OLD_PLAN;





    UPDATE OLIVER.TBL_HW_BENEFICIARY
        SET
            HB_PLAN = NEW_PLAN
    WHERE
        HB_CLIENT = OLD_CLIENT
        AND   HB_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_HW_COMMENTS
        SET
            THC_PLAN = NEW_PLAN
    WHERE
        THC_CLIENT = OLD_CLIENT
        AND   THC_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_HW_DEPENDANTS
        SET
            HD_PLAN = NEW_PLAN
    WHERE
        HD_CLIENT = OLD_CLIENT
        AND   HD_PLAN = OLD_PLAN;
        
 update OLIVER.TBL_HW_HISTORY       
 SET
            HW_PLAN_ID = NEW_PLAN
    WHERE
        HW_CLIENT_ID = OLD_CLIENT
        AND   HW_PLAN_ID = OLD_PLAN;       
        
        

    UPDATE OLIVER.TBL_HW_WAIVER
        SET
            THW_PLAN = NEW_PLAN
    WHERE
        THW_CLIENT = OLD_CLIENT
        AND   THW_PLAN = OLD_PLAN;
        
update OLIVER.TBL_HW_WAIVER_TYPES
SET
            THWT_PLAN = NEW_PLAN
    WHERE
        THWT_CLIENT = OLD_CLIENT
        AND   THWT_PLAN = OLD_PLAN;
        

update TBL_INVOICES
SET
            TI_PLAN_ID = NEW_PLAN
    WHERE
        TI_CLIENT_ID = OLD_CLIENT
        AND   TI_PLAN_ID = OLD_PLAN;


update OLIVER.TBL_MARITAL_STATUS 
SET
            TMS_PLAN = NEW_PLAN
    WHERE
        TMS_CLIENT = OLD_CLIENT
        AND   TMS_PLAN = OLD_PLAN;

 
        

    UPDATE OLIVER.TBL_MEM_FUNDS
        SET
            TMF_PLAN = NEW_PLAN
    WHERE
        TMF_CLIENT = OLD_CLIENT
        AND   TMF_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_MEM_UNITS
        SET
            MPU_PLAN = NEW_PLAN
    WHERE
        MU_CLIENT = OLD_CLIENT
        AND   MPU_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_MEM_VOL_BENEFITS
        SET
            MVB_PLAN = NEW_PLAN
    WHERE
        MVB_CLIENT = OLD_CLIENT
        AND   MVB_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_MEMBER_LOCATION
        SET
            MEM_PLAN = NEW_PLAN
    WHERE
        MEM_CLIENT_ID = OLD_CLIENT
        AND   MEM_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_MEMBER_NOTES
        SET
            MN_PLAN_ID = NEW_PLAN
    WHERE
        TMN_CLIENT = OLD_CLIENT
        AND   MN_PLAN_ID = OLD_PLAN;
        
update OLIVER.TBL_NETFUND_RETURN 
SET
            TNR_PLAN_ID = NEW_PLAN
    WHERE
        TNR_CLIENT_ID = OLD_CLIENT
        AND   TNR_PLAN_ID = OLD_PLAN;
    UPDATE OLIVER.TBL_OCCUPATIONS
        SET
            TO_PLAN = NEW_PLAN
    WHERE
        TO_CLIENT = OLD_CLIENT
        AND   TO_PLAN = OLD_PLAN;
update OLIVER.TBL_OPTION_FACTORS_JS
 SET
            OFJS_PLAN = NEW_PLAN
    WHERE
        OFJS_CLIENT = OLD_CLIENT
        AND   OFJS_PLAN = OLD_PLAN;
        
update OLIVER.TBL_OPTION_FACTORS_LO_G  
SET
            OFLG_PLAN = NEW_PLAN
    WHERE
        OFLG_CLIENT = OLD_CLIENT
        AND   OFLG_PLAN = OLD_PLAN;
     UPDATE OLIVER.TBL_PAST_UNITS
        SET
            TPU_PLAN = NEW_PLAN
    WHERE
        TPU_CLIENT = OLD_CLIENT
        AND   TPU_PLAN = OLD_PLAN;
update OLIVER.TBL_PAYMENTS_RECD
 SET
            TPR_PLAN_ID = NEW_PLAN
    WHERE
        TPR_CLIENT_ID = OLD_CLIENT
        AND   TPR_PLAN_ID = OLD_PLAN;
        
        
        
        
        
        

    UPDATE OLIVER.TBL_PEN_BENEFICIARY
        SET
            PB_PLAN = NEW_PLAN
    WHERE
        PB_CLIENT = OLD_CLIENT
        AND   PB_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_PEN_EXIT_STAT_TRANS
        SET
            PEST_PLAN = NEW_PLAN
    WHERE
        PEST_CLIENT = OLD_CLIENT
        AND   PEST_PLAN = OLD_PLAN;
update OLIVER.TBL_PEN_CALC_FORMULA
SET
            TPCF_PLAN = NEW_PLAN
    WHERE
        TPCF_CLIENT = OLD_CLIENT
        AND   TPCF_PLAN = OLD_PLAN;

update OLIVER.TBL_PEN_EXIT_FILE 
SET
            PLAN_ID = NEW_PLAN
    WHERE
        CLIENT_ID = OLD_CLIENT
        AND   PLAN_ID = OLD_PLAN;

update OLIVER.TBL_PEN_OPT_DETAILS
SET
            TPO_PLAN = NEW_PLAN
    WHERE
        TPO_CLIENT = OLD_CLIENT
        AND   TPO_PLAN = OLD_PLAN;

update OLIVER.TBL_PEN_OPT_HEADER
SET
            TPH_PLAN = NEW_PLAN
    WHERE
        TPH_CLIENT = OLD_CLIENT
        AND   TPH_PLAN = OLD_PLAN;




    UPDATE OLIVER.TBL_PENMAST
        SET
            PENM_PLAN = NEW_PLAN
    WHERE
        PENM_CLIENT = OLD_CLIENT
        AND   PENM_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_PENSION_FORMS
        SET
            TPF_PLAN = NEW_PLAN
    WHERE
        TPF_CLIENT = OLD_CLIENT
        AND   TPF_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_PENSION_STATUS
        SET
            TPS_PLAN = NEW_PLAN
    WHERE
        TPS_CLIENT = OLD_PLAN
        AND   TPS_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_PENWD
        SET
            PW_PLAN = NEW_PLAN
    WHERE
        PW_CLIENT = OLD_CLIENT
        AND   PW_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_PLAN
        SET
            PL_ID = NEW_PLAN
    WHERE
        PL_CLIENT_ID = OLD_CLIENT
        AND   PL_ID = OLD_PLAN;
        
update OLIVER.TBL_PLAN_ACCOUNTS
SET
            TPA_PLAN = NEW_PLAN
    WHERE
        TPA_CLIENT = OLD_CLIENT
        AND   TPA_PLAN = OLD_PLAN;
        
        
update OLIVER.TBL_PLAN_BANK
SET
            TPB_PLAN = NEW_PLAN
    WHERE
        TPB_CLIENT = OLD_CLIENT
        AND   TPB_PLAN = OLD_PLAN;
        
        
update OLIVER.TBL_PLAN_FUND_RATES
SET
            PFR_PLAN_ID = NEW_PLAN
    WHERE
        PFR_CLIENT_ID = OLD_CLIENT
        AND   PFR_PLAN_ID = OLD_PLAN;
 
    UPDATE OLIVER.TBL_PLAN_HR_BANK_CLASS_RATES
        SET
            PHBCR_PLAN = NEW_PLAN
    WHERE
        PHCR_CLIENT_ID = OLD_CLIENT
        AND   PHBCR_PLAN = OLD_PLAN;

    UPDATE OLIVER.TBL_PLAN_HR_BANK_RATES
        SET
            PHBR_PLAN = NEW_PLAN
    WHERE
        PHBR_CLIENT_ID = OLD_CLIENT
        AND   PHBR_PLAN = OLD_PLAN;
  
update OLIVER.TBL_PLAN_PARAMETERS
SET
            TPP_PLAN = NEW_PLAN
    WHERE
        TPP_CLIENT = OLD_CLIENT
        AND   TPP_PLAN = OLD_PLAN;
  
  
update OLIVER.TBL_PLAN_RULES
SET
            TPR_PLAN_ID = NEW_PLAN
    WHERE
        TPR_CLIENT_ID = OLD_CLIENT
        AND   TPR_PLAN_ID = OLD_PLAN;
  
update OLIVER.TBL_PORTAL_GROUP 
 SET
            PLANID = NEW_PLAN
    WHERE
        CLIENTID = OLD_CLIENT
        AND   PLANID = OLD_PLAN; 
 
    UPDATE OLIVER.TBL_RETIREES
        SET
            RET_PLAN_ID = NEW_PLAN
    WHERE
        RET_CLIENT_ID = OLD_CLIENT
        AND   RET_PLAN_ID = OLD_PLAN;
  
 update OLIVER.TBL_RELATIONS 
SET
            PLAN_ID = NEW_PLAN
    WHERE
        CLIENT_ID = OLD_CLIENT
        AND   PLAN_ID = OLD_PLAN; 
  
update OLIVER.TBL_YRLY_PARAMETERS  
SET
            TYP_PLAN = NEW_PLAN
    WHERE
        TYP_CLIENT = OLD_CLIENT
        AND   TYP_PLAN = OLD_PLAN;
  
  
  
  
  
  
  
  
  
  
  
  
  
        
        
        
        
        
        
        
        
        

    UPDATE OLIVER.TRAN_HEADER_TEMP_FUNDS
        SET
            THTF_PLAN_ID = NEW_PLAN
    WHERE
        THTF_CLIENT_ID = OLD_CLIENT
        AND   THTF_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TRAN_HEADER_TEMP_PEN
        SET
            THTP_PLAN_ID = NEW_PLAN
    WHERE
        THT_CLIENT_ID = OLD_CLIENT
        AND   THTP_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TRANSACTION_DETAIL
        SET
            TD_PLAN_ID = NEW_PLAN
    WHERE
        TD_CLIENT_ID = OLD_CLIENT
        AND   TD_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TRANSACTION_DETAIL_TEMP
        SET
            TDT_PLAN_ID = NEW_PLAN
    WHERE
        TDT_CLIENT_ID = OLD_CLIENT
        AND   TDT_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TRANSACTION_HEADER
        SET
            TH_PLAN_ID = NEW_PLAN
    WHERE
        TH_CLIENT_ID = OLD_CLIENT
        AND   TH_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TRANSACTION_HEADER_PEN
        SET
            THP_PLAN_ID = NEW_PLAN
    WHERE
        THP_CLIENT_ID = OLD_CLIENT
        AND   THP_PLAN_ID = OLD_PLAN;

    UPDATE OLIVER.TRANSACTION_HEADER_TEMP
        SET
            THT_PLAN_ID = NEW_PLAN
    WHERE
        THT_CLIENT_ID = OLD_CLIENT
        AND   THT_PLAN_ID = OLD_PLAN;

END UPDATE_PLAN;
/

