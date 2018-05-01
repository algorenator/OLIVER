--
-- BIU_EBA_RESTDEMO_URLPARAMS  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.biu_eba_restdemo_urlparams
before insert or update ON OLIVER.EBA_RESTDEMO_URLPARAMETERS
for each row
begin
    if inserting then
        :new.id := to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
        :new.created := localtimestamp;
        :new.created_by := nvl(wwv_flow.g_user,user);
        :new.row_version_number := 1;
    end if;
    if updating then 
        :new.row_version_number := nvl(:old.row_version_number, 1) + 1;
    end if;
    if inserting or updating then 
        :new.param_name := lower(:new.param_name);
        :new.param_for  := upper(:new.param_for);
        :new.updated    := localtimestamp;
        :new.updated_by := nvl(wwv_flow.g_user,user);
    end if;
end;
/


