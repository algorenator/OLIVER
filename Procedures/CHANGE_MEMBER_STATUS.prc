--
-- CHANGE_MEMBER_STATUS  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.CHANGE_MEMBER_STATUS (
    P_CLIENT_ID   VARCHAR2,
    P_PLAN_ID     VARCHAR2,
    P_MEM_ID      VARCHAR,
    P_STATUS      VARCHAR2,
    P_EFF_DATE    DATE
) IS
    L_OLD_STATUS_DATE   DATE;
BEGIN

  -- get latest status and validate new status
    FOR L IN (
        SELECT
            TMPSH_STATUS,
            TMPSH_STATUS_DATE
        FROM
            TBL_MEM_PEN_STATUS_HIST
        WHERE
            TMPSH_CLIENT = P_CLIENT_ID
            AND   TMPSH_PLAN = P_PLAN_ID
            AND   TMPSH_MEM_ID = P_MEM_ID
        ORDER BY
            TMPSH_STATUS_DATE DESC
    ) LOOP
        IF
            L.TMPSH_STATUS = P_STATUS
        THEN
            RAISE_APPLICATION_ERROR(-20000,'The New Status should be different from Latest Status.');
        END IF;
        IF
            P_EFF_DATE <= L.TMPSH_STATUS_DATE
        THEN
            RAISE_APPLICATION_ERROR(-20000,'The Effective Date should be greater than Latest Effective Date.');
        END IF;

        L_OLD_STATUS_DATE := L.TMPSH_STATUS_DATE;
        EXIT;
    END LOOP;

  -- insert new status

    INSERT INTO TBL_MEM_PEN_STATUS_HIST (
        TMPSH_CLIENT,
        TMPSH_PLAN,
        TMPSH_MEM_ID,
        TMPSH_STATUS,
        TMPSH_STATUS_DATE,
        TMPSH_CREATED_DATE,
        TMPSH_CREATED_BY
    ) VALUES (
        P_CLIENT_ID,
        P_PLAN_ID,
        P_MEM_ID,
        P_STATUS,
        P_EFF_DATE,
        SYSDATE,
        NVL(V('APP_USER'),USER)
    );

  -- update tbl_annual

    UPDATE TBL_ANNUAL
        SET
            ANN_STATUS = P_STATUS
    WHERE
        ANN_CLIENT = P_CLIENT_ID
        AND   ANN_PLAN = P_PLAN_ID
        AND   ANN_ID = P_MEM_ID
        AND   ANN_YEAR >= TO_NUMBER(TO_CHAR(P_EFF_DATE,'YYYY') );

  -- update tbl_penmast

    UPDATE TBL_PENMAST
        SET
            PENM_STATUS = P_STATUS,
            PENM_STATUS_DATE = P_EFF_DATE
    WHERE
        PENM_CLIENT = P_CLIENT_ID
        AND   PENM_PLAN = P_PLAN_ID
        AND   PENM_ID = P_MEM_ID;

END CHANGE_MEMBER_STATUS;
/

