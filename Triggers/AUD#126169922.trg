--
-- AUD#126169922  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AUD#126169922 
after insert or update or delete ON OLIVER.TBL_MEMBER_NOTES
for each row
begin

    table_audit_pkg.check_val( 'TBL_MEMBER_NOTES','MN_NOTE',:new.MN_NOTE,:old.MN_NOTE,:new.rowid);

end;
/


