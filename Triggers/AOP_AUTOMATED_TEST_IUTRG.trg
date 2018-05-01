--
-- AOP_AUTOMATED_TEST_IUTRG  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AOP_AUTOMATED_TEST_IUTRG 
before insert ON OLIVER.AOP_AUTOMATED_TEST
 for each row
begin  
   if :new.id is null 
   then 
     :new.id := to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');  
   end if; 
end;
/


