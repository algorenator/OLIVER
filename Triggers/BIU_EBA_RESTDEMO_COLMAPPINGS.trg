--
-- BIU_EBA_RESTDEMO_COLMAPPINGS  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.biu_eba_restdemo_colmappings
before insert or update ON OLIVER.EBA_RESTDEMO_COLUMN_MAPPINGS
for each row
begin
    :new.column_name := upper( :new.column_name );
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
        :new.updated_by := nvl(wwv_flow.g_user,user);
    end if;
end;
/


