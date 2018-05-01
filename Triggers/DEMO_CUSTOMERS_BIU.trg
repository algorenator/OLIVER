--
-- DEMO_CUSTOMERS_BIU  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.DEMO_CUSTOMERS_BIU 
  before insert or update ON OLIVER.DEMO_CUSTOMERS FOR EACH ROW
DECLARE
  cust_id number;
BEGIN
  if inserting then  
    if :new.customer_id is null then
      select demo_cust_seq.nextval
        into cust_id
        from dual;
      :new.customer_id := cust_id;
    end if;
    if :new.tags is not null then
          :new.tags := sample_pkg.demo_tags_cleaner(:new.tags);
    end if;
  end if;
  sample_pkg.demo_tag_sync(
     p_new_tags      => :new.tags,
     p_old_tags      => :old.tags,
     p_content_type  => 'CUSTOMER',
     p_content_id    => :new.customer_id );
END;
/


