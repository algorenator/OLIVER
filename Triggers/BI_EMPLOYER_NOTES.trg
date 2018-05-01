--
-- BI_EMPLOYER_NOTES  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.BI_EMPLOYER_NOTES 
  before insert ON OLIVER.TBL_EMPLOYER_NOTES
  for each row
begin
  select EMPLOYER_NOTE_seq.nextval into :new.EN_KEY from dual;
end;
/


