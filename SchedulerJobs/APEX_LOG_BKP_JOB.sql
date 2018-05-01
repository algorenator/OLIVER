--
-- APEX_LOG_BKP_JOB  (Scheduler Job) 
--
BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'OLIVER.APEX_LOG_BKP_JOB'
      ,start_date      => TO_TIMESTAMP_TZ('0018/02/25 04:00:00.000000 America/Vancouver','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=DAILY;INTERVAL=1'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'OLIVER.audit_utils.populate_apex_log'
      ,comments        => 'populate audit_apex_access_log and audit_apex_activity_log  from apex system log views'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'OLIVER.APEX_LOG_BKP_JOB'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'OLIVER.APEX_LOG_BKP_JOB'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'OLIVER.APEX_LOG_BKP_JOB'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'OLIVER.APEX_LOG_BKP_JOB'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'OLIVER.APEX_LOG_BKP_JOB'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'OLIVER.APEX_LOG_BKP_JOB'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'OLIVER.APEX_LOG_BKP_JOB'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'OLIVER.APEX_LOG_BKP_JOB'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'OLIVER.APEX_LOG_BKP_JOB');
END;
/

