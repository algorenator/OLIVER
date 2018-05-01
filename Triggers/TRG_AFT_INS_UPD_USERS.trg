--
-- TRG_AFT_INS_UPD_USERS  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.TRG_AFT_INS_UPD_USERS 
after insert or update or delete ON OLIVER.USERS for each row
declare
  l_affected_cols varchar2(2000);
  l_operator varchar2(2000);
begin
  l_operator := nvl(v('APP_USER'), user);
  if lower(l_operator) = 'nobody' then
    l_operator := 'SYSTEM';
  end if;
  if inserting then
    insert into app_users_audit (
      client_id, email, affected_cols, created_by, created_on
    ) values (
      :new.client_id, :new.email, 'USER CREATED', l_operator, sysdate
    );
  end if;
  if updating then
    if updating('USER_ID') then
      l_affected_cols := l_affected_cols || 'USER_ID, ';
    end if;
    if updating('USER_NAME') then
      l_affected_cols := l_affected_cols || 'USER_NAME, ';
    end if;
    if updating('PASSWORD') then
      l_affected_cols := l_affected_cols || 'PASSWORD, ';
    end if;
    if updating('FILE_NAME') then
      l_affected_cols := l_affected_cols || 'FILE_NAME, ';
    end if;
    if updating('MIME_TYPE') then
      l_affected_cols := l_affected_cols || 'MIME_TYPE, ';
    end if;
    if updating('ATTACHMENT') then
      l_affected_cols := l_affected_cols || 'ATTACHMENT, ';
    end if;
    if updating('USER_FIRST_NAME') then
      l_affected_cols := l_affected_cols || 'USER_FIRST_NAME, ';
    end if;
    if updating('USER_LAST_NAME') then
      l_affected_cols := l_affected_cols || 'USER_LAST_NAME, ';
    end if;
    if updating('USER_EFFECTIVE_DATE') then
      l_affected_cols := l_affected_cols || 'USER_EFFECTIVE_DATE, ';
    end if;
    if updating('USER_TERMINATION_DATE') then
      l_affected_cols := l_affected_cols || 'USER_TERMINATION_DATE, ';
    end if;
    if updating('CLIENT_ID') then
      l_affected_cols := l_affected_cols || 'CLIENT_ID, ';
    end if;
    if updating('EMAIL') then
      l_affected_cols := l_affected_cols || 'EMAIL, ';
    end if;
    if updating('ISADMIN') then
      l_affected_cols := l_affected_cols || 'ISADMIN, ';
    end if;
    if updating('VERIFICATION_CODE') then
      l_affected_cols := l_affected_cols || 'VERIFICATION_CODE, ';
    end if;
    l_affected_cols := substr(l_affected_cols, 1, length(l_affected_cols) - 2);
    insert into app_users_audit (
      client_id, email, affected_cols, updated_by, updated_on
    ) values (
      nvl(:old.client_id, :new.client_id), nvl(:old.email, :new.email), l_affected_cols, l_operator, sysdate
    );
  end if;
  if deleting then
    insert into app_users_audit (
      client_id, email, affected_cols, updated_by, updated_on
    ) values (
      :old.client_id, :old.email, 'USER DELETED', l_operator, sysdate
    );
  end if;
end trg_aft_ins_upd_users;
/


