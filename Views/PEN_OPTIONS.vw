--
-- PEN_OPTIONS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.PEN_OPTIONS
(TPO_ID, TPH_CLIENT, TPH_PLAN, TPH_MEM_ID, TPH_RET_DATE, 
 TPO_PEN_FORM, PRE65_WO_INT, POST65_WO_INT, PRE65_W_INT, POST65_W_INT, 
 TPO_CODE, OAS, CPP, OAS_CPP)
AS 
SELECT
        ROWNUM tpo_id,
        tph_client,
        tph_plan,
        tph_mem_id,
        tph_ret_date,
        tpo_pen_form,
        tpo_pen_amt pre65_wo_int,
        tpo_pen_amt post65_wo_int,
        tpo_int_amt pre65_w_int,
        ROUND(greatest(
            (tpo_PEN_amt -((1-NVL(TPO_INT_FACTOR,0))*(nvl(
                tph_oas_amt,
                0
            ) + nvl(
                tph_cpp_amt,
                0
            )) ) ),
           0
        ),2) post65_w_int,
        tpo_code,
        tph_oas_amT OAS,tph_CPP_amT CPP,NVL(tph_oas_amT,0)+NVL(TPH_CPP_AMT,0) OAS_CPP 
    FROM
        tbl_pen_opt_header,
        tbl_pen_opt_details
    WHERE
            tph_client = tpo_client
        AND
            tph_plan = tpo_plan
        AND
            tph_mem_id = tpo_mem_id;


