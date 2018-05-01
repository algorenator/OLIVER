--
-- V_APEX_VIEWS  (View) 
--
CREATE OR REPLACE FORCE VIEW OLIVER.V_APEX_VIEWS
(S, COMMENTS)
AS 
select LPAD (' ', (LEVEL - 1) * 2) ||  apex_view_name s, comments
from (
  select 'ROOT' as apex_view_name, null as comments, null as parent_view
  from dual
  UNION
  select apex_view_name, comments, nvl(parent_view,'ROOT') as parent_view
  from apex_dictionary
  where column_id = 0
) 
  connect by prior apex_view_name = parent_view
  start with parent_view is null
order SIBLINGS by apex_view_name DESC;


