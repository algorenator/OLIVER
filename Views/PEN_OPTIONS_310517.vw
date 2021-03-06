--
-- PEN_OPTIONS_310517  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.PEN_OPTIONS_310517
(TPO_ID, TPH_CLIENT, TPH_PLAN, TPH_MEM_ID, TPH_RET_DATE, 
 TPO_PEN_FORM, PRE65_WO_INT, POST65_WO_INT, PRE65_W_INT, POST65_W_INT)
AS 
(SELECT TPO_ID, TPH_CLIENT,TPH_PLAN,TPH_MEM_ID,TPH_RET_DATE,TPO_PEN_FORM,TPO_PEN_AMT PRE65_WO_INT,TPO_PEN_AMT POST65_WO_INT,TPO_INT_AMT PRE65_W_INT,GREATEST((TPO_INT_AMT-(NVL(TPH_OAS_AMT,0)+NVL(TPH_CPP_AMT,0))),NVL(TPO_INT_AMT,0)) POST65_W_INT FROM  TBL_PEN_OPT_HEADER,TBL_PEN_OPT_DETAILS WHERE TPH_CLIENT=TPO_CLIENT AND TPH_PLAN=TPO_PLAN AND TPH_MEM_ID=TPO_MEM_ID);


