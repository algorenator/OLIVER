-- 
-- Non Foreign Key Constraints for Table EBA_DEMO_CHART_POPULATION 
-- 
ALTER TABLE OLIVER.EBA_DEMO_CHART_POPULATION ADD (
  CONSTRAINT EBA_DEMO_CHART_POP_PK
  PRIMARY KEY
  (ID)
  USING INDEX OLIVER.EBA_DEMO_CHART_POP_PK
  ENABLE VALIDATE);

