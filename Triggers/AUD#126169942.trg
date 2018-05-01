--
-- AUD#126169942  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUD#126169942 
after insert or update or delete ON OLIVER.TBL_EMPLOYER_NOTES
for each row
begin

    table_audit_pkg.check_val( 'TBL_EMPLOYER_NOTES','EN_NOTE',:new.EN_NOTE,:old.EN_NOTE,:new.rowid);

end;
/


