--
-- DEPOSIT_SLIP_CREATED  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.DEPOSIT_SLIP_CREATED
(PLAN_TYPE, CLIENTID, PLANID, EMPLOYER, EMPLOYER_NAME, 
 CONTRIBUTION_START_DATE, CONTRIBUTION_END_DATE, CONTRIBUTION_PERIOD, PAYMENT_RECD_AMOUNT, PAYMENT_TYPE, 
 TH_TRAN_ID, PAYMENT_REFERENCE, POSTED_DATE, DEPOSIT_NUMBER, TRAN_SOURCE)
AS 
SELECT 'HW' plan_type
         ,th_client_id clientid
         ,th_plan_id planid
         ,th_employer employer
         ,co_name employer_name
         ,th_start_date contribution_start_date
         ,th_end_date contribution_end_date
         ,th_period contribution_period
         ,th_amount payment_recd_amount
         ,th_payment_type payment_type
         ,th_tran_id
         ,th_cheque payment_reference
         ,th_posted_date posted_date
         ,th_deposit_number deposit_number
         ,'F'         
     FROM transaction_header, tbl_compmast
    WHERE th_client_id = co_client AND th_plan_id = co_plan AND th_employer = co_number AND th_deposit_number IS NOT NULL
   UNION ALL
   SELECT 'PENSION' plan_type
         ,thp_client_id
         ,thp_plan_id
         ,thp_employer
         ,co_name
         ,thp_start_date
         ,thp_end_date
         ,thp_period
         ,thp_amount
         ,thp_payment_type
         ,thp_tran_id
         ,thp_cheque
         ,thp_posted_date
         ,thp_deposit_number
         ,'F'         
     FROM transaction_header_pen, tbl_compmast
    WHERE thp_client_id = co_client AND thp_plan_id = co_plan AND thp_employer = co_number AND thp_deposit_number IS NOT NULL
   UNION ALL
   SELECT 'OTHER FUNDS' plan_type
         ,thf_client_id
         ,thf_plan_id
         ,thf_employer
         ,co_name
         ,thf_start_date
         ,thf_end_date
         ,thf_period
         ,thf_amount
         ,thf_payment_type
         ,thf_tran_id
         ,thf_cheque
         ,thf_posted_date
         ,thf_deposit_number
         ,'F'
     FROM transaction_header_funds, tbl_compmast
    WHERE thf_client_id = co_client AND thf_plan_id = co_plan AND thf_employer = co_number AND thf_deposit_number IS NOT NULL
        UNION
    SELECT 'HW' PLAN_TYPE
          ,THT_CLIENT_ID CLIENTID
          ,THT_PLAN_ID PLANID
          ,THT_EMPLOYER EMPLOYER
          ,CO_NAME EMPLOYER_NAME
          ,THT_START_DATE CONTRIBUTION_START_DATE
          ,THT_END_DATE CONTRIBUTION_END_DATE
          ,THT_PERIOD CONTRIBUTION_PERIOD
          ,THT_AMOUNT PAYMENT_RECD_AMOUNT
          ,THT_PAYMENT_TYPE PAYMENT_TYPE
          ,THT_TRAN_ID
          ,THT_CHEQUE PAYMENT_REFERENCE
          ,THT_POSTED_DATE POSTED_DATE
          ,THT_DEPOSIT_NUMBER
          ,'T'
      FROM transaction_header_temp, TBL_COMPMAST
      WHERE THT_CLIENT_ID = CO_CLIENT AND THT_PLAN_ID = CO_PLAN AND THT_EMPLOYER = CO_NUMBER AND THT_DEPOSIT_NUMBER IS NOT NULL AND NVL (tht_post, 'N') <> 'Y'
      UNION
      SELECT 'PENSION' PLAN_TYPE
          ,THT_CLIENT_ID
          ,THTP_PLAN_ID
          ,THTP_EMPLOYER
          ,CO_NAME
          ,THTP_START_DATE
          ,THTP_END_DATE
          ,THTP_PERIOD
          ,THTP_AMOUNT
          ,THTP_PAYMENT_TYPE
          ,THTP_TRAN_ID
          ,THTP_CHEQUE
          ,THTP_POSTED_DATE
          ,THTP_DEPOSIT_NUMBER          
          ,'T'
      FROM tran_header_temp_pen, TBL_COMPMAST
     WHERE THT_CLIENT_ID = CO_CLIENT AND THTP_PLAN_ID = CO_PLAN AND THTP_EMPLOYER = CO_NUMBER AND THTP_DEPOSIT_NUMBER IS NOT  NULL AND NVL (thtp_post, 'N') <> 'Y'
     UNION     
     SELECT 'OTHER FUNDS' PLAN_TYPE
          ,THTF_CLIENT_ID
          ,THTF_PLAN_ID
          ,THTF_EMPLOYER
          ,CO_NAME
          ,THTF_START_DATE
          ,THTF_END_DATE
          ,THTF_PERIOD
          ,THTF_AMOUNT
          ,THTF_PAYMENT_TYPE
          ,THTF_TRAN_ID
          ,THTF_CHEQUE
          ,THTF_POSTED_DATE
          ,THTF_DEPOSIT_NUMBER          
          ,'T'
      FROM TRAN_HEADER_TEMP_FUNDS, TBL_COMPMAST
     WHERE THTF_CLIENT_ID = CO_CLIENT AND THTF_PLAN_ID = CO_PLAN AND THTF_EMPLOYER = CO_NUMBER AND THTF_DEPOSIT_NUMBER IS NOT  NULL AND NVL (thtF_post, 'N') <> 'Y';


