--
-- BI_EMPLOYER_CONTACTS  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.BI_EMPLOYER_CONTACTS 
  before insert ON OLIVER.TBL_EMPLOYER_CONTACTS
  for each row
begin
  select EMPLOYER_CONTACT_seq.nextval into :new.TEC_KEY from dual;
  --:new.user_name := upper(:new.user_name);
end;
/


