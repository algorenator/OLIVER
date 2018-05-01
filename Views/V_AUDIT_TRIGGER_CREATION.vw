--
-- V_AUDIT_TRIGGER_CREATION  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.V_AUDIT_TRIGGER_CREATION
(TABLE_NAME, COLUMN_NAME, TRIGGER_DDL)
AS 
SELECT
  table_name, column_name,   'create or replace trigger aud#'
    || TO_CHAR(abs(dbms_random.random) )
    || CHR(10)
    || 'after insert or update or delete on '
    || utc.table_name
    || CHR(10)
    || 'for each row'
    || CHR(10)
    || CHR(13)
    || 'begin'
    || CHR(10)
    || CHR(13)
    || '    table_audit_pkg.check_val( '''
    || utc.table_name
    || ''', '''
    || utc.column_name
    || ''', '
    || ':new.'
    || utc.column_name
    || ', :old.'
    || utc.column_name
    || ', :new.rowid);'
    || CHR(10)
    || CHR(13)
    || 'end;'
    || CHR(10)
    || '/'
    || CHR(10)
    || CHR(13) trigger_ddl
FROM
    user_tab_columns utc
order by table_name, column_name;


