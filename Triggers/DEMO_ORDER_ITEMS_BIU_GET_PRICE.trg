--
-- DEMO_ORDER_ITEMS_BIU_GET_PRICE  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.DEMO_ORDER_ITEMS_BIU_GET_PRICE 
  before insert or update ON OLIVER.DEMO_ORDER_ITEMS for each row
declare
  l_list_price number;
begin
  if :new.unit_price is null then
    -- First, we need to get the current list price of the order line item
    select list_price
    into l_list_price
    from demo_product_info
    where product_id = :new.product_id;
    -- Once we have the correct price, we will update the order line with the correct price
    :new.unit_price := l_list_price;
  end if;
end;
/


