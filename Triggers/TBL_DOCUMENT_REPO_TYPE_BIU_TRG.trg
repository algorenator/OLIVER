--
-- TBL_DOCUMENT_REPO_TYPE_BIU_TRG  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.TBL_DOCUMENT_REPO_TYPE_BIU_TRG 
before insert or update ON OLIVER.TBL_DOCUMENT_REPO_TYPE
for each row
begin
    if inserting then
        :new.document_repo_type_id := tbl_document_repo_type_seq.nextval;
        :new.cre_by := nvl(v('APP_USER'), user);
        :new.cre_date := sysdate;
    end if;

    if updating then
        :new.mod_by := nvl(v('APP_USER'), user);
        :new.mod_date := sysdate;
    end if;
end;
/


