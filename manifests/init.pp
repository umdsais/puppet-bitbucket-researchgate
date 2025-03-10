# == Class: bitbucket
#
# This modules installs Atlassian bitbucket.
#
# === Parameters
#
# JVM Settings:
# [*javahome*]
#   Java installation directory
# [*jvm_xms*]
#   Initial JVM heap size
# [*jvm_xmx*]
#   Maximum JVM heap size
# [*jvm_permgen*]
#   PermGen memory size
# [*jvm_optional*]
#   Additional JVM options
# [*jvm_support_recommended_args*]
#   Recommended JVM arguments
# [*java_opts*]
#   Additional java options
# [*umask*]
#   Process umask
# [*additional_env*]
#   Additional environment variables
#
# Bitbucket Settings:
# [*version*]
#   Bitbucket version to install
# [*product*]
#   Product name (bitbucket)
# [*format*]
#   Installation archive format
# [*installdir*]
#   Installation directory
# [*homedir*]
#   Home directory
# [*context_path*]
#   Context path for web interface
# [*tomcat_port*]
#   Port for web interface
# [*tomcat_ssl*]
#   Enable SSL support
# [*logdir*]
#   Log directory location
# [*log_maxhistory*]
#   Days to keep logs
# [*log_maxsize*]
#   Maximum log size
#
# User/Group Settings:
# [*manage_usr_grp*]
#   Whether to manage user/group
# [*user*]
#   Service user
# [*group*]
#   Service group
# [*uid*]
#   User ID
# [*gid*]
#   Group ID
#
# Database Settings:
# [*dbuser*]
#   Database user
# [*dbpassword*]
#   Database password
# [*dburl*]
#   Database URL
# [*dbdriver*]
#   Database driver
#
# Data Center Settings:
# [*hazelcast_network*]
#   Hazelcast network address
# [*hazelcast_group_name*]
#   Hazelcast group name
# [*hazelcast_group_password*]
#   Hazelcast group password
# [*elasticsearch_baseurl*]
#   Elasticsearch base URL
# [*elasticsearch_username*]
#   Elasticsearch username
# [*elasticsearch_password*]
#   Elasticsearch password
#
# Backup Settings:
# [*manage_backup*]
#   Whether to manage backup
# [*backup_ensure*]
#   Backup presence (present/absent)
# [*backupclient_url*]
#   Backup client download URL
# [*backup_format*]
#   Backup archive format
# [*backupclient_version*]
#   Backup client version
# [*backup_home*]
#   Backup home directory
# [*backupuser*]
#   Backup user
# [*backuppass*]
#   Backup password
# [*backup_schedule_day*]
#   Backup schedule day
# [*backup_schedule_hour*]
#   Backup schedule hour
# [*backup_schedule_minute*]
#   Backup schedule minute
# [*backup_keep_age*]
#   Backup retention period
#
# Service Settings:
# [*service_manage*]
#   Whether to manage service
# [*service_ensure*]
#   Service state (running/stopped)
# [*service_enable*]
#   Enable service at boot
# [*service_options*]
#   Additional service options
#
# Initialization Settings:
# [*display_name*]
#   Display name for the Bitbucket instance
# [*base_url*]
#   Base URL where Bitbucket will be accessible
# [*license*]
#   Bitbucket license key
# [*sysadmin_username*]
#   Admin username for initial setup
# [*sysadmin_password*]
#   Admin password for initial setup
# [*sysadmin_name*]
#   Admin display name
# [*sysadmin_email*]
#   Admin email address
# [*config_properties*]
#   Hash of additional configuration properties
#
# Installation Settings:
# [*download_url*]
#   URL to download Bitbucket package
# [*checksum*]
#   MD5 checksum of the package
# [*backup_base_url*]
#   Base URL for backup location
# [*backup_keystore*]
#   Path to SSL keystore for backups
# [*proxy*]
#   Hash of proxy server settings
# [*stop_bitbucket*]
#   Command to stop Bitbucket service
# [*deploy_module*]
#   Module to use for deployment (archive/staging)
# [*application_tunnel_allowed*]
#   Whether to enable application tunneling
#
class bitbucket (

  # JVM Settings
  Optional[Stdlib::Absolutepath] $javahome = undef,
  String $jvm_xms                          = '256m',
  String $jvm_xmx                          = '1024m',
  String $jvm_permgen                      = '256m',
  Array[String] $jvm_optional              = ['-XX:-HeapDumpOnOutOfMemoryError'],
  Optional[String] $jvm_support_recommended_args     = undef,
  Optional[Variant[String,Array[String]]] $java_opts = undef,
  Optional[String] $umask                  = undef,
  Optional[Hash] $additional_env           = undef,

  # Bitbucket Settings
  String $version                          = '7.2.2',
  String $product                          = 'bitbucket',
  String $format                           = 'tar.gz',
  Stdlib::Absolutepath $installdir         = '/opt/bitbucket',
  Stdlib::Absolutepath $homedir            = '/home/bitbucket',
  Optional[String] $context_path           = undef,
  Integer $tomcat_port                     = 7990,
  Boolean $tomcat_ssl                      = false,
  Stdlib::Absolutepath $logdir             = "${homedir}/log",
  Integer $log_maxhistory                  = 31, # days
  String $log_maxsize                      = '25MB',

  # User and Group Management Settings
  Boolean $manage_usr_grp                  = true,
  String $user                             = 'atlbitbucket',
  String $group                            = 'atlbitbucket',
  Optional[Integer] $uid                   = undef,
  Optional[Integer] $gid                   = undef,

  # Bitbucket 4.6.0 initialization configurations
  String $display_name                     = 'bitbucket',
  String $base_url                         = "https://${facts['networking']['fqdn']}",
  Optional[String] $license                = undef,
  String $sysadmin_username                = 'admin',
  String $sysadmin_password                = 'bitbucket',
  String $sysadmin_name                    = 'Bitbucket Admin',
  Optional[String] $sysadmin_email         = undef,
  Hash $config_properties                  = {},

  # Database Settings
  String $dbuser                           = 'bitbucket',
  String $dbpassword                       = 'password',
  String $dburl                            = 'jdbc:postgresql://localhost:5432/bitbucket',
  String $dbdriver                         = 'org.postgresql.Driver',

  # Data Center Settings
  Optional[String] $hazelcast_network           = undef,
  Optional[String] $hazelcast_group_name        = undef,
  Optional[String] $hazelcast_group_password    = undef,
  Optional[String] $elasticsearch_baseurl       = undef,
  Optional[String] $elasticsearch_username      = undef,
  Optional[String] $elasticsearch_password      = undef,

  # Misc Settings
  String $download_url                     = 'https://product-downloads.atlassian.com/software/stash/downloads',
  Optional[String] $checksum               = undef,

  # Backup Settings
  Boolean $manage_backup                   = true,
  String $backup_ensure                    = 'present',
  String $backupclient_url                 = 'https://maven.atlassian.com/content/groups/public/com/atlassian/bitbucket/server/backup/bitbucket-backup-distribution',
  String $backup_format                    = 'zip',
  String $backupclient_version             = '3.6.0',
  Stdlib::Absolutepath $backup_home        = '/opt/bitbucket-backup',
  String $backupuser                       = 'admin',
  String $backuppass                       = 'password',
  Variant[Integer,String] $backup_schedule_day = '1-5',
  Variant[Integer,String] $backup_schedule_hour = '5',
  Variant[Integer,String] $backup_schedule_minute = '0',
  String $backup_keep_age                  = '4w',
  String $backup_base_url                  = $bitbucket::base_url,
  String $backup_keystore        = "${bitbucket::homedir}/shared/config/ssl-keystore",

  # Manage service
  Boolean $service_manage                  = true,
  String $service_ensure                   = 'running',
  Boolean $service_enable                  = true,
  Optional[Variant[String,Array[String]]] $service_options = undef,

  # Reverse https proxy
  Hash $proxy                             = {},

  # Command to stop bitbucket in preparation to updgrade. # This is configurable
  # incase the bitbucket service is managed outside of puppet. eg: using the
  # puppetlabs-corosync module: 'crm resource stop bitbucket && sleep 15'
  String $stop_bitbucket                  = 'service bitbucket stop && sleep 15',

  # Choose whether to use nanliu-staging, or puppet-archive
  String $deploy_module                    = 'archive',

  # Chose whether options for application tunnel should be enabled
  Boolean $application_tunnel_allowed      = false,
) {
  include bitbucket::params

  Exec { path => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'] }

  $webappdir    = "${installdir}/atlassian-${product}-${version}"

  if $facts['bitbucket_version'] {
    # If the running version of bitbucket is less than the expected version of bitbucket
    # Shut it down in preparation for upgrade.
    if $facts['bitbucket_version'] != '-1' and
    versioncmp($version, $facts['bitbucket_version']) > 0 {
      notify { 'Attempting to upgrade bitbucket': }
      exec { $stop_bitbucket: }
      if versioncmp($version, '3.2.0') > 0 {
        exec { "rm -f ${homedir}/stash-config.properties": }
      }
    }
  }

  # Replace anchor pattern with contain
  contain bitbucket::install
  contain bitbucket::config
  contain bitbucket::service
  contain bitbucket::backup

  # Define relationships
  Class['bitbucket::install']
  -> Class['bitbucket::config']
  ~> Class['bitbucket::service']
  -> Class['bitbucket::backup']
}
