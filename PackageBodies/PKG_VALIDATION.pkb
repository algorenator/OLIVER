--
-- PKG_VALIDATION  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.PKG_VALIDATION AS

    FUNCTION PHONE_REGEXP RETURN VARCHAR2
        IS
    BEGIN
        RETURN '^(\(\d{3}\))([[:blank:]])\d{3}-\d{4}$|^\d{3}(-)\d{3}(-)\d{4}$|^\d{10}$';
    END PHONE_REGEXP;

    FUNCTION EMAIL_REGEXP RETURN VARCHAR2
        IS
    BEGIN
        RETURN '^[A-Za-z]+[A-Za-z0-9.]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$';
    END EMAIL_REGEXP;

    FUNCTION POSTAL_CODE_REGEXP RETURN VARCHAR2
        IS
    BEGIN
        RETURN '^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} *\d{1}[A-Z]{1}\d{1}$';
    END POSTAL_CODE_REGEXP;

    FUNCTION SIN_REGEXP RETURN VARCHAR2
        IS
    BEGIN
        RETURN '^\d{3}\s?\d{3}\s?\d{3}$';
    END SIN_REGEXP;

    FUNCTION PWD_FMT_REGEXP RETURN VARCHAR2
        IS
    BEGIN
    --return '([[:alpha:]]{1}[[:digit:]]{1})|([[:digit:]]{1}[[:alpha:]]{1})';
        RETURN '([[:alpha:]]{1})';
    END PWD_FMT_REGEXP;

    FUNCTION PWD_LEN_REGEXP RETURN VARCHAR2
        IS
    BEGIN
        RETURN '[[:alnum:]]{6,}';
    END PWD_LEN_REGEXP;

    FUNCTION DATE_FMT RETURN VARCHAR2
        IS
    BEGIN
        RETURN 'DD-MON-YYYY';
    END DATE_FMT;

    FUNCTION ALPHA_NUM_ONLY RETURN VARCHAR2 IS
    BEGIN
      RETURN '^[a-zA-Z0-9]*$';
    END ALPHA_NUM_ONLY;

    function is_sin_valid(p_client_id varchar2, p_plan_id varchar2, p_sin number) return varchar2 is
    begin
      for p in (
        select null
          from tbl_plan
         where pl_client_id = p_client_id
           and pl_id = p_plan_id
           and pl_verify_sin = 'N'
      ) loop
        return 'Y';
      end loop;
      return oliver.is_sin_valid(p_sin);
    end is_sin_valid;

END PKG_VALIDATION;

/

