--
-- SYS_EXPORT_SCHEMA_01  (Table) 
--
CREATE TABLE OLIVER.SYS_EXPORT_SCHEMA_01
(
  ABORT_STEP               NUMBER,
  ANCESTOR_PROCESS_ORDER   NUMBER,
  BASE_OBJECT_NAME         VARCHAR2(30 BYTE),
  BASE_OBJECT_SCHEMA       VARCHAR2(30 BYTE),
  BASE_OBJECT_TYPE         VARCHAR2(30 BYTE),
  BASE_PROCESS_ORDER       NUMBER,
  BLOCK_SIZE               NUMBER,
  CLUSTER_OK               NUMBER,
  COMPLETED_BYTES          NUMBER,
  COMPLETED_ROWS           NUMBER,
  COMPLETION_TIME          DATE,
  CONTROL_QUEUE            VARCHAR2(30 BYTE),
  CREATION_LEVEL           NUMBER,
  CUMULATIVE_TIME          NUMBER,
  DATA_BUFFER_SIZE         NUMBER,
  DATA_IO                  NUMBER,
  DATAOBJ_NUM              NUMBER,
  DB_VERSION               VARCHAR2(60 BYTE),
  DEGREE                   NUMBER,
  DOMAIN_PROCESS_ORDER     NUMBER,
  DUMP_ALLOCATION          NUMBER,
  DUMP_FILEID              NUMBER,
  DUMP_LENGTH              NUMBER,
  DUMP_ORIG_LENGTH         NUMBER,
  DUMP_POSITION            NUMBER,
  DUPLICATE                NUMBER,
  ELAPSED_TIME             NUMBER,
  ERROR_COUNT              NUMBER,
  EXTEND_SIZE              NUMBER,
  FILE_MAX_SIZE            NUMBER,
  FILE_NAME                VARCHAR2(4000 BYTE),
  FILE_TYPE                NUMBER,
  FLAGS                    NUMBER,
  GRANTOR                  VARCHAR2(30 BYTE),
  GRANULES                 NUMBER,
  GUID                     RAW(16),
  IN_PROGRESS              CHAR(1 BYTE),
  INSTANCE                 VARCHAR2(60 BYTE),
  INSTANCE_ID              NUMBER,
  IS_DEFAULT               NUMBER,
  JOB_MODE                 VARCHAR2(21 BYTE),
  JOB_VERSION              VARCHAR2(60 BYTE),
  LAST_FILE                NUMBER,
  LAST_UPDATE              DATE,
  LOAD_METHOD              NUMBER,
  METADATA_BUFFER_SIZE     NUMBER,
  METADATA_IO              NUMBER,
  NAME                     VARCHAR2(30 BYTE),
  OBJECT_INT_OID           VARCHAR2(32 BYTE),
  OBJECT_LONG_NAME         VARCHAR2(4000 BYTE),
  OBJECT_NAME              VARCHAR2(200 BYTE),
  OBJECT_NUMBER            NUMBER,
  OBJECT_PATH_SEQNO        NUMBER,
  OBJECT_ROW               NUMBER,
  OBJECT_SCHEMA            VARCHAR2(30 BYTE),
  OBJECT_TABLESPACE        VARCHAR2(30 BYTE),
  OBJECT_TYPE              VARCHAR2(30 BYTE),
  OBJECT_TYPE_PATH         VARCHAR2(200 BYTE),
  OLD_VALUE                VARCHAR2(4000 BYTE),
  OPERATION                VARCHAR2(8 BYTE),
  OPTION_TAG               VARCHAR2(30 BYTE),
  ORIG_BASE_OBJECT_SCHEMA  VARCHAR2(30 BYTE),
  ORIGINAL_OBJECT_NAME     VARCHAR2(128 BYTE),
  ORIGINAL_OBJECT_SCHEMA   VARCHAR2(30 BYTE),
  PACKET_NUMBER            NUMBER,
  PARALLELIZATION          NUMBER,
  PARENT_PROCESS_ORDER     NUMBER,
  PARTITION_NAME           VARCHAR2(30 BYTE),
  PHASE                    NUMBER,
  PLATFORM                 VARCHAR2(101 BYTE),
  PROCESS_NAME             VARCHAR2(30 BYTE),
  PROCESS_ORDER            NUMBER,
  PROCESSING_STATE         CHAR(1 BYTE),
  PROCESSING_STATUS        CHAR(1 BYTE),
  PROPERTY                 NUMBER,
  QUEUE_TABNUM             NUMBER,
  REMOTE_LINK              VARCHAR2(128 BYTE),
  SCN                      NUMBER,
  SEED                     NUMBER,
  SERVICE_NAME             VARCHAR2(64 BYTE),
  SIZE_ESTIMATE            NUMBER,
  START_TIME               DATE,
  STATE                    VARCHAR2(12 BYTE),
  STATUS_QUEUE             VARCHAR2(30 BYTE),
  SUBPARTITION_NAME        VARCHAR2(30 BYTE),
  TARGET_XML_CLOB          CLOB,
  TDE_REWRAPPED_KEY        RAW(2000),
  TEMPLATE_TABLE           VARCHAR2(30 BYTE),
  TIMEZONE                 VARCHAR2(64 BYTE),
  TOTAL_BYTES              NUMBER,
  TRIGFLAG                 NUMBER,
  UNLOAD_METHOD            NUMBER,
  USER_DIRECTORY           VARCHAR2(4000 BYTE),
  USER_FILE_NAME           VARCHAR2(4000 BYTE),
  USER_NAME                VARCHAR2(30 BYTE),
  VALUE_N                  NUMBER,
  VALUE_T                  VARCHAR2(4000 BYTE),
  VERSION                  NUMBER,
  WORK_ITEM                VARCHAR2(21 BYTE),
  XML_CLOB                 CLOB
)
TABLESPACE CDATV5DATAFILE
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   10
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOCOMPRESS ;

COMMENT ON TABLE OLIVER.SYS_EXPORT_SCHEMA_01 IS 'Data Pump Master Table EXPORT                         SCHEMA                        ';



