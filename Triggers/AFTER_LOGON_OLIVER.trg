--
-- AFTER_LOGON_OLIVER  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.after_logon_oliver after logon on schema
begin
  if user = 'OLIVER' then
    oliver.init.setclientid('DT');
  end if;
end;
/


