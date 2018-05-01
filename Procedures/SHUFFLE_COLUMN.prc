--
-- SHUFFLE_COLUMN  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.SHUFFLE_COLUMN (
    VTABLE   IN VARCHAR2,
    VCOL     IN VARCHAR2,
    VWHERE   IN VARCHAR2 DEFAULT NULL
) AS
    STR    VARCHAR2(2000);
    STRW   VARCHAR2(2000) := ' where 1=1 ';
BEGIN
    IF
        VWHERE IS NOT NULL
    THEN
        STRW := STRW
        || ' and '
        || VWHERE;
    END IF;

    STR := 'update '
    || VTABLE
    || ' t'
    || CHR(10)
    || 'set '
    || VCOL
    || ' ='
    || CHR(10)
    || '(with dq'
    || CHR(10)
    || 'as (select distinct '
    || VCOL
    || ' from '
    || VTABLE
    || STRW
    || ')'
    || CHR(10)
    || '(select v_new from'
    || CHR(10)
    || '(select  ranked.'
    || VCOL
    || ' v_old, rand.'
    || VCOL
    || ' v_new'
    || CHR(10)
    || '          from ('
    || CHR(10)
    || '                 select '
    || VCOL
    || ','
    || CHR(10)
    || '                       rownum as rk'
    || CHR(10)
    || '                 from   dq'
    || CHR(10)
    || '               ) ranked '
    || CHR(10)
    || '        inner join ( '
    || CHR(10)
    || '                 select '
    || VCOL
    || ', row_number() over (order by dbms_random.value()) as rnd'
    || CHR(10)
    || '                 from   dq'
    || CHR(10)
    || '               ) rand'
    || CHR(10)
    || '          on ranked.rk = rand.rnd'
    || CHR(10)
    || ' where t.'
    || VCOL
    || '=ranked.'
    || VCOL
    || ')'
    || CHR(10)
    || ')) '
    || STRW;

    DBMS_OUTPUT.PUT_LINE(STR);
    EXECUTE IMMEDIATE STR;
END SHUFFLE_COLUMN;
/

