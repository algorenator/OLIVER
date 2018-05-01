--
-- DEMO_ORDERS_BD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.DEMO_ORDERS_BD 
    before delete ON OLIVER.DEMO_ORDERS
    for each row
begin
    sample_pkg.demo_tag_sync(
        p_new_tags      => null,
        p_old_tags      => :old.tags,
        p_content_type  => 'ORDER',
        p_content_id    => :old.order_id );
end;
/


