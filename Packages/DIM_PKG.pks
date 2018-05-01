--
-- DIM_PKG  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.DIM_PKG AS
    TYPE T_TRAN_VALUES_REC IS RECORD ( TRAN_ID VARCHAR2(15),
    TRAN_START_DATE DATE,
    TRAN_END_DATE DATE,
    TRAN_EMPLOYER_NAME VARCHAR2(100),
    TRAN_IS_DCPP VARCHAR2(1),
    TRAN_RECD_AMT NUMBER,
    TRAN_BENEFIT VARCHAR2(1),
    TRAN_BEN_AGREE_ID VARCHAR2(20),
    TRAN_BEN_EARNED VARCHAR2(1),
    TRAN_PENSION VARCHAR2(1),
    TRAN_PEN_AGREE_ID VARCHAR2(20),
    TRAN_PEN_EARNED VARCHAR2(1),
    TRAN_FUNDS VARCHAR2(1),
    TRAN_VALIDATION_MSG VARCHAR2(2000),
    TRAN_BALANCE NUMBER,
    TRAN_POST_STATUS VARCHAR2(30),
    TRAN_BEN_RECD_UNT NUMBER,
    TRAN_BEN_ENT_UNT NUMBER,
    TRAN_BEN_ENT_AMT NUMBER,
    TRAN_BEN_RECD_EE_AMT NUMBER,
    TRAN_BEN_RECD_ER_AMT NUMBER,
    TRAN_PEN_RECD_UNT NUMBER,
    TRAN_PEN_ENT_UNT NUMBER,
    TRAN_PEN_ENT_AMT NUMBER,
    TRAN_FUN_RECD_UNT NUMBER,
    TRAN_FUN_ENT_UNT NUMBER,
    TRAN_FUN_ENT_AMT NUMBER,
    TRAN_VOL_ENT_AMT NUMBER,
    TRAN_VOL_RECD_AMT NUMBER,
    TRAN_EE_ENT_AMT NUMBER,
    TRAN_EE_RECD_AMT NUMBER,
    TRAN_ER_ENT_AMT NUMBER,
    TRAN_ER_RECD_AMT NUMBER,
    TRAN_EMPLOYER VARCHAR2(100),
    TRAN_ER_RATE NUMBER,
    TRAN_EE_RATE NUMBER,
    TRAN_TOT_ENT_AMT NUMBER
    );
    TYPE T_TRAN_VALUES IS TABLE OF T_TRAN_VALUES_REC;

    type t_pen_contribution is record (
      employer_id varchar2(100),
      employer_name varchar2(100),
      deposit_slip_no varchar2(100),
      deposit_slip_date date,
      tran_id varchar2(100),
      tran_entered_date date,
      tran_posted_date date,
      payment_reference varchar2(100),
      payment_amount number,
      contrib_start_date date,
      contrib_end_date date,
      employer_contrib_rate number,
      employer_contrib_amt number,
      employee_contrib_rate number,
      employee_contrib_amt number,
      voluntary_contrib_amt number,
      total_contrib_amt number,
      over_short_amt number,
      write_off varchar2(100),
      val_check varchar2(100),
      comments varchar2(3000)
    );
    type t_pen_contributions is table of t_pen_contribution;

    FUNCTION TRAN_VALUES (
        P_PLAN_ID     VARCHAR2,
        P_CLIENT_ID   VARCHAR2,
        P_TRAN_ID     VARCHAR2
    ) RETURN T_TRAN_VALUES PIPELINED;

    PROCEDURE UPDATE_TRANSACTION_HEADERS (
        P_PLAN_ID     VARCHAR2,
        P_CLIENT_ID   VARCHAR2,
        P_TRAN_ID     VARCHAR2
    );

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
    ) RETURN VARCHAR2;

    PROCEDURE DELETE_MEMBER (
        P_TDT_KEY VARCHAR2
    );

    PROCEDURE DELETE_ALL_MEMBERS (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_TRAN_ID     VARCHAR2
    );

    FUNCTION VALIDATE_MEMBER_DETAIL (
        P_TRAN_ID VARCHAR2,
        P_TDT_MEM_ID VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GENERATE_TRAN_ID RETURN VARCHAR2;

    PROCEDURE REMITTANCE_UPLOAD (
        P_CLIENT_ID    VARCHAR2,
        P_PLAN_ID      VARCHAR2,
        P_TRAN_ID      VARCHAR2,
        P_APP_ID       NUMBER,
        P_SESSION_ID   NUMBER,
        P_CREATED_BY   VARCHAR2
    );

    PROCEDURE FILE_UPLOAD (
        P_PEN_AGREEMENT   VARCHAR2,
        P_TRAN_ID         VARCHAR2,
        P_CLIENT_ID       VARCHAR2,
        P_PLAN_ID         VARCHAR2,
        P_EMPLOYER        VARCHAR2,
        P_PERIOD          DATE,
        P_APP_ID          NUMBER,
        P_SESSION_ID      NUMBER,
        P_CREATED_BY      VARCHAR2
    );

    PROCEDURE FILE_UPLOAD_DCPP (
        P_CLIENT_ID    VARCHAR2,
        P_PLAN_ID      VARCHAR2,
        P_TRAN_ID      VARCHAR2,
        P_EMPLOYER     VARCHAR2,
        P_APP_ID       NUMBER,
        P_SESSION_ID   NUMBER,
        P_CREATED_BY   VARCHAR2
    );

    FUNCTION GET_MEMBER_OCCU (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_MEMBER_ID   VARCHAR2,
        P_REF_DATE    DATE DEFAULT SYSDATE
    ) RETURN VARCHAR2;

    PROCEDURE UPDATE_MEMBER_SALARY (
        P_CLIENT_ID        VARCHAR2,
        P_PLAN_ID          VARCHAR2,
        P_MEMBER_ID        VARCHAR2,
        P_SALARY           VARCHAR2,
        P_EFFECTIVE_DATE   VARCHAR2
    );

    PROCEDURE SET_MEMBER_TERM_DATE (
        P_CLIENT_ID        VARCHAR2,
        P_PLAN_ID          VARCHAR2,
        P_MEMBER_ID        VARCHAR2,
        P_EFFECTIVE_DATE   VARCHAR2
    );

    FUNCTION GET_GROUP_TYPE_DESC (
        P_GROUP_TYPE VARCHAR2
    ) RETURN VARCHAR2;

    PROCEDURE DUPLICATE_TRANSACTION (
        P_CLIENT_ID          VARCHAR2,
        P_PLAN_ID            VARCHAR2,
        P_OLD_TRAN_ID        VARCHAR2,
        P_NEW_TRAN_ID        VARCHAR2,
        P_DUPLICATION_TYPE   VARCHAR2
    );

    PROCEDURE DELETE_TRANSACTION (
        P_CLIENT_ID   VARCHAR2,
        P_PLAN_ID     VARCHAR2,
        P_TRAN_ID     VARCHAR2
    );

    PROCEDURE APEX_FILE_LAYOUT (
        P_IS_PENSION   VARCHAR2,
        P_IS_BENEFIT   VARCHAR2,
        P_IS_DCPP      VARCHAR2
    );
    
    function pen_contributions(p_client_id varchar2, p_plan_id varchar2, p_from date, p_to date, p_employer_id varchar2) return t_pen_contributions pipelined;
    function hw_contributions(p_client_id varchar2, p_plan_id varchar2, p_from date, p_to date, p_employer_id varchar2) return t_pen_contributions pipelined;
    function get_hw_ee_rate(p_client_id varchar2, p_plan_id varchar2, p_date date, p_agree_id varchar2, p_occu_id varchar2, p_ben_earned varchar2) return number;
    function get_hw_er_rate(p_client_id varchar2, p_plan_id varchar2, p_date date, p_agree_id varchar2, p_occu_id varchar2, p_ben_earned varchar2) return number;

END DIM_PKG;

/

