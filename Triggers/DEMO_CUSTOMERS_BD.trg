--
-- DEMO_CUSTOMERS_BD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.DEMO_CUSTOMERS_BD 
    before delete ON OLIVER.DEMO_CUSTOMERS
    for each row
begin
    sample_pkg.demo_tag_sync(
        p_new_tags      => null,
        p_old_tags      => :old.tags,
        p_content_type  => 'CUSTOMER',
        p_content_id    => :old.customer_id );
end;
/


