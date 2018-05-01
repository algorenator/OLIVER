--
-- GET_REPORT_SQL  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.get_report_sql (
   p_app_id     IN   NUMBER,
   p_page_id    IN   NUMBER,
   p_all_cols   IN   BOOLEAN DEFAULT TRUE
)
   RETURN VARCHAR2
IS
   v_report_id   NUMBER;
   v_region_id   NUMBER;
   v_report      apex_ir.t_report;
   v_query       VARCHAR2 (32767);
   v_column      VARCHAR2 (4000);
   v_position    NUMBER;
BEGIN
   SELECT region_id
     INTO v_region_id
     FROM apex_application_page_regions
    WHERE application_id = p_app_id
      AND page_id = p_page_id
      AND source_type = 'Interactive Report';

   v_report_id :=
      apex_ir.get_last_viewed_report_id (p_page_id        => p_page_id,
                                         p_region_id      => v_region_id
                                        );
   v_report :=
      apex_ir.get_report (p_page_id        => p_page_id,
                          p_region_id      => v_region_id,
                          p_report_id      => v_report_id
                         );
   v_query := v_report.sql_query;

   FOR i IN 1 .. v_report.binds.COUNT
   LOOP
      v_query :=
         REPLACE (v_query,
                  ':' || v_report.binds (i).NAME,
                  '''' || v_report.binds (i).VALUE || ''''
                 );
   END LOOP;

   IF p_all_cols
   THEN
      FOR c IN (SELECT   *
                    FROM apex_application_page_ir_col
                   WHERE application_id = p_app_id AND page_id = p_page_id
                ORDER BY display_order)
      LOOP
         v_column := v_column || ', ' || c.column_alias;
      END LOOP;

      v_column := LTRIM (v_column, ', ');
      v_position := INSTR (v_query, '(');
      v_query := SUBSTR (v_query, v_position);
      v_query := 'SELECT ' || v_column || ' FROM ' || v_query;
   END IF;

   RETURN v_query;
EXCEPTION
   WHEN OTHERS
   THEN
      v_query := SQLERRM;
      RETURN v_query;
END get_report_sql;
/

