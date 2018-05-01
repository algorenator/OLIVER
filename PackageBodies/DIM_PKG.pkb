--
-- DIM_PKG  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.dim_pkg AS
    PROCEDURE INSERT_MEMBER (
        P_TDT_MEM_ID        VARCHAR2,
        P_TDT_MEM_SIN       VARCHAR2,
        P_TDT_START_DATE    VARCHAR2,
        P_TDT_END_DATE      VARCHAR2,
        P_TDT_PERIOD        VARCHAR2,
        P_TDT_FIRST_NAME    VARCHAR2,
        P_TDT_LAST_NAME     VARCHAR2,
        P_TDT_OCCU          VARCHAR2,
        P_TDT_UNITS         VARCHAR2,
        P_BEN_RATE          VARCHAR2,
        P_TDT_PEN_UNITS     VARCHAR2,
        P_TDT_FUNDS_UNITS   VARCHAR2,
        P_TDT_COMMENT       VARCHAR2,
        P_TDT_USER          VARCHAR2,
        P_TDT_DATE_TIME     VARCHAR2,
        P_TDT_RATE          VARCHAR2,
        P_TRAN_ID           VARCHAR2,
        P_TDT_EMPLOYER      VARCHAR2,
        P_PLAN_ID           VARCHAR2,
        P_CLIENT_ID         VARCHAR2,
        P_VOL_UNITS         VARCHAR2,
        P_EE_UNITS          VARCHAR2,
        P_ER_UNITS          VARCHAR2,
        P_ER_RATE           VARCHAR2,
        P_EE_RATE           VARCHAR2,
        P_BEN_RATE_EE       VARCHAR2,
        P_BEN_RATE_ER       VARCHAR2
    )
        IS
    BEGIN
        INSERT INTO TRANSACTION_DETAIL_TEMP (
            TDT_MEM_ID,
            TDT_MEM_SIN,
            TDT_START_DATE,
            TDT_END_DATE,
            TDT_PERIOD,
            TDT_FIRST_NAME,
            TDT_LAST_NAME,
            TDT_OCCU,
            TDT_UNITS,
            TDT_AMOUNT,
            TDT_PEN_UNITS,
            TDT_FUNDS_UNITS,
            TDT_COMMENT,
            TDT_USER,
            TDT_DATE_TIME,
            TDT_RATE,
            TDT_TRAN_ID,
            TDT_EMPLOYER,
            TDT_PLAN_ID,
            TDT_CLIENT_ID,
            TDT_ER_UNITS,
            TDT_EE_UNITS,
            TDT_VOL_UNITS,
            TDT_ER_RATE,
            TDT_EE_RATE,
            TDT_EE_UNITS_HW,
            TDT_ER_UNITS_HW
        ) VALUES (
            P_TDT_MEM_ID,
            P_TDT_MEM_SIN,
            P_TDT_START_DATE,
            P_TDT_END_DATE,
            P_TDT_PERIOD,
            P_TDT_FIRST_NAME,
            P_TDT_LAST_NAME,
            P_TDT_OCCU,
            TO_NUMBER(REPLACE(NVL(P_TDT_UNITS,'0'),','),'999999.99'),
            TO_NUMBER(REPLACE(NVL(P_TDT_UNITS,'0'),','),'999999.99') * TO_NUMBER(REPLACE(NVL(P_BEN_RATE,'0'),','),'999999.99'),
            TO_NUMBER(REPLACE(NVL(P_TDT_PEN_UNITS,'0'),','),'999999.99'),
            TO_NUMBER(REPLACE(NVL(P_TDT_FUNDS_UNITS,'0'),','),'999999.99'),
            P_TDT_COMMENT,
            P_TDT_USER,
            P_TDT_DATE_TIME,
            P_TDT_RATE,
            P_TRAN_ID,
            P_TDT_EMPLOYER,
            P_PLAN_ID,
            P_CLIENT_ID,
            TO_NUMBER(REPLACE(NVL(P_ER_UNITS,'0'),','),'999999.99'),
            TO_NUMBER(REPLACE(NVL(P_EE_UNITS,'0'),','),'999999.99'),
            TO_NUMBER(REPLACE(NVL(P_VOL_UNITS,'0'),','),'999999.99'),
            P_ER_RATE,
            P_EE_RATE,
            TO_NUMBER(REPLACE(NVL(P_TDT_UNITS,'0'),','),'999999.99') * TO_NUMBER(REPLACE(NVL(P_BEN_RATE_EE,'0'),','),'999999.99'),
            TO_NUMBER(REPLACE(NVL(P_TDT_UNITS,'0'),','),'999999.99') * TO_NUMBER(REPLACE(NVL(P_BEN_RATE_ER,'0'),','),'999999.99')
        );

        UPDATE_TRANSACTION_HEADERS(P_PLAN_ID,P_CLIENT_ID,P_TRAN_ID);
    END INSERT_MEMBER;

    PROCEDURE UPDATE_TRANSACTION_HEADERS (
        P_PLAN_ID     VARCHAR2,
        P_CLIENT_ID   VARCHAR2,
        P_TRAN_ID     VARCHAR2
    ) IS
        V_PEN_AMOUNT   NUMBER;
        V_BEN_AMOUNT   NUMBER;
    BEGIN
  
    -- get pension total entered
        FOR P IN (
            SELECT
                THTP_EMPLOYER,
                THTP_AGREE_ID,
                THTP_EARNED
            FROM
                TRAN_HEADER_TEMP_PEN
            WHERE
                THTP_TRAN_ID = P_TRAN_ID
                AND   THTP_PLAN_ID = P_PLAN_ID
                AND   THT_CLIENT_ID = P_CLIENT_ID
        ) LOOP
            BEGIN
                SELECT
                    SUM(NVL(TDT_PEN_UNITS,0) * PENSION_PKG.GET_CONT_RATE(P_CLIENT_ID,P_PLAN_ID,SYSDATE,P.THTP_AGREE_ID,P.THTP_EMPLOYER,TDT_MEM_ID,TDT_OCCU
,'PENSION',P.THTP_EARNED) )
                INTO
                    V_PEN_AMOUNT
                FROM
                    TRANSACTION_DETAIL_TEMP
                WHERE
                    TDT_TRAN_ID = P_TRAN_ID
                    AND   TDT_PLAN_ID = P_PLAN_ID
                    AND   TDT_CLIENT_ID = P_CLIENT_ID;

            EXCEPTION
                WHEN OTHERS THEN
                    V_PEN_AMOUNT := 0;
            END;
        END LOOP;
  
    -- update the pension header table

        UPDATE TRAN_HEADER_TEMP_PEN
            SET
                THTP_VARIANCE_AMT = V_PEN_AMOUNT,
                THTP_AMOUNT = V_PEN_AMOUNT,
                THTP_POST = 'N'
        WHERE
            THTP_TRAN_ID = P_TRAN_ID
            AND   THTP_PLAN_ID = P_PLAN_ID
            AND   THT_CLIENT_ID = P_CLIENT_ID;
    
    -- get benefit total entered

        FOR B IN (
            SELECT
                THT_EMPLOYER,
                THT_AGREE_ID,
                THT_EARNED,
                ROWID
            FROM
                TRANSACTION_HEADER_TEMP
            WHERE
                THT_TRAN_ID = P_TRAN_ID
                AND   THT_PLAN_ID = P_PLAN_ID
                AND   THT_CLIENT_ID = P_CLIENT_ID
        ) LOOP
            BEGIN
                SELECT
                    SUM(NVL(TDT_UNITS,0) * PENSION_PKG.GET_CONT_RATE(P_CLIENT_ID,P_PLAN_ID,SYSDATE,B.THT_AGREE_ID,B.THT_EMPLOYER,TDT_MEM_ID,TDT_OCCU,'HW'
,B.THT_EARNED) )
                INTO
                    V_BEN_AMOUNT
                FROM
                    TRANSACTION_DETAIL_TEMP
                WHERE
                    TDT_TRAN_ID = P_TRAN_ID
                    AND   TDT_PLAN_ID = P_PLAN_ID
                    AND   TDT_CLIENT_ID = P_CLIENT_ID;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_BEN_AMOUNT := 0;
            END;

      -- update the benefits header table

            UPDATE TRANSACTION_HEADER_TEMP
                SET
                    THT_AMOUNT = V_BEN_AMOUNT,
                    THT_POST = 'N'
            WHERE
                ROWID = B.ROWID;

        END LOOP;
    
    -- update the funds header table

        UPDATE TRAN_HEADER_TEMP_FUNDS
            SET
                THTF_UNITS = (
                    SELECT
                        NVL(SUM(DTF_UNITS),0)
                    FROM
                        TRAN_DETAILS_TEMP_FUNDS_DET
                    WHERE
                        DTF_TRAN_ID = THTF_TRAN_ID
                ),
                THTF_AMOUNT = (
                    SELECT
                        NVL(SUM(DTF_AMT),0)
                    FROM
                        TRAN_DETAILS_TEMP_FUNDS_DET
                    WHERE
                        DTF_TRAN_ID = THTF_TRAN_ID
                ),
                THTF_POST = 'N'
        WHERE
            THTF_PLAN_ID = P_PLAN_ID
            AND   THTF_TRAN_ID = P_TRAN_ID
            AND   THTF_CLIENT_ID = P_CLIENT_ID;

    END UPDATE_TRANSACTION_HEADERS;

    PROCEDURE UPDATE_MEMBER (
        P_TDT_KEY           VARCHAR2,
        P_TDT_MEM_ID        VARCHAR2,
        P_TDT_MEM_SIN       VARCHAR2,
        P_TDT_START_DATE    VARCHAR2,
        P_TDT_END_DATE      VARCHAR2,
        P_TDT_PERIOD        VARCHAR2,
        P_TDT_FIRST_NAME    VARCHAR2,
        P_TDT_LAST_NAME     VARCHAR2,
        P_TDT_OCCU          VARCHAR2,
        P_TDT_UNITS         VARCHAR2,
        P_BEN_RATE          VARCHAR2,
        P_TDT_PEN_UNITS     VARCHAR2,
        P_TDT_FUNDS_UNITS   VARCHAR2,
        P_TDT_COMMENT       VARCHAR2,
        P_TDT_USER          VARCHAR2,
        P_TDT_DATE_TIME     VARCHAR2,
        P_TDT_RATE          VARCHAR2,
        P_VOL_UNITS         VARCHAR2,
        P_EE_UNITS          VARCHAR2,
        P_ER_UNITS          VARCHAR2,
        P_ER_RATE           VARCHAR2,
        P_EE_RATE           VARCHAR2,
        P_BEN_RATE_EE       VARCHAR2,
        P_BEN_RATE_ER       VARCHAR2
    )
        IS
    BEGIN
        FOR M IN (
            SELECT
                ROWID,
                TDT_PLAN_ID,
                TDT_CLIENT_ID,
                TDT_TRAN_ID
            FROM
                TRANSACTION_DETAIL_TEMP
            WHERE
                TDT_KEY = P_TDT_KEY
        ) LOOP
            UPDATE TRANSACTION_DETAIL_TEMP
                SET
                    TDT_MEM_ID = P_TDT_MEM_ID,
                    TDT_MEM_SIN = P_TDT_MEM_SIN,
                    TDT_START_DATE = P_TDT_START_DATE,
                    TDT_END_DATE = P_TDT_END_DATE,
                    TDT_PERIOD = P_TDT_PERIOD,
                    TDT_FIRST_NAME = P_TDT_FIRST_NAME,
                    TDT_LAST_NAME = P_TDT_LAST_NAME,
                    TDT_OCCU = P_TDT_OCCU,
                    TDT_UNITS = TO_NUMBER(REPLACE(NVL(P_TDT_UNITS,'0'),','),'999999.99'),
                    TDT_AMOUNT = TO_NUMBER(REPLACE(NVL(P_TDT_UNITS,'0'),','),'999999.99') * TO_NUMBER(REPLACE(NVL(P_BEN_RATE,'0'),','),'999999.99'),
                    TDT_PEN_UNITS = TO_NUMBER(REPLACE(NVL(P_TDT_PEN_UNITS,'0'),','),'999999.99'),
                    TDT_FUNDS_UNITS = TO_NUMBER(REPLACE(NVL(P_TDT_FUNDS_UNITS,'0'),','),'999999.99'),
                    TDT_COMMENT = P_TDT_COMMENT,
                    TDT_USER = P_TDT_USER,
                    TDT_DATE_TIME = P_TDT_DATE_TIME,
                    TDT_RATE = P_TDT_RATE,
                    TDT_VOL_UNITS = TO_NUMBER(REPLACE(NVL(P_VOL_UNITS,'0'),','),'999999.99'),
                    TDT_EE_UNITS = TO_NUMBER(REPLACE(NVL(P_EE_UNITS,'0'),','),'999999.99'),
                    TDT_ER_UNITS = TO_NUMBER(REPLACE(NVL(P_ER_UNITS,'0'),','),'999999.99'),
                    TDT_ER_RATE = TO_NUMBER(REPLACE(NVL(P_ER_RATE,'0'),','),'999999.99'),
                    TDT_EE_RATE = TO_NUMBER(REPLACE(NVL(P_EE_RATE,'0'),','),'999999.99'),
                    TDT_EE_UNITS_HW = TO_NUMBER(REPLACE(NVL(P_TDT_UNITS,'0'),','),'999999.99') * TO_NUMBER(REPLACE(NVL(P_BEN_RATE_EE,'0'),','),'999999.99'),
                    TDT_ER_UNITS_HW = TO_NUMBER(REPLACE(NVL(P_TDT_UNITS,'0'),','),'999999.99') * TO_NUMBER(REPLACE(NVL(P_BEN_RATE_ER,'0'),','),'999999.99')
            WHERE
                ROWID = M.ROWID;

            UPDATE_TRANSACTION_HEADERS(M.TDT_PLAN_ID,M.TDT_CLIENT_ID,M.TDT_TRAN_ID);
        END LOOP;
    END UPDATE_MEMBER;

    FUNCTION ADD_MEMBER (
        P_TDT_KEY           VARCHAR2,
        P_TDT_MEM_ID        VARCHAR2,
        P_TDT_MEM_SIN       VARCHAR2,
        P_TDT_START_DATE    VARCHAR2,
        P_TDT_END_DATE      VARCHAR2,
        P_TDT_PERIOD        VARCHAR2,
        P_TDT_FIRST_NAME    VARCHAR2,
        P_TDT_LAST_NAME     VARCHAR2,
        P_TDT_OCCU          VARCHAR2,
        P_TDT_UNITS         VARCHAR2,
        P_BEN_RATE          VARCHAR2,
        P_TDT_PEN_UNITS     VARCHAR2,
        P_TDT_FUNDS_UNITS   VARCHAR2,
        P_TDT_COMMENT       VARCHAR2,
        P_TDT_USER          VARCHAR2,
        P_TDT_DATE_TIME     VARCHAR2,
        P_TDT_RATE          VARCHAR2,
        P_TRAN_ID           VARCHAR2,
        P_TDT_EMPLOYER      VARCHAR2,
        P_PLAN_ID           VARCHAR2,
        P_CLIENT_ID         VARCHAR2,
        P_VOL_UNITS         VARCHAR2,
        P_EE_UNITS          VARCHAR2,
        P_ER_UNITS          VARCHAR2,
        P_ER_RATE           VARCHAR2,
        P_EE_RATE           VARCHAR2,
        P_BEN_RATE_EE       VARCHAR2,
        P_BEN_RATE_ER       VARCHAR2
    ) RETURN VARCHAR2 IS
      l_member_exists varchar2(1);
      l_errors varchar2(255);
    BEGIN
      if p_tdt_mem_sin is not null then
        if pkg_validation.is_sin_valid(P_CLIENT_ID, P_PLAN_ID, P_TDT_MEM_SIN) = 'N' then
          l_errors := l_errors || 'SIN,';
        end if;
      end if;
      if p_tdt_mem_id is null then
        l_errors := l_errors || 'MEM_ID,';
      end if;
      if p_tdt_first_name is null then
        l_errors := l_errors || 'FIRST_NAME,';
      end if;
      if p_tdt_last_name is null then
        l_errors := l_errors || 'LAST_NAME,';
      end if;

      if l_errors is not null then
        return l_errors;
      end if;

      l_member_exists := 'N';
      for e in (select null from transaction_detail_temp where tdt_key = P_TDT_KEY) loop
          l_member_exists := 'Y';
      end loop;
      if l_member_exists = 'N' then
        insert_member(
            p_tdt_mem_id, p_tdt_mem_sin, p_tdt_start_date, p_tdt_end_date,
            p_tdt_period, p_tdt_first_name, p_tdt_last_name,
            p_tdt_occu, p_tdt_units, p_ben_rate,
            p_tdt_pen_units, p_tdt_funds_units, p_tdt_comment,
            p_tdt_user, p_tdt_date_time, p_tdt_rate, p_tran_id,
            p_tdt_employer, p_plan_id, p_client_id, p_vol_units,
            p_ee_units, p_er_units, p_er_rate, p_ee_rate,
            p_ben_rate_ee, p_ben_rate_er
        );
      else
        update_member(
            p_tdt_key, p_tdt_mem_id, p_tdt_mem_sin,
            p_tdt_start_date, p_tdt_end_date, p_tdt_period,
            p_tdt_first_name, p_tdt_last_name, p_tdt_occu,
            p_tdt_units, p_ben_rate, p_tdt_pen_units,
            p_tdt_funds_units, p_tdt_comment, p_tdt_user,
            p_tdt_date_time, p_tdt_rate, p_vol_units,
            p_ee_units, p_er_units, p_er_rate,
            p_ee_rate, p_ben_rate_ee, p_ben_rate_er
        );
      end if;
      return 'OK';
    END ADD_MEMBER;

    PROCEDURE DELETE_MEMBER (
        P_TDT_KEY VARCHAR2
    )
        IS
    BEGIN
        FOR M IN (
            SELECT
                ROWID,
                TDT_EMPLOYER,
                TDT_TRAN_ID,
                TDT_MEM_ID,
                TDT_CLIENT_ID,
                TDT_PLAN_ID
            FROM
                TRANSACTION_DETAIL_TEMP
            WHERE
                TDT_KEY = P_TDT_KEY
        ) LOOP
            DELETE TRAN_DETAILS_TEMP_FUNDS_DET
            WHERE
                DTF_EMPLOYER = M.TDT_EMPLOYER
                AND   DTF_TRAN_ID = M.TDT_TRAN_ID
                AND   DTF_MEM_ID = M.TDT_MEM_ID;

            DELETE TRANSACTION_DETAIL_TEMP WHERE
                ROWID = M.ROWID;

            UPDATE_TRANSACTION_HEADERS(M.TDT_PLAN_ID,M.TDT_CLIENT_ID,M.TDT_TRAN_ID);
        END LOOP;
    END DELETE_MEMBER;

    PROCEDURE DELETE_ALL_MEMBERS (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_TRAN_ID     VARCHAR2
    )
        IS
    BEGIN
        DELETE TRANSACTION_DETAIL_TEMP
        WHERE
            TDT_CLIENT_ID = P_CLIENT_ID
            AND   TDT_PLAN_ID = P_PLAN_ID
            AND   TDT_TRAN_ID = P_TRAN_ID;

        UPDATE_TRANSACTION_HEADERS(P_PLAN_ID,P_CLIENT_ID,P_TRAN_ID);
    END DELETE_ALL_MEMBERS;

    FUNCTION VALIDATE_MEMBER_DETAIL (
        P_TRAN_ID VARCHAR2,
        P_TDT_MEM_ID VARCHAR2
    ) RETURN VARCHAR2 AS
        V_COUNT             INTEGER;
        V_DUPLICATE_COUNT   INTEGER;
        V_ERROR_MESSAGE     VARCHAR2(200);
        V_MEM_DOB           DATE;
        V_AGE               NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO
            V_DUPLICATE_COUNT
        FROM
            TRANSACTION_DETAIL_TEMP
        WHERE
            TDT_TRAN_ID = P_TRAN_ID
            AND   TDT_MEM_ID = P_TDT_MEM_ID;

        SELECT
            COUNT(*)
        INTO
            V_COUNT
        FROM
            TBL_MEMBER
        WHERE
            MEM_ID = P_TDT_MEM_ID;

        IF
            V_COUNT = 0
        THEN
            V_ERROR_MESSAGE := ' New Member,';
        ELSE
            SELECT
                MEM_DOB
            INTO
                V_MEM_DOB
            FROM
                TBL_MEMBER
            WHERE
                MEM_ID = P_TDT_MEM_ID
                AND   ROWNUM < 2;

        END IF;

        IF
            V_DUPLICATE_COUNT > 1
        THEN
            V_ERROR_MESSAGE := V_ERROR_MESSAGE
            || ' Duplicate Member,';
        END IF;
        SELECT
            FLOOR(MONTHS_BETWEEN(SYSDATE,V_MEM_DOB) / 12)
        INTO
            V_AGE
        FROM
            DUAL;

        IF
            V_AGE < 20 OR V_AGE >= 80
        THEN
            V_ERROR_MESSAGE := V_ERROR_MESSAGE
            || ' Error Age ('
            || V_AGE
            || ')';
        END IF;

        V_ERROR_MESSAGE := RTRIM(V_ERROR_MESSAGE,',');
        RETURN V_ERROR_MESSAGE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END VALIDATE_MEMBER_DETAIL;

    FUNCTION GENERATE_TRAN_ID RETURN VARCHAR2
        IS
    BEGIN
        RETURN TO_CHAR(SYSDATE,'YYYYMONDD')
        || TO_CHAR(TRAN_ID_SEQ.NEXTVAL,'FM000000');
    END GENERATE_TRAN_ID;

PROCEDURE REMITTANCE_UPLOAD (
    P_CLIENT_ID    VARCHAR2,
    P_PLAN_ID      VARCHAR2,
    P_TRAN_ID      VARCHAR2,
    P_APP_ID       NUMBER,
    P_SESSION_ID   NUMBER,
    P_CREATED_BY   VARCHAR2
) IS
    V_CLOB CLOB;
    V_MEM_ID VARCHAR2(15);
    V_VOL_UNITS NUMBER;
    V_EE_UNITS NUMBER;
    V_ER_UNITS NUMBER;
    V_PENSION_UNITS NUMBER;
    V_BENEFIT_UNITS NUMBER;
    V_MEM_FIRST_NAME VARCHAR2(100);
    V_MEM_LAST_NAME VARCHAR2(100);
    V_OCCU VARCHAR2(100);
    V_EE_RATE NUMBER;
    V_ER_RATE NUMBER;
    V_EMPLOYER VARCHAR2(100);
    V_IS_PENSION VARCHAR2(1);
    V_IS_BENEFIT VARCHAR2(1);
    V_IS_DCPP VARCHAR2(1);
    V_INSERTED_LINES NUMBER;
   begin
    FOR C_BLOB IN (
        SELECT
            TO_CLOB(BLOB_CONTENT) CONTENT
        FROM
            WWV_FLOW_FILE_OBJECTS$
        WHERE
            FLOW_ID = P_APP_ID
            AND   SESSION_ID = P_SESSION_ID
            AND   CREATED_BY = P_CREATED_BY
        ORDER BY
            CREATED_ON DESC
    ) LOOP
        V_CLOB := C_BLOB.CONTENT;
        EXIT;
    END LOOP;

    FOR T IN (
        SELECT
            TRAN_ER_RATE,
            TRAN_EE_RATE,
            TRAN_EMPLOYER,
            TRAN_PENSION,
            TRAN_BENEFIT,
            TRAN_IS_DCPP
        FROM
            TABLE ( DIM_PKG.TRAN_VALUES(P_PLAN_ID,P_CLIENT_ID,P_TRAN_ID) )
    ) LOOP
        V_ER_RATE := T.TRAN_ER_RATE;
        V_EE_RATE := T.TRAN_EE_RATE;
        V_EMPLOYER := T.TRAN_EMPLOYER;
        V_IS_PENSION := T.TRAN_PENSION;
        V_IS_BENEFIT := T.TRAN_BENEFIT;
        V_IS_DCPP := T.TRAN_IS_DCPP;
    END LOOP;

    V_INSERTED_LINES := 0;
FOR l in ( SELECT
    COLUMN_VALUE LINE
        FROM
    APEX_STRING.SPLIT(v_clob, chr(10))) loop
       -- process line
       if instr(l.line, ',') > 0 then
         v_mem_id := null;
         v_pension_units := 0;
         v_benefit_units := 0;
         v_er_units := 0;
         v_ee_units := 0;
         v_vol_units := 0;
         v_mem_first_name := null;
         v_mem_last_name := null;
         v_occu := null;

         if v_is_pension = 'Y' and v_is_benefit = 'N' then -- pension
           if v_is_dcpp = 'Y' then
             begin
               v_mem_id := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 1), '[^0-9]', '');
             exception
               when others then v_mem_id := null;
             end;
             begin
               v_occu := regexp_substr(l.line, '[^,]+', 1, 2);
             exception
               when others then v_occu := null;
             end;
             begin
               v_pension_units := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 3), '[^0-9.]', '');
             exception
               when others then v_pension_units := 0;
             end;
             begin
               v_er_units := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 4), '[^0-9.]', '');
             exception
               when others then v_er_units := 0;
             end;
             begin
               v_ee_units := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 5), '[^0-9.]', '');
             exception
               when others then v_ee_units := 0;
             end;
             begin
               v_vol_units := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 6), '[^0-9.]', '');
             exception
               when others then v_vol_units := 0;
             end;
             if trim(v_occu) is null then
               v_occu := dim_pkg.get_member_occu(p_client_id, p_plan_id, v_mem_id);
             end if;
             for m in (
               select mem_first_name, mem_last_name
                 from tbl_member
                where mem_client_id = p_client_id
                  and mem_plan = p_plan_id
                  and mem_id = v_mem_id
                  and rownum < 2
             ) loop
               v_mem_first_name := m.mem_first_name;
               v_mem_last_name := m.mem_last_name;
             end loop;
           elsif v_is_dcpp = 'N' then
             begin
               v_mem_id := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 1), '[^0-9]', '');
             exception
               when others then v_mem_id := null;
             end;
             begin
               v_occu := regexp_substr(l.line, '[^,]+', 1, 2);
             exception
               when others then v_occu := null;
             end;
             begin
               v_pension_units := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 3), '[^0-9.]', '');
             exception
               when others then v_pension_units := 0;
             end;
             begin
               v_er_units := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 4), '[^0-9.]', '');
             exception
               when others then v_er_units := 0;
             end;
             begin
               v_ee_units := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 5), '[^0-9.]', '');
             exception
               when others then v_ee_units := 0;
             end;
             begin
               v_vol_units := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 6), '[^0-9.]', '');
             exception
               when others then v_vol_units := 0;
             end;
             if trim(v_occu) is null then
               v_occu := dim_pkg.get_member_occu(p_client_id, p_plan_id, v_mem_id);
             end if;
             for m in (
               select mem_first_name, mem_last_name
                 from tbl_member
                where mem_client_id = p_client_id
                  and mem_plan = p_plan_id
                  and mem_id = v_mem_id
                  and rownum < 2
             ) loop
               v_mem_first_name := m.mem_first_name;
               v_mem_last_name := m.mem_last_name;
             end loop;
           end if;
         elsif v_is_pension = 'N' and v_is_benefit = 'Y' then -- benefit
           begin
             v_mem_id := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 1), '[^0-9]', '');
           exception
             when others then v_mem_id := null;
           end;
           begin
             v_occu := regexp_substr(l.line, '[^,]+', 1, 2);
           exception
             when others then v_occu := null;
           end;
           begin
             v_benefit_units := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 3), '[^0-9.]', '');
           exception
             when others then v_benefit_units := 0;
           end;
           if trim(v_occu) is null then
             v_occu := dim_pkg.get_member_occu(p_client_id, p_plan_id, v_mem_id);
           end if;
           for m in (
             select mem_first_name, mem_last_name
               from tbl_member
              where mem_client_id = p_client_id
                and mem_plan = p_plan_id
                and mem_id = v_mem_id
                and rownum < 2
           ) loop
             v_mem_first_name := m.mem_first_name;
             v_mem_last_name := m.mem_last_name;
           end loop;
         elsif v_is_pension = 'Y' and v_is_benefit = 'Y' then -- pension + benefit
           null;
         end if;
         insert into transaction_detail_temp(
           tdt_tran_id, tdt_plan_id, tdt_client_id, tdt_employer, tdt_user,
           tdt_date_time, tdt_mem_id, tdt_first_name, tdt_last_name, tdt_occu,
           tdt_vol_units, tdt_ee_units, tdt_er_units, tdt_pen_units, tdt_units,
           tdt_er_rate, tdt_ee_rate
         ) values (
           p_tran_id, p_plan_id, p_client_id, v_employer, p_created_by,
           sysdate, v_mem_id, v_mem_first_name, v_mem_last_name, v_occu,
           v_vol_units, v_ee_units, v_er_units, v_pension_units, v_benefit_units,
           v_er_rate, v_ee_rate
         );
         v_inserted_lines := v_inserted_lines + 1;
       end if;
     end loop;
     -- update the headers tables
     if v_clob is not null and v_inserted_lines > 0 then
       dim_pkg.update_transaction_headers(p_plan_id, p_client_id, p_tran_id);
     end if;
     if v_inserted_lines = 0 then
       raise_application_error(-20000, 'No rows were created. The file does not contain any valid data.');
     end if;
   end remittance_upload;

   procedure file_upload(p_pen_agreement varchar2, p_tran_id varchar2, p_client_id varchar2, p_plan_id varchar2, p_employer varchar2, p_period  date, p_app_id number, p_session_id number, p_created_by varchar2) as
     v_clob clob;
     v_mem_id varchar2(15);
     v_pension number;
     v_hours number;
     v_funds number;
     v_mem_first_name varchar2(100);
     v_mem_last_name varchar2(100);
     v_occu varchar2(100);
   begin
     for c_blob in (
       select to_clob(blob_content) content
         from wwv_flow_file_objects$
        where flow_id = p_app_id
          and session_id = p_session_id
          and created_by = p_created_by
        order by created_on desc
     ) loop
       v_clob := c_blob.content;
       exit;
     end loop;
     for l in (select column_value line from apex_string.split(v_clob, chr(10))) loop
       -- process line
       if instr(l.line, ',') > 0 then
         v_mem_first_name := null;
         v_mem_last_name := null;
         v_mem_id := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 1), '[^0-9]', '');
         v_hours := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 2), '[^0-9]', '');
         v_occu := upper(regexp_substr(l.line, '[^,]+', 1, 3));
         v_pension := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 4), '[^0-9]', '');
         v_funds := regexp_replace(regexp_substr(l.line, '[^,]+', 1, 5), '[^0-9]', '');
         begin
           select mem_first_name, mem_last_name
             into v_mem_first_name, v_mem_last_name
             from tbl_member
            where mem_client_id = p_client_id
              and mem_plan = p_plan_id
              and mem_id = v_mem_id
              and rownum < 2;
         exception
           when others then null;
         end;
         if trim(v_occu) is null then
           v_occu := get_occupation_latest(p_client_id, p_plan_id, v_mem_id, sysdate);
         end if;
         insert into transaction_detail_temp (
           tdt_tran_id, tdt_plan_id, tdt_employer, tdt_period,
           tdt_units, tdt_user, tdt_date_time, tdt_mem_id,
           tdt_first_name, tdt_last_name, tdt_pen_units, tdt_funds_units,
           tdt_client_id, tdt_occu, tdt_amount
         ) values (
           p_tran_id, p_plan_id, p_employer, p_period,
           v_hours, p_created_by, sysdate, v_mem_id,
           v_mem_first_name, v_mem_last_name, v_pension, v_funds,
           p_client_id, v_occu,
           v_pension * pension_pkg.get_cont_rate(p_client_id, p_plan_id, sysdate, p_pen_agreement, p_employer, v_mem_id, v_occu, 'PENSION', 'Y')
         );
       end if;
     end loop;
     -- update the headers tables
     if v_clob is not null then
       dim_pkg.update_transaction_headers(p_plan_id, p_client_id, p_tran_id);
     end if;
   exception
     when others then
       null;
   end file_upload;

   procedure file_upload_dcpp(
     p_client_id varchar2,
     p_plan_id varchar2,
     p_tran_id varchar2,
     p_employer varchar2,
     p_app_id number,
     p_session_id number,
     p_created_by varchar2
   ) as
     v_clob clob;
     v_mem_id varchar2(15);
     v_vol_units number;
     v_ee_units number;
     v_er_units number;
     v_pension_units number;
     v_mem_first_name varchar2(100);
     v_mem_last_name varchar2(100);
     v_occu varchar2(100);
     v_ee_rate number;
     v_er_rate number;
   begin
     for c_blob in (
       select to_clob(blob_content) content
         from wwv_flow_file_objects$
        where flow_id = p_app_id
          and session_id = p_session_id
          and created_by = p_created_by
        order by created_on desc
     ) loop
       v_clob := c_blob.content;
       exit;
     end loop;
     for l in (select column_value line from apex_string.split(v_clob, chr(10))) loop
       -- process line
       if instr(l.line, ',') > 0 then
    V_MEM_FIRST_NAME := NULL;
    V_MEM_LAST_NAME := NULL;
    BEGIN
        V_MEM_ID := REGEXP_REPLACE(REGEXP_SUBSTR(L.LINE,'[^,]+',1,1),'[^0-9]','');
    EXCEPTION
        WHEN OTHERS THEN
            V_MEM_ID := NULL;
    END;

    BEGIN
        V_PENSION_UNITS := REGEXP_REPLACE(REGEXP_SUBSTR(L.LINE,'[^,]+',1,2),'[^0-9.]','');
    EXCEPTION
        WHEN OTHERS THEN
            V_PENSION_UNITS := 0;
    END;

    BEGIN
        V_ER_UNITS := REGEXP_REPLACE(REGEXP_SUBSTR(L.LINE,'[^,]+',1,3),'[^0-9.]','');
    EXCEPTION
        WHEN OTHERS THEN
            V_ER_UNITS := 0;
    END;

    BEGIN
        V_EE_UNITS := REGEXP_REPLACE(REGEXP_SUBSTR(L.LINE,'[^,]+',1,4),'[^0-9.]','');
    EXCEPTION
        WHEN OTHERS THEN
            V_EE_UNITS := 0;
            END;
            BEGIN
                V_VOL_UNITS := REGEXP_REPLACE(REGEXP_SUBSTR(L.LINE,'[^,]+',1,5),'[^0-9.]','');
            EXCEPTION
                WHEN OTHERS THEN
                    V_VOL_UNITS := 0;
                    END;
                    V_OCCU := DIM_PKG.GET_MEMBER_OCCU(P_CLIENT_ID,P_PLAN_ID,V_MEM_ID);
                    FOR M IN (
                        SELECT
                            MEM_FIRST_NAME,
                            MEM_LAST_NAME
                        FROM
                            TBL_MEMBER
                        WHERE
                            MEM_CLIENT_ID = P_CLIENT_ID
                            AND   MEM_PLAN = P_PLAN_ID
                                AND   MEM_ID = V_MEM_ID
                                    AND   ROWNUM < 2
                    ) LOOP
                        V_MEM_FIRST_NAME := M.MEM_FIRST_NAME;
                        V_MEM_LAST_NAME := M.MEM_LAST_NAME;
                    END LOOP;

                    FOR T IN (
                        SELECT
                            TRAN_ER_RATE,
                            TRAN_EE_RATE
                        FROM
                            TABLE ( DIM_PKG.TRAN_VALUES(P_PLAN_ID,P_CLIENT_ID,P_TRAN_ID) )
                    ) LOOP
                        V_ER_RATE := T.TRAN_ER_RATE;
                        V_EE_RATE := T.TRAN_EE_RATE;
                    END LOOP;

                    INSERT INTO TRANSACTION_DETAIL_TEMP (
                        TDT_TRAN_ID,
                        TDT_PLAN_ID,
                        TDT_CLIENT_ID,
                        TDT_EMPLOYER,
                        TDT_USER,
                        TDT_DATE_TIME,
                        TDT_MEM_ID,
                        TDT_FIRST_NAME,
                        TDT_LAST_NAME,
                        TDT_OCCU,
                        TDT_VOL_UNITS,
                        TDT_EE_UNITS,
                        TDT_ER_UNITS,
                        TDT_PEN_UNITS,
                        TDT_ER_RATE,
                        TDT_EE_RATE
                    ) VALUES (
                        P_TRAN_ID,
                        P_PLAN_ID,
                        P_CLIENT_ID,
                        P_EMPLOYER,
                        P_CREATED_BY,
                        SYSDATE,
                        V_MEM_ID,
                        V_MEM_FIRST_NAME,
                        V_MEM_LAST_NAME,
                        V_OCCU,
                        V_VOL_UNITS,
                        V_EE_UNITS,
                        V_ER_UNITS,
                        V_PENSION_UNITS,
                        V_ER_RATE,
                        V_EE_RATE
                    );

            END IF;

    END LOOP;
     -- update the headers tables

    IF
        V_CLOB IS NOT NULL
    THEN
        DIM_PKG.UPDATE_TRANSACTION_HEADERS(P_PLAN_ID,P_CLIENT_ID,P_TRAN_ID);
    END IF;
   exception
    WHEN OTHERS THEN
        NULL;
   end FILE_UPLOAD_DCPP;
    FUNCTION TRAN_VALUES (
        P_PLAN_ID     VARCHAR2,
        P_CLIENT_ID   VARCHAR2,
        P_TRAN_ID     VARCHAR2
    ) RETURN T_TRAN_VALUES
        PIPELINED
    IS
        TRAN_VALUES   T_TRAN_VALUES_REC;
    BEGIN
      -- initialize
        TRAN_VALUES := NULL;
        TRAN_VALUES.TRAN_ID := P_TRAN_ID;
        TRAN_VALUES.TRAN_RECD_AMT := 0;
        TRAN_VALUES.TRAN_BENEFIT := 'N';
        TRAN_VALUES.TRAN_BEN_EARNED := 'N';
        TRAN_VALUES.TRAN_PENSION := 'N';
        TRAN_VALUES.TRAN_PEN_EARNED := 'N';
        TRAN_VALUES.TRAN_FUNDS := 'N';
        TRAN_VALUES.TRAN_BALANCE := 0;
        TRAN_VALUES.TRAN_BEN_RECD_UNT := 0;
        TRAN_VALUES.TRAN_BEN_ENT_UNT := 0;
        TRAN_VALUES.TRAN_BEN_ENT_AMT := 0;
        TRAN_VALUES.TRAN_BEN_RECD_EE_AMT := 0;
        TRAN_VALUES.TRAN_BEN_RECD_ER_AMT := 0;
        TRAN_VALUES.TRAN_PEN_RECD_UNT := 0;
        TRAN_VALUES.TRAN_PEN_ENT_UNT := 0;
        TRAN_VALUES.TRAN_PEN_ENT_AMT := 0;
        TRAN_VALUES.TRAN_FUN_RECD_UNT := 0;
        TRAN_VALUES.TRAN_FUN_ENT_UNT := 0;
        TRAN_VALUES.TRAN_FUN_ENT_AMT := 0;
        TRAN_VALUES.TRAN_VOL_ENT_AMT := 0;
        TRAN_VALUES.TRAN_VOL_RECD_AMT := 0;
        TRAN_VALUES.TRAN_EE_ENT_AMT := 0;
        TRAN_VALUES.TRAN_EE_RECD_AMT := 0;
        TRAN_VALUES.TRAN_ER_ENT_AMT := 0;
        TRAN_VALUES.TRAN_ER_RECD_AMT := 0;
        TRAN_VALUES.TRAN_ER_RATE := 0;
        TRAN_VALUES.TRAN_EE_RATE := 0;
        TRAN_VALUES.TRAN_TOT_ENT_AMT := 0;

      -- get benefits values
        FOR B IN (
            SELECT
                THT_AGREE_ID,
                THT_EARNED,
                THT_RECD_AMT,
                NVL(THT_UNITS,0) BEN_UNITS,
                DECODE(THT_POST,'Y','Completed','P','Pending','In Progress') POST_STATUS,
                THT_EMPLOYER,
                THT_START_DATE,
                THT_END_DATE,
                THT_EE_UNITS,
                THT_ER_UNITS
            FROM
                TRANSACTION_HEADER_TEMP
            WHERE
                THT_PLAN_ID = P_PLAN_ID
                AND   THT_CLIENT_ID = P_CLIENT_ID
                   --AND   THT_TRAN_ID = P_TRAN_ID
        ) LOOP
            TRAN_VALUES.TRAN_RECD_AMT := B.THT_RECD_AMT;
            TRAN_VALUES.TRAN_BENEFIT := 'Y';
            TRAN_VALUES.TRAN_BEN_AGREE_ID := B.THT_AGREE_ID;
            TRAN_VALUES.TRAN_BEN_EARNED := B.THT_EARNED;
            TRAN_VALUES.TRAN_POST_STATUS := B.POST_STATUS;
            TRAN_VALUES.TRAN_BEN_RECD_UNT := B.BEN_UNITS;
            TRAN_VALUES.TRAN_EMPLOYER := B.THT_EMPLOYER;
            TRAN_VALUES.TRAN_START_DATE := B.THT_START_DATE;
            TRAN_VALUES.TRAN_END_DATE := B.THT_END_DATE;
            TRAN_VALUES.TRAN_BEN_RECD_EE_AMT := B.THT_EE_UNITS;
            TRAN_VALUES.TRAN_BEN_RECD_ER_AMT := B.THT_ER_UNITS;
        END LOOP;
      
      -- get pension values

        FOR P IN (
            SELECT
                THTP_AGREE_ID,
                THTP_EARNED,
                THTP_RECD_AMT,
                NVL(THTP_UNITS,0) PEN_UNITS,
                THTP_VOL_UNITS,
                THTP_EE_UNITS,
                THTP_ER_UNITS,
                DECODE(THTP_POST,'Y','Completed','P','Pending','In Progress') POST_STATUS,
                THTP_EMPLOYER,
                THTP_START_DATE,
                THTP_END_DATE
            FROM
                TRAN_HEADER_TEMP_PEN
            WHERE
                THTP_PLAN_ID = P_PLAN_ID
                AND   THT_CLIENT_ID = P_CLIENT_ID
                    AND   THTP_TRAN_ID = P_TRAN_ID
        ) LOOP
            TRAN_VALUES.TRAN_RECD_AMT := P.THTP_RECD_AMT;
            TRAN_VALUES.TRAN_PENSION := 'Y';
            TRAN_VALUES.TRAN_PEN_AGREE_ID := P.THTP_AGREE_ID;
            TRAN_VALUES.TRAN_PEN_EARNED := P.THTP_EARNED;
            TRAN_VALUES.TRAN_POST_STATUS := P.POST_STATUS;
            TRAN_VALUES.TRAN_PEN_RECD_UNT := P.PEN_UNITS;
            TRAN_VALUES.TRAN_VOL_RECD_AMT := P.THTP_VOL_UNITS;
            TRAN_VALUES.TRAN_EE_RECD_AMT := P.THTP_EE_UNITS;
            TRAN_VALUES.TRAN_ER_RECD_AMT := P.THTP_ER_UNITS;
            TRAN_VALUES.TRAN_EMPLOYER := P.THTP_EMPLOYER;
            TRAN_VALUES.TRAN_START_DATE := P.THTP_START_DATE;
            TRAN_VALUES.TRAN_END_DATE := P.THTP_END_DATE;
            FOR R IN (
                SELECT
                    TAD_ER_PORTION,
                    TAD_EE_PORTION
                FROM
                    TBL_AGREEMENT_DETAILS
                WHERE
                    TAD_CLIENT_ID = P_CLIENT_ID
                    AND   TAD_PLAN_ID = P_PLAN_ID
                        AND   TAD_AGREE_ID = TRAN_VALUES.TRAN_PEN_AGREE_ID
                            AND   TAD_FUND = 'PEN'
                                AND   TAD_OCCUP_ID IS NULL
                                    AND   TRIM(TAD_UNIT_TYPE) = DECODE(TRAN_VALUES.TRAN_PEN_EARNED,'Y','EARN','WORK')
                                        AND   TAD_EFF_DATE <= P.THTP_START_DATE
            ) LOOP
                TRAN_VALUES.TRAN_ER_RATE := NVL(R.TAD_ER_PORTION,0);
                TRAN_VALUES.TRAN_EE_RATE := NVL(R.TAD_EE_PORTION,0);
            END LOOP;

        END LOOP;
      
      -- get funds values

        FOR F IN (
            SELECT
                THTF_AGREE_ID,
                THTF_EARNED,
                THTF_RECD_AMT,
                THTF_UNITS,
                THTF_AMOUNT,
                DECODE(THTF_POST,'Y','Completed','P','Pending','In Progress') POST_STATUS,
                THTF_EMPLOYER,
                THTF_START_DATE,
                THTF_END_DATE
            FROM
                TRAN_HEADER_TEMP_FUNDS
            WHERE
                THTF_PLAN_ID = P_PLAN_ID
                AND   THTF_CLIENT_ID = P_CLIENT_ID
                    AND   THTF_TRAN_ID = P_TRAN_ID
        ) LOOP
            TRAN_VALUES.TRAN_RECD_AMT := F.THTF_RECD_AMT;
            TRAN_VALUES.TRAN_FUNDS := 'Y';
            TRAN_VALUES.TRAN_POST_STATUS := F.POST_STATUS;
            TRAN_VALUES.TRAN_FUN_ENT_UNT := F.THTF_UNITS;
            TRAN_VALUES.TRAN_FUN_ENT_AMT := F.THTF_AMOUNT;
            TRAN_VALUES.TRAN_EMPLOYER := F.THTF_EMPLOYER;
            TRAN_VALUES.TRAN_START_DATE := F.THTF_START_DATE;
            TRAN_VALUES.TRAN_END_DATE := F.THTF_END_DATE;
        -- get fund recd amount
            FOR FH IN (
                SELECT
                    NVL(SUM(HTFD_UNITS),0) FUN_UNITS
                FROM
                    TRAN_HEADDER_TEMP_FUNDS_DET
                WHERE
                    HTFD_TRAN_ID = P_TRAN_ID
                    AND   THTFD_CLIENT_ID = P_CLIENT_ID
            ) LOOP
                TRAN_VALUES.TRAN_FUN_RECD_UNT := FH.FUN_UNITS;
            END LOOP;

        END LOOP;
      
      -- validate transaction's units

        FOR M IN (
            SELECT
                NVL(SUM(TDT_UNITS),0) BEN_UNITS_USED,
                NVL(SUM(TDT_PEN_UNITS),0) PEN_UNITS_USED,
                NVL(SUM(TDT_UNITS * PENSION_PKG.GET_CONT_RATE(TDT_CLIENT_ID,TDT_PLAN_ID,SYSDATE,TRAN_VALUES.TRAN_BEN_AGREE_ID,TDT_EMPLOYER,TDT_MEM_ID
,TDT_OCCU,'HW',TRAN_VALUES.TRAN_BEN_EARNED) ),0) BEN_AMOUNT_USED,
                NVL(SUM(TDT_VOL_UNITS),0) + NVL(SUM(TDT_EE_UNITS),0) + NVL(SUM(TDT_ER_UNITS),0) PEN_AMOUNT_USED,
                NVL(SUM(TDT_VOL_UNITS),0) VOL_UNITS_USED,
                NVL(SUM(TDT_EE_UNITS),0) EE_UNITS_USED,
                NVL(SUM(TDT_ER_UNITS),0) ER_UNITS_USED
            FROM
                TRANSACTION_DETAIL_TEMP
            WHERE
                TDT_PLAN_ID = P_PLAN_ID
                AND   TDT_CLIENT_ID = P_CLIENT_ID
                    AND   TDT_TRAN_ID = P_TRAN_ID
        ) LOOP
            TRAN_VALUES.TRAN_BEN_ENT_UNT := M.BEN_UNITS_USED;
            TRAN_VALUES.TRAN_BEN_ENT_AMT := M.BEN_AMOUNT_USED;
            TRAN_VALUES.TRAN_PEN_ENT_UNT := M.PEN_UNITS_USED;
            TRAN_VALUES.TRAN_PEN_ENT_AMT := M.PEN_AMOUNT_USED;
            TRAN_VALUES.TRAN_VOL_ENT_AMT := M.VOL_UNITS_USED;
            TRAN_VALUES.TRAN_EE_ENT_AMT := M.EE_UNITS_USED;
            TRAN_VALUES.TRAN_ER_ENT_AMT := M.ER_UNITS_USED;

        -- validate benefit units
            IF
                M.BEN_UNITS_USED > 0 AND TRAN_VALUES.TRAN_BEN_RECD_UNT <> M.BEN_UNITS_USED
            THEN
                TRAN_VALUES.TRAN_VALIDATION_MSG := TRAN_VALUES.TRAN_VALIDATION_MSG
                || 'Variance of Benefit Units: '
                || ( TRAN_VALUES.TRAN_BEN_RECD_UNT - M.BEN_UNITS_USED )
                || ', ';
            END IF;
        -- validate pension units

            IF
                M.PEN_UNITS_USED > 0 AND TRAN_VALUES.TRAN_PEN_RECD_UNT <> M.PEN_UNITS_USED
            THEN
                TRAN_VALUES.TRAN_VALIDATION_MSG := TRAN_VALUES.TRAN_VALIDATION_MSG
                || 'Variance of Pension Units: '
                || ( TRAN_VALUES.TRAN_PEN_RECD_UNT - M.PEN_UNITS_USED )
                || ', ';
            END IF;
        -- validate funds units

            IF
                TRAN_VALUES.TRAN_FUN_ENT_UNT > 0 AND TRAN_VALUES.TRAN_FUN_RECD_UNT <> TRAN_VALUES.TRAN_FUN_ENT_UNT
            THEN
                TRAN_VALUES.TRAN_VALIDATION_MSG := TRAN_VALUES.TRAN_VALIDATION_MSG
                || 'Variance of Funds Units: '
                || ( TRAN_VALUES.TRAN_FUN_RECD_UNT - TRAN_VALUES.TRAN_FUN_ENT_UNT )
                || ', ';
            END IF;
        -- validate submitted amount

            TRAN_VALUES.TRAN_BALANCE := NVL(TRAN_VALUES.TRAN_RECD_AMT,0) - NVL(M.BEN_AMOUNT_USED,0) - NVL(M.PEN_AMOUNT_USED,0) - NVL(TRAN_VALUES.TRAN_FUN_ENT_AMT
,0);

            IF
                TRAN_VALUES.TRAN_BALANCE < 0
            THEN
                TRAN_VALUES.TRAN_VALIDATION_MSG := TRAN_VALUES.TRAN_VALIDATION_MSG
                || 'Variance of Amount: '
                || TO_CHAR(TRAN_VALUES.TRAN_BALANCE,'FM999G999G990D00')
                || ', ';
            END IF;
        -- validate voluntary units

            IF
                M.VOL_UNITS_USED > 0 AND TRAN_VALUES.TRAN_VOL_RECD_AMT <> M.VOL_UNITS_USED
            THEN
                TRAN_VALUES.TRAN_VALIDATION_MSG := TRAN_VALUES.TRAN_VALIDATION_MSG
                || 'Variance of Voluntary Units: '
                || ( TRAN_VALUES.TRAN_VOL_RECD_AMT - M.VOL_UNITS_USED )
                || ', ';
            END IF;
        -- validate employee units

            IF
                M.EE_UNITS_USED > 0 AND TRAN_VALUES.TRAN_EE_RECD_AMT <> M.EE_UNITS_USED
            THEN
                TRAN_VALUES.TRAN_VALIDATION_MSG := TRAN_VALUES.TRAN_VALIDATION_MSG
                || 'Variance of Employee Units: '
                || ( TRAN_VALUES.TRAN_EE_RECD_AMT - M.EE_UNITS_USED )
                || ', ';
            END IF;
        -- validate employer units

            IF
                M.ER_UNITS_USED > 0 AND TRAN_VALUES.TRAN_ER_RECD_AMT <> M.ER_UNITS_USED
            THEN
                TRAN_VALUES.TRAN_VALIDATION_MSG := TRAN_VALUES.TRAN_VALIDATION_MSG
                || 'Variance of Employer Units: '
                || ( TRAN_VALUES.TRAN_ER_RECD_AMT - M.ER_UNITS_USED )
                || ', ';
            END IF;
        -- remove last comma

            TRAN_VALUES.TRAN_VALIDATION_MSG := RTRIM(TRAN_VALUES.TRAN_VALIDATION_MSG,', ');
        END LOOP;

      -- get employer's name

        FOR E IN (
            SELECT
                INITCAP(CO_NAME) EMP_NAME
            FROM
                TBL_COMPMAST
            WHERE
                CO_PLAN = P_PLAN_ID
                AND   CO_CLIENT = P_CLIENT_ID
                    AND   CO_NUMBER = TRAN_VALUES.TRAN_EMPLOYER
        ) LOOP
            TRAN_VALUES.TRAN_EMPLOYER_NAME := E.EMP_NAME;
        END LOOP;
      
      -- get plan information

        FOR P IN (
            SELECT
                DECODE(PL_TYPE,'DCPP','Y','N') IS_DCPP
            FROM
                TBL_PLAN
            WHERE
                PL_CLIENT_ID = P_CLIENT_ID
                AND   PL_ID = P_PLAN_ID
        ) LOOP
            TRAN_VALUES.TRAN_IS_DCPP := P.IS_DCPP;
        END LOOP;

      -- get the transaction's totals
      TRAN_VALUES.TRAN_TOT_ENT_AMT := NVL(TRAN_VALUES.TRAN_BEN_ENT_AMT, 0) + NVL(TRAN_VALUES.TRAN_PEN_ENT_AMT, 0) + NVL(TRAN_VALUES.TRAN_FUN_ENT_AMT, 0);

        PIPE ROW ( TRAN_VALUES );
    END TRAN_VALUES;

    FUNCTION GET_MEMBER_OCCU (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_MEMBER_ID   VARCHAR2,
        P_REF_DATE    DATE DEFAULT SYSDATE
    ) RETURN VARCHAR2
        IS
    BEGIN
        FOR O IN (
            SELECT
                TEH_OCCU
            FROM
                TBL_EMPLOYMENT_HIST
            WHERE
                TEH_CLIENT = P_CLIENT_ID
                AND   TEH_PLAN = P_PLAN_ID
                    AND   TEH_ID = P_MEMBER_ID
                        AND   TEH_EFF_DATE = (
                    SELECT
                        MAX(B.TEH_EFF_DATE)
                    FROM
                        TBL_EMPLOYMENT_HIST B
                    WHERE
                        B.TEH_CLIENT = P_CLIENT_ID
                        AND   B.TEH_PLAN = P_PLAN_ID
                            AND   B.TEH_ID = P_MEMBER_ID
                                AND   B.TEH_EFF_DATE <= P_REF_DATE
                )
        ) LOOP
            RETURN O.TEH_OCCU;
        END LOOP;

        FOR O IN (
            SELECT
                MAX(TD_OCCU) TD_OCCU
            FROM
                TRANSACTION_DETAIL
            WHERE
                TD_CLIENT_ID = P_CLIENT_ID
                AND   TD_PLAN_ID = P_PLAN_ID
                    AND   TD_MEM_ID = P_MEMBER_ID
                        AND   TRUNC(TD_PERIOD,'MM') = (
                    SELECT
                        MAX(TRUNC(B.TD_PERIOD,'MM') )
                    FROM
                        TRANSACTION_DETAIL B
                    WHERE
                        B.TD_CLIENT_ID = P_CLIENT_ID
                        AND   B.TD_PLAN_ID = P_PLAN_ID
                            AND   B.TD_MEM_ID = P_MEMBER_ID
                                AND   TRUNC(B.TD_PERIOD,'MM') <= P_REF_DATE
                )
        ) LOOP
            RETURN O.TD_OCCU;
        END LOOP;

    END GET_MEMBER_OCCU;

    PROCEDURE UPDATE_MEMBER_SALARY (
        P_CLIENT_ID        VARCHAR2,
        P_PLAN_ID          VARCHAR2,
        P_MEMBER_ID        VARCHAR2,
        P_SALARY           VARCHAR2,
        P_EFFECTIVE_DATE   VARCHAR2
    ) IS
        L_SALARY           NUMBER;
        L_EFFECTIVE_DATE   DATE;
    BEGIN
        BEGIN
            L_SALARY := TO_NUMBER(P_SALARY,'FM999G999G999G990D00');
        EXCEPTION
            WHEN OTHERS THEN
                L_SALARY := TO_NUMBER(REPLACE(P_SALARY,',','') );
        END;

        L_EFFECTIVE_DATE := TO_DATE(P_EFFECTIVE_DATE,'DD-MON-YYYY');
      -- get the latest employment history record
        FOR S IN (
            SELECT
                *
            FROM
                (
                    SELECT
                        TEH_ER_ID,
                        TEH_EFF_DATE,
                        TEH_PROCESS_DATE,
                        TEH_OCCU,
                        TEH_EMPLOYMENT_TYPE,
                        TEH_UNION_LOCAL,
                        TEH_AGREE_ID,
                        TEH_HIRE_DATE,
                        MAX(TEH_EFF_DATE) OVER(
                            PARTITION BY TEH_CLIENT,
                            TEH_PLAN,
                            TEH_ID
                        ) MAX_TEH_EFF_DATE,
                        ROWID
                    FROM
                        TBL_EMPLOYMENT_HIST
                    WHERE
                        TEH_CLIENT = P_CLIENT_ID
                        AND   TEH_PLAN = P_PLAN_ID
                            AND   TEH_ID = P_MEMBER_ID
                )
            WHERE
                TEH_EFF_DATE = MAX_TEH_EFF_DATE
        ) LOOP
        -- terminate the actual employment history record
            UPDATE TBL_EMPLOYMENT_HIST
                SET
                    TEH_TREM_DATE = L_EFFECTIVE_DATE - 1,
                    TEH_LAST_MODIFIED_BY = V('APP_USER'),
                    TEH_LAST_MODIFIED_DATE = SYSDATE
            WHERE
                ROWID = S.ROWID;
        -- create a new employment history record

            INSERT INTO TBL_EMPLOYMENT_HIST (
                TEH_ID,
                TEH_ER_ID,
                TEH_EFF_DATE,
                TEH_SALARY,
                TEH_PROCESS_DATE,
                TEH_LAST_MODIFIED_BY,
                TEH_LAST_MODIFIED_DATE,
                TEH_OCCU,
                TEH_EMPLOYMENT_TYPE,
                TEH_PLAN,
                TEH_CLIENT,
                TEH_UNION_LOCAL,
                TEH_AGREE_ID,
                TEH_HIRE_DATE
            ) VALUES (
                P_MEMBER_ID,
                S.TEH_ER_ID,
                L_EFFECTIVE_DATE,
                L_SALARY,
                S.TEH_PROCESS_DATE,
                V('APP_USER'),
                SYSDATE,
                S.TEH_OCCU,
                S.TEH_EMPLOYMENT_TYPE,
                P_PLAN_ID,
                P_CLIENT_ID,
                S.TEH_UNION_LOCAL,
                S.TEH_AGREE_ID,
                S.TEH_HIRE_DATE
            );

        END LOOP;

    END UPDATE_MEMBER_SALARY;

    PROCEDURE SET_MEMBER_TERM_DATE (
        P_CLIENT_ID        VARCHAR2,
        P_PLAN_ID          VARCHAR2,
        P_MEMBER_ID        VARCHAR2,
        P_EFFECTIVE_DATE   VARCHAR2
    )
        IS
    BEGIN
        FOR S IN (
            SELECT
                *
            FROM
                (
                    SELECT
                        MAX(TEH_EFF_DATE) OVER(
                            PARTITION BY TEH_CLIENT,
                            TEH_PLAN,
                            TEH_ID
                        ) MAX_TEH_EFF_DATE,
                        TEH_EFF_DATE,
                        ROWID
                    FROM
                        TBL_EMPLOYMENT_HIST
                    WHERE
                        TEH_CLIENT = P_CLIENT_ID
                        AND   TEH_PLAN = P_PLAN_ID
                            AND   TEH_ID = P_MEMBER_ID
                )
            WHERE
                TEH_EFF_DATE = MAX_TEH_EFF_DATE
        ) LOOP
        -- terminate the actual employment history record
            UPDATE TBL_EMPLOYMENT_HIST
                SET
                    TEH_TREM_DATE = TO_DATE(P_EFFECTIVE_DATE,'MM/DD/YYYY') - 1,
                    TEH_LAST_MODIFIED_BY = V('APP_USER'),
                    TEH_LAST_MODIFIED_DATE = SYSDATE
            WHERE
                ROWID = S.ROWID;

        END LOOP;
    END SET_MEMBER_TERM_DATE;

    FUNCTION GET_GROUP_TYPE_DESC (
        P_GROUP_TYPE VARCHAR2
    ) RETURN VARCHAR2
        IS
    BEGIN
        IF
            P_GROUP_TYPE = 'HW'
        THEN
            RETURN 'Health and Benefits';
        ELSIF P_GROUP_TYPE = 'PEN' THEN
            RETURN 'Pension';
        ELSIF P_GROUP_TYPE = 'HSA' THEN
            RETURN 'Health Spending Account';
        ELSIF P_GROUP_TYPE = 'FUNDS' THEN
            RETURN 'Funds';
        ELSE
            RETURN '';
        END IF;
    END GET_GROUP_TYPE_DESC;

    procedure DUPLICATE_TRANSACTION (
    P_CLIENT_ID          VARCHAR2,
    P_PLAN_ID            VARCHAR2,
    P_OLD_TRAN_ID        VARCHAR2,
    P_NEW_TRAN_ID        VARCHAR2,
    P_DUPLICATION_TYPE   VARCHAR2
) IS
    L_HEADER_INSERTED VARCHAR2(1);
    L_SIGNAL NUMBER;
    L_COMMENT VARCHAR2(255);
    begin
    IF
        TRIM(P_NEW_TRAN_ID) IS NULL OR TRIM(P_OLD_TRAN_ID) IS NULL
    THEN
        RETURN;
    END IF;

    L_HEADER_INSERTED := 'N';
    L_SIGNAL :=
        CASE
            WHEN P_DUPLICATION_TYPE = 'N' THEN 1
            ELSE -1
        END;
    L_COMMENT := '* duplicated'
    ||
        CASE
            WHEN P_DUPLICATION_TYPE = 'R' THEN ' (reverse)'
        END
    || ' from transaction '
    || P_OLD_TRAN_ID
    || ' *';

      -- duplicate pension header

    FOR H IN (
        SELECT
            *
        FROM
            TRAN_HEADER_TEMP_PEN
        WHERE
            THT_CLIENT_ID = P_CLIENT_ID
            AND   THTP_PLAN_ID = P_PLAN_ID
                AND   THTP_TRAN_ID = P_OLD_TRAN_ID
                    AND   THTP_POST = 'Y'
    ) LOOP
        INSERT INTO TRAN_HEADER_TEMP_PEN (
            THTP_EMPLOYER,
            THTP_PLAN_ID,
            THTP_START_DATE,
            THTP_END_DATE,
            THTP_PERIOD,
            THTP_UNITS,
            THTP_RATE,
            THTP_AMOUNT,
            THTP_PAYMENT_TYPE,
            THTP_COMMENT,
            THTP_USER,
            THTP_DATE_TIME,
            THTP_MEM_ID,
            THTP_TRAN_ID,
            THTP_POSTED_DATE,
            THTP_POST,
            THTP_CHEQUE,
            THTP_EARNED,
            THTP_RECD_AMT,
            THTP_VARIANCE_AMT,
            THTP_VAR_REASON,
            THT_CLIENT_ID,
            THTP_DEPOSIT_NUMBER,
            THTP_AGREE_ID,
            THTP_EARNINGS,
            THTP_VOL_UNITS,
            THTP_HRS,
            THTP_EE_UNITS,
            THTP_ER_UNITS,
            THTP_EE_ACCOUNT,
            THTP_ER_ACCOUNT,
            THTP_VOL_ACCOUNT
        ) VALUES (
            H.THTP_EMPLOYER,
            H.THTP_PLAN_ID,
            H.THTP_START_DATE,
            H.THTP_END_DATE,
            H.THTP_PERIOD,
            H.THTP_UNITS * L_SIGNAL,
            H.THTP_RATE,
            H.THTP_AMOUNT * L_SIGNAL,
            H.THTP_PAYMENT_TYPE,
            H.THTP_COMMENT
            || CHR(10)
            || L_COMMENT,
            H.THTP_USER,
            SYSDATE,
            H.THTP_MEM_ID,
            P_NEW_TRAN_ID,
            NULL,
            'P',
            H.THTP_CHEQUE,
            H.THTP_EARNED,
            H.THTP_RECD_AMT * L_SIGNAL,
            H.THTP_VARIANCE_AMT * L_SIGNAL,
            H.THTP_VAR_REASON,
            H.THT_CLIENT_ID,
            H.THTP_DEPOSIT_NUMBER,
            H.THTP_AGREE_ID,
            H.THTP_EARNINGS * L_SIGNAL,
            H.THTP_VOL_UNITS * L_SIGNAL,
            H.THTP_HRS * L_SIGNAL,
            H.THTP_EE_UNITS * L_SIGNAL,
            H.THTP_ER_UNITS * L_SIGNAL,
            H.THTP_EE_ACCOUNT,
            H.THTP_ER_ACCOUNT,
            H.THTP_VOL_ACCOUNT
        );

        L_HEADER_INSERTED := 'Y';
        EXIT;
    END LOOP;

      -- duplicate benefits header

    FOR H IN (
        SELECT
            *
        FROM
            TRANSACTION_HEADER_TEMP
        WHERE
            THT_CLIENT_ID = P_CLIENT_ID
            AND   THT_PLAN_ID = P_PLAN_ID
                AND   THT_TRAN_ID = P_OLD_TRAN_ID
                    AND   THT_POST = 'Y'
    ) LOOP
        INSERT INTO TRANSACTION_HEADER_TEMP (
            THT_EMPLOYER,
            THT_PLAN_ID,
            THT_START_DATE,
            THT_END_DATE,
            THT_PERIOD,
            THT_UNITS,
            THT_RATE,
            THT_AMOUNT,
            THT_PAYMENT_TYPE,
            THT_COMMENT,
            THT_USER,
            THT_DATE_TIME,
            THT_MEM_ID,
            THT_TRAN_ID,
            THT_POST,
            THT_CHEQUE,
            THT_POSTED_DATE,
            THT_EARNED,
            THT_RECD_AMT,
            THT_VARIANCE_AMT,
            THT_VAR_REASON,
            THT_CLIENT_ID,
            THT_DEPOSIT_NUMBER,
            THT_AGREE_ID
        ) VALUES (
            H.THT_EMPLOYER,
            H.THT_PLAN_ID,
            H.THT_START_DATE,
            H.THT_END_DATE,
            H.THT_PERIOD,
            H.THT_UNITS * L_SIGNAL,
            H.THT_RATE,
            H.THT_AMOUNT * L_SIGNAL,
            H.THT_PAYMENT_TYPE,
            H.THT_COMMENT
            || CHR(10)
            || L_COMMENT,
            H.THT_USER,
            SYSDATE,
            H.THT_MEM_ID,
            P_NEW_TRAN_ID,
            'P',
            H.THT_CHEQUE,
            NULL,
            H.THT_EARNED,
            H.THT_RECD_AMT * L_SIGNAL,
            H.THT_VARIANCE_AMT * L_SIGNAL,
            H.THT_VAR_REASON,
            H.THT_CLIENT_ID,
            H.THT_DEPOSIT_NUMBER,
            H.THT_AGREE_ID
        );

        L_HEADER_INSERTED := 'Y';
        EXIT;
    END LOOP;

      -- duplicate funds header

    FOR H IN (
        SELECT
            *
        FROM
            TRAN_HEADER_TEMP_FUNDS
        WHERE
            THTF_CLIENT_ID = P_CLIENT_ID
            AND   THTF_PLAN_ID = P_PLAN_ID
                AND   THTF_TRAN_ID = P_OLD_TRAN_ID
                    AND   THTF_POST = 'Y'
    ) LOOP
        INSERT INTO TRAN_HEADER_TEMP_FUNDS (
            THTF_EMPLOYER,
            THTF_PLAN_ID,
            THTF_START_DATE,
            THTF_END_DATE,
            THTF_PERIOD,
            THTF_UNITS,
            THTF_RATE,
            THTF_AMOUNT,
            THTF_PAYMENT_TYPE,
            THTF_COMMENT,
            THTF_USER,
            THTF_DATE_TIME,
            THTF_MEM_ID,
            THTF_TRAN_ID,
            THTF_POST,
            THTF_CHEQUE,
            THTF_POSTED_DATE,
            THTF_EARNED,
            THTF_RECD_AMT,
            THTF_VARIANCE_AMT,
            THTF_VAR_REASON,
            THTF_CLIENT_ID,
            THTF_DEPOSIT_NUMBER,
            THTF_AGREE_ID
        ) VALUES (
            H.THTF_EMPLOYER,
            H.THTF_PLAN_ID,
            H.THTF_START_DATE,
            H.THTF_END_DATE,
            H.THTF_PERIOD,
            H.THTF_UNITS * L_SIGNAL,
            H.THTF_RATE,
            H.THTF_AMOUNT * L_SIGNAL,
            H.THTF_PAYMENT_TYPE,
            H.THTF_COMMENT
            || CHR(10)
            || L_COMMENT,
            H.THTF_USER,
            SYSDATE,
            H.THTF_MEM_ID,
            P_NEW_TRAN_ID,
            'P',
            H.THTF_CHEQUE,
            NULL,
            H.THTF_EARNED,
            H.THTF_RECD_AMT * L_SIGNAL,
            H.THTF_VARIANCE_AMT * L_SIGNAL,
            H.THTF_VAR_REASON,
            H.THTF_CLIENT_ID,
            H.THTF_DEPOSIT_NUMBER,
            H.THTF_AGREE_ID
        );

        L_HEADER_INSERTED := 'Y';

        -- duplicate funds header's details
        FOR HD IN (
            SELECT
                *
            FROM
                TRAN_HEADDER_TEMP_FUNDS_DET
            WHERE
                THTFD_CLIENT_ID = P_CLIENT_ID
                AND   HTFD_TRAN_ID = P_OLD_TRAN_ID
        ) LOOP
            INSERT INTO TRAN_HEADDER_TEMP_FUNDS_DET (
                HTFD_TRAN_ID,
                HTFD_FUND,
                HTFD_UNITS,
                HTFD_RATE,
                HTFD_AMT,
                THTFD_CLIENT_ID,
                HTFD_AGREE_ID
            ) VALUES (
                P_NEW_TRAN_ID,
                HD.HTFD_FUND,
                HD.HTFD_UNITS * L_SIGNAL,
                HD.HTFD_RATE,
                HD.HTFD_AMT * L_SIGNAL,
                HD.THTFD_CLIENT_ID,
                HD.HTFD_AGREE_ID
            );

        END LOOP;

        EXIT;
    END LOOP;

      -- duplicate transaction's details (pension, benefit)

    IF
        L_HEADER_INSERTED = 'Y'
    THEN
        FOR D IN (
            SELECT
                T.*,
                M.MEM_FIRST_NAME,
                M.MEM_LAST_NAME
            FROM
                TBL_MEMBER M,
                TRANSACTION_DETAIL_TEMP T
            WHERE
                T.TDT_CLIENT_ID = P_CLIENT_ID
                AND   T.TDT_PLAN_ID = P_PLAN_ID
                    AND   T.TDT_TRAN_ID = P_OLD_TRAN_ID
                        AND   M.MEM_CLIENT_ID (+) = T.TDT_CLIENT_ID
                            AND   M.MEM_PLAN (+) = T.TDT_PLAN_ID
                                AND   M.MEM_ID (+) = T.TDT_MEM_ID
        ) LOOP
            INSERT INTO TRANSACTION_DETAIL_TEMP (
                TDT_TRAN_ID,
                TDT_EMPLOYER,
                TDT_PLAN_ID,
                TDT_START_DATE,
                TDT_END_DATE,
                TDT_PERIOD,
                TDT_UNITS,
                TDT_AMOUNT,
                TDT_COMMENT,
                TDT_USER,
                TDT_DATE_TIME,
                TDT_MEM_ID,
                TDT_KEY,
                TDT_LAST_NAME,
                TDT_FIRST_NAME,
                TDT_PEN_UNITS,
                TDT_FUNDS_UNITS,
                TDT_CLIENT_ID,
                TDT_OCCU,
                TDT_RATE,
                TDT_EARNINGS,
                TDT_VOL_UNITS,
                TDT_HRS,
                TDT_EE_UNITS,
                TDT_ER_UNITS,
                TDT_ER_RATE,
                TDT_EE_RATE,
                TDT_MEM_SIN
            ) VALUES (
                P_NEW_TRAN_ID,
                D.TDT_EMPLOYER,
                D.TDT_PLAN_ID,
                D.TDT_START_DATE,
                D.TDT_END_DATE,
                D.TDT_PERIOD,
                D.TDT_UNITS * L_SIGNAL,
                D.TDT_AMOUNT * L_SIGNAL,
                D.TDT_COMMENT,
                D.TDT_USER,
                D.TDT_DATE_TIME,
                D.TDT_MEM_ID,
                D.TDT_KEY,
                D.MEM_LAST_NAME,
                D.MEM_FIRST_NAME,
                D.TDT_PEN_UNITS * L_SIGNAL,
                D.TDT_FUNDS_UNITS * L_SIGNAL,
                D.TDT_CLIENT_ID,
                D.TDT_OCCU,
                D.TDT_RATE,
                D.TDT_EARNINGS * L_SIGNAL,
                D.TDT_VOL_UNITS * L_SIGNAL,
                D.TDT_HRS * L_SIGNAL,
                D.TDT_EE_UNITS * L_SIGNAL,
                D.TDT_ER_UNITS * L_SIGNAL,
                D.TDT_ER_RATE,
                D.TDT_EE_RATE,
                D.TDT_MEM_SIN
            );

        END LOOP;

        -- duplicate fund's details

        FOR D IN (
            SELECT
                *
            FROM
                TRAN_DETAILS_TEMP_FUNDS_DET
            WHERE
                DTF_TRAN_ID = P_OLD_TRAN_ID
        ) LOOP
            INSERT INTO TRAN_DETAILS_TEMP_FUNDS_DET (
                DTF_TRAN_ID,
                DTF_MEM_ID,
                DTF_FUND,
                DTF_UNITS,
                DTF_RATE,
                DTF_AMT,
                DTF_EMPLOYER,
                DTF_OCCU
            ) VALUES (
                P_NEW_TRAN_ID,
                D.DTF_MEM_ID,
                D.DTF_FUND,
                D.DTF_UNITS * L_SIGNAL,
                D.DTF_RATE,
                D.DTF_AMT * L_SIGNAL,
                D.DTF_EMPLOYER,
                D.DTF_OCCU
            );

        END LOOP;

    END IF;

    end DUPLICATE_TRANSACTION;
    PROCEDURE DELETE_TRANSACTION (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_TRAN_ID     VARCHAR2
    ) IS
        L_DELETED_HEADER   VARCHAR2(1);
    BEGIN
        L_DELETED_HEADER := 'N';
        IF
            TRIM(P_TRAN_ID) IS NULL
        THEN
            RETURN;
        END IF;

      -- delete pension header
        DELETE TRAN_HEADER_TEMP_PEN
        WHERE
            THT_CLIENT_ID = P_CLIENT_ID
            AND   THTP_PLAN_ID = P_PLAN_ID
                AND   THTP_TRAN_ID = P_TRAN_ID
                    AND   THTP_POST <> 'Y';

        IF
            SQL%ROWCOUNT > 0
        THEN
            L_DELETED_HEADER := 'Y';
        END IF;

      -- delete benefits header
        DELETE TRANSACTION_HEADER_TEMP
        WHERE
            THT_CLIENT_ID = P_CLIENT_ID
            AND   THT_PLAN_ID = P_PLAN_ID
                AND   THT_TRAN_ID = P_TRAN_ID
                    AND   THT_POST <> 'Y';

        IF
            SQL%ROWCOUNT > 0
        THEN
            L_DELETED_HEADER := 'Y';
        END IF;

      -- delete funds header
        DELETE TRAN_HEADER_TEMP_FUNDS
        WHERE
            THTF_CLIENT_ID = P_CLIENT_ID
            AND   THTF_PLAN_ID = P_PLAN_ID
                AND   THTF_TRAN_ID = P_TRAN_ID
                    AND   THTF_POST <> 'Y';

        IF
            SQL%ROWCOUNT > 0
        THEN
            L_DELETED_HEADER := 'Y';
        END IF;
        IF
            L_DELETED_HEADER = 'Y'
        THEN
        -- delete funds header details
            DELETE TRAN_HEADDER_TEMP_FUNDS_DET
            WHERE
                THTFD_CLIENT_ID = P_CLIENT_ID
                AND   HTFD_TRAN_ID = P_TRAN_ID;

        -- delete transaction details

            DELETE TRANSACTION_DETAIL_TEMP
            WHERE
                TDT_CLIENT_ID = P_CLIENT_ID
                AND   TDT_PLAN_ID = P_PLAN_ID
                    AND   TDT_TRAN_ID = P_TRAN_ID;
        
        -- delete fund details

            DELETE TRAN_DETAILS_TEMP_FUNDS_DET WHERE
                DTF_TRAN_ID = P_TRAN_ID;

        END IF;

    END DELETE_TRANSACTION;

    PROCEDURE APEX_FILE_LAYOUT (
        P_IS_PENSION   VARCHAR2,
        P_IS_BENEFIT   VARCHAR2,
        P_IS_DCPP      VARCHAR2
    )
        IS
    BEGIN
        HTP.P('
        <p>
          The expected CSV file should obey the following rules:</br>
          * the file should not contain header columns.</br>
          * the columns should be comma separated.</br>
          * other columns found in the file will be ignored.
        </p>
        </br>
        Columns list:
      '
);
        IF
            P_IS_PENSION = 'Y' AND P_IS_BENEFIT = 'N'
        THEN
            IF
                P_IS_DCPP = 'Y'
            THEN
                HTP.P('
            <table class="t-file-layout">
              <thead>
                <tr>
                  <th>Column Order</th>
                  <th>Column Name</th>
                  <th>Data Type</th>
                  <th>Required</th>
                  <th>Sample</th>
                </tr>
              <thead>
              <tbody>
                <tr>
                  <td>1</td>
                  <td>Member ID</td>
                  <td>Integer</td>
                  <td>Yes</td>
                  <td>123</td>
                </tr>
                <tr>
                  <td>2</td>
                  <td>Hours</td>
                  <td>Numeric</td>
                  <td>No</td>
                  <td>456.78</td>
                </tr>
                <tr>
                  <td>3</td>
                  <td>Employer Amount</td>
                  <td>Numeric</td>
                  <td>No</td>
                  <td>901.2</td>
                </tr>
                <tr>
                  <td>4</td>
                  <td>Employee Amount</td>
                  <td>Numeric</td>
                  <td>No</td>
                  <td>3456.78</td>
                </tr>
                <tr>
                  <td>5</td>
                  <td>Voluntary Amount</td>
                  <td>Numeric</td>
                  <td>No</td>
                  <td>90</td>
                </tr>
              </tbody>
            </table>
          '
);
                HTP.P('
            </br>
            <p>
              A sample file having 2 rows would be like:
            </p>
            <p>
              123,456.78,901.2,3456.78,90</br>
              111,160,235,,300</br>
            </p>
          '
);
            ELSIF P_IS_DCPP = 'N' THEN
                NULL;
            END IF;

        ELSIF P_IS_PENSION = 'N' AND P_IS_BENEFIT = 'Y' THEN
            HTP.P('
          <table class="t-file-layout">
            <thead>
              <tr>
                <th>Column Order</th>
                <th>Column Name</th>
                <th>Data Type</th>
                <th>Required</th>
                <th>Sample</th>
              </tr>
            <thead>
            <tbody>
              <tr>
                <td>1</td>
                <td>Member ID</td>
                <td>Integer</td>
                <td>Yes</td>
                <td>123</td>
              </tr>
              <tr>
                <td>2</td>
                <td>Occupation</td>
                <td>String</td>
                <td>No</td>
                <td>ADMIN</td>
              </tr>
              <tr>
                <td>3</td>
                <td>Hours</td>
                <td>Numeric</td>
                <td>No</td>
                <td>456.78</td>
              </tr>
            </tbody>
          </table>
        '
);
            HTP.P('
          </br>
          <p>
            A sample file having 2 rows would be like:
          </p>
          <p>
            123,ADMIN,456.5</br>
            111,CONL,160</br>
          </p>
        '
);
        ELSIF P_IS_PENSION = 'Y' AND P_IS_BENEFIT = 'Y' THEN
            HTP.P('
          <table class="t-file-layout">
            <thead>
              <tr>
                <th>Column Order</th>
                <th>Column Name</th>
                <th>Data Type</th>
                <th>Required</th>
                <th>Sample</th>
              </tr>
            <thead>
            <tbody>
              <tr>
                <td>1</td>
                <td>Member ID</td>
                <td>Integer</td>
                <td>Yes</td>
                <td>123</td>
              </tr>
              <tr>
                <td>2</td>
                <td>Occupation</td>
                <td>String</td>
                <td>No</td>
                <td>ALL</td>
              </tr>
              <tr>
                <td>3</td>
                <td>H&W Hours</td>
                <td>Numeric</td>
                <td>No</td>
                <td>456.78</td>
              </tr>
              <tr>
                <td>4</td>
                <td>Pension Hours</td>
                <td>Numeric</td>
                <td>No</td>
                <td>901.2</td>
              </tr>
              <tr>
                <td>5</td>
                <td>Employer Amount</td>
                <td>Numeric</td>
                <td>No</td>
                <td>3456.78</td>
              </tr>
              <tr>
                <td>6</td>
                <td>Employee Amount</td>
                <td>Numeric</td>
                <td>No</td>
                <td>90</td>
              </tr>
              <tr>
                <td>7</td>
                <td>Voluntary Amount</td>
                <td>Numeric</td>
                <td>No</td>
                <td>1234.5</td>
              </tr>
            </tbody>
          </table>
        '
);
            HTP.P('
          </br>
          <p>
            A sample file having 2 rows would be like:
          </p>
          <p>
            123,ALL,456.78,901.2,3456.78,90,1234.5</br>
            111,ADMIN,160,170.5,,300,2550</br>
          </p>
        '
);
        END IF;
      -- css

        HTP.P('
        <style>
          table.t-file-layout { width: 100%; }
          table.t-file-layout tbody { text-align: center; }
          table.t-file-layout td, th { border: 1px solid #CCC; }
        </style>
      '
);
    END APEX_FILE_LAYOUT;

  function pen_contributions(p_client_id varchar2, p_plan_id varchar2, p_from date, p_to date, p_employer_id varchar2) return t_pen_contributions pipelined is
    l_contribution t_pen_contribution;
  begin
    for t in (
      select thp_employer employer_id,
             thp_deposit_number deposit_slip_no,
             thp_deposit_slip_date deposit_slip_date,
             thp_tran_id tran_id,
             thp_date_time tran_entered_date,
             thp_posted_date tran_posted_date,
             thp_cheque payment_reference,
             thp_write_off_amt,
             thp_recd_amt payment_amount,
             thp_start_date contrib_start_date,
             thp_end_date contrib_end_date,
             thp_comment comments
        from transaction_header_pen
       where thp_client_id = p_client_id
         and thp_plan_id = p_plan_id
         and thp_posted_date >= p_from
         and thp_posted_date <= p_to
         and thp_employer like nvl(p_employer_id,'%')
    ) loop
      l_contribution := null;
      l_contribution.employer_id := t.employer_id;
      l_contribution.deposit_slip_no := t.deposit_slip_no;
      l_contribution.deposit_slip_date := t.deposit_slip_date;
      l_contribution.tran_id := t.tran_id;
      l_contribution.tran_entered_date := t.tran_entered_date;
      l_contribution.tran_posted_date := t.tran_posted_date;
      l_contribution.payment_reference := t.payment_reference;
      l_contribution.payment_amount := t.payment_amount;
      l_contribution.payment_amount := t.payment_amount;
      l_contribution.contrib_start_date := t.contrib_start_date;
      l_contribution.contrib_end_date := t.contrib_end_date;
      l_contribution.comments := t.comments;
      for v in (
        select tran_employer_name, tran_er_rate, tran_er_recd_amt, tran_ee_rate, tran_ee_recd_amt, tran_vol_recd_amt
          from table(dim_pkg.tran_values(p_plan_id, p_client_id, t.tran_id))
      ) loop
        l_contribution.employer_name := v.tran_employer_name;
        l_contribution.employer_contrib_rate := v.tran_er_rate;
        l_contribution.employer_contrib_amt := v.tran_er_recd_amt;
        l_contribution.employee_contrib_rate := v.tran_ee_rate;
        l_contribution.employee_contrib_amt := v.tran_ee_recd_amt;
        l_contribution.voluntary_contrib_amt := v.tran_vol_recd_amt;
        l_contribution.total_contrib_amt := nvl(v.tran_er_recd_amt, 0) + nvl(v.tran_ee_recd_amt, 0) + nvl(v.tran_vol_recd_amt, 0);        
      end loop;
      l_contribution.over_short_amt := l_contribution.payment_amount - l_contribution.total_contrib_amt;
      if l_contribution.over_short_amt = 0 then
        l_contribution.over_short_amt := null;
      end if;
      l_contribution.write_off := to_char(t.thp_write_off_amt, 'FM999G999G990D00');
      if nvl(l_contribution.employee_contrib_rate, 0) = 0 then
        l_contribution.val_check := '';
      else
        if l_contribution.employee_contrib_amt >= (l_contribution.employee_contrib_amt / l_contribution.employee_contrib_rate) * l_contribution.employer_contrib_rate then
          l_contribution.val_check := 'OK';
        else
          l_contribution.val_check := to_char(l_contribution.employer_contrib_amt - ((l_contribution.employee_contrib_amt / l_contribution.employee_contrib_rate) * l_contribution.employer_contrib_rate), 'FM999G999G990D00');
        end if;
      end if;
      pipe row (l_contribution);
    end loop;
  end pen_contributions;
function hw_contributions(p_client_id varchar2, p_plan_id varchar2, p_from date, p_to date, p_employer_id varchar2) return t_pen_contributions pipelined is
    l_contribution t_pen_contribution;
  begin
    for t in (
      select th_employer employer_id,
             th_deposit_number deposit_slip_no,
             th_deposit_slip_date deposit_slip_date,
             th_tran_id tran_id,
             th_date_time tran_entered_date,
             th_posted_date tran_posted_date,
             th_cheque payment_reference,
             th_write_off_amt,
             th_recd_amt payment_amount,
             th_start_date contrib_start_date,
             th_end_date contrib_end_date,
             th_comment comments
        from transaction_header
       where th_client_id = p_client_id
         and th_plan_id = p_plan_id
         and th_posted_date >= p_from
         and th_posted_date <= p_to
         and th_employer like nvl(p_employer_id,'%')
    ) loop
      l_contribution := null;
      l_contribution.employer_id := t.employer_id;
      l_contribution.deposit_slip_no := t.deposit_slip_no;
      l_contribution.deposit_slip_date := t.deposit_slip_date;
      l_contribution.tran_id := t.tran_id;
      l_contribution.tran_entered_date := t.tran_entered_date;
      l_contribution.tran_posted_date := t.tran_posted_date;
      l_contribution.payment_reference := t.payment_reference;
      l_contribution.payment_amount := t.payment_amount;
      l_contribution.payment_amount := t.payment_amount;
      l_contribution.contrib_start_date := t.contrib_start_date;
      l_contribution.contrib_end_date := t.contrib_end_date;
      l_contribution.comments := t.comments;
      for v in (
        select tran_employer_name, tran_er_rate, tran_er_recd_amt, tran_ee_rate, tran_ee_recd_amt, tran_vol_recd_amt
          from table(dim_pkg.tran_values(p_plan_id, p_client_id, t.tran_id))
      ) loop
        l_contribution.employer_name := v.tran_employer_name;
        l_contribution.employer_contrib_rate := v.tran_er_rate;
        l_contribution.employer_contrib_amt := v.tran_er_recd_amt;
        l_contribution.employee_contrib_rate := v.tran_ee_rate;
        l_contribution.employee_contrib_amt := v.tran_ee_recd_amt;
        l_contribution.voluntary_contrib_amt := v.tran_vol_recd_amt;
        l_contribution.total_contrib_amt := nvl(v.tran_er_recd_amt, 0) + nvl(v.tran_ee_recd_amt, 0) + nvl(v.tran_vol_recd_amt, 0);        
      end loop;
      l_contribution.over_short_amt := l_contribution.payment_amount - l_contribution.total_contrib_amt;
      if l_contribution.over_short_amt = 0 then
        l_contribution.over_short_amt := null;
      end if;
      l_contribution.write_off := to_char(t.th_write_off_amt, 'FM999G999G990D00');
      if nvl(l_contribution.employee_contrib_rate, 0) = 0 then
        l_contribution.val_check := '';
      else
        if l_contribution.employee_contrib_amt >= (l_contribution.employee_contrib_amt / l_contribution.employee_contrib_rate) * l_contribution.employer_contrib_rate then
          l_contribution.val_check := 'OK';
        else
          l_contribution.val_check := to_char(l_contribution.employer_contrib_amt - ((l_contribution.employee_contrib_amt / l_contribution.employee_contrib_rate) * l_contribution.employer_contrib_rate), 'FM999G999G990D00');
        end if;
      end if;
      pipe row (l_contribution);
    end loop;
  end hw_contributions;
  function get_hw_ee_rate(p_client_id varchar2, p_plan_id varchar2, p_date date, p_agree_id varchar2, p_occu_id varchar2, p_ben_earned varchar2) return number is
  begin
    for r in (
      select distinct a.tad_ee_portion
        from tbl_agreement_details a
       where a.tad_client_id = p_client_id
         and a.tad_plan_id = p_plan_id
         and a.tad_agree_id = p_agree_id
         and nvl(a.tad_fund, '%') like '%HW%'
         and nvl(a.tad_occup_id, '%') like nvl(p_occu_id, '%')
         and nvl(a.tad_unit_type, '%') like decode(p_ben_earned, 'Y', 'EARN', 'WORK')
         and a.tad_eff_date = (
               select max(b.tad_eff_date)
                 from tbl_agreement_details b
                where b.tad_client_id = p_client_id
                  and b.tad_plan_id = p_plan_id
                  and b.tad_agree_id = p_agree_id
                  and nvl(b.tad_fund, '%') like '%HW%'
                  and nvl(b.tad_occup_id, '%') like nvl(p_occu_id, '%')
                  and nvl(b.tad_unit_type, '%') like decode(p_ben_earned, 'Y', 'EARN', 'WORK')
                  and b.tad_eff_date <= p_date
             )
    ) loop      
      return r.tad_ee_portion;
    end loop;
    return null;
  end get_hw_ee_rate;

  function get_hw_er_rate(p_client_id varchar2, p_plan_id varchar2, p_date date, p_agree_id varchar2, p_occu_id varchar2, p_ben_earned varchar2) return number is
  begin
    for r in (
      select distinct a.tad_er_portion
        from tbl_agreement_details a
       where a.tad_client_id = p_client_id
         and a.tad_plan_id = p_plan_id
         and a.tad_agree_id = p_agree_id
         and nvl(a.tad_fund, '%') like '%HW%'
         and nvl(a.tad_occup_id, '%') like nvl(p_occu_id, '%')
         and nvl(a.tad_unit_type, '%') like decode(p_ben_earned, 'Y', 'EARN', 'WORK')
         and a.tad_eff_date = (
               select max(b.tad_eff_date)
                 from tbl_agreement_details b
                where b.tad_client_id = p_client_id
                  and b.tad_plan_id = p_plan_id
                  and b.tad_agree_id = p_agree_id
                  and nvl(b.tad_fund, '%') like '%HW%'
                  and nvl(b.tad_occup_id, '%') like nvl(p_occu_id, '%')
                  and nvl(b.tad_unit_type, '%') like decode(p_ben_earned, 'Y', 'EARN', 'WORK')
                  and b.tad_eff_date <= p_date
             )
    ) loop      
      return r.tad_er_portion;
    end loop;
    return null;
  end get_hw_er_rate;

END DIM_PKG;

/

