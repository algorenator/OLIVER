--
-- BI_USERS  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.BI_USERS 
  before insert ON OLIVER.USERS
  for each row
begin
  select users_seq.nextval into :new.user_id from dual;
  --:new.user_name := upper(:new.user_name);
end;
/


