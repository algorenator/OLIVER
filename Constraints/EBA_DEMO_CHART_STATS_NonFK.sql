-- 
-- Non Foreign Key Constraints for Table EBA_DEMO_CHART_STATS 
-- 
ALTER TABLE OLIVER.EBA_DEMO_CHART_STATS ADD (
  CONSTRAINT EBA_DEMO_CHART_STATS_PK
  PRIMARY KEY
  (ID)
  USING INDEX OLIVER.EBA_DEMO_CHART_STATS_PK
  ENABLE VALIDATE);

