--
-- DEMO_PRODUCT_INFO_BD  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.DEMO_PRODUCT_INFO_BD 
    before delete ON OLIVER.DEMO_PRODUCT_INFO
    for each row
begin
    sample_pkg.demo_tag_sync(
        p_new_tags      => null,
        p_old_tags      => :old.tags,
        p_content_type  => 'PRODUCT',
        p_content_id    => :old.product_id );
end;
/


