--
-- AOP_PLSQL3_PKG  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.aop_plsql3_pkg
AUTHID CURRENT_USER
as
/* Copyright 2015-2018 - APEX RnD
*/
-- AOP Version
c_aop_version  constant varchar2(5)   := '3.4';
--
-- Pre-requisites: apex_web_service package
-- if APEX is not installed, you can use this package as your starting point
-- but you would need to change the apex_web_service calls by utl_http calls or similar
--
--
-- Change following variables for your environment
--
g_aop_url  varchar2(200) := 'http://www.apexofficeprint.com/api/'; -- for https use https://www.apexrnd.be/aop
g_api_key  varchar2(200) := '1C511A58ECC73874E0530100007FD01A';
-- Global variables
-- Call to AOP
g_proxy_override          varchar2(300) := null;  -- null=proxy defined in the application attributes
g_transfer_timeout        number(6)     := 180;   -- default is 180
g_wallet_path             varchar2(300) := null;  -- null=defined in Manage Instance > Instance Settings
g_wallet_pwd              varchar2(300) := null;  -- null=defined in Manage Instance > Instance Settings
-- Constants
c_mime_type_docx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
c_mime_type_xlsx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
c_mime_type_pptx        varchar2(100) := 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
c_mime_type_pdf         varchar2(100) := 'application/pdf';
function make_aop_request(
  p_aop_url          in varchar2 default g_aop_url,
  p_api_key          in varchar2 default g_api_key,
  p_json             in clob,
  p_template         in blob,
  p_output_encoding  in varchar2 default 'raw', -- change to raw to have binary, change to base64 to have base64 encoded
  p_output_type      in varchar2 default null,
  p_output_filename  in varchar2 default 'output',
  p_aop_remote_debug in varchar2 default 'No')
  return blob;
end aop_plsql3_pkg;

/

