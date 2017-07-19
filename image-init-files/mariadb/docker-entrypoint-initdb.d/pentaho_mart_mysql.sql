--
-- MySQL DDL for creating a Pentaho Logging datamart
--
-- ------------------------------------------------------

--
-- Create schema pentaho_operations_mart
--

CREATE DATABASE IF NOT EXISTS pentaho_operations_mart;
grant all on pentaho_operations_mart.* to 'pentaho_user'@'%';

USE pentaho_operations_mart;

--
-- Definition of table pentaho_operations_mart.dim_batch
--

CREATE TABLE  pentaho_operations_mart.dim_batch (
  batch_tk bigint(20) NOT NULL,
  batch_id bigint(20) DEFAULT NULL,
  logchannel_id varchar(100) DEFAULT NULL,
  parent_logchannel_id varchar(100) DEFAULT NULL,
  PRIMARY KEY (batch_tk),
  KEY IDX_dim_batch_BATCH_TK (batch_tk),
  KEY IDX_dim_batch_LOOKUP (batch_id,logchannel_id,parent_logchannel_id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Definition of table pentaho_operations_mart.dim_date
--

CREATE TABLE  pentaho_operations_mart.dim_date (
  date_tk int(11) NOT NULL,
  date_field datetime DEFAULT NULL,
  ymd varchar(10) DEFAULT NULL,
  ym varchar(7) DEFAULT NULL,
  year int(11) DEFAULT NULL,
  quarter int(11) DEFAULT NULL,
  quarter_code varchar(2) DEFAULT NULL,
  month int(11) DEFAULT NULL,
  month_desc varchar(20) DEFAULT NULL,
  month_code varchar(15) DEFAULT NULL,
  day int(11) DEFAULT NULL,
  day_of_year int(11) DEFAULT NULL,
  day_of_week int(11) DEFAULT NULL,
  day_of_week_desc varchar(20) DEFAULT NULL,
  day_of_week_code varchar(15) DEFAULT NULL,
  week int(11) DEFAULT NULL,
  PRIMARY KEY (date_tk)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Definition of table pentaho_operations_mart.dim_execution
--

CREATE TABLE  pentaho_operations_mart.dim_execution (
  execution_tk bigint(20) NOT NULL,
  execution_id varchar(100) DEFAULT NULL,
  server_host varchar(100) DEFAULT NULL,
  executing_user varchar(100) DEFAULT NULL,
  execution_status varchar(30) DEFAULT NULL,
  client varchar(255) DEFAULT NULL,
  PRIMARY KEY (execution_tk),
  KEY IDX_dim_execution_EXECUTION_TK (execution_tk),
  KEY IDX_dim_execution_LOOKUP (execution_id,server_host,executing_user,client)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Definition of table pentaho_operations_mart.dim_executor
--

CREATE TABLE  pentaho_operations_mart.dim_executor (
  executor_tk bigint(20) NOT NULL,
  version int(11) DEFAULT NULL,
  date_from datetime DEFAULT NULL,
  date_to datetime DEFAULT NULL,
  executor_id varchar(255) DEFAULT NULL,
  executor_source varchar(255) DEFAULT NULL,
  executor_environment varchar(255) DEFAULT NULL,
  executor_type varchar(255) DEFAULT NULL,
  executor_name varchar(255) DEFAULT NULL,
  executor_desc varchar(255) DEFAULT NULL,
  executor_revision varchar(255) DEFAULT NULL,
  executor_version_label varchar(255) DEFAULT NULL,
  exec_enabled_table_logging char(1) DEFAULT NULL,
  exec_enabled_detailed_logging char(1) DEFAULT NULL,
  exec_enabled_perf_logging char(1) DEFAULT NULL,
  exec_enabled_history_logging char(1) DEFAULT NULL,
  last_updated_date datetime DEFAULT NULL,
  last_updated_user varchar(255) DEFAULT NULL,
  PRIMARY KEY (executor_tk),
  KEY IDX_dim_executor_EXCUTOR_TK (executor_tk),
  KEY IDX_dim_executor_LOOKUP (executor_id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Definition of table pentaho_operations_mart.dim_time
--

CREATE TABLE  pentaho_operations_mart.dim_time (
  time_tk int(11) NOT NULL,
  hms varchar(8) DEFAULT NULL,
  hm varchar(5) DEFAULT NULL,
  ampm varchar(8) DEFAULT NULL,
  hour int(11) DEFAULT NULL,
  hour12 int(11) DEFAULT NULL,
  minute int(11) DEFAULT NULL,
  second int(11) DEFAULT NULL,
  PRIMARY KEY (time_tk)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Definition of table pentaho_operations_mart.dim_log_table
--

CREATE TABLE  pentaho_operations_mart.dim_log_table (
  log_table_tk bigint(20) NOT NULL,
  object_type varchar(30) DEFAULT NULL,
  table_connection_name varchar(255) DEFAULT NULL,
  table_name varchar(255) DEFAULT NULL,
  schema_name varchar(255) DEFAULT NULL,
  step_entry_table_conn_name varchar(255) DEFAULT NULL,
  step_entry_table_name varchar(255) DEFAULT NULL,
  step_entry_schema_name varchar(255) DEFAULT NULL,
  perf_table_conn_name varchar(255) DEFAULT NULL,
  perf_table_name varchar(255) DEFAULT NULL,
  perf_schema_name varchar(255) DEFAULT NULL,
  PRIMARY KEY (log_table_tk),
  UNIQUE KEY idx_dim_log_table_pk (log_table_tk),
  KEY idx_dim_log_table_lookup (object_type, table_connection_name, table_name, schema_name),
  KEY idx_dim_log_step_entry_table_lookup (object_type, step_entry_table_conn_name, step_entry_table_name, step_entry_schema_name),
  KEY idx_dim_log_perf_table_lookup (object_type, perf_table_conn_name, perf_table_name, perf_schema_name)
  ) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Definition of table pentaho_operations_mart.dim_log_table
--

CREATE TABLE  pentaho_operations_mart.dim_step (
  step_tk bigint(20) NOT NULL,
  step_id varchar(255) DEFAULT NULL,
  original_step_name varchar(255) DEFAULT NULL,
  PRIMARY KEY (step_tk),
  UNIQUE KEY idx_dim_step_pk (step_tk),
  KEY idx_dim_step_lookup (step_id)
  ) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Definition of table pentaho_operations_mart.fact_execution
--

CREATE TABLE  pentaho_operations_mart.fact_execution (
  execution_date_tk int(11) DEFAULT NULL,
  execution_time_tk int(11) DEFAULT NULL,
  batch_tk int(11) DEFAULT NULL,
  execution_tk int(11) DEFAULT NULL,
  executor_tk int(11) DEFAULT NULL,
  parent_executor_tk int(11) DEFAULT NULL,
  root_executor_tk int(11) DEFAULT NULL,
  execution_timestamp DATETIME DEFAULT NULL,
  duration double DEFAULT NULL,
  rows_input int(11) DEFAULT NULL,
  rows_output int(11) DEFAULT NULL,
  rows_read int(11) DEFAULT NULL,
  rows_written int(11) DEFAULT NULL,
  rows_rejected int(11) DEFAULT NULL,
  errors int(11) DEFAULT NULL,
  failed int(1) DEFAULT NULL,
  KEY IDX_fact_execution_EXECUTION_DATE_TK (execution_date_tk),
  KEY IDX_fact_execution_EXECUTION_TIME_TK (execution_time_tk),
  KEY IDX_fact_execution_BATCH_TK (batch_tk),
  KEY IDX_fact_execution_EXECUTION_TK (execution_tk),
  KEY IDX_fact_execution_EXECUTOR_TK (executor_tk),
  KEY IDX_fact_execution_PARENT_EXECUTOR_TK (parent_executor_tk),
  KEY IDX_fact_execution_ROOT_EXECUTOR_TK (root_executor_tk)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Definition of table pentaho_operations_mart.FACT_STEP_EXECUTION
--

CREATE TABLE  pentaho_operations_mart.fact_step_execution (
  execution_date_tk int(11) DEFAULT NULL,
  execution_time_tk int(11) DEFAULT NULL,
  batch_tk int(11) DEFAULT NULL,
  executor_tk int(11) DEFAULT NULL,
  parent_executor_tk int(11) DEFAULT NULL,
  root_executor_tk int(11) DEFAULT NULL,
  step_tk int(11) DEFAULT NULL,
  step_copy int(11) DEFAULT NULL,
  execution_timestamp DATETIME DEFAULT NULL,
  rows_input int(11) DEFAULT NULL,
  rows_output int(11) DEFAULT NULL,
  rows_read int(11) DEFAULT NULL,
  rows_written int(11) DEFAULT NULL,
  rows_rejected int(11) DEFAULT NULL,
  errors int(11) DEFAULT NULL
);
CREATE INDEX IDX_FACT_STEP_EXECUTION_EXECUTION_DATE_TK ON pentaho_operations_mart.fact_step_execution(execution_date_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_EXECUTION_TIME_TK ON pentaho_operations_mart.fact_step_execution(execution_time_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_BATCH_TK ON pentaho_operations_mart.fact_step_execution(batch_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_EXECUTOR_TK ON pentaho_operations_mart.fact_step_execution(executor_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_PARENT_EXECUTOR_TK ON pentaho_operations_mart.fact_step_execution(parent_executor_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_ROOT_EXECUTOR_TK ON pentaho_operations_mart.fact_step_execution(root_executor_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_STEP_TK ON pentaho_operations_mart.fact_step_execution(step_tk);

--
-- Definition of table pentaho_operations_mart.FACT_JOBENTRY_EXECUTION
--

CREATE TABLE  pentaho_operations_mart.fact_jobentry_execution (
  execution_date_tk int(11) DEFAULT NULL,
  execution_time_tk int(11) DEFAULT NULL,
  batch_tk int(11) DEFAULT NULL,
  executor_tk int(11) DEFAULT NULL,
  parent_executor_tk int(11) DEFAULT NULL,
  root_executor_tk int(11) DEFAULT NULL,
  step_tk int(11) DEFAULT NULL,
  execution_timestamp DATETIME DEFAULT NULL,
  rows_input int(11) DEFAULT NULL,
  rows_output int(11) DEFAULT NULL,
  rows_read int(11) DEFAULT NULL,
  rows_written int(11) DEFAULT NULL,
  rows_rejected int(11) DEFAULT NULL,
  errors int(11) DEFAULT NULL,
  result char(1) DEFAULT NULL,
  nr_result_rows int(11) DEFAULT NULL,
  nr_result_files int(11) DEFAULT NULL
);
CREATE INDEX IDX_FACT_STEP_EXECUTION_EXECUTION_DATE_TK ON pentaho_operations_mart.fact_jobentry_execution(execution_date_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_EXECUTION_TIME_TK ON pentaho_operations_mart.fact_jobentry_execution(execution_time_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_BATCH_TK ON pentaho_operations_mart.fact_jobentry_execution(batch_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_EXECUTOR_TK ON pentaho_operations_mart.fact_jobentry_execution(executor_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_PARENT_EXECUTOR_TK ON pentaho_operations_mart.fact_jobentry_execution(parent_executor_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_ROOT_EXECUTOR_TK ON pentaho_operations_mart.fact_jobentry_execution(root_executor_tk);
CREATE INDEX IDX_FACT_STEP_EXECUTION_STEP_TK ON pentaho_operations_mart.fact_jobentry_execution(step_tk);


--
-- Definition of table pentaho_operations_mart.FACT_PERF_EXECUTION
--

CREATE TABLE  pentaho_operations_mart.fact_perf_execution (
  execution_date_tk int(11) DEFAULT NULL,
  execution_time_tk int(11) DEFAULT NULL,
  batch_tk int(11) DEFAULT NULL,
  executor_tk int(11) DEFAULT NULL,
  parent_executor_tk int(11) DEFAULT NULL,
  root_executor_tk int(11) DEFAULT NULL,
  step_tk int(11) DEFAULT NULL,
  seq_nr int(11) DEFAULT NULL,
  step_copy int(11) DEFAULT NULL,
  execution_timestamp DATETIME DEFAULT NULL,
  rows_input int(11) DEFAULT NULL,
  rows_output int(11) DEFAULT NULL,
  rows_read int(11) DEFAULT NULL,
  rows_written int(11) DEFAULT NULL,
  rows_rejected int(11) DEFAULT NULL,
  errors int(11) DEFAULT NULL,
  input_buffer_rows int(11) DEFAULT NULL,
  output_buffer_rows int(11) DEFAULT NULL
);
CREATE INDEX IDX_FACT_PERF_EXECUTION_EXECUTION_DATE_TK ON pentaho_operations_mart.fact_perf_execution(execution_date_tk);
CREATE INDEX IDX_FACT_PERF_EXECUTION_EXECUTION_TIME_TK ON pentaho_operations_mart.fact_perf_execution(execution_time_tk);
CREATE INDEX IDX_FACT_PERF_EXECUTION_BATCH_TK ON pentaho_operations_mart.fact_perf_execution(batch_tk);
CREATE INDEX IDX_FACT_PERF_EXECUTION_EXECUTION_TK ON pentaho_operations_mart.fact_perf_execution(step_tk);
CREATE INDEX IDX_FACT_PERF_EXECUTION_EXECUTOR_TK ON pentaho_operations_mart.fact_perf_execution(executor_tk);
CREATE INDEX IDX_FACT_PERF_EXECUTION_PARENT_EXECUTOR_TK ON pentaho_operations_mart.fact_perf_execution(parent_executor_tk);
CREATE INDEX IDX_FACT_PERF_EXECUTION_ROOT_EXECUTOR_TK ON pentaho_operations_mart.fact_perf_execution(root_executor_tk);

CREATE TABLE  pentaho_operations_mart.dim_state (
  state_tk bigint NOT NULL,
  state varchar(100) NOT NULL,
  PRIMARY KEY (state_tk)
) ENGINE = MYISAM;

CREATE TABLE  pentaho_operations_mart.dim_session (
  session_tk bigint NOT NULL,
  session_id varchar(200) NOT NULL,
  session_type varchar(200) NOT NULL,
  username varchar(200) NOT NULL,
  PRIMARY KEY (session_tk)
) ENGINE = MYISAM;

CREATE TABLE  pentaho_operations_mart.dim_instance (
  instance_tk bigint NOT NULL,
  instance_id varchar(200) NOT NULL,
  engine_id varchar(200) NOT NULL,
  service_id varchar(200) NOT NULL,
  content_id varchar(200) NOT NULL,
  content_detail varchar(1024) NOT NULL,
  PRIMARY KEY (instance_tk)
) ENGINE = MYISAM;

CREATE TABLE  pentaho_operations_mart.dim_component (
  component_tk bigint NOT NULL,
  component_id varchar(200) NOT NULL,
  PRIMARY KEY (component_tk)
) ENGINE = MYISAM;

CREATE TABLE pentaho_operations_mart.stg_content_item (
  gid char(36) NOT NULL,
  parent_gid char(36) DEFAULT NULL,
  fileSize int NOT NULL,
  locale varchar(5) DEFAULT NULL,
  name varchar(200) NOT NULL,
  ownerType tinyint(4) NOT NULL,
  path varchar(1024) NOT NULL,
  title varchar(255) DEFAULT NULL,
  is_folder char(1) NOT NULL,
  is_hidden char(1) NOT NULL,
  is_locked char(1) NOT NULL,
  is_versioned char(1) NOT NULL,
  date_created datetime NULL,
  date_last_modified datetime NULL,
  is_processed char(1) DEFAULT NULL,
  PRIMARY KEY (gid),
  KEY gid (parent_gid)
) ENGINE = MYISAM;

CREATE TABLE pentaho_operations_mart.dim_content_item (
  content_item_tk int NOT NULL,
  content_item_title VARCHAR(255) NOT NULL DEFAULT 'NA',
  content_item_locale VARCHAR(255) NOT NULL DEFAULT 'NA',
  content_item_size int NOT NULL DEFAULT 0,
  content_item_path VARCHAR(1024) NOT NULL DEFAULT 'NA',
  content_item_name VARCHAR(255) NOT NULL DEFAULT 'NA',
  content_item_fullname VARCHAR(1024) NOT NULL DEFAULT 'NA',
  content_item_type VARCHAR(32) NOT NULL DEFAULT 'NA',
  content_item_extension VARCHAR(32) NOT NULL DEFAULT 'NA',
  content_item_guid CHAR(36) NOT NULL DEFAULT 'NA',
  parent_content_item_guid CHAR(36) NULL DEFAULT 'NA',
  parent_content_item_tk int NULL,
  content_item_modified datetime NOT NULL DEFAULT '1900-01-01 00:00:00',
  content_item_valid_from datetime NOT NULL DEFAULT '1900-01-01 00:00:00',
  content_item_valid_to datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  content_item_state VARCHAR(16) NOT NULL DEFAULT 'new',
  content_item_version int NOT NULL DEFAULT 0,
  PRIMARY KEY(content_item_tk),
  KEY(content_item_guid, content_item_valid_from)
) ENGINE = MYISAM;

CREATE TABLE  pentaho_operations_mart.fact_session (
  start_date_tk int NOT NULL,
  start_time_tk int NOT NULL,
  end_date_tk int NOT NULL,
  end_time_tk int NOT NULL,
  session_tk bigint NOT NULL,
  state_tk bigint NOT NULL,
  duration numeric(19,3) NOT NULL,
  INDEX IDX_FACT_PERF_SESSION_START_DATE_TK (start_date_tk),
  INDEX IDX_FACT_PERF_SESSION_START_TIME_TK (start_time_tk),
  INDEX IDX_FACT_PERF_SESSION_END_DATE_TK (end_date_tk),
  INDEX IDX_FACT_PERF_SESSION_END_TIME_TK (end_time_tk),
  INDEX IDX_FACT_PERF_SESSION_SESSION_TK (session_tk),
  INDEX IDX_FACT_PERF_SESSION_STATE_TK (state_tk)
) ENGINE = MYISAM;

CREATE TABLE  pentaho_operations_mart.fact_instance (
  start_date_tk int NOT NULL,
  start_time_tk int NOT NULL,
  end_date_tk int NOT NULL,
  end_time_tk int NOT NULL,
  session_tk bigint NOT NULL,
  instance_tk bigint NOT NULL,
  state_tk bigint NOT NULL,
  duration numeric(19,3) NOT NULL,
  INDEX IDX_FACT_PERF_INSTANCE_START_DATE_TK (start_date_tk),
  INDEX IDX_FACT_PERF_INSTANCE_START_TIME_TK (start_time_tk),
  INDEX IDX_FACT_PERF_INSTANCE_END_DATE_TK (end_date_tk),
  INDEX IDX_FACT_PERF_INSTANCE_END_TIME_TK (end_time_tk),
  INDEX IDX_FACT_PERF_INSTANCE_SESSION_TK (session_tk),
  INDEX IDX_FACT_PERF_INSTANCE_INSTANCE_TK (instance_tk),
  INDEX IDX_FACT_PERF_INSTANCE_STATE_TK (state_tk)
) ENGINE = MYISAM;

CREATE TABLE  pentaho_operations_mart.fact_component (
  start_date_tk int NOT NULL,
  start_time_tk int NOT NULL,
  end_date_tk int NOT NULL,
  end_time_tk int NOT NULL,
  session_tk bigint NOT NULL,
  instance_tk bigint NOT NULL,
  state_tk bigint NOT NULL,
  component_tk bigint NOT NULL,
  duration numeric(19,3) NOT NULL,
  INDEX IDX_FACT_PERF_COMPONENT_START_DATE_TK (start_date_tk),
  INDEX IDX_FACT_PERF_COMPONENT_START_TIME_TK (start_time_tk),
  INDEX IDX_FACT_PERF_COMPONENT_END_DATE_TK (end_date_tk),
  INDEX IDX_FACT_PERF_COMPONENT_END_TIME_TK (end_time_tk),
  INDEX IDX_FACT_PERF_COMPONENT_SESSION_TK (session_tk),
  INDEX IDX_FACT_PERF_COMPONENT_INSTANCE_TK (instance_tk),
  INDEX IDX_FACT_PERF_COMPONENT_COMPONENT_TK (component_tk),
  INDEX IDX_FACT_PERF_COMPONENT_STATE_TK (state_tk)
) ENGINE = MYISAM;

CREATE TABLE pentaho_operations_mart.pro_audit_staging (
   job_id varchar(200),
   inst_id varchar(200),
   obj_id varchar(200),
   obj_type varchar(200),
   actor varchar(200),
   message_type varchar(200),
   message_name varchar(200),
   message_text_value varchar(1024),
   message_num_value numeric(19),
   duration numeric(19, 3),
   audit_time datetime NULL,
   INDEX IDX_PRO_AUDIT_STAGING_MESSAGE_TYPE (message_type)
) ENGINE = MYISAM;

CREATE TABLE pentaho_operations_mart.pro_audit_tracker (
   audit_time datetime,
  INDEX IDX_PRO_AUDIT_TRACKER_AUDIT_TIME (audit_time)
) ENGINE = MYISAM;
INSERT INTO pentaho_operations_mart.pro_audit_tracker values ('1970-01-01 00:00:01');

