--
-- VW_ANNUAL  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.VW_ANNUAL
(ANN_ID, ANN_PLAN, ANN_YEAR, ANN_STATUS, ANN_COMP, 
 ANN_EE_CONTS, ANN_ER_CONTS, ANN_EARNINGS, ANN_HRS, ANN_CRED_SERV, 
 ANN_PA, ANN_PEN_VALUE, ANN_LRD, ANN_CLIENT, ANN_VOL_UNITS, 
 EE_INT, ER_INT, VOL_INT, ANN_ACCOUNT)
AS 
SELECT
        "ANN_ID",
        "ANN_PLAN",
        "ANN_YEAR",
        "ANN_STATUS",
        "ANN_COMP",
        "ANN_EE_CONTS",
        "ANN_ER_CONTS",
        "ANN_EARNINGS",
        "ANN_HRS",
        "ANN_CRED_SERV",
        "ANN_PA",
        "ANN_PEN_VALUE",
        "ANN_LRD",
        "ANN_CLIENT",
        "ANN_VOL_UNITS",
    DECODE(nvl(ee_int,0),0,pension_pkg.calc_interest(ann_client,ann_plan,ann_id,ann_year,TO_DATE('31-DEC-'
    || TO_CHAR(ann_year),'DD-MON-RRRR'),'EE',ann_account),nvl(ee_int,0) ) ee_int,
    DECODE(nvl(er_int,0),0,pension_pkg.calc_interest(ann_client,ann_plan,ann_id,ann_year,TO_DATE('31-DEC-'
    || TO_CHAR(ann_year),'DD-MON-RRRR'),'ER',ann_account),nvl(er_int,0) ) er_int,
    DECODE(nvl(vol_int,0),0,pension_pkg.calc_interest(ann_client,ann_plan,ann_id,ann_year,TO_DATE('31-DEC-'
    || TO_CHAR(ann_year),'DD-MON-RRRR'),'VOL',ann_account),nvl(vol_int,0) ) vol_int,    
    "ANN_ACCOUNT"    
    FROM
        tbl_annual;


