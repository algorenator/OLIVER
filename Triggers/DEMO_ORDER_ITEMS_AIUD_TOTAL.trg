--
-- DEMO_ORDER_ITEMS_AIUD_TOTAL  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.DEMO_ORDER_ITEMS_AIUD_TOTAL 
  after insert or update or delete ON OLIVER.DEMO_ORDER_ITEMS
begin
  -- Update the Order Total when any order item is changed
  update demo_orders set order_total =
  (select sum(unit_price*quantity) from demo_order_items
    where demo_order_items.order_id = demo_orders.order_id);
end;
/


