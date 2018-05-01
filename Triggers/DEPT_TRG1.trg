--
-- DEPT_TRG1  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.DEPT_TRG1 
              before insert ON OLIVER.DEPT
              for each row
begin
                  if :new.deptno is null then
                      select dept_seq.nextval into :new.deptno from sys.dual;
                 end if;
              end;
/


