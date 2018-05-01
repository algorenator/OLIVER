--
-- PKG_REPORTS  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.PKG_REPORTS IS

    FUNCTION STRING_CONTAINS_WORDS (
        P_STRING             VARCHAR2,
        P_WORDS              VARCHAR2,
        P_MUST_CONTAIN_ALL   VARCHAR2 DEFAULT 'Y'
    ) RETURN VARCHAR2 IS
        L_FOUND   PLS_INTEGER := 0;
    BEGIN
        FOR W IN (
            SELECT
                LOWER(COLUMN_VALUE) LOWERCASE_WORD,
                COUNT(*) OVER(
                    PARTITION BY NULL
                ) TOTAL_WORDS,
                ROWNUM
            FROM
                TABLE ( APEX_STRING.SPLIT(TRIM(P_WORDS),' ') )
        ) LOOP
            IF
                INSTR(LOWER(P_STRING),W.LOWERCASE_WORD) > 0
            THEN
                L_FOUND := L_FOUND + 1;
            END IF;

            IF
                P_MUST_CONTAIN_ALL = 'N' AND L_FOUND > 0
            THEN
                RETURN 'Y';
            END IF;
            IF
                P_MUST_CONTAIN_ALL = 'Y' AND L_FOUND = 0
            THEN
                RETURN 'N';
            END IF;
            IF
                W.ROWNUM = W.TOTAL_WORDS
            THEN
                RETURN
                    CASE
                        WHEN P_MUST_CONTAIN_ALL = 'Y' AND L_FOUND = W.ROWNUM THEN 'Y'
                        ELSE 'N'
                    END;
            END IF;

        END LOOP;

        RETURN 'N';
    END STRING_CONTAINS_WORDS;

    FUNCTION REPORT_CONTAIN_TAGS (
        P_REPORT_ID   NUMBER,
        P_CLIENT_ID   VARCHAR2,
        P_EMAIL       VARCHAR2,
        P_TAGS        VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        FOR R IN (
            SELECT
                NULL
            FROM
                TBL_REPORT
            WHERE
                REPORT_ID = P_REPORT_ID
                AND   PKG_REPORTS.STRING_CONTAINS_WORDS(REPORT_NAME
                || ' '
                || DESCRIPTION,P_TAGS,'Y') = 'Y'
        ) LOOP
            RETURN 'Y';
        END LOOP;

        FOR T IN (
            SELECT
                NULL
            FROM
                TBL_REPORT_TAGS
            WHERE
                REPORT_ID = P_REPORT_ID
                AND   CLIENT_ID = P_CLIENT_ID
                AND   UPPER(EMAIL) = UPPER(P_EMAIL)
                AND   PKG_REPORTS.STRING_CONTAINS_WORDS(TAGS,P_TAGS,'N') = 'Y'
        ) LOOP
            RETURN 'Y';
        END LOOP;

        RETURN 'N';
    END REPORT_CONTAIN_TAGS;

    PROCEDURE SET_REPORT_TAGS (
        P_REPORT_ID   NUMBER,
        P_CLIENT_ID   VARCHAR2,
        P_EMAIL       VARCHAR2,
        P_TAGS        VARCHAR2
    )
        IS
    BEGIN
        UPDATE TBL_REPORT_TAGS
            SET
                TAGS = P_TAGS
        WHERE
            REPORT_ID = P_REPORT_ID
            AND   CLIENT_ID = P_CLIENT_ID
            AND   UPPER(EMAIL) = ( P_EMAIL );

        IF
            SQL%ROWCOUNT = 0
        THEN
            INSERT INTO TBL_REPORT_TAGS (
                REPORT_ID,
                CLIENT_ID,
                EMAIL,
                TAGS
            ) VALUES (
                P_REPORT_ID,
                P_CLIENT_ID,
                P_EMAIL,
                P_TAGS
            );

        END IF;

    END SET_REPORT_TAGS;

    FUNCTION GET_REPORT_TAGS (
        P_REPORT_ID   NUMBER,
        P_CLIENT_ID   VARCHAR2,
        P_EMAIL       VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        FOR T IN (
            SELECT
                TAGS
            FROM
                TBL_REPORT_TAGS
            WHERE
                REPORT_ID = P_REPORT_ID
                AND   CLIENT_ID = P_CLIENT_ID
                AND   EMAIL = P_EMAIL
        ) LOOP
            RETURN REPLACE(T.TAGS,' ',', ');
        END LOOP;

        RETURN '';
    END GET_REPORT_TAGS;

    FUNCTION INSURANCE_CERTIFICATE_BEN (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_MEM_ID      VARCHAR2
    ) RETURN T_INS_CERT_BEN_T
        PIPELINED
        IS
    BEGIN
        FOR B IN (
            SELECT
                B.CODE,
                CASE
                        WHEN TRIM(TRANSLATE(B.COVERGAE,' .,0123456789','              ') ) IS NULL THEN TO_CHAR(TO_NUMBER(B.COVERGAE),'FML999G999G999G990D00')
                        ELSE DECODE(B.COVERGAE,'S','Single','F','Family','C','Couple',B.COVERGAE)
                    END
                BEN_COV,
                BM.BM_POLICY,
                BM.BM_CARRIER,
                TO_CHAR(BM.BM_EFF_DATE,'DD/MM/YYYY') EFF_DATE
            FROM
                TBL_BENEFITS_MASTER BM,
                MEMBER_BENEFITS B
            WHERE
                B.CLIENT_ID = P_CLIENT_ID
                AND   B.PLAN_ID = P_PLAN_ID
                AND   B.MEM_ID = P_MEM_ID
                AND   BM.BM_CLIENT_ID = B.CLIENT_ID
                AND   BM.BM_PLAN = B.PLAN_ID
                AND   BM.BM_CODE = B.CODE
        ) LOOP
            PIPE ROW ( B );
        END LOOP;
    END INSURANCE_CERTIFICATE_BEN;

    FUNCTION INSURANCE_CERTIFICATE_DATA (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_MEM_ID      VARCHAR2
    ) RETURN CLOB IS
        L_CURSOR   SYS_REFCURSOR;
        L_RETURN   CLOB;
    BEGIN
        APEX_JSON.INITIALIZE_CLOB_OUTPUT(DBMS_LOB.CALL,TRUE,2);
        OPEN L_CURSOR FOR SELECT
            'insurance_certificate' "filename",
            CURSOR (
                SELECT
                    UPPER(MEM.MEM_FIRST_NAME
                    || ' '
                    || MEM.MEM_LAST_NAME) AS "mem_name",
                    'Regular Full Time Employees' AS "mem_type",
                    MEM.MEM_ID AS "mem_id",
                    C.CO_NAME
                    || ' #'
                    || C.CO_NUMBER AS "comp_name",
                    C.CO_DIV AS "comp_div",
                    case
                      when p.pl_logo is not null then APEX_WEB_SERVICE.BLOB2CLOBBASE64(P.PL_LOGO)
                      else null
                    end AS "rpt_logo",
                    100 AS "rpt_logo_max_width",
                    100 AS "rpt_logo_max_height",
                    CURSOR (
                        SELECT
                            BEN_CODE AS "ben_code",
                            BEN_COV AS "ben_cov",
                            PLAN_NUM AS "plan_num",
                            CARRIER AS "carrier",
                            EFF_DATE AS "eff_date"
                        FROM
                            TABLE ( PKG_REPORTS.INSURANCE_CERTIFICATE_BEN(P_CLIENT_ID,P_PLAN_ID,P_MEM_ID) )
                    ) AS "ben",
                    CURSOR (
                        SELECT
                            HB_FIRST_NAME
                            || ' '
                            || HB_LAST_NAME AS "bfc_name",
                            NVL(HB_BE_PER,100)
                            || '%' AS "bfc_pct"
                        FROM
                            TBL_HW_BENEFICIARY
                        WHERE
                            HB_CLIENT = P_CLIENT_ID
                            AND   HB_PLAN = P_PLAN_ID
                            AND   HB_ID = P_MEM_ID
                        ORDER BY
                            1
                    ) AS "bfc",
                    CURSOR (
                        SELECT
                            HD_FIRST_NAME
                            || ' '
                            || HD_LAST_NAME AS "dpd_name"
                        FROM
                            TBL_HW_DEPENDANTS
                        WHERE
                            HD_CLIENT = P_CLIENT_ID
                            AND   HD_PLAN = P_PLAN_ID
                            AND   HD_ID = P_MEM_ID
                        ORDER BY
                            1
                    ) AS "dpd"
                FROM
                    TBL_PLAN P,
                    TBL_COMPMAST C,
                    TBL_MEMBER MEM
                WHERE
                    MEM.MEM_ID = P_MEM_ID
                    AND   MEM.MEM_CLIENT_ID = P_CLIENT_ID
                    AND   MEM.MEM_PLAN = P_PLAN_ID
                    AND   C.CO_NUMBER = GET_EMPLOYER_LATEST(MEM.MEM_CLIENT_ID,MEM.MEM_PLAN,MEM.MEM_ID,SYSDATE)
                    AND   C.CO_CLIENT = MEM.MEM_CLIENT_ID
                    AND   C.CO_PLAN = MEM.MEM_PLAN
                    AND   P.PL_CLIENT_ID = MEM.MEM_CLIENT_ID
                    AND   P.PL_ID = MEM.MEM_PLAN
            ) "data"
                          FROM
            DUAL;

        APEX_JSON.WRITE(L_CURSOR);
        L_RETURN := APEX_JSON.GET_CLOB_OUTPUT;
        RETURN L_RETURN;
    END INSURANCE_CERTIFICATE_DATA;

  function is_report_visible(p_client_id varchar2, p_plan_id varchar2, p_report_id number) return varchar2 is
  begin
    for p in (
        select plan_group, plan_type, plan_id
          from v_plan_info
         where client_id = p_client_id
           and plan_id = p_plan_id
    ) loop
      for r in (
        select plan_group, plan_type, plan_id
          from tbl_report
         where report_id = p_report_id
           and isactive = 'Y'
      ) loop
        if r.plan_group is null then
          return 'Y';
        else
          if instr(r.plan_group, p.plan_group) > 0 then
            if r.plan_type is null then
              return 'Y';
            else
              if instr(r.plan_type, p.plan_type) > 0 then
                if r.plan_id is null then
                  return 'Y';
                else
                  if instr(r.plan_id, p.plan_id) > 0 then
                    return 'Y';
                  end if;
                end if;
              end if;
            end if;
          end if;
        end if;
      end loop;
    end loop;
    return 'N';
  end is_report_visible;

END PKG_REPORTS;

/

