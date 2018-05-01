--
-- BIU_EBA_RESTDEMO_SERVICES  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.biu_eba_restdemo_services
before insert or update ON OLIVER.EBA_RESTDEMO_SERVICES
for each row
begin
    if inserting then
        :new.id := to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
        :new.created := localtimestamp;
        :new.created_by := nvl(wwv_flow.g_user,user);
        :new.row_version_number := 1;
    end if;
    if updating then 
        :new.row_version_number := nvl(:old.row_version_number,1) + 1;
        if :new.auth_basic_password is null then :new.auth_basic_password := :old.auth_basic_password; end if;
        if :new.oauth_clientsecret is null then :new.oauth_clientsecret := :old.oauth_clientsecret; end if;
    end if;
    if inserting or updating then 
        :new.updated := localtimestamp;
        :new.updated_by := nvl(wwv_flow.g_user,user);
    end if;
end;
/


