--
-- AOP_OUTPUT_IUTRG  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AOP_OUTPUT_IUTRG 
before insert ON OLIVER.AOP_OUTPUT
for each row
begin  
   if :new.id is null 
   then 
     :new.id := to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');  
   end if; 
end;
/


