--
-- BI_TBL_DOCUMENT  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.BI_TBL_DOCUMENT 
  before insert ON OLIVER.TBL_DOCUMENT
  for each row
begin
  select DOCUMENT_seq.nextval into :new.DOC_key from dual;
end;
/


