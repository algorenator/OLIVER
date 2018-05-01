--
-- IS_SIN_VALID  (Function) 
--
CREATE OR REPLACE FUNCTION OLIVER.IS_SIN_VALID(SIN INT) RETURN VARCHAR2 IS

lv_sin_final_tot number(2);
lv_sin_tot number (3);
begin
if length(NVL(sin,0))<>9 then 
return 'N';
else
  lv_sin_tot := SUBSTR (SIN, 1,1) * 1
           + SUBSTR (SIN, 2,1) * 2
           + SUBSTR (SIN, 3,1) * 1
           + SUBSTR (SIN, 4,1) * 2
           + SUBSTR (SIN, 5,1) * 1
           + SUBSTR (SIN, 6,1) * 2
           + SUBSTR (SIN, 7,1) * 1
           + SUBSTR (SIN, 8,1) * 2;
if substr (SIN, 2,1) * 2 > 9 then
   lv_sin_tot := lv_sin_tot + 1;
end if; 
if substr (SIN, 4,1) * 2 > 9 then
   lv_sin_tot := lv_sin_tot + 1;
end if; 
if substr (SIN, 6,1) * 2 > 9 then
   lv_sin_tot := lv_sin_tot + 1;
end if; 
if substr (SIN, 8,1) * 2 > 9 then
   lv_sin_tot := lv_sin_tot + 1;
end if; 
lv_sin_final_tot := substr(lv_sin_tot, 2,1);
--:global.lv_sintot := lv_sin_tot;
--:global.lv_sinfinaltot := lv_sin_final_tot;
  IF lv_sin_final_tot = 0 THEN
     lv_sin_final_tot := 10;
  END IF;
     if   10 - lv_sin_final_tot <> substr (SIN, 9,1) THEN
		RETURN 'N';
     ELSE
		RETURN 'Y';
     END IF;
end if;
END IS_SIN_VALID;
/

