--
-- BIU_EBA_RESTDEMO_LOG  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.biu_eba_restdemo_log
before insert ON OLIVER.EBA_RESTDEMO_LOG
for each row
begin
    :new.id := to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    :new.time_stamp := localtimestamp;
end;
/


