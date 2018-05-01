--
-- BI_CARRIER_TEMP  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.BI_CARRIER_TEMP 
  before insert ON OLIVER.CARRIER_TEMP
  for each row
begin
  select CARRIER_TEMP_seq.nextval into :new.ct_key from dual;
end;
/


