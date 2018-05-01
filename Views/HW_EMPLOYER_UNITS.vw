--
-- HW_EMPLOYER_UNITS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.HW_EMPLOYER_UNITS
(TH_CLIENT_ID, TH_PLAN_ID, TH_EMPLOYER, CO_NAME, TH_PERIOD, 
 TH_UNITS, TH_RATE, TH_AMOUNT, TH_VARIANCE_AMT, TH_COMMENT, 
 TH_PAYMENT_TYPE, TH_CHEQUE, TH_POSTED_DATE)
AS 
(select TH_CLIENT_ID,th_plan_id,th_employer,co_name,th_period,th_units,th_rate,th_amount,th_variance_amt,th_comment,th_payment_type,th_cheque,th_posted_date from transaction_header,tbl_compmast,TBL_PLAN where TH_CLIENT_ID=CO_CLIENT AND TH_CLIENT_ID=PL_CLIENT_ID AND co_plan=th_plan_id and CO_PLAN=PL_ID AND PL_TYPE IN ('HB') AND co_number=th_employer);


