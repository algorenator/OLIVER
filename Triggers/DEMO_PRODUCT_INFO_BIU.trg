--
-- DEMO_PRODUCT_INFO_BIU  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.DEMO_PRODUCT_INFO_BIU 
  before insert or update ON OLIVER.DEMO_PRODUCT_INFO FOR EACH ROW
DECLARE
  prod_id number;
BEGIN
  if inserting then  
    if :new.product_id is null then
      select demo_prod_seq.nextval
        into prod_id
        from dual;
      :new.product_id := prod_id;
    end if;
    if :new.tags is not null then
          :new.tags := sample_pkg.demo_tags_cleaner(:new.tags);
    end if;
  end if;
  sample_pkg.demo_tag_sync(
    p_new_tags      => :new.tags,
    p_old_tags      => :old.tags,
    p_content_type  => 'PRODUCT',
    p_content_id    => :new.product_id );
END;
/


