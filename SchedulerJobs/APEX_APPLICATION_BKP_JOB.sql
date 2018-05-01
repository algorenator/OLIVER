--
-- APEX_APPLICATION_BKP_JOB  (Scheduler Job) 
--
BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'OLIVER.APEX_APPLICATION_BKP_JOB'
      ,start_date      => TO_TIMESTAMP_TZ('0017/08/25 03:12:00.000000 America/Vancouver','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=DAILY;INTERVAL=1'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'OLIVER.UTILS_PKG.APEX_BACKUP_JOB'
      ,comments        => 'results on table cdatv5.apex_application_backup'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'OLIVER.APEX_APPLICATION_BKP_JOB'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'OLIVER.APEX_APPLICATION_BKP_JOB'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'OLIVER.APEX_APPLICATION_BKP_JOB'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'OLIVER.APEX_APPLICATION_BKP_JOB'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'OLIVER.APEX_APPLICATION_BKP_JOB'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'OLIVER.APEX_APPLICATION_BKP_JOB'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'OLIVER.APEX_APPLICATION_BKP_JOB'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'OLIVER.APEX_APPLICATION_BKP_JOB'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'OLIVER.APEX_APPLICATION_BKP_JOB');
END;
/

