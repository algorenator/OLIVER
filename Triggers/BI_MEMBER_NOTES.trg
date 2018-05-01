--
-- BI_MEMBER_NOTES  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.BI_MEMBER_NOTES 
  before insert ON OLIVER.TBL_MEMBER_NOTES
  for each row
begin
  select MEMBER_NOTES_seq.nextval into :new.MN_KEY from dual;
  --:new.user_name := upper(:new.user_name);
end;
/


