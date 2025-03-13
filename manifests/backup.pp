# == Class: bitbucket::backup
#
# This installs the bitbucket backup client
#
# @param manage_backup
#   Whether to manage the backup
# @param ensure
#   The state of the backup (present/absent)
# @param schedule_weekday
#   Day of the week to run backup
# @param schedule_hour
#   Hour to run backup
# @param schedule_minute
#   Minute to run backup
# @param backup_base_url
#   Base URL for backup
# @param backupuser
#   Username for backup
# @param backuppass
#   Password for backup
# @param version
#   Version of backup client
# @param product
#   Product name
# @param backup_format
#   Format of backup file
# @param homedir
#   Home directory path
# @param user
#   System user
# @param group
#   System group
# @param download_url
#   URL to download backup client
# @param backup_home
#   Backup home directory
# @param javahome
#   Java home directory
# @param keep_age
#   How long to keep backups
# @param manage_usr_grp
#   Whether to manage user/group
#
class bitbucket::backup (
  Boolean $manage_backup                  = $bitbucket::manage_backup,
  String $ensure                         = $bitbucket::backup_ensure,
  Variant[Integer,String] $schedule_weekday = $bitbucket::backup_schedule_day,
  Variant[Integer,String] $schedule_hour = $bitbucket::backup_schedule_hour,
  Variant[Integer,String] $schedule_minute = $bitbucket::backup_schedule_minute,
  String $backup_base_url                = $bitbucket::backup_base_url,
  String $backupuser                     = $bitbucket::backupuser,
  String $backuppass                     = $bitbucket::backuppass,
  String $version                        = $bitbucket::backupclient_version,
  String $product                        = $bitbucket::product,
  String $backup_format                  = $bitbucket::backup_format,
  Stdlib::Absolutepath $homedir          = $bitbucket::homedir,
  String $user                           = $bitbucket::user,
  String $group                          = $bitbucket::group,
  Optional[String] $download_url         = $bitbucket::backupclient_url,
  String $backup_home                   = $bitbucket::backup_home,
  Optional[Stdlib::Absolutepath] $javahome         = $bitbucket::javahome,
  String $keep_age                       = $bitbucket::backup_keep_age,
  Boolean $manage_usr_grp                = $bitbucket::manage_usr_grp,
) {
  if $manage_backup {
    $appdir = "${backup_home}/${product}-backup-client-${version}"

    file { $backup_home:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }
    file { "${backup_home}/archives":
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }

    $file = "${product}-backup-distribution-${version}.${backup_format}"

    file { $appdir:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }

    file { '/var/tmp/downloadurl':
      content => "${download_url}/${version}/${file}",
    }

    archive { "/tmp/${file}":
      ensure       => present,
      extract      => true,
      extract_path => $backup_home,
      source       => "${download_url}/${version}/${file}",
      user         => $user,
      group        => $group,
      creates      => "${appdir}/lib",
      cleanup      => true,
      before       => File[$appdir],
    }

    if $javahome {
      $java_bin = "${javahome}/bin/java"
    } else {
      $java_bin = '/usr/bin/java'
    }

    # Enable Cronjob
    if $bitbucket::tomcat_ssl {
      $backup_cmd = "${java_bin} -Djavax.net.ssl.trustStore=${homedir}/shared/config/ssl-keystore -Dbitbucket.password='${backuppass}' -Dbitbucket.user='${backupuser}' -Dbitbucket.baseUrl='${backup_base_url}' -Dbitbucket.home=${homedir} -Dbackup.home=${backup_home}/archives -jar ${appdir}/bitbucket-backup-client.jar"
    }
    else {
      $backup_cmd = "${java_bin} -Dbitbucket.password='${backuppass}' -Dbitbucket.user='${backupuser}' -Dbitbucket.baseUrl='${backup_base_url}' -Dbitbucket.home=${homedir} -Dbackup.home=${backup_home}/archives -jar ${appdir}/bitbucket-backup-client.jar"
    }

    cron { 'Backup Bitbucket':
      ensure  => $ensure,
      command => $backup_cmd,
      user    => $user,
      hour    => $schedule_hour,
      minute  => $schedule_minute,
      weekday => $schedule_weekday,
    }

    tidy { 'remove_old_archives':
      path    => "${backup_home}/archives",
      age     => $keep_age,
      matches => '*.tar',
      type    => 'mtime',
      recurse => 2,
    }
  }
}
