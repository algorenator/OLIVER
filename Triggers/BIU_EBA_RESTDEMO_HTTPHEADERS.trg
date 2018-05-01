--
-- BIU_EBA_RESTDEMO_HTTPHEADERS  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.biu_eba_restdemo_httpheaders
before insert or update ON OLIVER.EBA_RESTDEMO_HTTP_HEADERS
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
    end if;
    if inserting or updating then 
        :new.updated := localtimestamp;
        :new.header_for := upper(:new.header_for);
        :new.header_name := initcap(:new.header_name);
        :new.updated_by := nvl(wwv_flow.g_user,user);
    end if;
end;
/


