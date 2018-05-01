--
-- DEMO_ORDER_ITEMS_BI  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.DEMO_ORDER_ITEMS_BI 
  BEFORE insert ON OLIVER.DEMO_ORDER_ITEMS for each row
declare
  order_item_id number;
begin
  if :new.order_item_id is null then
    select demo_order_items_seq.nextval 
      into order_item_id 
      from dual;
    :new.order_item_id := order_item_id;
  end if;
end;
/


