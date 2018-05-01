--
-- PKG_DATA_EXTRACTION  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.PKG_DATA_EXTRACTION
IS
   G_MAIN_FILE_ROW         NUMBER;
   L_SECTION_TITLE_COLOR   VARCHAR2 (30) := '4286f4';
   L_SECTION_FONT_COLOR    VARCHAR2 (30) := 'ffffff';

   -- member information

   PROCEDURE MEMBER_XLSX_MI (P_CLIENT_ID    VARCHAR2,
                             P_PLAN_ID      VARCHAR2,
                             P_MEM_ID       VARCHAR2)
   IS
   BEGIN
      PKG_EXCEL_FILE.CELL (
         1,
         G_MAIN_FILE_ROW,
         'Member Information',
         P_BORDERID    => PKG_EXCEL_FILE.GET_BORDER,
         P_FILLID      => PKG_EXCEL_FILE.GET_FILL ('solid',
                                                   L_SECTION_TITLE_COLOR),
         P_FONTID      => PKG_EXCEL_FILE.GET_FONT (
                            'Calibri',
                            P_RGB   => L_SECTION_FONT_COLOR),
         P_ALIGNMENT   => PKG_EXCEL_FILE.GET_ALIGNMENT (
                            P_HORIZONTAL   => 'center'));

      FOR I IN 2 .. 5
      LOOP
         PKG_EXCEL_FILE.CELL (I,
                              G_MAIN_FILE_ROW,
                              '',
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      END LOOP;

      PKG_EXCEL_FILE.MERGECELLS (1,
                                 G_MAIN_FILE_ROW,
                                 5,
                                 G_MAIN_FILE_ROW);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      PKG_EXCEL_FILE.CELL (1,
                           G_MAIN_FILE_ROW,
                           'Name',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (2,
                           G_MAIN_FILE_ROW,
                           'Gender',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (3,
                           G_MAIN_FILE_ROW,
                           'Date of Birth',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (4,
                           G_MAIN_FILE_ROW,
                           'Age',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (5,
                           G_MAIN_FILE_ROW,
                           'Salary',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;

      FOR M
         IN (SELECT MEM_ID,
                       INITCAP (MEM_FIRST_NAME)
                    || ' '
                    || INITCAP (MEM_LAST_NAME)
                       NAME,
                    DECODE (MEM_GENDER,  'f', 'female',  'm', 'male') GENDER,
                    TO_CHAR (MEM_DOB, 'fmmonth fmdd, yyyy') DOB,
                       FLOOR (MONTHS_BETWEEN (SYSDATE, MEM_DOB) / 12)
                    || NVL2 (MEM_DOB, ' years old', '')
                       AGE,
                    TO_CHAR (GET_SALARY (MEM_CLIENT_ID,
                                         MEM_PLAN,
                                         MEM_ID,
                                         NULL,
                                         SYSDATE),
                             '$999,999.99')
                       SALARY
               FROM TBL_MEMBER
              WHERE     MEM_ID = P_MEM_ID
                    AND MEM_PLAN = P_PLAN_ID
                    AND MEM_CLIENT_ID = P_CLIENT_ID)
      LOOP
         PKG_EXCEL_FILE.CELL (1,
                              G_MAIN_FILE_ROW,
                              M.NAME,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (2,
                              G_MAIN_FILE_ROW,
                              M.GENDER,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (3,
                              G_MAIN_FILE_ROW,
                              M.DOB,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (4,
                              G_MAIN_FILE_ROW,
                              M.AGE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (5,
                              G_MAIN_FILE_ROW,
                              M.SALARY,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      END LOOP;

      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
   END MEMBER_XLSX_MI;

   -- marital status

   PROCEDURE MEMBER_XLSX_MS (P_CLIENT_ID    VARCHAR2,
                             P_PLAN_ID      VARCHAR2,
                             P_EMP_ID       VARCHAR2,
                             P_MEM_ID       VARCHAR2)
   IS
   BEGIN
      PKG_EXCEL_FILE.CELL (
         1,
         G_MAIN_FILE_ROW,
         'Marital Status',
         P_BORDERID    => PKG_EXCEL_FILE.GET_BORDER,
         P_FILLID      => PKG_EXCEL_FILE.GET_FILL ('solid',
                                                   L_SECTION_TITLE_COLOR),
         P_FONTID      => PKG_EXCEL_FILE.GET_FONT (
                            'Calibri',
                            P_RGB   => L_SECTION_FONT_COLOR),
         P_ALIGNMENT   => PKG_EXCEL_FILE.GET_ALIGNMENT (
                            P_HORIZONTAL   => 'center'));

      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;

      FOR S
         IN (SELECT C.DESCRIPTION
               FROM TBL_MARITAL_STATUS_CODES C, TBL_PENMAST P
              WHERE     P.PENM_CLIENT = P_CLIENT_ID
                    AND P.PENM_PLAN = P_PLAN_ID
                    AND P.PENM_ID = P_MEM_ID
                    AND P.PENM_EMPLOYER = P_EMP_ID
                    AND C.CODE = P.PENM_MARITAL_STATUS)
      LOOP
         PKG_EXCEL_FILE.CELL (1,
                              G_MAIN_FILE_ROW,
                              S.DESCRIPTION,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      END LOOP;

      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
   END MEMBER_XLSX_MS;

   -- current employment

   PROCEDURE MEMBER_XLSX_CE (P_CLIENT_ID    VARCHAR2,
                             P_PLAN_ID      VARCHAR2,
                             P_MEM_ID       VARCHAR2)
   IS
   BEGIN
      PKG_EXCEL_FILE.CELL (
         1,
         G_MAIN_FILE_ROW,
         'Current Employment',
         P_BORDERID    => PKG_EXCEL_FILE.GET_BORDER,
         P_FILLID      => PKG_EXCEL_FILE.GET_FILL ('solid',
                                                   L_SECTION_TITLE_COLOR),
         P_FONTID      => PKG_EXCEL_FILE.GET_FONT (
                            'Calibri',
                            P_RGB   => L_SECTION_FONT_COLOR),
         P_ALIGNMENT   => PKG_EXCEL_FILE.GET_ALIGNMENT (
                            P_HORIZONTAL   => 'center'));

      FOR I IN 2 .. 8
      LOOP
         PKG_EXCEL_FILE.CELL (I,
                              G_MAIN_FILE_ROW,
                              '',
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      END LOOP;

      PKG_EXCEL_FILE.MERGECELLS (1,
                                 G_MAIN_FILE_ROW,
                                 8,
                                 G_MAIN_FILE_ROW);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      PKG_EXCEL_FILE.CELL (1,
                           G_MAIN_FILE_ROW,
                           'Company Name',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (2,
                           G_MAIN_FILE_ROW,
                           'Job Type',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (3,
                           G_MAIN_FILE_ROW,
                           'Hire Date',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (4,
                           G_MAIN_FILE_ROW,
                           'Salary',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (5,
                           G_MAIN_FILE_ROW,
                           'Union Local',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (6,
                           G_MAIN_FILE_ROW,
                           'Agreement',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (7,
                           G_MAIN_FILE_ROW,
                           'Effective Date',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (8,
                           G_MAIN_FILE_ROW,
                           'Termination Date',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;

      FOR E
         IN (SELECT CO_NAME,
                    TO_DESC JOB_TYPE,
                    TEH_HIRE_DATE,
                    DECODE (TEH_SALARY, 0, NULL, TEH_SALARY) TEH_SALARY,
                    TEH_UNION_LOCAL,
                    TA_DESC,
                    TEH_EFF_DATE,
                    TEH_TREM_DATE
               FROM (  SELECT INITCAP (CO_NAME) CO_NAME,
                              TO_DESC,
                              TEH_HIRE_DATE,
                              TEH_SALARY,
                              TEH_EFF_DATE,
                              H.TEH_UNION_LOCAL,
                              A.TA_DESC,
                              TEH_TREM_DATE
                         FROM (SELECT *
                                 FROM TBL_EMPLOYMENT_HIST
                                WHERE     TEH_PLAN = P_PLAN_ID
                                      AND TEH_CLIENT = P_CLIENT_ID) H
                              INNER JOIN
                              (SELECT *
                                 FROM TBL_COMPMAST
                                WHERE     CO_PLAN = P_PLAN_ID
                                      AND CO_CLIENT = P_CLIENT_ID) C
                                 ON H.TEH_ER_ID = C.CO_NUMBER
                              LEFT OUTER JOIN
                              (SELECT *
                                 FROM TBL_AGREEMENT
                                WHERE     TA_PLAN_ID = P_PLAN_ID
                                      AND TA_CLIENT_ID = P_CLIENT_ID) A
                                 ON H.TEH_AGREE_ID = A.TA_ID
                              LEFT OUTER JOIN
                              (SELECT *
                                 FROM TBL_OCCUPATIONS
                                WHERE     TO_PLAN = P_PLAN_ID
                                      AND TO_CLIENT = P_CLIENT_ID) O
                                 ON O.TO_CODE = H.TEH_OCCU
                        WHERE TEH_ID = P_MEM_ID
                     ORDER BY TEH_EFF_DATE DESC)
              WHERE ROWNUM = 1)
      LOOP
         PKG_EXCEL_FILE.CELL (1,
                              G_MAIN_FILE_ROW,
                              E.CO_NAME,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (2,
                              G_MAIN_FILE_ROW,
                              E.JOB_TYPE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (3,
                              G_MAIN_FILE_ROW,
                              E.TEH_HIRE_DATE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (4,
                              G_MAIN_FILE_ROW,
                              E.TEH_SALARY,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (5,
                              G_MAIN_FILE_ROW,
                              E.TEH_UNION_LOCAL,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (6,
                              G_MAIN_FILE_ROW,
                              E.TA_DESC,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (7,
                              G_MAIN_FILE_ROW,
                              E.TEH_EFF_DATE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (8,
                              G_MAIN_FILE_ROW,
                              E.TEH_TREM_DATE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      END LOOP;

      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
   END MEMBER_XLSX_CE;

   -- contact details

   PROCEDURE MEMBER_XLSX_CD (P_CLIENT_ID    VARCHAR2,
                             P_PLAN_ID      VARCHAR2,
                             P_MEM_ID       VARCHAR2)
   IS
   BEGIN
      PKG_EXCEL_FILE.CELL (
         1,
         G_MAIN_FILE_ROW,
         'Contact Details',
         P_BORDERID    => PKG_EXCEL_FILE.GET_BORDER,
         P_FILLID      => PKG_EXCEL_FILE.GET_FILL ('solid',
                                                   L_SECTION_TITLE_COLOR),
         P_FONTID      => PKG_EXCEL_FILE.GET_FONT (
                            'Calibri',
                            P_RGB   => L_SECTION_FONT_COLOR),
         P_ALIGNMENT   => PKG_EXCEL_FILE.GET_ALIGNMENT (
                            P_HORIZONTAL   => 'center'));

      FOR I IN 2 .. 7
      LOOP
         PKG_EXCEL_FILE.CELL (I,
                              G_MAIN_FILE_ROW,
                              '',
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      END LOOP;

      PKG_EXCEL_FILE.MERGECELLS (1,
                                 G_MAIN_FILE_ROW,
                                 7,
                                 G_MAIN_FILE_ROW);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      PKG_EXCEL_FILE.CELL (1,
                           G_MAIN_FILE_ROW,
                           'SIN',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (2,
                           G_MAIN_FILE_ROW,
                           'Address',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (3,
                           G_MAIN_FILE_ROW,
                           'City',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (4,
                           G_MAIN_FILE_ROW,
                           'Province',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (5,
                           G_MAIN_FILE_ROW,
                           'Postal Code',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (6,
                           G_MAIN_FILE_ROW,
                           'Phone (Work)',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (7,
                           G_MAIN_FILE_ROW,
                           'Phone (Home)',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;

      FOR E
         IN (SELECT MEM_SIN,
                    INITCAP (MEM_ADDRESS1) MEM_ADDRESS,
                    INITCAP (MEM_CITY) MEM_CITY,
                    UPPER (MEM_PROV) MEM_PROV,
                    MEM_POSTAL_CODE,
                    MEM_WORK_PHONE,
                    MEM_HOME_PHONE
               FROM TBL_MEMBER
              WHERE     MEM_ID = P_MEM_ID
                    AND MEM_CLIENT_ID = P_CLIENT_ID
                    AND MEM_PLAN = P_PLAN_ID)
      LOOP
         PKG_EXCEL_FILE.CELL (1,
                              G_MAIN_FILE_ROW,
                              E.MEM_SIN,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (2,
                              G_MAIN_FILE_ROW,
                              E.MEM_ADDRESS,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (3,
                              G_MAIN_FILE_ROW,
                              E.MEM_CITY,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (4,
                              G_MAIN_FILE_ROW,
                              E.MEM_PROV,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (5,
                              G_MAIN_FILE_ROW,
                              E.MEM_POSTAL_CODE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (6,
                              G_MAIN_FILE_ROW,
                              E.MEM_WORK_PHONE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (7,
                              G_MAIN_FILE_ROW,
                              E.MEM_HOME_PHONE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      END LOOP;

      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
   END MEMBER_XLSX_CD;

   -- notes

   PROCEDURE MEMBER_XLSX_NT (P_CLIENT_ID    VARCHAR2,
                             P_PLAN_ID      VARCHAR2,
                             P_MEM_ID       VARCHAR2)
   IS
   BEGIN
      PKG_EXCEL_FILE.CELL (
         1,
         G_MAIN_FILE_ROW,
         'Notes',
         P_BORDERID    => PKG_EXCEL_FILE.GET_BORDER,
         P_FILLID      => PKG_EXCEL_FILE.GET_FILL ('solid',
                                                   L_SECTION_TITLE_COLOR),
         P_FONTID      => PKG_EXCEL_FILE.GET_FONT (
                            'Calibri',
                            P_RGB   => L_SECTION_FONT_COLOR),
         P_ALIGNMENT   => PKG_EXCEL_FILE.GET_ALIGNMENT (
                            P_HORIZONTAL   => 'center'));

      FOR I IN 2 .. 5
      LOOP
         PKG_EXCEL_FILE.CELL (I,
                              G_MAIN_FILE_ROW,
                              '',
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      END LOOP;

      PKG_EXCEL_FILE.MERGECELLS (1,
                                 G_MAIN_FILE_ROW,
                                 5,
                                 G_MAIN_FILE_ROW);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      PKG_EXCEL_FILE.CELL (1,
                           G_MAIN_FILE_ROW,
                           'Create Date',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (2,
                           G_MAIN_FILE_ROW,
                           'Subject',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (3,
                           G_MAIN_FILE_ROW,
                           'Note',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (4,
                           G_MAIN_FILE_ROW,
                           'Last Modified',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (5,
                           G_MAIN_FILE_ROW,
                           'Modified By',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;

      FOR N
         IN (  SELECT MN_DATE,
                      MN_TYPE,
                      MN_NOTE,
                      MN_LAST_MODIFIED_DATE,
                      MN_LAST_MODIFIED_BY
                 FROM TBL_MEMBER_NOTES
                WHERE     MN_PLAN_ID = P_PLAN_ID
                      AND TMN_CLIENT = P_CLIENT_ID
                      AND MN_ID = P_MEM_ID
             ORDER BY MN_DATE DESC)
      LOOP
         PKG_EXCEL_FILE.CELL (1,
                              G_MAIN_FILE_ROW,
                              TO_CHAR (N.MN_DATE, 'DD-MON-YYYY'),
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (2,
                              G_MAIN_FILE_ROW,
                              N.MN_TYPE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (3,
                              G_MAIN_FILE_ROW,
                              N.MN_NOTE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (
            4,
            G_MAIN_FILE_ROW,
            TO_CHAR (N.MN_LAST_MODIFIED_DATE, 'DD-MON-YYYY'),
            P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (5,
                              G_MAIN_FILE_ROW,
                              N.MN_LAST_MODIFIED_BY,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      END LOOP;

      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
   END MEMBER_XLSX_NT;

   -- pension summary

   PROCEDURE MEMBER_XLSX_PS (P_CLIENT_ID    VARCHAR2,
                             P_PLAN_ID      VARCHAR2,
                             P_MEM_ID       VARCHAR2)
   IS
   BEGIN
      PKG_EXCEL_FILE.CELL (
         1,
         G_MAIN_FILE_ROW,
         'Plan Summary',
         P_BORDERID    => PKG_EXCEL_FILE.GET_BORDER,
         P_FILLID      => PKG_EXCEL_FILE.GET_FILL ('solid',
                                                   L_SECTION_TITLE_COLOR),
         P_FONTID      => PKG_EXCEL_FILE.GET_FONT (
                            'Calibri',
                            P_RGB   => L_SECTION_FONT_COLOR),
         P_ALIGNMENT   => PKG_EXCEL_FILE.GET_ALIGNMENT (
                            P_HORIZONTAL   => 'center'));

      FOR I IN 2 .. 6
      LOOP
         PKG_EXCEL_FILE.CELL (I,
                              G_MAIN_FILE_ROW,
                              '',
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      END LOOP;

      PKG_EXCEL_FILE.MERGECELLS (1,
                                 G_MAIN_FILE_ROW,
                                 6,
                                 G_MAIN_FILE_ROW);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      PKG_EXCEL_FILE.CELL (1,
                           G_MAIN_FILE_ROW,
                           'Status',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (2,
                           G_MAIN_FILE_ROW,
                           'Status Date',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (3,
                           G_MAIN_FILE_ROW,
                           'Current Pension',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (4,
                           G_MAIN_FILE_ROW,
                           'Past Pension (NLI)',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (5,
                           G_MAIN_FILE_ROW,
                           'Past Pension (LI)',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (6,
                           G_MAIN_FILE_ROW,
                           'Total Pension',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;

      FOR S
         IN (SELECT NVL (INITCAP (TPS_STATUS_DESC), 'N/A') PENM_STATUS,
                    PENM_STATUS_DATE,
                    PENM_CURR_PENSION,
                    PENM_PAST_PENSION,
                    PENM_PAST_PENSION_LI,
                    (  NVL (PENM_PAST_PENSION, 0)
                     + NVL (PENM_CURR_PENSION, 0)
                     + NVL (PENM_PAST_PENSION_LI, 0))
                       TOTAL_PEN
               FROM TBL_PENMAST P
                    INNER JOIN TBL_PENSION_STATUS S
                       ON P.PENM_STATUS = S.TPS_STATUS
              WHERE     PENM_ID = P_MEM_ID
                    AND PENM_CLIENT = P_CLIENT_ID
                    AND PENM_PLAN = P_PLAN_ID)
      LOOP
         PKG_EXCEL_FILE.CELL (1,
                              G_MAIN_FILE_ROW,
                              S.PENM_STATUS,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (2,
                              G_MAIN_FILE_ROW,
                              TO_CHAR (S.PENM_STATUS_DATE, 'DD-MON-YYYY'),
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (3,
                              G_MAIN_FILE_ROW,
                              S.PENM_CURR_PENSION,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (4,
                              G_MAIN_FILE_ROW,
                              S.PENM_PAST_PENSION,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (5,
                              G_MAIN_FILE_ROW,
                              S.PENM_PAST_PENSION_LI,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (6,
                              G_MAIN_FILE_ROW,
                              S.TOTAL_PEN,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      END LOOP;

      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
   END MEMBER_XLSX_PS;

   -- beneficiaries

   PROCEDURE MEMBER_XLSX_BE (P_CLIENT_ID    VARCHAR2,
                             P_PLAN_ID      VARCHAR2,
                             P_MEM_ID       VARCHAR2)
   IS
   BEGIN
      PKG_EXCEL_FILE.CELL (
         1,
         G_MAIN_FILE_ROW,
         'Beneficiaries',
         P_BORDERID    => PKG_EXCEL_FILE.GET_BORDER,
         P_FILLID      => PKG_EXCEL_FILE.GET_FILL ('solid',
                                                   L_SECTION_TITLE_COLOR),
         P_FONTID      => PKG_EXCEL_FILE.GET_FONT (
                            'Calibri',
                            P_RGB   => L_SECTION_FONT_COLOR),
         P_ALIGNMENT   => PKG_EXCEL_FILE.GET_ALIGNMENT (
                            P_HORIZONTAL   => 'center'));

      FOR I IN 2 .. 3
      LOOP
         PKG_EXCEL_FILE.CELL (I,
                              G_MAIN_FILE_ROW,
                              '',
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      END LOOP;

      PKG_EXCEL_FILE.MERGECELLS (1,
                                 G_MAIN_FILE_ROW,
                                 3,
                                 G_MAIN_FILE_ROW);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      PKG_EXCEL_FILE.CELL (1,
                           G_MAIN_FILE_ROW,
                           'Beneficiary',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (2,
                           G_MAIN_FILE_ROW,
                           'First Name',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (3,
                           G_MAIN_FILE_ROW,
                           'Last Name',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;

      FOR B
         IN (SELECT NVL (PB_BEN_NO, ROWNUM) PB_BEN_NO,
                    INITCAP (PB_FIRST_NAME) PB_FIRST_NAME,
                    INITCAP (PB_LAST_NAME) PB_LAST_NAME,
                    PB_KEY LINK
               FROM TBL_PEN_BENEFICIARY
              WHERE     PB_ID = P_MEM_ID
                    AND PB_CLIENT = P_CLIENT_ID
                    AND PB_PLAN = P_PLAN_ID
                    AND NVL (PB_RELATION, 'XX') <> 'SP')
      LOOP
         PKG_EXCEL_FILE.CELL (1,
                              G_MAIN_FILE_ROW,
                              B.PB_BEN_NO,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (2,
                              G_MAIN_FILE_ROW,
                              B.PB_FIRST_NAME,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (3,
                              G_MAIN_FILE_ROW,
                              B.PB_LAST_NAME,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      END LOOP;

      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
   END MEMBER_XLSX_BE;

   -- dependents

   PROCEDURE MEMBER_XLSX_DP (P_CLIENT_ID    VARCHAR2,
                             P_PLAN_ID      VARCHAR2,
                             P_MEM_ID       VARCHAR2)
   IS
   BEGIN
      PKG_EXCEL_FILE.CELL (
         1,
         G_MAIN_FILE_ROW,
         'Dependents',
         P_BORDERID    => PKG_EXCEL_FILE.GET_BORDER,
         P_FILLID      => PKG_EXCEL_FILE.GET_FILL ('solid',
                                                   L_SECTION_TITLE_COLOR),
         P_FONTID      => PKG_EXCEL_FILE.GET_FONT (
                            'Calibri',
                            P_RGB   => L_SECTION_FONT_COLOR),
         P_ALIGNMENT   => PKG_EXCEL_FILE.GET_ALIGNMENT (
                            P_HORIZONTAL   => 'center'));

      FOR I IN 2 .. 5
      LOOP
         PKG_EXCEL_FILE.CELL (I,
                              G_MAIN_FILE_ROW,
                              '',
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      END LOOP;

      PKG_EXCEL_FILE.MERGECELLS (1,
                                 G_MAIN_FILE_ROW,
                                 5,
                                 G_MAIN_FILE_ROW);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      PKG_EXCEL_FILE.CELL (1,
                           G_MAIN_FILE_ROW,
                           'Dependent Name',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (2,
                           G_MAIN_FILE_ROW,
                           'DOB',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (3,
                           G_MAIN_FILE_ROW,
                           'Gender',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (4,
                           G_MAIN_FILE_ROW,
                           'Relation',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (5,
                           G_MAIN_FILE_ROW,
                           'Effective Date',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;

      FOR D
         IN (SELECT INITCAP (HD_FIRST_NAME) || ' ' || INITCAP (HD_LAST_NAME)
                       DEP_NAME,
                    TO_CHAR (HD_DOB, 'DD-MON-YYYY') DOB,
                    HD_SEX GENDER,
                    (SELECT R_DESCRIPTION
                       FROM TBL_RELATIONS
                      WHERE     PLAN_ID = HD_PLAN
                            AND CLIENT_ID = HD_CLIENT
                            AND R_CODE = HD_RELATION)
                       RELATION,
                    TO_CHAR (HD_EFF_DATE, 'DD-MON-YYYY') EFF_DATE
               FROM TBL_HW_DEPENDANTS
              WHERE     HD_ID = P_MEM_ID
                    AND HD_CLIENT = P_CLIENT_ID
                    AND HD_PLAN = P_PLAN_ID)
      LOOP
         PKG_EXCEL_FILE.CELL (1,
                              G_MAIN_FILE_ROW,
                              D.DEP_NAME,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (2,
                              G_MAIN_FILE_ROW,
                              D.DOB,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (3,
                              G_MAIN_FILE_ROW,
                              D.GENDER,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (4,
                              G_MAIN_FILE_ROW,
                              D.RELATION,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (5,
                              G_MAIN_FILE_ROW,
                              D.EFF_DATE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      END LOOP;

      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
   END MEMBER_XLSX_DP;

   -- hour bank

   PROCEDURE MEMBER_XLSX_HB (P_CLIENT_ID    VARCHAR2,
                             P_PLAN_ID      VARCHAR2,
                             P_MEM_ID       VARCHAR2)
   IS
   BEGIN
      PKG_EXCEL_FILE.CELL (
         1,
         G_MAIN_FILE_ROW,
         'Hour Bank',
         P_BORDERID    => PKG_EXCEL_FILE.GET_BORDER,
         P_FILLID      => PKG_EXCEL_FILE.GET_FILL ('solid',
                                                   L_SECTION_TITLE_COLOR),
         P_FONTID      => PKG_EXCEL_FILE.GET_FONT (
                            'Calibri',
                            P_RGB   => L_SECTION_FONT_COLOR),
         P_ALIGNMENT   => PKG_EXCEL_FILE.GET_ALIGNMENT (
                            P_HORIZONTAL   => 'center'));

      FOR I IN 2 .. 8
      LOOP
         PKG_EXCEL_FILE.CELL (I,
                              G_MAIN_FILE_ROW,
                              '',
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      END LOOP;

      PKG_EXCEL_FILE.MERGECELLS (1,
                                 G_MAIN_FILE_ROW,
                                 8,
                                 G_MAIN_FILE_ROW);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      PKG_EXCEL_FILE.CELL (1,
                           G_MAIN_FILE_ROW,
                           'Is Eligible?',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (2,
                           G_MAIN_FILE_ROW,
                           'Employer',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (3,
                           G_MAIN_FILE_ROW,
                           'Work month',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (4,
                           G_MAIN_FILE_ROW,
                           'Eligibility Month',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (5,
                           G_MAIN_FILE_ROW,
                           'Hours',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (6,
                           G_MAIN_FILE_ROW,
                           'Deduct Hrs',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (7,
                           G_MAIN_FILE_ROW,
                           'Closing Hrs',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      PKG_EXCEL_FILE.CELL (8,
                           G_MAIN_FILE_ROW,
                           'Posted Date',
                           P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);
      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;

      FOR H
         IN (  SELECT THB_EMPLOYER,
                      TO_CHAR (THB_MONTH, 'Mon yyyy') WORK_MONTH,
                      TO_CHAR (ADD_MONTHS (THB_MONTH, 2), 'Mon YYYY')
                         ELIG_MONTH,
                      THB_HOURS,
                      THB_DEDUCT_HRS,
                      THB_CLOSING_HRS,
                      TO_CHAR (THB_POSTED_DATE, 'DD-MON-YYYY') THB_POSTED_DATE,
                      IS_ELIGIBLE (P_PLAN_ID,
                                   NULL,
                                   P_MEM_ID,
                                   ADD_MONTHS (THB_MONTH, 2),
                                   P_CLIENT_ID)
                         IS_ELIGIBLE
                 FROM TBL_HR_BANK
                WHERE     THB_PLAN = P_PLAN_ID
                      AND THB_CLIENT_ID = P_CLIENT_ID
                      AND THB_ID = P_MEM_ID
             ORDER BY THB_MONTH DESC)
      LOOP
         PKG_EXCEL_FILE.CELL (1,
                              G_MAIN_FILE_ROW,
                              H.IS_ELIGIBLE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (2,
                              G_MAIN_FILE_ROW,
                              H.THB_EMPLOYER,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (3,
                              G_MAIN_FILE_ROW,
                              H.WORK_MONTH,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (4,
                              G_MAIN_FILE_ROW,
                              H.ELIG_MONTH,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (5,
                              G_MAIN_FILE_ROW,
                              H.THB_HOURS,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (6,
                              G_MAIN_FILE_ROW,
                              H.THB_DEDUCT_HRS,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (7,
                              G_MAIN_FILE_ROW,
                              H.THB_CLOSING_HRS,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         PKG_EXCEL_FILE.CELL (8,
                              G_MAIN_FILE_ROW,
                              H.THB_POSTED_DATE,
                              P_BORDERID   => PKG_EXCEL_FILE.GET_BORDER);

         G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
      END LOOP;

      G_MAIN_FILE_ROW := G_MAIN_FILE_ROW + 1;
   END MEMBER_XLSX_HB;

   --
   -- p_content parameter has two members: content_type and destination
   -- posible values for p_content.content_type are:
   --   2 => marital status
   --   3 => current employment
   --   4 => contact details
   --   5 => notes
   --   6 => pension summary
   --   7 => beneficiaries
   --   8 => dependants
   --   9 => hour bank
   --   10 => plan summary
   --   11 => transactions
   -- possible values for p_content.destination are:
   --   M => Main File
   --   S => Separate File
   --   N => Do Not Generate
   --

   PROCEDURE MEMBER_XLSX (P_CLIENT_ID    VARCHAR2,
                          P_PLAN_ID      VARCHAR2,
                          P_EMP_ID       VARCHAR2,
                          P_MEM_ID       VARCHAR2,
                          P_CONTENT      T_CONTENT)
   IS
      L_FILE   BLOB;

      PROCEDURE SEPARATE_FILE (P_CONTENT_TYPE VARCHAR2)
      IS
         L_FILE_NAME   VARCHAR2 (255);
      BEGIN
         -- create separate file
         PKG_EXCEL_FILE.CLEAR_WORKBOOK;
         PKG_EXCEL_FILE.NEW_SHEET;
         G_MAIN_FILE_ROW := 1;

         -- generate the file content
         IF P_CONTENT_TYPE = '2'
         THEN                                                -- marital status
            MEMBER_XLSX_MS (P_CLIENT_ID,
                            P_PLAN_ID,
                            P_EMP_ID,
                            P_MEM_ID);
            L_FILE_NAME :=
                  'member_'
               || P_MEM_ID
               || '_employer_'
               || P_EMP_ID
               || '_marital_status.xlsx';
         ELSIF P_CONTENT_TYPE = '3'
         THEN                                            -- current employment
            MEMBER_XLSX_CE (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
            L_FILE_NAME :=
                  'member_'
               || P_MEM_ID
               || '_employer_'
               || P_EMP_ID
               || '_curr_empl.xlsx';
         ELSIF P_CONTENT_TYPE = '4'
         THEN                                               -- contact details
            MEMBER_XLSX_CD (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
            L_FILE_NAME :=
                  'member_'
               || P_MEM_ID
               || '_employer_'
               || P_EMP_ID
               || '_contact_det.xlsx';
         ELSIF P_CONTENT_TYPE = '5'
         THEN                                                         -- notes
            MEMBER_XLSX_NT (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
            L_FILE_NAME :=
                  'member_'
               || P_MEM_ID
               || '_employer_'
               || P_EMP_ID
               || '_notes.xlsx';
         ELSIF P_CONTENT_TYPE = '6'
         THEN                                               -- pension summary
            MEMBER_XLSX_PS (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
            L_FILE_NAME :=
                  'member_'
               || P_MEM_ID
               || '_employer_'
               || P_EMP_ID
               || '_pen_sum.xlsx';
         ELSIF P_CONTENT_TYPE = '7'
         THEN                                                 -- beneficiaries
            MEMBER_XLSX_BE (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
            L_FILE_NAME :=
                  'member_'
               || P_MEM_ID
               || '_employer_'
               || P_EMP_ID
               || '_beneficiaries.xlsx';
         ELSIF P_CONTENT_TYPE = '8'
         THEN                                                    -- dependents
            MEMBER_XLSX_DP (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
            L_FILE_NAME :=
                  'member_'
               || P_MEM_ID
               || '_employer_'
               || P_EMP_ID
               || '_dependents.xlsx';
         ELSIF P_CONTENT_TYPE = '9'
         THEN                                                     -- hour bank
            MEMBER_XLSX_HB (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
            L_FILE_NAME :=
                  'member_'
               || P_MEM_ID
               || '_employer_'
               || P_EMP_ID
               || '_hour_bank.xlsx';
         END IF;

         -- store the separate file temporarily for later download

         IF L_FILE_NAME IS NOT NULL
         THEN
            L_FILE := PKG_EXCEL_FILE.FINISH;

            INSERT INTO TBL_TEMPORARY_FILES (FILE_NAME,
                                             FILE_BLOB,
                                             FILE_LENGTH,
                                             MIME_TYPE)
                    VALUES (
                              L_FILE_NAME,
                              L_FILE,
                              DBMS_LOB.GETLENGTH (L_FILE),
                              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
         END IF;

         IF DBMS_LOB.ISTEMPORARY (L_FILE) = 1
         THEN
            DBMS_LOB.FREETEMPORARY (L_FILE);
         END IF;
      END SEPARATE_FILE;
   BEGIN
      -- start on spreadsheet's first row
      G_MAIN_FILE_ROW := 1;

      -- clear temporary file's table used for later download
      EXECUTE IMMEDIATE 'delete tbl_temporary_files';

      -- create the main file first (*** the excel package only works for ONE file at time ***)
      PKG_EXCEL_FILE.CLEAR_WORKBOOK;
      PKG_EXCEL_FILE.NEW_SHEET;
      -- member information (always generated)
      MEMBER_XLSX_MI (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);

      -- select only content to include into main file
      FOR I IN 1 .. P_CONTENT.COUNT
      LOOP
         -- marital status
         IF     P_CONTENT (I).CONTENT_TYPE = '2'
            AND P_CONTENT (I).DESTINATION = 'M'
         THEN
            MEMBER_XLSX_MS (P_CLIENT_ID,
                            P_PLAN_ID,
                            P_EMP_ID,
                            P_MEM_ID);
         END IF;

         -- current employment

         IF     P_CONTENT (I).CONTENT_TYPE = '3'
            AND P_CONTENT (I).DESTINATION = 'M'
         THEN
            MEMBER_XLSX_CE (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
         END IF;

         -- contact details

         IF     P_CONTENT (I).CONTENT_TYPE = '4'
            AND P_CONTENT (I).DESTINATION = 'M'
         THEN
            MEMBER_XLSX_CD (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
         END IF;

         -- notes

         IF     P_CONTENT (I).CONTENT_TYPE = '5'
            AND P_CONTENT (I).DESTINATION = 'M'
         THEN
            MEMBER_XLSX_NT (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
         END IF;

         -- pension summary

         IF     P_CONTENT (I).CONTENT_TYPE = '6'
            AND P_CONTENT (I).DESTINATION = 'M'
         THEN
            MEMBER_XLSX_PS (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
         END IF;

         -- beneficiaries

         IF     P_CONTENT (I).CONTENT_TYPE = '7'
            AND P_CONTENT (I).DESTINATION = 'M'
         THEN
            MEMBER_XLSX_BE (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
         END IF;

         -- dependents

         IF     P_CONTENT (I).CONTENT_TYPE = '8'
            AND P_CONTENT (I).DESTINATION = 'M'
         THEN
            MEMBER_XLSX_DP (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
         END IF;

         -- hour bank

         IF     P_CONTENT (I).CONTENT_TYPE = '9'
            AND P_CONTENT (I).DESTINATION = 'M'
         THEN
            MEMBER_XLSX_HB (P_CLIENT_ID, P_PLAN_ID, P_MEM_ID);
         END IF;
      END LOOP;

      -- store the main file temporarily for later download

      L_FILE := PKG_EXCEL_FILE.FINISH;

      INSERT INTO TBL_TEMPORARY_FILES (FILE_NAME,
                                       FILE_BLOB,
                                       FILE_LENGTH,
                                       MIME_TYPE)
              VALUES (
                           'member_'
                        || P_MEM_ID
                        || '_employer_'
                        || P_EMP_ID
                        || '.xlsx',
                        L_FILE,
                        DBMS_LOB.GETLENGTH (L_FILE),
                        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

      IF DBMS_LOB.ISTEMPORARY (L_FILE) = 1
      THEN
         DBMS_LOB.FREETEMPORARY (L_FILE);
      END IF;

      -- select only content to generate separate files

      FOR I IN 1 .. P_CONTENT.COUNT
      LOOP
         IF P_CONTENT (I).DESTINATION = 'S'
         THEN
            SEPARATE_FILE (P_CONTENT (I).CONTENT_TYPE);
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- if logged in apex
         IF APEX_CUSTOM_AUTH.IS_SESSION_VALID
         THEN
            SYS.HTP.PRN ('error: ' || SQLERRM);
            APEX_APPLICATION.STOP_APEX_ENGINE;
         ELSE
            DBMS_OUTPUT.PUT_LINE (SQLERRM);
         END IF;
   END MEMBER_XLSX;

   PROCEDURE DOWNLOAD_FILES
   IS
      L_ZIP_FILE   BLOB;
   BEGIN
      -- check if there are more than one file and compress them
      FOR F
         IN (SELECT FILE_NAME,
                    FILE_BLOB,
                    COUNT (*) OVER (PARTITION BY NULL) CNT
               FROM TBL_TEMPORARY_FILES)
      LOOP
         IF F.CNT > 1
         THEN
            APEX_ZIP.ADD_FILE (L_ZIP_FILE, F.FILE_NAME, F.FILE_BLOB);
         END IF;
      END LOOP;

      -- keep only the zip file

      IF L_ZIP_FILE IS NOT NULL AND DBMS_LOB.GETLENGTH (L_ZIP_FILE) > 0
      THEN
         APEX_ZIP.FINISH (L_ZIP_FILE);

         -- clear temporary file's table
         EXECUTE IMMEDIATE 'delete tbl_temporary_files';

         -- store the zip file
         INSERT INTO TBL_TEMPORARY_FILES (FILE_NAME,
                                          FILE_BLOB,
                                          FILE_LENGTH,
                                          MIME_TYPE)
              VALUES ('oliver_member_data.zip',
                      L_ZIP_FILE,
                      DBMS_LOB.GETLENGTH (L_ZIP_FILE),
                      'application/octet-stream');
      END IF;

      -- if logged in apex

      IF APEX_CUSTOM_AUTH.IS_SESSION_VALID
      THEN
         -- apex download process (*** limited to ONE file only ***)
         FOR F IN (SELECT FILE_NAME,
                          FILE_BLOB,
                          FILE_LENGTH,
                          MIME_TYPE
                     FROM TBL_TEMPORARY_FILES)
         LOOP
            OWA_UTIL.MIME_HEADER (F.MIME_TYPE, FALSE);
            HTP.P ('Content-length: ' || F.FILE_LENGTH);
            HTP.P (
                  'Content-Disposition: attachment; filename="'
               || F.FILE_NAME
               || '"');
            OWA_UTIL.HTTP_HEADER_CLOSE;
            WPG_DOCLOAD.DOWNLOAD_FILE (F.FILE_BLOB);
         END LOOP;
      END IF;
   END DOWNLOAD_FILES;
END PKG_DATA_EXTRACTION;
/

