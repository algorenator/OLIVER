--
-- BI_TBL_CLAIMS  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.BI_TBL_CLAIMS 
  before insert ON OLIVER.TBL_CLAIMS
  for each row
begin
  select TBL_CLAIMS_seq.nextval into :new.cL_key from dual;
end;
/


