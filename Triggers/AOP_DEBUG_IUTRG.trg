--
-- AOP_DEBUG_IUTRG  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AOP_DEBUG_IUTRG 
before insert ON OLIVER.AOP_DEBUG
for each row
begin  
   if :new.id is null 
   then 
     :new.id := to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');  
   end if; 
end;
/


