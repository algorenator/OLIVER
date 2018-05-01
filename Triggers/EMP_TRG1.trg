--
-- EMP_TRG1  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.EMP_TRG1 
              before insert ON OLIVER.EMP
              for each row
begin
                  if :new.empno is null then
                      select emp_seq.nextval into :new.empno from sys.dual;
                 end if;
              end;
/


