--
-- TRG_BEF_INS_UPD_USERS_PASSWD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.TRG_BEF_INS_UPD_USERS_PASSWD 
before insert or update of password ON OLIVER.USERS for each row
begin
  :new.password := pkg_portal_auth.create_hash_password(:new.email, :new.password);
end;
/


