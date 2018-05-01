--
-- ACTIVE_HW_EMPLOYEES  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.ACTIVE_HW_EMPLOYEES
(CO_CLIENT, CO_PLAN, CO_NUMBER, CO_NAME, MEM_ID, 
 MEM_LAST_NAME, MEM_FIRST_NAME, MEM_ADDRESS1, MEM_ADDRESS2, MEM_CITY, 
 MEM_PROV, MEM_POSTAL_CODE, HW_EFF_DATE, HW_TERM_DATE)
AS 
(SELECT CO_CLIENT,CO_PLAN,
    co_number,
    co_name,
    mem_id,
    mem_last_name,
    mem_first_name,
    mem_address1,
    mem_address2,
    mem_city,
    mem_prov,
    mem_postal_code,
    hw_eff_date,
    hw_term_date
  FROM tbl_member,
    tbl_hw,
    tbl_compmast
  WHERE MEM_CLIENT_ID=HW_CLIENT AND MEM_CLIENT_ID=CO_CLIENT AND mem_plan                                     =hw_plan
  AND mem_id                                         =hw_id
  AND hw_term_date                                  IS NULL
  AND CO_PLAN                                        =HW_PLAN
  AND hr_bank_pkg.get_employer(HW_CLIENT,hw_plan,hw_id,sysdate)=co_number(+)
  );


