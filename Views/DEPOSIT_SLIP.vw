--
-- DEPOSIT_SLIP  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.DEPOSIT_SLIP
(PLAN_TYPE, CLIENTID, PLANID, EMPLOYER, EMPLOYER_NAME, 
 CONTRIBUTION_START_DATE, CONTRIBUTION_END_DATE, CONTRIBUTION_PERIOD, PAYMENT_RECD_AMOUNT, PAYMENT_TYPE, 
 TH_TRAN_ID, PAYMENT_REFERENCE, POSTED_DATE, TRAN_SOURCE)
AS 
(SELECT 'HW' PLAN_TYPE
          ,TH_CLIENT_ID CLIENTID
          ,TH_PLAN_ID PLANID
          ,TH_EMPLOYER EMPLOYER
          ,CO_NAME EMPLOYER_NAME
          ,TH_START_DATE CONTRIBUTION_START_DATE
          ,TH_END_DATE CONTRIBUTION_END_DATE
          ,TH_PERIOD CONTRIBUTION_PERIOD
          ,TH_AMOUNT PAYMENT_RECD_AMOUNT
          ,TH_PAYMENT_TYPE PAYMENT_TYPE
          ,TH_TRAN_ID
          ,TH_CHEQUE PAYMENT_REFERENCE
          ,TH_POSTED_DATE POSTED_DATE
          ,'F'
      FROM TRANSACTION_HEADER, TBL_COMPMAST
     WHERE TH_CLIENT_ID = CO_CLIENT AND TH_PLAN_ID = CO_PLAN AND TH_EMPLOYER = CO_NUMBER AND TH_DEPOSIT_NUMBER IS NULL)
   UNION ALL
   (SELECT 'PENSION' PLAN_TYPE
          ,THP_CLIENT_ID
          ,THP_PLAN_ID
          ,THP_EMPLOYER
          ,CO_NAME
          ,THP_START_DATE
          ,THP_END_DATE
          ,THP_PERIOD
          ,THP_AMOUNT
          ,THP_PAYMENT_TYPE
          ,THP_TRAN_ID
          ,THP_CHEQUE
          ,THP_POSTED_DATE
          ,'F'
      FROM TRANSACTION_HEADER_PEN, TBL_COMPMAST
     WHERE THP_CLIENT_ID = CO_CLIENT AND THP_PLAN_ID = CO_PLAN AND THP_EMPLOYER = CO_NUMBER AND THP_DEPOSIT_NUMBER IS NULL)
   UNION ALL
   (SELECT 'OTHER FUNDS' PLAN_TYPE
          ,THF_CLIENT_ID
          ,THF_PLAN_ID
          ,THF_EMPLOYER
          ,CO_NAME
          ,THF_START_DATE
          ,THF_END_DATE
          ,THF_PERIOD
          ,THF_AMOUNT
          ,THF_PAYMENT_TYPE
          ,THF_TRAN_ID
          ,THF_CHEQUE
          ,THF_POSTED_DATE
          ,'F'
      FROM TRANSACTION_HEADER_FUNDS, TBL_COMPMAST
     WHERE THF_CLIENT_ID = CO_CLIENT AND THF_PLAN_ID = CO_PLAN AND THF_EMPLOYER = CO_NUMBER AND THF_DEPOSIT_NUMBER IS NULL)
     -- added transaction info from temp processing tables #2886 --Alexey
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
          ,'T'
      FROM transaction_header_temp, TBL_COMPMAST
      WHERE THT_CLIENT_ID = CO_CLIENT AND THT_PLAN_ID = CO_PLAN AND THT_EMPLOYER = CO_NUMBER AND THT_DEPOSIT_NUMBER IS NULL AND NVL (tht_post, 'N') <> 'Y'
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
          ,'T'
      FROM tran_header_temp_pen, TBL_COMPMAST
     WHERE THT_CLIENT_ID = CO_CLIENT AND THTP_PLAN_ID = CO_PLAN AND THTP_EMPLOYER = CO_NUMBER AND THTP_DEPOSIT_NUMBER IS NULL AND NVL (thtp_post, 'N') <> 'Y'
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
          ,'T'
      FROM TRAN_HEADER_TEMP_FUNDS, TBL_COMPMAST
     WHERE THTF_CLIENT_ID = CO_CLIENT AND THTF_PLAN_ID = CO_PLAN AND THTF_EMPLOYER = CO_NUMBER AND THTF_DEPOSIT_NUMBER IS NULL AND NVL (thtF_post, 'N') <> 'Y';


