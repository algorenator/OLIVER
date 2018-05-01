--
-- AUD#988848128  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUD#988848128 
after insert or update or delete ON OLIVER.TBL_PENMAST
for each row
begin

    table_audit_pkg.check_val( 'TBL_PENMAST','PENM_STATUS',:new.PENM_STATUS,:old.PENM_STATUS,:new.rowid);

end;
/


