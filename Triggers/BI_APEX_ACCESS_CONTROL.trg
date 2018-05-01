--
-- BI_APEX_ACCESS_CONTROL  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.BI_APEX_ACCESS_CONTROL 
  before insert or update ON OLIVER.APEX_ACCESS_CONTROL
  for each row
begin
    if inserting and :new.id is null then
        select apex_access_control_seq.nextval into :new.id from sys.dual;
    end if;
    if inserting then
        :new.created_by := v('USER');
        :new.created_on := sysdate;
    end if;
    if updating then
        :new.updated_by := v('USER');
        :new.updated_on := sysdate;
    end if;
end;
/


