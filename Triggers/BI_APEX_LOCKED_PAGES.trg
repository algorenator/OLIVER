--
-- BI_APEX_LOCKED_PAGES  (Trigger) 
--
CREATE OR REPLACE TRIGGER OLIVER.BI_APEX_LOCKED_PAGES
BEFORE INSERT
   ON OLIVER.APEX_LOCKED_PAGES
   FOR EACH ROW
DISABLE
DECLARE
  l_clob clob;
  v_story varchar2(10);
     j apex_json.t_values; 
    v apex_json.t_value;

  APP_WALLET_PATH   varchar2(200):='file:c:\ords\https_wallet2';
  APP_CH_TOKEN   varchar2(200):='5ab530a3-c207-41c6-bb7e-685202103287';

BEGIN
 

v_story:=LTRIM(REGEXP_SUBSTR( :new.LOCK_COMMENT, '#[[:digit:]]{1,}'),'#');

 if  v_story is not null then
                  
            --Sending to ClubHouse
            apex_web_service.g_request_headers.delete;
            apex_web_service.g_request_headers (1).name := 'Content-Type';
            apex_web_service.g_request_headers (1).VALUE := 'application/json';
            l_clob :=
               apex_web_service.make_rest_request (
                  p_url           =>    'https://api.clubhouse.io/api/v2/stories/'
                                     || v_story
                                     || '/comments?token='
                                     || APP_CH_TOKEN,
                  p_body          =>    '{ "text": "Application  '||:new.APP_ID                                     
                                     || '\n'
                                     || 'Page ' || TO_CHAR (:new.PAGE_ID)
                                     || '\n'                                     
                                     || 'https://devweb.ollieapp.co/ords/f?p='||:new.APP_ID||':'||:new.PAGE_ID
                                     || '\n\n'
                                     || ' has been updated to implement this story '
                                     || '\n\n'
                                     ||'Changed by '||:new.LOCKED_BY||' on '||to_char(:new.LOCKED_ON,'dd-mon-yyyy hh24:mi')||'\n\n'
                                     || :new.LOCK_COMMENT
                                     || ' "}',
                  p_http_method   => 'POST',
                  p_wallet_path   => APP_WALLET_PATH);
                  
    l_clob:=apex_web_service.make_rest_request(
                p_url         => 'https://api.clubhouse.io/api/v2/stories/'||v_story||'?token='|| APP_CH_TOKEN,
                p_http_method => 'GET',
                p_wallet_path => APP_WALLET_PATH ) ;
    
    apex_json.parse(j, l_clob);          
     :new.LOCK_COMMENT:=
     apex_json.get_varchar2(p_path=>'name',p_values=>j)
     ||' / '--||chr(10)
     ||:new.LOCK_COMMENT;
                         
                                                
           
 end if; 

  
 
END;
/


