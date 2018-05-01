--
-- PEN_EMPLOYER_UNITS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.PEN_EMPLOYER_UNITS
(THP_CLIENT_ID, THP_PLAN_ID, THP_EMPLOYER, CO_NAME, THP_PERIOD, 
 THP_UNITS, THP_RATE, THP_AMOUNT, THP_VARIANCE_AMT, THP_COMMENT, 
 THP_PAYMENT_TYPE, THP_CHEQUE, THP_POSTED_DATE)
AS 
(select THP_CLIENT_ID,THP_plan_id,THP_employer,co_name,THP_period,THP_units,THP_rate,THP_amount,THP_variance_amt,THP_comment,THP_payment_type,THP_cheque,nvl(thp_posted_date,thp_period) THP_posted_date from transaction_header_PEN,tbl_compmast,TBL_PLAN where THP_CLIENT_ID=CO_CLIENT AND THP_CLIENT_ID=PL_CLIENT_ID AND co_plan=THP_plan_id and co_number=THP_employer AND CO_PLAN=PL_ID  AND PL_TYPE IN ('DBPP','DCPP'));


