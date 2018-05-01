-- 
-- Non Foreign Key Constraints for Table EBA_RESTDEMO_COLUMN_MAPPINGS 
-- 
ALTER TABLE OLIVER.EBA_RESTDEMO_COLUMN_MAPPINGS ADD (
  CONSTRAINT EBA_RESTDEMO_CK_COLMAP_PK
  CHECK ( primary_key in ( 'Y', 'N' ) )
  ENABLE VALIDATE);

ALTER TABLE OLIVER.EBA_RESTDEMO_COLUMN_MAPPINGS ADD (
  CONSTRAINT EBA_RESTDEMO_CK_COLMAP_TYPE
  CHECK ( data_type in ( 'VARCHAR2', 'NUMBER', 'DATE' ) )
  ENABLE VALIDATE);

ALTER TABLE OLIVER.EBA_RESTDEMO_COLUMN_MAPPINGS ADD (
  CONSTRAINT EBA_RESTDEMO_COLMAPPINGS_PK
  PRIMARY KEY
  (ID)
  USING INDEX OLIVER.EBA_RESTDEMO_COLMAPPINGS_PK
  ENABLE VALIDATE);

