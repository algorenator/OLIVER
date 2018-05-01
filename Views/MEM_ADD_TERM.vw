--
-- MEM_ADD_TERM  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.MEM_ADD_TERM
(MEM_CLIENT_ID, MEM_PLAN, MEM_ID, MEM_LAST_NAME, MEM_FIRST_NAME, 
 MEM_ADDRESS1, MEM_ADDRESS2, MEM_CITY, MEM_PROV, MEM_POSTAL_CODE, 
 HW_CLASS, HW_EMPLOYER, CO_NAME, BENEFIT_MONTH, MEM_GENDER, 
 MEM_DOB, HW_EFF_DATE, HW_TERM_DATE, STATUS)
AS 
( SELECT DISTINCT
        MEM_CLIENT_ID,
        MEM_PLAN,
        MEM_ID,
        MEM_LAST_NAME,
        MEM_FIRST_NAME,
        MEM_ADDRESS1,
        MEM_ADDRESS2,
        MEM_CITY,
        MEM_PROV,
        MEM_POSTAL_CODE,
        HW_CLASS,
        HW_EMPLOYER,
        CO_NAME,
        PL_HW_MONTHEND BENEFIT_MONTH,
        MEM_GENDER,
        MEM_DOB,
        HW_EFF_DATE,
        HW_TERM_DATE,
        DECODE(HW_TERM_DATE,NULL,'NEW MEMBER','TERMINATED') STATUS
      FROM
        TBL_MEMBER,
        TBL_HW,
        TBL_COMPMAST,
        TBL_PLAN
      WHERE
        PL_CLIENT_ID = MEM_CLIENT_ID
        AND   PL_CLIENT_ID = HW_CLIENT
        AND   PL_CLIENT_ID = CO_CLIENT
        AND   PL_ID = MEM_PLAN
        AND   MEM_ID = HW_ID
        AND   MEM_PLAN = HW_PLAN
        AND   NVL(HW_EMPLOYER,HR_BANK_PKG.GET_EMPLOYER(HW_CLIENT,HW_PLAN,HW_ID,SYSDATE) ) = CO_NUMBER (+)
        AND   (
            (
                HW_EFF_DATE >= PL_HW_MONTHEND
                AND   HW_TERM_DATE IS NULL
            )
            OR    (
                HW_TERM_DATE >= PL_HW_MONTHEND
                AND   HW_TERM_DATE IS NOT NULL
            )
        )
    );


