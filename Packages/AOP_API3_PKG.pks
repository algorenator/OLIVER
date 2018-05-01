--
-- AOP_API3_PKG  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.aop_api3_pkg
AUTHID CURRENT_USER
as
/* Copyright 2015-2018 - APEX RnD
*/
-- AOP Version
c_aop_version             constant varchar2(5) := '3.4';
c_aop_url                 constant varchar2(50) := 'http://www.apexofficeprint.com/api/'; -- for https use https://www.apexrnd.be/aop
-- Logger
g_logger_enabled          constant boolean := false;  -- set to true to write extra debug output to logger - see https://github.com/OraOpenSource/Logger
-- Global variables
-- Call to AOP
g_proxy_override          varchar2(300) := null;  -- null=proxy defined in the application attributes
g_https_host              varchar2(300) := null;  -- parameter for utl_http and apex_web_service
g_transfer_timeout        number(6)     := 1800;  -- default of APEX is 180
g_wallet_path             varchar2(300) := null;  -- null=defined in Manage Instance > Instance Settings
g_wallet_pwd              varchar2(300) := null;  -- null=defined in Manage Instance > Instance Settings
g_output_filename         varchar2(100) := null;  -- output
g_language                varchar2(2)   := 'en';  -- Language can be: en, fr, nl, de
g_logging                 clob          := '';    -- ability to add your own logging: e.g. "request_id":"123", "request_app":"APEX", "request_user":"RND"
g_debug                   varchar2(10)  := null;  -- set to 'Local' when only the JSON needs to be generated, 'Remote' for remore debug
g_debug_procedure         varchar2(4000):= null;  -- when debug in APEX is turned on, next to the normal APEX debug, this procedure will be called
                                                  -- e.g. to write to your own debug table. The definition of the procedure needs to be the same as aop_debug
-- AOP settings for Interactive Report (see also Printing attributes in IR)
g_rpt_header_font_name    varchar2(50)  := '';    -- Arial - see https://www.microsoft.com/typography/Fonts/product.aspx?PID=163
g_rpt_header_font_size    varchar2(3)   := '';    -- 14
g_rpt_header_font_color   varchar2(50)  := '';    -- #071626
g_rpt_header_back_color   varchar2(50)  := '';    -- #FAFAFA
g_rpt_header_border_width varchar2(50)  := '';    -- 1 ; '0' = no border
g_rpt_header_border_color varchar2(50)  := '';    -- #000000
g_rpt_data_font_name      varchar2(50)  := '';    -- Arial - see https://www.microsoft.com/typography/Fonts/product.aspx?PID=163
g_rpt_data_font_size      varchar2(3)   := '';    -- 14
g_rpt_data_font_color     varchar2(50)  := '';    -- #000000
g_rpt_data_back_color     varchar2(50)  := '';    -- #FFFFFF
g_rpt_data_border_width   varchar2(50)  := '';    -- 1 ; '0' = no border
g_rpt_data_border_color   varchar2(50)  := '';    -- #000000
g_rpt_data_alt_row_color  varchar2(50)  := '';    -- #FFFFFF for no alt row color, use same color as g_rpt_data_back_color
-- HTML template to Word/PDF
g_orientation             varchar2(50)  := '';    -- empty is portrait, other option is 'landscape'
-- Call to URL data source
g_url_username            varchar2(300) := null;
g_url_password            varchar2(300) := null;
g_url_proxy_override      varchar2(300) := null;
g_url_transfer_timeout    number        := 180;
g_url_body                clob          := empty_clob();
g_url_body_blob           blob          := empty_blob();
g_url_parm_name           apex_application_global.vc_arr2; --:= empty_vc_arr;
g_url_parm_value          apex_application_global.vc_arr2; --:= empty_vc_arr;
g_url_wallet_path         varchar2(300) := null;
g_url_wallet_pwd          varchar2(300) := null;
g_url_https_host          varchar2(300) := null;  -- parameter for utl_http and apex_web_service
-- IP Printer support
g_ip_printer_location     varchar2(300) := null;
g_ip_printer_version      varchar2(300) := '1';
g_ip_printer_requester    varchar2(300) := nvl(apex_application.g_user, USER);
g_ip_printer_job_name     varchar2(300) := 'AOP';
-- Convert characterset
g_convert                 varchar2(1)  := 'N';        -- set to Y if you want to convert the JSON that is send over; necessary for Arabic support
g_convert_source_charset  varchar2(20) := null;       -- default of database 
g_convert_target_charset  varchar2(20) := 'AL32UTF8';  
-- Output
g_output_directory        varchar2(200) := '.';       -- set output directory on AOP Server
                                                      -- if . is specified the files are saved in the default directory: outputfiles
-- Constants
c_source_type_apex        constant varchar2(4) := 'APEX';
c_source_type_workspace   constant varchar2(9) := 'WORKSPACE';
c_source_type_sql         constant varchar2(3) := 'SQL';
c_source_type_plsql       constant varchar2(5) := 'PLSQL';
c_source_type_plsql_sql   constant varchar2(9) := 'PLSQL_SQL';
c_source_type_filename    constant varchar2(8) := 'FILENAME';
c_source_type_url         constant varchar2(3) := 'URL';
c_source_type_rpt         constant varchar2(6) := 'IR';
c_mime_type_docx          constant varchar2(100) := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
c_mime_type_xlsx          constant varchar2(100) := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
c_mime_type_pptx          constant varchar2(100) := 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
c_mime_type_pdf           constant varchar2(100) := 'application/pdf';
c_mime_type_html          constant varchar2(100) := 'text/html';
c_mime_type_markdown      constant varchar2(100) := 'text/markdown';
c_mime_type_rtf           constant varchar2(100) := 'application/rtf';
c_mime_type_json          constant varchar2(100) := 'application/json';
c_mime_type_text          constant varchar2(100) := 'text/plain';
c_output_encoding_raw     constant varchar2(3) := 'raw';
c_output_encoding_base64  constant varchar2(6) := 'base64';
-- Types
--type t_bind_record is record(name varchar2(100), value varchar2(32767));
--type t_bind_table  is table of t_bind_record index by pls_integer;
c_binds wwv_flow_plugin_util.t_bind_list;
-- Useful functions
-- debug function, will write to apex_debug_messages, logger (if enabled) and your own debug procedure
procedure aop_debug(p_message     in varchar2, 
                    p0            in varchar2 default null, 
                    p1            in varchar2 default null, 
                    p2            in varchar2 default null, 
                    p3            in varchar2 default null, 
                    p4            in varchar2 default null, 
                    p5            in varchar2 default null, 
                    p6            in varchar2 default null, 
                    p7            in varchar2 default null, 
                    p8            in varchar2 default null, 
                    p9            in varchar2 default null, 
                    p10           in varchar2 default null, 
                    p11           in varchar2 default null, 
                    p12           in varchar2 default null, 
                    p13           in varchar2 default null, 
                    p14           in varchar2 default null, 
                    p15           in varchar2 default null, 
                    p16           in varchar2 default null, 
                    p17           in varchar2 default null, 
                    p18           in varchar2 default null, 
                    p19           in varchar2 default null, 
                    p_level       in apex_debug.t_log_level default apex_debug.c_log_level_info, 
                    p_description in clob default null);
-- convert a url with for example an image to base64
function url2base64 (
  p_url in varchar2)
  return clob;
-- get the value of one of the above constants
function getconstantvalue (
  p_constant in varchar2)
  return varchar2 deterministic;
-- get the mime type of a file extention: docx, xlsx, pptx, pdf
function getmimetype (
  p_file_ext in varchar2)
  return varchar2 deterministic;
-- get the file extention of a mime type
function getfileextension (
  p_mime_type in varchar2)
  return varchar2 deterministic;  
-- convert a blob to a clob
function blob2clob(p_blob in blob)
  return clob;
-- Manual call to AOP
-- p_aop_remote_debug: Yes (=Remote) / No / Local
-- p_special options: NUMBER_TO_STRING, ALWAYS_REPORT_ALIAS, FILTERS_ON_TOP, HIGHLIGHTS_ON_TOP, HEADER_WITH_FILTER
-- usage: p_special => 'ALWAYS_REPORT_ALIAS' or multiple p_special => 'FILTERS_ON_TOP:HIGHLIGHTS_ON_TOP'
function plsql_call_to_aop(
  p_data_type             in varchar2 default c_source_type_sql,
  p_data_source           in clob,
  p_template_type         in varchar2 default c_source_type_apex,
  p_template_source       in clob,
  p_output_type           in varchar2,
  p_output_filename       in out nocopy varchar2,
  p_output_type_item_name in varchar2 default null,
  p_output_to             in varchar2 default null,
  p_procedure             in varchar2 default null,
  p_binds                 in wwv_flow_plugin_util.t_bind_list default c_binds,
  p_special               in varchar2 default null,
  p_aop_remote_debug      in varchar2 default 'No',
  p_output_converter      in varchar2 default null,
  p_aop_url               in varchar2,
  p_api_key               in varchar2,
  p_app_id                in number default null,
  p_page_id               in number default null,
  p_user_name             in varchar2 default null,
  p_init_code             in clob default 'null;',
  p_output_encoding       in varchar2 default c_output_encoding_raw,
  p_failover_aop_url      in varchar2 default null,
  p_failover_procedure    in varchar2 default null)
  return blob;
-- APEX Plugins
-- Process Type Plugin
function f_process_aop(
  p_process in apex_plugin.t_process,
  p_plugin  in apex_plugin.t_plugin)
  return apex_plugin.t_process_exec_result;
-- Dynamic Action Plugin
function f_render_aop (
  p_dynamic_action in apex_plugin.t_dynamic_action,
  p_plugin         in apex_plugin.t_plugin)
  return apex_plugin.t_dynamic_action_render_result;
function f_ajax_aop(
  p_dynamic_action in apex_plugin.t_dynamic_action,
  p_plugin         in apex_plugin.t_plugin)
  return apex_plugin.t_dynamic_action_ajax_result;
-- Other Procedure
-- Create an APEX session from PL/SQL
-- p_enable_debug: Yes / No (default)
procedure create_apex_session(
  p_app_id       in apex_applications.application_id%type,
  p_user_name    in apex_workspace_sessions.user_name%type default 'ADMIN',
  p_page_id      in apex_application_pages.page_id%type default null,
  p_session_id   in apex_workspace_sessions.apex_session_id%type default null,
  p_enable_debug in varchar2 default 'No');
-- Get the current APEX Session
function get_apex_session
  return apex_workspace_sessions.apex_session_id%type;
-- Join an APEX Session
procedure join_apex_session(
  p_session_id   in apex_workspace_sessions.apex_session_id%type,
  p_app_id       in apex_applications.application_id%type default null,
  p_enable_debug in varchar2 default 'No');
-- Drop the current APEX Session
procedure drop_apex_session(
  p_app_id     in apex_applications.application_id%type);
end aop_api3_pkg;

/

