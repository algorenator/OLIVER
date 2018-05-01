--
-- BIU_EBA_DEMO_CHART_ORDERS  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.BIU_EBA_DEMO_CHART_ORDERS 
   before insert or update ON OLIVER.EBA_DEMO_CHART_ORDERS
   for each row
begin  
   if :new."ORDER_ID" is null then
     select to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') into :new.order_id from dual;
   end if;
   if inserting then
       :new.created := localtimestamp;
       :new.created_by := nvl(wwv_flow.g_user,user);
       :new.updated := localtimestamp;
       :new.updated_by := nvl(wwv_flow.g_user,user);
   end if;
   if inserting or updating then
       :new.updated := localtimestamp;
       :new.updated_by := nvl(wwv_flow.g_user,user);
   end if;
end;
/


