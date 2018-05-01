--
-- PEN_CALC_TEST  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.PEN_CALC_TEST
(PENM_ID, DT_PENSION, CDAT_PENSION)
AS 
(select penm_id,NVL(penm_curr_pension,0)+NVL(PENM_PAST_PENSION,0) DT_PENSION ,pension_pkg.GET_PEN_MTHLY_PENSION('DT','GOT',PENM_ID,SYSDATE, MEM_DOB) cdat_pension FROM TBL_PENMAST,TBL_MEMBER WHERE MEM_ID=PENM_ID AND PENM_STATUS IN ('C'));


