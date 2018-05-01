--
-- AOP_TEMPLATE_IUTRG  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.AOP_TEMPLATE_IUTRG 
  before insert ON OLIVER.AOP_TEMPLATE FOR EACH ROW
BEGIN
  if :new.id is null 
  then 
     :new.id := to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');  
  end if;     
END;
/


