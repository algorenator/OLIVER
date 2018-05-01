--
-- PENSION_AIR  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.PENSION_AIR
(PENM_CLIENT, PENM_PLAN, MEM_PROV, PENM_STATUS, MALE, 
 FEMALE, UNKNOWN, TOTAL)
AS 
(select penm_client,penm_plan,MEM_PROV,penm_status,SUM(decode(UPPER(NVL(ltrim(rtrim(mem_gender)),'X')),'M',1,0)) MALE,SUM(decode(UPPER(NVL(ltrim(rtrim(mem_gender)),'X')),'F',1,0)) FEMALE, COUNT(*)-(SUM(decode(UPPER(NVL(ltrim(rtrim(mem_gender)),'X')),'F',1,0))+SUM(decode(UPPER(NVL(ltrim(rtrim(mem_gender)),'X')),'M',1,0))) UNKNOWN,count(*) TOTAL  from tbl_penmast,tbl_member where penm_client=mem_client_id and  penm_plan=mem_plan and mem_id=penm_id group by penm_client,penm_plan,MEM_PROV,penm_sTATUS);


